from collections import defaultdict
import sys

 

data_input = """

00 09 53 03 9A 9A 0A 53 36 40 46 02 C4 02 3A 1C
1F 10 2E 2B 1E BD FC CD 02 55 78 76 BD 25 DC 02
EB 6A 72 23 3A 5C A8 7E 0D 12 72 0B 12 73 18 8A
3F 3E 2A B5 70 CF 21 36 25 FB 00 00 04 00 07 CA
02 D1 0C 05 11 FC EB 5A A3 A3 8B 5A A3 B3 5A B2
EA 53 08 CD CD 0D 53 48 90 9B 07 C5 51 1D 19 1D
2F FA 08 28 B8 31 C8 47 FC C6 47 63 15 EB BC 5A
EC EF 29 B8 30 C3 47 68 FC 5A 86 BB 8A 8A 5A 86
8A BA 8A 5A EA FA A6 5A 86 BA B8 8A BD 3D 3B 21
EA FE 86 F0 67 06 67 C1 41 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
E9 50 65 A8 FA 08 5B 3D A6 CF CA D0 3C FA 04 FD
25 A3 BC 11 70 5C 0E 72 1D A4 21 5C 0E 11 BF C3
1A B8 29 17 1C 1D FA 0C 5B 1F 85 CD 75 80 2A 1A
1D 1C FA 0C B8 35 29 15 70 C7 13 2E B8 72 5C 02
19 27 26 12 14 FA 0C 5B 4D B7 CE 64 70 3A FA 03
26 11 1A 1D FA 03 1A 10 B4 2C 1A 19 C3 4D 27 B9
EA 12 1C 0A 3C 10 15 1C 2A 50 59 07 2C FA 03 FE
49 F8 01 49 B9 38 34 2B C0
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
