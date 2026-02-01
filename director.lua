local M = {}

M.brightness = 0
M.brightness_target = 1
M.fade_remaining = 60 * 3

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

    if M.fade_remaining > 0 then
        local step = (M.brightness_target - M.brightness) / M.fade_remaining
        M.brightness = M.brightness + step
        M.fade_remaining = M.fade_remaining - 1
    else
        M.brightness = M.brightness_target
    end
end

M.draw = function() 
    M.current_scene.draw(M.frame)
end

M.get_brightness = function()
    return M.brightness
end

M.fade_in = function(frames)
    M.brightness_target = 1
    M.fade_remaining = frames
end

M.fade_out = function(frames)
    M.brightness_target = 0
    M.fade_remaining = frames
end

return M 