-- ============================================================
-- "Pique Esconde Ninja" - Menu BGM
-- Bossa nova / jazz feel, 96 bars, loops seamlessly
-- 120 BPM @ 60 FPS => 30 frames/beat, 120 frames/bar
-- Total: 11520 frames (192 seconds / 3m12s)
--
-- Structure (96 bars):
--   A  (1-8)   Kalimba melody, full band
--   B  (9-16)  Kalimba soaring, Fmaj7 color
--   A' (17-24) Kalimba variation
--   C  (25-32) Bridge, Fm7 chromatic moment
--   D  (33-40) ** Flute takes melody, lighter groove **
--   E  (41-48) ** Rhodes melody, breakdown feel **
--   F  (49-56) ** Kalimba returns, new theme **
--   G  (57-64) ** Flute + Kalimba call-and-response **
--   H  (65-72) ** Energetic build, maraca added **
--   I  (73-80) ** Sparse breakdown, harp arpeggios **
--   J  (81-88) ** Flute melody, ascending chords **
--   K  (89-96) ** Grand finale, main motif returns **
--
-- Pitch ranges kept within ±7 of each sample's base MIDI note.
-- Kalimba (base 69): melody 59-72  |  Flute (base 74): melody 66-81
-- Rhodes (base 60): pads 55-68     |  Harp (base 63): sparkles 50-65
-- ============================================================

local FRAMES_PER_BEAT = 30
local FRAMES_PER_BAR  = 120
local TOTAL_FRAMES    = 96 * FRAMES_PER_BAR  -- 11520

-- Sample aliases (index into pcm_map)
local BASS    = 59   -- Acoustic Bass A#3 (base midi 46)
local NYLON   = 23   -- Nylon Guitar B4   (base midi 59)
local KALIMBA = 62   -- Kalimba A5        (base midi 69)
local RHODES  = 50   -- Rhodes C5         (base midi 60)
local CLAVE   = 12   -- 808 Clave         (base midi 82)
local HIHAT   = 6    -- 808 Closed Hat    (base midi 53)
local FLUTE   = 33   -- Flute D5          (base midi 74)
local HARP    = 64   -- Harp D#4          (base midi 63)
local MARACA  = 0    -- 808 Maraca        (base midi 89)

-- ============================================================
-- Builder
-- ============================================================
local notes = {}

local function add(frame, sample, note)
    if not notes[frame] then notes[frame] = {} end
    table.insert(notes[frame], {sample, note})
end

local function at(bar, eighth)
    -- bar: 1-indexed, eighth: 0-7 (8th-note position inside bar)
    return (bar - 1) * FRAMES_PER_BAR + eighth * 15
end

-- ============================================================
-- Chord data
-- ============================================================
local chords = {
    Cmaj7 = { root = 48, fifth = 55, comp1 = 64, comp2 = 59 },
    Am7   = { root = 45, fifth = 52, comp1 = 60, comp2 = 55 },
    Dm7   = { root = 50, fifth = 45, comp1 = 65, comp2 = 60 },
    G7    = { root = 43, fifth = 50, comp1 = 62, comp2 = 65 },
    Fmaj7 = { root = 53, fifth = 48, comp1 = 57, comp2 = 64 },
    Em7   = { root = 52, fifth = 47, comp1 = 55, comp2 = 59 },
    Fm7   = { root = 53, fifth = 48, comp1 = 56, comp2 = 63 },
}

-- Chord for each of the 96 bars
local progression = {
    -- A (1-8)
    "Cmaj7","Cmaj7", "Am7","Am7", "Dm7","Dm7", "G7","G7",
    -- B (9-16)
    "Fmaj7","Fmaj7", "Em7","Am7", "Dm7","G7", "Cmaj7","Cmaj7",
    -- A' (17-24)
    "Cmaj7","Cmaj7", "Am7","Am7", "Dm7","Dm7", "G7","G7",
    -- C (25-32)
    "Fmaj7","Fm7", "Em7","Am7", "Dm7","G7", "Cmaj7","Cmaj7",
    -- D (33-40): relative minor start
    "Am7","Am7", "Fmaj7","Fmaj7", "Dm7","Dm7", "G7","G7",
    -- E (41-48): iii-vi-ii-I
    "Em7","Em7", "Am7","Am7", "Dm7","Dm7", "Cmaj7","Cmaj7",
    -- F (49-56): IV descending
    "Fmaj7","Fmaj7", "Em7","Em7", "Dm7","Dm7", "G7","G7",
    -- G (57-64): circle with chromatic
    "Am7","Am7", "Dm7","Dm7", "Fmaj7","Fm7", "Cmaj7","Cmaj7",
    -- H (65-72): bright and energetic
    "Cmaj7","Cmaj7", "Fmaj7","Fmaj7", "Am7","Am7", "G7","G7",
    -- I (73-80): ascending diatonic (sparse)
    "Dm7","Dm7", "Em7","Em7", "Fmaj7","Fmaj7", "G7","G7",
    -- J (81-88): flute melody
    "Am7","Am7", "Fmaj7","Fmaj7", "Dm7","G7", "Em7","Am7",
    -- K (89-96): grand cadence, loop home
    "Fmaj7","Fm7", "Em7","Am7", "Dm7","G7", "Cmaj7","Cmaj7",
}

