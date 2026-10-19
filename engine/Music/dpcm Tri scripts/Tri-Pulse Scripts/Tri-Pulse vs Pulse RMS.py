import math
from collections import OrderedDict

# ----------------- Constants -----------------
CPU = 1789773  # NTSC NES CPU
BYTES = "$F7, $83, $17, $B2, $52, $F5, $A1, $51, $01, $B8, $74, $34"
FREQ_REF = 55.0  # A1 reference

NOTE_TO_SEMITONE = {'C':0,'C#':1,'D':2,'D#':3,'E':4,'F':5,'F#':6,'G':7,'G#':8,'A':9,'A#':10,'B':11}

group1 = {
    'B1': [-6.7, -9.7], 'C1': [-15.3], 'C#1': [-0.8], 'D1': [-9.3], 'D#1': [-8.2, -7.6],
    'E1': [-3.3, -16.8], 'F1': [-11.8, -1.7], 'F#1': [-8.8], 'G1': [-17.3, -9.2], 'G#1': [-3.4, -4.2],
    'A1': [-11.9], 'A#1': [-1.2, -9.7], 'B2': [9.5], 'C2': [-15.3, -4.3], 'C#2': [-0.8],
    'D2': [-9.3, -2.1], 'D#2': [-7.6], 'E2': [-3.3], 'F2': [-11.8, -1.7], 'F#2': [3.3],
    'G2': [-5.2], 'G#2': [-17.0, -4.2], 'A2': [-25.5], 'A#2': [2.4],
}

group2 = {
    'B2': [-23.1, -6.7], 'C2': [-28.6, 0.2], 'C#2': [-0.8], 'D2': [-22.7, -7.2], 'D#2': [-8.2, -2.2],
    'E2': [-30.1, -3.3], 'F2': [-25.2, -7.8], 'F#2': [-8.8], 'G2': [-30.7, -2.3], 'G#2': [-3.4],
    'A2': [-25.3, -0.1], 'A#2': [-1.2, -5.7], 'B3': [9.5], 'C3': [-28.6, 0.2], 'C#3': [-0.8],
    'D3': [-22.7], 'D#3': [-2.2], 'E3': [-3.3], 'F3': [-25.2, 4.4], 'F#3': [3.3],
    'G3': [-18.6, -15.9], 'G#3': [-17.0], 'A3': [-38.9], 'A#3': [10.6]
}

# ----------------- Helpers -----------------
def best_detune(detunes):
    return min(detunes, key=lambda x: abs(x))

def note_to_midi(note):
    octave = int(note[-1])
    name = note[:-1]
    return (octave + 1) * 12 + NOTE_TO_SEMITONE[name]

def midi_to_freq(midi):
    return 440.0 * 2 ** ((midi - 69)/12)

def cents_to_ratio(cents):
    return 2 ** (cents/1200)

def reconstruct_period(byte):
    L = (byte >> 2) & 0x3F
    H = byte & 0x03
    return (1 << 10) | (H << 8) | (L << 2) | H

def expand_octave(period, octave_shift):
    return period >> octave_shift

def period_to_freq(period):
    return CPU / (16 * (period + 1))

def hz_to_semitone_index(freq):
    cents = 1200 * math.log2(freq / FREQ_REF)
    return round(cents / 100)

def sort_table_by_index(table):
    return OrderedDict(sorted(table.items(), key=lambda x: x[0]))

# ----------------- Build Tables -----------------
def build_pulse_table(pulse_bytes_str, num_octaves=5):
    pulse_bytes = [int(b.strip().replace("$",""),16) for b in pulse_bytes_str.split(",") if b.strip()]
    table = {}
    for octave in range(num_octaves):
        for byte in pulse_bytes:
            period = expand_octave(reconstruct_period(byte), octave)
            freq = period_to_freq(period)
            idx = hz_to_semitone_index(freq)
            table[idx] = freq
    return sort_table_by_index(table)

def build_group_table(group):
    table = {}
    for note, detunes in group.items():
        best = best_detune(detunes)
        freq = midi_to_freq(note_to_midi(note)) * cents_to_ratio(best)
        idx = hz_to_semitone_index(freq)
        table[idx] = freq
    return sort_table_by_index(table)

