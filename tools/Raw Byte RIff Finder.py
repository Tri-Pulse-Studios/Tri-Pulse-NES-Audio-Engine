from collections import defaultdict
import sys

 

data_input = """

31 09 B8 31 1D BB 52 61 D0 60 C8 02 90 0E 00 00
93 E3 B8 89 10 16 15 06 08 15 03 28 10 C5 14 08
18 16 15 16 15 13 13 01 08 03 C8 C8 14 13 58 68
65 C7 24 F0 87 7C 1A 77 13 7D 16 C6 35 FB 7C 1A
78 13 F0 87 7B 1D 78 15 7D 18 C6 44 7B 1D 93 DC
33 FD E2 DE 33 FB E9 C8 02 9F E3 B8 9D 00 90 C5
6B C3 1F 25 11 61 C5 5F 16 25 41 15 16 18 0D 18
93 1F 0F 00 E1 B8 5D 09 00 05 00 02 00 01 00 C0
99 05 C4 7B FA 06 00 93 B8 59 E2 56 A3 D8 A8 65
C5 8B 90 0A FC 00 08 E3 70 C2 23 33 00 FC 93 56
6A BA 1A 6A AA 56 58 A8 18 58 A2 CC 9F C0 21 07
80 91 13 5B 55 31 92 80 91 0C B8 9E E1 54 50 86
08 18 06 18 15 85 C8 BD 25 11 01 50 C8 BD 83 55
30 53 56 23 C0 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1D 06 D0 20 10 54 AF BC CB 20 BD C5 2B 80 CB B7
C4 02 00 00 C3 07 B2 C5 2B 30 76 B2 C4 02 CA 14
50 66 20 C3 20 00 18 06 03 00 05 50 66 C8 25 54
60 87 B3 D0 20 30 12 B9 C3 46 D1 20 98 B5 D1 20
76 B2 D1 20 45 BC C3 42 BD C6 3E A9 C0 01 7B 15
90 1A 04 06 04 05 93 50 11 05 08 04 04 93 50 11
11 CA 64 35 16 50 95 11 51 35 15 16 51 91 11 CE
61 9D 70 D3 4E CE 61 95 C7 61 CF 52 C3 6F C4 78
C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
A5 03 00 E0 F3 F3 23 58 65 AD F6 F6 C3 07 C5 04
65 25 21 00 E0 97 CF 04 93 FB C2 29 2E C9 49 B7
14 16 7F 18 7E 1B 7F 4D E0 F6 38 7B 89 40 E4 B8
61 7D B0 60 11 11 7F 13 93 7E 26 7E 28 2B 60 7E
18 93 1B 1B 2B C3 50 D4 33 60 7F 18 7F 1A 1B 1B
7F 2A 26 7F 28 CC 49 D4 33 60 FB B8 9E E1 21 48
79 2A 70 FE 85 C6 5E 05 46 F4 F4 E3 FD 58 87 CF
FC A3 59 87 7A 38 BF 21 CD 5A 05 70 00 46 99 E0
B9 40 25 30 7F 22 10 23 20 C3 81 7E 2A 10 7E 2C
20 C2 40 1A CF 4A C0 A5 05 FA 03 E0 93 B3 C4 99
BB C4 99 FA 0C E0 93 70 C3 91 B8 C2 E3 00 54 F0
77 23 2B 95 23 20 C6 AF 00 EE C9 AF FB FD E5 FA
08 A8 93 D8 7F 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
69 01 80 91 2F 68 69 FC 44 68 69 44 06 9A 29 48
24 02 62 28 29 4B 29 68 7B 29 06 B6 80 B8 4E 09
70 06 70 01 E0 C6 1F 00 E0 B8 85 40 29 30 24 10
26 20 C3 2B 2D 10 2E 20 00 70 9F B9 D3 05 44 41
08 46 26 08 A8 40 70 CC 13 C0 4D 07 E7 74 1D E8
11 11 11 C7 4C 70 CA 4C 90 26 C6 62 01 54 40 CC
4C 97 B5 C3 66 BB CC 4C 93 00 E0 95 CC 4C 90 09
CF 5A C7 62 C0 00 00 E0 93 C3 7E 93 00 A8 27 15
15 27 1A 50 AA B1 51 A0 AA A5 51 BB B0 BD 00 70
D7 79 28 15 15 21 15 15 54 58 50 C3 95 CB 92 95
CB 92 9B C4 92 56 11 88 80 21 28 02 46 2F 42 CB
92 9D 28 15 1F C4 95 18 80 C3 95 00 70 9D C9 B2
99 CF A0 CE 92 CC AF C0 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00

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



from collections import defaultdict


def strip_padding(byte_data):
    no_padding_bytes = []
    i = 0

    while i < len(byte_data):

        if byte_data[i] != 0:
            no_padding_bytes.append(byte_data[i])
            i += 1
            continue

        start = i

        while i < len(byte_data) and byte_data[i] == 0:
            i += 1

        count = i - start

        if count <= 2:
            no_padding_bytes.extend([0] * count)

    return no_padding_bytes


def find_all_occurrences(byte_data, min_len, max_len):
    occurrences = defaultdict(list)

    n = len(byte_data)

    for length in range(min_len, max_len + 1):
        for i in range(n - length + 1):
            seq = tuple(byte_data[i:i + length])
            occurrences[seq].append(i)

    # Keep only sequences appearing more than once.
    return {
        seq: positions
        for seq, positions in occurrences.items()
        if len(positions) > 1
    }


def remove_overlapping_occurrences(repeats):
    filtered = {}

    for seq, positions in repeats.items():
        seq_len = len(seq)

        valid_positions = []
        last_end = -1

        # Greedy left-to-right selection of independent occurrences.
        for pos in sorted(positions):
            if pos >= last_end:
                valid_positions.append(pos)
                last_end = pos + seq_len

        # Require at least two independent occurrences.
        if len(valid_positions) > 1:
            filtered[seq] = valid_positions

    return filtered


def filter_inner_sequences(repeats, max_len):

    # Precompute lengths for convenience.
    seqs_by_len = defaultdict(list)

    for seq in repeats:
        seqs_by_len[len(seq)].append(seq)

    filtered = {}

    for seq, positions in repeats.items():

        # Ignore sequences containing two consecutive $00 bytes.
        if any(seq[i] == seq[i + 1] == 0 for i in range(len(seq) - 1)):
            continue

        seq_len = len(seq)
        seq_count = len(positions)
        drop = False

        # Examine only strictly longer sequences.
        for longer_len in range(seq_len + 1, max_len + 1):
            for longer in seqs_by_len.get(longer_len, []):

                longer_positions = repeats[longer]
                longer_count = len(longer_positions)

                # Check whether seq exists inside longer.
                found_inside = False
                max_off = longer_len - seq_len

                for off in range(max_off + 1):
                    if longer[off:off + seq_len] == seq:
                        found_inside = True
                        break

                if not found_inside:
                    continue

                # Drop shorter sequence if longer has equal
                # or greater occurrence count.
                if longer_count >= seq_count:
                    drop = True
                    break

            if drop:
                break

        if not drop:
            filtered[seq] = positions

    return filtered


def format_results(filtered):

    result = sorted(
        (
            (seq, [hex(p) for p in positions])
            for seq, positions in filtered.items()
        ),
        key=lambda item: (
            -len(item[0]),       # Sequence length descending
            -len(item[1]),       # Frequency descending
            item[1]              # Address ascending
        )
    )

    return result


def find_repeated_sequences(byte_data, min_len=2, max_len=8):

    if not byte_data:
        return []

    repeats = find_all_occurrences(byte_data, min_len, max_len)
    repeats = remove_overlapping_occurrences(repeats)
    filtered = filter_inner_sequences(repeats, max_len)

    return format_results(filtered)


if __name__ == "__main__":

    byte_data = [int(x, 16) for x in data_input.split() if x]

    no_padding_bytes = strip_padding(byte_data)

    print(f"Loaded {len(no_padding_bytes)} bytes.")
    print(f"Uses {len(byte_data) - len(no_padding_bytes)} padding bytes.")

    result = find_repeated_sequences(no_padding_bytes, min_len=3, max_len=255)

    print("\nSequences:")

    for seq, positions in result:
        values = " ".join(f"${b:02x}" for b in seq)
        addresses = " ".join(f"${int(p, 16):03x}" for p in positions)

        print(f"    Values: {values} | Addresses: {addresses}")

    print()


