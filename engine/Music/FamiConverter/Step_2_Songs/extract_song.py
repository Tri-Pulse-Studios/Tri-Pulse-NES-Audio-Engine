from utils.voice_catalog import VoiceCatalog
from Step_2_Songs.format_song import Format_Pattern_Main_Block
import re
import string
from collections import defaultdict
from typing import List, Dict, Tuple
from utils import helpers as h

 
def get_raw_data(song_raw_lines, header_data, channel_name):
    """
    Retrieves raw line data, note length, total expected time, and
    pattern locations for a specific channel from the song file.
    """

    raw_lines = song_raw_lines.get('raw_lines', [])
    if not raw_lines:
        raise ("Error: No 'raw_lines' found in song_raw_lines.")


    total_expected_time = header_data['NoteLength'] * header_data['PatternLength']
    patterns_in_channel = {}

    inside_channel = False
    for idx, line in enumerate(raw_lines):
        if f'Channel Type="{channel_name}"' in line:
            inside_channel = True
            continue
        if inside_channel and 'Channel Type="' in line and channel_name not in line:
            break
        if inside_channel and 'Pattern Name=' in line:
            parts = line.split('"')
            pattern_num = int(parts[1].replace('Pattern ', ''))
            patterns_in_channel[pattern_num] = idx

    return raw_lines, total_expected_time, patterns_in_channel


