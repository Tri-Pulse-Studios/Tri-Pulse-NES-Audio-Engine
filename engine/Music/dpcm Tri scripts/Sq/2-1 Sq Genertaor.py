def pad_half(bits, target_length=68):
    """Pad bits with zeros up to target_length bits."""
    if len(bits) > target_length:
        raise ValueError(f"Half pattern too long ({len(bits)} bits), max is {target_length}")
    return bits + [0] * (target_length - len(bits))

def get_pattern(x, y):
    base = [1]*x + [bit for pair in ([0,1] for _ in range(y)) for bit in pair] + [0]*x
    half = pad_half(base, 68)
    full_pattern = half + half
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

    bits = get_pattern(x, y)
    assert len(bits) == 136, f"Total pattern length is {len(bits)}, expected 136 bits (17 bytes)"

    byte_data = bits_to_bytes(bits)

    with open("fake_square_17byte_padded.dmc", "wb") as f:
        f.write(bytearray(byte_data))

    print(f"Wrote fake_square_17byte_padded.dmc with pattern:")
    print(f"Each half: [1]*{x} + [0,1]*{y} + [0]*{x} padded to 68 bits")
    print("Pattern repeated twice for full 136 bits")

if __name__ == "__main__":
    main()
    print()
