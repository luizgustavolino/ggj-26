require "sprites"
require "palette"

function update()

  for i = 1, #Palette do
    local color = Palette[i]
    ui.palset(i - 1, color)
  end

  ui.cls(0)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  ui.rectfill(50, 50, 80, 80, 2)
  ui.print("hello world?", 20, 20, 2)

  ui.spr(Sprites.find("ninja_a"), 100, 100)

end 
