require "sprites"
require "palette"
ninja = require "ninja"

ninja.init()
frame = 0

function update()
  frame = frame + 1

  for i = 1, #Palette do
    local color = Palette[i]
    ui.palset(i - 1, color)
  end

  ui.cls(0)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  ui.print("hello?", 20, 20, 2)
  ninja.draw(frame)

  if ui.btn(BTN_Z, 0) and frame > 4 then
    ninja.change_state(NinjaStates.smoke)
  end

end 
