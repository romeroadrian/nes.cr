require "./cpu_ram"
require "./instruction"

class Cpu

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

    init

    # TODO move this elsewhere
    @instructions = [->brk(UInt16, String), ->ora(UInt16, String), ->kil(UInt16, String), ->slo(UInt16, String), ->nop(UInt16, String), ->ora(UInt16, String), ->asl(UInt16, String), ->slo(UInt16, String), ->php(UInt16, String), ->ora(UInt16, String), ->asl(UInt16, String), ->anc(UInt16, String), ->nop(UInt16, String), ->ora(UInt16, String), ->asl(UInt16, String), ->slo(UInt16, String), ->bpl(UInt16, String), ->ora(UInt16, String), ->kil(UInt16, String), ->slo(UInt16, String), ->nop(UInt16, String), ->ora(UInt16, String), ->asl(UInt16, String), ->slo(UInt16, String), ->clc(UInt16, String), ->ora(UInt16, String), ->nop(UInt16, String), ->slo(UInt16, String), ->nop(UInt16, String), ->ora(UInt16, String), ->asl(UInt16, String), ->slo(UInt16, String), ->jsr(UInt16, String), ->and(UInt16, String), ->kil(UInt16, String), ->rla(UInt16, String), ->bit(UInt16, String), ->and(UInt16, String), ->rol(UInt16, String), ->rla(UInt16, String), ->plp(UInt16, String), ->and(UInt16, String), ->rol(UInt16, String), ->anc(UInt16, String), ->bit(UInt16, String), ->and(UInt16, String), ->rol(UInt16, String), ->rla(UInt16, String), ->bmi(UInt16, String), ->and(UInt16, String), ->kil(UInt16, String), ->rla(UInt16, String), ->nop(UInt16, String), ->and(UInt16, String), ->rol(UInt16, String), ->rla(UInt16, String), ->sec(UInt16, String), ->and(UInt16, String), ->nop(UInt16, String), ->rla(UInt16, String), ->nop(UInt16, String), ->and(UInt16, String), ->rol(UInt16, String), ->rla(UInt16, String), ->rti(UInt16, String), ->eor(UInt16, String), ->kil(UInt16, String), ->sre(UInt16, String), ->nop(UInt16, String), ->eor(UInt16, String), ->lsr(UInt16, String), ->sre(UInt16, String), ->pha(UInt16, String), ->eor(UInt16, String), ->lsr(UInt16, String), ->alr(UInt16, String), ->jmp(UInt16, String), ->eor(UInt16, String), ->lsr(UInt16, String), ->sre(UInt16, String), ->bvc(UInt16, String), ->eor(UInt16, String), ->kil(UInt16, String), ->sre(UInt16, String), ->nop(UInt16, String), ->eor(UInt16, String), ->lsr(UInt16, String), ->sre(UInt16, String), ->cli(UInt16, String), ->eor(UInt16, String), ->nop(UInt16, String), ->sre(UInt16, String), ->nop(UInt16, String), ->eor(UInt16, String), ->lsr(UInt16, String), ->sre(UInt16, String), ->rts(UInt16, String), ->adc(UInt16, String), ->kil(UInt16, String), ->rra(UInt16, String), ->nop(UInt16, String), ->adc(UInt16, String), ->ror(UInt16, String), ->rra(UInt16, String), ->pla(UInt16, String), ->adc(UInt16, String), ->ror(UInt16, String), ->arr(UInt16, String), ->jmp(UInt16, String), ->adc(UInt16, String), ->ror(UInt16, String), ->rra(UInt16, String), ->bvs(UInt16, String), ->adc(UInt16, String), ->kil(UInt16, String), ->rra(UInt16, String), ->nop(UInt16, String), ->adc(UInt16, String), ->ror(UInt16, String), ->rra(UInt16, String), ->sei(UInt16, String), ->adc(UInt16, String), ->nop(UInt16, String), ->rra(UInt16, String), ->nop(UInt16, String), ->adc(UInt16, String), ->ror(UInt16, String), ->rra(UInt16, String), ->nop(UInt16, String), ->sta(UInt16, String), ->nop(UInt16, String), ->sax(UInt16, String), ->sty(UInt16, String), ->sta(UInt16, String), ->stx(UInt16, String), ->sax(UInt16, String), ->dey(UInt16, String), ->nop(UInt16, String), ->txa(UInt16, String), ->xaa(UInt16, String), ->sty(UInt16, String), ->sta(UInt16, String), ->stx(UInt16, String), ->sax(UInt16, String), ->bcc(UInt16, String), ->sta(UInt16, String), ->kil(UInt16, String), ->ahx(UInt16, String), ->sty(UInt16, String), ->sta(UInt16, String), ->stx(UInt16, String), ->sax(UInt16, String), ->tya(UInt16, String), ->sta(UInt16, String), ->txs(UInt16, String), ->tas(UInt16, String), ->shy(UInt16, String), ->sta(UInt16, String), ->shx(UInt16, String), ->ahx(UInt16, String), ->ldy(UInt16, String), ->lda(UInt16, String), ->ldx(UInt16, String), ->lax(UInt16, String), ->ldy(UInt16, String), ->lda(UInt16, String), ->ldx(UInt16, String), ->lax(UInt16, String), ->tay(UInt16, String), ->lda(UInt16, String), ->tax(UInt16, String), ->lax(UInt16, String), ->ldy(UInt16, String), ->lda(UInt16, String), ->ldx(UInt16, String), ->lax(UInt16, String), ->bcs(UInt16, String), ->lda(UInt16, String), ->kil(UInt16, String), ->lax(UInt16, String), ->ldy(UInt16, String), ->lda(UInt16, String), ->ldx(UInt16, String), ->lax(UInt16, String), ->clv(UInt16, String), ->lda(UInt16, String), ->tsx(UInt16, String), ->las(UInt16, String), ->ldy(UInt16, String), ->lda(UInt16, String), ->ldx(UInt16, String), ->lax(UInt16, String), ->cpy(UInt16, String), ->cmp(UInt16, String), ->nop(UInt16, String), ->dcp(UInt16, String), ->cpy(UInt16, String), ->cmp(UInt16, String), ->dec(UInt16, String), ->dcp(UInt16, String), ->iny(UInt16, String), ->cmp(UInt16, String), ->dex(UInt16, String), ->axs(UInt16, String), ->cpy(UInt16, String), ->cmp(UInt16, String), ->dec(UInt16, String), ->dcp(UInt16, String), ->bne(UInt16, String), ->cmp(UInt16, String), ->kil(UInt16, String), ->dcp(UInt16, String), ->nop(UInt16, String), ->cmp(UInt16, String), ->dec(UInt16, String), ->dcp(UInt16, String), ->cld(UInt16, String), ->cmp(UInt16, String), ->nop(UInt16, String), ->dcp(UInt16, String), ->nop(UInt16, String), ->cmp(UInt16, String), ->dec(UInt16, String), ->dcp(UInt16, String), ->cpx(UInt16, String), ->sbc(UInt16, String), ->nop(UInt16, String), ->isc(UInt16, String), ->cpx(UInt16, String), ->sbc(UInt16, String), ->inc(UInt16, String), ->isc(UInt16, String), ->inx(UInt16, String), ->sbc(UInt16, String), ->nop(UInt16, String), ->sbc(UInt16, String), ->cpx(UInt16, String), ->sbc(UInt16, String), ->inc(UInt16, String), ->isc(UInt16, String), ->beq(UInt16, String), ->sbc(UInt16, String), ->kil(UInt16, String), ->isc(UInt16, String), ->nop(UInt16, String), ->sbc(UInt16, String), ->inc(UInt16, String), ->isc(UInt16, String), ->sed(UInt16, String), ->sbc(UInt16, String), ->nop(UInt16, String), ->isc(UInt16, String), ->nop(UInt16, String), ->sbc(UInt16, String), ->inc(UInt16, String), ->isc(UInt16, String)]
  end

  def step
    opcode = read(@pc)
    addressing_mode = Instruction::AddressingMode[opcode]
    size = Instruction::Size[opcode]
    name = Instruction::Name[opcode]

    address = solve_address addressing_mode

    print_state opcode, size, name

    @pc = @pc + size

    instruction = @instructions[opcode]
    instruction.call address, addressing_mode
  end

  private def print_state(opcode, size, name)
    arg1 = size < 2 ? "  " : "%02x" % read(@pc + 1)
    arg2 = size < 3 ? "  " : "%02x" % read(@pc + 2)

    description = "%-31s" % name # TODO

    state = "A:%02x X:%02x Y:%02x P:%02x SP:%02x CYC:%3d SL:??" % [@a, @x, @y, packed_flags, @sp, @cycles]

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
    # @pc = read2(0xFFFC)
    @pc = 0xC000_u16
    # SP starts at 0xFD
    @sp = 0xFD_u8
    # Flag I
    @i = 1_u8
  end

  private def read(address)
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

  # INSTRUCTIONS

  private def txs(address, mode)
    @sp = @x
  end

  private def bpl(address, mode)
    if @n == 0
      @pc = address
    end
  end

  private def sei(address, mode)
    @i = 1_u8
  end

  private def cld(address, mode)
    @d = 0_u8
  end

  private def nop(address, mode)
  end

  private def bcs(address, mode)
    if @c > 0
      @pc = address
    end
  end

  private def sec(address, mode)
    @c = 1_u8
  end

  private def brk(address, mode)
    raise "TODO"
  end

  private def ora(address, mode)
    @a |= read address
    set_ZN(@a)
  end

  private def php(address, mode)
    push_stack packed_flags
  end

  private def clc(address, mode)
    @c = 0_u8
  end

  private def jsr(address, mode)
    push_stack_2(@pc - 1)
    @pc = address
  end

  private def and(address, mode)
    @a &= read address
    set_ZN @a
  end

  private def bit(address, mode)
    test = read address
    @z = (test & @a) == 0 ? 1_u8 : 0_u8
    @v = (test >> 6) & 0x1
    @n = (test >> 7) & 0x1
  end

  private def plp(address, mode)
    unpack_flags pop_stack
  end

  private def bmi(address, mode)
    if @n > 0
      @pc = address
    end
  end

  private def rti(address, mode)
    unpack_flags pop_stack
    @pc = pop_stack_2
  end

  private def eor(address, mode)
    @a ^= read address
    set_ZN @a
  end

  private def lsr(address, mode)
    if mode == "ACC"
      @c = @a & 0x1
      @a >>= 1
      set_ZN(@a)
    else
      value = read address
      @c = value & 0x1
      value >>= 1
      write address, value
      set_ZN value
    end
  end

  private def asl(address, mode)
    if mode == "ACC"
      @c = (@a >> 7) & 1
      @a <<= 1
      set_ZN(@a)
    else
      value = read address
      @c = (value >> 7) & 1
      value <<= 1
      write address, value
      set_ZN(value)
    end
  end

  private def ror(address, mode)
    old_c = @c
    if mode == "ACC"
      @c = @a & 0x1
      @a = (@a >> 1) | (old_c << 7)
      set_ZN(@a)
    else
      value = read address
      @c = value & 0x1
      value = (value >> 1) | (old_c << 7)
      write address, value
      set_ZN(value)
    end
  end

  private def rol(address, mode)
    old_c = @c
    if mode == "ACC"
      @c = (@a >> 7) & 0x1
      @a = (@a << 1) | old_c
      set_ZN(@a)
    else
      value = read address
      @c = (value >> 7) & 0x1
      value = (value << 1) | old_c
      write address, value
      set_ZN(value)
    end
  end

  private def pha(address, mode)
    push_stack @a
  end

  private def jmp(address, mode)
    @pc = address
  end

  private def bvc(address, mode)
    if @v == 0
      @pc = address
    end
  end

  private def cli(address, mode)
    raise "TODO"
  end

  private def rts(address, mode)
    @pc = pop_stack_2 + 1
  end

  private def adc(address, mode)
    old_a = @a
    value = read address
    test_carry = @a.to_i + value.to_i + @c.to_i # we need 32
    @a += value + @c
    @c = test_carry > 0xFF ? 1_u8 : 0_u8
    @v = ((~(old_a ^ value)) & (old_a ^ @a) & 0x80) == 0 ? 0_u8 : 1_u8
    set_ZN(@a)
  end

  private def sbc(address, mode)
    # TODO refactor this since is the same as ADC with a negated operand
    old_a = @a
    value = ~read(address)
    test_carry = @a.to_i + value.to_i + @c.to_i # we need 32
    @a += value + @c
    @c = test_carry > 0xFF ? 1_u8 : 0_u8
    @v = ((~(old_a ^ value)) & (old_a ^ @a) & 0x80) == 0 ? 0_u8 : 1_u8
    set_ZN(@a)
  end

  private def pla(address, mode)
    @a = pop_stack
    set_ZN @a
  end

  private def bvs(address, mode)
    if @v > 0
      @pc = address
    end
  end

  private def sta(address, mode)
    write address, @a
  end

  private def sty(address, mode)
    write address, @x
  end

  private def stx(address, mode)
    write address, @x
  end

  private def txa(address, mode)
    @a = @x
    set_ZN(@a)
  end

  private def tya(address, mode)
    @a = @y
    set_ZN(@a)
  end

  private def bcc(address, mode)
    if @c == 0
      @pc = address
    end
  end

  private def ldy(address, mode)
    @y = read address
    set_ZN @y
  end

  private def lda(address, mode)
    @a = read address
    set_ZN(@a)
  end

  private def ldx(address, mode)
    @x = read address
    set_ZN(@x)
  end

  private def tax(address, mode)
    @x = @a
    set_ZN(@x)
  end

  private def tay(address, mode)
    @y = @a
    set_ZN(@y)
  end

  private def clv(address, mode)
    @v = 0_u8
  end

  private def tsx(address, mode)
    @x = @sp
    set_ZN(@x)
  end

  private def cmp(address, mode)
    compare_and_set_flags @a, read(address)
  end

  private def cpx(address, mode)
    compare_and_set_flags @x, read(address)
  end

  private def cpy(address, mode)
    compare_and_set_flags @y, read(address)
  end

  private def inx(address, mode)
    @x += 1
    set_ZN(@x)
  end

  private def iny(address, mode)
    @y += 1
    set_ZN(@y)
  end

  private def dex(address, mode)
    @x -= 1
    set_ZN(@x)
  end

  private def dey(address, mode)
    @y -= 1
    set_ZN(@y)
  end

  private def bne(address, mode)
    if @z == 0
      @pc = address
    end
  end

  private def inc(address, mode)
    value = read(address) + 1
    write address, value
    set_ZN value
  end

  private def dec(address, mode)
    value = read(address) - 1
    write address, value
    set_ZN value
  end

  private def beq(address, mode)
    if @z > 0
      @pc = address
    end
  end

  private def sed(address, mode)
    @d = 1_u8
  end

  private def error(address, mode)
    raise "Invalid instruction"
  end

  private def kil(address, mode)
    raise "CPU HALT"
  end

  private def slo(address, mode)
    asl(address, mode)
    ora(address, mode)
  end

  private def anc(address, mode)
    raise "TODO instruction"
  end

  private def rla(address, mode)
    rol(address, mode)
    and(address, mode)
  end

  private def sre(address, mode)
    lsr(address, mode)
    eor(address, mode)
  end

  private def alr(address, mode)
    raise "TODO instruction"
  end

  private def rra(address, mode)
    ror(address, mode)
    adc(address, mode)
  end

  private def arr(address, mode)
    raise "TODO instruction"
  end

  private def sax(address, mode)
    result = @a ^ @x
    write address, result
    set_ZN result
  end

  private def xaa(address, mode)
    raise "TODO instruction"
  end

  private def ahx(address, mode)
    raise "TODO instruction"
  end

  private def tas(address, mode)
    raise "TODO instruction"
  end

  private def shy(address, mode)
    raise "TODO instruction"
  end

  private def shx(address, mode)
    raise "TODO instruction"
  end

  private def lax(address, mode)
    value = read address
    @a = value
    @x = value
    set_ZN(value)
  end

  private def las(address, mode)
    raise "TODO instruction"
  end

  private def dcp(address, mode)
    dec(address, mode)
    cmp(address, mode)
  end

  private def axs(address, mode)
    raise "TODO instruction"
  end

  private def isc(address, mode)
    inc(address, mode)
    sbc(address, mode)
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

  # flags
  # 7 6 5 4 3 2 1 0
  # N V   B D I Z C
  # 0 0 1 0 0 1 0 0 << initial state

  # opcodes: 151 possible of 256 (8 bits)
end
