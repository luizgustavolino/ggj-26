local M = {}

HandStates = {
  waiting = 'waiting',
  playing = 'playing'
}

local drawers = {
    [HandStates.waiting] = function(frame)
        ui.tile(Sprites.img.hands, 0, 480//2, 270//2)
    end,
    [HandStates.playing] = function(frame)
        
    end 
}

M.init = function()
    M.state = HandStates.waiting
    M.state_frame = 0
end 

M.change_state = function(new_state)
    M.state = new_state
    M.state_frame = 0
end 

M.draw = function(frame)
    drawers[M.state](M.state_frame)
    M.state_frame = M.state_frame + 1
end 

return M 