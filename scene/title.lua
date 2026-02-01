local M = {}

local TitleStates = {
    waiting_start = "waiting_start",
    waiting_players = "waiting_players",
    transition_to_game = "transition_to_game"
}

M.init = function()
    M.state = TitleStates.waiting_start 
end 

M.update = function(frame)
    if ui.btn(BTN_Z, 0) or ui.btn(BTN_X, 0) then
        M.state = TitleStates.waiting_players
    end
end 

M.draw = function(frame)
    ui.cls(1)
    ui.spr(Sprites.img.title, 480/2 - 170/2, 40)

    if M.state == TitleStates.waiting_start then
        if frame % 60 > 20 then
            ui.print("- Aperte A ou B para iniciar -", 480/2 - 138/2, 200, 180)
        end 
    elseif M.state == TitleStates.waiting_players then
        ui.print("Quantas pessoas para jogar?", 480/2 - 138/2, 200, 130)
        ui.tile(Sprites.img.nplayers, 0, 480/2 - 32 - 32, 200)
        ui.tile(Sprites.img.nplayers, 1, 480/2 - 32 + 32, 200)
    end
end 

return M