require "./bool"

class Ppu

  @control :: UInt8
  @mask :: UInt8
  @oam_address :: UInt8
  @vram_address :: UInt16
  @temp_vram_address :: UInt16
  @address_latch :: Bool
  @scroll_x :: UInt8
  @last_register :: UInt8
  @name_table_data :: UInt8
  @attr_table_data :: UInt8
  @tile_low_data :: UInt8
  @tile_high_data :: UInt8

  private getter! memory

  def initialize(rom)
    @control = 0_u8
    @mask = 0_u8
    @last_register = 0_u8
    @oam_address = 0_u8
    @vram_address = 0_u16
    @temp_vram_address = 0_u16
    @scroll_x = 0_u8
    @address_latch = false
    @sprite_overflow = false
    @spite_collision = false
    @in_vblank = false

    @oam = StaticArray(UInt8, 256).new { 0_u8 }
    @palette = StaticArray(UInt8, 32).new { 0_u8 }

    @cycle = 0
    @scan_line = 0
    @frame = 0

    @current = Array(Array(UInt8)).new
    @shown = Array(Array(UInt8)).new

    @name_table_data = 0_u8
    @attr_table_data = 0_u8
    @tile_low_data = 0_u8
    @tile_high_data = 0_u8

    @memory = PpuMemory.new rom, self
  end

  def read_register(number)
    case number
    when 2 # 0x2002 = PPUSTATUS
      read_status
    when 4 # 0x2004 = OAMDATA
      @oam[@oam_address]
    when 7 # 0x2007 = PPUDATA
      read_vram
    else
      raise "Can't read PPU register #{number}"
    end
  end

  def write_register(number, value)
    case number
    when 0 # 0x2000 = PPUCTRL
      write_control value
    when 1 # 0x2001 = PPUMASK
      @mask = value
    when 3 # 0x2003 = OAMADDR
      @oam_address = value
    when 4 # 0x2004 = OAMDATA
      @oam[@oam_address] = value
      @oam_address += 1
    when 5 # 0x2005 = PPUSCROLL
      write_scroll value
    when 6 # 0x2006 = PPUADDR
      write_address value
    when 7 # 0x2007 = PPUDATA
      write_vram value
    end
  end

  # 0x4014 = OAMDMA
  def dma_address=(value)
    address = value.to_u16 * 256
    0.upto(255) do |i|
      # @oam[@oam_address] = @nes.cpu.read(address + i)
      # TODO wire cpu or cpu_memory
      @oam[@oam_address] = 0_u8
      @oam_address += 1
    end
    # TODO CPU should be suspended
    # The CPU is suspended during the transfer, which will take 513 or 514 cycles after the $4014 write tick. (1 idle cycle, +1 if on an odd CPU cycle, then 256 alternating read/write cycles.)
  end

  def read_palette(address)
    @palette[mirror_palette(address)]
  end

  def write_palette(address, value)
    @palette[mirror_palette(address)] = value
  end

  private def mirror_palette(address)
    # 0x10 -> 0x00, 0x14 -> 0x04, 0x18 -> 0x08, 0x1C -> 0x0C
    address >= 0x10 && address % 0x04 == 0 ? address - 0x10 : address
  end

  def step
    #increase cycles and scanlines, check for frame complete
    # TODO odd frames are 1 cycle shorter IF rendering is enabled
    @cycle += 1
    if @cycle > 340
      @cycle = 0
      @scan_line += 1
      if @scan_line > 261
        @scan_line = 0
        @frame += 1
      end
    end

    if rendering_enabled? && visible_scan_line? && visible_cycle?
      render
    end

    if rendering_enabled? && visible_scan_line? && fetch_cycle?
      fetch_data
    end


    # At dot 256 of each scanline -> If rendering is enabled, the PPU
    # increments the vertical position in v
    if @cycle == 256 && rendering_enabled?
      increment_y!
    end

    # At dot 257 of each scanline -> If rendering is enabled, the PPU copies
    # all bits related to horizontal position from t to v:
    if @cycle == 257 && rendering_enabled?
      copy_x_from_temp
    end

    # During dots 280 to 304 of the pre-render scanline (end of vblank)
    # If rendering is enabled, at the end of vblank, shortly after the horizontal
    # bits are copied from t to v at dot 257, the PPU will repeatedly copy the vertical
    # bits from t to v from dots 280 to 304
    if @scan_line == 261 && @cycle >= 280 && @cycle <= 304 && rendering_enabled?
      copy_y_from_temp
    end

    # Between dot 328 of a scanline, and 256 of the next scanline
    # If rendering is enabled, the PPU increments the horizontal position
    # in v many times across the scanline, it begins at dots 328 and 336,
    # and will continue through the next scanline at 8, 16, 24... 240, 248,
    # 256 (every 8 dots across the scanline until 256).
    # The effective X scroll coordinate is incremented, which will wrap to
    # the next nametable appropriately. See Wrapping around below.
    if ((@cycle >= 328 && @cycle <= 336) ||
       (@cycle >= 1 && @cycle <= 256)) && @cycle % 8 == 0 && rendering_enabled?

        increment_x!
    end

    # Sprite evaluation for next scanline happens between cycle 65 and
    # 256, in visible scanlines

    # Set vblank flag in scanline = 241 and cycle = 1
    if @scan_line == 241 && @cycle == 1
      @in_vblank = true
    end

    # Clear vblank flag, sprite 0 and sprite overflow in scanline = 261 and cycle =1
    if @scan_line == 261 && @cycle == 1
      @in_vblank = false
      @spite_collision = false
      @sprite_overflow = false
    end
  end

  private def render
  end

  private def fetch_data
    case @cycle % 8
    when 1 # 1 and 2
      # tile address = 0x2000 | (v & 0x0FFF)
      address = 0x2000_u16 | (@vram_address && 0x0FFF)
      @name_table_data = memory.read(address).not_nil!
    when 3 # 3 and 4
      # attribute address = 0x23C0 | (v & 0x0C00) | ((v >> 4) & 0x38) | ((v >> 2) & 0x07)
      address = 0x23C0_u16 | (@vram_address & 0x0C00) | ((@vram_address >> 4) & 0x38) | ((@vram_address >> 2) & 0x07)
      # TODO should we calculate the tile data INSIDE the attr table
      # data of 32x32 or should we delay this when rendering?
      @attr_table_data = memory.read(address).not_nil!
    when 5 # 5 and 6
      # low order byte of pattern table
      @tile_low_data = memory.read(pattern_table_address).not_nil!
    when 7 # 7 and 8
      # high order byte of pattern table
      @tile_high_data = memory.read(pattern_table_address + 8).not_nil!
    end
  end

  private def pattern_table_address
    background_pattern_table + @name_table_data.to_u16 * 16 + (@vram_address >> 12) & 7
  end

  def write_control(value)
    @control = value
    # t: ....BA.. ........ = d: ......BA
    @temp_vram_address = (@temp_vram_address & 0xF3FF) | ((value.to_u16 & 0x3) << 10)
    # TODO After power/reset, writes to this register are ignored for about 30000 cycles.
    # TODO check for nmi
    # TODO When turning on the NMI flag in bit 7, if the PPU is currently in vertical blank and the PPUSTATUS ($2002) vblank flag is set, an NMI will be generated immediately. This can result in graphical errors (most likely a misplaced scroll) if the NMI routine is executed too late in the blanking period to finish on time. To avoid this problem it is prudent to read $2002 immediately before writing $2000 to clear the vblank flag.
  end

  private def pack_status
    status = @last_register & 0x1F
    status |= @sprite_overflow.to_u8 << 5
    status |= @spite_collision.to_u8 << 6
    status |= @in_vblank.to_u8 << 5
  end

  private def read_status
    @address_latch = false
    pack_status
  end

  private def write_scroll(value)
    if @address_latch # second write
      # t: .CBA..HG FED..... = d: HGFEDCBA
      # w:                   = 0
      @temp_vram_address =
        (@temp_vram_address & 0x8C1F) | ((value.to_u16 & 0x7) << 12)  | ((value.to_u16 >> 3) << 5)
    else # first write
      # t: ....... ...HGFED = d: HGFED...
      # x:              CBA = d: .....CBA
      # w:                  = 1
      @temp_vram_address = (@temp_vram_address & 0xFFE0) | (value.to_u16 >> 3)
      @scroll_x = value & 0x7
    end
    @address_latch = !@address_latch
  end

  private def write_address(value)
    if @address_latch # second write
      # t: ....... HGFEDCBA = d: HGFEDCBA
      # v                   = t
      # w:                  = 0
      @temp_vram_address = (@temp_vram_address & 0xFF00) | value.to_u16
      @vram_address = @temp_vram_address
    else # first write
      # t: ..FEDCBA ........ = d: ..FEDCBA
      # t: .X...... ........ = 0
      # w:                   = 1
      @temp_vram_address = (@temp_vram_address & 0x80FF) | ((value.to_u16 & 0x3F) << 8)
    end
    @address_latch = !@address_latch
  end

  private def read_vram
    # TODO buffer
    # The PPUDATA read buffer (post-fetch)
    # When reading while the VRAM address is in the range 0-$3EFF (i.e., before the palettes), the read will return the contents of an internal read buffer. This internal buffer is updated only when reading PPUDATA, and so is preserved across frames. After the CPU reads and gets the contents of the internal buffer, the PPU will immediately update the internal buffer with the byte at the current VRAM address. Thus, after setting the VRAM address, one should first read this register and discard the result.
    # Reading palette data from $3F00-$3FFF works differently. The palette data is placed immediately on the data bus, and hence no dummy read is required. Reading the palettes still updates the internal buffer though, but the data placed in it is the mirrored nametable data that would appear "underneath" the palette. (Checking the PPU memory map should make this clearer.)
    value = memory.read @vram_address
    @vram_address += vram_increment
    value.not_nil!
  end

  private def write_vram(value)
    memory.write @vram_address, value
    @vram_address += vram_increment
  end

  private def vram_increment
    # control bit 2 = 0 => +1
    #                 1 => +32
    (@control >> 2) & 1 == 1 ? 32 : 1
  end

  private def show_background_in_corner?
    (@mask >> 1) & 1 == 1
  end

  private def show_sprites_in_corner?
    (@mask >> 2) & 1 == 1
  end

  private def show_background?
    (@mask >> 3) & 1 == 1
  end

  private def show_sprites?
    (@mask >> 4) & 1 == 1
  end

  private def rendering_enabled?
    show_background? || show_sprites?
  end

  # TODO delete?
  # this bits are written to temp_vram_address when writing @control
  private def base_nametable_address
    0x2000_u16 + (@control && 0x3).to_u16 * 0x400_u16
  end

  private def sprite_pattern_table
    (@control >> 3) & 1 == 1 ? 0x1000_u16 : 0x0000_u16
  end

  private def background_pattern_table
    (@control >> 4) & 1 == 1 ? 0x1000_u16 : 0x0000_u16
  end

  private def sprite_size_16?
    (@control >> 5) & 1 == 1
  end

  private def should_generate_nmi?
    (@control >> 7) & 1 == 1
  end

  private def increment_x!
    if (@vram_address & 0x001F) == 31
      @vram_address &= 0xFFE0 # coarse X = 0
      @vram_address ^= 0x0400 # switch horizontal nametable
    else
      @vram_address += 1 # increment coarse X
    end
  end

  private def increment_y!
    if (@vram_address & 0x7000) != 0x7000 # if fine Y < 7
      @vram_address += 0x1000 # increment fine Y
    else
      @vram_address &= 0x8FFF # fine Y = 0
      y = (@vram_address & 0x03E0) >> 5 # y = coarse Y
      if y == 29
        y = 0 # coarse Y = 0
        @vram_address ^= 0x0800 # switch vertical nametable
      elsif y == 31
        y = 0 # coarse Y = 0, nametable not switched
      else
        y += 1 # increment coarse Y
      end
      @vram_address = (@vram_address & 0xFC1F) | (y << 5) #put coarse Y back into v
    end
  end

  private def copy_x_from_temp
    # v: ....F.. ...EDCBA = t: ....F.. ...EDCBA
    @vram_address = (@vram_address & 0xFBE0) | (@temp_vram_address & 0x041F)
  end

  private def copy_y_from_temp
    # v: IHGF.ED CBA..... = t: IHGF.ED CBA.....
    @vram_address = (@vram_address & 0x841F) | (@temp_vram_address & 0x7BE0)
  end

  private def visible_scan_line?
    @scan_line < 240
  end

  private def pre_scan_line?
    @scan_line == 261
  end

  private def post_scan_line?
    @scan_line == 240
  end

  private def vblank_scan_line?
    @scan_line > 240 && @scan_line < 261
  end

  private def visible_cycle?
    @cycle >= 1 && @cycle <= 256
  end

  private def fetch_cycle?
    visible_cycle? || (@cycle >= 321 && @cycle <= 336)
  end

  # control register
  # 7654 3210
  # VPHB SINN
end
