import re
import os
from utils.voice_catalog import VoiceCatalog
import utils.helpers as h

#get_raw_env_data, including Song_Pointers, Vibrato, and Volume tables.

def process_txt(input_file):


    """
    Processes the full input file into global env data,
    individual song blocks, and a list of sanitized song names.
    
    Returns:
        env_data (list of lines),
        song_data_list (list of dicts),
        song_names (list of sanitized names)
    """
    with open(input_file, 'r', encoding='utf-8') as infile:
        lines = infile.readlines()

    env_data = []
    song_data_list = []
    song_names = []

    current_song = None
    header_started = False

    for line in lines:
        line = line.strip()

        # Start of a new song
        if 'Song Name=' in line:
            if current_song:
                # Save the current song before starting a new one
                song_data_list.append(current_song)

            # Start new song block
            current_song = {
                'raw_lines': []  # Store all lines for this song
            }
            header_started = True

        if not header_started:
            env_data.append(line)
        else:
            if current_song is not None:
                current_song['raw_lines'].append(line)

    # After loop ends, don't forget to save the last song!
    if current_song:
        song_data_list.append(current_song)

        # Now sanitize song names
    for song in song_data_list:
        # Find the Song Name
        song_name = None
        for line in song['raw_lines']:
            if 'Song Name=' in line:
                # Extract using regex to find text between quotes after Song Name=
                match = re.search(r'Song Name="([^"]+)"', line)
                if match:
                    raw_name = match.group(1)
                    song_name = h.sanitize_song_name(raw_name)  # <-- Sanitize it here
                break  # No need to keep scanning

        if song_name:
            song_names.append(song_name)
        else:
            print("Error: Song block has no Song Name defined.")

    return env_data, song_data_list, song_names


def write_song_pointers(song_names, env_file_stats):
    """
    Generates the global data file 'Music_Global_Data.s' with song pointer tables
    and includes each song's .s file.
    """
    output_lines = []

    # Write the High Byte pointer table
    output_lines.append('Table_Song_Pointers_Hi:')
    for name in song_names:
        output_lines.append(f'    .byte >{name}_Data')
    output_lines.append('')

    # Write the Low Byte pointer table
    output_lines.append('Table_Song_Pointers_Low:')
    for name in song_names:
        output_lines.append(f'    .byte <{name}_Data')
    output_lines.append('')

    subfolder = "Env_Data"
    folder_path = os.path.join("Output_Files", subfolder)
    filename = f"Song_Pointers.s"
    path = os.path.join(folder_path, filename)


    if ENABLE_WRITES:
        with open(path, "w", encoding="utf-8") as outfile:
            h.write_block(outfile, output_lines)

    file_size = len(song_names)*2

    env_file_stats.append({
    "Folder": subfolder,
    "File": filename,
    "Size": file_size,
    "Can_Cross_Page": True,
    })


    return env_file_stats



def get_raw_env_data(isntrument_raw_lines):
    processed_env_data = {}
    current_env = None

    for line in isntrument_raw_lines:
        if line.strip().startswith("Song Name="):
            break  # Stop parsing envs at this point

        if line.strip().startswith("Instrument Name="):
            # Extract env name
            match = re.search(r'Instrument Name="([^"]+)"', line)
            if match:
                current_env = match.group(1)
                processed_env_data[current_env] = []
            continue

        if line.strip().startswith("Envelope Type=") and current_env:
            envelope_match = re.findall(r'(\w+)=("[^"]*"|\S+)', line)
            envelope_info = {}
            for key, val in envelope_match:
                val = val.strip('"')
                if key == "Values":
                    envelope_info[key] = [int(v.strip()) for v in val.split(',')]
                elif val.isdigit():
                    envelope_info[key] = int(val)
                else:
                    envelope_info[key] = val

            processed_env_data[current_env].append(envelope_info)

    return processed_env_data




def write_vol_data(vol_file_size, volume_lines, env_file_stats):
    subfolder = "Env_Data"
    folder_path = os.path.join("Output_Files", subfolder)

    filename = f"Volume_Data.s"
    path = os.path.join(folder_path, filename)


    if ENABLE_WRITES: 
        with open(path, "w", encoding="utf-8") as outfile:
            h.write_block(outfile, volume_lines)

    env_file_stats.append({
    "Folder": subfolder,
    "File": filename,
    "Size": vol_file_size,
    "Can_Cross_Page": True,
    })
    return env_file_stats


