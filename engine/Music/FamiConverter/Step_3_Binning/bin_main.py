import os
import math
import utils.helpers as h


from typing import TypedDict, List
class FileStat(TypedDict):
    Folder: str
    File: str
    Size: int
    Can_Cross_Page: bool


def group_files(all_files_stats: List[FileStat]) -> List[FileStat]: #4 sub-groups
    can_cross: List[FileStat] = []
    must_fit: List[FileStat] = []

    for entry in all_files_stats:
        if entry["Can_Cross_Page"]:
            can_cross.append(entry)
        else:
            must_fit.append(entry)

    # Sort
    must_fit.sort(key=lambda f: f["Size"], reverse=True)  # biggest first
    can_cross.sort(key=lambda f: f["Size"])  # smallest first



    return must_fit, can_cross




def Sort_Files_into_Bins(all_files_stats: List[FileStat]) -> None:
    def fix_noise_at_pc_0(file):
        nonlocal current_pc_low
        if "Noise" in file["File"] and current_pc_low == 0:
            # Try to find the first non-"Noise" file
            for i, alt_file in enumerate(must_fit):
                if "Noise" not in alt_file["File"]:
                    return alt_file
            else:
                # No non-"Noise" file found — emit filler byte
                include_lines.append(".byte $ff ;Noise Filler")
                current_pc_low += 1
        return file

    def append_include_line(file: FileStat) -> None:
        line = f'.include "{file["Folder"]}/{file["File"]}"'
        include_lines.append(line)
        return
    
    def fill_a_page():
        nonlocal current_pc_low
        binned_files = []  # Track files to be removed


        while must_fit:
            file = must_fit[0]
            file = fix_noise_at_pc_0(file)
            if current_pc_low + file["Size"] <= 256:
                append_include_line(file)
                must_fit.remove(file)
                current_pc_low += file["Size"]
            else:
                break #Stop


        limit = 3*(len(must_fit) // 4) + len(must_fit) % 4 #75%, truncated up.
        for file in must_fit[:limit]:
            file = fix_noise_at_pc_0(file)
            if current_pc_low + file["Size"] <= 256: #Then pack in as many Mid-Sized ones as will fit.
                binned_files.append(file)
                current_pc_low += file["Size"]

        # Remove the files after iterating
        for file in binned_files:
            append_include_line(file)
            must_fit.remove(file)


        for file in must_fit:
            if current_pc_low + file["Size"] == 256: #If a small can land ON a page boundary, perfect.
                binned_files.append(file)
                current_pc_low = 256


        include_lines.append("")
        if must_fit and current_pc_low == 256: #If exactly landed, keep goin.
            include_lines.append("")
            current_pc_low = 0
            fill_a_page() #Recursive

        return



    def cross_a_page():
        nonlocal current_pc_low

        #Step 1: Cross w/ a single-small
        limit = 2*(len(can_cross) // 3) + len(can_cross) % 3 #2/3, truncate up.
        for file in can_cross[:limit]:
            if current_pc_low + file["Size"] >= 256:   
                current_pc_low += file["Size"]
                current_pc_low -= 256

                append_include_line(file)
                can_cross.remove(file)
                
                return

        #Step 2a: Fill w/ Any
        binned_files = []  # Track files to be removed
        for file in must_fit:
            if current_pc_low + file["Size"] <= 256: #If a small can land ON a page boundary, perfect.
                current_pc_low += file["Size"]
                binned_files.append(file)

        for file in binned_files:
            append_include_line(file)
            must_fit.remove(file)

        #Step 2b: Cross w/ Any
        while can_cross and must_fit:

            for file in can_cross: #Repeat Step 1, w/o Limit
                if current_pc_low + file["Size"] >= 256:   
                    current_pc_low += file["Size"]
                    current_pc_low -= 256
                    append_include_line(file)
                    can_cross.remove(file)
                    return 
                
            file = can_cross[-1] #Largest
            current_pc_low += file["Size"] #Append Largest if still not done.
            append_include_line(file)
            can_cross.remove(file)

        #Step 3: Cross w/ Filler
        if must_fit and current_pc_low < 256:
            if current_pc_low == 0:
                forced_file = must_fit[0] 
                current_pc_low += file["Size"]
                append_include_line(file)
                must_fit.remove(file)
                if current_pc_low > 256:              
                    print(f"[ERROR] Forced an oversized File to be inserted: {forced_file}, Size = {file['Size']}")
                    current_pc_low -= 256
                    return

            fill_amount = 256 - current_pc_low
            print(f'Wasted "{fill_amount}" Bytes to cross a page.')
            fill_line = (f".res {fill_amount}, $00")
            include_lines.append(fill_line)

            current_pc_low = 0
        return

    #===Section Main===
    include_lines = []
    must_fit, can_cross = group_files(all_files_stats)

    current_pc_low = 0
    while must_fit:
        fill_a_page()
        if must_fit:
            cross_a_page()
        include_lines.append("")
    
    include_lines.append(";Leftovers")
    for file in can_cross: #Append any left-overs.
        append_include_line(file)


    filename = f"All_Music_Data.s"
    file_path = os.path.join("Output_Files", filename)

    with open(file_path, "w", encoding="utf-8") as outfile:
        h.write_block(outfile, include_lines) 
    return

