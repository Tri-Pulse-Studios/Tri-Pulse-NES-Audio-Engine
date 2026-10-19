def pad_segment(bits, target_length=72):
    """Pad bits with zeros up to target_length bits."""
    if len(bits) > target_length:
        raise ValueError(f"Segment too long ({len(bits)} bits), max is {target_length}")
    return bits + [0] * (target_length - len(bits))

def get_pattern_81(x, y):
    base = [1]*x + [bit for pair in ([0,1] for _ in range(y)) for bit in pair] + [0]*x
    segment = pad_segment(base, 72)
    full_pattern = segment * 9
    return full_pattern

def bits_to_bytes(bits):
    byte_array = []
    for i in range(0, len(bits), 8):
        byte = 0
        for bit in bits[i:i+8]:
            byte = (byte << 1) | bit
        byte_array.append(byte)
    return byte_array

def main():
    x = int(input("Enter plateau width (x): "))
    y = int(input("Enter toggle count (y): "))

    bits = get_pattern_81(x, y)
    expected_length = 72 * 9
    assert len(bits) == expected_length, f"Total length is {len(bits)}, expected {expected_length} bits"

    byte_data = bits_to_bytes(bits)

    with open("fake_square_81byte.dmc", "wb") as f:
        f.write(bytearray(byte_data))

    print(f"Wrote fake_square_81byte.dmc with pattern:")
    print(f"Each segment: [1]*{x} + [0,1]*{y} + [0]*{x} padded to 72 bits")
    print("Pattern repeated 9 times for total 81 bytes")

if __name__ == "__main__":
    main()
