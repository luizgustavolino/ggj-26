local M = {}

Scenes = {
    title = "title",
    game = "game",
}

M.init = function (){
    M.change_scene(Scenes.title)
}

M.change_scene = function(scene){
    M.current_scene = require("scene." .. scene)
    M.frame = 0
    M.current_scene.init()
}

M.update = function(){
    M.current_scene.update(M.frame)
    M.frame = M.frame + 1
}

M.draw = function() {
    M.current_scene.draw(M.frame)
}

return M 