def mark_repeated_patterns(channel_sequence, patterns_in_channel, song_raw_lines):
 
        #This works great, but Stands things like (A,1,A,2) x2 patterns. If speed becomes an issue, this may be needed.
    def find_maximal_repeats(channel_sequence: List[int]) -> Dict[str, List[int]]:
        from collections import defaultdict
        import string

        #==============================
        # Map non-int items to unique ints
        #==============================
        sanitized = []
        mapping = {}  # original -> sanitized int
        unique_counter = max([x for x in channel_sequence if isinstance(x,int)] + [0]) + 1

        for x in channel_sequence:
            if isinstance(x, int):
                sanitized.append(x)
            else:
                # Use the id() of x if it's a dict, tuple, str, etc.
                key = x if isinstance(x, str) else id(x)
                if key not in mapping:
                    mapping[key] = unique_counter
                    unique_counter += 1
                sanitized.append(mapping[key])

        #==============================
        # Standard Suffix Array + LCP
        #==============================
        def build_suffix_array(seq: List[int]) -> List[int]:
            return sorted(range(len(seq)), key=lambda i: seq[i:])

        def build_lcp_array(seq: List[int], sa: List[int]) -> List[int]:
            n = len(seq)
            rank = [0]*n
            for i, idx in enumerate(sa):
                rank[idx] = i
            lcp = [0]*(n-1)
            h = 0
            for i in range(n):
                if rank[i] > 0:
                    j = sa[rank[i]-1]
                    while i+h<n and j+h<n and seq[i+h]==seq[j+h]:
                        h += 1
                    lcp[rank[i]-1] = h
                    if h > 0: h -= 1
            return lcp

        def find_repeated_subsequences(seq: List[int], sa: List[int], lcp: List[int]) -> List[Tuple[Tuple[int,...], List[int]]]:
            subseq_occurrences = defaultdict(list)
            for i, l in enumerate(lcp):
                if l == 0:
                    continue
                substr = tuple(seq[sa[i]:sa[i]+l])
                subseq_occurrences[substr].append(sa[i])
                subseq_occurrences[substr].append(sa[i+1])

            results = []
            for subseq, indices in subseq_occurrences.items():
                indices = sorted(set(indices))
                occurrences = []
                length = len(subseq)
                claimed = set()
                for idx in indices:
                    if all((idx+offset) not in claimed for offset in range(length)):
                        occurrences.append(idx)
                        claimed.update(range(idx, idx+length))
                if len(occurrences) >= 2:
                    results.append((subseq, occurrences))
            return results

        sa = build_suffix_array(sanitized)
        lcp = build_lcp_array(sanitized, sa)
        repeated_subseqs = find_repeated_subsequences(sanitized, sa, lcp)

        #==============================
        # Greedy selection: longest first
        #==============================
        repeated_subseqs.sort(key=lambda x: (-len(x[0]), x[1]))
        claimed_positions = set()
        compressed_patterns = {}
        letter_iter = iter(string.ascii_uppercase)

        for subseq, positions in repeated_subseqs:
            length = len(subseq)
            usable_positions = []
            for pos in positions:
                if all((pos+offset) not in claimed_positions for offset in range(length)):
                    usable_positions.append(pos)
            if len(usable_positions) >= 2:
                letter = next(letter_iter)
                # Restore original items from mapping if needed
                original_subseq = [k if isinstance(k,int) else list(mapping.keys())[list(mapping.values()).index(k)]
                                for k in subseq]
                compressed_patterns[letter] = original_subseq
                for pos in usable_positions:
                    claimed_positions.update(range(pos, pos+length))

        return compressed_patterns

    def analyze_maximal_repeats(compressed_patterns: Dict[str, List[int]]) -> Dict[str, List[int]]:
        subriff_patterns = {}
        used_names = set(compressed_patterns.keys())
        subriff_letter_iter = iter([a + a for a in string.ascii_lowercase])

        # Track claimed index ranges per riff
        claimed_indices = {name: set() for name in compressed_patterns}

        # Step 1: Collect all candidate substrings of raw ints only
        subseq_occurrences = defaultdict(list)

        for riff_name, riff in compressed_patterns.items():
            min_len = 1
            max_len = 100000 #Debugging. Can tinker w/ these, but making the max len less than maximal really doesn't help it seems.
            for length in range(min_len, min(max_len, len(riff)) + 1):
                for i in range(len(riff) - length + 1):
                    window = riff[i:i + length]
                    if all(isinstance(x, int) for x in window):
                        subseq_occurrences[tuple(window)].append((riff_name, i))

        # Step 2: Filter for multi-riff occurrences
        multi_riff_subseqs = {
            subseq: locs
            for subseq, locs in subseq_occurrences.items()
            if len(set(name for name, _ in locs)) >= 2
        }

        # Step 3: Greedily apply longest subriffs first, non-overlapping
        sorted_subseqs = sorted(multi_riff_subseqs.items(), key=lambda x: -len(x[0]))

        for subseq, locations in sorted_subseqs:
            length = len(subseq)
            valid_locations = []

            for riff_name, start_idx in locations:
                claimed = claimed_indices[riff_name]
                if all((start_idx + offset) not in claimed for offset in range(length)):
                    valid_locations.append((riff_name, start_idx))

            if len(valid_locations) >= 2:
                # Reserve a name
                name = next(subriff_letter_iter)
                while name in used_names:
                    name = next(subriff_letter_iter)
                used_names.add(name)

                # Apply substitution and mark claims
                for riff_name, start_idx in valid_locations:
                    riff = compressed_patterns[riff_name]
                    if riff[start_idx:start_idx + length] == list(subseq):
                        compressed_patterns[riff_name] = (
                            riff[:start_idx] + [name] + riff[start_idx + length:]
                        )
                        claimed_indices[riff_name].update(range(start_idx, start_idx + length))

                subriff_patterns[name] = list(subseq)

        compressed_patterns.update(subriff_patterns)
        return compressed_patterns

    def list_repetitions(channel_sequence):
        index_map = defaultdict(list)
        mapping = {}  # non-int -> unique int
        unique_counter = max([x for x in channel_sequence if isinstance(x, int)] + [0]) + 100

        for idx, value in enumerate(channel_sequence):
            if value == 0 or value == -1:
                continue  # Skip ignored markers if needed

            # convert non-int (dict, etc) to a unique hashable key
            key = value if isinstance(value, int) else id(value)

            if key not in mapping:
                mapping[key] = unique_counter
                unique_counter += 1

            index_map[mapping[key]].append(idx)

        repeated_patterns = {
            key: indices for key, indices in index_map.items() if len(indices) > 1
        }
        return repeated_patterns

    def analyze_repetitions(repeated_patterns):
        # Step 4: Sort each group by the first occurrence index
        group_by_count = defaultdict(list)
        for val, indices in repeated_patterns.items():
            group_by_count[len(indices)].append((val, indices))

        for count in group_by_count:
            group_by_count[count].sort(key=lambda x: x[1][0])  # sort by first idx in list

        compressed_patterns = {}  # Letter -> sequence list
        used_patterns = set()
        next_letter = iter(string.ascii_uppercase)

        for count, group in sorted(group_by_count.items()):
            i = 0
            while i < len(group):
                val, indices = group[i]
                if val in used_patterns:
                    i += 1
                    continue

                # Try building a candidate sequence starting at val
                sequence = []
                pos = indices[0]  # first occurrence of this value
                current_idx = pos
                seen_vals = []

                while current_idx < len(channel_sequence):
                    next_val = channel_sequence[current_idx]
                    next_val_count = len(repeated_patterns.get(next_val, [1]))


                    if (
                        next_val not in used_patterns
                        and next_val not in seen_vals
                        and next_val in repeated_patterns
                        and next_val_count == count
                    ):
                        
                        sequence.append(next_val)
                        current_idx += 1
                        seen_vals.append(next_val)

                    else:
                        break


                # Check if every position group starts with this sequence
                candidate_positions = [repeated_patterns[v] for v in sequence]
                candidate_slices = []
                try:
                    for positions in zip(*candidate_positions):
                        slice_vals = [channel_sequence[pos] for pos in positions]
                        candidate_slices.append(slice_vals)
                except IndexError:
                    # Skip if any sequence is incomplete
                    i += 1
                    continue

                min_len = min(len(s) for s in candidate_slices)
                match_sequence = sequence[:min_len]

                if all(slice[:min_len] == match_sequence for slice in candidate_slices):
                    # Assign a letter to this sequence
                    letter = next(next_letter)
                    compressed_patterns[letter] = match_sequence

                    # Mark used pattern IDs
                    used_patterns.update(match_sequence)

                    # Remove those from the group
                    group = [g for g in group if g[0] not in used_patterns]

                    # Restart the scan of the modified group
                    i = 0
                else:
                    i += 1
        # Next: use this index_map to find repeating sequences...
        return compressed_patterns



    def find_back_to_back_repeats(seq: List[int]) -> Dict[str, List[int]]:
        n = len(seq)
        claimed = set()
        patterns = {}
        letter_iter = iter(string.ascii_uppercase)

        first_index_map = {}  # Letter -> starting index of first occurrence

        i = 0
        while i < n:
            if i in claimed:
                i += 1
                continue

            max_repeat = None
            max_len = 0

            for k in range(1, (n - i) // 2 + 1):
                block = tuple(seq[i:i+k])
                next_block = tuple(seq[i+k:i+2*k])
                if block == next_block:
                    # Check how far it repeats
                    repeat_count = 2
                    while seq[i+(repeat_count)*k : i+(repeat_count+1)*k] == list(block):
                        repeat_count += 1
                    total_len = repeat_count * k
                    if total_len > max_len:
                        max_len = total_len
                        max_repeat = block

            if max_repeat:
                letter = next(letter_iter)
                patterns[letter] = list(max_repeat)
                first_index_map[letter] = i 
                claimed.update(range(i, i + max_len))
                i += max_len  # Skip the whole block
            else:
                i += 1

        return patterns, first_index_map


    def expand_compressed_sequence(marked_sequence, compressed_patterns):
        expanded = []
        for item in marked_sequence:
            if isinstance(item, int) or item == -1:
                expanded.append(item)
            elif isinstance(item, str) and item in compressed_patterns:
                real_entries = compressed_patterns[item]
                expanded.extend(real_entries)
            else:
                raise ValueError(f"Unknown item in marked_sequence: {item}")
        return expanded


    def mark_repetitions(channel_sequence):
        i = 0
        marked_sequence = []
        pattern_lengths = sorted({len(p) for p in compressed_patterns.values()}, reverse=True)
        used_once = set()

        while i < len(channel_sequence):
            matched = False
            for length in pattern_lengths:
                if i + length > len(channel_sequence):
                    continue
                subseq = channel_sequence[i:i+length]
                for letter, pattern in compressed_patterns.items():
                    if subseq == pattern:
                        # Count how many times it repeats back-to-back
                        repeat_count = 1
                        while (i + (repeat_count + 1) * length) <= len(channel_sequence) and \
                            channel_sequence[i + repeat_count * length: i + (repeat_count + 1) * length] == pattern:
                            repeat_count += 1

                        if letter not in used_once:
                            # First instance: Write the Raw Letter once, which counts as a "repeat"
                            marked_sequence.append(letter)
                            used_once.add(letter)
                            if repeat_count > 1: #First Time, One "repeat" is just written out, no repeats.
                                marked_sequence.append({letter: {'repeats': repeat_count - 2, 'first_repeat': True}})

                        else:
                            marked_sequence.append({letter: {'repeats': repeat_count - 1, 'first_repeat': False}})

                        i += repeat_count * length
                        matched = True
                        break
                if matched:
                    break
            if not matched:
                marked_sequence.append(channel_sequence[i])
                i += 1

        real_entries = [item for item in marked_sequence if not isinstance(item, dict) and item != -1]

        # If there's exactly one real entry, return a simplified list: [-1, entry] or [entry]
        if len(real_entries) == 1:
            marked_sequence = [item for item in marked_sequence if not isinstance(item, dict)]
            marked_sequence = expand_compressed_sequence(marked_sequence, compressed_patterns)

        if all(item in (-1, 0) for item in marked_sequence):
            marked_sequence = [] #Return Empty Channel

        return marked_sequence
    


    def trim_loop(channel_sequence: List[int]) -> List[int]:
        if -1 not in channel_sequence:
            return channel_sequence.copy()

        loop_idx = channel_sequence.index(-1)
        before = channel_sequence[:loop_idx]
        after = channel_sequence[loop_idx+1:]

        # Find matching trailing elements between 'before' and 'after'
        match_len = 0
        while match_len < len(before) and match_len < len(after):
            if before[-(match_len + 1)] != after[-(match_len + 1)]:
                break
            match_len += 1

        if match_len > 0:
            # Move -1 before the repeated segment
            trimmed = before[:-match_len] + [-1] + before[-match_len:] + after[:-match_len]
        else:
            trimmed = channel_sequence.copy()

        return trimmed
    
    def verify_patterns(compressed_patterns):

        compressed_patterns = {  #Delete all 0s  patterns.
        k: v for k, v in compressed_patterns.items()
        if any(x != 0 for x in v)
        }

        # Step 2: Filter based on total raw entries across all pattern instances
        raw_lines = song_raw_lines.get('raw_lines', [])
        if not raw_lines:
            raise ValueError("Error: 'raw_lines' missing in song_raw_lines.")

        filtered_patterns = {}

        for letter, pattern_numbers in compressed_patterns.items():
            # 1. Remove patterns that are all zeros
            if all(x == 0 for x in pattern_numbers):
                continue

            total_entries = 0

            # 2. Count note entries across all occurrences of this pattern
            for pat_num in pattern_numbers:
                if pat_num not in patterns_in_channel:
                    continue  # safety check
                start_idx = patterns_in_channel[pat_num]
                idx = start_idx + 1  # skip the Pattern Name line itself

                while idx < len(raw_lines):
                    line = raw_lines[idx].strip()
                    if line.startswith("Pattern"):  # stop at next pattern
                        break
                    if line.startswith("Note"):
                        total_entries += 1
                    else:
                        print(f"[WARN] Unverified Line type.")

                    idx += 1

            # 3. Keep only if there are 3 or more note entries
            if total_entries >= 3:
                filtered_patterns[letter] = pattern_numbers

        return filtered_patterns

    
    #=== Major Main===
    trimmed_channel_seqence = trim_loop(channel_sequence)

        #Version 1:
    # repeated_patterns = list_repetitions()
    # compressed_patterns = analyze_repetitions()
    # analyzed_patterns = analyze_maximal_repeats(compressed_patterns)
    # compressed_patterns = analyzed_patterns #Allow Sub-Riffs of letter riffs. Doesn't seem to help.

    # compressed_patterns = {
    # k: v for k, v in compressed_patterns.items()
    # if any(x != 0 for x in v)
    # }
    # marked_sequence = mark_repetitions()


        #Version 2:
    compressed_patterns, compressed_pattern_starts = find_back_to_back_repeats(trimmed_channel_seqence)

    compressed_patterns = verify_patterns(compressed_patterns)
    


    marked_sequence = mark_repetitions(trimmed_channel_seqence)


    return marked_sequence, compressed_patterns, compressed_pattern_starts




    compressed_patterns: Dict[str, List[int]]






def extract_notes_dicts(channel_sequence, compressed_patterns, patterns_in_channel, song_name, raw_lines, total_expected_time, channel_name):

    def insert_string(string):
        inserts = []
        inserts.append({
            "type": "string",
            "string": string
        })
        return inserts
    
    def insert_repeat_directive(entry):
        key = list(entry.keys())[0]
        info = entry[key]
        return [{
            "type": "repeat",
            "id": key,
            "count": info["repeats"],
            "first_instance": info.get("first_repeat", True)
        }]

    def insert_full_measure_rest():
        inserts = []
        pattern_str = f"{previous_pattern_num}-None" 

        rest_duration = total_expected_time

        sorted_lengths = sorted(VoiceCatalog.length_to_nibble.keys(), reverse=True)


        if rest_duration in sorted_lengths:
            length = sorted_lengths.index(rest_duration)
        else: 
            length = rest_duration
    
        opcode = get_opcode(rest_duration)

        inserts.append({
            "type": "rest",
            "ptr": pattern_str,
            "length": opcode  
        })
        rest_duration -= length

        return inserts


    def pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num):
       
        def handle_end_of_comrpessed_pattern():
            def insert_change_env():
                inserts = []
                pattern_str = f"{pattern_num}-0" #ie, 1-2 for 1st pattern, 2nd note.
                
                try:
                    Env_Change_pointer = VoiceCatalog.env_name_to_pointer[pattern_start_env]
                except KeyError:
                    Env_Change_pointer = "Unidentified"
                
                inserts.append({

                    "type": "Env_Change",
                    "ptr": pattern_str,  # Now it's a string like "1-2"
                    "new_env_pointer": Env_Change_pointer,
                    "new_env_name": pattern_start_env
                    
                })

                return inserts
            
            nonlocal end_of_compressed_pattern
            nonlocal current_env
            #nonlocal pattern_start_env

            idx = patterns_in_channel.get(previous_pattern_num, None)
            if idx is None:
                raise ValueError (f"Assumed {song_name} has empty channel. Should not enter this section at all.")
                #That, or it expects to find a previous pattern when processing the first.
                
            idx += 1
            # Skip 'Pattern Name=' line
            while idx < len(raw_lines):
                line = raw_lines[idx]

                if 'Note Time=' in line:
                    note_data = h.parse_note_line(line)
                    pattern_start_env = note_data["Instrument"]

                    note_duration = note_data.get("Duration")
                    if note_duration is not None:
                        pass  # proceed normally
                    elif "Volume" in note_data:
                        continue  # silently skip if only Duration missing
                    else:
                        raise KeyError("Missing Volume")  # truly missing both keys



                    is_slide_note = bool(note_data.get("SlideTarget", False))

                    if note_duration <= 5 and is_slide_note:
                        idx += 1
                        continue #The Tri Thumps don't count.

                    if  current_env != pattern_start_env:
                        current_env = pattern_start_env
                        all_notes_data.extend(insert_change_env())

                    break  # Found first note; stop

                elif "Pattern Name=" in line:
                    break  # End early if another pattern appears

                else:
                    print(f"Warning '{song_name}' has unexpected txt format w/ line '{line}'.")



            all_notes_data.extend(insert_string(f"; end @_{end_of_compressed_pattern}"))
            end_of_compressed_pattern = None
            return


    
        def handle_pattern_end_gap():
            nonlocal expected_time
            inserts = []
            pattern_str = "End" 

            if note_short_5f:
                expected_time -= note_short_5f #Not confident this is right.
                # note_short_5f = 0

            if expected_time < total_expected_time:
                sorted_lengths = sorted(VoiceCatalog.length_to_nibble.keys(), reverse=True)

                rest_duration = total_expected_time - expected_time
                expected_time = total_expected_time


                if rest_duration in sorted_lengths:
                    length = sorted_lengths.index(rest_duration)
                else: 
                    length = rest_duration
            
                opcode = get_opcode(rest_duration)

                inserts.append({
                    "type": "rest",
                    "ptr": pattern_str,
                    "length": opcode  
                })
                rest_duration -= length

            return inserts
        #===Minor Main===
        nonlocal end_of_compressed_pattern
        nonlocal repeat_directives
        nonlocal start_of_compressed_pattern

        all_notes_data.extend(handle_pattern_end_gap()) 


        if end_of_compressed_pattern is not None:
            handle_end_of_comrpessed_pattern()

        for repeat_entry in repeat_directives:
            all_notes_data.extend(insert_repeat_directive(repeat_entry))
        repeat_directives= []    
        

        if start_of_compressed_pattern is not None:
            all_notes_data.extend(insert_string(f"@_{entry}:"))
            start_of_compressed_pattern = None


        return current_env, expected_time

    def process_pattern_lines(expected_time, all_notes_data, prev_pitch, current_env, pattern_num):

        def insert_change_env():
            inserts = []
            pattern_str = f"{pattern_num}-{note_index_in_pattern}" #ie, 1-2 for 1st pattern, 2nd note.
            
            try:
                Env_Change_pointer = VoiceCatalog.env_name_to_pointer[note_env]
            except KeyError:
                Env_Change_pointer = "Unidentified"

            inserts.append({

                "type": "Env_Change",
                "ptr": pattern_str,  # Now it's a string like "1-2"
                "new_env_pointer": Env_Change_pointer,
                "new_env_name": note_env
                
            })


            return inserts
    
        def insert_kick_sfx():
            nonlocal expected_time
            inserts = []

            pattern_str = f"{pattern_num}-{note_index_in_pattern}"  # e.g., "1-2"

            note_value = note_data.get("Value")
            slide_target = note_data.get("SlideTarget")
            instrument_name = note_data.get("Instrument")

            pitch_start = VoiceCatalog.NOTE_NAME_TO_ID.get(note_value)
            pitch_end = VoiceCatalog.NOTE_NAME_TO_ID.get(slide_target)

            # Safety warnings
            if pitch_start is None or pitch_end is None:
                print(f"[WARN] Missing pitch value(s): '{note_value}' -> '{slide_target}' at ptr: {pattern_str}")
            else:
                interval = pitch_start - pitch_end
                if interval < 25:
                    print(f"[WARN] Kick SFX slide too shallow ({interval} semitones) at ptr: '{pattern_str}' {note_value} -> {slide_target}")

            if not any(tag in instrument_name.lower() for tag in ("drum", "sfx")):
                print(f"[WARN] Instrument name '{instrument_name}' doesn't match a sfx at ptr: '{pattern_str}'")

            inserts.append({
                "type": "Kick SFX",
                "ptr": pattern_str,
            })

            

            return inserts


        def insert_rest():
            nonlocal expected_time
            inserts = []
            pattern_str = f"{pattern_num}-{note_index_in_pattern}" #ie, 1-2 for 1st pattern, 2nd note.

            rest_duration = note_data["Time"] - expected_time
            if note_short_5f:
                rest_duration += note_short_5f
                #note_short_5f = 0

            expected_time += rest_duration


            sorted_lengths = sorted(VoiceCatalog.length_to_nibble.keys(), reverse=True)


            while rest_duration > 0:
                # Find the largest length <= tmp
                for length in sorted_lengths:
                    if length <= rest_duration:

                        opcode = get_opcode(length)

                        inserts.append({
                            "type": "rest",
                            "ptr": pattern_str,
                            "length": opcode  
                        })
                        rest_duration -= length
                        break
                else:
                    #Needs Custom Frame number
                        inserts.append({
                            "type": "rest",
                            "ptr": pattern_str,
                            "length": rest_duration  
                        })
                        rest_duration = 0
                        break
            
            return inserts



        def process_pitch(prev_pitch):
            note_value = note_data["Value"]
            pitch_abs = VoiceCatalog.NOTE_NAME_TO_ID.get(note_value)
            if pitch_abs is None:
                raise ValueError(f"Unknown note value {note_value}.")

            if channel_name == "Noise":
                pitch_abs = (15 - (pitch_abs % 16))
                pitch_abs = (pitch_abs + 6) % 16
                if pitch_abs == 0:
                    print (f"Noise pitch resulted in 0 period for note {note_value}. Replaced w/ 1 (Indistinguisable difference)")
                pitch_abs = pitch_abs % 16
                return pitch_abs, None, None

            else:
                if prev_pitch is not None:
                    pitch_rel = pitch_abs - prev_pitch
                else: 
                    pitch_rel = -100
                prev_pitch = pitch_abs
                return pitch_abs, pitch_rel, prev_pitch
        
        def build_note_dict(pitch_abs, pitch_rel):
            pattern_str = f"{pattern_num}-{note_index_in_pattern}" #ie, 1-2 for 1st pattern, 2nd note.
            
            duration = note_data["Duration"]
            if note_short_5f:
                duration += note_short_5f
                #note_short_5f = 0


            nibble = VoiceCatalog.length_to_nibble.get(duration, None)
            if nibble is None:
                opcode = duration
            else:
                opcode = VoiceCatalog.nibble_to_opcode.get(nibble, None)
                if opcode is None:
                    opcode = duration

            note_dict = {
                "type": "note",
                "ptr": pattern_str,
                "length": opcode,
                "pitch_abs": pitch_abs,
            }
            if channel_name != "Noise":
                note_dict["pitch_rel"] = pitch_rel

            # Include other metadata (e.g., Sweep, Volume)
            for key, value in note_data.items():
                if key not in ("Time", "Value", "Duration", "Instrument", "Release"):
                    note_dict[key] = value

            return note_dict


        def insert_init_header():
            nonlocal prev_pitch
            
            inserts = []
            note_value = note_data["Value"]
            pitch = VoiceCatalog.NOTE_NAME_TO_ID.get(note_value)

            prev_pitch = pitch


            try:
                env_pointer = VoiceCatalog.env_name_to_pointer[note_env]
            except KeyError:
                env_pointer = "Unidentified"

            inserts.append({
                "type": "Init_Header",
                "Ptr_Name": f"{song_name}_{channel_name}:",
                "Init_pitch_id": None,  # This will be resolved later
                "Init_env_pointer": env_pointer,
                "Init_env_name": note_env
            })
            return inserts

        #===Sub Main===


        expected_time -= total_expected_time
        
        try:
            idx = patterns_in_channel[pattern_num] + 1
        except KeyError:
            values = list(patterns_in_channel.values())
            if len(values) >= 3:
                idx = values[1] + 1   # third entry (0-based)
            else:
                raise KeyError(f"pattern_num {pattern_num} missing and no 3rd entry fallback")
        #idx = patterns_in_channel[pattern_num] + 1

        note_index_in_pattern = 0
        note_short_5f = 0

        while idx < len(raw_lines):

            if expected_time < 0:
                print(f"[WARN] Time is negative. Double check no excesive rests") #Issue with end gap

            line = raw_lines[idx]
            if "Pattern Name=" in line:
                break

            if 'Note Time=' in line:
                note_data = h.parse_note_line(line)
                note_index_in_pattern += 1
                

                
                note_duration = note_data.get("Duration")
                if note_duration is not None:
                    pass  # proceed normally
                elif "Volume" in note_data:
                    idx += 1
                    continue  # silently skip if only Duration missing
                else:
                    raise KeyError("Missing Volume")  # truly missing both keys


                note_time = note_data["Time"] #GOTTA INCLUDE THE CHECK
                if note_time > expected_time:
                    all_notes_data.extend(insert_rest())
                    note_short_5f = 0
                elif note_time < expected_time:
                    print(f'Note time mismatch. Bad sfx/rest? Clear Famistudio Overlapping Notes.')


                
                is_slide_note = bool(note_data.get("SlideTarget", False))

                if note_duration <= 5 and is_slide_note:
                    all_notes_data.extend(insert_kick_sfx())
                    note_short_5f = note_duration
                    expected_time += note_duration
                    idx += 1
                    continue

                note_env = note_data["Instrument"] 
                if current_env is None:
                    all_notes_data[:0] = insert_init_header()
                    current_env = note_env

                elif current_env != note_env:
                    current_env = note_env 
                    all_notes_data.extend(insert_change_env())

                note_time = note_data["Time"]
                if note_time > expected_time:
                    all_notes_data.extend(insert_rest())
                    note_short_5f = 0
                elif note_time < expected_time:
                    print(f'Note time mismatch. Bad sfx/rest? Clear Famistudio Overlapping Notes.')

                pitch_abs, pitch_rel, prev_pitch = process_pitch(prev_pitch)
                all_notes_data.append(build_note_dict(pitch_abs, pitch_rel))
                note_short_5f = 0

                expected_time += note_data["Duration"]

            idx += 1
        return expected_time, note_short_5f, prev_pitch, current_env


    # ===Minor Main===
    letter_riff_end_env = {}
    all_notes_data = []
    prev_pitch = None
    current_env = None
    repeat_directives = []
    start_of_compressed_pattern = None
    end_of_compressed_pattern = None
    expected_time = total_expected_time  # Reset for each pattern
    previous_pattern_num = None
    note_short_5f = 0

    for entry in channel_sequence:
        if isinstance(entry, int):

            if entry == 6:
                pass

            if entry == -1:

                pattern_num = None

                current_env, expected_time = pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num)
                all_notes_data.extend([{"type": "End_Intro"}])

                expected_time = total_expected_time  # Reset for next ptr
                note_short_5f = False
                continue 

            elif entry == 0:
                pattern_num = 0
                current_env, expected_time = pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num)
                
                if expected_time > total_expected_time:
                    expected_time -= total_expected_time
                    continue
                
                elif expected_time < total_expected_time:
                    print (f"[WARN] Unsure if expected time should ever be less than during empty pattern.")
                all_notes_data.extend(insert_full_measure_rest())
                
                    #If expected time is well over cuz long note, don

                expected_time = total_expected_time  # Reset for next ptr
                note_short_5f = False
                continue  
            else:


                if entry in patterns_in_channel:
                    pattern_num = entry
                    current_env, expected_time = pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num)
                    expected_time, note_short_5f, prev_pitch, current_env = process_pattern_lines(expected_time, all_notes_data, prev_pitch, current_env, pattern_num)
                    
                    end_of_compressed_pattern = None
                    repeat_directives = []
                    previous_pattern_num = pattern_num
                else:
                    raise ValueError(f"Pattern {entry} not found in raw_lines.")
        
        elif isinstance(entry, str):
            if entry == "E":
                print()

            pattern_list = compressed_patterns[entry]
            
            start_of_compressed_pattern = entry
            # all_notes_data.extend(insert_string(f"@_{entry}:"))

            for pattern_num in pattern_list:
                
                current_env, expected_time = pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num)
                expected_time, note_short_5f, prev_pitch, current_env = process_pattern_lines(expected_time, all_notes_data,prev_pitch, current_env, pattern_num)
            
            end_of_compressed_pattern = entry
            repeat_directives = []
            previous_pattern_num = pattern_num

            letter_riff_end_env[entry] = current_env 


        elif isinstance(entry, dict):
            repeat_directives.append(entry)
            #Current Instrument may be modified by letter riff.
            letter_riff = next(iter(entry))
            
            # Retrieve the saved end environment
            try:
                current_env = letter_riff_end_env[letter_riff]
            except KeyError:
                raise KeyError(f"Missing end env info for pattern letter '{letter_riff}'")
        else:
            raise TypeError(f"Unsupported type in channel_sequence: {entry}")
        

    if end_of_compressed_pattern is not None:
        #GET INSTRUMENT CHANGE TOO
        print (f"Warning: Looping instrument changes are Unimplimented at the end.")
        all_notes_data.extend(insert_string(f"; end @_{end_of_compressed_pattern}"))

    current_env, expected_time = pre_process_pattern_env_and_rests(expected_time, note_short_5f, all_notes_data, current_env, pattern_num)


    for repeat_entry in repeat_directives:
        all_notes_data.extend(insert_repeat_directive(repeat_entry))
    


    all_notes_data.extend(insert_string(f".byte Loop"))
    return all_notes_data





