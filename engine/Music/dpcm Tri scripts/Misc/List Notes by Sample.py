import numpy as np
from scipy.fft import rfft, rfftfreq

# NES constants
CPU_CLOCK = 1789773  # NTSC NES CPU clock in Hz
CYCLES_PER_BIT = [
    428, 380, 340, 320, 286, 254, 226, 214,
    190, 160, 142, 128, 106, 85, 72, 54
]

# Reference for note A4
A4_FREQ = 430.5 #Alt Tuning for cheaper samples
NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

def bits_from_dmc_pattern(byte_count, num_waves):
    total_bits = byte_count * 8
    bits_per_wave = total_bits // num_waves
    up = bits_per_wave // 2
    down = bits_per_wave - up
    wave = [1] * up + [0] * down
    pattern = []
    for _ in range(num_waves):
        pattern.extend(wave)
    while len(pattern) < total_bits:
        pattern.append(0)
    return pattern

def generate_signal(bits, pitch_index, repeat=10):
    cycles_per_bit = CYCLES_PER_BIT[pitch_index]
    sample_rate = CPU_CLOCK / cycles_per_bit
    signal = np.array(bits * repeat, dtype=float)
    return signal, sample_rate

def analyze_frequency(signal, sample_rate):
    n = len(signal)
    yf = rfft(signal)
    xf = rfftfreq(n, 1 / sample_rate)
    amplitude = np.abs(yf)
    dominant_idx = np.argmax(amplitude[1:]) + 1
    return xf[dominant_idx]

