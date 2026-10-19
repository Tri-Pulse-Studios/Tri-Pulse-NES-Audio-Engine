from math import floor
from pathlib import Path

def create_triangle_wave(bits_total, wave_count):
    bits_per_wave = bits_total // wave_count
    bits = []
    for _ in range(wave_count):
        base_half_wave = bits_per_wave // 2
        
        ones_len = base_half_wave
        zeros_len = base_half_wave
        
        wave = [1] * ones_len + [0] * zeros_len
        
        # Calculate padding needed to reach exact bits_per_wave length
        padding = bits_per_wave - (ones_len + zeros_len)
        wave += [0] * padding  # pad with zeros if needed
        
        bits.extend(wave)

    # Pad with zeros if total bits is less than bits_total
    bits += [0] * (bits_total - len(bits))
    return bits



def bits_to_bytes(bits):
    byte_array = bytearray()
    for i in range(0, len(bits), 8):
        byte_val = 0
        for j in range(8):
            byte_val |= (bits[i + j] << (7 - j))

        byte_array.append(byte_val)
    return byte_array

def main():
    print("DMC Triangle Wave Generator with bit-reversed bytes")
    byte_size = int(input("Enter sample size in bytes: "))
    wave_count = int(input("Enter number of triangle waves: "))

    bits_total = byte_size * 8
    bits = create_triangle_wave(bits_total, wave_count)
    dmc_bytes = bits_to_bytes(bits)

    filename = f"triangle_{wave_count}_waves_{byte_size}bytes_reversed.dmc"
    with open(filename, "wb") as f:
        f.write(dmc_bytes)

    print(f"Generated {filename} with {wave_count} waves over {byte_size} bytes.")

if __name__ == "__main__":
    main()
