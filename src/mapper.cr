abstract class Mapper
  abstract def read(address)
  abstract def write(address, value)
end
