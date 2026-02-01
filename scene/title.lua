local M = {}

M.init = function()

end 

M.update = function(frame)
    if ui.btn(BTN_Z, 0) then
        ui.spr(Sprites.img.nplayers, 480/2 - 32, 120)
    end
end 

M.draw = function(frame)
    ui.spr(Sprites.img.title, 480/2 - 180/2, 40)
end 

return M