-- ============================================================
-- RHYTHM SECTION (96 bars with per-section variations)
-- ============================================================
for bar = 1, 96 do
    local ch = chords[progression[bar]]
    local odd = (bar % 2 == 1)

    -- Section I (73-80): sparse breakdown — bass only, no comp/perc
    local is_breakdown = (bar >= 73 and bar <= 80)
    -- Section E (41-48): lighter groove — no clave
    local is_light = (bar >= 41 and bar <= 48)
    -- Section H (65-72): energetic — add maraca
    local is_energetic = (bar >= 65 and bar <= 72)

    -- Bass: always plays (the heartbeat)
    add(at(bar, 0), BASS, ch.root)
    add(at(bar, 3), BASS, ch.fifth)

    if not is_breakdown then
        -- Nylon comp: chord tones on upbeats
        add(at(bar, 1), NYLON, ch.comp1)
        add(at(bar, 5), NYLON, ch.comp2)

        -- Hi-hat: beats 2 and 4
        add(at(bar, 2), HIHAT, 53)
        add(at(bar, 6), HIHAT, 53)

        -- Clave: bossa pattern (skip in light sections)
        if not is_light then
            if odd then
                add(at(bar, 0), CLAVE, 82)
            else
                add(at(bar, 4), CLAVE, 82)
            end
        end

        -- Maraca on energetic sections: 8th notes on and-of-1 and and-of-3
        if is_energetic then
            add(at(bar, 1), MARACA, 89)
            add(at(bar, 5), MARACA, 89)
        end
    else
        -- Breakdown: only a light hat on beat 4 every other bar
        if odd then
            add(at(bar, 6), HIHAT, 53)
        end
    end
end

-- ============================================================
-- WALKING BASS approach notes throughout all 96 bars
-- (chromatic or diatonic approaches before chord changes)
-- ============================================================

-- Section A (1-8)
add(at(2, 7), BASS, 47)   -- B2 -> Am
add(at(4, 7), BASS, 48)   -- C3 -> Dm
add(at(6, 7), BASS, 42)   -- F#2 -> G
add(at(8, 6), BASS, 45)   -- A2 approach
add(at(8, 7), BASS, 51)   -- Eb3 chromatic -> E

-- Section B (9-16)
add(at(10, 7), BASS, 52)  -- E3 slide
add(at(12, 7), BASS, 49)  -- Db3 chromatic -> D
add(at(14, 7), BASS, 47)  -- B2 -> C
add(at(16, 7), BASS, 47)  -- B2 pickup

-- Section A' (17-24)
add(at(18, 7), BASS, 47)
add(at(20, 7), BASS, 48)
add(at(22, 7), BASS, 42)
add(at(24, 7), BASS, 52)  -- E3 -> F

-- Section C (25-32)
add(at(26, 7), BASS, 52)  -- -> Em
add(at(28, 7), BASS, 49)  -- -> Dm
add(at(30, 7), BASS, 47)  -- -> C
add(at(32, 7), BASS, 44)  -- Ab2 chromatic -> A (into section D)

-- Section D (33-40)
add(at(34, 7), BASS, 52)  -- -> F
add(at(36, 7), BASS, 49)  -- -> Dm
add(at(38, 7), BASS, 42)  -- -> G
add(at(40, 7), BASS, 51)  -- -> Em (into section E)

