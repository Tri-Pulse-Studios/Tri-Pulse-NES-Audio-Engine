from collections import defaultdict
import sys

 

data_input = """

49 05 00 24 05 06 93 54 05 03 45 36 7F 19 05 7E
20 F9 0D 80 80 E4 10 25 15 23 13 25 E4 15 15 50
55 54 55 46 CE 16 97 B5 D0 16 BB D0 16 00 82 F2
20 0C 04 93 0C 09 93 1C 1D 0F 08 0D 09 0C 09 D2
2D B3 40 00 12 C8 2F 0C 08 B2 E5 4C C6 43 C3 4B
FF 00 65 02 70 CF 02 70 FC 00 D0 93 D6 6D 93 B5
CA 6D 0F 11 0D 11 0B 09 09 09 C5 7E BB E8 3A F8
02 0A 14 E2 05 54 1A 1B 0D 15 09 09 0D 09 C7 6D
05 61 40 C7 91 16 18 1F 6A 20 C7 83 C9 91 08 0A
B5 08 22 06 09 05 09 13 15 51 07 08 B2 C9 91 06
08 8A B8 95 11 10 01 08 01 09 93 11 10 93 B3 CA
A4 C6 B8 CF A4 B2 C5 B9 BF CA A4 BE CA A4 B5 C5
B6 C1 58 65 05 C4 54 B8 35 75 B0 CF 15 95 C3 16
03 15 71 E4 0A 05 0C 04 B3 A2 B6 C6 1B 18 18 51
56 34 C6 C7 D4 CE 70 C5 E2 C4 E2 B8 3D DC 2D B3
E2 09 22 07 09 C6 95 09 B3 C3 9D 07 FF 44 00 00


6E 20 E3 B8 24 42 54 40 95 48 44 47 05 11 01 12
05 11 FB FE 82 B8 B6 CF 05 02 47 E5 FD 02 07 51
54 97 3A 50 AA 53 0A 07 02 0A 69 20 BD C5 22 05
01 0A 68 20 B3 C8 22 BF C5 22 06 03 0A BE C5 2D
FE 88 C1 14 4B 4A B8 55 D0 05 93 00 D0 93 B4 E5
C6 38 C6 22 03 0A BE C8 22 C1 C7 51 08 00 0C 03
6C 44 03 7E 20 43 41 43 24 22 AA B5 C5 65 93 BB
C3 6C FD 5D 34 34 46 A5 5B 53 32 92 5C 68 35 68
85 C1 65 00 08 06 93 05 6C F6 4B 50 77 95 17 F6
DB 50 88 90 09 08 04 08 0E 93 08 16 F4 03 D0 CC
A7 9B BF C5 9C 93 B1 18 28 18 39 28 18 18 50 88
54 88 97 CC A7 F6 63 08 04 90 0C 18 91 03 09 22
C4 C6 19 19 09 08 09 09 09 09 D5 B5 BF D5 B5 B2
C9 B5 BD CC BE 0A 5B 50 99 09 5B B2 C4 D7 BF 92
50 AA CB D5 BF 50 99 29 C6 C4 39 B1 C6 E5 94 BD
50 99 C3 E7 C8 C2 B1 A4 C1 9C 00 00 00 00 00 00


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
import sys

#========================================
## Riff Extensions
#========================================

def find_riffs(byte_data, address_base=0):
    """
    Find all short and long Riff commands.

    Short:
        C3-DF, followed by target low byte.
        Length = opcode - C0.

    Long:
        C2, length, target low byte.
    """

    riffs = []

    for i, opcode in enumerate(byte_data):

        if 0xC3 <= opcode <= 0xDF:
            if i + 1 >= len(byte_data):
                continue

            length = opcode - 0xC0
            target_low = byte_data[i + 1]
            command_size = 2


        elif opcode == 0xC2:
            if i + 2 >= len(byte_data):
                continue

            length = byte_data[i + 1]
            target_low = byte_data[i + 2]
            command_size = 3


        else:
            continue

        call_address = address_base + i

        # Riff target shares the call's high byte.
        target_address = (
            (call_address & 0xFF00) | target_low
        )

        target_index = target_address - address_base

        # Verify that the referenced data exists.
        if target_index < 0:
            continue

        if target_index + length > len(byte_data):
            continue

        riffs.append({
            "call_index": i,
            "call_address": call_address,
            "opcode": opcode,
            "command_size": command_size,
            "target_address": target_address,
            "target_index": target_index,
            "length": length,
            "data": byte_data[target_index:target_index + length]
        })

    return riffs



def analyze_riff_extensions(byte_data, riffs, address_base=0):
    """
    Compare the data surrounding each Riff target against
    the data surrounding the Riff call.

    Finds matching bytes that could be included by extending
    the Riff backwards and/or forwards.
    """

    results = []

    for riff in riffs:

        call = riff["call_index"]
        target = riff["target_index"]
        length = riff["length"]
        command_size = riff["command_size"]

        call_after = call + command_size
        target_after = target + length

        backward = 0
        forward = 0

        # -------------------------------------------------
        # Backward extension
        # -------------------------------------------------

        max_backward = min(
            target & 0xFF,
            call,
            target
        )

        while backward < max_backward:

            a = byte_data[call - 1 - backward]
            b = byte_data[target - 1 - backward]

            if a != b:
                break

            backward += 1

        # -------------------------------------------------
        # Forward extension
        # -------------------------------------------------

        max_forward = min(
            255 - length,
            len(byte_data) - call_after,
            len(byte_data) - target_after
        )

        while forward < max_forward:

            a = byte_data[call_after + forward]
            b = byte_data[target_after + forward]

            if a != b:
                break

            forward += 1

        # -------------------------------------------------
        # Capture surrounding data
        # -------------------------------------------------

        # Include two additional context bytes beyond
        # the possible extension, when available.

        before_count = 0
        after_count = 0

        if backward:
            before_count = min(
                backward + 2,
                call,
                target
            )

        if forward:
            after_count = min(
                forward + 2,
                len(byte_data) - call_after,
                len(byte_data) - target_after
            )

        before_call = byte_data[
            call - before_count:call
        ]

        before_target = byte_data[
            target - before_count:target
        ]

        after_call = byte_data[
            call_after:call_after + after_count
        ]

        after_target = byte_data[
            target_after:target_after + after_count
        ]

        # -------------------------------------------------
        # Construct extended sequence
        # -------------------------------------------------

        extended_target = target - backward
        extended_length = length + backward + forward

        extended_data = byte_data[
            extended_target:
            extended_target + extended_length
        ]

        original_data = riff["data"]

        results.append({
            **riff,

            "backward": backward,
            "forward": forward,

            "extended_target": extended_target,
            "extended_address": address_base + extended_target,

            "extended_length": extended_length,
            "extended_data": extended_data,

            "original_data": original_data,


            "command_data": byte_data[
                call:call + command_size
            ],

            "before_call": before_call,
            "before_target": before_target,

            "after_call": after_call,
            "after_target": after_target,

            "improved": backward > 0 or forward > 0
        })

    return results



def print_riff_extensions(results, address_base=0):

    improved = [
        riff for riff in results
        if riff["improved"]
    ]

    print()
    print("\nRiff Extension Analysis")
    print("-" * 40)

    for riff in improved:

        call_address = riff["call_address"]
        command_data = riff["command_data"]
        original_bytes = riff["original_data"]

        # -------------------------------------------------
        # Format the middle block
        # -------------------------------------------------

        command_text = " ".join(
            f"{b:02X}" for b in command_data
        )

        if len(original_bytes) >= 6:
            raw_text = (
                " ".join(f"{b:02X}" for b in original_bytes[:2])
                + " ... "
                + " ".join(f"{b:02X}" for b in original_bytes[-2:])
            )
        else:
            raw_text = " ".join(
                f"{b:02X}" for b in original_bytes
            )

        # -------------------------------------------------
        # Format the outer blocks
        # -------------------------------------------------

        before_call = " ".join(
            f"{b:02X}" for b in riff["before_call"]
        )

        before_target = " ".join(
            f"{b:02X}" for b in riff["before_target"]
        )

        after_call = " ".join(
            f"{b:02X}" for b in riff["after_call"]
        )

        after_target = " ".join(
            f"{b:02X}" for b in riff["after_target"]
        )

        # -------------------------------------------------
        # Align the three blocks
        # -------------------------------------------------

        core_width = max(
            len(command_text),
            len(raw_text)
        )

        command_text = command_text.center(core_width)
        raw_text = raw_text.center(core_width)

        before_width = max(
            len(before_call),
            len(before_target)
        )

        before_call = before_call.rjust(before_width)
        before_target = before_target.rjust(before_width)

        # -------------------------------------------------
        # Print
        # -------------------------------------------------

        print(
            f"\nRiff at ${call_address:02x} "
            f"(re-reads ${riff['target_address']:02x})"
        )

        print(
            f"    Re-Read:  "
            f"{before_call} "
            f"{command_text} "
            f"{after_call}"
        )

        print(
            f"    Raw Riff: "
            f"{before_target} "
            f"{raw_text} "
            f"{after_target}"
        )


#========================================
## New Riffs
#========================================

def strip_padding(byte_data):
    no_padding_bytes = []
    original_addresses = []

    i = 0

    while i < len(byte_data):

        if byte_data[i] != 0:
            no_padding_bytes.append(byte_data[i])
            original_addresses.append(i)
            i += 1
            continue

        start = i

        while i < len(byte_data) and byte_data[i] == 0:
            i += 1

        count = i - start

        if count <= 2:
            for address in range(start, i):
                no_padding_bytes.append(0)
                original_addresses.append(address)

    return no_padding_bytes, original_addresses


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


def find_repeated_sequences(
    byte_data,
    original_addresses,
    min_len=2,
    max_len=8
):

    if not byte_data:
        return []

    repeats = find_all_occurrences(byte_data, min_len, max_len)
    repeats = remove_overlapping_occurrences(repeats)
    filtered = filter_inner_sequences(repeats, max_len)

    return sorted(
        (
            (
                seq,
                [original_addresses[p] for p in positions]
            )
            for seq, positions in filtered.items()
        ),
        key=lambda item: item[1][0]
    )



if __name__ == "__main__":

    # Address corresponding to the first input byte.
    # Change this when analyzing a different ROM segment.
    ADDRESS_BASE = 0x0000

    byte_data = [
        int(x, 16)
        for x in data_input.split()
        if x
    ]

    # -------------------------------------------------
    # Original deduplication
    # -------------------------------------------------

    no_padding_bytes, original_addresses = strip_padding(
        byte_data
    )

    print(f"Loaded {len(no_padding_bytes)} bytes.")
    print(
        f"Uses {len(byte_data) - len(no_padding_bytes)} "
        f"padding bytes."
    )

    result = find_repeated_sequences(
        no_padding_bytes,
        original_addresses,
        min_len=3,
        max_len=255
    )

    print("\nNew Riff Analysis")
    print("-" * 40)

    print("\nSequences:")

    for seq, positions in result:

        values = " ".join(
            f"{b:02X}" for b in seq
        )

        addresses = " ".join(
            f"${p + ADDRESS_BASE:02X}"
            for p in positions
        )

        print(
            f"    Values: {values} | "
            f"Addresses: {addresses}"
        )

    # -------------------------------------------------
    # Riff analysis
    # -------------------------------------------------

    riffs = find_riffs(
        byte_data,
        ADDRESS_BASE
    )

    riff_results = analyze_riff_extensions(
        byte_data,
        riffs,
        ADDRESS_BASE
    )

    print_riff_extensions(
        riff_results,
        ADDRESS_BASE
    )

    print()