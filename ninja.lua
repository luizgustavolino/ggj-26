local M = {}

local states = {
  idle = 'idle',
  smoke = 'smoke'
}

local drawers = {
    [states.idle] = function(frame)
        local f = ((frame/4)%3) // 1
        ui.tile(Sprites.img.ninja_a, f, 100, 100)
    end,
    [states.smoke] = function(frame)

    end 
}

local state_frame = 0

M.init = function()
    M.state = states.idle
end

M.draw = function(frame)
    state_frame = state_frame + 1
    drawers[M.state](state_frame)
end 

return M 