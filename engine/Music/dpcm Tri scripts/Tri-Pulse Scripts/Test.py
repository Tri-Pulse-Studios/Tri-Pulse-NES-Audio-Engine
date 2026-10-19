import os

SAMPLE_LEN = 68  # 34 ones + 34 zeros

OUT_DIR = "Kick_DMCs"

# ------------------------------
# helpers
# ------------------------------

def build_base_bits():
    """2 periods of 34 ones + 34 zeros"""
    return [1]*34 + [0]*34 + [1]*34 + [0]*34

def rotate_bits(bits, modulo):
    modulo %= len(bits)
    return bits[modulo:] + bits[:modulo]

def bits_to_dmc_bytes(bits):
    """Pack bits into bytes, LSB-first"""
    out = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for b in range(8):
            if i + b < len(bits):
                byte |= (bits[i+b] & 1) << b
        out.append(byte)
    return out

def confirm_overwrite(paths):
    if any(os.path.exists(p) for p in paths):
        print("WARNING: The following files already exist:")
        for p in paths:
            print(" ", os.path.basename(p))
        resp = input("Overwrite? [Y/N]: ").strip().lower()
        return resp == "y"
    return True

# ------------------------------
# main
# ------------------------------

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(script_dir, OUT_DIR)
    os.makedirs(out_dir, exist_ok=True)

    base_bits = build_base_bits()
    paths = []

    for modulo in range(68):
        # Piecewise mapping for DMC output level (0–34)
        dmc_output = modulo if modulo <= 34 else 68 - modulo
        mod_filename = f"Kick_TP_50%_M{modulo}_L{dmc_output}.dmc"
        path = os.path.join(out_dir, mod_filename)
        paths.append(path)

    if not confirm_overwrite(paths):
        print("Aborted.")
        return

    for modulo, path in enumerate(paths):
        rotated = rotate_bits(base_bits, modulo)
        data = bits_to_dmc_bytes(rotated)
        with open(path, "wb") as f:
            f.write(data)
        print(f"Wrote {path} (DMC output level {modulo if modulo <= 34 else 68 - modulo})")

if __name__ == "__main__":
    main()
