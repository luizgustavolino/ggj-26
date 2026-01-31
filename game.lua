function update()
  ui.palset(0, 0x03E6) 
  ui.palset(1, 0x07E0) 
  ui.palset(2, 0x467A)

  ui.cls(0)
  ui.clip(0, 0, 480, 270)
  ui.camera()

  ui.rectfill(50, 50, 80, 80, 2)
  ui.print("hello world", 20, 20, 2)
end 