def freq_to_note_info(freq):
    if freq <= 0:
        return None, 0, 0, 0
    n = 12 * np.log2(freq / A4_FREQ)
    nearest_note_num = int(round(n)) + 57
    cents_off = (n - round(n)) * 100
    octave = (nearest_note_num // 12) - 1
    note = NOTE_NAMES[nearest_note_num % 12]
    return note, octave, nearest_note_num, cents_off



def collect_notes(byte_wave_pairs):
    note_map = {}
    for byte_count, num_waves in byte_wave_pairs:
        bits = bits_from_dmc_pattern(byte_count, num_waves)
        for rate in range(16):
            signal, sample_rate = generate_signal(bits, rate, repeat=10)
            freq = analyze_frequency(signal, sample_rate)
            note, octave, midi_num, cents = freq_to_note_info(freq)
            if note is None:
                continue
            note_str = f"{note}{octave}"
            if note_str not in note_map:
                note_map[note_str] = {
                    "midi_num": midi_num,
                    "waves_cents": []
                }
            note_map[note_str]["waves_cents"].append((num_waves, cents))
    return note_map



def print_note_summary(note_map):
    # Map of MIDI number to note name, even if no wave data
    midi_to_note = {}
    for note_str, data in note_map.items():
        midi_to_note[data['midi_num']] = note_str

    # Determine range of MIDI notes to print
    midi_nums = [data['midi_num'] for data in note_map.values()]
    if not midi_nums:
        print("No notes to display.")
        return
    min_midi = min(midi_nums)
    max_midi = max(midi_nums)

    # Reverse lookup: MIDI number -> note_str (even if empty waves_cents)
    midi_to_note_str = {
        data["midi_num"]: note_str for note_str, data in note_map.items()
    }

    print(f"{'Note':>6} {'(NumWaves, Detune_cents)':>30}")
    print("-" * 40)
    for midi in range(max_midi, min_midi - 1, -1):
        note_str = midi_to_note_str.get(midi, f"MIDI{midi}")
        waves_cents = note_map.get(note_str, {}).get("waves_cents", [])
        if waves_cents:
            formatted = [(nw, round(float(c), 1)) for nw, c in waves_cents]
            print(f"{note_str:>6} {tuple(formatted)!r:>30}")
        else:
            print(f"{note_str:>6} {'None':>30}")






if __name__ == "__main__":

    print()

    #=== For 25% TriPulse ===
    byte_wave_pairs = (65,8), (17,2), (81,9) #, (65,8), (81,10)
        #(65,9) 7.22 :D2 and A2 Tunings are near-perfect. I get nothing else tho.

        #(65,8) 8.125 :D2 is.. OK. A2 is -38c. I do get a Good C3 and an OK E3 though.  For space concern, 65/8 Can share the first 17 bytes w/ 17/2. The distortion this causes is noticible however.
        #(81,10) 8.1 :Better tuned (65,8)

        #(65,6) Gives G0, A0 instead of filling A2,C3,E3. Still Fills D2
        #(97,9) Better Tuned 65,6. (Won't play as nice sharing data w/ 17-2)
            #ratio: 10.777

        # 7.22, 8.5, 9
            #The 8.5 and 9.0 Are both "Perfect" for the 25% 
    
            #byte_wave_pairs = (17,2),(81,9),(209,22),(81,8)
            #   ;209/22=9.5 for 8.5,9,9.5 All perfect Harmonics. All in Tune. 209/22 is +4 Cents
                    #Four Half-Steps can add 81-8 10.125. Imperfect harmoncis by only -6 cents.


    #=== For 12.5% TriPulse ===
    byte_wave_pairs = (129,8),(65,4)
    #byte_wave_pairs = (81,6), (65,4), (17,1),  #BEST FOR SMALL SPACE
            #13.5, 16.25, 17, 
            # To Fill: C0,D0 A0, G1, and A1 
                #(65,4), ;Just worse tuned 129,8. Its decent enough, and obvi fills all 5 (Though A1 is -38c.) -Can re-use 17-1's start and fit w/o any gaps.

                #(97,9), :Fills in the upper register a lil more. Tuning is Better. Leaves Holes at C0 and D0
                #(113,6) :Simular to 97,9. Tuning is sharp though, which works a bit as the holes its filling lean toward flat anyway.

            #81,6 Issue:
                #Ratio of 13.5 Causes noticably different tempre/volume profile. Thats fine for filler (Its less noticable than the data overlap of 65-8 and 17-2)
                    #However, as primary, it causes single steps to not really register correctly. 
                

                #3 Options:
                    # 1) Deal w/ it. Take tiny storage.
                        #I could use //9  1's bits. (A Duty cycle of 11.1%)
                            #Harmonics of 81-6 are perfect. 17-1 is close at 136/9= 15.111 1's
                            #Since the harmonics get quiet so fast, this may be "good enough" as it'll have all the right higher harmonics.

                            #Could also try a 13-14-13-14 alternating for the 13.5 May be audible though...

                    # 2) Upgrade 65-4 to 129-8.   byte_wave_pairs = (81,6), (129,8), (17,1)
                        # 16.125 is Perfect division between waves (129 bits each) and Close to Perfect 12.5% harmonics.
                            #16.125 - 13.5 have lots of Overlap. 13.5 Has bad harmonics. 16.125 is significantly worse tuning.
                            #I kinda end up picking between two bad options.

                    # 3) Also Replace 81-6 w/ 225-15.   byte_wave_pairs = (225,15),(129,8),(17,1)
                        # 15^2 = 225, so perfect harmonics. 
                        # However, 15 and 17 leave a lot of gaps for an only OK-tuned 129,8
                        
                        #(145,8) is interesting. OK Tuning. And it can fill the D2 Hole of the 25% (Though its probs noticably different)

        #=== Perfect Harmonics ===
    #byte_wave_pairs = (225,15),(129,8)#,(17,1)
    #     #Ratio 15, 16.125, 17
    #         #Tuning is decent, the 225,15 and 17,1 will both create perfect 12.5% waves, and the 129/8 never has a better tuning at any overlaps.
                    #Can easily halve the 129/8 to 65/4 if I want. 
    
            #Lower, Perfect Alternative
            # byte_wave_pairs = (17,1),(145,8),(209,11) Same bytes, but lower range. The 17,1 already hits the Tri's lower limit.
                #Ratio 17, 17.89, 19

    #byte_wave_pairs = (1290,80),(17,1),(145,8),(209,11)
    #byte_wave_pairs = (17,1),(129,8),(1450,80), (17,2),(81,9)#,(129,8)

    #byte_wave_pairs = (810,60), (1450,80), (170,10),(17,2),(81,9)


        #===Tinkering w/ Alternate Tunings===
    #byte_wave_pairs = (49,4),(65,5),(17,1)
        #Highly Tuned from E1-C3 (+5 Semitones.) -Means its Quieter, and a given note has a greater amount of Quantization Noise. (b/c its a slower dmc Rate to get the same note.)
            #Hole at G#2 (17-2 fills at +20c)       -However, its 32 Fewer Bytes. The 12.5% and 25% are also 100% Identical. (Meaning simpler lookups. And an octive lower litterally just means the other sample.)





    note_map = collect_notes(byte_wave_pairs)
    print_note_summary(note_map)
    print()
