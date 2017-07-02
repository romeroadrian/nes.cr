class Rom
  HEADER_SIZE = 16
  TRAINER_SIZE = 512
  PRG_ROM_SIZE = 16384
  CHR_ROM_SIZE = 8192

  @prg_banks : UInt8
  @chr_banks : UInt8
  @mirror_mode : Symbol
  @chr_ram :  Array(UInt8)?

  getter prg_banks
  getter chr_banks
  getter mirror_mode
  private getter! chr_ram

  def initialize(@data : Array(UInt8))
    @prg_banks = @data[4]
    @chr_banks = @data[5]
    @mirror_mode = read_mirror_mode
    if @chr_banks == 0
      @chr_ram = Array(UInt8).new(CHR_ROM_SIZE, 0_u8)
    end
  end

  def self.from_file(path)
    File.open(path) do |f|
      s = Slice(UInt8).new f.size.to_i
      f.read s
      self.new s.to_a
    end
  end

  def valid_header?
    # N - E - S - EOF
    @data[0..3] == [0x4E, 0x45, 0x53, 0x1A]
  end

  def has_trainer?
    (flags6 & (0x1 << 2)) == 1
  end

  def mapper_number
    (flags7 & 0xF0) | (flags6 >> 4)
  end

  def flags6
    @data[6]
  end

  def flags7
    @data[7]
  end

  def read_prg(address)
    @data[
      HEADER_SIZE +
      (has_trainer? ? TRAINER_SIZE : 0) +
      address]
  end

  def read_chr(address)
    if @chr_banks == 0
      chr_ram[address]
    else
      @data[
        HEADER_SIZE +
        (has_trainer? ? TRAINER_SIZE : 0) +
        (PRG_ROM_SIZE * @prg_banks) +
        (address % (CHR_ROM_SIZE * @chr_banks))]
    end
  end

  def write_chr(address, value)
    if @chr_banks == 0
      chr_ram[address] = value
    else
      @data[
        HEADER_SIZE +
        (has_trainer? ? TRAINER_SIZE : 0) +
        (PRG_ROM_SIZE * @prg_banks) +
        (address % (CHR_ROM_SIZE * @chr_banks))] = value
    end
  end

  private def read_mirror_mode
    mirror = (flags6 & 0x1) | ((flags6 & 0x8) >> 2)
    case mirror
    when 0
      :horizontal
    when 1
      :vertical
    when 2, 3
      :single
    when 4
      :quad
    else
      raise "Mirror mode unkown: #{mirror}"
    end
  end
end
