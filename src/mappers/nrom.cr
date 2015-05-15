class Nrom
  def initialize(@rom)
  end

  def read_prg(address)
    @rom.read_prg(address % (Rom::PRG_ROM_SIZE * @rom.prg_banks))
  end

  def write_prg(address, value)
  end
end
