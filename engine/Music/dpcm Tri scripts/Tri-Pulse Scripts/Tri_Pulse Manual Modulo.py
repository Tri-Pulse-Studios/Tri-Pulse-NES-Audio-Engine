import os
import sys
import string

# ===============================
# NES / DMC CONSTANTS
# ===============================

SAMPLE_LEN = 68  # 34 ones + 34 zeros

# Note LUT for DMC rates 0–$F
DMC_NOTE_NAMES = {
    0x0: "B1",
    0x1: "Cs2",
    0x2: "Ds2",
    0x3: "E2",
    0x4: "Fs2",
    0x5: "Gs2",
    0x6: "As2",
    0x7: "B2",
    0x8: "Cs3",
    0x9: "E3",
    0xA: "Fs3",
    0xB: "Gs3",
    0xC: "B3",
    0xD: "Ds4",
    0xE: "Fs4",
    0xF: "B4",
}


# ===============================
# HELPERS
# ===============================

def build_base_bits():
    """2 periods of triangle: 34 ones + 34 zeros each"""
    return [1] * 34 + [0] * 34 + [1] * 34 + [0] * 34


def rotate_bits(bits, modulo):
    modulo %= len(bits)
    return bits[modulo:] + bits[:modulo]


def bits_to_dmc_bytes(bits):
    """Pack bits into bytes, LSB-first (DMC order)"""
    out = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for b in range(8):
            if i + b < len(bits):
                byte |= (bits[i + b] & 1) << b
        out.append(byte)
    return out


def confirm_overwrite(paths):
    print("WARNING: The following files already exist:")
    for p in paths:
        print(" ", os.path.basename(p))
    resp = input("Overwrite? [Y/N]: ").strip().lower()
    return resp == "y"


# ===============================
# MAIN
# ===============================

def main(rates, manual_modulos):
    """
    rates: list of DMC rates (0-F)
    manual_modulos: list of integers, same length as rates
    """
    if len(rates) != len(manual_modulos):
        print("Error: rates and manual_modulos must have the same length")
        sys.exit(1)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(script_dir, "Kick_DMCs")
    os.makedirs(out_dir, exist_ok=True)

    rate_str = "".join(str(r) for r in rates)

    print("Using manual modulos:")
    for i, (r, m) in enumerate(zip(rates, manual_modulos)):
        print(f"index {i}, rate ${r:X}: modulo {m}")

    # Build output paths (skip index 0 / letter A)
    paths = []
    work_items = []

    for i in range(1, len(rates)):
        letter = string.ascii_uppercase[i]  # A skipped
        modulo = manual_modulos[i]

        # Map to DMC sample offset for naming
        dmc_offset = modulo if modulo <= 34 else 68 - modulo

        note = DMC_NOTE_NAMES[rates[i]]
        letter_mod = f"{letter}{dmc_offset}"
        name = f"Kick_TP_50%_{rate_str}_{letter_mod}_{note}.dmc"
        path = os.path.join(out_dir, name)

        paths.append(path)
        work_items.append((i, path))

    existing = [p for p in paths if os.path.exists(p)]
    if existing and not confirm_overwrite(existing):
        print("Aborted.")
        sys.exit(1)

    # Generate and write rotated DMC samples
    base_bits = build_base_bits()
    for i, path in work_items:
        rotated = rotate_bits(base_bits, manual_modulos[i])
        data = bits_to_dmc_bytes(rotated)

        with open(path, "wb") as f:
            f.write(data)

        print(f"Wrote {path}")


# ===============================
# EXAMPLE USAGE
# ===============================

if __name__ == "__main__":
    # Example rates
    rates = [8, 4, 0]
    # Example manually calculated modulos (0-based)
    manual_modulos = [0, 2, 37]  # first (index 0) will be skipped
    main(rates, manual_modulos)