def write_vibrato_data(env_file_stats):
    subfolder = "Env_Data"
    folder_path = os.path.join("Output_Files", subfolder)
    filename = f"Vibrato_Data.s"
    path = os.path.join(folder_path, filename)




    seq_to_pointer = VoiceCatalog.vibrato_sequence_to_pointer
    id_to_waveform = {v: k for k, v in seq_to_pointer.items()}


    next_pointer = 1
    vibrato_pointers = [0]
    VoiceCatalog.vibrato_data_lines.append(f".byte $00 ;Temp No Vibrato")
    VoiceCatalog.vibrato_data_lines.append("")

    for vibrato_id in id_to_waveform:
        wait_time, waveform = id_to_waveform[vibrato_id]
        wave = waveform[:-1]
        start_ptr = next_pointer

        if waveform[-1] != 0:
            print (f"[WARN], Vibrato wave {waveform} ends w/ non-zero. Its truncated.")


        ones_comp_vals = [(~(-x) & 0xFF) for x in wave]
        byte_list = ", ".join(f"${v:02x}" for v in ones_comp_vals)
        VoiceCatalog.vibrato_data_lines.append(f".byte {byte_list}")

        VoiceCatalog.vibrato_data_lines.append(f".byte ${start_ptr:02x}")
        VoiceCatalog.vibrato_data_lines.append("")
        if start_ptr > 127:
            print (f"[ERROR] Too much Vibrato Data.")

        vibrato_pointers.append(next_pointer)
        next_pointer += len(waveform)  # wave + end Pointer


    if len(vibrato_pointers) > 3:
        print (f"[ERROR] Too many Vibrato IDs. Only 3 + None accessable.")

    VoiceCatalog.vibrato_data_lines.append("")
    VoiceCatalog.vibrato_data_lines.append("Table_Vibrato_Pointers:")
    pointer_bytes = ", ".join(f"${ptr:02x}" for ptr in vibrato_pointers)
    VoiceCatalog.vibrato_data_lines.append(f".byte {pointer_bytes}")

    if ENABLE_WRITES:
        with open(path, "w", encoding="utf-8") as outfile:
            h.write_block(outfile, VoiceCatalog.vibrato_data_lines)

    file_size = next_pointer-1 + len(vibrato_pointers)

    env_file_stats.append({
    "Folder": subfolder,
    "File": filename,
    "Size": file_size,
    "Can_Cross_Page": True,
    })

    return env_file_stats


