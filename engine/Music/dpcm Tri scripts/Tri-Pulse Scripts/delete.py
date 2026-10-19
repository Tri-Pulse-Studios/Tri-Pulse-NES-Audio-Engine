import numpy as np
import wave
import struct

def tri_pulse_v2(phase, D, Volume=1.0):
    """V2 Tri-Pulse: bipolar, zero DC"""
    val = np.zeros_like(phase)
    mask1 = phase < D/2
    val[mask1] = (phase[mask1] / (D/2)) * Volume
    mask2 = (phase >= D/2) & (phase < 3*D/2)
    val[mask2] = Volume * (1 - 2*(phase[mask2] - D/2)/D)  # +Vol -> -Vol
    mask3 = (phase >= 3*D/2) & (phase < 2*D)
    val[mask3] = Volume * (-1 + (phase[mask3] - 3*D/2)/(D/2))  # -Vol -> 0
    # else 0
    return val

def generate_wave(frequency, duration_s, sample_rate=44100, D=0.125, Volume=0.9):
    total_samples = int(sample_rate * duration_s)
    t = np.arange(total_samples) / sample_rate

    # Phase progresses from 0 to 1 every period (1/frequency)
    phase = (t * frequency) % 1.0

    # Calculate waveform samples
    samples = tri_pulse_v2(phase, D, Volume)

    # Scale to 16-bit signed integer range
    samples_int16 = np.int16(samples * 32767)

    return samples_int16

def save_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)  # mono
        wf.setsampwidth(2)  # 16 bits = 2 bytes
        wf.setframerate(sample_rate)
        wf.writeframes(samples.tobytes())

if __name__ == "__main__":
    freq = 440          # A4 note
    duration = 5.0      # seconds
    duty = 0.25        # 12.5% duty cycle
    volume = 0.9        # amplitude scale (0 to 1)

    wave_data = generate_wave(freq, duration, D=duty, Volume=volume)
    save_wav("tri_pulse_v2_12.5pct_duty.wav", wave_data)
    print("WAV file generated: tri_pulse_v2_12.5pct_duty.wav")
