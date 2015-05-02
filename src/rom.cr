class Rom
  HEADER_SIZE = 16
  TRAINER_SIZE = 512
  PRG_ROM_SIZE = 16384
  CHR_ROM_SIZE = 8192

  getter prg_banks
  getter chr_banks
  getter mirror_mode

  def initialize(@data)
    @prg_banks = @data[4]
    @chr_banks = @data[5]
    @mirror_mode = read_mirror_mode
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
      (address % (PRG_ROM_SIZE * @prg_banks))]
  end

  def read_chr(address)
    @data[
      HEADER_SIZE +
      (has_trainer? ? TRAINER_SIZE : 0) +
      (PRG_ROM_SIZE * @prg_banks) +
      (address % (CHR_ROM_SIZE * @chr_banks))]
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
