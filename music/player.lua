-- ============================================================
-- Simple frame-based music player
-- Usage:
--   local player = require("music_player")
--   local song = require("song_menu")
--   player.play(song)
--
--   -- In your game loop (called once per frame):
--   player.tick()
--
--   -- To stop:
--   player.stop()
-- ============================================================

local M = {}

local current_song = nil
local frame = 0
local playing = false

function M.play(song)
    current_song = song
    frame = 0
    playing = true
end

function M.stop()
    playing = false
    current_song = nil
    frame = 0
end

function M.tick()
    if not playing or not current_song then return end

    local events = current_song.notes[frame]
    if events then
        for _, ev in ipairs(events) do
            sfx.fx(ev[1], ev[2])
        end
    end

    frame = frame + 1
    if frame >= current_song.length then
        frame = 0  -- seamless loop
    end
end

return M
