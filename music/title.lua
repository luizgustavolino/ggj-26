-- ============================================================
-- "Pique Esconde Ninja" - Menu BGM
-- Bossa nova / jazz feel, 32 bars, loops seamlessly
-- 120 BPM @ 60 FPS => 30 frames/beat, 120 frames/bar
-- Total: 3840 frames (64 seconds)
-- ============================================================

local FRAMES_PER_BEAT = 30
local FRAMES_PER_BAR  = 120
local TOTAL_FRAMES    = 32 * FRAMES_PER_BAR  -- 3840

-- Sample aliases (index into pcm_map)
local BASS    = 59   -- Acoustic Bass A#3 (base midi 46)
local NYLON   = 23   -- Nylon Guitar B4   (base midi 59)
local KALIMBA = 62   -- Kalimba A5        (base midi 69)
local RHODES  = 50   -- Rhodes C5         (base midi 60)
local CLAVE   = 12   -- 808 Clave         (base midi 82)
local HIHAT   = 6    -- 808 Closed Hat    (base midi 53)
local FLUTE   = 33   -- Flute D5          (base midi 74)
local HARP    = 64   -- Harp D#4          (base midi 63)

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
-- Chord progression (32 bars)
--   A  |: Cmaj7 . | Am7 .  | Dm7 .  | G7  .  :|   (8 bars)
--   B  | Fmaj7 .  | Em7 Am7| Dm7 G7 | Cmaj7 . |   (8 bars)
--   A' |: Cmaj7 . | Am7 .  | Dm7 .  | G7  .  :|   (8 bars)
--   C  | Fmaj7 Fm7| Em7 Am7| Dm7 G7 | Cmaj7 . |   (8 bars)
-- ============================================================

-- Bass root / fifth for each chord (MIDI notes in octave 2-3)
local chords = {
    Cmaj7 = { root = 48, fifth = 55, comp1 = 64, comp2 = 71 },  -- C3, G3, E4, B4
    Am7   = { root = 45, fifth = 52, comp1 = 60, comp2 = 67 },  -- A2, E3, C4, G4
    Dm7   = { root = 50, fifth = 45, comp1 = 65, comp2 = 72 },  -- D3, A2, F4, C5
    G7    = { root = 43, fifth = 50, comp1 = 62, comp2 = 65 },  -- G2, D3, D4, F4
    Fmaj7 = { root = 53, fifth = 48, comp1 = 69, comp2 = 76 },  -- F3, C3, A4, E5
    Em7   = { root = 52, fifth = 47, comp1 = 67, comp2 = 71 },  -- E3, B2, G4, B4
    Fm7   = { root = 53, fifth = 48, comp1 = 68, comp2 = 75 },  -- F3, C3, Ab4, Eb5
}

-- Which chord for each bar
local progression = {
    -- Section A (bars 1-8)
    "Cmaj7","Cmaj7", "Am7","Am7", "Dm7","Dm7", "G7","G7",
    -- Section B (bars 9-16)
    "Fmaj7","Fmaj7", "Em7","Am7", "Dm7","G7", "Cmaj7","Cmaj7",
    -- Section A' (bars 17-24)
    "Cmaj7","Cmaj7", "Am7","Am7", "Dm7","Dm7", "G7","G7",
    -- Section C (bars 25-32)
    "Fmaj7","Fm7", "Em7","Am7", "Dm7","G7", "Cmaj7","Cmaj7",
}

-- ============================================================
-- RHYTHM SECTION (bass + nylon comp + percussion)
-- Repeats for all 32 bars following the chord progression
-- ============================================================
for bar = 1, 32 do
    local ch = chords[progression[bar]]
    local odd = (bar % 2 == 1)

    -- Bass: root on beat 1, fifth on "and of 2"
    add(at(bar, 0), BASS, ch.root)
    add(at(bar, 3), BASS, ch.fifth)

    -- Nylon comp: chord tones on upbeats ("and of 1", "and of 3")
    add(at(bar, 1), NYLON, ch.comp1)
    add(at(bar, 5), NYLON, ch.comp2)

    -- Hi-hat: beats 2 and 4
    add(at(bar, 2), HIHAT, 53)
    add(at(bar, 6), HIHAT, 53)

    -- Clave: bossa pattern (alternates between bars)
    if odd then
        add(at(bar, 0), CLAVE, 82)
    else
        add(at(bar, 4), CLAVE, 82)
    end
end

-- ============================================================
-- Walking bass approach notes (last beat before chord changes)
-- These give the bossa that smooth walking feel
-- ============================================================
-- Bar 2 -> Am7:  walk C-B-A
add(at(2, 7), BASS, 47)   -- B2 approach to A

-- Bar 4 -> Dm7:  walk A-B-C-D
add(at(4, 7), BASS, 48)   -- C3 approach to D

-- Bar 6 -> G7:   walk D-E-F#-G
add(at(6, 7), BASS, 42)   -- F#2 approach to G

-- Bar 8 -> Fmaj7 (section B): walk G-A-Bb
add(at(8, 6), BASS, 45)   -- A2
add(at(8, 7), BASS, 51)   -- Eb3 (chromatic approach to E)

