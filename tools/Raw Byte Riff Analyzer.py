from collections import defaultdict
import sys

 

data_input = """

51 08 00 0C 03 6C 44 03 7E 20 43 41 43 24 22 AA
B5 C5 0A 93 BB C3 11 FD 04 22 0B 09 FC 04 09 4B
BF C9 17 B1 CD 17 B9 01 2B 06 09 4D BE C5 27 B1
C5 27 B5 C5 27 FD 5B 86 65 92 5C 9B 68 9B 88 C1
0A 00 08 06 93 05 6C F6 4B 50 77 95 17 F6 DB 50
88 90 09 08 04 08 0E 93 08 16 F4 03 D0 CC 65 9B
BF C5 5A 93 B1 18 28 18 39 28 18 18 50 88 54 88
97 CC 65 F6 63 08 04 90 0C 18 91 03 09 22 C4 84
19 19 09 08 09 09 09 09 D5 73 BF D5 73 B2 C9 73
BD CC 7C 0A 5B 50 99 09 5B B2 C4 95 BF 92 50 AA
CB 93 BF 50 99 29 C6 82 39 B1 C6 A3 94 BD 50 99
C3 A5 C8 80 B1 A4 C1 5A 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00


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