import math

def make_dmc_wave(byte_count, subwaves, duty_cycle):
    total_bits = byte_count * 8
    bits_per_subwave = total_bits / subwaves
    ones_per_subwave = round(bits_per_subwave * duty_cycle)

    dmc_bits = [0] * total_bits

    for i in range(subwaves):
        sub_start = round(i * bits_per_subwave)
        for j in range(ones_per_subwave):
            if sub_start + j < total_bits:
                dmc_bits[sub_start + j] = 1

    # Convert bit list into bytes
    dmc_bytes = []
    for i in range(0, len(dmc_bits), 8):
        byte = 0
        for b in range(8):
            if i + b < len(dmc_bits):
                byte |= (dmc_bits[i + b] << b)  # NES DMC uses bit-reversed order (LSB first)
        dmc_bytes.append(byte)

    return dmc_bytes

def main():
    import ast

    duty_input = input("Enter duty cycle as a decimal (e.g. 0.125): ").strip()
    wave_input = input("Enter list of tuples (e.g. ((81,6),(129,9),(177,14)) ): ").strip()

    try:
        duty_cycle = float(duty_input)
        wave_tuples = ast.literal_eval(wave_input)

        for idx, (byte_count, subwaves) in enumerate(wave_tuples):
            dmc_data = make_dmc_wave(byte_count, subwaves, duty_cycle)
            print(f"\nDMC Wave #{idx + 1} — Bytes: {byte_count}, Subwaves: {subwaves}")
            print(f"Hex Output (first 32 bytes):")
            print(' '.join(f'{b:02X}' for b in dmc_data[:32]))

            # Optional: write to file
            with open(f'dmc_wave_{idx + 1}_{byte_count}bytes.dmc', 'wb') as f:
                f.write(bytearray(dmc_data))

    except Exception as e:
        print("Error parsing input:", e)

if __name__ == "__main__":
    main()
    print()