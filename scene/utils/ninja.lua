local TILE_SIZE = 16
local SCREEN_W = 480
local SCREEN_H = 270
local TILES_X = 30
local TILES_Y = 17
local MOVE_STEP = 2
local MOVE_FRAMES = 4
 
local MIN_TILE_Y = 1
local MAX_TILE_Y = 15
local MIN_TILE_X = 0
local MAX_TILE_X = 29

NinjaStates = {
    before_start = 'before_start',
    start = 'start',
    idle = 'idle',
    freeze = 'freeze',
    win = 'win',
    lose = 'lose',
    smoke = 'smoke',
    moving = 'moving'
}

local Directions = {
    none = 0,
    up = 1,
    down = 2,
    left = 3,
    right = 4
}

local function new()
    local M = {}

    local move_dir = Directions.none
    local move_progress = 0
    local target_tile_x = 0
    local target_tile_y = 0
    local queued_dir = Directions.none
    local item_index = math.random(0, 24)
    local item_changes_left = 3

    local block_layer = nil
    local map_width = TILES_X

    local function get_direction_from_input(player)
        if ui.btn(UP, player) then return Directions.up end
        if ui.btn(DOWN, player) then return Directions.down end
        if ui.btn(LEFT, player) then return Directions.left end
        if ui.btn(RIGHT, player) then return Directions.right end
        return Directions.none
    end

    local function is_tile_blocked(tile_x, tile_y)
        if not block_layer then return false end
        local tile_index = tile_y * map_width + tile_x + 1

        for layer_key, layer_data in pairs(block_layer) do
            if layer_key ~= "lupi_metadata" and layer_data[tile_index] then
                return true
            end
        end

        return false
    end

    local function can_move_to(tile_x, tile_y)
        if tile_x < MIN_TILE_X or tile_x > MAX_TILE_X then return false end
        if tile_y < MIN_TILE_Y or tile_y > MAX_TILE_Y then return false end
        if is_tile_blocked(tile_x, tile_y) then return false end
        return true
    end

    local function get_target_tile(dir, from_x, from_y)
        local tx, ty = from_x, from_y
        if dir == Directions.up then ty = ty - 1
        elseif dir == Directions.down then ty = ty + 1
        elseif dir == Directions.left then tx = tx - 1
        elseif dir == Directions.right then tx = tx + 1
        end
        return tx, ty
    end

    local function start_move(dir)
        local tx, ty = get_target_tile(dir, M.tile_x, M.tile_y)
        if can_move_to(tx, ty) then
            move_dir = dir
            move_progress = 0
            target_tile_x = tx
            target_tile_y = ty
            M.change_state(NinjaStates.moving)
            return true
        end
        return false
    end

    local function change_item(frame, player)
        if item_changes_left > 1 then
            local new_index
            
            repeat
                new_index = math.random(0, 24)
            until new_index ~= item_index

            item_index = new_index
            item_changes_left = item_changes_left - 1
        end 
    end 

    local updaters = {
        [NinjaStates.before_start] = function()
            -- só espera
        end,
        [NinjaStates.start] = function(frame, player)
            if ui.btnp(BTN_Z, player) and M.frame > 10 then
                M.change_state(NinjaStates.smoke)
            end
        end,
        [NinjaStates.smoke] = function(frame, player)
            if frame >= 10 * 9 then
                M.game.dispatch_event(GameEvents.ninja_start_issued)
            end
        end,
        [NinjaStates.idle] = function(frame, player)
            local dir = get_direction_from_input(player)
            if dir ~= Directions.none then
                start_move(dir)
            end

            if ui.btnp(BTN_Z, player) then
                change_item(frame, player)
            end
        end,
        [NinjaStates.freeze] = function(frame, player)
            -- não move!
        end,
        [NinjaStates.win] = function(frame, player)
            -- não move!
        end,
        [NinjaStates.lose] = function(frame, player)
            -- não move!
        end,
        [NinjaStates.moving] = function(frame, player)
            move_progress = move_progress + 1

            if move_dir == Directions.up then
                M.y = M.y - MOVE_STEP
            elseif move_dir == Directions.down then
                M.y = M.y + MOVE_STEP
            elseif move_dir == Directions.left then
                M.x = M.x - MOVE_STEP
            elseif move_dir == Directions.right then
                M.x = M.x + MOVE_STEP
            end

            local input_dir = get_direction_from_input(player)
            if input_dir ~= Directions.none then
                queued_dir = input_dir
            end

            if ui.btnp(BTN_Z, player) then
                change_item(frame, player)
            end

            if move_progress >= MOVE_FRAMES then
                M.tile_x = target_tile_x
                M.tile_y = target_tile_y
                M.x = M.tile_x * TILE_SIZE
                M.y = M.tile_y * TILE_SIZE
                move_dir = Directions.none
                move_progress = 0

                local next_dir = queued_dir
                if next_dir == Directions.none then
                    next_dir = get_direction_from_input(player)
                end
                queued_dir = Directions.none

                if next_dir ~= Directions.none then
                    if not start_move(next_dir) then
                        M.change_state(NinjaStates.idle)
                    end
                else
                    M.change_state(NinjaStates.idle)
                end
            end
        end
    }

    local drawers = {
        [NinjaStates.before_start] = function()
            -- só espera
        end,
        [NinjaStates.start] = function(frame, player)
            local f = ((frame / 12) % 3) // 1
            ui.tile(Sprites.img.ninja_a, f, M.x, M.y)
            local d = math.sin(frame/10) * 2
            ui.spr(Sprites.img.hide, M.x - 70, M.y - (34+d))
        end,
        [NinjaStates.smoke] = function(frame)
            local f = ((frame / 9)) // 1
            if f < 9 then
                if f > 3 then
                    ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)          
                end
                ui.tile(Sprites.img.ninja_a, 3 + f, M.x, M.y)
            end
        end,
        [NinjaStates.freeze] = function(frame, player)
            ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)
        end,
        [NinjaStates.idle] = function(frame)
            ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)
        end,
        [NinjaStates.moving] = function(frame)
            ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)
        end,
        [NinjaStates.win] = function(frame, player)
            local f = 0
            if frame % 20 >= 10 then  f = 5 end 
            ui.tile(Sprites.img.ninja_a, f, M.x, M.y)
        end,
        [NinjaStates.lose] = function(frame, player)
            local f = 14
            if frame % 60 >= 40 then  f = 13
            elseif frame % 60 >= 20 then  f = 12 end 
            ui.tile(Sprites.img.ninja_a, f, M.x, M.y)
        end
    }

    M.init = function(params)
        params = params or {}
        M.state = NinjaStates.start
        M.frame = 0
        M.player = params.player or 0
        M.game = params.game

        M.tile_x = 15
        M.tile_y = 8

        M.x = M.tile_x * TILE_SIZE
        M.y = M.tile_y * TILE_SIZE

        move_dir = Directions.none
        move_progress = 0
        queued_dir = Directions.none

        block_layer = params.block_layer
        if block_layer and block_layer.lupi_metadata then
            map_width = block_layer.lupi_metadata.width
        end
    end

    M.is_at = function(x,y)
        return M.tile_x == x and M.tile_y == y
    end

    M.game_state_changed = function(new_state)
        local actions = {
            [GameStates.waiting_start] = function()
                M.change_state(NinjaStates.before_start)
            end,
            [GameStates.waiting_ninja_start] = function()
                M.change_state(NinjaStates.start)
            end,
            [GameStates.ninja_is_hidding] = function()
                item_changes_left = 3
                M.change_state(NinjaStates.idle)
            end,
            [GameStates.players_will_seek] = function()
                M.tile_x = target_tile_x
                M.tile_y = target_tile_y
                M.change_state(NinjaStates.freeze)
            end,
            [GameStates.level_conclusion] = function()
                if M.game.win == true then 
                    M.change_state(NinjaStates.win)
                else 
                    M.change_state(NinjaStates.lose)
                end
            end
        }

        actions[new_state]()
    end 

    M.change_state = function(new_state)
        M.state = new_state
        M.frame = 0
    end

    M.update = function(frame, game_state)
        updaters[M.state](M.frame, M.player, game_state)
    end

    M.draw = function(frame)
        drawers[M.state](M.frame)
        M.frame = M.frame + 1
    end

    return M
end

return { new = new }
