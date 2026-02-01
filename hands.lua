local M = {}

local ACCELERATION = 0.2
local FRICTION = 0.92
local MAX_SPEED = 10
local BOUNCE_FACTOR = 1.1
local SCREEN_W = 480
local SCREEN_H = 270
local SPRITE_SIZE = 16

HandStates = {
  waiting = 'waiting',
  playing = 'playing'
}

local drawers = {
    [HandStates.waiting] = function(frame)
        local d = 0
        if M.acel_x == 0 and M.acel_y == 0 then 
            d = math.sin(frame/10) * 3
        end
        
        local tx, ty = (M.x + SPRITE_SIZE) // 16, (M.y + SPRITE_SIZE) // 16
        ui.tile(Sprites.img.hands, 1, tx * 16, ty * 16)
        ui.tile(Sprites.img.hands, 0, M.x, d + M.y)
    end,
    [HandStates.playing] = function(frame)
        
    end 
}

M.init = function()
    M.state = HandStates.waiting
    M.state_frame = 0
    M.x = SCREEN_W / 2
    M.y = SCREEN_H / 2
    M.acel_x = 0
    M.acel_y = 0
end 

M.change_state = function(new_state)
    M.state = new_state
    M.state_frame = 0
end 

M.update = function(frame)
    
    if ui.btn(UP, 0) then
        M.acel_y = M.acel_y - ACCELERATION
    end
    if ui.btn(DOWN, 0) then
        M.acel_y = M.acel_y + ACCELERATION
    end
    if ui.btn(LEFT, 0) then
        M.acel_x = M.acel_x - ACCELERATION
    end
    if ui.btn(RIGHT, 0) then
        M.acel_x = M.acel_x + ACCELERATION
    end

    local speed = math.sqrt(M.acel_x * M.acel_x + M.acel_y * M.acel_y)
    if speed > MAX_SPEED then
        M.acel_x = (M.acel_x / speed) * MAX_SPEED
        M.acel_y = (M.acel_y / speed) * MAX_SPEED
    end

    M.x = M.x + M.acel_x
    M.y = M.y + M.acel_y

    if M.x < 0 then
        M.x = 0
        M.acel_x = -M.acel_x * BOUNCE_FACTOR
    elseif M.x > SCREEN_W - SPRITE_SIZE then
        M.x = SCREEN_W - SPRITE_SIZE
        M.acel_x = -M.acel_x * BOUNCE_FACTOR
    end

    if M.y < 0 then
        M.y = 0
        M.acel_y = -M.acel_y * BOUNCE_FACTOR
    elseif M.y > SCREEN_H - SPRITE_SIZE then
        M.y = SCREEN_H - SPRITE_SIZE
        M.acel_y = -M.acel_y * BOUNCE_FACTOR
    end

    M.acel_x = M.acel_x * FRICTION
    M.acel_y = M.acel_y * FRICTION

    if math.abs(M.acel_x) < 0.01 then M.acel_x = 0 end
    if math.abs(M.acel_y) < 0.01 then M.acel_y = 0 end
end 

M.draw = function(frame)
    drawers[M.state](M.state_frame)
    M.state_frame = M.state_frame + 1
end 

return M 