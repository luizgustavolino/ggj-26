local M = {}

Scenes = {
    title = "title",
    game = "game",
    
}

M.init = function ()
    M.change_scene(Scenes.title)
end

M.change_scene = function(scene, params)
    M.current_scene = require("scene." .. scene)
    M.frame = 0
    M.current_scene.init(params)
end

M.update = function()
    M.current_scene.update(M.frame)
    M.frame = M.frame + 1
end

M.draw = function() 
    M.current_scene.draw(M.frame)
end

return M 