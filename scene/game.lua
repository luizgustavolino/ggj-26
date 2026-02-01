local M = {}

TIME_TO_LOOK_AT_MAP = 300
TIME_TO_HIDE = 300

GameStates = {
    -- intro, ninja vai estar esperando
    -- P2 e P3 vão estar invisíveis
    -- 10 segundos para todos verem o mapa
    waiting_start = "waiting_start",

    -- instruções para todos fecharem os olhos
    -- ninja confirma que está pronto pelo controle
    waiting_ninja_start = "waiting_ninja_start",

    -- 10 segundos para o ninja se esconder no cenário
    -- ele usa o controle para trocar de asset
    -- P2 e P3 de olhos fechados
    ninja_is_hidding = "ninja_is_hidding",

    -- ninja não pode ser mover mais
    -- jogadores começaam a procurar
    -- com controle, podem dar até 3 palpites
    -- limite de tempo maior, ou até achar o ninja
    players_will_seek = "players_will_seek",

    -- encerramento
    level_conclusion = "level_conclusion",
}

GameEvents = {
    -- quando o ninja pressiona o botão para começar
    ninja_start_issued = "ninja_start_issued"
}

M.init = function(params)
    M.players = params.players
    M.state_frame = 0
    M.win = false

    M.map = require "map.s01"

    local Ninja = require "scene.utils.ninja"
    M.ninja = Ninja.new()
    M.ninja.init({ player = 0, block_layer = M.map.BLOCK, game = M })

    local Hands = require "scene.utils.hands"
    local num_hands = M.players - 1
    M.hands = {}
    
    for i = 1, num_hands do
        local hand = Hands.new()
        table.insert(M.hands, hand)
        hand.init({player = i+1, game = M})
    end

    M.change_state(GameStates.waiting_start)
    Director.fade_in(20)
end 

M.dispatch_event = function(event)
    local actions = {
        [GameEvents.ninja_start_issued] = function()
            M.change_state(GameStates.ninja_is_hidding)
        end
    }

    actions[event](frame)
end 

M.change_state = function(new_state)
    M.state = new_state
    M.state_frame = 0

    M.ninja.game_state_changed(new_state)
    for i = 1, #M.hands do M.hands[i].game_state_changed(new_state) end
end

--[[ GAME LOOP update/draw ]]

M.update = function(frame)
    local actions = {
        [GameStates.waiting_start] = function(frame)
            if M.state_frame == TIME_TO_LOOK_AT_MAP then 
                M.change_state(GameStates.waiting_ninja_start)
            end 
        end,
        [GameStates.waiting_ninja_start] = function(frame)
            -- espera pelo evento 'GameEvents.ninja_start_issued'
        end,
        [GameStates.ninja_is_hidding] = function(frame)
            if M.state_frame == TIME_TO_HIDE then 
                M.change_state(GameStates.players_will_seek)
            end 
        end,
        [GameStates.players_will_seek] = function(frame)
            -- sum bets of hands
            local total_bets = 0 
            local max_bets = 3 * (M.players - 1)
            for i = 1, #M.hands do
                total_bets = total_bets + M.hands[i].count_bets()
            end

            if total_bets == max_bets then
                M.win = true
                M.change_state(GameStates.level_conclusion)
            end
        end,
        [GameStates.level_conclusion] = function(frame)
            -- todo
        end
    }

    actions[M.state](frame)

    M.ninja.update(frame)
    for i = 1, #M.hands do
        M.hands[i].update(frame, i)
    end
end 

M.draw = function(frame)
    ui.map(M.map.BG1, 0, 0)
    ui.map(M.map.BG2, 0, 0) 

    M.ninja.draw(frame)
    for i = 1, #M.hands do
        M.hands[i].draw(frame, i)
    end

    if M.state == GameStates.level_conclusion then
        local f = (1 + math.min(12, (frame//4)%(13*2)))
        if M.win == true then 
            ui.spr(Sprites.img["ganhou" .. f], 480/2 - 128/2, 4)
        else 
            ui.spr(Sprites.img["perdeu" .. f], 480/2 - 128/2, 4)
        end 
    end
    
    M.state_frame = M.state_frame + 1
end 

return M