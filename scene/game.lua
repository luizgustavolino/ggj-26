local M = {}

local GameStates = {
    waiting_start = "waiting_start"
}

M.init = function(map, players)
    M.state = GameStates.waiting_start
    M.players = players

    M.map = require "map.s01"
    M.ninja = require "ninja"
    M.hands = require "hands"

    M.ninja.init()
    M.hands.init()
end 

M.update = function(frame)
    local actions = {
        [GameStates.waiting_start] = function(frame) 
            
        end
    }

    pcall(actions[M.state], frame)
end 

M.draw = function(frame)
    ui.cls(1)

    if M.state == GameStates.waiting_start then
        ui.print("cena do jogo", 480/2 - 128/2, 200, 181)
    end
end 

return M