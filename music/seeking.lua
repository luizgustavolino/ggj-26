-- ============================================================
-- "Procurando o Ninja" - Seeking Phase BGM
-- Bossa nova + mystery — the seekers are hunting!
-- 120 BPM @ 60 FPS => 30 frames/beat, 120 frames/bar
-- Total: 3840 frames (64 seconds), loops seamlessly
--
-- Structure (32 bars):
--   A  (1-8)   Rhodes mysterious pads, sparse & tense
--   B  (9-16)  English Horn haunting melody enters
--   C  (17-24) Tension builds, harp arpeggios
--   D  (25-32) Peak suspense, resolves into loop
-- ============================================================

local FRAMES_PER_BEAT = 30
local FRAMES_PER_BAR  = 120
local TOTAL_FRAMES    = 32 * FRAMES_PER_BAR  -- 3840

-- Sample aliases (index into pcm_map)
local BASS    = 59   -- Acoustic Bass A#3 (base midi 46)
local NYLON   = 23   -- Nylon Guitar B4   (base midi 59)
local RHODES  = 50   -- Rhodes C5         (base midi 60)
local EHORN   = 40   -- English Horn C5   (base midi 60)
local HIHAT   = 6    -- 808 Closed Hat    (base midi 53)
local CLAVE   = 12   -- 808 Clave         (base midi 82)
local HARP    = 64   -- Harp D#4          (base midi 63)
local CHOIR   = 58   -- Ahh Choir C5-L    (base midi 60)
local KALIMBA = 62   -- Kalimba A5        (base midi 69)

-- ============================================================
-- Builder
-- ============================================================
local notes = {}

local function add(frame, sample, note)
    if not notes[frame] then notes[frame] = {} end
    table.insert(notes[frame], {sample, note})
end

local function at(bar, eighth)
    return (bar - 1) * FRAMES_PER_BAR + eighth * 15
end

-- ============================================================
-- Chord data (darker voicings, more minor)
-- ============================================================
local chords = {
    Cmaj7 = { root = 48, fifth = 55, comp1 = 64, comp2 = 71 },
    Am7   = { root = 45, fifth = 52, comp1 = 60, comp2 = 67 },
    Dm7   = { root = 50, fifth = 45, comp1 = 65, comp2 = 72 },
    G7    = { root = 43, fifth = 50, comp1 = 62, comp2 = 65 },
    Fmaj7 = { root = 53, fifth = 48, comp1 = 69, comp2 = 76 },
    Em7   = { root = 52, fifth = 47, comp1 = 67, comp2 = 71 },
    Fm7   = { root = 53, fifth = 48, comp1 = 68, comp2 = 75 },
}

-- Chord for each of the 32 bars (minor-heavy, mysterious)
local progression = {
    -- A (1-8): dark, mysterious
    "Am7","Am7", "Dm7","Dm7", "Fm7","Fm7", "Em7","Em7",
    -- B (9-16): English Horn enters
    "Am7","Am7", "Fmaj7","Fm7", "Dm7","Dm7", "Em7","Em7",
    -- C (17-24): building tension
    "Fmaj7","Fmaj7", "Am7","Am7", "Dm7","Dm7", "G7","G7",
    -- D (25-32): peak suspense, loop back
    "Am7","Am7", "Fm7","Fm7", "Dm7","G7", "Am7","Am7",
}

