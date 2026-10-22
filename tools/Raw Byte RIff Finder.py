from collections import defaultdict
import sys

 

data_input = """

91 01 21 26 28 11 26 28 92 24 28 2B 14 28 2D 18
2B 28 C0 01 02 80 91 05 B8 C1 F0 56 C3 32 FD 92
F6 50 C4 1C 8D 80 91 0E B8 CD F0 56 54 8A 15 92
F0 56 54 AD 58 92 F0 56 54 DF 8C 92 B7 FB 56 8A
36 56 13 DB 28 83 D0 16 C3 15 DD 28 DE 28 C1 16
7D 05 80 91 0F 40 89 4B 59 B9 BD 69 14 C8 55 C3
52 C8 55 9B C0 4D 05 01 A0 04 A0 81 84 06 A0 C0
00 41 91 0D 31 1E 4D 21 28 93 21 18 72 1E 2D 28
70 C9 77 C1 77
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