def convert_lengths_to_nibbles(all_notes_data, raw_lines):

    for note in all_notes_data:
        if "length" not in note:
            continue

        length = note["length"]

        # Control code — leave unchanged
        if length < 0:
            continue

        matched = False

        # Match ±0.1
        for key, value in VoiceCatalog.length_to_nibble.items():
            if abs(length - key) <= 0.1:
                if key == 5.33:
                    raise ValueError("Unsupported length: 5.33 — Use 5-6-5/16ths split instead.")
                note["length"] = value  # Replace float with nibble
                matched = True
                break

        # Fallback ±0.33
        if not matched:
            for key, value in VoiceCatalog.length_to_nibble.items():
                if abs(length - key) <= 0.33:
                    print(f"Warning: Low accuracy length match: {note}")
                    #input("Paused for Debugging...")
                    if key == 5.33:
                        raise ValueError("Unsupported length: 5.33 — Use 5-6-5/16ths split instead.")
                    note["length"] = value  # Replace float with nibble
                    matched = True
                    break

        if not matched:
            raise ValueError(f"Unable to match length {length}")
    return all_notes_data





def get_opcode(length):

    nibble = VoiceCatalog.length_to_nibble.get(length, None)
    if nibble is None:
        return length

    else:
        opcode = VoiceCatalog.nibble_to_opcode.get(nibble, None)
        if opcode is None:
            return length

    return opcode



#===Section Main===

def extract_pattern_data(song_data, channel_sequence, header_data, song_raw_lines, channel_name):




    raw_lines, total_expected_time, patterns_in_channel = get_raw_data(song_raw_lines, header_data, channel_name)
    marked_sequence, compressed_patterns, compressed_pattern_starts  = mark_repeated_patterns(channel_sequence)



    # Now process each channel's seqence
    All_Patterns_Block = []
    All_Patterns_Block.append('')


    song_name = header_data['Name']
    if not marked_sequence:
        output_lines = [
        f"{song_name}_{channel_name}:",
        f".byte $00, $00 ;Header for spacing",
        f".byte $70 ;Whole Rest",
        f".byte Loop",
        ]
        estimate_size = 4
        return output_lines, estimate_size

    all_notes_data = extract_notes_dicts(marked_sequence, compressed_patterns, patterns_in_channel, song_name, raw_lines, total_expected_time, channel_name)

    #all_notes_data = convert_lengths_to_nibbles(all_notes_data, raw_lines)

    output_lines, file_size = Format_Pattern_Main_Block(song_data, all_notes_data, channel_name)
    return output_lines, file_size