#Main of Part 1
def Create_Env_Data(input_file):

    def format_env_data(env_name, envelopes):
        
        def process_duty_cycle():
            duty_envelope = next((env for env in envelopes if env['Type'] == 'DutyCycle'), None)

            if not duty_envelope or not duty_envelope.get("Values"):
                print(f"Assumed \"{env_name}\" has Duty 12.5")
                return 0, 0  # init_duty, sustain_duty

            duty_vals = duty_envelope["Values"]
            if max(set(duty_vals)) > 3 or min(set(duty_vals)) < 0:
                raise ValueError(f"DutyCycle values must be 0–3, got {init_duty} and {sustain_duty} in \"{env_name}\"")

            if len(set(duty_vals)) == 1:
                # Static Duty
                return duty_vals[0], 0

            init_duty = duty_vals[0]
            duty_change_idx = None
            for i, val in enumerate(duty_vals):
                if val != init_duty:
                    duty_change_idx = i
                    break
            if duty_change_idx is None:
                raise NotImplementedError

            #Validate the release
            volume_env = next((env for env in envelopes if env['Type'] == 'Volume'), None)
            if volume_env and "Values" in volume_env:
                release_index = volume_env.get("Release", len(volume_env["Values"]))
            else:
                release_index = 0

            if release_index is None or release_index != duty_change_idx:
                print(f"[ERROR] Env \"{env_name}\": DutyCycle changes at {duty_change_idx}, but Volume Release is at {release_index}")



            sustain_duty = duty_vals[duty_change_idx]

            # Ensure rest of values are all the same as sustain_duty
            for val in duty_vals[duty_change_idx:]:
                if val != sustain_duty:
                    raise ValueError(f"Bad duty vals in \"{env_name}\": more than one change in DutyCycle envelope")

            sustain_duty ^= init_duty
            if init_duty >= 2:
                print(f"[WARN] Env {env_name} is not safe for Triangle")

            return init_duty, sustain_duty


        def process_release():
            release_envelope = next(
                (env for env in envelopes if env['Type'] == 'Volume' and env.get('Release') is not None),
                None #SKEPTICAL. This should be turned into something neater. It should be able to pinpoint the release.
            )

            release_time = 0
            if release_envelope:
                release_index = release_envelope.get("Release")
                if isinstance(release_index, int) and 0 <= release_index <= len(release_envelope["Values"]):
                    release_time = sum(1 for value in release_envelope["Values"][release_index:] if value == 0)

            if release_time > 3:
                print(f"Warning: \"{env_name}\" has a cut-off of {release_time}")

            release_time &= 0xff

            return release_time

        def process_vibrato():
            pitch_envelope = next((env for env in envelopes if env['Type'] == 'Pitch'), None)
            vibrato_id = 0

            if pitch_envelope and pitch_envelope.get("Values"):
                values = pitch_envelope["Values"]

                # Step 1: Count initial delay frames
                wait_frames = 0
                for v in values:
                    if v == 0:
                        wait_frames += 1
                    else:
                        break

                vibrato_wave = values[wait_frames:]
                if not vibrato_wave:
                    raise ValueError(f"Vibrato envelope in \"{env_name}\" has no wave after delay")
                elif max(vibrato_wave) > 0:
                    raise ValueError(f"Vibrato wave of \"{env_name}\" has down-pitch vibrato: {vibrato_wave}")

                # Step 2: Normalize by greatest common power of 2
                def power_of_two(n):
                    if n == 0:
                        return 0
                    shift = 0
                    while n % 2 == 0:
                        n >>= 1
                        shift += 1
                    return shift

                def common_power_of_two(nums):
                    powers = [power_of_two(abs(n)) for n in nums if n != 0]
                    return min(powers) if powers else 0

                norm_factor = 2 ** common_power_of_two(vibrato_wave)
                normalized_wave = [v // norm_factor for v in vibrato_wave]


                # Step 4: Identify or register vibrato
                vibrato_id = 0
                for (existing_wait, existing_wave), existing_index in VoiceCatalog.vibrato_sequence_to_pointer.items():
                    if existing_wave == tuple(normalized_wave):
                        #if existing_wait != wait_frames: #wait frames vestigial
                        #    print(f"Warning: Vibrato waveform in \"{env_name}\" already exists but with different delay ({existing_wait} vs {wait_frames})")
                        vibrato_id = list(VoiceCatalog.vibrato_sequence_to_pointer.values()).index(existing_index) + 1
                        return vibrato_id

                print(f"Registered new vibrato ID {vibrato_id}: wait={wait_frames}, wave={normalized_wave}")
                vibrato_index = VoiceCatalog.vibrato_data_byte_count
                VoiceCatalog.vibrato_sequence_to_pointer[(wait_frames, tuple(normalized_wave))] = vibrato_index

                # +1 for wait frame, +len for wave (Terminator is 2's comp negetive of length, saying to go back, and treated as 0 vibrato.)
                VoiceCatalog.vibrato_data_byte_count += len(normalized_wave) + 1

                vibrato_id = len(VoiceCatalog.vibrato_sequence_to_pointer)
                
            return vibrato_id
            

        def process_volume(): #release env means ignore thigns after it. first it attack volume. last is sus volume. take difference, and number of in bewteen, divide things out. 
            def simulate_decay_until_sustain(volume_vals):
                """
                Simulate decay until it hits sustain.
                Only keep decay rates where:
                - the envelope is sustaining by the final frame
                - and the sustain value occurs exactly at the target frame
                """
                step=0.25                

                target_frame = len(volume_vals)-1

                decay_rate = attack


                valid_paths = {}
                while decay_rate > 0:
                    vol = attack
                    truncated_volumes = [int(vol)]
                    #sustained = False
                    frame = 0

                    while frame < 256:
                        frame += 1
                        vol -= decay_rate

                        if vol < 0:
                            truncated_volumes.append(0)
                            break

                        if vol < sustain:
                            truncated_volumes.append(sustain)
                            break  # once sustaining, envelope is stable

                        truncated_volumes.append(int(vol))




                    if (
                        target_frame <= frame and
                        truncated_volumes[-1] == sustain and
                        truncated_volumes[target_frame] == sustain
                        
                    ):
                        truncated_volumes = truncated_volumes[:target_frame + 1]
                        valid_paths[round(decay_rate, 4)] = truncated_volumes

                    if truncated_volumes == volume_vals:
                        return decay_rate #Perfect match.

                    decay_rate -= step


                
                if not valid_paths:
                    best_decay_rate = 1
                    print(f"No valid Decay found for {env_name}")
                    return best_decay_rate

                target_sum = sum(volume_vals)
                best_diff = float("inf")

                for rate, vol_seq in valid_paths.items():
                    diff = abs(sum(vol_seq) - target_sum)
                    if diff < best_diff:
                        best_diff = diff
                        best_decay_rate = rate
                        best_path = vol_seq

                print (f"Volume isn't perfect for: {env_name}. Given: {volume_vals}. Used: {best_path} w/ Decay: {best_decay_rate}")
                return best_decay_rate

                        
            
            
            
            volume_envelope = next((env for env in envelopes if env['Type'] == 'Volume'), None)
            if not volume_envelope or not volume_envelope.get("Values"):
                print(f"Assumed {env_name} was Hold 15")
                volume_vals = [15]
            else:
                volume_vals = volume_envelope["Values"]
                #If a release point is defined, trim the envelope to it
                release_index = volume_envelope.get("Release")
                if isinstance(release_index, int) and 0 <= release_index <= len(volume_vals):
                    volume_vals = volume_vals[:release_index]
                if not all(0 <= value <= 15 for value in volume_vals):
                    raise ValueError(f"Volume envelope contains invalid value(s): {volume_vals}")

            #The end value can now be repeated

            attack = volume_vals[0]
            if attack != max(volume_vals):
                raise ValueError
            
            sustain = volume_vals[-1]
            if sustain != min(volume_vals):
                raise ValueError

            if attack == sustain:
                decay_speed = 0
                return attack, sustain, decay_speed

            print()
            decay_speed = simulate_decay_until_sustain(volume_vals)
            decay_speed = int(4*decay_speed)
            

            return attack, sustain, decay_speed

        # --- Sub Main ---
        init_duty, sustain_duty = process_duty_cycle()
        release_time = process_release()
        vibrato_id = process_vibrato()
        attack_vol, sustain_vol, decay_speed = process_volume()

        # ---- Table_Env_Attack ----
        # Format: %DD VVVV pp 
        # VVVV = 4-bit attack volume
        # DD = 2-bit init duty cycle
        # pp = 2-bit vibrato ID (limited to 4)

        attack_line = (f".byte ${init_duty << 6:02x} | (${attack_vol:x} << 2) | ${vibrato_id:x}")

        # ---- Table_Env_Decay_Rate ----
        decay_byte = decay_speed & 0xFF 


        # ---- Table_Env_Sustain ----
        # Format: %DD 00 VVVV
        # VVVV = 4-bit sustain volume
        # DD = init_duty ^ sustain_duty (2 bits)
        sustain_byte = sustain_duty << 6 | sustain_vol

        # ---- Table_Env_Release_Time ----
        release_byte = release_time & 0xFF

        env_pointer_index = len(Table_Env_Attack) - 2 #Exlcude both header lines.
        VoiceCatalog.env_name_to_pointer[env_name] = env_pointer_index

        if env_pointer_index > 15:
            print (f"[WARN] Env: {env_name} can only be at the start of a song, or special effects.")

        # ---- Table Output ----
        Table_Env_Attack.append(attack_line)
        Table_Env_Decay_Rate.append(f".byte ${decay_byte:02x}")
        Table_Env_Sustain.append(f".byte ${sustain_byte:02x}")
        Table_Env_Release_Time.append(f".byte ${release_byte:02x}")
        return 

    #=== Section Main ===
    env_data, song_data_list, song_names = process_txt(input_file)  # Process the text and get all the header data

    env_file_stats = []
    env_file_stats = write_song_pointers(song_names, env_file_stats)
    
    processed_env_data = get_raw_env_data(env_data)

    # Initialize tables with headers and comments
    Table_Env_Attack = [
        "Table_Env_Attack:",
        "; %DD VVVV pp ; Duty | Attack_Volume | Vibrato ID"
    ]

    Table_Env_Decay_Rate = [
        "Table_Env_Decay_Rate:",
        "; $int  subtracted from AT every frame til below Sus"
    ]

    Table_Env_Sustain = [
        "Table_Env_Sustain:",
        "; %DD 00 VVVV ; Duty XOR | Sustain_Volume"
    ]

    Table_Env_Release_Time = [
        "Table_Env_Release_Time:",
        "; $int  Silence threshold (cutoff in frames)"
    ]

    for env_name, envelopes in processed_env_data.items():
        format_env_data(env_name, envelopes)
    
    vol_file_size = 4* (len(Table_Env_Attack)-2) #The comment, and the the Label lines not included.

    volume_lines = (
            Table_Env_Attack + [""] +
            Table_Env_Decay_Rate + [""] +
            Table_Env_Sustain + [""] +
            Table_Env_Release_Time
        )

    env_file_stats = write_vol_data(vol_file_size, volume_lines, env_file_stats)
    env_file_stats = write_vibrato_data(env_file_stats)

    return song_data_list, song_names, env_file_stats

"""
TODO

        channel_file_stats.append({
            "Folder": f"Env_Data",
            "File": f"{Type}.s",  #Where type is either Pointers, Volume, or Vibrato
            "Size": file_size,
            "Can_Cross_Page": False,
        })
"""

ENABLE_WRITES = False