-- ============================================================
-- RHYTHM SECTION (32 bars — sparse, mysterious)
-- ============================================================
for bar = 1, 32 do
    local ch = chords[progression[bar]]
    local odd = (bar % 2 == 1)

    -- Section A (1-8): very sparse — bass + light hat only
    local is_sparse = (bar >= 1 and bar <= 8)
    -- Section C (17-24): fuller groove builds
    local is_building = (bar >= 17 and bar <= 24)
    -- Section D (25-32): peak
    local is_peak = (bar >= 25 and bar <= 32)

    -- Bass: always present but slower, more brooding
    add(at(bar, 0), BASS, ch.root)
    add(at(bar, 4), BASS, ch.fifth)  -- on beat 3 instead of "and of 2"

    if is_sparse then
        -- Just a light hat on beat 4
        if odd then
            add(at(bar, 6), HIHAT, 53)
        end
    else
        -- Nylon comp: sparse, dark chord stabs
        add(at(bar, 1), NYLON, ch.comp1)
        if not is_building then
            add(at(bar, 5), NYLON, ch.comp2)
        else
            -- Building: add comp on beat 3+ too
            add(at(bar, 3), NYLON, ch.comp2)
            add(at(bar, 5), NYLON, ch.comp2)
        end

        -- Hi-hat: beats 2 and 4
        add(at(bar, 2), HIHAT, 53)
        add(at(bar, 6), HIHAT, 53)

        -- Clave: subtle bossa (only in building/peak sections)
        if is_building or is_peak then
            if odd then
                add(at(bar, 0), CLAVE, 82)
            else
                add(at(bar, 4), CLAVE, 82)
            end
        end
    end
end

-- ============================================================
-- WALKING BASS approach notes
-- ============================================================

-- Section A (1-8)
add(at(2, 7), BASS, 49)   -- -> Dm
add(at(4, 7), BASS, 52)   -- -> Fm
add(at(6, 7), BASS, 51)   -- -> Em
add(at(8, 7), BASS, 44)   -- -> Am (into B)

-- Section B (9-16)
add(at(10, 7), BASS, 52)  -- -> F
add(at(12, 7), BASS, 49)  -- -> Dm
add(at(14, 7), BASS, 51)  -- -> Em
add(at(16, 7), BASS, 52)  -- -> F (into C)

-- Section C (17-24)
add(at(18, 7), BASS, 44)  -- -> Am
add(at(20, 7), BASS, 49)  -- -> Dm
add(at(22, 7), BASS, 42)  -- -> G
add(at(24, 7), BASS, 44)  -- -> Am (into D)

-- Section D (25-32)
add(at(26, 7), BASS, 52)  -- -> Fm
add(at(28, 7), BASS, 49)  -- -> Dm
add(at(30, 7), BASS, 44)  -- -> Am
add(at(32, 7), BASS, 44)  -- -> Am (loop!)

-- ============================================================
-- MIDI reference:
--   C4=60 D4=62 E4=64 F4=65 G4=67 A4=69 B4=71
--   C5=72 D5=74 E5=76 F5=77 G5=79 A5=81 B5=83 C6=84
--   Db5=73 Eb5=75 F#5=78 Ab5=80 Bb5=82
-- ============================================================

-- ============================================================
-- SECTION A (bars 1-8): Rhodes mysterious pads
-- Sparse, hovering chords — "where is the ninja?"
-- ============================================================

-- Bar 1: Am7  Rhodes enters slowly  A4 . . . . . . .
add(at(1, 0), RHODES, 69)

-- Bar 2: Am7  . . . . E5 . . .
add(at(2, 4), RHODES, 76)

-- Bar 3: Dm7  D5 . . . . . . .
add(at(3, 0), RHODES, 74)

-- Bar 4: Dm7  . . . F5 . . A4 .
add(at(4, 3), RHODES, 77)
add(at(4, 6), RHODES, 69)

-- Bar 5: Fm7  Ab5 . . . . . . .  (dark!)
add(at(5, 0), RHODES, 80)

-- Bar 6: Fm7  . . G5 . . . F5 .
add(at(6, 2), RHODES, 79)
add(at(6, 6), RHODES, 77)

-- Bar 7: Em7  G4 . . . . . B4 .
add(at(7, 0), RHODES, 67)
add(at(7, 6), RHODES, 71)

-- Bar 8: Em7  . . . E5 . . . .  (hanging tension)
add(at(8, 3), RHODES, 76)

