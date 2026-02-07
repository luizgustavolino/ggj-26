local FRAMES_PER_BEAT = 30
local FRAMES_PER_BAR  = 120
local TOTAL_FRAMES    = 32 * FRAMES_PER_BAR  -- 3840

local BASS    = 59   -- Acoustic Bass A#3 (base midi 46)
local NYLON   = 23   -- Nylon Guitar B4   (base midi 59)
local KALIMBA = 62   -- Kalimba A5        (base midi 69)
local KOTO    = 43   -- Koto F#5          (base midi 66)
local FLUTE   = 33   -- Flute D5          (base midi 74)
local HIHAT   = 6    -- 808 Closed Hat    (base midi 53)
local CLAVE   = 12   -- 808 Clave         (base midi 82)
local MARACA  = 0    -- 808 Maraca        (base midi 89)
local HARP    = 64   -- Harp D#4          (base midi 63)

local notes = {}

local function add(frame, sample, note)
    if not notes[frame] then notes[frame] = {} end
    table.insert(notes[frame], {sample, note})
end

local function at(bar, eighth)
    return (bar - 1) * FRAMES_PER_BAR + eighth * 15
end

local chords = {
    Cmaj7 = { root = 48, fifth = 55, comp1 = 64, comp2 = 59 },
    Am7   = { root = 45, fifth = 52, comp1 = 60, comp2 = 55 },
    Dm7   = { root = 50, fifth = 45, comp1 = 65, comp2 = 60 },
    G7    = { root = 43, fifth = 50, comp1 = 62, comp2 = 65 },
    Fmaj7 = { root = 53, fifth = 48, comp1 = 57, comp2 = 64 },
    Em7   = { root = 52, fifth = 47, comp1 = 55, comp2 = 59 },
    Fm7   = { root = 53, fifth = 48, comp1 = 56, comp2 = 63 },
}

local progression = {
    -- A (1-8): sneaky start
    "Am7","Am7", "Dm7","Dm7", "G7","G7", "Cmaj7","Cmaj7",
    -- B (9-16): koto ninja
    "Fmaj7","Fmaj7", "Em7","Em7", "Am7","Am7", "Dm7","G7",
    -- C (17-24): playful exchange
    "Cmaj7","Cmaj7", "Am7","Am7", "Fmaj7","Fmaj7", "Dm7","G7",
    -- D (25-32): build and loop
    "Am7","Am7", "Dm7","Dm7", "Fmaj7","Fm7", "Em7","Am7",
}

for bar = 1, 32 do
    local ch = chords[progression[bar]]
    local odd = (bar % 2 == 1)
    local is_koto_section = (bar >= 9 and bar <= 16)
    local is_build = (bar >= 25 and bar <= 32)

    add(at(bar, 0), BASS, ch.root)
    add(at(bar, 3), BASS, ch.fifth)
    add(at(bar, 1), NYLON, ch.comp1)
    add(at(bar, 5), NYLON, ch.comp2)
    add(at(bar, 2), HIHAT, 53)
    add(at(bar, 6), HIHAT, 53)

    if odd then
        add(at(bar, 0), CLAVE, 82)
    else
        add(at(bar, 4), CLAVE, 82)
    end

    if is_koto_section then
        add(at(bar, 1), HIHAT, 53)
        add(at(bar, 5), HIHAT, 53)
    end

    if is_build then
        add(at(bar, 1), MARACA, 89)
        add(at(bar, 3), MARACA, 89)
        add(at(bar, 5), MARACA, 89)
        add(at(bar, 7), MARACA, 89)
    end
end

add(at(2, 7), BASS, 49)
add(at(4, 7), BASS, 42)
add(at(6, 7), BASS, 47)
add(at(8, 7), BASS, 52)

add(at(10, 7), BASS, 51)
add(at(12, 7), BASS, 44)
add(at(14, 7), BASS, 49)
add(at(16, 7), BASS, 47)

add(at(18, 7), BASS, 44)
add(at(20, 7), BASS, 52)
add(at(22, 7), BASS, 49)
add(at(24, 7), BASS, 44)

add(at(26, 7), BASS, 49)
add(at(28, 7), BASS, 52)
add(at(30, 7), BASS, 51)
add(at(32, 7), BASS, 44)

