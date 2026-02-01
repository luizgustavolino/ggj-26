require "sprites"
require "palette"

local director = require "director"
director.init()

-- ninja = require "ninja"
-- hands = require "hands"

-- ninja.init()
-- hands.init()
-- local s01 = require "map.s01"

local frame = 0

function update()
  for i = 1, #Palette do
    local color = Palette[i]
    ui.palset(i - 1, color)
  end

  ui.cls(2)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  frame = frame + 1
  if frame <= 3 then return end

  director.update()
  director.draw()
  
  -- hands.update(frame)

  -- ui.map(s01.BG1, 0, 0)
  -- ui.map(s01.BG2, 0, 0)
  -- ninja.draw(frame)
  -- hands.draw(frame)

  -- if ui.btnp(BTN_Z, 0) and frame > 3 then
  --   ninja.change_state(NinjaStates.smoke)
  --   sfx.fx(60, 50)
  -- end

end