-- Choir atmosphere in section A (long, ghostly)
add(at(1, 0), CHOIR, 69)    -- A4 drone start
add(at(5, 0), CHOIR, 68)    -- Ab4 (Fm7 color — eerie)

-- Harp mystery drops
add(at(2, 6), HARP, 64)     -- E4 drip
add(at(6, 4), HARP, 65)     -- F4 drip
add(at(8, 6), HARP, 60)     -- C4 drip

-- ============================================================
-- SECTION B (bars 9-16): English Horn haunting melody
-- The seekers are on the move — searching, scanning
-- ============================================================

-- Bar 9: Am7  EHorn  A4 . . . . . E5 .
add(at(9, 0), EHORN, 69)
add(at(9, 6), EHORN, 76)

-- Bar 10: Am7  EHorn  . . C5 . . . A4 .
add(at(10, 2), EHORN, 72)
add(at(10, 6), EHORN, 69)

-- Bar 11: Fmaj7  EHorn  F5 . . . . . A4 .
add(at(11, 0), EHORN, 77)
add(at(11, 6), EHORN, 69)

-- Bar 12: Fm7  EHorn chromatic  Ab5 . . G5 . . . .
add(at(12, 0), EHORN, 80)
add(at(12, 3), EHORN, 79)

-- Bar 13: Dm7  EHorn  D5 . . . F5 . . .
add(at(13, 0), EHORN, 74)
add(at(13, 4), EHORN, 77)

-- Bar 14: Dm7  EHorn  . . A4 . . . D5 .
add(at(14, 2), EHORN, 69)
add(at(14, 6), EHORN, 74)

-- Bar 15: Em7  EHorn  E5 . . . G5 . . .
add(at(15, 0), EHORN, 76)
add(at(15, 4), EHORN, 79)

-- Bar 16: Em7  EHorn  . . B4 . . . . .  (suspense)
add(at(16, 2), EHORN, 71)

-- Rhodes pads in section B
add(at(9, 0), RHODES, 60)    -- C4 pad
add(at(13, 0), RHODES, 65)   -- F4 pad

-- Harp mystery drips in B
add(at(10, 4), HARP, 67)     -- G4
add(at(14, 4), HARP, 62)     -- D4
add(at(16, 6), HARP, 64)     -- E4

-- ============================================================
-- SECTION C (bars 17-24): Tension builds
-- Harp arpeggios emerge, rhythm gets fuller
-- ============================================================

-- Bar 17: Fmaj7  Harp arpeggio  F . A . C5 . . .
add(at(17, 0), HARP, 65)
add(at(17, 2), HARP, 69)
add(at(17, 4), HARP, 72)

-- Bar 18: Fmaj7  Harp  E5 . . . A . . .
add(at(18, 0), HARP, 76)
add(at(18, 4), HARP, 69)

-- Bar 19: Am7  Harp  A . C . E5 . . .
add(at(19, 0), HARP, 69)
add(at(19, 2), HARP, 72)
add(at(19, 4), HARP, 76)

-- Bar 20: Am7  Harp  G5 . . . E5 . . .
add(at(20, 0), HARP, 79)
add(at(20, 4), HARP, 76)

-- EHorn continues over harp
-- Bar 17: EHorn  . . . . . . A .
add(at(17, 6), EHORN, 81)

-- Bar 18: EHorn  . . . . . . F .
add(at(18, 6), EHORN, 77)

-- Bar 19: EHorn  . . . . . . E .
add(at(19, 6), EHORN, 76)

-- Bar 20: EHorn  . . . . . . C .
add(at(20, 6), EHORN, 72)

-- Bar 21: Dm7  Harp  D . F . A . . .
add(at(21, 0), HARP, 62)
add(at(21, 2), HARP, 65)
add(at(21, 4), HARP, 69)

-- Bar 22: Dm7  EHorn  D5 . . F5 . . A4 .
add(at(22, 0), EHORN, 74)
add(at(22, 3), EHORN, 77)
add(at(22, 6), EHORN, 69)

