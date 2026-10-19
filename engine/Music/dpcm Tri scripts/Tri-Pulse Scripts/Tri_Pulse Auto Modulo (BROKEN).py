import os
import sys
import string
# ===============================
# NES / DMC CONSTANTS
# ===============================

CYCLES_PER_FRAME = 29_780.5

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

DMC_PERIODS = {
    0: 428, 1: 380, 2: 340, 3: 320,
    4: 286, 5: 254, 6: 226, 7: 214,
    8: 190, 9: 160, 10: 142, 11: 128,
    12: 106, 13: 85, 14: 72, 15: 54,
}

SAMPLE_LEN = 68  # 34 ones + 34 zeros


# ===============================
# STEP 1 — COMPUTE MODULOS
# ===============================

def compute_modulos(rate_list):
    phase = 0.0
    modulos = []

    for rate in rate_list:
        modulos.append(int(phase) % SAMPLE_LEN)
        phase += CYCLES_PER_FRAME / DMC_PERIODS[rate]

    return modulos


# ===============================
# STEP 2 — SAMPLE GENERATION
# ===============================

def build_base_bits():
    return (
        [1] * 34 +
        [0] * 34 +
        [1] * 34 +
        [0] * 34
    )


def rotate_bits(bits, modulo):
    modulo %= len(bits)
    return bits[modulo:] + bits[:modulo]


def bits_to_dmc_bytes(bits):
    out = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for b in range(8):
            if i + b < len(bits):
                byte |= (bits[i + b] & 1) << b  # LSB-first
        out.append(byte)
    return out


def confirm_overwrite(paths):
    print("WARNING: The following files already exist:")
    for p in paths:
        print(" ", os.path.basename(p))  # show only the filename
    resp = input("Overwrite? [Y/N]: ").strip().lower()
    return resp == "y"

def write_dmc_files(modulos, rate_str, out_dir):
        # Build output paths (skip index 0 / letter A)
    paths = []
    work_items = []  # (index, path)

    for i in range(1, len(rates)):
        letter = string.ascii_uppercase[i]   # A skipped, B = index 1
        modulo = modulos[i]
        note = DMC_NOTE_NAMES[rates[i]]

        dmc_offset = modulo if modulo <= 34 else 68 - modulo
        letter_mod = f"{letter}_{dmc_offset}"     # e.g. B20, C9

        name = f"Kick_TP_50%_{rate_str}_{letter_mod}_{note}.dmc"
        path = os.path.join(out_dir, name)

        paths.append(path)
        work_items.append((i, path))

    existing = [p for p in paths if os.path.exists(p)]
    if existing and not confirm_overwrite(existing):
        print("Aborted.")
        sys.exit(1)

    # Step 2
    base_bits = build_base_bits()

    for i, path in work_items:
        rotated = rotate_bits(base_bits, modulos[i])
        data = bits_to_dmc_bytes(rotated)

        with open(path, "wb") as f:
            f.write(data)

        print(f"Wrote {name}")
# ===============================
# MAIN
# ===============================

def main(rates):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(script_dir, "Kick_DMCs")
    os.makedirs(out_dir, exist_ok=True)

    rate_str = "".join(str(r) for r in rates)

    # Step 1
    modulos = compute_modulos(rates)

    print("Frame modulos:")
    for i, (r, m) in enumerate(zip(rates, modulos)):
        print(f"index {i}, rate ${r:X}: {m}")

    write_dmc_files(modulos, rate_str, out_dir)


if __name__ == "__main__":
    rates = [8, 4, 0]
    main(rates)

print()