from pathlib import Path

# ===== CONFIG =====
INPUT_FILE = "Kick_TP_50%_"  # no .dmc needed
# ==================

def rotate_bytes(data, n):
    n %= len(data)
    return data[n:] + data[:n]

def main():
    script_dir = Path(__file__).resolve().parent
    in_path = script_dir / f"{INPUT_FILE}.dmc"

    if not in_path.exists():
        raise FileNotFoundError(f"Could not find {in_path.name} in {script_dir}")

    data = in_path.read_bytes()

    if len(data) != 17:
        raise ValueError(f"Expected 17 bytes, got {len(data)}")

    for i in range(1, 17):
        rotated = rotate_bytes(data, i)
        out_path = script_dir / f"{in_path.stem}_rot{i:02}.dmc"
        out_path.write_bytes(rotated)

if __name__ == "__main__":
    main()
