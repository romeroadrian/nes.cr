require "./bool"
require "./color"

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
  @tile_data_store :: UInt32
  @attr_data_store :: UInt16
  @buffer_vram :: UInt8

  getter shown
  setter cpu

  private getter! memory
  private getter! cpu

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
    @sprite_collision = false
    @in_vblank = false
    @buffer_vram = 0_u8
    @tile_data_store = 0_u32
    @attr_data_store = 0_u16

    @oam = StaticArray(UInt8, 256).new { 0_u8 }
    @secondary_oam = StaticArray(UInt8, 32).new { 0_u8 }
    @sprite_tile_data = StaticArray(UInt16, 8).new { 0_u16 }
    @sprite_attr_data = StaticArray(UInt8, 8).new { 0_u8 }
    @sprite_x_data = StaticArray(UInt8, 8).new { 0_u8 }
    @sprite_count = 0

    @palette = StaticArray(UInt8, 32).new { 0_u8 }

    @cycle = 0
    @scan_line = 241
    @frame = 0

    @current = Array(Array(Int32)).new(256) do
      Array(Int32).new(240) { 0 }
    end
    @shown = Array(Array(Int32)).new(256) do
      Array(Int32).new(240) { 0 }
    end

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

    if number != 2
      @last_register = value
    end
  end

  # 0x4014 = OAMDMA
  def dma_address=(value)
    address = value.to_u16 * 256
    256.times do |i|
      @oam[@oam_address] = cpu.read(address + i)
      @oam_address += 1
    end
    cpu.suspend_for(cpu.cycles % 2 == 1 ? 514 : 513)
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
    if rendering_enabled?
      if visible_scan_line? && visible_cycle?
        render
      end

      if (visible_scan_line? || pre_scan_line?) && fetch_cycle?
        fetch_data
      end

      if @cycle == 256 && render_scan_line?
        increment_y!
      end

      if @cycle == 257 && render_scan_line?
        copy_x_from_temp
      end

      if pre_scan_line? && @cycle >= 280 && @cycle <= 304
        copy_y_from_temp
      end

      if fetch_cycle? && @cycle % 8 == 0 && render_scan_line?
        increment_x!
      end
    end

    # Sprite evaluation for next scanline happens between cycle 65 and
    # 256, in visible scanlines
    if rendering_enabled? && visible_scan_line?
      if @cycle == 63
        clear_secondary_oam
      end
      if @cycle == 256
        evaluate_sprites
      end
      if @cycle == 319
        fetch_sprites
      end
    end

    # Set vblank flag in scanline = 241 and cycle = 1
    if @scan_line == 241 && @cycle == 1
      @in_vblank = true
      @current, @shown = @shown, @current
      if should_generate_nmi?
        cpu.interrupt :nmi
      end
    end

    # Clear vblank flag, sprite 0 and sprite overflow in scanline = 261 and cycle =1
    if pre_scan_line? && @cycle == 1
      @in_vblank = false
      @sprite_collision = false
      @sprite_overflow = false
    end

    # Increase cycles and scanlines, check for frame complete
    # Odd frames are 1 cycle shorter IF rendering is enabled
    if rendering_enabled? && pre_scan_line? && @cycle == 339 && (@frame % 2 == 1)
      @cycle += 1
    end

    @cycle += 1
    if @cycle > 340
      @cycle = 0
      @scan_line += 1
      if @scan_line > 261
        @scan_line = 0
        @frame += 1
      end
    end
  end

  private def render
    x = @cycle - 1
    y = @scan_line
    # TODO: priority of sprite over background
    background_color = render_background
    sprite_color = render_sprite

    color = if sprite_color % 4 == 0
      background_color
    else
      sprite_color | 0x10
    end

    color_index = read_palette(color.to_u16)
    @current[x][y] = Color::Palette[color_index]
  end

  private def render_background
    if show_background?
      attribute = (@attr_data_store >> 8).to_u8
      tile = (@tile_data_store >> 16).to_u16
      l_index = 7 - ((@cycle - 1) % 8)
      h_index = l_index + 8
      # select bit from low tile
      l = ((tile & (0x1 << l_index)) >> l_index).to_u8
      # select bit from high tile
      h = ((tile & (0x1 << h_index)) >> (h_index - 1)).to_u8
      # TODO fine x scrolling!
      attribute | h | l
    else
      0_u8
    end
  end

  private def render_sprite
    color = 0_u8
    if show_sprites?
      i = 0
      current_x = @cycle - 1
      while color == 0 && i < @sprite_count
        x = @sprite_x_data[i]
        if x <= current_x && current_x < x + 8
          tile = @sprite_tile_data[i]
          attr = @sprite_attr_data[i]
          flip_h = (attr >> 6) & 0x1 == 0x1
          offset = current_x - x
          l_index = flip_h ? offset : 7 - offset
          h_index = l_index + 8
          l = ((tile & (0x1 << l_index)) >> l_index).to_u8
          h = ((tile & (0x1 << h_index)) >> (h_index - 1)).to_u8
          color = ((attr & 0x3) << 2) | h | l
        end
        i += 1
      end
    end
    color
  end

  private def store_background_data
    # shift registers
    @attr_data_store <<= 8
    @tile_data_store <<= 16
    # save current attribute and tile data
    @attr_data_store = (@attr_data_store & 0xFF00) | @attr_table_data.to_u16
    @tile_data_store = (@tile_data_store & 0xFFFF0000) |
                       (@tile_high_data.to_u32 << 8) |
                        @tile_low_data.to_u32
  end

  # Fetch data to render next tile, this happens every 8 cycles
  # 1.Nametable byte
  # 2.Attribute table byte
  # 3.Tile bitmap low
  # 4.Tile bitmap high (+8 bytes from tile bitmap low)
  private def fetch_data
    case @cycle % 8
    when 0
      # store fetched data to be used when rendering background in next 8 cycles
      store_background_data
    when 1 # 1 and 2
      # tile address = 0x2000 | (v & 0x0FFF)
      address = 0x2000_u16 | (@vram_address & 0x0FFF)
      @name_table_data = memory.read(address)
    when 3 # 3 and 4
      # base attribute table address + name table selector (bits 10-11) of vram +
      # + 3 hi bits of y coarse + 3 hi bits of x coarse
      # attribute address = 0x23C0 | (v & 0x0C00) | ((v >> 4) & 0x38) | ((v >> 2) & 0x07)
      address = 0x23C0_u16 | (@vram_address & 0x0C00) | ((@vram_address >> 4) & 0x38) | ((@vram_address >> 2) & 0x07)
      # attribute shift = ((v >> 4) & 0x04) | (v & 0x02)
      shift = ((@vram_address >> 4) & 0x04) | (@vram_address & 0x02)
      value = memory.read(address)
      # shift attribute table and select bits 1-0
      @attr_table_data = ((value >> shift) & 0x03) << 2
    when 5 # 5 and 6
      # low order byte of pattern table
      @tile_low_data = memory.read(pattern_table_address)
    when 7 # 7 and 8
      # high order byte of pattern table
      @tile_high_data = memory.read(pattern_table_address + 8)
    end
  end

  private def pattern_table_address
    # pattern table selector + offset using name table index + fine y scroll
    background_pattern_table + @name_table_data.to_u16 * 16 + ((@vram_address >> 12) & 0x7_u16)
  end

  private def clear_secondary_oam
    32.times { |i| @secondary_oam[i] = 0xFF_u8 }
  end

  private def evaluate_sprites
    @sprite_count = 0
    height = sprite_size_16? ? 16 : 8
    64.times do |i|
      y = @oam[i * 4]
      # if it's in range, add to secondary oam
      if y <= @scan_line && @scan_line < y + height
        @secondary_oam[@sprite_count * 4]     = y
        @secondary_oam[@sprite_count * 4 + 1] = @oam[i * 4 + 1]
        @secondary_oam[@sprite_count * 4 + 2] = @oam[i * 4 + 2]
        @secondary_oam[@sprite_count * 4 + 3] = @oam[i * 4 + 3]

        @sprite_count += 1

        if @sprite_count == 8
          @sprite_overflow = true
          break
        end
      end
    end
  end

  private def fetch_sprites
    # process secondary oam into sprite data registers
    @sprite_count.times do |i|
      y     = @secondary_oam[i * 4]
      index = @secondary_oam[i * 4 + 1]
      attrs = @secondary_oam[i * 4 + 2]
      x     = @secondary_oam[i * 4 + 3]

      current_y = @scan_line - y.to_i

      # flip vertical
      if (attrs >> 7) == 0x1
        current_y = (sprite_size_16? ? 15 : 7) - current_y
      end

      base_address = if sprite_size_16?
        index & 0x1 == 0 ? 0x0000_u16 : 0x1000_u16
      else
        sprite_pattern_table
      end

      offset = sprite_size_16? ? index & 0xFE : index

      if sprite_size_16? && current_y > 7
        offset += 1
        current_y -= 8
      end

      address = base_address + offset.to_u16 * 16 + current_y.to_u16
      low_tile = memory.read(address)
      high_tile = memory.read(address + 8)

      @sprite_tile_data[i] = (high_tile.to_u16 << 8) | low_tile.to_u16
      @sprite_attr_data[i] = attrs
      @sprite_x_data[i]    = x
    end
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
    status |= @sprite_collision.to_u8 << 6
    status |= @in_vblank.to_u8 << 7
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
    value = memory.read(@vram_address)

    # TODO check mirroring?
    if @vram_address <= 0x3EFF
      tmp = @buffer_vram
      @buffer_vram = value
      value = tmp
    else
      # buffer is still updated using the data mirrored from $2F00-$2FFF
      @buffer_vram = memory.read(@vram_address - 0x1000)
    end

    @vram_address += vram_increment

    value
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

  private def render_scan_line?
    visible_scan_line? || pre_scan_line?
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