def compute_per_octave_stats(table):
    """
    Per octave:
      - RMS = detuning of intervals (100c per semitone)
      - Mean = average cents offset vs A=440 reference
    """
    octaves = {}
    for idx, freq in table.items():
        octave = idx // 12
        if octave not in octaves:
            octaves[octave] = {}
        octaves[octave][idx] = freq

    stats_per_octave = {}
    for octv, freqs_dict in octaves.items():
        sorted_indices = sorted(freqs_dict.keys())
        cents_errors = []

        for i in range(len(sorted_indices)):
            idx_i = sorted_indices[i]
            freq_i = freqs_dict[idx_i]
            for j in range(i+1, len(sorted_indices)):
                idx_j = sorted_indices[j]
                freq_j = freqs_dict[idx_j]
                semitone_diff = idx_j - idx_i
                actual_cents = 1200 * math.log2(freq_j / freq_i)
                expected_cents = 100 * semitone_diff
                error = actual_cents - expected_cents
                cents_errors.append(error)

        # RMS of interval errors
        rms = math.sqrt(sum(e**2 for e in cents_errors)/len(cents_errors)) if cents_errors else 0

        # Mean vs ideal A=440 tuning
        mean_errors = []
        for idx, freq in freqs_dict.items():
            ideal_freq = 440.0 * 2 ** ((idx - 36)/12)
            mean_errors.append(1200 * math.log2(freq / ideal_freq))
        mean = sum(mean_errors)/len(mean_errors) if mean_errors else 0

        stats_per_octave[octv] = {'RMS': rms, 'Mean': mean}

    return stats_per_octave




def compare_pulse_to_group_rms_all(pulse_table, group_table):
    """
    Compare Pulse table to Group table per octave and overall.
    - For each octave: compute RMS of deviations (100c per semitone interval)
    - Overall: compute RMS across all notes
    Returns:
        rms_per_octave: dict {octave: RMS}
        rms_overall: float
    """
    # Group notes by octave
    pulse_octaves = {}
    for idx, freq in pulse_table.items():
        octv = idx // 12
        if octv not in pulse_octaves:
            pulse_octaves[octv] = {}
        pulse_octaves[octv][idx] = freq

    group_octaves = {}
    for idx, freq in group_table.items():
        octv = idx // 12
        if octv not in group_octaves:
            group_octaves[octv] = {}
        group_octaves[octv][idx] = freq

    rms_per_octave = {}
    all_errors = []

    for octv in pulse_octaves.keys():
        if octv not in group_octaves:
            continue  # skip octaves not in group

        pulse_freqs = pulse_octaves[octv]
        group_freqs = group_octaves[octv]

        # sorted indices
        pulse_indices = sorted(pulse_freqs.keys())
        group_indices = sorted(group_freqs.keys())

        cents_errors = []

        for i in range(len(pulse_indices)):
            idx_i = pulse_indices[i]
            freq_i = pulse_freqs[idx_i]

            for j in range(len(group_indices)):
                idx_j = group_indices[j]
                freq_j = group_freqs[idx_j]

                semitone_diff = idx_j - idx_i
                actual_cents = 1200 * math.log2(freq_j / freq_i)
                expected_cents = 100 * semitone_diff
                error = actual_cents - expected_cents
                cents_errors.append(error)
                all_errors.append(error)

        rms = math.sqrt(sum(e**2 for e in cents_errors)/len(cents_errors)) if cents_errors else 0
        rms_per_octave[octv] = rms

    rms_overall = math.sqrt(sum(e**2 for e in all_errors)/len(all_errors)) if all_errors else 0

    return rms_per_octave, rms_overall



# ----------------- Main -----------------
def main():
    pulse_table = build_pulse_table(BYTES)
    group1_table = build_group_table(group1)
    group2_table = build_group_table(group2)

    pulse_stats = compute_per_octave_stats(pulse_table)
    group1_stats = compute_per_octave_stats(group1_table)
    group2_stats = compute_per_octave_stats(group2_table)

    print("Pulse Table per-Octave Stats:")
    for octv, stats in pulse_stats.items():
        print(f" Octave {octv}: RMS={stats['RMS']:.2f}c, Mean={stats['Mean']:.2f}c")

    print("\nGroup1 per-Octave Stats:")
    for octv, stats in group1_stats.items():
        print(f" Octave {octv}: RMS={stats['RMS']:.2f}c, Mean={stats['Mean']:.2f}c")

    print("\nGroup2 per-Octave Stats:")
    for octv, stats in group2_stats.items():
        print(f" Octave {octv}: RMS={stats['RMS']:.2f}c, Mean={stats['Mean']:.2f}c")


    pulse_vs_group1_rms_oct, pulse_vs_group1_rms_all = compare_pulse_to_group_rms_all(pulse_table, group1_table)
    pulse_vs_group2_rms_oct, pulse_vs_group2_rms_all = compare_pulse_to_group_rms_all(pulse_table, group2_table)

    print("\nPulse vs Group1 RMS per Octave:")
    for octv, rms in pulse_vs_group1_rms_oct.items():
        print(f" Octave {octv}: RMS={rms:.2f}c")
    print(f"All : RMS={pulse_vs_group1_rms_all:.2f}c")

    print("\nPulse vs Group2 RMS per Octave:")
    for octv, rms in pulse_vs_group2_rms_oct.items():
        print(f" Octave {octv}: RMS={rms:.2f}c")
    print(f"All : RMS={pulse_vs_group2_rms_all:.2f}c")

    print()

if __name__ == "__main__":
    main()