-- Section E (41-48)
add(at(42, 7), BASS, 44)  -- -> Am
add(at(44, 7), BASS, 49)  -- -> Dm
add(at(46, 7), BASS, 47)  -- -> C
add(at(48, 7), BASS, 52)  -- -> F (into section F)

-- Section F (49-56)
add(at(50, 7), BASS, 51)  -- -> Em
add(at(52, 7), BASS, 49)  -- -> Dm
add(at(54, 7), BASS, 42)  -- -> G
add(at(56, 7), BASS, 44)  -- -> Am (into section G)

-- Section G (57-64)
add(at(58, 7), BASS, 49)  -- -> Dm
add(at(60, 7), BASS, 52)  -- -> F
add(at(62, 7), BASS, 47)  -- -> C
add(at(64, 7), BASS, 47)  -- -> C (into section H)

-- Section H (65-72)
add(at(66, 7), BASS, 52)  -- -> F
add(at(68, 7), BASS, 44)  -- -> Am
add(at(70, 7), BASS, 42)  -- -> G
add(at(72, 7), BASS, 49)  -- -> Dm (into section I)

-- Section I (73-80)
add(at(74, 7), BASS, 51)  -- -> Em
add(at(76, 7), BASS, 52)  -- -> F
add(at(78, 7), BASS, 42)  -- -> G
add(at(80, 7), BASS, 44)  -- -> Am (into section J)

-- Section J (81-88)
add(at(82, 7), BASS, 52)  -- -> F
add(at(84, 7), BASS, 49)  -- -> Dm
add(at(86, 7), BASS, 51)  -- -> Em
add(at(88, 7), BASS, 52)  -- -> F (into section K)

-- Section K (89-96)
add(at(90, 7), BASS, 52)  -- -> Em
add(at(92, 7), BASS, 49)  -- -> Dm
add(at(94, 7), BASS, 47)  -- -> C
add(at(96, 7), BASS, 47)  -- -> C (loop back to bar 1!)

-- ============================================================
-- MIDI reference:
--   C3=48 D3=50 E3=52 F3=53 G3=55 A3=57 B3=59
--   C4=60 D4=62 E4=64 F4=65 G4=67 A4=69 B4=71
--   C5=72 D5=74 E5=76 F5=77 G5=79 A5=81 B5=83 C6=84
-- ============================================================

-- ============================================================
-- SECTION A (bars 1-8): Kalimba main theme
-- ============================================================

-- Bar 1: opening motif  G-A-G-E
add(at(1, 0), KALIMBA, 67)
add(at(1, 2), KALIMBA, 69)
add(at(1, 4), KALIMBA, 67)
add(at(1, 6), KALIMBA, 64)

-- Bar 2: answer  D . E . . . G .
add(at(2, 0), KALIMBA, 62)
add(at(2, 2), KALIMBA, 64)
add(at(2, 6), KALIMBA, 67)

-- Bar 3: rising  E-G-A
add(at(3, 0), KALIMBA, 64)
add(at(3, 2), KALIMBA, 67)
add(at(3, 4), KALIMBA, 69)

-- Bar 4: settle  G . . . . . C .
add(at(4, 0), KALIMBA, 67)
add(at(4, 6), KALIMBA, 60)

-- Bar 5: Dm7 color  F-A . . F
add(at(5, 0), KALIMBA, 65)
add(at(5, 2), KALIMBA, 69)
add(at(5, 6), KALIMBA, 65)

-- Bar 6: step down  D . . E
add(at(6, 0), KALIMBA, 62)
add(at(6, 4), KALIMBA, 64)

-- Bar 7: G7 tension  B-D-F
add(at(7, 0), KALIMBA, 59)
add(at(7, 2), KALIMBA, 62)
add(at(7, 4), KALIMBA, 65)

-- Bar 8: resolve approach  . E . . . . D .
add(at(8, 2), KALIMBA, 64)
add(at(8, 6), KALIMBA, 62)

-- ============================================================
-- SECTION B (bars 9-16): Kalimba soaring
-- ============================================================

-- Bar 9: Fmaj7 soaring  A-C5-A
add(at(9, 0), KALIMBA, 69)
add(at(9, 2), KALIMBA, 72)
add(at(9, 4), KALIMBA, 69)

-- Bar 10: cascade  . . G . . . E .
add(at(10, 2), KALIMBA, 67)
add(at(10, 6), KALIMBA, 64)

