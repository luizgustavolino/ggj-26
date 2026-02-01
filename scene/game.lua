local M = {}

local GameStates = {
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

M.init = function(params)
    M.state = GameStates.waiting_start
    M.players = params.players

    M.map = require "map.s01"

    local Ninja = require "scene.utils.ninja"
    M.ninja = Ninja.new()
    M.ninja.init({ player = 0, block_layer = M.map.BLOCK })

    local Hands = require "scene.utils.hands"
    local num_hands = M.players - 1
    M.hands = {}
    
    for i = 1, num_hands do
        local hand = Hands.new()
        table.insert(M.hands, hand)
        hand.init({player = i+1})
    end
end 

M.update = function(frame)
    local actions = {
        local mstate = M.state
        [GameStates.waiting_start] = function(frame)
            M.ninja.update(frame, 0, mstate)
            for i = 1, #M.hands do M.hands[i].update(frame, i, mstate) end
        end
    }

    pcall(actions[M.state], frame)
end 

M.draw = function(frame)
    ui.map(M.map.BG1, 0, 0)
    ui.map(M.map.BG2, 0, 0) 

    if M.state == GameStates.waiting_start then
        M.ninja.draw(frame)
        for i = 1, #M.hands do M.hands[i].draw(frame, i) end
    end
end 

return M