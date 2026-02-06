-- ═══════════════════════════════════════════════════
--  "Lupi Bossa" — Game Menu Theme
--  90 BPM | Key of C major | 8-bar loop
--  40 frames/beat · 160 frames/bar · 1280 frames (~21s)
--
--  Progression: Cmaj7 | Am7 | Dm7 | G7 |
--               Cmaj7 | Fmaj7 | Dm7 | G7
--
--  Voices (max 3 simultaneous):
--    Bass  (59) Acoustic Bass    — root movement
--    Rhodes(50) Rhodes Piano     — jazz chords (3rds & 7ths)
--    Melody(62) Kalimba          — gentle melodic line
-- ═══════════════════════════════════════════════════

local TOTAL_FRAMES = 1280

local B = 59   -- Acoustic Bass
local R = 50   -- Rhodes
local M = 62   -- Kalimba (melody)

local song = {
    -- ── Bar 1: Cmaj7 ────────────────────────
    [0]    = {{B, 48}},           -- Bass C3
    [8]    = {{R, 64}},           -- Rhodes E4
    [40]   = {{M, 76}},           -- ♪ E5
    [60]   = {{R, 71}},           -- Rhodes B4
    [80]   = {{B, 43}},           -- Bass G2
    [100]  = {{M, 74}},           -- ♪ D5

    -- ── Bar 2: Am7 ─────────────────────────
    [160]  = {{B, 45}},           -- Bass A2
    [168]  = {{R, 60}},           -- Rhodes C4
    [200]  = {{M, 72}},           -- ♪ C5
    [240]  = {{B, 52}},           -- Bass E3
    [260]  = {{R, 67}},           -- Rhodes G4
    [280]  = {{M, 71}},           -- ♪ B4
    [300]  = {{M, 72}},           -- ♪ C5

    -- ── Bar 3: Dm7 ─────────────────────────
    [320]  = {{B, 50}},           -- Bass D3
    [328]  = {{R, 65}},           -- Rhodes F4
    [360]  = {{M, 74}},           -- ♪ D5
    [380]  = {{R, 72}},           -- Rhodes C5
    [400]  = {{B, 45}},           -- Bass A2
    [420]  = {{M, 77}},           -- ♪ F5

    -- ── Bar 4: G7 ──────────────────────────
    [480]  = {{B, 43}},           -- Bass G2
    [488]  = {{R, 59}},           -- Rhodes B3
    [520]  = {{M, 76}},           -- ♪ E5 (13th — jazzy)
    [560]  = {{B, 50}},           -- Bass D3
    [580]  = {{R, 65}},           -- Rhodes F4
    [600]  = {{M, 74}},           -- ♪ D5

    -- ── Bar 5: Cmaj7 ───────────────────────
    [640]  = {{B, 48}},           -- Bass C3
    [648]  = {{R, 64}},           -- Rhodes E4
    [680]  = {{M, 76}},           -- ♪ E5
    [700]  = {{R, 71}},           -- Rhodes B4
    [720]  = {{B, 43}},           -- Bass G2
    [740]  = {{M, 79}},           -- ♪ G5 (reaching higher)

    -- ── Bar 6: Fmaj7 ───────────────────────
    [800]  = {{B, 41}},           -- Bass F2
    [808]  = {{R, 69}},           -- Rhodes A4
    [840]  = {{M, 81}},           -- ♪ A5 ★ melodic peak
    [860]  = {{R, 76}},           -- Rhodes E5 (maj7 — dreamy)
    [880]  = {{B, 48}},           -- Bass C3
    [900]  = {{M, 79}},           -- ♪ G5
    [920]  = {{M, 76}},           -- ♪ E5

    -- ── Bar 7: Dm7 ─────────────────────────
    [960]  = {{B, 50}},           -- Bass D3
    [968]  = {{R, 65}},           -- Rhodes F4
    [1000] = {{M, 77}},           -- ♪ F5
    [1020] = {{R, 72}},           -- Rhodes C5
    [1040] = {{B, 45}},           -- Bass A2
    [1060] = {{M, 74}},           -- ♪ D5

    -- ── Bar 8: G7 → loop ───────────────────
    [1120] = {{B, 43}},           -- Bass G2
    [1128] = {{R, 59}},           -- Rhodes B3
    [1160] = {{M, 76}},           -- ♪ E5
    [1200] = {{B, 55}},           -- Bass G3 (higher, tension)
    [1210] = {{R, 65}},           -- Rhodes F4
    [1240] = {{M, 72}},           -- ♪ C5 (home — loops back)
}

-- Playback: call menu_song_update(frame) from your update()
function menu_song_update(frame)
    local f = frame % TOTAL_FRAMES
    local events = song[f]
    if events then
        for _, e in ipairs(events) do
            sfx.fx(e[1], e[2])
        end
    end
end