-- Bar 10 -> Em7: walk F-E
add(at(10, 7), BASS, 52)  -- E3 slide

-- Bar 14 -> Cmaj7: walk G-A-B
add(at(14, 7), BASS, 47)  -- B2 into C

-- Bar 16 -> Cmaj7 (loop to A'): keep C
add(at(16, 7), BASS, 47)  -- B2 pickup

-- Bar 18 -> Am7: same as bar 2
add(at(18, 7), BASS, 47)

-- Bar 20 -> Dm7
add(at(20, 7), BASS, 48)

-- Bar 22 -> G7
add(at(22, 7), BASS, 42)

-- Bar 24 -> Fmaj7 (section C)
add(at(24, 7), BASS, 52)

-- Bar 26 -> Em7: walk F-E
add(at(26, 7), BASS, 52)

-- Bar 30 -> Cmaj7
add(at(30, 7), BASS, 47)

-- Bar 32 -> loop back to bar 1 (Cmaj7): approach note
add(at(32, 7), BASS, 47)  -- B2 -> C

-- ============================================================
-- MELODY (Kalimba) - pentatonic with jazzy passing tones
--
-- MIDI reference: C5=72 D5=74 E5=76 F5=77 G5=79
--                 A5=81 B5=83 C6=84
--                 B4=71 A4=69
-- ============================================================

-- ---- Section A (bars 1-8): Main theme ----

-- Bar 1: opening motif  G-A-G-E (catchy hook)
add(at(1, 0), KALIMBA, 79)  -- G5
add(at(1, 2), KALIMBA, 81)  -- A5
add(at(1, 4), KALIMBA, 79)  -- G5
add(at(1, 6), KALIMBA, 76)  -- E5

-- Bar 2: answer phrase  D . E . . . G .
add(at(2, 0), KALIMBA, 74)  -- D5
add(at(2, 2), KALIMBA, 76)  -- E5
add(at(2, 6), KALIMBA, 79)  -- G5 (pickup)

-- Bar 3: Am7 color  E-G-A (rising)
add(at(3, 0), KALIMBA, 76)  -- E5
add(at(3, 2), KALIMBA, 79)  -- G5
add(at(3, 4), KALIMBA, 81)  -- A5

-- Bar 4: settle  G . . . . . C .
add(at(4, 0), KALIMBA, 79)  -- G5
add(at(4, 6), KALIMBA, 72)  -- C5

-- Bar 5: Dm7 - new color  F-A . . F
add(at(5, 0), KALIMBA, 77)  -- F5
add(at(5, 2), KALIMBA, 81)  -- A5
add(at(5, 6), KALIMBA, 77)  -- F5

-- Bar 6: stepping down  D . . E . . . .
add(at(6, 0), KALIMBA, 74)  -- D5
add(at(6, 4), KALIMBA, 76)  -- E5

-- Bar 7: G7 tension  B-D . F . . . .
add(at(7, 0), KALIMBA, 71)  -- B4
add(at(7, 2), KALIMBA, 74)  -- D5
add(at(7, 4), KALIMBA, 77)  -- F5 (tritone color)

-- Bar 8: resolution approach  . E . . . . D .
add(at(8, 2), KALIMBA, 76)  -- E5
add(at(8, 6), KALIMBA, 74)  -- D5

-- ---- Section B (bars 9-16): Contrasting melody ----

-- Bar 9: Fmaj7 - soaring high  A-C6-A
add(at(9, 0), KALIMBA, 81)   -- A5
add(at(9, 2), KALIMBA, 84)   -- C6 (high point!)
add(at(9, 4), KALIMBA, 81)   -- A5

-- Bar 10: cascading  . . G . . . E .
add(at(10, 2), KALIMBA, 79)  -- G5
add(at(10, 6), KALIMBA, 76)  -- E5

-- Bar 11: Em7  G . . B4 . . D .
add(at(11, 0), KALIMBA, 79)  -- G5
add(at(11, 3), KALIMBA, 71)  -- B4
add(at(11, 6), KALIMBA, 74)  -- D5

-- Bar 12: Am7  E . . C . . . .
add(at(12, 0), KALIMBA, 76)  -- E5
add(at(12, 3), KALIMBA, 72)  -- C5

-- Bar 13: Dm7  . . D . F . . .
add(at(13, 2), KALIMBA, 74)  -- D5
add(at(13, 4), KALIMBA, 77)  -- F5

-- Bar 14: G7  G . . F . . D .
add(at(14, 0), KALIMBA, 79)  -- G5
add(at(14, 3), KALIMBA, 77)  -- F5
add(at(14, 6), KALIMBA, 74)  -- D5

-- Bar 15: resolve to C  E . C . E . . .
add(at(15, 0), KALIMBA, 76)  -- E5
add(at(15, 2), KALIMBA, 72)  -- C5
add(at(15, 4), KALIMBA, 76)  -- E5

-- Bar 16: breathing space, pickup to A'
add(at(16, 6), KALIMBA, 79)  -- G5 (pickup)

-- ---- Section A' (bars 17-24): Variation on main theme ----

-- Bar 17: motif with higher reach  G-B5-A-G
add(at(17, 0), KALIMBA, 79)  -- G5
add(at(17, 2), KALIMBA, 83)  -- B5 (higher variation!)
add(at(17, 4), KALIMBA, 81)  -- A5
add(at(17, 6), KALIMBA, 79)  -- G5

-- Bar 18: descending  . E . D . . C .
add(at(18, 1), KALIMBA, 76)  -- E5 (syncopated!)
add(at(18, 3), KALIMBA, 74)  -- D5
add(at(18, 6), KALIMBA, 72)  -- C5

-- Bar 19: Am7  A-G . . . E . .
add(at(19, 0), KALIMBA, 81)  -- A5
add(at(19, 2), KALIMBA, 79)  -- G5
add(at(19, 5), KALIMBA, 76)  -- E5

-- Bar 20: space  . . C . D . . .
add(at(20, 2), KALIMBA, 72)  -- C5
add(at(20, 4), KALIMBA, 74)  -- D5

-- Bar 21: Dm7 variation  F . . A . . D .
add(at(21, 0), KALIMBA, 77)  -- F5
add(at(21, 3), KALIMBA, 81)  -- A5
add(at(21, 6), KALIMBA, 74)  -- D5

-- Bar 22: settling  F . E . . . D .
add(at(22, 0), KALIMBA, 77)  -- F5
add(at(22, 2), KALIMBA, 76)  -- E5
add(at(22, 6), KALIMBA, 74)  -- D5

-- Bar 23: G7  B4 . . D . . G .
add(at(23, 0), KALIMBA, 71)  -- B4
add(at(23, 3), KALIMBA, 74)  -- D5
add(at(23, 6), KALIMBA, 79)  -- G5

-- Bar 24: transition to C section  F-E . . . . D .
add(at(24, 0), KALIMBA, 77)  -- F5
add(at(24, 2), KALIMBA, 76)  -- E5
add(at(24, 6), KALIMBA, 74)  -- D5

-- ---- Section C (bars 25-32): Bridge / build ----

-- Bar 25: Fmaj7 - high energy  C6 . . A . . G .
add(at(25, 0), KALIMBA, 84)  -- C6 (big!)
add(at(25, 3), KALIMBA, 81)  -- A5
add(at(25, 6), KALIMBA, 79)  -- G5

-- Bar 26: Fm7 - chromatic moment!  Ab5 . G . . F . .
add(at(26, 0), KALIMBA, 80)  -- Ab5 (Fm7 color!)
add(at(26, 2), KALIMBA, 79)  -- G5
add(at(26, 5), KALIMBA, 77)  -- F5

-- Bar 27: Em7  G . E . G . . .
add(at(27, 0), KALIMBA, 79)  -- G5
add(at(27, 2), KALIMBA, 76)  -- E5
add(at(27, 4), KALIMBA, 79)  -- G5

-- Bar 28: Am7  A . . G . . E .
add(at(28, 0), KALIMBA, 81)  -- A5
add(at(28, 3), KALIMBA, 79)  -- G5
add(at(28, 6), KALIMBA, 76)  -- E5

-- Bar 29: Dm7  D . . F . . A .
add(at(29, 0), KALIMBA, 74)  -- D5
add(at(29, 3), KALIMBA, 77)  -- F5
add(at(29, 6), KALIMBA, 81)  -- A5

-- Bar 30: G7  G . F . D . . .
add(at(30, 0), KALIMBA, 79)  -- G5
add(at(30, 2), KALIMBA, 77)  -- F5
add(at(30, 4), KALIMBA, 74)  -- D5

-- Bar 31: Cmaj7 finale  E . G . C6 . . .
add(at(31, 0), KALIMBA, 76)  -- E5
add(at(31, 2), KALIMBA, 79)  -- G5
add(at(31, 4), KALIMBA, 84)  -- C6 (climax)

-- Bar 32: descending to loop point  B5 . A . G . . D
add(at(32, 0), KALIMBA, 83)  -- B5
add(at(32, 2), KALIMBA, 81)  -- A5
add(at(32, 4), KALIMBA, 79)  -- G5

-- ============================================================
-- HARP sparkles (sample 64) on section transitions
-- Adds a magical "ninja" shimmer
-- ============================================================
add(at(8, 7),  HARP, 72)   -- C5 end of section A
add(at(16, 4), HARP, 76)   -- E5 end of section B
add(at(24, 7), HARP, 72)   -- C5 end of section A'
add(at(32, 7), HARP, 67)   -- G4 end of section C (loop point)

-- ============================================================
-- RHODES pad (sample 50) - occasional color on section starts
-- Adds warmth under the Kalimba melody
-- ============================================================
add(at(9, 0),  RHODES, 69)   -- A4 (Fmaj7 color) section B start
add(at(25, 0), RHODES, 72)   -- C5 (Fmaj7 color) section C start

-- ============================================================
-- Return the song data
-- ============================================================
return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 120,
    title  = "Pique Esconde Ninja",
}
