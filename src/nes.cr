require "./rom"
require "./cpu"
require "./cpu_memory"
require "./ppu"
require "./ppu_memory"
require "./control_pad"
require "./mappers/*"

class Nes
  getter rom
  getter ppu
  getter control_pad

  def initialize(path)
    @rom = Rom.from_file path
    @mapper = build_mapper
    @control_pad = ControlPad.new
    @ppu = Ppu.new @rom
    @cpu_memory = CpuMemory.new @mapper, @ppu, @control_pad
    @cpu = Cpu.new @cpu_memory
    @ppu.cpu = @cpu
  end

  def step
    cycles = @cpu.cycles
    @cpu.step
    d_cycles = @cpu.cycles - cycles
    (d_cycles * 3).times { @ppu.step }
    d_cycles
  end

  private def build_mapper
    case @rom.mapper_number
    when 0; Nrom.new(@rom)
    when 2; Unrom.new(@rom)
    else
      raise "Error: unsupported mapper #{@rom.mapper_number}"
    end
  end
end
