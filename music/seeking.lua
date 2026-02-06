-- ============================================================
-- "Cadê o Ninja?" - Seeking Phase BGM
-- Mysterious bossa — the seekers are looking!
-- Tense, atmospheric, with jazzy suspense and bossa groove
-- 100 BPM @ 60 FPS => 36 frames/beat, 144 frames/bar
-- 48 bars => 6912 frames (115.2 seconds / ~1m55s), loops seamlessly
--
-- Structure (48 bars):
--   A  (1-8)   Harp arpeggios + Rhodes, mysterious
--   B  (9-16)  Flute melody, searching theme
--   C  (17-24) Cello enters, darker chromatic
--   D  (25-32) Kalimba + Flute, "getting warmer!"
--   E  (33-40) Sparse tension, windchimes
--   F  (41-48) Theme intensifies, loop home
-- ============================================================

local FRAMES_PER_BEAT = 36
local FRAMES_PER_BAR  = 144
local TOTAL_FRAMES    = 48 * FRAMES_PER_BAR  -- 6912

-- Sample aliases (index into pcm_map)
local BASS    = 59   -- Acoustic Bass A#3 (base midi 46)
local NYLON   = 23   -- Nylon Guitar B4   (base midi 59)
local KALIMBA = 62   -- Kalimba A5        (base midi 69)
local RHODES  = 50   -- Rhodes C5         (base midi 60)
local CLAVE   = 12   -- 808 Clave         (base midi 82)
local HIHAT   = 6    -- 808 Closed Hat    (base midi 53)
local FLUTE   = 33   -- Flute D5          (base midi 74)
local HARP    = 64   -- Harp D#4          (base midi 63)
local CELLO   = 18   -- Cello E4          (base midi 52)
local WINDCHM = 24   -- Windchimes        (base midi 60)
local MARACA  = 0    -- 808 Maraca        (base midi 89)
local WOODBLK = 54   -- Low Woodblock     (base midi 60)
local OBOE    = 39   -- Oboe A#4          (base midi 70)

-- ============================================================
-- Builder
-- ============================================================
local notes = {}

local function add(frame, sample, note)
    if not notes[frame] then notes[frame] = {} end
    table.insert(notes[frame], {sample, note})
end

local function at(bar, eighth)
    -- 100 BPM: 8th note = 18 frames
    return (bar - 1) * FRAMES_PER_BAR + eighth * 18
end

-- ============================================================
-- Chord data (minor, mysterious voicings)
-- ============================================================
local chords = {
    Am7   = { root = 45, fifth = 52, comp1 = 60, comp2 = 67 },
    Dm7   = { root = 50, fifth = 45, comp1 = 65, comp2 = 72 },
    Em7   = { root = 52, fifth = 47, comp1 = 67, comp2 = 71 },
    E7    = { root = 52, fifth = 47, comp1 = 68, comp2 = 71 },
    Fmaj7 = { root = 53, fifth = 48, comp1 = 69, comp2 = 76 },
    Fm7   = { root = 53, fifth = 48, comp1 = 68, comp2 = 75 },
    Cmaj7 = { root = 48, fifth = 55, comp1 = 64, comp2 = 71 },
    G7    = { root = 43, fifth = 50, comp1 = 62, comp2 = 65 },
    Bbmaj7= { root = 46, fifth = 53, comp1 = 62, comp2 = 69 },
    Abdim = { root = 44, fifth = 50, comp1 = 63, comp2 = 68 },
}

-- Chord progression — 48 bars, minor & mysterious
local progression = {
    -- A (1-8): mysterious opening, Am center
    "Am7","Am7", "Dm7","Dm7", "Em7","E7", "Am7","Am7",
    -- B (9-16): searching flute, chromatic color
    "Fmaj7","Fm7", "Em7","Am7", "Dm7","G7", "Cmaj7","E7",
    -- C (17-24): darker, cello enters
    "Am7","Am7", "Bbmaj7","Bbmaj7", "Dm7","Abdim", "E7","E7",
    -- D (25-32): "getting warmer" — more active
    "Am7","Dm7", "Em7","Am7", "Fmaj7","Fm7", "E7","E7",
    -- E (33-40): sparse, windchimes, tension
    "Am7","Am7", "Dm7","Dm7", "Fmaj7","Fmaj7", "E7","E7",
    -- F (41-48): theme intensifies, loop
    "Am7","Am7", "Dm7","Dm7", "Fmaj7","E7", "Am7","Am7",
}

