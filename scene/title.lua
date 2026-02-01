local M = {}

M.init = function()

end 

M.update = function(frame)
    if ui.btn(BTN_Z, 0) then
        ui.tile(Sprites.img.nplayers, 0, 480/2 - 32, 220)
    end
end 

M.draw = function(frame)
    ui.spr(Sprites.img.title, 480/2 - 171/2, 40)
end 

return M