-- Bar 11: Em7  G . . B3 . . D .
add(at(11, 0), KALIMBA, 67)
add(at(11, 3), KALIMBA, 59)
add(at(11, 6), KALIMBA, 62)

-- Bar 12: Am7  E . . C
add(at(12, 0), KALIMBA, 64)
add(at(12, 3), KALIMBA, 60)

-- Bar 13: Dm7  . . D . F
add(at(13, 2), KALIMBA, 62)
add(at(13, 4), KALIMBA, 65)

-- Bar 14: G7  G . . F . . D .
add(at(14, 0), KALIMBA, 67)
add(at(14, 3), KALIMBA, 65)
add(at(14, 6), KALIMBA, 62)

-- Bar 15: resolve  E . C . E
add(at(15, 0), KALIMBA, 64)
add(at(15, 2), KALIMBA, 60)
add(at(15, 4), KALIMBA, 64)

-- Bar 16: breath + pickup
add(at(16, 6), KALIMBA, 67)

-- ============================================================
-- SECTION A' (bars 17-24): Kalimba variation
-- ============================================================

-- Bar 17: higher reach  G-B4-A-G
add(at(17, 0), KALIMBA, 67)
add(at(17, 2), KALIMBA, 71)
add(at(17, 4), KALIMBA, 69)
add(at(17, 6), KALIMBA, 67)

-- Bar 18: descending syncopated  . E . D . . C .
add(at(18, 1), KALIMBA, 64)
add(at(18, 3), KALIMBA, 62)
add(at(18, 6), KALIMBA, 60)

-- Bar 19: Am7  A-G . . . E
add(at(19, 0), KALIMBA, 69)
add(at(19, 2), KALIMBA, 67)
add(at(19, 5), KALIMBA, 64)

-- Bar 20: space  . . C . D
add(at(20, 2), KALIMBA, 60)
add(at(20, 4), KALIMBA, 62)

-- Bar 21: Dm7  F . . A . . D .
add(at(21, 0), KALIMBA, 65)
add(at(21, 3), KALIMBA, 69)
add(at(21, 6), KALIMBA, 62)

-- Bar 22: settle  F . E . . . D .
add(at(22, 0), KALIMBA, 65)
add(at(22, 2), KALIMBA, 64)
add(at(22, 6), KALIMBA, 62)

-- Bar 23: G7  B3 . . D . . G .
add(at(23, 0), KALIMBA, 59)
add(at(23, 3), KALIMBA, 62)
add(at(23, 6), KALIMBA, 67)

-- Bar 24: transition  F-E . . . . D .
add(at(24, 0), KALIMBA, 65)
add(at(24, 2), KALIMBA, 64)
add(at(24, 6), KALIMBA, 62)

-- ============================================================
-- SECTION C (bars 25-32): Bridge / chromatic
-- ============================================================

-- Bar 25: high  C5 . . A . . G .
add(at(25, 0), KALIMBA, 72)
add(at(25, 3), KALIMBA, 69)
add(at(25, 6), KALIMBA, 67)

-- Bar 26: Fm7 chromatic  Ab4 . G . . F
add(at(26, 0), KALIMBA, 68)
add(at(26, 2), KALIMBA, 67)
add(at(26, 5), KALIMBA, 65)

-- Bar 27: Em7  G . E . G
add(at(27, 0), KALIMBA, 67)
add(at(27, 2), KALIMBA, 64)
add(at(27, 4), KALIMBA, 67)

-- Bar 28: Am7  A . . G . . E .
add(at(28, 0), KALIMBA, 69)
add(at(28, 3), KALIMBA, 67)
add(at(28, 6), KALIMBA, 64)

-- Bar 29: Dm7  D . . F . . A .
add(at(29, 0), KALIMBA, 62)
add(at(29, 3), KALIMBA, 65)
add(at(29, 6), KALIMBA, 69)

-- Bar 30: G7  G . F . D
add(at(30, 0), KALIMBA, 67)
add(at(30, 2), KALIMBA, 65)
add(at(30, 4), KALIMBA, 62)

-- Bar 31: Cmaj7  E . G . C5
add(at(31, 0), KALIMBA, 64)
add(at(31, 2), KALIMBA, 67)
add(at(31, 4), KALIMBA, 72)

-- Bar 32: descend  B4 . A . G
add(at(32, 0), KALIMBA, 71)
add(at(32, 2), KALIMBA, 69)
add(at(32, 4), KALIMBA, 67)

