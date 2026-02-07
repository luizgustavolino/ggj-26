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

return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 120,
    title  = "Pique Esconde Ninja",
}
