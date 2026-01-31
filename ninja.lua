local M = {}


local states = {
  idle = 'idle',
  smoke = 'smoke'
}

local drawers = {
    [states.idle] = function(frame)
        local f = ((frame/12)%3) // 1
        ui.tile(Sprites.img.ninja_a, f, 100, 100)
    end,
    [states.smoke] = function(frame)

    end 
}

M.init = function()
    M.state = states.idle
    M.state_frame = 0
end

M.draw = function(frame)
    drawers[M.state](M.state_frame)
    M.state_frame = M.state_frame + 1
end 

return M 