-- ============================================================
-- RHYTHM SECTION (48 bars with per-section variations)
-- ============================================================
for bar = 1, 48 do
    local ch = chords[progression[bar]]
    local odd = (bar % 2 == 1)

    -- Section flags
    local is_sparse = (bar >= 33 and bar <= 40)
    local is_dark = (bar >= 17 and bar <= 24)
    local is_active = (bar >= 25 and bar <= 32)

    -- Bass: deep and slow, root + ghost fifth
    add(at(bar, 0), BASS, ch.root)
    if not is_sparse then
        add(at(bar, 4), BASS, ch.fifth)
    end

    if not is_sparse then
        -- Nylon: quiet comp on upbeats
        add(at(bar, 2), NYLON, ch.comp1)
        add(at(bar, 6), NYLON, ch.comp2)

        -- Hi-hat: very light, just beat 3
        add(at(bar, 4), HIHAT, 53)

        -- Clave: sparse mystery pattern
        if odd then
            add(at(bar, 0), CLAVE, 82)
        else
            add(at(bar, 3), CLAVE, 82)
        end
    else
        -- Sparse section: only a ghostly hat on beat 4 every other bar
        if odd then
            add(at(bar, 6), HIHAT, 53)
        end
    end

    -- Low woodblock heartbeat in dark section (like footsteps!)
    if is_dark then
        add(at(bar, 0), WOODBLK, 60)
        add(at(bar, 4), WOODBLK, 60)
    end

    -- Maraca shuffle in active section
    if is_active then
        add(at(bar, 1), MARACA, 89)
        add(at(bar, 5), MARACA, 89)
    end
end

-- ============================================================
-- WALKING BASS approach notes
-- ============================================================
-- Section A (1-8)
add(at(2, 7), BASS, 49)   -- Db3 -> Dm
add(at(4, 7), BASS, 51)   -- Eb3 -> Em
add(at(6, 7), BASS, 44)   -- Ab2 -> Am
add(at(8, 7), BASS, 52)   -- E3 -> F (into B)

-- Section B (9-16)
add(at(10, 7), BASS, 51)  -- -> Em
add(at(12, 7), BASS, 49)  -- -> Dm
add(at(14, 7), BASS, 47)  -- -> C
add(at(16, 7), BASS, 44)  -- -> Am (into C)

-- Section C (17-24)
add(at(18, 7), BASS, 45)  -- -> Bb
add(at(20, 7), BASS, 49)  -- -> Dm
add(at(22, 7), BASS, 51)  -- -> E7
add(at(24, 7), BASS, 44)  -- -> Am (into D)

-- Section D (25-32)
add(at(26, 7), BASS, 51)  -- -> Em
add(at(28, 7), BASS, 52)  -- -> F
add(at(30, 7), BASS, 51)  -- -> E7
add(at(32, 7), BASS, 44)  -- -> Am (into E)

-- Section E (33-40)
add(at(34, 7), BASS, 49)  -- -> Dm
add(at(36, 7), BASS, 52)  -- -> F
add(at(38, 7), BASS, 51)  -- -> E7
add(at(40, 7), BASS, 44)  -- -> Am (into F)

-- Section F (41-48)
add(at(42, 7), BASS, 49)  -- -> Dm
add(at(44, 7), BASS, 52)  -- -> F
add(at(46, 7), BASS, 44)  -- -> Am
add(at(48, 7), BASS, 44)  -- -> Am (loop!)

-- ============================================================
-- MIDI reference:
--   C4=60 D4=62 E4=64 F4=65 G4=67 A4=69 B4=71
--   C5=72 D5=74 E5=76 F5=77 G5=79 A5=81 B5=83 C6=84
--   Bb3=58 Ab4=68 Db5=73 Eb5=75 F#5=78 Ab5=80 Bb5=82
-- ============================================================

-- ============================================================
-- SECTION A (bars 1-8): Harp arpeggios + Rhodes mystery
-- Like shadows in the moonlight
-- ============================================================

-- Bar 1: Harp arpeggio Am  A . C . E . . .
add(at(1, 0), HARP, 57)    -- A3
add(at(1, 2), HARP, 60)    -- C4
add(at(1, 4), HARP, 64)    -- E4
-- Rhodes pad
add(at(1, 0), RHODES, 60)  -- C4 (warm)

-- Bar 2: Harp descending  G . E . C . . .
add(at(2, 0), HARP, 67)    -- G4
add(at(2, 2), HARP, 64)    -- E4
add(at(2, 4), HARP, 60)    -- C4

