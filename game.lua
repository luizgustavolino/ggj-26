require "sprites"
require "palette"
ninja = require "ninja"
hands = require "hands"

ninja.init()
hands.init()

frame = 0

local s01 = require "map.s01"

function update()
  frame = frame + 1

  for i = 1, #Palette do
    local color = Palette[i]
    ui.palset(i - 1, color)
  end

  ui.cls(0)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  if frame <= 3 then return end

  hands.update(frame)

  ui.map(s01.BG1, 0, 0)
  ui.map(s01.BG2, 0, 0)
  ninja.draw(frame)
  hands.draw(frame)

  if ui.btnp(BTN_Z, 0) and frame > 3 then
    ninja.change_state(NinjaStates.smoke)
    sfx.fx(60, 50)
  end

end
