class Nrom < Mapper
  def initialize(@rom : Rom)
  end

  def read_prg(address)
    @rom.read_prg(address % (Rom::PRG_ROM_SIZE * @rom.prg_banks))
  end

  def write_prg(address, value)
  end
end