-- ============================================================
-- SECTION D (bars 33-40): Flute takes the melody
-- Lighter feel — Kalimba rests, Flute (sample 33) sings
-- Am7 -> Fmaj7 -> Dm7 -> G7
-- ============================================================

-- Bar 33: Am7 — Flute enters with a gentle line  E5 . . G . . A .
add(at(33, 0), KALIMBA, 71)
add(at(33, 3), KALIMBA, 74)
add(at(33, 6), KALIMBA, 76)

-- Bar 34: Am7  . . G . E . . .
add(at(34, 2), KALIMBA, 74)
add(at(34, 4), KALIMBA, 71)

-- Bar 35: Fmaj7  A . . C6 . . A .
add(at(35, 0), KALIMBA, 76)
add(at(35, 3), KALIMBA, 79)
add(at(35, 6), KALIMBA, 76)

-- Bar 36: Fmaj7  G . . F . . E .
add(at(36, 0), KALIMBA, 74)
add(at(36, 3), KALIMBA, 72)
add(at(36, 6), KALIMBA, 71)

-- Bar 37: Dm7  F . . A . . . .
add(at(37, 0), KALIMBA, 72)
add(at(37, 3), KALIMBA, 76)

-- Bar 38: Dm7  D . . . E . F .
add(at(38, 0), KALIMBA, 69)
add(at(38, 4), KALIMBA, 71)
add(at(38, 6), KALIMBA, 72)

-- Bar 39: G7  B4 . D . . . G .
add(at(39, 0), KALIMBA, 66)
add(at(39, 2), KALIMBA, 69)
add(at(39, 6), KALIMBA, 74)

-- Bar 40: G7  F . . D . . . .  (winding down for E)
add(at(40, 0), KALIMBA, 72)
add(at(40, 3), KALIMBA, 69)

-- ============================================================
-- SECTION E (bars 41-48): Rhodes melody, breakdown
-- No clave, spacious and dreamy. Rhodes (sample 50) leads.
-- Em7 -> Am7 -> Dm7 -> Cmaj7
-- ============================================================

-- Bar 41: Em7  G . . . . . . .
add(at(41, 0), RHODES, 55)   -- G3 (low, warm)

-- Bar 42: Em7  . . B3 . . . . .
add(at(42, 2), RHODES, 59)   -- B3

-- Bar 43: Am7  A3 . . . E4 . . .
add(at(43, 0), RHODES, 57)   -- A3
add(at(43, 4), RHODES, 64)   -- E4

-- Bar 44: Am7  . . C4 . . . . .
add(at(44, 2), RHODES, 60)   -- C4

-- Bar 45: Dm7  D4 . . . F4 . . .
add(at(45, 0), RHODES, 62)
add(at(45, 4), RHODES, 65)

-- Bar 46: Dm7  . . A3 . . . D4 .
add(at(46, 2), RHODES, 57)
add(at(46, 6), RHODES, 62)

-- Bar 47: Cmaj7 — resolve with warmth  E4 . . G4 . . C4 .
add(at(47, 0), RHODES, 64)
add(at(47, 3), RHODES, 67)
add(at(47, 6), RHODES, 60)

-- Bar 48: Cmaj7  . . . . G3 . . .  (sparse, breathing)
add(at(48, 4), RHODES, 55)

-- Kalimba adds a tiny echo in section E for color
add(at(43, 6), KALIMBA, 60)  -- C4 ghost
add(at(47, 4), KALIMBA, 64)  -- E4 sparkle

-- ============================================================
-- SECTION F (bars 49-56): Kalimba returns with new theme
-- Fmaj7 -> Em7 -> Dm7 -> G7
-- Fresh melody that contrasts with section A
-- ============================================================

-- Bar 49: Fmaj7  C5 . . . A . G .
add(at(49, 0), KALIMBA, 72)
add(at(49, 4), KALIMBA, 69)
add(at(49, 6), KALIMBA, 67)

-- Bar 50: Fmaj7  F . . . . . A .
add(at(50, 0), KALIMBA, 65)
add(at(50, 6), KALIMBA, 69)

-- Bar 51: Em7  G . . E . G . .
add(at(51, 0), KALIMBA, 67)
add(at(51, 3), KALIMBA, 64)
add(at(51, 5), KALIMBA, 67)

