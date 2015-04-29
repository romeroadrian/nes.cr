require "./v_ram"

class PpuMemory
  def initialize(@rom, @ppu)
    @vram = VRam.new
  end

  def read(address: UInt16)
    address = address % 0x4000
    case
    when address < 0x2000 # Pattern tables
      @rom.read_chr(address)
    when address < 0x3F00 # Name/Attribute tables
      # TODO mirroring?
      # TODO this will fail if accesing name/attribute tables 2 and 3
      address = (address - 0x2000) % 0x1000
      @vram.read address
    when address < 0x4000 # Image/Sprite palettes
      address = (address - 0x3F00) % 0x20
      @ppu.read_palette address
    end
  end

  def write(address: UInt16, value: UInt8)
    address = address % 0x4000
    case
    when address < 0x2000 # Pattern tables
      raise "Can't write to CHR"
    when address < 0x3F00 # Name/Attribute tables
      # TODO mirroring?
      # TODO this will fail if accesing name/attribute tables 2 and 3
      address = (address - 0x2000) % 0x1000
      @vram.write address, value
    when address < 0x4000 # Image/Sprite palettes
      address = (address - 0x3F00) % 0x20
      @ppu.write_palette address
    end
  end
end
