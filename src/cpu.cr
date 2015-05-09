require "./cpu_ram"
require "./instruction"

class Cpu
  include Instruction

  Frequency = 1789773

  @a  :: UInt8
  @x  :: UInt8
  @y  :: UInt8
  @sp :: UInt8
  @pc :: UInt16

  @c  :: UInt8
  @z  :: UInt8
  @i  :: UInt8
  @d  :: UInt8
  @b  :: UInt8
  @v  :: UInt8
  @n  :: UInt8

  @cycles :: UInt64

  getter cycles

  def initialize(@memory)
    # CPU Registers
    @a = 0_u8     # accumulator 8bits
    @x = 0_u8     # x index 8bits
    @y = 0_u8     # y index 8bits
    @sp = 0_u8    # stack pointer 8bits
    @pc = 0_u16   # program counter 16bits

    # CPU flags
    @c = 0_u8 # C carry flag
    @z = 0_u8 # Z zero flag
    @i = 0_u8 # I interrupt disable flag
    @d = 0_u8 # D decimal mode flag (not used in NES)
    @b = 0_u8 # B break command flag
    @v = 0_u8 # V overflow flag
    @n = 0_u8 # N negative flag (0 = positive, 1 = negative)

    @cycles = 0_u64
    @suspend = 0

    @requested_interrupt = nil

    @instructions = build_instructions

    init
  end

  def step
    # TODO how many cycles should suspend take in each step?
    if @suspend > 0
      @suspend -= 1
      @cycles += 1
      return
    end

    case @requested_interrupt
    when :nmi
      perform_nmi
    when :irq
      perform_irq if @i == 0
    end
    @requested_interrupt = nil

    opcode = read(@pc)
    addressing_mode = Instruction::AddressingMode[opcode]
    size = Instruction::Size[opcode]
    name = Instruction::Name[opcode]

    address = solve_address addressing_mode

    # print_state opcode, size, name

    @pc = @pc + size

    @cycles += Instruction::Cycles[opcode]
    page_crossed = case addressing_mode
    when "ABSX"
      page_crossed?(address - @x.to_u16, address)
    when "ABSY", "INDY"
      page_crossed?(address - @y.to_u16, address)
    else
      false
    end
    @cycles += Instruction::CrossCycles[opcode] if page_crossed

    instruction = @instructions[opcode]
    instruction.call address, addressing_mode
  end

  def suspend_for(n)
    @suspend += n
  end

  def interrupt(mode)
    @requested_interrupt = mode
  end

  private def perform_nmi
    push_stack_2 @pc
    push_flags
    @pc = read2 0xFFFA
    @i = 1_u8
    @cycles += 7
  end

  private def perform_irq
    push_stack_2 @pc
    push_flags
    @pc = read2 0xFFFE
    @i = 1_u8
    @cycles += 7
  end

  private def print_state(opcode, size, name)
    arg1 = size < 2 ? "  " : "%02x" % read(@pc + 1)
    arg2 = size < 3 ? "  " : "%02x" % read(@pc + 2)

    description = "%-31s" % name # TODO

    state = "A:%02x X:%02x Y:%02x P:%02x SP:%02x CYC:%3d SL:??" % [@a, @x, @y, packed_flags, @sp, (@cycles * 3) % 341]

    print "%04x  %02x %s %s  %s %s\n" % [@pc, opcode, arg1, arg2, description, state]
  end

  private def solve_address(mode)
    # Note that base PC here is PC + 1 since we need
    # to take into account the opcode (PC points at opcode)
    case mode
    when "ABS"
      read2(@pc + 1)
    when "ABSX"
      read2(@pc + 1) + @x.to_u16
    when "ABSY"
      read2(@pc + 1) + @y.to_u16
    when "IMM"
      @pc + 1
    when "ZP"
      read(@pc + 1).to_u16
    when "ZPX"
      (read(@pc + 1) + @x).to_u16
    when "ZPY"
      (read(@pc + 1) + @y).to_u16
    when "IMP"
      0_u16 # TODO is this ok?
    when "REL"
      offset = read(@pc + 1).to_u16
      @pc + 2 + offset - (offset >= 0x80 ? 0x100 : 0) # offset is signed byte
    when "ACC"
      0_u16 # TODO is this ok?
    when "INDX"
      address = read(@pc + 1) + @x
      read2_with_bug(address.to_u16)
    when "INDY"
      address = read(@pc + 1).to_u16
      read2_with_bug(address) + @y.to_u16
    when "IND"
      read2_with_bug(read2(@pc + 1))
    when "?"
      raise "Invalid Addressing Mode"
    else
      raise "TODO ADDRESS MODE: #{mode}"
    end
  end

  private def init
    # 6502 begins execution at u16 in 0xFFFC
    @pc = read2(0xFFFC)
    # SP starts at 0xFD
    @sp = 0xFD_u8
    # Flag I
    @i = 1_u8
  end

  def read(address)
    @memory.read address
  end

  private def read2(address)
    @memory.read2 address
  end

  private def read2_with_bug(address)
    @memory.read2_with_bug address
  end

  private def write(address, value)
    @memory.write address, value
  end

  # FLAGS

  private def set_ZN(value)
    @z = value == 0 ? 1_u8 : 0_u8
    @n = (value >> 7) & 0x1
  end

  private def compare_and_set_flags(p, q)
    @c = p >= q ? 1_u8 : 0_u8
    set_ZN(p - q)
  end

  def packed_flags
    flags = 0x20_u8 # bit 5 on
    flags |= @c
    flags |= @z << 1
    flags |= @i << 2
    flags |= @d << 3
    flags |= @b << 4
    flags |= @v << 6
    flags |= @n << 7
  end

  def unpack_flags(flags)
    @c = flags & 0x1
    @z = (flags >> 1) & 0x1
    @i = (flags >> 2) & 0x1
    @d = (flags >> 3) & 0x1
    @b = (flags >> 4) & 0x1
    @v = (flags >> 6) & 0x1
    @n = (flags >> 7) & 0x1
  end

  # STACK POINTER

  private def push_stack_2(value)
    a = (value >> 8).to_u8
    b = (value & 0xFF).to_u8
    push_stack a
    push_stack b
  end

  private def push_stack(value)
    write(@sp.to_u16 + 0x100, value)
    @sp -= 1
  end

  private def pop_stack
    @sp += 1
    read(@sp.to_u16 + 0x100)
  end

  private def pop_stack_2
    b = pop_stack.to_u16
    a = pop_stack.to_u16
    (a << 8) | b
  end

  # Cycles

  private def add_branch_cycles(address)
    @cycles += page_crossed?(@pc, address) ? 2 : 1
  end

  private def page_crossed?(a, b)
    # higher byte differs
    (a & 0xFF00) != (b & 0xFF00)
  end

end