-- Bar 52: Em7  B3 . . . D . . .
add(at(52, 0), KALIMBA, 59)
add(at(52, 4), KALIMBA, 62)

-- Bar 53: Dm7  F . A . . . D .
add(at(53, 0), KALIMBA, 65)
add(at(53, 2), KALIMBA, 69)
add(at(53, 6), KALIMBA, 62)

-- Bar 54: Dm7  . . E . F . . .
add(at(54, 2), KALIMBA, 64)
add(at(54, 4), KALIMBA, 65)

-- Bar 55: G7  D . . F . . G .
add(at(55, 0), KALIMBA, 62)
add(at(55, 3), KALIMBA, 65)
add(at(55, 6), KALIMBA, 67)

-- Bar 56: G7  . . F . D . . .  (transition)
add(at(56, 2), KALIMBA, 65)
add(at(56, 4), KALIMBA, 62)

-- ============================================================
-- SECTION G (bars 57-64): Flute + Kalimba call-and-response
-- Am7 -> Dm7 -> Fmaj7/Fm7 -> Cmaj7
-- Flute calls, Kalimba answers — playful dialogue
-- ============================================================

-- Bar 57: Flute call  A . G . . .
-- Kalimba answer  . . . . E . G .
add(at(57, 4), KALIMBA, 64)
add(at(57, 6), KALIMBA, 67)

-- Bar 58: Flute  . . E . . .
-- Kalimba  . . . . C . D .
add(at(58, 4), KALIMBA, 60)
add(at(58, 6), KALIMBA, 62)

-- Bar 59: Flute call  D . F . . .
-- Kalimba answer  . . . . A . . .
add(at(59, 4), KALIMBA, 69)

-- Bar 60: Flute  . . A . . .
-- Kalimba  . . . . F . D .
add(at(60, 4), KALIMBA, 65)
add(at(60, 6), KALIMBA, 62)

-- Bar 61: Fmaj7 — both together!  Flute A, Kalimba C5
add(at(61, 0), KALIMBA, 72)
-- Then separate  Flute G
-- Kalimba A
add(at(61, 6), KALIMBA, 69)

-- Bar 62: Fm7 chromatic  Flute Ab . G
-- Kalimba  F . Eb
add(at(62, 2), KALIMBA, 65)
add(at(62, 6), KALIMBA, 63)

-- Bar 63: Cmaj7  Flute E . G
-- Kalimba  . C . . . . C5
add(at(63, 2), KALIMBA, 60)
add(at(63, 6), KALIMBA, 72)

-- Bar 64: Cmaj7  unison landing on E4!
add(at(64, 0), KALIMBA, 64)
-- Kalimba tail
add(at(64, 4), KALIMBA, 67)

-- ============================================================
-- SECTION H (bars 65-72): Energetic build
-- Cmaj7 -> Fmaj7 -> Am7 -> G7
-- Kalimba melody gets busier, maraca added in rhythm
-- ============================================================

-- Bar 65: Cmaj7  E-G-A-G  (fast, playful)
add(at(65, 0), KALIMBA, 64)
add(at(65, 2), KALIMBA, 67)
add(at(65, 4), KALIMBA, 69)
add(at(65, 6), KALIMBA, 67)

-- Bar 66: Cmaj7  C5-B4-A-G  (descending run)
add(at(66, 0), KALIMBA, 72)
add(at(66, 2), KALIMBA, 71)
add(at(66, 4), KALIMBA, 69)
add(at(66, 6), KALIMBA, 67)

-- Bar 67: Fmaj7  A . C5 . A . F .
add(at(67, 0), KALIMBA, 69)
add(at(67, 2), KALIMBA, 72)
add(at(67, 4), KALIMBA, 69)
add(at(67, 6), KALIMBA, 65)

-- Bar 68: Fmaj7  E . . G . . A .
add(at(68, 0), KALIMBA, 64)
add(at(68, 3), KALIMBA, 67)
add(at(68, 6), KALIMBA, 69)

-- Bar 69: Am7  C5 . A . G . E .
add(at(69, 0), KALIMBA, 72)
add(at(69, 2), KALIMBA, 69)
add(at(69, 4), KALIMBA, 67)
add(at(69, 6), KALIMBA, 64)

-- Bar 70: Am7  E . G . A . . .
add(at(70, 0), KALIMBA, 64)
add(at(70, 2), KALIMBA, 67)
add(at(70, 4), KALIMBA, 69)

