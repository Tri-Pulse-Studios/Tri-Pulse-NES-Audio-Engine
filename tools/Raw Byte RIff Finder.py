from collections import defaultdict
import sys

 

data_input = """

01 00 80 C0 01 00 80 C0 89 04 55 01 01 01 14 50
44 C4 0A 04 09 04 08 04 09 CF 0A 93 B1 C4 0A BD
C3 0E B3 BF CA 11 72 B9 C4 0A 7E B2 C4 1F B5 C8
11 D6 1B 7F B5 C6 1D 73 BE C3 1D C6 13 B3 7E BB
C6 1D 73 B2 C5 39 7D BC C6 1D 72 B4 C5 39 7E BB
C6 1D B5 C8 11 C0 6D 04 70 C2 4C 0A 00 C6 1D C5
39 C0 

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


