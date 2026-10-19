# fade_volume_grid.py
# Prints a clean 16x8 grid of VVVVvv results (like a multiplication table)
print("Fade-Out Volume Table (VVVVvv results after subtracting truncated 1/8 steps)\n")

# Header
header = "Vol | " + " ".join([f"Step{i:>2}" for i in range(8)])
print(header)
print("-" * len(header))

# Generate grid
#for V4 in range(64):
    #V = V4 // 4
for V in range(16):
    V4 = V * 4

    step = V4 // 4
    step = step / 2

    row = [f"{V:>3} |"]
    for i in range(8):
        faded = (V4 - (step * i)) / 4

        faded = ((faded * 8)//8)/1
       #faded = ((faded * 8)//2)/4

        row.append(f"{faded:5.0f}")
    print(" ".join(row))

print()
