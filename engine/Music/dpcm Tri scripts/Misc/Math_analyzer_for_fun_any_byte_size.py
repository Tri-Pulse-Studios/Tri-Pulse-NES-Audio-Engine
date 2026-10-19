import math

# Ratio of semitone difference
def semitone_ratio(n):
    return 2 ** (n / 12)

# Difference in cents between ideal ratio and actual ratio
def cents_diff(k_unrounded, k_rounded):
    if k_rounded == 0:
        return float('nan')
    ratio = k_unrounded / k_rounded
    return 1200 * math.log2(ratio)

def analyze_k(base_k, x_max=200):
    """Check k +/- semitone offsets, looking for integer k = x/m."""
    results = {}
    for n in [-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8]:
        # Ideal target
        k_unrounded = base_k * semitone_ratio(n)
        k_rounded = round(k_unrounded)

        # Find integer solutions for x/m = k_rounded
        solutions = []
        for x in range(1, x_max+1):
            for m in range(1, x_max+1):
                if x % m == 0:  # must be integer
                    if x // m == k_rounded:
                        solutions.append((x, m))

        results[n] = {
            "k_unrounded": k_unrounded,
            "k_rounded": k_rounded,
            "error_cents": cents_diff(k_unrounded, k_rounded),
            "solutions": solutions
        }
    return results

def print_results(results, base_k):
    print(f"Results for base k = {base_k}")
    print(f"{'Semitone':>9} | {'k_unrounded':>12} | {'k_rounded':>9} | {'Error (�)':>9} | Solutions (x,m)")
    print("-"*60)
    for n, r in results.items():
        sol_str = ", ".join(f"{x}/{m}" for x, m in r["solutions"]) if r["solutions"] else "--"
        print(f"{n:9} | {r['k_unrounded']:12.4f} | {r['k_rounded']:9} | {r['error_cents']:9.3f} | {sol_str}")
    print()

# Example usage
if __name__ == "__main__":
    for base_k in range(70, 75):  # test a few base k's
        res = analyze_k(base_k)
        print_results(res, base_k)


target_k = 128.3669
max_x = 20

results = []

for x in range(1, max_x + 1):
    numerator = (16 * x + 1) * 8
    for m in range(1, 3*x + 1):
        k = numerator / m
        if 128 < k < 129:
            error = abs(k - target_k)
            results.append((x, m, k, error))

results.sort(key=lambda r: r[3])

print("Closest results to k=128.3669 with 128<k<129:\n")
for r in results[:30]:
    print(f"x={r[0]:2}, m={r[1]:2}, k={r[2]:9.6f}, error={r[3]:.6f}")


print()