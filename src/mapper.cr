abstract class Mapper
  abstract def read_prg(address)
  abstract def write_prg(address, value)
end