-- Bar 71: G7  B4 . A . G . F .  (peak energy!)
add(at(71, 0), KALIMBA, 71)
add(at(71, 2), KALIMBA, 69)
add(at(71, 4), KALIMBA, 67)
add(at(71, 6), KALIMBA, 65)

-- Bar 72: G7  D . . . . . . .  (sudden drop — into breakdown)
add(at(72, 0), KALIMBA, 62)

-- ============================================================
-- SECTION I (bars 73-80): Sparse breakdown
-- Dm7 -> Em7 -> Fmaj7 -> G7
-- Just bass + harp arpeggios — magical/mysterious feel
-- Like the ninja is hiding in shadows
-- ============================================================

-- Bar 73: Dm7  Harp D . F . . .
add(at(73, 0), HARP, 50)    -- D3
add(at(73, 3), HARP, 53)    -- F3

-- Bar 74: Dm7  Harp A . . . C .
add(at(74, 0), HARP, 57)    -- A3
add(at(74, 5), HARP, 60)    -- C4

-- Bar 75: Em7  Harp E . G . B .
add(at(75, 0), HARP, 52)    -- E3
add(at(75, 3), HARP, 55)    -- G3
add(at(75, 6), HARP, 59)    -- B3

-- Bar 76: Em7  Harp D4 . . . B .
add(at(76, 0), HARP, 62)    -- D4
add(at(76, 5), HARP, 59)    -- B3

-- Bar 77: Fmaj7  Harp F . A . C4 .
add(at(77, 0), HARP, 53)    -- F3
add(at(77, 3), HARP, 57)    -- A3
add(at(77, 6), HARP, 60)    -- C4

-- Bar 78: Fmaj7  Harp E4 . . . A .
add(at(78, 0), HARP, 64)    -- E4
add(at(78, 5), HARP, 57)    -- A3

-- Bar 79: G7  Harp G . B . D4 .
add(at(79, 0), HARP, 55)    -- G3
add(at(79, 3), HARP, 59)    -- B3
add(at(79, 6), HARP, 62)    -- D4

-- Bar 80: G7  Harp F4 . D4 . B . .  (building tension to return)
add(at(80, 0), HARP, 65)    -- F4
add(at(80, 2), HARP, 62)    -- D4
add(at(80, 4), HARP, 59)    -- B3
-- Kalimba sneaks back with a single note
add(at(80, 7), KALIMBA, 69) -- A4 (pickup into J!)

-- ============================================================
-- SECTION J (bars 81-88): Flute melody, ascending chords
-- Am7 -> Fmaj7 -> Dm7/G7 -> Em7/Am7
-- Flute sings a lyrical jazz melody, Kalimba adds tiny echoes
-- ============================================================

-- Bar 81: Am7  Flute A . G . E . . .
add(at(81, 0), KALIMBA, 76)
add(at(81, 2), KALIMBA, 74)
add(at(81, 4), KALIMBA, 71)

-- Bar 82: Am7  Flute . . C . E . G .
add(at(82, 2), KALIMBA, 67)
add(at(82, 4), KALIMBA, 71)
add(at(82, 6), KALIMBA, 74)

-- Kalimba echo
add(at(82, 0), KALIMBA, 69)  -- A4 echo from bar 81

-- Bar 83: Fmaj7  Flute A . . C6 . . A .
add(at(83, 0), KALIMBA, 76)
add(at(83, 3), KALIMBA, 79)
add(at(83, 6), KALIMBA, 76)

-- Bar 84: Fmaj7  Flute F . E . . . . .
add(at(84, 0), KALIMBA, 72)
add(at(84, 2), KALIMBA, 71)
-- Kalimba echo
add(at(84, 5), KALIMBA, 69)

-- Bar 85: Dm7  Flute D . F . A . . .
add(at(85, 0), KALIMBA, 69)
add(at(85, 2), KALIMBA, 72)
add(at(85, 4), KALIMBA, 76)

-- Bar 86: G7  Flute G . . F . . D .
add(at(86, 0), KALIMBA, 74)
add(at(86, 3), KALIMBA, 72)
add(at(86, 6), KALIMBA, 69)
-- Kalimba echo
add(at(86, 4), KALIMBA, 65)

-- Bar 87: Em7  Flute E . G . B5 . . .
add(at(87, 0), KALIMBA, 71)
add(at(87, 2), KALIMBA, 74)
add(at(87, 4), KALIMBA, 78)

