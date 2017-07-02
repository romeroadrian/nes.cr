require "./v_ram"

class PpuMemory
  def initialize(@rom : Rom, @ppu : Ppu)
    @vram = VRam.new
  end

  def read(address : UInt16)
    address = address % 0x4000
    case
    when address < 0x2000 # Pattern tables
      @rom.read_chr(address)
    when address < 0x3F00 # Name/Attribute tables
      @vram.peek mirror_name_table(address)
    when address < 0x4000 # Image/Sprite palettes
      address = (address - 0x3F00) % 0x20
      @ppu.read_palette address
    else
      raise "Should not happen"
    end
  end

  def write(address : UInt16, value : UInt8)
    address = address % 0x4000
    case
    when address < 0x2000 # Pattern tables
      @rom.write_chr(address, value)
    when address < 0x3F00 # Name/Attribute tables
      @vram.poke mirror_name_table(address), value
    when address < 0x4000 # Image/Sprite palettes
      address = (address - 0x3F00) % 0x20
      @ppu.write_palette address, value
    end
  end

  private def mirror_name_table(address)
    address = (address - 0x2000) % 0x1000
    case @rom.mirror_mode
    when :horizonal # $2000 -> $2400, $2800 -> $2C00
      if address >= 0xC00 || (address >= 0x400 && address < 0x800)
        address -= 0x400
      end
    when :vertical # $2000 -> $2800, $2400 -> $2C00
      if address >= 0x800
        address -= 0x800
      end
    when :single # all to $2000
      address = address % 0x400
    end
    address
  end
end
