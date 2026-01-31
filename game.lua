function update()
  ui.palset(0, 0x03E6) 
  ui.palset(1, 0x07E0) 
  
  ui.clip(0, 0, 480, 270)
  ui.camera()
  
  ui.print("hello world", 20, 20, 1)
end 
