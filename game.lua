require "sprites"
require "palette"

Director = require "director"
Director.init()

local frame = 0
ui.clip(0, 0, 480, 270)
ui.camera()

function update()
  for i = 1, #Palette do
    local color = Palette[i]
    local r = 0b0000000000011111
    local g = 0b0000001111100000
    local b = 0b0111110000000000
    
    r = r / 2
    g = g / 2
    b = b / 2

    ui.palset(i - 1, r | g | b)
  end
  
  frame = frame + 1
  if frame <= 3 then return end

  Director.update()
  Director.draw()

  -- if ui.btnp(BTN_Z, 0) and frame > 3 then
  --   ninja.change_state(NinjaStates.smoke)
  --   sfx.fx(60, 50)
  -- end

end
