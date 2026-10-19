
def bits_to_bytes(bits):
    bytes_out = []
    for i in range(0, len(bits), 8):
        byte = 0
        for b in range(8):
            if i + b < len(bits):
                byte |= (bits[i + b] << b)  # LSB-first
        bytes_out.append(byte)
    return bytes_out



def build_core_17_2_bits():
    bits = []
    bits += [0] * 8            # Front padding
    bits += [1] * 17           # First pulse
    bits += [0] * 51           # Middle gap
    bits += [1] * 17           # Second pulse
    bits += [0] * (51 - 8)     # Tail padding to balance
    return bits



def generate_65_8_from_core(core_bits, mode='snap'):
    bits = core_bits.copy()

    deltas = [3, 0, 0, 0, 0, 0, 0, -3] #The 3 is a result of the 17-2
    sub_deltas = deltas[2:] #Loop the last 6 deltas

    # Initial compensation: (17-2 ends in 43 zeros), minus 3 from overflow → 5 bits
    bits += [0] * (5 + deltas[1])  # Adjust pre-padding

    for delta in sub_deltas:
        bits += [1] * 16
        bits += [0] * (49 + delta)

        # Convert to bytes and trim the $00 at the end that was pre-pended.
    bytes_out = bits_to_bytes(bits)

    if bytes_out[-1] == 0x00:
        bytes_out = bytes_out[:-1]  # Pop the last $00
    else:
        raise ValueError (F"malformed data. Should end w/ 00 byte.")

    if len(bytes_out) != 65:
        raise ValueError (F"malformed data. Should be exactly 65 bytes.")

    return bytes_out



def build_core_17_1_bits():
    bits = []
    bits += [0] * 8            # Front padding
    bits += [1] * 17           # Pulse
    bits += [0] * (119 - 8)   # Tail padding to balance
    return bits
#136 bits in 17-1

#520 bits total.
#130 bits per wave.
#Wants 16.25 to be 1s. Is round up to 17 better for consistancy?
def generate_65_4_from_core(core_bits):
    bits = core_bits.copy()

    deltas = [0, 0, 0, 0] #The 3 is a result of the 17-2
    sub_deltas = deltas[1:] #1 loop is inside the 17-1

    # Initial compensation: (17-2 ends in 43 zeros), minus 3 from overflow → 5 bits
    bits += [0] * (2 + deltas[1])  # Adjust pre-padding

    for delta in sub_deltas:
        bits += [1] * 17
        bits += [0] * (113 + delta)

        # Convert to bytes and trim the $00 at the end that was pre-pended.
    bytes_out = bits_to_bytes(bits)

    if bytes_out[-1] == 0x00:
        bytes_out = bytes_out[:-1]  # Pop the last $00
    else:
        raise ValueError (F"malformed data. Should end w/ 00 byte.")

    if len(bytes_out) != 65:
        raise ValueError (F"malformed data. Should be exactly 65 bytes.")

    return bytes_out


def write_dmc_file(filename, byte_data):
    with open(filename, 'wb') as f:
        f.write(bytearray(byte_data))

def main():
    # Build core 17/2 or 17/1
    core_17_2_bits = build_core_17_1_bits()

    # Write 17-byte DMC sample (standard layout)
    bytes_17 = bits_to_bytes(core_17_2_bits)
    print("17-byte Wave:")
    print(" ".join(f"{b:02X}" for b in bytes_17))
    write_dmc_file("dmc_17byte_reference.dmc", bytes_17)

    # Build 65-byte sample (snap version)
    bytes_65 = generate_65_4_from_core(core_17_2_bits)
    print("\n65-byte Wave (Snap Padding):")
    print(" ".join(f"{b:02X}" for b in bytes_65))
    write_dmc_file("dmc_65byte_snap.dmc", bytes_65)

if __name__ == "__main__":
    main()
