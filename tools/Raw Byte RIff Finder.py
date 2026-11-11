from collections import defaultdict
import sys

 

data_input = """

A5 03 00 E0 F3 F3 23 58 65 AD F6 F6 C3 07 C5 04
65 25 21 00 E0 97 CF 04 93 FB E4 B8 61 7D B0 60
11 11 7F 13 93 7E 26 7E 28 2B 60 7E 18 93 1B 1B
2B 7F 2A 26 D5 1F 60 7F 18 7F 1A 1B 1B 7F 2A 26
7F 28 CC 36 C9 36 B7 14 16 7F 18 7E 1B 7F 4D E0
F6 38 7B 89 40 C2 2A 1A D5 1F 60 FB B8 9E E1 21
48 79 2A 70 FE 85 C6 5F 05 46 F4 F4 E3 FD 58 87
CF FC A3 59 87 7A 38 FD 2C CD 5B 05 70 00 46 99
E0 B8 81 7D B0 40 25 30 7F 22 10 23 20 C3 85 7E
2A 10 7E 2C 20 C2 40 1A CE 36 D5 1F C0 A5 05 FA
03 E0 93 B3 C4 9F BB C4 9F FA 0C E0 93 70 C2 40
1A B8 B3 00 7E F0 77 27 2F 95 27 20 C6 B5 00 EE
C9 B5 FB FD E5 FA 0C A8 93 DD 80 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
69 01 80 91 2F 68 69 FC 44 68 69 44 06 9A 29 48
24 02 62 28 29 4B 29 68 7B 29 06 9A 00 54 B8 4E
09 70 06 70 01 E0 C6 20 00 E0 B8 91 40 26 30 21
10 23 20 C3 2C 2A 10 2B 20 00 70 9F B8 69 D3 05
44 41 08 46 26 08 8C 80 70 CD 13 C0 4D 07 E7 74
1D E8 11 11 11 C7 4E 70 CA 4E 90 26 C6 64 01 54
40 CC 4E 97 B5 C3 68 BB CC 4E 93 00 E0 95 CC 4E
90 09 CF 5C C7 64 C0 00 00 E0 93 C3 80 93 00 A8
27 15 15 27 1A 50 AA B1 51 A0 AA A5 51 BB B0 BD
00 70 D7 7B 28 15 15 21 15 15 54 58 50 C3 97 CB
94 95 CB 94 9B C4 94 56 11 88 80 21 28 02 46 2F
42 CB 94 9D 28 15 1F C4 97 18 80 C3 97 00 70 9D
C9 B4 99 CF A2 CE 94 CC B1 C0
"""

"""
51/08 5D-70-98 70 3A 3A 3A 3A 4A 7FB2 C506 93
71BE C506 CE06 C50B 71BC C506 B2 C506 B3
C40B C410 7FBF C30D C105 

45/08 5D-60-98 C22206 C12F 

75/0D C32C E2 5C-6A-93 16 5C-8B-95
18 5C-8B-94 18 C439 CE39 C441 5C-6B-93 16 
5C-48-91 14 C439 B3 C641 BD C83D C138 

29/12 5D-10-1D 26 2D 97 28 2F 97 
2D 28 97 26 21 97 CC62 B3 C365 
27 2F 97 BD C365 26 2D 95 E1 24 2B 22
29 97 21 28 97 E2 C365 C382 C162 

01/-- 57-99-97
47 17 19 51-99-99 2B C89D -9D-9D CA9D 
56-9E-ED-E9-EA 56-E9-9D-9E-9D C697 CD97 -9D-9E-ED 
CA9D D39B C197

    """






def find_repeated_sequences(byte_data, min_len=2, max_len=8):
    """
    Finds repeated sequences of bytes in a list of integers.

    Args:
        byte_data: List of integers (0-255) representing bytes.
        min_len: Minimum length of sequences to consider.
        max_len: Maximum length of sequences to consider.

    Returns:
        List of tuples: (sequence as tuple, list of start positions in hex)
    """
    n = len(byte_data)
    if n == 0:
        return []

    # Store occurrences: seq -> list of positions
    occurrences = defaultdict(list)

    for length in range(min_len, max_len + 1):
        for i in range(n - length + 1):
            seq = tuple(byte_data[i:i + length])
            occurrences[seq].append(i)

    # Keep only sequences that appear more than once
    repeats = {seq: positions for seq, positions in occurrences.items() if len(positions) > 1}

    # Precompute lengths for convenience
    seqs_by_len = defaultdict(list)
    for seq in repeats:
        seqs_by_len[len(seq)].append(seq)

    # For each sequence, decide whether to keep it.
    # Rule: If a sequence `s` is a contiguous subsequence of any longer sequence `L`
    # then we compare counts. Keep `s` only if count(s) > count(L) for every such L.
    filtered = {}

    # We'll iterate sequences in any order; logic does pairwise checks.
    for seq, positions in repeats.items():

        if  any(seq[i] == seq[i+1] == 0 for i in range(len(seq)-1)):
            continue #If any 2 $00s in a row

        seq_len = len(seq)
        seq_count = len(positions)
        drop = False

        # Examine only strictly longer sequences
        for longer_len in range(seq_len + 1, max_len + 1):
            for longer in seqs_by_len.get(longer_len, []):
                longer_positions = repeats[longer]
                longer_count = len(longer_positions)

                # Check if `seq` exists as a contiguous subsequence inside `longer`
                # (for any offset within `longer`)
                found_inside = False
                max_off = longer_len - seq_len
                for off in range(max_off + 1):
                    if longer[off:off + seq_len] == seq:
                        found_inside = True
                        break

                if not found_inside:
                    continue

                # If any longer sequence that contains `seq` has occurrence count >= seq_count,
                # we drop the shorter `seq`. (User requested "only keep shorter if it has more entries")
                if longer_count >= seq_count:
                    drop = True
                    break
            if drop:
                break

        if not drop:
            filtered[seq] = positions

    # Convert start positions to hex and sort results for readability:
    # sort primarily by length descending, then by frequency descending, then hex positions
    result = sorted(
        ((seq, [hex(p) for p in pos]) for seq, pos in filtered.items()),
        key=lambda item: (-len(item[0]), -len(item[1]), item[1])
    )

    return result


# ========================
# Example Usage
# ========================
if __name__ == "__main__":
    
    # Strip and convert to list of integers (ignore empty tokens)
    byte_data = [int(x, 16) for x in data_input.split() if x]

    no_padding_bytes = []
    i = 0

    while i < len(byte_data):
        if byte_data[i] != 0:
            # Non-zero → keep
            no_padding_bytes.append(byte_data[i])
            i += 1
            continue

        # We found a zero → count group size
        start = i
        while i < len(byte_data) and byte_data[i] == 0:
            i += 1
        count = i - start

        if count <= 2:
            # Keep single 0 or pair
            no_padding_bytes.extend([0] * count)

    print(f"Loaded {len(no_padding_bytes)} bytes.")
    print(f"Uses {len(byte_data) - len(no_padding_bytes)} padding bytes.")

    repeats = find_repeated_sequences(byte_data, min_len=3, max_len=255)

    # Print results
    for seq, positions in repeats:
        print(f"Sequence: {' '.join(f'{b:02X}' for b in seq)} | Addresses: {positions}")

    print()
