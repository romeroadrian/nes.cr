require "./rom"
require "./cpu"
require "./cpu_memory"
require "./ppu"
require "./ppu_memory"

class Nes
  getter rom

  def initialize(path)
    @rom = Rom.from_file path
    @ppu = Ppu.new @rom
    @cpu_memory = CpuMemory.new @rom, @ppu
    @cpu = Cpu.new @cpu_memory
  end

  def run
    while true
      @cpu.step
    end
  end
end
