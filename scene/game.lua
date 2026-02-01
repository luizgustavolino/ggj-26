local M = {}

local GameStates = {
    waiting_start = "waiting_start"
}

M.init = function(params)
    M.state = GameStates.waiting_start
    M.players = params.players

    M.map = require "map.s01"

    local Ninja = require "scene.utils.ninja"
    M.ninja = Ninja.new()
    M.ninja.init({ player = 0 })

    local Hands = require "scene.utils.hands"
    local num_hands = M.players - 1
    M.hands = {}
    
    for i = 1, num_hands do
        local hand = Hands.new()
        table.insert(M.hands, hand)
        hand.init({player = i+1})
    end
end 

M.update = function(frame)
    local actions = {
        [GameStates.waiting_start] = function(frame)
            M.ninja.update(frame)
            for i = 1, #M.hands do M.hands[i].update(frame, i) end
        end
    }

    pcall(actions[M.state], frame)
end 

M.draw = function(frame)
    ui.map(M.map.BG1, 0, 0)
    ui.map(M.map.BG2, 0, 0) 

    if M.state == GameStates.waiting_start then
        M.ninja.draw(frame)
        for i = 1, #M.hands do M.hands[i].draw(frame, i) end
    end
end 

return M