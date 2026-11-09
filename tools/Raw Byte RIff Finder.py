from collections import defaultdict
import sys

 
 
data_input = """
3D 04 00 D0 93 B8 3C E4 51 D1 D0 E1 1B 1D E2 C7
6A CA 07 95 C9 05 E3 B7 10 16 10 36 20 2B 20 C9
14 B7 2D 20 CD 14 2D 20 CB 31 80 B0 C3 36 C6 28
93 C9 05 E4 10 1D 10 50 DD C3 08 54 D0 D0 C3 36
C9 28 51 81 80 10 18 95 C6 42 28 10 18 20 18 10
C6 4A 95 B1 C9 4A BF CC 4A B2 C8 4A 92 BB C9 4A
C1 08 6D 01 F6 00 34 54 81 86 54 46 43 C4 67 86
DB CA 67 99 B8 0D C7 07 B8 BA 79 B0 E5 F5 68 7E
1D 11 16 A3 F0 6D C5 7F FB 70 D6 74 D8 74 B8 6D
E0 5C B8 DF B8 81 C3 05 C7 39 FC C5 90 8F C3 05
C6 42 FF 00 0D 01 CF 64 B8 89 E0 5C D6 48 D6 FC
88 84 C3 14 20 11 18 11 26 2B 16 28 C8 B2 1F 2B
CA B2 C5 B2 14 26 2B 18 2F C4 A8 86 9B 86 C3 D6
C7 39 A3 C5 C9 8D B8 0D E4 C6 42 C3 A8 01 D0 88
84 B1 C4 DD BF C8 DD 04 D0 06 D0 8D 8D 93 C1 A8
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
E3 56 B8 8A AB B8 A2 E0 7F FC 7B 10 8B 08 5B 7E
FD B1 D1 00 BF D4 00 B2 C7 00 B2 C6 00 56 A8 8B
BA B8 E0 B7 20 63 61 83 4B 48 2F C1 73 9D 00 00
D0 93 5B 18 3B 92 FD E4 30 30 28 26 3B 68 C4 39
6B C7 39 3F E0 FC 64 21 66 21 69 2B 88 C4 46 FD
88 80 CA 45 88 80 B8 3D 70 C2 23 00 B8 95 4A 41
23 61 B7 63 26 4A 46 C1 32 00 F6 00 34 54 66 61
9C 16 16 51 63 22 D0 7C 13 50 22 A4 14 14 42 22
51 54 50 54 62 66 12 16 C4 7C C6 80 51 33 22 C4
7C 25 C7 83 25 C3 83 C3 78 CA 8F 95 14 14 12 F4
F4 71 37 FB 22 25 C6 9E C3 78 CE 9C 70 D1 9C 95
C5 9C 39 FB 22 55 66 62 66 C3 78 CB B0 C5 B0 C9
9C C9 B0 C3 8C C1 76
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
