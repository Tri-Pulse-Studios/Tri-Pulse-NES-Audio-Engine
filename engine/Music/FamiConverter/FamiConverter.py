import os

from Step_1_Envelopes.env_main import Create_Env_Data
from Step_2_Songs.song_main import Create_Song_Data
from Step_3_Binning.bin_main import Sort_Files_into_Bins
 

if __name__ == "__main__":
    # Lock working directory to the script's location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Step 1: Process the header data
    input_file = os.path.join(script_dir, "FamiConverter.txt")

    all_files_stats = []

    song_data_list, song_names, env_file_stats = Create_Env_Data(input_file)
    all_files_stats.extend(env_file_stats)
    
    """
    Env data can be split into 3 Spacer files, each may cross a page.
    """
     

    # Step 2: Loop through all the songs and create the .s files
    for song, song_name in zip(song_data_list, song_names):
        channel_file_stats = Create_Song_Data(song, song_name)
        all_files_stats.extend(channel_file_stats)



    # Step 3: Bin Files such that Channel data never crosses a page boundary.
    Sort_Files_into_Bins(all_files_stats)

    print(f"All songs processed and written to .s files.")
    print()
