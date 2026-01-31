local M = {}

NinjaStates = {
  idle = 'idle',
  smoke = 'smoke'
}

local drawers = {
    [NinjaStates.idle] = function(frame)
        local f = ((frame/12)%3) // 1
        ui.tile(Sprites.img.ninja_a, f, 100, 100)
    end,
    [NinjaStates.smoke] = function(frame)
        local f = ((frame/12)%3) // 1
        ui.tile(Sprites.img.ninja_a, 3 + f, 100, 100)
    end 
}

M.init = function()
    M.state = NinjaStates.idle
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