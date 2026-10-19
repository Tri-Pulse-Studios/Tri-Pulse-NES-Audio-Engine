import os
import traceback

from Step_1_Envelopes.env_main import Create_Env_Data, process_txt
from Step_2_Songs.song_main import Create_Song_Data, extract_header_data, get_famistudio_pattern_sequence
from Step_2_Songs.extract_song import extract_notes_dicts,get_raw_data,mark_repeated_patterns
from Step_3_Binning.bin_main import Sort_Files_into_Bins
from utils.riff_class import UNINIT, NO_DATA, RiffData, SongData
#from Fami_Outliner.outliner_main import Outline_Lines
import utils.helpers as h

import Fami_Outliner.lines as l

 
if __name__ == "__main__":
    # Lock working directory to the script's location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Step 1: Process the header data
    input_file = os.path.join(script_dir, "FamiConverter.txt")


    _env_data, song_data_list, song_names = process_txt(input_file)

     
    channel_tag_map = {
        "Square1": "Sq0",
        "Square2": "Sq1",
        "Triangle": "Tri",
        "Noise": "Noise",
        "DPCM": "dmc"
    }


    # Step 2: Loop through all the songs and create the .s files
    for song_raw_lines, song_name in zip(song_data_list, song_names):

        channels = [
            'Square1',
            'Square2', 
            'Triangle', 
            
            'DPCM',

            'Noise', 
            ]

        folder_path = os.path.join("Output_Files", song_name)
        header_data = extract_header_data(song_raw_lines)

        song_data = SongData(header_data, song_name)
        

        s_lines = []

        bpm_line, bpm = l.get_bpm_line(song_data)
        s_lines.append(bpm_line)
        s_lines.append("")


        for channel_name in channels:
            channel_data = song_data.init_channel(channel_name)
            # Step 1: Get the pattern sequence for the current channel
            channel_sequence = get_famistudio_pattern_sequence(song_raw_lines, header_data, song_name, channel_name)
            
            raw_lines, total_expected_time, patterns_in_channel = get_raw_data(song_raw_lines, header_data, channel_name)
            marked_sequence, compressed_patterns, compressed_pattern_starts = mark_repeated_patterns(channel_sequence, patterns_in_channel, song_raw_lines)
            if channel_name in ("Noise", "DPCM"):
                all_notes_data = {} #Too many issues with em. May clean up dmc
            else:
                
                
                try:
                    all_notes_data = extract_notes_dicts(
                                marked_sequence, compressed_patterns, patterns_in_channel,
                                song_name, raw_lines, total_expected_time, channel_name
                            )
                

                except Exception as e:
                    print(f"[ERROR] During {channel_name}: {e!r}")
                    print("Type:", type(e))
                    traceback.print_exc()
                    all_notes_data = {}

            channel_tag = channel_tag_map.get(channel_name)

    # Step 3: Write Simplified .s

            channel_lines = l.outline_channel(song_name, song_data, all_notes_data, marked_sequence, compressed_patterns, compressed_pattern_starts, channel_tag)

            s_lines.extend(channel_lines)
            s_lines.append("")
            s_lines.append("")
            s_lines.append("")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    filename = os.path.join(script_dir, f"{song_name}_Outlined.s")

    h.write_w_overwrite_check(filename, s_lines)
 
    print()