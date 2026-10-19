# Define the bit pattern
pattern = ([1, 1, 0, 1, 0] * 11 + [0] * 13) * 2

# Convert bits to bytes
byte_array = []
for i in range(0, len(pattern), 8):
    byte = 0
    for bit in pattern[i:i+8]:
        byte = (byte << 1) | bit
    byte_array.append(byte)

# Write to a .dmc file
with open("sawtooth_custom.dmc", "wb") as f:
    f.write(bytearray(byte_array))

print("Wrote sawtooth_custom.dmc")
