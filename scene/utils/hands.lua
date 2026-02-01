local ACCELERATION = 0.2
local FRICTION = 0.92
local MAX_SPEED = 10
local BOUNCE_FACTOR = 1.1
local SCREEN_W = 480
local SCREEN_H = 270
local SPRITE_SIZE = 16
local MAX_BETS = 3

HandStates = {
  map_looking = 'map_looking',
  waiting = 'waiting',
  playing = 'playing'
}

local function new()
    local M = {}

    local drawers = {
        [HandStates.map_looking] = function(frame)
            local f = (1 + math.min(9, (frame//4)%30))
            ui.spr(Sprites.img["observe"..f], 480/2 - 128/2, 270/2 - 32/2)
        end,
        [HandStates.waiting] = function(frame)
            -- só espera
        end,
        [HandStates.playing] = function(frame)
            local d = 0
            if M.acel_x == 0 and M.acel_y == 0 then
                d = math.sin(frame/10) * 3
            end

            local tx = (M.x + (SPRITE_SIZE / 2)) // 16
            local ty = (M.y + (SPRITE_SIZE)) // 16
            ui.tile(Sprites.img.hands, 1, tx * 16, ty * 16)
            ui.tile(Sprites.img.hands, M.player, M.x, d + M.y - 8)
        end
    }

    local updaters = {
        [HandStates.map_looking] = function(frame)
            -- só espera
        end,
        [HandStates.waiting] = function(frame)
            -- só espera
        end,
        [HandStates.playing] = function(frame, player)
            if ui.btn(UP, player) then
                M.acel_y = M.acel_y - ACCELERATION
            end
            if ui.btn(DOWN, player) then
                M.acel_y = M.acel_y + ACCELERATION
            end
            if ui.btn(LEFT, player) then
                M.acel_x = M.acel_x - ACCELERATION
            end
            if ui.btn(RIGHT, player) then
                M.acel_x = M.acel_x + ACCELERATION
            end

            if ui.btnp(BTN_Z, player) then
                if #M.bets < MAX_BETS then
                    local tx = (M.x + (SPRITE_SIZE / 2)) // 16
                    local ty = (M.y + (SPRITE_SIZE)) // 16

                    local already_placed = false

                    for _, bet in ipairs(M.bets) do
                        if bet.x == tx and bet.y == ty then
                            already_placed = true
                            break
                        end
                    end

                    if not already_placed then
                        M.place_bet(tx,ty)
                    end
                end
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
    }

    M.init = function(params)
        M.state = HandStates.map_looking
        M.game = params.game
        M.ninja = params.ninja
        
        M.state_frame = 0
        M.x = SCREEN_W / 2 - ((params.player * 32) - 76)
        M.y = SCREEN_H / 2 - 64
        M.acel_x = 0
        M.acel_y = 0
        M.player = params.player
        M.bets = {}
    end

    M.place_bet = function(x, y) 
        if M.ninja.is_at(x, y) then
            M.game.dispatch_event(GameEvents.ninja_found)
        else 
            table.insert(M.bets, {x = x, y = y})
        end 
    end 

    M.change_state = function(new_state)
        M.state = new_state
        M.state_frame = 0
    end

    M.game_state_changed = function(new_state)
        local actions = {
            [GameStates.waiting_start] = function()
                M.change_state(HandStates.map_looking)
            end,
            [GameStates.waiting_ninja_start] = function()
                M.change_state(HandStates.waiting)
            end,
            [GameStates.ninja_is_hidding] = function()
                M.change_state(HandStates.waiting)
            end,
            [GameStates.players_will_seek] = function()
                M.change_state(HandStates.playing)
            end,
            [GameStates.level_conclusion] = function()
                M.change_state(HandStates.waiting)
            end
        }

        actions[new_state]()
    end 

    M.count_bets = function()
        return #M.bets 
    end 

    M.update = function(frame, game_state)
        updaters[M.state](M.state_frame, M.player - 1)
    end

    M.draw = function(frame)
        for _, bet in ipairs(M.bets) do
            ui.tile(Sprites.img.hands, 4, bet.x * 16, bet.y * 16)
            ui.tile(Sprites.img.hands, 5, bet.x * 16, bet.y* 16 -16)
        end
        
        drawers[M.state](M.state_frame)
        M.state_frame = M.state_frame + 1
    end

    return M
end

return { new = new }