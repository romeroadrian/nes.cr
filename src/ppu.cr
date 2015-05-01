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
    # TODO mirroring?
    @palette[address]
  end

  def write_palette(address, value)
    # TODO mirroring?
    @palette[address] = value
  end

  def step
    #increase cycles and scanlines, check for frame complete
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

  private def base_nametable_address
    @control && 0x3
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

  # control register
  # 7654 3210
  # VPHB SINN
end
