local M = {}

local TitleStates = {
    waiting_start = "waiting_start",
    waiting_players = "waiting_players",
    transition_to_game = "transition_to_game"
}

M.init = function()
    M.state = TitleStates.waiting_start 
    M.players = 2
end 

M.update = function(frame)

    local actions = {
        [TitleStates.waiting_start] = function(frame) 
            if ui.btn(BTN_Z, 0) then
                M.state = TitleStates.waiting_players
            end
        end,
        [TitleStates.waiting_players] = function(frame) 
            if ui.btn(BTN_Z, 0) then
                M.state = TitleStates.transition_to_game
            elseif ui.btn(BTN_X, 0) then
                M.state = TitleStates.waiting_start
            end
        end 
    }
end 

M.draw = function(frame)
    ui.cls(1)
    ui.spr(Sprites.img.title, 480/2 - 170/2, 40)

    if M.state == TitleStates.waiting_start then
        if frame % 60 > 20 then
            ui.print("- Aperte A ou B para iniciar -", 480/2 - 138/2, 200, 181)
        end 
    elseif M.state == TitleStates.waiting_players then
        ui.print("Quantas pessoas para jogar?", 480/2 - 136/2, 150, 181)
        ui.tile(Sprites.img.nplayers, 0, 480/2 - 16 - 32, 200)
        ui.tile(Sprites.img.nplayers, 1, 480/2 - 16 + 32, 200)

        local d = math.sin(frame/12) * 3
        local p2 = { x = 480/2 - 16 + 32 + 8 - 64, y = d + 200 - 24 }
        local p3 = { x = 480/2 - 16 + 32 + 8, y = d + 200 - 24 }
        
        if M.players == 2 then 
                ui.tile(Sprites.img.hands, 0, p2.x, p2.y)
        elseif M.players == 3 then 
            ui.tile(Sprites.img.hands, 1, p3.x, p3.y)
        end 
    end
end 

return M