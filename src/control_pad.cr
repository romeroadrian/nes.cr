require "./bool"

class ControlPad

  enum Button
    A
    B
    Select
    Start
    Up
    Down
    Left
    Right
  end

  def initialize
    @pressed = Array.new(8, false)
    @index = 0
    @reset = false
  end

  def press(which: Button)
    @pressed[which.value] = true
  end

  def release(which: Button)
    @pressed[which.value] = false
  end

  def set(which: Button, pressed: Bool)
    @pressed[which.value] = pressed
  end

  def read : UInt8
    value = @index < 8 ? @pressed[@index].to_u8 : 0x1_u8
    @index += 1
    try_reset
    value
  end

  def write(value: UInt8)
    @reset = value % 2 == 1
    try_reset
  end

  private def try_reset
    @index = 0 if @reset
  end
end
