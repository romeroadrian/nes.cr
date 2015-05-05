require "./rom"
require "./cpu"
require "./cpu_memory"
require "./ppu"
require "./ppu_memory"

class Nes
  getter rom
  getter ppu

  def initialize(path)
    @rom = Rom.from_file path
    @ppu = Ppu.new @rom
    @cpu_memory = CpuMemory.new @rom, @ppu
    @cpu = Cpu.new @cpu_memory
    @ppu.cpu = @cpu
  end

  def run
    while true
      step
    end
  end

  def step
    cycles = @cpu.cycles
    @cpu.step
    d_cycles = @cpu.cycles - cycles
    (d_cycles * 3).times { @ppu.step }
  end
end
