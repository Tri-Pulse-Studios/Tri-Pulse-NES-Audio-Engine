import ast
import os
import sys

def safe_eval(expr):
    try:
        # Evaluate using a restricted namespace
        return eval(expr, {"__builtins__": None}, {})
    except Exception as e:
        raise ValueError(f"Invalid expression: {e}")
    
def bits_to_bytes(bits):
    # Pad with zeros to make full bytes
    if len(bits) % 8 != 0:
        bits += [0] * (8 - len(bits) % 8)
    result = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for bit_index in range(8):
            bit = bits[i + bit_index]
            byte |= (bit & 1) << bit_index  # LSB first
        result.append(byte)
    return result

def make_sample(repeat_count, expected_length, name):
    while True:
        bits_per_subwave = (expected_length*8)/repeat_count
        if bits_per_subwave != int(bits_per_subwave):
            raise ValueError("Uneven bits per wave. Define as a single, longer formula and manually place extra bits.")
        bits_per_subwave = int(bits_per_subwave)


        formula = input(f"Enter bit formula (e.g., [1,1,0]*3 + [0]*3). Expecting {bits_per_subwave} bits:\n> ")
        try:
            bits = safe_eval(formula)
            if not isinstance(bits, list) or not all(bit in (0,1) for bit in bits):
                raise ValueError("Input must be a list of 0s and 1s")
        
            full_bits = bits * repeat_count
            print(f"received {len(bits)} bits")
            byte_data = bits_to_bytes(full_bits)
            if len(byte_data) != expected_length:
                raise ValueError (f"Expected {expected_length} bits. Please try again.")
                

            filename = f"{name}.dmc"
            with open(filename, "wb") as f:
                f.write(byte_data)
            print(f"Saved {filename} with {len(byte_data)} bytes.")
            break
        
        except Exception as e:
            print(f"Error: {e}")
            continue



def main():
    os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))

    while True: #Get a valid input
        try:
            repeat_count = input(f"Enter Sub-Wave Count:\n")
            repeat_count = int(repeat_count)
            break
        except ValueError:
            continue

    while True: #Get a valid input
        try:
            expected_length = input(f"Enter Total Byte Size (e.g., 17,81):\n")
            expected_length = int(expected_length)

            if (expected_length-1)/16 == int((expected_length-1)/16):
                break #need 16k+1
            
            print (f"Sample size must be 16k+1")

        except ValueError:
            continue


    make_sample(repeat_count, expected_length, name=f"DMC_Sample_{repeat_count}_{expected_length}")
    print("Done")

if __name__ == "__main__":
    main()
    print()