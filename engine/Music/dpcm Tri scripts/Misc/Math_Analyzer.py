import math

def modinv(a, m):
    def egcd(a, b):
        if b == 0:
            return (a, 1, 0)
        g, x, y = egcd(b, a % b)
        return (g, y, x - (a // b) * y)

    g, x, _ = egcd(a, m)
    if g != 1:
        return None
    return x % m

def solve_for_x_m(k_rounded, k_unrounded):
    gcd = math.gcd(128, k_rounded)
    if 8 % gcd != 0:
        return None
    k_reduced = k_rounded // gcd
    lhs = 128 % k_reduced
    rhs = (-8) % k_reduced

    inv = modinv(lhs, k_reduced)
    if inv is None:
        return None

    x0 = (inv * rhs) % k_reduced
    x = x0

    if x > MAX_SAMPLE_SIZE:
        return None

    sixteen_x_plus_1 = 16 * x + 1
    numerator = sixteen_x_plus_1 * 8
    m = numerator / k_rounded

    if m.is_integer():
        m = int(m)
        return {
            'x': x,
            '16x+1': sixteen_x_plus_1,
            'm': m
        }
    else:
        return None


def semitone_ratio(n):
    return 2 ** (n / 12)

def analyze_five_semitones(k_middle):
    results = {}
    for n in [-5,-4,-3,-2, -1, 0, 1, 2,3,4,5,6,7,8]:
        k_unrounded = k_middle * semitone_ratio(n)
        k_rounded = round(k_unrounded)
        rounding_error = k_rounded - k_unrounded
        sol = solve_for_x_m(k_rounded, k_unrounded)
        results[n] = {
            'k_unrounded': k_unrounded,
            'k_rounded': k_rounded,
            'rounding_error': rounding_error,
            'solution': sol
        }
    return results



import math
import math

def cents_diff(k_unrounded, k_rounded):
    if k_rounded == 0:
        return float('nan')
    ratio = k_unrounded / k_rounded
    return 1200 * math.log2(ratio)

def print_results(results, base_k):
    base_sol = results.get(0, {}).get('solution')
    minus1 = results.get(-1)
    plus1 = results.get(1)

    if not base_sol or (not minus1 and not plus1):
        return

    base_x = base_sol['x']
    neighbors = []

    # Check -1 neighbor
    if minus1 and 'solution' in minus1 and minus1['solution']:
        error_cents = abs(cents_diff(minus1['k_unrounded'], minus1['k_rounded']))
        if error_cents <= 5:
            if minus1['solution']['x'] < base_x:
                neighbors.append(-1)

    # Check +1 neighbor
    if plus1 and 'solution' in plus1 and plus1['solution']:
        error_cents = abs(cents_diff(plus1['k_unrounded'], plus1['k_rounded']))
        if error_cents <= 5:
            if plus1['solution']['x'] < base_x:
                neighbors.append(1)

    if not neighbors:
        return  # Nothing to print

    widths = {
        "offset": 18,
        "bits": 12,
        "tuning": 14,
        "x": 3,
        "bytes": 6,
        "subwaves": 8
    }

    print(f"Results for base k = {base_k}")
    print(f"{'Semitone Offset':>{widths['offset']}} | "
          f"{'bits/subwave':>{widths['bits']}} | "
          f"{'Tuning (cents)':>{widths['tuning']}} | "
          f"{'x':>{widths['x']}} | "
          f"{'Bytes':>{widths['bytes']}} | "
          f"{'Subwaves':>{widths['subwaves']}}")
    print("-" * (sum(widths.values()) + 3*5))  # 5 separators " | "

    for n in sorted(results.keys()):
        r = results[n]
        sol = r['solution']

        x_str = str(sol['x']) if sol else "--"
        val16x1_str = str(sol['16x+1']) if sol else "---"
        m_str = str(sol['m']) if sol else "---"
        error_cents = cents_diff(r['k_unrounded'], r['k_rounded'])

        print(f"{n:>{widths['offset']}d} | "
              f"{r['k_rounded']:>{widths['bits']}d} | "
              f"{error_cents:>{widths['tuning']}.2f} | "
              f"{x_str:>{widths['x']}} | "
              f"{val16x1_str:>{widths['bytes']}} | "
              f"{m_str:>{widths['subwaves']}}")
    print("\n")



MAX_SAMPLE_SIZE = 256
def generate_possible_ks(x_min=1, x_max=200):
    ks = set()
    for x in range(x_min, x_max + 1):
        sixteen_x_plus_1 = 16 * x + 1
        numerator = sixteen_x_plus_1 * 8
        for m in range(x_min, x*3):
            if numerator % m == 0:
                k = numerator // m
                if 70<k<250:
                    ks.add(k)
    return sorted(ks)

if __name__ == "__main__":
    k_list = generate_possible_ks()
    k_list = [136]
    print(f"Generated {len(k_list)} unique k values from brute force.\n")

    for base_k in k_list:
        res = analyze_five_semitones(base_k)
        print_results(res, base_k)

    print()