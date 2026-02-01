local M = {}

HandStates = {
  waiting = 'waiting',
  playing = 'playing'
}

local drawers = {
    [HandStates.waiting] = function(frame)
        local d = math.sin(frame/10) * 3
        ui.tile(Sprites.img.hands, 0, M.x, d + M.y)
    end,
    [HandStates.playing] = function(frame)
        
    end 
}

M.init = function()
    M.state = HandStates.waiting
    M.state_frame = 0
    M.x = 480/2
    M.y = 270/2
end 

M.change_state = function(new_state)
    M.state = new_state
    M.state_frame = 0
end 

M.update = function(frame)
    if ui.btn(UP, 0) then
        M.y = M.y - 1
    end 
    if ui.btn(DOWN, 0) then
        M.y = M.y + 1
    end 
    if ui.btn(LEFT, 0) then
        M.x = M.x - 1
    end 
    if ui.btn(RIGHT, 0) then
        M.x = M.x + 1
    end 
end 

M.draw = function(frame)
    drawers[M.state](M.state_frame)
    M.state_frame = M.state_frame + 1
end 

return M 