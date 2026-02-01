local TILE_SIZE = 16
local SCREEN_W = 480
local SCREEN_H = 270
local TILES_X = 30
local TILES_Y = 17
local MOVE_STEP = 2
local MOVE_FRAMES = 8
 
local MIN_TILE_Y = 1
local MAX_TILE_Y = 15
local MIN_TILE_X = 0
local MAX_TILE_X = 29

NinjaStates = {
    before_start = 'before_start'
    start = 'start',
    idle = 'idle',
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
    local item_index = 0

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

    local updaters = {
        [NinjaStates.before_start] = function()
            -- só espera
        end,
        [NinjaStates.start] = function(frame, player)
            if ui.btnp(BTN_Z, player) then
                M.game.dispatch_event(GameEvents.ninja_start_issued)
            end
        end,
        [NinjaStates.smoke] = function(frame, player)
            if frame >= 10 * 9 then
                M.change_state(NinjaStates.idle)
            end
        end,
        [NinjaStates.idle] = function(frame, player)
            local dir = get_direction_from_input(player)
            if dir ~= Directions.none then
                start_move(dir)
            end

            if ui.btnp(BTN_Z, player) then
                item_index = (item_index + 1) % 25
            end
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
                item_index = (item_index + 1) % 25
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
        end,
        [NinjaStates.smoke] = function(frame)
            local f = ((frame / 9)) // 1
            if f < 10 then
                if f > 3 then
                    ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)          
                end
                ui.tile(Sprites.img.ninja_a, 3 + f, M.x, M.y)
            end
        end,
        [NinjaStates.idle] = function(frame)
            ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)
        end,
        [NinjaStates.moving] = function(frame)
            ui.tile(Sprites.map.scene_b, item_index, M.x, M.y)
        end
    }

    M.init = function(params)
        params = params or {}
        M.state = NinjaStates.start
        M.state_frame = 0
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

    M.game_state_changed = function(new_state)
        local actions = {
            [GameStates.waiting_ninja_start] = function()
                M.change_state(NinjaStates.start)
            end
        }

        actions[new_state]()
    end 

    M.change_state = function(new_state)
        M.state = new_state
        M.state_frame = 0
    end

    M.update = function(frame, game_state)
        updaters[M.state](M.state_frame, M.player, game_state)
    end

    M.draw = function(frame)
        drawers[M.state](M.state_frame)
        M.state_frame = M.state_frame + 1
    end

    return M
end

return { new = new }
