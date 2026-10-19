from utils.voice_catalog import VoiceCatalog as vc

import re
timestamp_regex = re.compile(r'^\s*(?:_\d+)+:')


def get_bpm_line(song_data) -> str:
    """Generates the _8th .set line from the Groove field in song_data.header_data."""
    # Find the groove entry
    groove_entry = song_data.header_data.get("Groove")


    if not groove_entry:
        print(f"⚠️  Warning: No Groove found for {song_data.name}, defaulting to 6")
        groove_entry = [6]

    # Groove might be a list of ints, like [6, 7]
    groove_values = groove_entry if isinstance(groove_entry, list) else [groove_entry]
    groove_avg = sum(groove_values) / len(groove_values)
    bpm_value = round(groove_avg * 2)

    # If not integer, warn before rounding
    if bpm_value != groove_avg * 2:
        print(f"⚠️  Groove average not integer in {song_data.name}. Rounded {groove_avg*2:.2f} → {bpm_value}")

    bpm_hex = f"${bpm_value:02x}"  # Convert to hex like $0d
    groove_str = "-".join(str(g) for g in groove_values)

    return f"_8th .set {bpm_hex} ;{groove_str}", bpm_value




def outline_channel(song_name, song_data, all_notes_data, marked_sequence, compressed_patterns, compressed_pattern_starts, channel):

    def flush_notes_line(force_emit=False):
        nonlocal ch_lines, notes_line

        if not notes_line:
            return  # Nothing to emit

       
    
        # Gather lengths and pitches separately
        lengths = notes_line[0::2]  # even indices
        pitches = notes_line[1::2]  # odd indices

        if len(pitches) < 4  and not force_emit:
            return #Create larger groupings for clarity.


        i = 0
        new_notes_line = []  # for Notes command when no compression
        while i < len(lengths):
            # Check for Duration patterns
            pattern_matched = False

            # Define compression patterns  (higher ones are searched for first, and blindly-accepted.)
            duration_patterns = [
                ("_8x1", ["8th", "8th", "8th", "8th", "8th", "8th", "8th", "8th"]),
                ("_1111", ["8th", "8th", "8th", "8th"]),
                ("_0000", ["_16th", "_16th", "_16th", "_16th"]),
                ("_00", ["_16th", "_16th"])
            ]

            for dtype, pattern in duration_patterns:
                end = i + len(pattern)
                if end <= len(lengths):
                    # Compare current segment with pattern
                    if lengths[i:end] == pattern:
                        pattern_matched = True

                        # Emit any current Notes line first
                        if new_notes_line:
                            formatted = "Notes " + ", ".join(new_notes_line)
                            ch_lines.append(f"    {formatted}")
                            new_notes_line.clear()

                        # Emit Duration command
                        dur_line = f"Duration {dtype}, " + ",".join(pitches[i:end])
                        ch_lines.append(f"    {dur_line}")
                        i += len(pattern)
                        break  # pattern matched, break pattern loop

            if not pattern_matched:
                # Append current pair to Notes line
                new_notes_line.append(f"{lengths[i]},{pitches[i]}")
                i += 1

        # Emit any remaining Notes line
        if new_notes_line:
            formatted = "Notes " + ", ".join(new_notes_line)
            ch_lines.append(f"    {formatted}")

        ch_lines.append("")  # blank line for separation
        notes_line.clear()

        emit_timestamp()

        return


    def emit_timestamp():
        nonlocal ch_lines

        # Helper: Build timestamp
        parts = [str(measure)]
        if not (beat == 1 and frame == 0):
            parts.append(str(beat))
        if frame != 0:
            parts.append(str(frame))
        timestamp = '_'.join(parts)
        
        ch_lines.append(f"    _{timestamp}:")

        return
    
    def update_line(length, pitch):
         
        nonlocal measure 
        nonlocal beat 
        nonlocal  frame 

    # Case 1: Length is an opcode string (like 'qtr', 'hlf', etc.)
        if isinstance(length, str):
            nibble = vc.opcode_to_nibble.get(length, None)

            if nibble == 0:  # 16th note
                frame += _16th  

            elif nibble is not None:
                beat += nibble  

            else:
                print(f"[ERROR] Unknown length opcode: {length}")

        # Case 2: Length is numeric (raw duration)
        elif isinstance(length, (int, float)):
            frame += length

            
            x = length // _8th
            y = length % _8th

            parts = []
            if x > 0:
                parts.append(f"{x}*_8th")
            if y > 0:
                parts.append(f"{y}")

            length = '+'.join(parts)

        else:
            print(f"[WARN] Unsupported length type: {length}")

        # Convert frames into beats
        while frame >= _8th:
            frame -= _8th
            beat += 1

        # Convert beats into measures (8 beats per measure)
        flush_line = False
        while beat > 8:
            flush_line = True
            beat -= 8
            measure += 1

        notes_line.extend([length, pitch])
        if flush_line:
            flush_notes_line()

        return


    def emit_repeat(entry):
        nonlocal ch_lines, measure

        riff_id = entry["id"]
       

        # Flush current notes line first
        if notes_line:
            print("[WARN] Riff appeared mid-measure")
            flush_notes_line()

        pattern_length = len(compressed_patterns[riff_id])
        start_measure = compressed_pattern_starts[riff_id]
        end_measure = start_measure + pattern_length

        # Emit the Riff line
        ch_lines.append(f"    Riff _{end_measure}, _{start_measure}")
        ch_lines.append("")

        # Advance measure
        measure += pattern_length
        emit_timestamp()


        count = entry.get("count", 0)
        if count  > 0:
            ch_lines.append(f'    Repeat "2b", {count}')
            ch_lines.append("")
            measure += pattern_length * count
            emit_timestamp()

        return


    #=== Main ===
    if channel == "Noise":

        ch_lines = ([  #Hardcoded Noise template.
            f"{song_name}_Noise_Bank .set NoiseFX_Index",
            "",
            "NoiseFX @Placeholder, $00, $00, $00",
            "",
            f"Channel {song_name}_Noise",
            f"    Noise_Header ::{song_name}_Noise_Bank, Intro",
            "",
            "    End_Intro:",
            "",
            "    Notes whl, rest",
            "",
            f"Loop {song_name}_Noise",
        ])

        return ch_lines


    _16th = song_data.header_data.get("NoteLength") #trancated _16th * 2
    _8th = 2*_16th
    notes_line = []
    ch_lines = []

    ch_lines.append(f"Channel {song_name}_{channel}",)

    if marked_sequence and marked_sequence[0] != -1:
        ch_lines.extend([
            f"    Header A0, $00, \"Intro\"",
            "",
        ])


    else:
        ch_lines.extend([
        f"    Header A0, $00",
        "",
        ]) 

    if not all_notes_data: #Error during transcribe,  emit default.
    
        if marked_sequence and marked_sequence[0] != -1:
            ch_lines.append("    End_Intro:")

        ch_lines.append("")
        ch_lines.append("    Notes whl, rest")
        ch_lines.append("")



    measure = 1
    beat = 1
    frame = 0


    for entry in all_notes_data:
        
        if notes_line and not isinstance(notes_line[0], str):
            pass
                
        entry_type = entry.get("type")

        if entry_type == "note":

            length = entry.get("length")
            pitch_abs = entry.get("pitch_abs")

            pitch = vc.PITCH_ID_TO_NAME.get(pitch_abs, "Unknown")

            update_line(length, pitch)

        elif entry_type == "rest":
             
            length = entry.get("length")
            pitch = "rest"

            update_line(length, pitch)

            #Call helper common w/ Note.
                #modifies measure/beat/frame
                    #it ends the line whenever the measure overflows, emits the current timestamp, starts a new line.
                #it appends the length/pitch pair to the line

        elif entry_type == "repeat":
            emit_repeat(entry)
            

        elif entry_type == "End_Intro":
                timestamp = ch_lines.pop()
                ch_lines.append("    End_Intro:")

                ch_lines.append("")
                if not timestamp_regex.match(timestamp):
                    print(f"[WARN] End Intro's Line {timestamp} wasn't actually a timestamp")
                ch_lines.append(timestamp)

        else:
            continue



    # timestamp = ch_lines.pop()
    # if not pattern.match(timestamp):
    #     print(f"[WARN] Last line {timestamp} wasn't actually a timestamp")
    #     ch_lines.append(timestamp)

    # blank = ch_lines.pop()
    # if blank:
    #     print(f"[WARN] Last line {blank} wasn't actually blank")
    #     ch_lines.append(blank)

    ch_lines.append(f"Loop {song_name}_{channel}")

    return ch_lines




def emit_noise_channel(song_name):
    return [
        f"{song_name}_Noise_Bank .set NoiseFX_Index",
        "",
        "NoiseFX @Placeholder, $00, $00, $00",
        "",
        f"Channel {song_name}_Noise",
        f"    Noise_Header A0, ::{song_name}_Noise_Bank, \"Intro\"",

        "",
        "    End_Intro:",
        "",
        "    Notes whl, rest",
        "",
        f"Loop {song_name}_Noise",
        "",
    ]

