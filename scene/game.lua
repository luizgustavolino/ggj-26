local M = {}

local GameStates = {
    waiting_start = "waiting_start"
}

M.init = function(map, players)
    M.state = GameStates.waiting_start
    M.players = players

    M.map = require "map.s01"
    M.ninja = require "scene.utils.ninja"
    M.hands = require "scene.utils.hands"

    M.ninja.init()
    M.hands.init()
end 

M.update = function(frame)
    local actions = {
        [GameStates.waiting_start] = function(frame) 
            M.hands.update(frame)
        end
    }

    pcall(actions[M.state], frame)
end 

M.draw = function(frame)
    ui.cls(1)
    ui.map(M.map.BG1, 0, 0)
    ui.map(M.map.BG2, 0, 0)

    if M.state == GameStates.waiting_start then
        M.ninja.draw(frame)
        M.hands.draw(frame)
    end
end 

return M