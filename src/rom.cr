class Rom
  HEADER_SIZE = 16
  TRAINER_SIZE = 512
  PRG_ROM_SIZE = 16384
  CHR_ROM_SIZE = 8192

  getter prg_banks
  getter chr_banks

  def initialize(@data)
    @prg_banks = @data[4]
    @chr_banks = @data[5]
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

  def flags6
    @data[6]
  end

  def readPRG(address)
    @data[
      HEADER_SIZE +
      (has_trainer? ? TRAINER_SIZE : 0) +
      (address % (PRG_ROM_SIZE * @prg_banks))]
  end
end
