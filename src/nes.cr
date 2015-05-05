require "./rom"
require "./cpu"
require "./cpu_memory"
require "./ppu"
require "./ppu_memory"
require "./control_pad"

class Nes
  getter rom
  getter ppu
  getter control_pad

  def initialize(path)
    @rom = Rom.from_file path
    @control_pad = ControlPad.new
    @ppu = Ppu.new @rom
    @cpu_memory = CpuMemory.new @rom, @ppu, @control_pad
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