-- Bar 88: Am7  Flute A . . G . . E .   (winding down)
add(at(88, 0), KALIMBA, 76)
add(at(88, 3), KALIMBA, 74)
add(at(88, 6), KALIMBA, 71)

-- ============================================================
-- SECTION K (bars 89-96): Grand finale — main motif returns!
-- Fmaj7/Fm7 -> Em7/Am7 -> Dm7/G7 -> Cmaj7
-- Kalimba plays the G-A-G-E hook one last time, builds to loop
-- ============================================================

-- Bar 89: Fmaj7 — buildup  A . C5 . A . G .
add(at(89, 0), KALIMBA, 69)
add(at(89, 2), KALIMBA, 72)
add(at(89, 4), KALIMBA, 69)
add(at(89, 6), KALIMBA, 67)

-- Bar 90: Fm7 chromatic  Ab . G . F . Eb .
add(at(90, 0), KALIMBA, 68)
add(at(90, 2), KALIMBA, 67)
add(at(90, 4), KALIMBA, 65)
add(at(90, 6), KALIMBA, 63)

-- Bar 91: Em7  E . G . B4 . . .
add(at(91, 0), KALIMBA, 64)
add(at(91, 2), KALIMBA, 67)
add(at(91, 4), KALIMBA, 71)

-- Bar 92: Am7  A . . G . . E .
add(at(92, 0), KALIMBA, 69)
add(at(92, 3), KALIMBA, 67)
add(at(92, 6), KALIMBA, 64)

-- Bar 93: Dm7  ** THE HOOK RETURNS! **  F-A-F-D (transposed down to D context)
add(at(93, 0), KALIMBA, 65)  -- F4
add(at(93, 2), KALIMBA, 69)  -- A4
add(at(93, 4), KALIMBA, 65)  -- F4
add(at(93, 6), KALIMBA, 62)  -- D4

-- Bar 94: G7  ** ORIGINAL HOOK! **  G-A-G-E
add(at(94, 0), KALIMBA, 67)  -- G4
add(at(94, 2), KALIMBA, 69)  -- A4
add(at(94, 4), KALIMBA, 67)  -- G4
add(at(94, 6), KALIMBA, 64)  -- E4

-- Bar 95: Cmaj7  E . G . C5 . . .  (final flourish)
add(at(95, 0), KALIMBA, 64)
add(at(95, 2), KALIMBA, 67)
add(at(95, 4), KALIMBA, 72)

-- Bar 96: Cmaj7  . . G . E . . D  (lead back into bar 1)
add(at(96, 2), KALIMBA, 67)
add(at(96, 4), KALIMBA, 64)
add(at(96, 7), KALIMBA, 62)  -- D4 pickup into loop

-- ============================================================
-- HARP sparkles on section transitions
-- ============================================================
add(at(8, 7),  HARP, 60)   -- C4 end of A
add(at(16, 4), HARP, 64)   -- E4 end of B
add(at(24, 7), HARP, 60)   -- C4 end of A'
add(at(32, 7), HARP, 55)   -- G3 end of C
add(at(40, 7), HARP, 57)   -- A3 end of D
add(at(48, 7), HARP, 60)   -- C4 end of E (awakening)
add(at(56, 7), HARP, 57)   -- A3 end of F
add(at(64, 7), HARP, 60)   -- C4 end of G
add(at(72, 7), HARP, 50)   -- D3 end of H (into mystery)
-- Section I is all harp, no transition sparkle needed
add(at(88, 7), HARP, 60)   -- C4 end of J
add(at(96, 6), HARP, 64)   -- E4 end of K (loop shimmer)

-- ============================================================
-- RHODES pad color on key section starts
-- ============================================================
add(at(9, 0),  RHODES, 57)   -- A3 section B
add(at(25, 0), RHODES, 60)   -- C4 section C
add(at(33, 0), RHODES, 57)   -- A3 section D (flute enters)
add(at(49, 0), RHODES, 60)   -- C4 section F
add(at(57, 0), RHODES, 57)   -- A3 section G (call & response)
add(at(65, 0), RHODES, 60)   -- C4 section H (energy!)
add(at(89, 0), RHODES, 57)   -- A3 section K (grand finale)

-- ============================================================
-- Return the song data
-- ============================================================
return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 120,
    title  = "Pique Esconde Ninja",
}
