import numpy as np

CPU_CLOCK = 1789773

CYCLES_PER_BIT = [
    428, 380, 340, 320, 286, 254, 226, 214,
    190, 160, 142, 128, 106, 85, 72, 54
]

A4_FREQ = 440


def freq_to_midi_and_cents(freq):

    if freq <= 0:
        return None, None

    n = 12 * np.log2(freq / A4_FREQ)

    nearest = int(round(n)) + 57
    cents = (n - round(n)) * 100

    return nearest, cents


def lowest_freq(byte_count, subwaves):

    total_bits = byte_count * 8
    bits_per_subwave = total_bits / subwaves

    cycles = CYCLES_PER_BIT[0]  # rate 0

    sample_rate = CPU_CLOCK / cycles

    freq = sample_rate / bits_per_subwave

    return freq


def search(target_midi):

    for x in range(17):

        byte_count = 16 * x + 1

        for subwaves in range(1, 21):

            freq = lowest_freq(byte_count, subwaves)

            midi, cents = freq_to_midi_and_cents(freq)

            if midi is None:
                continue

            if midi == target_midi and abs(cents) <= 20:

                cents = int(round(cents))

                print(f"(({byte_count}, {subwaves}), {midi}, {cents})")


if __name__ == "__main__":

    TARGET_MIDI = 12
        # 11 is the (17,1)  #12 is the (129,8)

    search(TARGET_MIDI)