add(at(1, 2), KALIMBA, 64)
add(at(1, 6), KALIMBA, 67)

add(at(2, 0), KALIMBA, 69)
add(at(2, 2), KALIMBA, 67)
add(at(2, 4), KALIMBA, 64)

add(at(3, 0), KALIMBA, 65)

add(at(4, 2), KALIMBA, 69)
add(at(4, 4), KALIMBA, 65)
add(at(4, 6), KALIMBA, 62)

add(at(5, 0), KALIMBA, 59)
add(at(5, 4), KALIMBA, 62)

add(at(6, 2), KALIMBA, 65)
add(at(6, 4), KALIMBA, 62)
add(at(6, 6), KALIMBA, 59)

add(at(7, 0), KALIMBA, 64)
add(at(7, 2), KALIMBA, 67)
add(at(7, 6), KALIMBA, 60)

add(at(8, 2), KALIMBA, 64)

add(at(9, 0), KOTO, 69)
add(at(9, 3), KOTO, 72)
add(at(9, 6), KOTO, 69)

add(at(10, 0), KOTO, 65)
add(at(10, 6), KOTO, 69)

add(at(11, 0), KOTO, 67)
add(at(11, 3), KOTO, 64)
add(at(11, 6), KOTO, 59)

add(at(12, 2), KOTO, 67)
add(at(12, 4), KOTO, 64)

add(at(13, 0), KOTO, 69)
add(at(13, 4), KOTO, 64)
add(at(13, 6), KOTO, 67)

add(at(14, 0), KOTO, 72)
add(at(14, 3), KOTO, 69)

add(at(15, 0), KOTO, 62)
add(at(15, 2), KOTO, 65)
add(at(15, 6), KOTO, 69)

add(at(16, 0), KOTO, 59)
add(at(16, 3), KOTO, 62)
add(at(16, 5), KOTO, 65)

add(at(10, 4), KALIMBA, 60)
add(at(14, 6), KALIMBA, 64)

add(at(17, 0), KALIMBA, 64)
add(at(17, 2), KALIMBA, 67)

add(at(18, 0), KALIMBA, 67)

add(at(19, 0), KALIMBA, 69)
add(at(19, 4), KALIMBA, 64)


add(at(21, 0), KALIMBA, 69)
add(at(21, 2), KALIMBA, 72)

add(at(22, 0), KALIMBA, 64)
add(at(22, 4), KALIMBA, 69)

add(at(23, 0), KALIMBA, 65)
add(at(23, 3), KALIMBA, 69)
add(at(23, 6), KALIMBA, 62)

add(at(25, 0), KALIMBA, 64)
add(at(25, 2), KALIMBA, 67)
add(at(25, 4), KALIMBA, 69)
add(at(25, 6), KALIMBA, 67)

add(at(26, 0), KALIMBA, 69)
add(at(26, 2), KALIMBA, 67)
add(at(26, 4), KALIMBA, 64)
add(at(26, 6), KALIMBA, 60)

add(at(27, 0), KOTO, 62)
add(at(27, 2), KOTO, 65)
add(at(27, 4), KOTO, 69)

add(at(28, 0), KALIMBA, 65)
add(at(28, 2), KALIMBA, 62)
add(at(28, 6), KALIMBA, 69)

add(at(29, 0), KOTO, 69)
add(at(29, 0), KALIMBA, 72)
add(at(29, 2), KALIMBA, 69)
add(at(29, 4), KALIMBA, 65)

add(at(30, 0), KALIMBA, 68)
add(at(30, 2), KALIMBA, 67)
add(at(30, 4), KALIMBA, 65)
add(at(30, 6), KALIMBA, 63)

add(at(31, 0), KOTO, 64)
add(at(31, 2), KOTO, 67)
add(at(31, 4), KOTO, 71)

add(at(32, 0), KALIMBA, 69)
add(at(32, 3), KALIMBA, 67)
add(at(32, 6), KALIMBA, 64)

add(at(8, 7),  HARP, 69) 
add(at(16, 7), HARP, 60) 
add(at(24, 7), HARP, 69) 
add(at(32, 7), HARP, 64) 

return {
    notes  = notes,
    length = TOTAL_FRAMES,
    bpm    = 120,
    title  = "Ninja Escondido",
}
