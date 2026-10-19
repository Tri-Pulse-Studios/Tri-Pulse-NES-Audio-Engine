"""

Used throughout the whole project

"""
import os

def write_block(outfile, block):
    """
    Writes a block of lines to the output file.
    """
    for line in block:
        outfile.write(line + '\n')

def write_w_overwrite_check(outfile, lines):

    if os.path.exists(outfile):
        response = input(f"File '{outfile}' exists. Overwrite? (y/n): ").strip().lower()
        if response != 'y':
            print("Aborted. File not overwritten.")
            return

    with open(outfile, 'w', encoding='utf-8') as f:
        for line in lines:
            f.write(line + '\n')

    print(f"File written: {outfile}")

    return



def closest_power_of_two_fraction(x):
    powers = [1 / (2 ** i) for i in range(1, 9)]  # 1/2 to 1/256
    return min(powers, key=lambda p: abs(p - x))

import re
def sanitize_song_name(name):
    name = name.replace(' ', '_')
    name = re.sub(r'[^A-Za-z0-9_]', '', name)
    return name

def parse_note_line(line):
    parts = re.findall(r'(\w+)=("[^"]*"|\S+)', line)
    note_data = {}
    for key, value in parts:
        value = value.strip('"')
        try:
            note_data[key] = int(value)
        except ValueError:
            note_data[key] = value

    if not all(k in note_data for k in ("Time", "Value", "Duration", "Instrument")):
        if "Volume" not in note_data:
            raise ValueError(f"Malformed Note from {line}")
    return note_data

def set_median(s):
    if not isinstance(s, set):
        raise TypeError(f"Expected a set, got {type(s).__name__}")
    if not s:
        return None

    sorted_vals = sorted(s)
    mid = len(sorted_vals) // 2
    return sorted_vals[mid]