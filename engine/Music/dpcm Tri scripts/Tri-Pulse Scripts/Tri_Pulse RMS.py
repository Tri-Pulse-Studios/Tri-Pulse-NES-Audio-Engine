import math
from collections import defaultdict

# ---------- Input Data ----------
group1 = {
    'B2': [9.5],
    'A#2': [2.4],
    'A2': [-25.5],
    'G#2': [-17.0, -4.2],
    'G2': [-5.2],
    'F#2': [3.3],
    'F2': [-11.8, -1.7],
    'E2': [-3.3],
    'D#2': [-7.6],
    'D2': [-9.3, -2.1],
    'C#2': [-0.8],
    'C2': [-15.3, -4.3],
    'B1': [-6.7, -9.7],
    'A#1': [-1.2, -9.7],
    'A1': [-11.9],
    'G#1': [-3.4, -4.2],
    'G1': [-17.3, -9.2],
    'F#1': [-8.8],
    'F1': [-11.8, -1.7],
    'E1': [-3.3, -16.8],
    'D#1': [-8.2, -7.6],
    'D1': [-9.3],
    'C#1': [-0.8],
    'C1': [-15.3],
}

group2 = {
    'B3': [9.5],
    'A#3': [10.6],
    'A3': [-38.9],
    'G#3': [-17.0],
    'G3': [-18.6, -15.9],
    'F#3': [3.3],
    'F3': [-25.2, 4.4],
    'E3': [-3.3],
    'D#3': [-2.2],
    'D3': [-22.7],
    'C#3': [-0.8],
    'C3': [-28.6, 0.2],
    'B2': [-23.1, -6.7],
    'A#2': [-1.2, -5.7],
    'A2': [-25.3, -0.1],
    'G#2': [-3.4],
    'G2': [-30.7, -2.3],
    'F#2': [-8.8],
    'F2': [-25.2, -7.8],
    'E2': [-30.1, -3.3],
    'D#2': [-8.2, -2.2],
    'D2': [-22.7, -7.2],
    'C#2': [-0.8],
    'C2': [-28.6, 0.2],

}

# ---------- Helper Functions ----------

def rms(values):
    n = len(values)
    return math.sqrt(sum(v**2 for v in values) / n) if n else 0

def average(values):
    n = len(values)
    return sum(values) / n if n else 0

def octave_from_note(note):
    for c in '0123456789':
        if c in note:
            return int(c)
    return 0

def best_detune(detunes):
    """Pick the value closest to 0."""
    return min(detunes, key=lambda x: abs(x))

# ---------- Compute RMS and Mean per Octave ----------

def rms_and_mean_per_octave_best(group):
    octaves = defaultdict(list)
    for note, detunes in group.items():
        oct_index = octave_from_note(note)
        octaves[oct_index].append(best_detune(detunes))
    
    stats_oct = {}
    for oct_index, detunes in octaves.items():
        stats_oct[oct_index] = {
            'RMS': rms(detunes),
            'Mean': average(detunes)
        }
    return stats_oct

# ---------- Compute RMS and Mean for entire group ----------

def rms_and_mean_group_best(group):
    best_detunes = [best_detune(detunes) for detunes in group.values()]
    return rms(best_detunes), average(best_detunes)

# ---------- Run Analysis for Both Groups ----------

for i, group in enumerate([group1, group2], start=1):
    oct_stats = rms_and_mean_per_octave_best(group)
    rms_g, mean_g = rms_and_mean_group_best(group)
    
    print(f"\nGroup {i} Per Octave Statistics (best detune per note):")
    for oct_index in sorted(oct_stats.keys()):
        print(f" Octave {oct_index}: RMS = {oct_stats[oct_index]['RMS']:.2f} cents, "
              f"Mean = {oct_stats[oct_index]['Mean']:.2f} cents")
    
    print(f"\nOverall Group {i}: RMS = {rms_g:.2f} cents, Mean = {mean_g:.2f} cents")
