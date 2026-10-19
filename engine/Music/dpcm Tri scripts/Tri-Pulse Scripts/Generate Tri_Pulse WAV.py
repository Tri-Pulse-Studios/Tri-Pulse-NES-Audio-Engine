import numpy as np
from scipy.io.wavfile import write

def generate_tri_pulse_wav(
    filename: str,
    frequency: float = 440.0,
    duty_cycle: float = 0.125,  # Portion of cycle to ramp up (0–1)
    sample_rate: int = 44100,
    duration_seconds: float = 1.0
):
    """
    Generate a Tri-Pulse waveform and save it to a WAV file.
    
    duty_cycle: Portion of the cycle spent ramping up (e.g., 0.125 for 12.5%)
    The next equal portion ramps down, and the remainder is flat.
    """
    # Safety clamp
    duty_cycle = np.clip(duty_cycle, 0.0, 0.5)

    samples_per_cycle = int(sample_rate / frequency)
    total_samples = int(sample_rate * duration_seconds)

    ramp_up_len = int(samples_per_cycle * duty_cycle)
    ramp_down_len = ramp_up_len
    flat_len = samples_per_cycle - ramp_up_len - ramp_down_len

    # One cycle: ramp up, ramp down, flat
    up = np.linspace(0, 1, ramp_up_len, endpoint=False)
    down = np.linspace(1, 0, ramp_down_len, endpoint=False)
    flat = np.zeros(flat_len)

    one_cycle = np.concatenate([up, down, flat])
    waveform = np.tile(one_cycle, total_samples // samples_per_cycle + 1)
    waveform = waveform[:total_samples]  # Trim to exact length

    # Normalize and convert to int16
    waveform -= np.mean(waveform)  # Center it
    waveform /= np.max(np.abs(waveform))  # Normalize to [-1, 1]
    int_waveform = np.int16(waveform * 32767)

    write(filename, sample_rate, int_waveform)
    print(f"Saved to: {filename}")

# Example usage:
generate_tri_pulse_wav("tri_pulse_25pct.wav", frequency=440, duty_cycle=0.25)