-- Bar 3: Dm  Harp D . F . A . . .
add(at(3, 0), HARP, 62)    -- D4
add(at(3, 2), HARP, 65)    -- F4
add(at(3, 4), HARP, 69)    -- A4

-- Bar 4: Dm  Harp high  C . A . F . . .
add(at(4, 0), HARP, 72)    -- C5
add(at(4, 2), HARP, 69)    -- A4
add(at(4, 4), HARP, 65)    -- F4

-- Bar 5: Em  Harp E . G . B . . .
add(at(5, 0), HARP, 64)    -- E4
add(at(5, 2), HARP, 67)    -- G4
add(at(5, 4), HARP, 71)    -- B4

-- Bar 6: E7  Rhodes G# . B . . .
add(at(6, 0), RHODES, 68)  -- G#4 (tension!)
add(at(6, 3), RHODES, 71)  -- B4

-- Bar 7: Am resolve  Harp A . E . . .
add(at(7, 0), HARP, 69)    -- A4
add(at(7, 3), HARP, 64)    -- E4
-- Rhodes
add(at(7, 0), RHODES, 60)  -- C4

-- Bar 8: Am  Harp C . A . . .  (settling)
add(at(8, 0), HARP, 72)    -- C5
add(at(8, 3), HARP, 69)    -- A4

-- ============================================================
-- SECTION B (bars 9-16): Flute searching theme
-- The seeker looks around, eyes scanning...
-- ============================================================

-- Bar 9: Fmaj7  Flute A . . C6 . . A .
add(at(9, 0), FLUTE, 81)
add(at(9, 3), FLUTE, 84)
add(at(9, 6), FLUTE, 81)

-- Bar 10: Fm7  Flute Ab . . G . F .  (chromatic descent — suspicious!)
add(at(10, 0), FLUTE, 80)
add(at(10, 3), FLUTE, 79)
add(at(10, 5), FLUTE, 77)

-- Bar 11: Em7  Flute G . . E . . B4 .
add(at(11, 0), FLUTE, 79)
add(at(11, 3), FLUTE, 76)
add(at(11, 6), FLUTE, 71)

-- Bar 12: Am7  Flute . . E . . . A .  (questioning)
add(at(12, 2), FLUTE, 76)
add(at(12, 6), FLUTE, 81)

-- Harp echo
add(at(12, 4), HARP, 64)

-- Bar 13: Dm7  Flute D . . F . . A .
add(at(13, 0), FLUTE, 74)
add(at(13, 3), FLUTE, 77)
add(at(13, 6), FLUTE, 81)

-- Bar 14: G7  Flute G . F . . D . .
add(at(14, 0), FLUTE, 79)
add(at(14, 2), FLUTE, 77)
add(at(14, 5), FLUTE, 74)

-- Bar 15: Cmaj7  Flute E . . G . . . .
add(at(15, 0), FLUTE, 76)
add(at(15, 3), FLUTE, 79)

-- Bar 16: E7  Flute G# . . B . . . .  (uh oh, where are they?)
add(at(16, 0), FLUTE, 80)
add(at(16, 3), FLUTE, 83)
-- Harp tension
add(at(16, 5), HARP, 68)   -- G#4

-- ============================================================
-- SECTION C (bars 17-24): Cello enters — darker!
-- The search intensifies, chromatic tension builds
-- ============================================================

-- Bar 17: Am  Cello A low drone
add(at(17, 0), CELLO, 57)  -- A3
-- Harp  E . A . . .
add(at(17, 2), HARP, 64)
add(at(17, 4), HARP, 69)

-- Bar 18: Am  Cello E
add(at(18, 0), CELLO, 52)  -- E3
-- Flute echo  . . . G . . E .
add(at(18, 3), FLUTE, 79)
add(at(18, 6), FLUTE, 76)

-- Bar 19: Bbmaj7  Cello Bb — dark shift!
add(at(19, 0), CELLO, 58)  -- Bb3
-- Harp Bb . D . F .
add(at(19, 0), HARP, 58)
add(at(19, 2), HARP, 62)
add(at(19, 4), HARP, 65)
-- Rhodes
add(at(19, 0), RHODES, 69) -- A4 -> Bb creates tension

-- Bar 20: Bbmaj7  Cello sustain
add(at(20, 0), CELLO, 58)
-- Flute wanders  D . . . Bb . . .
add(at(20, 0), FLUTE, 74)
add(at(20, 4), FLUTE, 70)  -- Bb4

-- Bar 21: Dm7  Cello D
add(at(21, 0), CELLO, 50)  -- D3
-- Harp  D . F . A .
add(at(21, 0), HARP, 62)
add(at(21, 2), HARP, 65)
add(at(21, 4), HARP, 69)

