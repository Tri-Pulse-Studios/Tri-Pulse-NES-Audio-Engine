# Define the bit pattern
pattern = ([1, 1, 0] * 18 + [0] * 18) * 9  # Total bits = 648

# Convert bits to bytes
byte_array = []
for i in range(0, len(pattern), 8):
    byte = 0
    for bit in pattern[i:i+8]:
        byte = (byte << 1) | bit
    byte_array.append(byte)

# Verify output length
assert len(byte_array) == 81, f"Expected 81 bytes, got {len(byte_array)}"

# Write to a .dmc (binary) file
with open("sawtooth_sample_long.dmc", "wb") as f:
    f.write(bytearray(byte_array))

print("DMC sample written to sawtooth_sample_long.dmc")