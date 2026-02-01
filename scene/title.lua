local M = {}

M.init = function()

end 

M.update = function(frame)
    if ui.btnp(BTN_Z, 0) and frame > 3 then
        sfx.fx(60, 80)
    end
end 

M.draw = function(frame)
    ui.spr(Sprites.img.title, 480/2 - 180/2, 40)


end 

return M