-- Bar 22: Abdim  Cello Ab — eerie!
add(at(22, 0), CELLO, 56)  -- Ab3
-- Harp  Ab . . B . . .
add(at(22, 0), HARP, 68)   -- Ab4
add(at(22, 3), HARP, 71)   -- B4
-- Rhodes dissonance
add(at(22, 0), RHODES, 63) -- Eb4

-- Bar 23: E7  Cello E
add(at(23, 0), CELLO, 52)  -- E3
-- Flute  G# . B . E . . .  (dominant tension)
add(at(23, 0), FLUTE, 80)  -- G#5
add(at(23, 2), FLUTE, 83)  -- B5
add(at(23, 4), FLUTE, 76)  -- E5

-- Bar 24: E7  resolve approach
add(at(24, 0), CELLO, 52)
-- Harp descending  B . G# . E . . .
add(at(24, 0), HARP, 71)   -- B4
add(at(24, 2), HARP, 68)   -- Ab4/G#4
add(at(24, 4), HARP, 64)   -- E4

-- ============================================================
-- SECTION D (bars 25-32): "Getting warmer!"
-- Kalimba + Flute, more energy, maraca shuffle
-- ============================================================

-- Bar 25: Am  Kalimba sneaks in  E . A . . . . .
add(at(25, 0), KALIMBA, 76)
add(at(25, 2), KALIMBA, 81)

-- Bar 26: Dm  Flute  D . F . A . . .
add(at(26, 0), FLUTE, 74)
add(at(26, 2), FLUTE, 77)
add(at(26, 4), FLUTE, 81)
-- Kalimba echo
add(at(26, 6), KALIMBA, 74)

-- Bar 27: Em  Kalimba  G . B . G . E .
add(at(27, 0), KALIMBA, 79)
add(at(27, 2), KALIMBA, 83)
add(at(27, 4), KALIMBA, 79)
add(at(27, 6), KALIMBA, 76)

-- Bar 28: Am  Flute  A . G . E . . .
add(at(28, 0), FLUTE, 81)
add(at(28, 2), FLUTE, 79)
add(at(28, 4), FLUTE, 76)

-- Bar 29: Fmaj7  Kalimba  A . C6 . A . F .
add(at(29, 0), KALIMBA, 81)
add(at(29, 2), KALIMBA, 84)
add(at(29, 4), KALIMBA, 81)
add(at(29, 6), KALIMBA, 77)

-- Bar 30: Fm7  Flute chromatic descent  Ab . G . F . . .
add(at(30, 0), FLUTE, 80)
add(at(30, 2), FLUTE, 79)
add(at(30, 4), FLUTE, 77)
-- Kalimba  Eb (dark!)
add(at(30, 6), KALIMBA, 75)

-- Bar 31: E7  Kalimba  G# . B . E . . .
add(at(31, 0), KALIMBA, 80)
add(at(31, 2), KALIMBA, 83)
add(at(31, 4), KALIMBA, 76)
-- Flute
add(at(31, 6), FLUTE, 80)  -- G#5

-- Bar 32: E7  Flute  B . G# . . . . .  (tension holds!)
add(at(32, 0), FLUTE, 83)
add(at(32, 2), FLUTE, 80)
-- Harp
add(at(32, 4), HARP, 64)
add(at(32, 6), HARP, 68)

-- ============================================================
-- SECTION E (bars 33-40): Sparse tension + windchimes
-- Almost found them... or not? Ghostly atmosphere.
-- Bass only + harp + windchimes
-- ============================================================

-- Bar 33: Am  Harp A . . E . . . .
add(at(33, 0), HARP, 69)
add(at(33, 3), HARP, 64)

-- Windchimes!
add(at(33, 0), WINDCHM, 60)

-- Bar 34: Am  Rhodes whisper  C . . . . .
add(at(34, 0), RHODES, 60)

-- Bar 35: Dm  Harp D . A . . .
add(at(35, 0), HARP, 62)
add(at(35, 3), HARP, 69)

-- Bar 36: Dm  Harp F . . C . . .
add(at(36, 0), HARP, 65)
add(at(36, 3), HARP, 72)

-- Windchimes
add(at(36, 6), WINDCHM, 60)

-- Bar 37: Fmaj7  Harp F . A . C . E .
add(at(37, 0), HARP, 65)
add(at(37, 2), HARP, 69)
add(at(37, 4), HARP, 72)
add(at(37, 6), HARP, 76)

