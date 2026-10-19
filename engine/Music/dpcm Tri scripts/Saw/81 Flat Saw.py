# Build the pattern: ([1,1,0,1,0] * 12 + [0] * 12) * 3
pattern = ([1, 1, 0, 1, 0] * 12 + [0] * 12) * 9

# Convert bits to bytes
def bits_to_bytes(bits):
    byte_array = []
    for i in range(0, len(bits), 8):
        byte = 0
        for bit in bits[i:i+8]:
            byte = (byte << 1) | bit
        byte_array.append(byte)
    return byte_array

bytes_out = bits_to_bytes(pattern)

# Verify it's 81 bytes
assert len(bytes_out) == 81, f"Expected 81 bytes, got {len(bytes_out)}"

# Write to .dmc file
with open("sawtooth_81byte.dmc", "wb") as f:
    f.write(bytearray(bytes_out))

print("Wrote sawtooth_81byte.dmc")
