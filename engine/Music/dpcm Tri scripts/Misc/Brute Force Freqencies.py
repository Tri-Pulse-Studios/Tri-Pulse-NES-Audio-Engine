import numpy as np
from scipy.fft import rfft, rfftfreq

# NES constants
CPU_CLOCK = 1789773  # NTSC NES CPU clock in Hz
CYCLES_PER_BIT = [
    428, 380, 340, 320, 286, 254, 226, 214,
    190, 160, 142, 128, 106, 85, 72, 54
]

# Reference for note A4
A4_FREQ = 440 #430.5   #431 is 37c flat of standard A440 Tuning. Makes 5_65 and 4_49 In Tune (with eachother.)
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






import itertools

def brute_force_score(note_map):
    midi_nums = [note_data['midi_num'] for note_data in note_map.values()]
    if not midi_nums:
        raise ValueError("Missing MIDI numbers")


    min_midi = min(midi_nums)


    all_cents = []
    for note_data in note_map.values():
        cents_list = [cents for _, cents in note_data['waves_cents']]

        all_cents.extend(cents_list)

    if not all_cents:
        raise ValueError("Missing cent deviations")


    all_cents.sort()
    median_cents = all_cents[len(all_cents) // 2]
    ratio = pair[0]/pair[1]


    binned = False
    if ratio == int(ratio) and abs(median_cents) <= 30 :
        _125_perfect_pairs.append((pair, min_midi, int(median_cents)))
        

    elif 2*ratio == int(2*ratio) and abs(median_cents) <= 30 :
        _250_perfect_pairs.append((pair, min_midi, int(median_cents)))

    elif 4*ratio == int(4*ratio) and abs(median_cents) <= 30 :
        _500_perfect_pairs.append((pair, min_midi, int(median_cents)))

    elif 8*ratio == int(8*ratio) and abs(median_cents) <= 30 :
        bitwise_perfect_pairs.append((pair, min_midi, int(median_cents))) 

    if 8*ratio == int(8*ratio) and abs(median_cents) <= 20: #12 :
        highly_tuned.append((pair, min_midi, int(median_cents))) 



    # if not binned:
    #     raise NotImplementedError


    # if 9 <= min_midi <= 30 and abs(median_cents) <= 30:
    #     good_pairs.append((pair, min_midi, int(median_cents)))
    # elif -5 <= min_midi <= 25 and median_cents <= 30:
    #     ok_pairs.append((pair, min_midi))
    # if min_midi in (22, 16,17) and abs(median_cents) <= 40:
    #     ok_pairs.append((pair, min_midi, int(median_cents)))

#=== ===


if __name__ == "__main__":
    target_bits = set(range(45, 156))  # Bits per subwave. equates to Lowest pitch of 9-30 MIDI


    all_pairs = []

    for sample_size in range(1, 20):
        byte_count = 16 * sample_size + 1
        bit_len = byte_count * 8

        for bits_per_wave in list(target_bits):  # Only test remaining targets
            if bit_len % bits_per_wave != 0:
                continue  # Must divide cleanly

            wave_count = bit_len // bits_per_wave
            all_pairs.append((byte_count, wave_count))
            target_bits.remove(bits_per_wave)  # No need to find this one again



    _125_perfect_pairs = []
    _250_perfect_pairs = []
    _500_perfect_pairs = []
    bitwise_perfect_pairs = []
    highly_tuned = []

    seen_bit_sizes = set()

    # Now test each pair
    for pair in all_pairs:
        bytes_len, wave_count = pair
        bit_len = bytes_len * 8
        if bit_len % wave_count != 0:
            continue  # skip if doesn't give an integer number of bits per subwave.
        


        bits_per_subwave = round(bit_len / wave_count, 6)  # <== NEW
        if bits_per_subwave in seen_bit_sizes:             # <== NEW
            continue                                        # <== NEW
        seen_bit_sizes.add(bits_per_subwave)   

        print (f"Crunching: {pair}")

        try:
            note_map = collect_notes((pair,))
            score = brute_force_score(note_map)
            if score:
                print(f"{score} | Pair: {pair}")
        except Exception as e:
            print(f"Error with pair {pair}: {e}")
            continue


    print()
    from collections import defaultdict

    # List of (label, list) tuples
    perfect_pair_sets = [
        ("12.5% Perfect", _125_perfect_pairs),
        ("25% Perfect", _250_perfect_pairs),
        ("50% Perfect", _500_perfect_pairs),
        ("Odd-Only Bitwise Perfect", bitwise_perfect_pairs),
        ("All_Highly_Tuned", highly_tuned),
    ]

    for label, pair_list in perfect_pair_sets:
        print(f"\n=== {label} pairs ===")

        # Group by min_midi (assumes it's the second element in the tuple)
        grouped = defaultdict(list)
        for pair in pair_list:
            grouped[pair[1]].append(pair)

        # Print in order of increasing min_midi
        for min_midi in sorted(grouped):
            for p in grouped[min_midi]:
                print(p)
            print()  # Blank line between groups


    print()
