module Instruction
  Name = ["BRK", "ORA", "KIL", "SLO", "NOP", "ORA", "ASL", "SLO", "PHP", "ORA", "ASL", "ANC", "NOP", "ORA", "ASL", "SLO", "BPL", "ORA", "KIL", "SLO", "NOP", "ORA", "ASL", "SLO", "CLC", "ORA", "NOP", "SLO", "NOP", "ORA", "ASL", "SLO", "JSR", "AND", "KIL", "RLA", "BIT", "AND", "ROL", "RLA", "PLP", "AND", "ROL", "ANC", "BIT", "AND", "ROL", "RLA", "BMI", "AND", "KIL", "RLA", "NOP", "AND", "ROL", "RLA", "SEC", "AND", "NOP", "RLA", "NOP", "AND", "ROL", "RLA", "RTI", "EOR", "KIL", "SRE", "NOP", "EOR", "LSR", "SRE", "PHA", "EOR", "LSR", "ALR", "JMP", "EOR", "LSR", "SRE", "BVC", "EOR", "KIL", "SRE", "NOP", "EOR", "LSR", "SRE", "CLI", "EOR", "NOP", "SRE", "NOP", "EOR", "LSR", "SRE", "RTS", "ADC", "KIL", "RRA", "NOP", "ADC", "ROR", "RRA", "PLA", "ADC", "ROR", "ARR", "JMP", "ADC", "ROR", "RRA", "BVS", "ADC", "KIL", "RRA", "NOP", "ADC", "ROR", "RRA", "SEI", "ADC", "NOP", "RRA", "NOP", "ADC", "ROR", "RRA", "NOP", "STA", "NOP", "SAX", "STY", "STA", "STX", "SAX", "DEY", "NOP", "TXA", "XAA", "STY", "STA", "STX", "SAX", "BCC", "STA", "KIL", "AHX", "STY", "STA", "STX", "SAX", "TYA", "STA", "TXS", "TAS", "SHY", "STA", "SHX", "AHX", "LDY", "LDA", "LDX", "LAX", "LDY", "LDA", "LDX", "LAX", "TAY", "LDA", "TAX", "LAX", "LDY", "LDA", "LDX", "LAX", "BCS", "LDA", "KIL", "LAX", "LDY", "LDA", "LDX", "LAX", "CLV", "LDA", "TSX", "LAS", "LDY", "LDA", "LDX", "LAX", "CPY", "CMP", "NOP", "DCP", "CPY", "CMP", "DEC", "DCP", "INY", "CMP", "DEX", "AXS", "CPY", "CMP", "DEC", "DCP", "BNE", "CMP", "KIL", "DCP", "NOP", "CMP", "DEC", "DCP", "CLD", "CMP", "NOP", "DCP", "NOP", "CMP", "DEC", "DCP", "CPX", "SBC", "NOP", "ISB", "CPX", "SBC", "INC", "ISB", "INX", "SBC", "NOP", "SBC", "CPX", "SBC", "INC", "ISB", "BEQ", "SBC", "KIL", "ISB", "NOP", "SBC", "INC", "ISB", "SED", "SBC", "NOP", "ISB", "NOP", "SBC", "INC", "ISB"]
  AddressingMode = ["IMP", "INDX", "IMP", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "ACC", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX", "ABS", "INDX", "IMP", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "ACC", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX", "IMP", "INDX", "IMP", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "ACC", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX", "IMP", "INDX", "IMP", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "ACC", "IMM", "IND", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX", "IMM", "INDX", "IMM", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "IMP", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPY", "ZPY", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSY", "ABSY", "IMM", "INDX", "IMM", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "IMP", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPY", "ZPY", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSY", "ABSY", "IMM", "INDX", "IMM", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "IMP", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX", "IMM", "INDX", "IMM", "INDX", "ZP", "ZP", "ZP", "ZP", "IMP", "IMM", "IMP", "IMM", "ABS", "ABS", "ABS", "ABS", "REL", "INDY", "IMP", "INDY", "ZPX", "ZPX", "ZPX", "ZPX", "IMP", "ABSY", "IMP", "ABSY", "ABSX", "ABSX", "ABSX", "ABSX"]
  Size = [1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 3, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 3, 3, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 3, 1, 3, 3, 3, 3, 3]
  Cycles = [7, 6, 0, 8, 3, 3, 5, 5, 3, 2, 2, 2, 4, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7, 6, 6, 0, 8, 3, 3, 5, 5, 4, 2, 2, 2, 4, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7, 6, 6, 0, 8, 3, 3, 5, 5, 3, 2, 2, 2, 3, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7, 6, 6, 0, 8, 3, 3, 5, 5, 4, 2, 2, 2, 5, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7, 2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4, 2, 6, 0, 6, 4, 4, 4, 4, 2, 5, 2, 5, 5, 5, 5, 5, 2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4, 2, 5, 0, 5, 4, 4, 4, 4, 2, 4, 2, 4, 4, 4, 4, 4, 2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7, 2, 6, 2, 8, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6, 2, 5, 0, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7]
  CrossCycles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0]

  macro instruction_procs(names)
    [
      {% for name in names %}
        ->{{name}}(UInt16, String),
      {% end %}
    ]
  end

  private def build_instructions
    instruction_procs [
      brk, ora, kil, slo, nop, ora, asl, slo,
      php, ora, asl, anc, nop, ora, asl, slo,
      bpl, ora, kil, slo, nop, ora, asl, slo,
      clc, ora, nop, slo, nop, ora, asl, slo,
      jsr, and, kil, rla, bit, and, rol, rla,
      plp, and, rol, anc, bit, and, rol, rla,
      bmi, and, kil, rla, nop, and, rol, rla,
      sec, and, nop, rla, nop, and, rol, rla,
      rti, eor, kil, sre, nop, eor, lsr, sre,
      pha, eor, lsr, alr, jmp, eor, lsr, sre,
      bvc, eor, kil, sre, nop, eor, lsr, sre,
      cli, eor, nop, sre, nop, eor, lsr, sre,
      rts, adc, kil, rra, nop, adc, ror, rra,
      pla, adc, ror, arr, jmp, adc, ror, rra,
      bvs, adc, kil, rra, nop, adc, ror, rra,
      sei, adc, nop, rra, nop, adc, ror, rra,
      nop, sta, nop, sax, sty, sta, stx, sax,
      dey, nop, txa, xaa, sty, sta, stx, sax,
      bcc, sta, kil, ahx, sty, sta, stx, sax,
      tya, sta, txs, tas, shy, sta, shx, ahx,
      ldy, lda, ldx, lax, ldy, lda, ldx, lax,
      tay, lda, tax, lax, ldy, lda, ldx, lax,
      bcs, lda, kil, lax, ldy, lda, ldx, lax,
      clv, lda, tsx, las, ldy, lda, ldx, lax,
      cpy, cmp, nop, dcp, cpy, cmp, dec, dcp,
      iny, cmp, dex, axs, cpy, cmp, dec, dcp,
      bne, cmp, kil, dcp, nop, cmp, dec, dcp,
      cld, cmp, nop, dcp, nop, cmp, dec, dcp,
      cpx, sbc, nop, isb, cpx, sbc, inc, isb,
      inx, sbc, nop, sbc, cpx, sbc, inc, isb,
      beq, sbc, kil, isb, nop, sbc, inc, isb,
      sed, sbc, nop, isb, nop, sbc, inc, isb,
    ]
  end

  private def txs(address, mode)
    @sp = @x
  end

  private def sei(address, mode)
    @i = 1_u8
  end

  private def cli(address, mode)
    @i = 0_u8
  end

  private def cld(address, mode)
    @d = 0_u8
  end

  private def nop(address, mode)
  end

  private def sec(address, mode)
    @c = 1_u8
  end

  private def brk(address, mode)
    push_stack_2 @pc
    push_flags
    @i = 1_u8
    @pc = read2(0xFFFE)
  end

  private def ora(address, mode)
    @a |= read address
    set_ZN(@a)
  end

  private def php(address, mode)
    push_flags
  end

  private def push_flags
    push_stack(packed_flags | 0x10)
  end

  private def plp(address, mode)
    unpack_flags(pop_stack & 0xEF)
  end

  private def pla(address, mode)
    @a = pop_stack
    set_ZN @a
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

  private def sta(address, mode)
    write address, @a
  end

  private def sty(address, mode)
    write address, @y
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
      add_branch_cycles address
      @pc = address
    end
  end

  private def bcs(address, mode)
    if @c > 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def beq(address, mode)
    if @z > 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def bmi(address, mode)
    if @n > 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def bne(address, mode)
    if @z == 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def bpl(address, mode)
    if @n == 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def bvc(address, mode)
    if @v == 0
      add_branch_cycles address
      @pc = address
    end
  end

  private def bvs(address, mode)
    if @v > 0
      add_branch_cycles address
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
    write address, @a & @x
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

  private def isb(address, mode)
    inc(address, mode)
    sbc(address, mode)
  end
end
