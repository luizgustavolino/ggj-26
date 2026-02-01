local M = {}

local GameStates = {
    waiting_start = "waiting_start"
}

M.init = function(map, params)
    M.state = GameStates.waiting_start
    M.players = players

    M.map = require "map.s01"
    
    M.ninja = require "scene.utils.ninja"
    M.ninja.init()

    M.hands = {}
    
    if params.players == 2 then 
        table.insert(M.hands, require "scene.utils.hands")
    elseif params.players == 3 then 
        table.insert(M.hands, require "scene.utils.hands")
        table.insert(M.hands, require "scene.utils.hands")
    end 

    for i = 1, #M.hands do M.hands[i].init() end 
end 

M.update = function(frame)
    local actions = {
        [GameStates.waiting_start] = function(frame) 
            for i = 1, #M.hands do M.hands[i].update(frame, i) end 
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
        for i = 1, #M.hands do  M.hands[i].draw(frame, i) end
    end
end 

return M