import re
import os
import math
import utils.helpers as h
import heapq
from utils.voice_catalog import VoiceCatalog
from collections import defaultdict
from Step_2_Songs.extract_song import extract_pattern_data
from utils.riff_class import UNINIT, NO_DATA, RiffData, SongData
#Process_Song_Data , each Channel gets its own file.



def extract_header_data(song_raw_lines):
    
    def extract_duration_lengths(raw_lines):
        seen_durations = set()
        sfx_shortening = False

        for i, line in enumerate(raw_lines):
            try:
                if 'Note Time=' in line:
                    note_data = h.parse_note_line(line)
                    
                    note_duration = note_data.get("Duration")
                    if note_duration is not None:
                        pass  # proceed normally

                    elif "Volume" in note_data:
                        continue  # silently skip Volume Markers

                    else:
                        raise KeyError("Missing Volume")  # truly missing both keys
                    
                    is_slide_note = bool(note_data.get("SlideTarget", False))
                    if note_duration < 6 and is_slide_note:  # less than six is just to be lazy
                        sfx_shortening = True
                        continue

                    if not sfx_shortening:
                        if note_duration not in seen_durations:
                            seen_durations.add(note_duration)

                    sfx_shortening = False

                if 'Channel Type="Noise"' in line:
                    break  # Noise breaks this method.

                if 'Channel Type="DPCM"' in line:
                    break  # DPCM breaks this method.

            except Exception as e:
                print(f"Error Parsing Note Line: {line},  e:{e}")  
                continue


        if not seen_durations:
            raise ValueError("No valid durations found.")

        # For each duration, check how many of its multiples exist
        multiple_candidates = {}
        multiples_to_check = [2, 3, 4, 6, 8]

        for base in seen_durations:
            found = sum(1 for m in multiples_to_check if base * m in seen_durations)
            multiple_candidates[base] = found

        # Find the maximum number of matches
        max_matches = max(multiple_candidates.values())
        likely_bases = [k for k, v in multiple_candidates.items() if v == max_matches]

        # --- Select the most likely 8th-note length ---
        if len(likely_bases) == 1:
            len_8th = likely_bases[0]
            print(f"[INFO] Auto-detected base (8th) duration: {len_8th}")
        else:
            # Ambiguous results — ask user which one to pick
            print("\n[ASK] Multiple possible base durations detected:")
            for i, cand in enumerate(likely_bases, start=1):
                print(f"  {i}. {cand}")

            while True:
                try:
                    choice = int(input(f"Input the correct 8th-note length: "))
                    if choice not in likely_bases:
                        print(f"Proceeding with Custom BPM: {choice}")
                    len_8th = choice
                    break

                except ValueError:
                    print("Please enter a valid number.")

        # --- Derive 16th and special lengths from context ---
        len_16th = [len_8th // 2, (len_8th+1) // 2]
        len_special = []  # DEPRECIATE

        return len_8th, len_16th, len_special
    





    def build_duration_lookup(len_8th, len_16th, len_special):
        length_to_id = {}

        # Regular multiples of 8th
        allowed_multiples = [1, 2, 3, 4, 6, 8]
        for mul in allowed_multiples:
            val = mul * len_8th
            length_to_id[val] = mul

        # 16th notes (both map to ID 4)
        for val in len_16th:
            length_to_id[val] = 0

        # Special durations (triplets or singleton), map to ID 6
        # for val in len_special:
        #     length_to_id[val] = 6



        return length_to_id

    """
    Processes the raw lines of a single song's text and extracts header data.
    Auto-detects types where possible, but explicitly handles Groove as a list.
    """
    header_data = {}

    # Extract the raw lines from the dictionary
    raw_lines = song_raw_lines.get('raw_lines', [])
    if not raw_lines:
        raise ("Error: No 'raw_lines' found in song_raw_lines.")

    # Process the key-value header pairs)
    first_line = raw_lines[0].strip()

    parts = re.findall(r'(\w+)=("[^"]*"|\S+)', first_line)

    for key, value in parts:
        value = value.strip('"')
        if key == 'Name':
            header_data['Name'] = h.sanitize_song_name(value)
        elif key == 'Groove':
            # Special handling for Groove
            header_data['Groove'] = [int(x) for x in value.split('-')]

            if len(header_data['Groove']) > 2:
                print(f"[WARN] BPM groove needs integer 8th length. Timing may be de-synced")

        else:
            # Try to auto-convert to int if it looks like a number
            try:
                header_data[key] = int(value)
            except ValueError:
                header_data[key] = value

    len_8th, len_16th, len_special = extract_duration_lengths(raw_lines)
    length_to_id = build_duration_lookup(len_8th, len_16th, len_special)

    VoiceCatalog.length_to_nibble = length_to_id
    
    reverse = defaultdict(list)
    for dur, id_ in length_to_id.items():
        reverse[id_].append(dur)

    VoiceCatalog.nibble_to_length = dict(reverse)


    return header_data



"""
simplified to 
    seen_durations = set()

    for line in raw_lines:
        if 'Note Time=' in line:          
            note_data = h.parse_note_line(line)
            note_duration = note_data["Duration"]
            seen_durations.add(note_duration)
            

ok, now to do some validation. 
First, lets consolidate similar values

One of the values should be a common factor of all except for at most 3 values with these special rules:
-two may be, at most, 1 apart, and sum to the common factor (ie, if 9 is common, there can be 4,5. If 8, it can be 4,4)

-three, there 
"""


def get_famistudio_pattern_sequence(song_raw_lines, header_data, song_name, channel_name):
    """
    Extracts pattern numbers placed on the timeline for a specific channel from Famistudio song data.
    Returns a list of pattern numbers, with 0 for empty slots and -1 inserted at the loop point.
    """

    length = header_data['Length']
    loop_point = header_data.get('LoopPoint', None)
    raw_lines = song_raw_lines.get('raw_lines', [])

    # Find the start and end index of the target channel
    channel_start = None
    channel_end = len(raw_lines)

    for i, line in enumerate(raw_lines):
        if re.search(rf'Channel Type="{channel_name}"', line):
            channel_start = i
            # Find where the next channel begins
            for j in range(i + 1, len(raw_lines)):
                if re.search(r'Channel Type="', raw_lines[j]):
                    channel_end = j
                    break
            break

    if channel_start is None:
        print(f"Error [{song_name}]: Channel '{channel_name}' not found.")
        return None

    # Collect pattern instances within the current channel block
    pattern_lines = []
    for i in range(channel_start, channel_end):
        if 'PatternInstance' in raw_lines[i]:
            pattern_lines.append(raw_lines[i])

    # Map pattern lines to a time -> pattern number dict
    time_to_pattern = {}
    for line in pattern_lines:
        match = re.search(r'Time="(\d+)"\s+Pattern="Pattern (\d+)"', line)
        if match:
            time = int(match.group(1))
            pattern = int(match.group(2))
            time_to_pattern[time] = pattern

    # Build the timeline sequence
    pattern_sequence = []
    for t in range(length):
        if loop_point is not None and t == loop_point:
            pattern_sequence.append(-1)
        pattern_sequence.append(time_to_pattern.get(t, 0))

    return pattern_sequence



def create_song_header(header_data, song_name):
    
    nibble_map = VoiceCatalog.nibble_to_length
    eighth_note_len = nibble_map[0][0]

    # Retrieve special durations (nibble 6) — may not exist
    special_vals = nibble_map.get(6)

    if special_vals is None:
        #special_line = ";No Special Length"
        special_line = ".byte $00, $00, $00 ;No Special"
        file_size = 12 #9

    elif len(special_vals) == 1:
        special_line = f".byte {special_vals[0]}, {special_vals[0]}, {special_vals[0]} ;Special Length."
        file_size = 12

    elif len(special_vals) == 2:
        raise NotImplementedError (f"Triplets likely collapsed to 2 values. Needs to be reworked to ID the duplicate.")
    
    elif len(special_vals) == 3:
        special_line = f".byte {special_vals[0]}, {special_vals[1]}, {special_vals[2]} ;Special Lengths."
        file_size = 12
        print (f"[WARN] Order of Special Lengths likely not preserved.")

    else:
        raise ValueError (f"Too many special values {special_vals}")


    header_lines = []

    header_lines.extend([
    f"{song_name}_Data:",
    special_line,
    f".byte {eighth_note_len} ;8th",
    f"",
    f".word {song_name}_DPCM",
    f".word {song_name}_Noise - 1",
    f".word {song_name}_Triangle",
    f".word {song_name}_Square2",
    f".word {song_name}_Square1",
    ])


    return header_lines, file_size





#=== Section Main ===

def Create_Song_Data(song_raw_lines, song_name):

    channels = [
          'Square1',
          'Square2', 
          'Triangle', 
          'Noise', 
          'DPCM'
          ]


    channel_file_stats = []

    folder_path = os.path.join("Output_Files", song_name)
    header_data = extract_header_data(song_raw_lines)

    song_data = SongData(header_data, song_name)
    

    for channel_name in channels:
        channel_data = song_data.init_channel(channel_name)
        # Step 1: Get the pattern sequence for the current channel
        channel_sequence = get_famistudio_pattern_sequence(song_raw_lines, header_data, song_name, channel_name)
        
        # Step 2: Extract the pattern data and format it. (This Also does all the complex Riff/BP Handling.)
        output_lines, file_size = extract_pattern_data(channel_data, channel_sequence, header_data, song_raw_lines, channel_name)


        #Step 3: Write to Channel Specific file. 
        os.makedirs(folder_path, exist_ok=True)

        filename = f"{song_name}_{channel_name}.s"
        file_path = os.path.join(folder_path, filename)

        with open(file_path, "w", encoding="utf-8") as outfile:
            h.write_block(outfile, output_lines) 
        
            # Step 5: Track file size
        channel_file_stats.append({
            "Folder": f"{song_name}",
            "File": f"{song_name}_{channel_name}.s",
            "Size": file_size,
            "Can_Cross_Page": False,
        })


    
    header_lines, file_size = create_song_header(header_data, song_name) 

    header_filename = f"{song_name}_Header.s"
    header_path = os.path.join(folder_path, header_filename)

    with open(header_path, "w", encoding="utf-8") as header_file:
        h.write_block(header_file, header_lines)

    channel_file_stats.append({
        "Folder": f"{song_name}",
        "File": f"{song_name}_Header.s",
        "Size": file_size,
        "Can_Cross_Page": True,
    })

    return channel_file_stats


"""
Config Binning logic.

Make the Noise kick sfx
"""