-- Bar 38: Fmaj7  Rhodes  A . . . . .
add(at(38, 0), RHODES, 69)
-- Harp echo  . . E . . .
add(at(38, 3), HARP, 76)

-- Bar 39: E7  Harp tension  E . G# . B . . .
add(at(39, 0), HARP, 64)
add(at(39, 2), HARP, 68)
add(at(39, 4), HARP, 71)

-- Cello rumble
add(at(39, 0), CELLO, 52)

-- Bar 40: E7  Building...  Harp D . E . . .
add(at(40, 0), HARP, 74)   -- D5
add(at(40, 2), HARP, 76)   -- E5

-- Windchimes (awakening)
add(at(40, 4), WINDCHM, 60)

-- Flute pickup into F
add(at(40, 6), FLUTE, 76)  -- E5

-- ============================================================
-- SECTION F (bars 41-48): Theme intensifies, loop home
-- The search continues! Main melody comes back stronger
-- ============================================================

-- Bar 41: Am  Flute A . G . E . . .
add(at(41, 0), FLUTE, 81)
add(at(41, 2), FLUTE, 79)
add(at(41, 4), FLUTE, 76)
-- Cello foundation
add(at(41, 0), CELLO, 57)

-- Bar 42: Am  Kalimba echo  E . A . . . G .
add(at(42, 0), KALIMBA, 76)
add(at(42, 2), KALIMBA, 81)
add(at(42, 6), KALIMBA, 79)

-- Bar 43: Dm  Flute D . F . A . . .
add(at(43, 0), FLUTE, 74)
add(at(43, 2), FLUTE, 77)
add(at(43, 4), FLUTE, 81)
-- Cello
add(at(43, 0), CELLO, 50)

-- Bar 44: Dm  Kalimba  A . F . D . . .
add(at(44, 0), KALIMBA, 81)
add(at(44, 2), KALIMBA, 77)
add(at(44, 4), KALIMBA, 74)

-- Bar 45: Fmaj7  Flute + Kalimba together!
add(at(45, 0), FLUTE, 81)     -- A
add(at(45, 0), KALIMBA, 84)   -- C6
add(at(45, 3), FLUTE, 77)     -- F
add(at(45, 5), KALIMBA, 81)   -- A

-- Bar 46: E7  Chromatic tension!  Flute G# . B . . . . .
add(at(46, 0), FLUTE, 80)
add(at(46, 2), FLUTE, 83)
-- Kalimba  . . . . E . G# .
add(at(46, 4), KALIMBA, 76)
add(at(46, 6), KALIMBA, 80)
-- Cello
add(at(46, 0), CELLO, 52)

-- Bar 47: Am  Flute resolve  A . . G . . E .
add(at(47, 0), FLUTE, 81)
add(at(47, 3), FLUTE, 79)
add(at(47, 6), FLUTE, 76)

-- Bar 48: Am  winding down to loop  . . E . C . . .
add(at(48, 2), KALIMBA, 76)
add(at(48, 4), KALIMBA, 72)
-- Harp loop shimmer
add(at(48, 6), HARP, 69)   -- A4

-- ============================================================
-- HARP sparkles on section transitions
-- ============================================================
add(at(8, 7),  HARP, 69)   -- A4 end of A
add(at(16, 7), HARP, 64)   -- E4 end of B (mysterious)
add(at(24, 7), HARP, 57)   -- A3 end of C (low, dark)
add(at(32, 7), HARP, 69)   -- A4 end of D
add(at(40, 7), HARP, 64)   -- E4 end of E
add(at(48, 7), HARP, 69)   -- A4 loop shimmer

-- ============================================================
-- RHODES pad color on section starts
-- ============================================================
add(at(1, 0),  RHODES, 57)  -- A3 section A (low, mysterious)
add(at(9, 0),  RHODES, 65)  -- F4 section B
add(at(17, 0), RHODES, 57)  -- A3 section C (dark)
add(at(25, 0), RHODES, 60)  -- C4 section D
add(at(33, 0), RHODES, 57)  -- A3 section E (ghostly)
add(at(41, 0), RHODES, 60)  -- C4 section F

-- ============================================================
-- WINDCHIMES atmosphere at key moments
-- ============================================================
add(at(1, 4),  WINDCHM, 60)  -- opening atmosphere
add(at(17, 4), WINDCHM, 60)  -- cello entrance
add(at(41, 4), WINDCHM, 60)  -- final section

-- ============================================================
-- Return the song data
-- ============================================================
return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 100,
    title  = "Cadê o Ninja?",
}
