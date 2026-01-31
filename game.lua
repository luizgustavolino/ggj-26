require "sprites"
require "palette"
ninja = require "ninja"

ninja.init()

function update(frame)

  for i = 1, #Palette do
    local color = Palette[i]
    ui.palset(i - 1, color)
  end

  ui.cls(0)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  ui.rectfill(50, 50, 80, 80, 2)
  ui.print("hello worlders?!", 20, 20, 2)

  ninja.draw(frame)

  if ui.btn(BTN_Z, 0) then
    ninja.change_state(NinjaStates.smoke)
  end

end 
