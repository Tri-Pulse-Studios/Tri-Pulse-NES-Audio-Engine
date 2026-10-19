import sympy as sp
import numpy as np
import matplotlib.pyplot as plt

# Symbols
t, D, n = sp.symbols('t D n', real=True, positive=True)
j = sp.I  # imaginary unit

# Define piecewise triangular pulse function x(t) with period T=1
x_t = sp.Piecewise(
    ((2/D)*t, (t >= 0) & (t < D/2)),
    (1 - (2/D)*(t - D/2), (t >= D/2) & (t < D)),
    (0, True)
)

# Fourier coefficient for Tri-Pulse
c_n_tri = sp.integrate(x_t * sp.exp(-j*2*sp.pi*n*t), (t, 0, 1))
c_n_tri = sp.simplify(c_n_tri)
c_n_tri_func = sp.lambdify((D, n), c_n_tri, modules=['numpy'])

# Define Pulse wave Fourier coefficient analytically for duty cycle d
def c_n_pulse_func(d, n):
    # handle n=0 separately
    n = np.array(n, dtype=float)
    result = np.zeros_like(n, dtype=complex)
    nz = n != 0
    result[~nz] = d  # n=0 term
    result[nz] = d * np.sinc(n[nz] * d)
    return result

# Parameters
D_val = 24/108  # Tri-Pulse duty cycle
harmonics = np.arange(1, 33)

# Evaluate Tri-Pulse coefficients
coeffs_tri = np.array([c_n_tri_func(D_val, hn) for hn in harmonics])
mag_tri = np.abs(coeffs_tri)

# Evaluate Pulse coefficients with duty cycle D/2
d_pulse = D_val / 2
coeffs_pulse = c_n_pulse_func(d_pulse, harmonics)
mag_pulse = np.abs(coeffs_pulse)

# Normalize to fundamental (max magnitude across both sets)
max_val = max(np.max(mag_tri), np.max(mag_pulse))
mag_tri_db = 20 * np.log10(mag_tri / max_val + 1e-15)
mag_pulse_db = 20 * np.log10(mag_pulse / max_val + 1e-15)

# Plot
bottom_limit = -80  # define bottom of y-axis

# height = bottom_limit - node_value  (negative because node_value > bottom_limit)
height_tri = bottom_limit - mag_tri_db
height_pulse = bottom_limit - mag_pulse_db

bar_width = 0.6
offset = 0.0

plt.figure(figsize=(10,6))


pulse_color = "#ffd700"   # firebrick red for 12.5% pulse
tri_pulse_color = "#006363"  # dark purple for 25% tri pulse

plt.bar(harmonics + offset/2, height_pulse, bottom=mag_pulse_db, width=bar_width,
        color=pulse_color, alpha=0.4, edgecolor='black', label=f'Pulse (Duty D/2={d_pulse:.3f})')

plt.bar(harmonics - offset/2, height_tri, bottom=mag_tri_db, width=bar_width,
        color=tri_pulse_color, alpha=0.8, edgecolor='black', label='Tri-Pulse (Duty D)')


# Plot markers on top
plt.plot(harmonics - offset/2, mag_tri_db, 'o', color='C0', label='_nolegend_')
plt.plot(harmonics + offset/2, mag_pulse_db, 's', color='C1', label='_nolegend_')

plt.xlabel('Harmonic Number n')
plt.ylabel('Magnitude (dB)')
plt.title(f'Comparison: Tri-Pulse (Duty={D_val:.2f}) vs Pulse (Duty={d_pulse:.2f})')
plt.ylim([bottom_limit, 0])
plt.grid(True, which='both', linestyle='--', alpha=0.5)
plt.legend()
plt.show()

