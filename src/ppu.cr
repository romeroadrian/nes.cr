require "./bool"

class Ppu

  @control :: UInt8
  @mask :: UInt8
  @oam_address :: UInt8
  @vram_address :: UInt16
  @address_latch :: Bool
  @scroll_x :: UInt8
  @scroll_y :: UInt8
  @last_register :: UInt8

  def initialize(rom)
    @control = 0_u8
    @mask = 0_u8
    @last_register = 0_u8
    @oam_address = 0_u8
    @vram_address = 0_u16
    @scroll_x = 0_u8
    @scroll_y = 0_u8
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
      @control = value
      # TODO After power/reset, writes to this register are ignored for about 30000 cycles.
      # TODO check for nmi
      # TODO When turning on the NMI flag in bit 7, if the PPU is currently in vertical blank and the PPUSTATUS ($2002) vblank flag is set, an NMI will be generated immediately. This can result in graphical errors (most likely a misplaced scroll) if the NMI routine is executed too late in the blanking period to finish on time. To avoid this problem it is prudent to read $2002 immediately before writing $2000 to clear the vblank flag.
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
    if @address_latch # write to y
      @scroll_y = value
    else
      @scroll_x = value
    end
    @address_latch = !@address_latch
  end

  private def write_address(value)
    if @address_latch # write to low
      @vram_address = (@vram_address & 0xFF00) | value.to_u16
    else # write to hi
      @vram_address = (@vram_address & 0x00FF) | (value.to_u16 << 8)
    end
    @address_latch = !@address_latch
  end

  private def read_vram
    # TODO buffer
    # The PPUDATA read buffer (post-fetch)
    # When reading while the VRAM address is in the range 0-$3EFF (i.e., before the palettes), the read will return the contents of an internal read buffer. This internal buffer is updated only when reading PPUDATA, and so is preserved across frames. After the CPU reads and gets the contents of the internal buffer, the PPU will immediately update the internal buffer with the byte at the current VRAM address. Thus, after setting the VRAM address, one should first read this register and discard the result.
    # Reading palette data from $3F00-$3FFF works differently. The palette data is placed immediately on the data bus, and hence no dummy read is required. Reading the palettes still updates the internal buffer though, but the data placed in it is the mirrored nametable data that would appear "underneath" the palette. (Checking the PPU memory map should make this clearer.)
    @memory.read @vram_address
    @vram_address += vram_increment
  end

  private def write_vram(value)
    @memory.write @vram_address, value
    @vram_address += vram_increment
  end

  private def vram_increment
    # control bit 2 = 0 => +1
    #                 1 => +32
    (@control >> 2) & 1 == 1 ? 32 : 1
  end

  # control register
  # 7654 3210
  # VPHB SINN
end
