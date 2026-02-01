local M = {}

local TitleStates = {
    waiting_start = "waiting_start",
    waiting_players = "waiting_players",
    transition_to_game = "transition_to_game"
}

M.init = function()
    M.state = TitleStates.waiting_start 
    M.players = 2
    M.frame = 0
end 

M.update = function(frame)

    local actions = {
        [TitleStates.waiting_start] = function(frame) 
            if ui.btnp(BTN_Z, 0) then
                M.state = TitleStates.waiting_players
            end
        end,
        [TitleStates.waiting_players] = function(frame) 
            if ui.btnp(BTN_Z, 0) then
                M.frame = 0
                M.state = TitleStates.transition_to_game
            elseif ui.btnp(BTN_G, 0) then
                M.state = TitleStates.waiting_start
            elseif ui.btnp(LEFT, 0) then
                M.players = 2
            elseif ui.btnp(RIGHT, 0) then
                M.players = 3
            end
        end,
        [TitleStates.transition_to_game] = function(frame)
            if M.frame == 1 then 
                Director.fade_out(30)
            elseif M.frame == 31 then 
                Director.change_scene(Scenes.game, { players = M.players })
            end
            M.frame = M.frame + 1
        end 
    }

    actions[M.state](frame)
end 

M.draw = function(frame)
    ui.cls(1)
    ui.spr(Sprites.img.title, 480/2 - 170/2, 40)

    if M.state == TitleStates.waiting_start then
        if frame % 60 > 20 then
            ui.print("- Aperte B para iniciar -", 480/2 - 128/2, 200, 181)
        end 
        ui.print("Global Game Jam 26 . PUC PR . Arte: LimeZu@itchio", 480/2 - 245/2, 242, 180)
    elseif M.state == TitleStates.waiting_players then
        ui.print("Quantas pessoas para jogar?", 480/2 - 136/2 - 2, 150, 181)

        ui.tile(Sprites.img.nplayers, 0, 480/2 - 16 - 32, 200)
        ui.tile(Sprites.img.nplayers, 1, 480/2 - 16 + 32, 200)

        local d = math.sin(frame/12) * 3
        local p2 = { x = 480/2 - 16 + 32 + 8 - 64, y = d + 200 - 24 }
        local p3 = { x = 480/2 - 16 + 32 + 8, y = d + 200 - 24 }

        if M.players == 2 then 
            ui.tile(Sprites.img.hands, 0, p2.x, p2.y)
            ui.print("Uma esconde, uma procura", 480/2 - 136/2, 242, 180)
        elseif M.players == 3 then 
            ui.tile(Sprites.img.hands, 0, p3.x, p3.y)
            ui.print("Uma esconde, duas procuram", 480/2 - 136/2 - 3, 242, 180)
        end 
    end
end 

return M