-- Bar 23: G7  Harp  G . B4 . D . . .
add(at(23, 0), HARP, 67)
add(at(23, 2), HARP, 71)
add(at(23, 4), HARP, 74)

-- Bar 24: G7  EHorn dramatic  G5 . . F5 . . D5 .
add(at(24, 0), EHORN, 79)
add(at(24, 3), EHORN, 77)
add(at(24, 6), EHORN, 74)

-- Rhodes color in C
add(at(17, 0), RHODES, 72)   -- C5 section start
add(at(21, 0), RHODES, 69)   -- A4 midpoint

-- ============================================================
-- SECTION D (bars 25-32): Peak suspense, loops back
-- "I see you!" — maximum tension before the loop restarts
-- ============================================================

-- Bar 25: Am7  EHorn intense  A5 . . . E5 . . .
add(at(25, 0), EHORN, 81)
add(at(25, 4), EHORN, 76)

-- Bar 26: Am7  EHorn  . . G5 . . . A5 .
add(at(26, 2), EHORN, 79)
add(at(26, 6), EHORN, 81)

-- Bar 27: Fm7  dark — EHorn  Ab5 . . G5 . . F5 .
add(at(27, 0), EHORN, 80)
add(at(27, 3), EHORN, 79)
add(at(27, 6), EHORN, 77)

-- Bar 28: Fm7  EHorn  . . Eb5 . . . . .  (chromatic tension)
add(at(28, 2), EHORN, 75)

-- Harp rapid arpeggios in D
-- Bar 25: Harp  . E . . . A . .
add(at(25, 1), HARP, 64)
add(at(25, 5), HARP, 69)

-- Bar 26: Harp  A . . . E . . .
add(at(26, 0), HARP, 69)
add(at(26, 4), HARP, 64)

-- Bar 27: Harp  . Ab . . . C . .
add(at(27, 1), HARP, 68)
add(at(27, 5), HARP, 72)

-- Bar 28: Harp  F . . . Ab . . .
add(at(28, 0), HARP, 65)
add(at(28, 4), HARP, 68)

-- Bar 29: Dm7  EHorn descending  D5 . . . A4 . . .
add(at(29, 0), EHORN, 74)
add(at(29, 4), EHORN, 69)

-- Bar 30: G7  EHorn  G5 . . F5 . . D5 .
add(at(30, 0), EHORN, 79)
add(at(30, 3), EHORN, 77)
add(at(30, 6), EHORN, 74)

-- Bar 31: Am7  Kalimba sneaks in!  . . E . . . . .  (a hint of the ninja)
add(at(31, 2), KALIMBA, 76)

-- Rhodes resolve
add(at(31, 0), RHODES, 69)   -- A4

-- Bar 32: Am7  Everything sparse — breath before loop
add(at(32, 0), EHORN, 69)    -- A4 (landing)

-- Harp in D (continued)
-- Bar 29: Harp  . D . . . F . .
add(at(29, 1), HARP, 62)
add(at(29, 5), HARP, 65)

-- Bar 30: Harp  . G . . . B4 . .
add(at(30, 1), HARP, 67)
add(at(30, 5), HARP, 71)

-- Choir atmosphere on section transitions
add(at(9, 0), CHOIR, 60)     -- C4 entering B
add(at(17, 0), CHOIR, 65)    -- F4 entering C
add(at(25, 0), CHOIR, 57)    -- A3 entering D (deep, ominous)

-- ============================================================
-- Harp transition sparkles
-- ============================================================
add(at(8, 7),  HARP, 60)    -- C4 end of A (dark shimmer)
add(at(16, 7), HARP, 64)    -- E4 end of B
add(at(24, 7), HARP, 60)    -- C4 end of C
add(at(32, 6), HARP, 69)    -- A4 end of D (loop shimmer)

-- ============================================================
-- Return the song data
-- ============================================================
return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 120,
    title  = "Procurando o Ninja",
}
