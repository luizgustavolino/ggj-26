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
    local r = color & 0b0000000000011111
    local g = (color & 0b0000001111100000) >> 5
    local b = (color & 0b0111110000000000) >> 10

    local brightness = math.max(Director.get_brightness(), 1)
    r = r // brightness
    g = g // brightness
    b = b // brightness

    ui.palset(i - 1, r | (g << 5) | (b << 10))

  end
  
  frame = frame + 1
  if frame <= 3 then return end

  Director.update()
  Director.draw()

end
