require "crsfml"
require "./src/nes"

filename = ARGV.first? || abort("error: missing rom filename")
nes = Nes.new filename

window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "nes.cr")
window.vertical_sync_enabled = true

clock = SF::Clock.new

class NesDrawable
  include SF::Drawable

  def initialize(@nes : Nes)
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates)
    texture = SF::Texture.new(256, 240)
    sprite = SF::Sprite.new(texture)

    pixels = Array(UInt8).new(256 * 240 * 4)

    240.times do |y|
      256.times do |x|
        color = @nes.ppu.shown[x][y]

        pixels << (color >> 16).to_u8
        pixels << (color >> 8).to_u8
        pixels << color.to_u8
        pixels << 0xFF_u8
      end
    end

    texture.update(pixels.to_unsafe)

    target.draw sprite
  end
end

nes_drawable = NesDrawable.new(nes)

view = SF::View.new(SF.float_rect(0, 0, 256, 240))
window.view = view

while window.open?
  while event = window.poll_event
    case event
    when SF::Event::Closed
      window.close
    when SF::Event::KeyPressed
      case event.code
      when SF::Keyboard::Key::Z
        nes.control_pad.press(ControlPad::Button::A)
      when SF::Keyboard::Key::X
        nes.control_pad.press(ControlPad::Button::B)
      when SF::Keyboard::Key::Up
        nes.control_pad.press(ControlPad::Button::Up)
      when SF::Keyboard::Key::Down
        nes.control_pad.press(ControlPad::Button::Down)
      when SF::Keyboard::Key::Left
        nes.control_pad.press(ControlPad::Button::Left)
      when SF::Keyboard::Key::Right
        nes.control_pad.press(ControlPad::Button::Right)
      when SF::Keyboard::Key::O
        nes.control_pad.press(ControlPad::Button::Start)
      when SF::Keyboard::Key::P
        nes.control_pad.press(ControlPad::Button::Select)
      end
    when SF::Event::KeyReleased
      case event.code
      when SF::Keyboard::Key::Z
        nes.control_pad.release(ControlPad::Button::A)
      when SF::Keyboard::Key::X
        nes.control_pad.release(ControlPad::Button::B)
      when SF::Keyboard::Key::Up
        nes.control_pad.release(ControlPad::Button::Up)
      when SF::Keyboard::Key::Down
        nes.control_pad.release(ControlPad::Button::Down)
      when SF::Keyboard::Key::Left
        nes.control_pad.release(ControlPad::Button::Left)
      when SF::Keyboard::Key::Right
        nes.control_pad.release(ControlPad::Button::Right)
      when SF::Keyboard::Key::O
        nes.control_pad.release(ControlPad::Button::Start)
      when SF::Keyboard::Key::P
        nes.control_pad.release(ControlPad::Button::Select)
      end
    end
  end

  elapsed = clock.restart.as_milliseconds
  nes.step(elapsed)

  window.clear
  window.draw(nes_drawable)
  window.display
end
