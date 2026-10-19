def find_smallest_solution(k, x_max=1000):
    """
    Find the smallest x > 0 such that (128 * x) / k = m is integer.
    Return x, m, and 16x.
    """
    for x in range(1, x_max + 1):
        numerator = 128 * x
        if numerator % k == 0:
            m = numerator // k
            return {'x': x, 'm': m, '16x': 16 * x}
    return None

def print_results_unconditional(base_k, steps=3):
    print(f"Results for base k = {base_k}")
    print("Semitone offset |   k unrounded   | k rounded | rounding error | x     | 16x    | m")
    print("-" * 85)

    for n in range(-steps, steps + 1):
        k_unrounded = base_k * (2 ** (n / 12))
        k_rounded = round(k_unrounded)
        rounding_error = k_unrounded - k_rounded

        solution = find_smallest_solution(k_rounded)
        if solution:
            x = solution['x']
            sixteen_x = solution['16x']
            m = solution['m']
        else:
            x = sixteen_x = m = None

        print(f"{n:15d} | {k_unrounded:14.5f} | {k_rounded:9d} | {rounding_error:14.5f} | "
              f"{str(x):5} | {str(sixteen_x):6} | {m}")
    print()



def print_results(base_k, steps=3):
    # Collect results first
    results = {}
    for n in range(-steps, steps + 1):
        k_unrounded = base_k * (2 ** (n / 12))
        k_rounded = round(k_unrounded)
        rounding_error = k_unrounded - k_rounded

        solution = find_smallest_solution(k_rounded)
        results[n] = {
            'k_unrounded': k_unrounded,
            'k_rounded': k_rounded,
            'rounding_error': rounding_error,
            'solution': solution
        }

    base_sol = results[0]['solution']
    if base_sol is None:
        return  # No base solution, skip printing

    base_x = base_sol['x']

    # Gather neighbor x values (only those with solutions)
    neighbors = []
    for offset in [-1, 1]:
        sol = results.get(offset, {}).get('solution')
        if sol:
            neighbors.append((offset, sol['x'], results[offset]['rounding_error']))

    # If no neighbors have solution, skip printing
    if not neighbors:
        return

    # Check if base x is smaller than all neighbor x
    if all(base_x < n_x for _, n_x, _ in neighbors):
        return  # base x smallest, skip printing

    # Check rounding error condition for neighbors that have smaller x than base
    for offset, n_x, n_err in neighbors:
        if n_x < base_x and abs(n_err) > 0.15:
            return  # Neighbor with smaller x has bad error, skip printing

    # If reached here, print results
    print(f"Results for base k = {base_k}")
    print("Semitone offset |   k unrounded   | k rounded | rounding error | x     | 16x    | m")
    print("-" * 85)

    for n in sorted(results.keys()):
        r = results[n]
        sol = r['solution']
        if sol:
            x = sol['x']
            sixteen_x = sol['16x']
            m = sol['m']
        else:
            x = sixteen_x = m = None

        print(f"{n:15d} | {r['k_unrounded']:14.5f} | {r['k_rounded']:9d} | {r['rounding_error']:14.5f} | "
              f"{str(x):5} | {str(sixteen_x):6} | {m}")
    print()





def generate_possible_ks_brute_force(x_min=1, x_max=255, m_max=30, k_min=6, k_max=200):
    ks = []#set()
    for x in range(x_min, x_max + 1):
        numerator = 128 * x
        for m in range(1, 2*x+1):
            if numerator % m == 0:
                k = numerator // m
                if k_min <= k <= k_max:
                    ks.append(k)
    return ks

# Example usage:
ks = generate_possible_ks_brute_force()
for k in ks:
    print_results(k)

print()




"""

TLDR:
The power of 2 alone doesn't play nice with finding a small neighbor.

The SMALLEST, sample that has a sample smaller than it as a neighbor is 560 Bytes. (Neighbor is 526)
    -The tuning isn't even that good, at 

"""