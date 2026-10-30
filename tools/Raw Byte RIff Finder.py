from collections import defaultdict
import sys

 

data_input = """

55 00 38 5E 01 05 08 58 5A 73 B8 65 7B B0 E2 5F
DD 0D 0D 0D 71 3C 71 1C 18 FD 18 11 20 B8 66 11
20 38 51 60 65 30 BB 83 40 C6 1F 10 B3 67 55 72
CA 55 E0 AF 55 07 83 BA 54 DB 10 24 19 3B 10 5D
0B 0B 59 7B B9 69 68 B8 61 E1 30 32 49 17 16 17
10 12 6B 55 67 97 14 16 19 FC 21 22 24 66 24 26
24 42 FD 1B 16 3D 29 16 59 2B B7 BC 1D 10 11 26
1A 54 0B A8 59 AB A8 66 E3 51 16 A6 DB B7 67 56
9B 64 64 33 64 C3 7E FD FD BB 36 C3 7E A4 DB EE
9D 6B 67 6B 64 0D 6C FF 00 24 00 70 D9 02 B8 51
E4 6A 6D 0F 6C 68 6D 6A 36 38 BD 69 68 36 39 34
31 62 67 64 E2 BB 11 14 19 FC A3 D5 9E BB E2 FF
50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
26 40 B8 51 E2 51 5D BD 89 FC E1 66 72 31 36 68
74 61 71 B0 39 71 34 39 7F 3D 6B 7F 28 29 2B 71
69 7F 26 7F 28 29 69 36 31 68 46 18 16 65 C7 02
E0 36 39 3B 3D 6D 28 2B 2D 6D 69 8B B9 50 83 FD
6D 50 41 D9 B1 1E 1F 6E BD 50 51 D8 B4 1B 1D C0
C9 57 00 2D E5 B8 51 71 11 16 19 FC A2 FD 71 1D
19 16 A2 B2 CC 57 B8 51 7E 13 16 1A FC A2 FD 7E
1F 1A 16 A2 CC 68 CE 55 BE CC 68 CE 66 CE 66 D3
55 BF CC 57 70 CE 55 C3 84 BC 70 CC 68 B3 70 CC
57 E2 C7 50 E3 B8 8D DC 0B 65 67 65 84 24 25 62
34 35 84 22 24 65 69 8B 40 CF 54 70 CC 57 C0 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
55 06 54 01 D8 2F 2A 23 BF 21 10 5C 0D 95 2D 10
31 B8 35 E8 54 11 11 54 1D 11 B5 C6 14 54 33 33
FD 54 33 3F B5 54 23 A7 E6 3F 3E 54 2C C7 3A 27
1A 38 54 FA A0 33 3D 7C 31 92 B8 51 51 1D D1 11
B8 31 11 14 19 FC A3 C3 11 21 50 D1 11 A3 B5 C5
49 23 50 F3 33 D6 20 BD C3 36 B4 C3 36 12 16 19
FC A3 12 00 2D E7 B8 19 04 6C 06 6C 08 6C 7F FC
68 28 26 23 7E FD 04 6C 66 6A C5 6C 7E FD 28 2A
2C C4 68 63 67 68 38 36 04 6C 01 6C 03 6C 51 03
33 33 B6 51 19 79 45 E6 7C 62 6E BF A9 B5 C3 98
67 68 69 C5 93 FC 22 50 22 95 2E 50 22 25 BF C8
A6 92 BF 22 C3 AB 59 5A 52 BF C4 A6 59 9E 32 B2
C3 BA 2E E9 C0 51 06 70 00 BD C2 39 10 CC 14 C2
50 55 6E 60 BF 98 B2 6F 60 C0 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 C3 07 95 40 15 15 21 C5 15 24 C5 15 C8 14 75
55 28 C5 08 28 5C 55 15 15 15 51 54 45 55 C6 07
18 5C 55 50 85 55 C3 0A 21 5C 55 13 15 15 28 C5
29 C6 28 93 C2 2C 07 C3 41 93 C3 3E C3 48 33 25
15 41 15 15 23 25 15 15 45 15 15 59 53 53 C3 39
45 C6 42 C3 41 43 15 15 35 25 C4 4A DF 39 C3 41
61 CD 07 C4 0D CD 07 48 C6 18 C4 61 C6 07 21 C9
15 C0
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
