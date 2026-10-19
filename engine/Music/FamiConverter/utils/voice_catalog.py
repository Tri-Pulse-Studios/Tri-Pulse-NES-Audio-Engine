# voice_catalog.py

class VoiceCatalog:
    # Static variables (unchanging data)
    NOTE_NAME_TO_ID = {
        'A0': 0,  'A#0': 1,  'B0': 2,
        'C1': 3,  'C#1': 4,  'D1': 5,  'D#1': 6,  'E1': 7,  'F1': 8,  'F#1': 9,  'G1': 10, 'G#1': 11, 'A1': 12, 'A#1': 13, 'B1': 14,
        'C2': 15, 'C#2': 16, 'D2': 17, 'D#2': 18, 'E2': 19, 'F2': 20, 'F#2': 21, 'G2': 22, 'G#2': 23, 'A2': 24, 'A#2': 25, 'B2': 26,
        'C3': 27, 'C#3': 28, 'D3': 29, 'D#3': 30, 'E3': 31, 'F3': 32, 'F#3': 33, 'G3': 34, 'G#3': 35, 'A3': 36, 'A#3': 37, 'B3': 38,
        'C4': 39, 'C#4': 40, 'D4': 41, 'D#4': 42, 'E4': 43, 'F4': 44, 'F#4': 45, 'G4': 46, 'G#4': 47, 'A4': 48, 'A#4': 49, 'B4': 50,
        'C5': 51, 'C#5': 52, 'D5': 53, 'D#5': 54, 'E5': 55, 'F5': 56, 'F#5': 57, 'G5': 58, 'G#5': 59, 'A5': 60, 'A#5': 61, 'B5': 62,
        'C6': 63
    }
    

    PITCH_ID_TO_NAME = {
        0:  'A0',   1:  'As0',  2:  'B0',
        3:  'C1',   4:  'Cs1',  5:  'D1',   6:  'Ds1',  7:  'E1',   8:  'F1',   9:  'Fs1',  10: 'G1',  11: 'Gs1',  12: 'A1',  13: 'As1',  14: 'B1',
        15: 'C2',  16: 'Cs2',  17: 'D2',  18: 'Ds2',  19: 'E2',  20: 'F2',  21: 'Fs2',  22: 'G2',  23: 'Gs2',  24: 'A2',  25: 'As2',  26: 'B2',
        27: 'C3',  28: 'Cs3',  29: 'D3',  30: 'Ds3',  31: 'E3',  32: 'F3',  33: 'Fs3',  34: 'G3',  35: 'Gs3',  36: 'A3',  37: 'As3',  38: 'B3',
        39: 'C4',  40: 'Cs4',  41: 'D4',  42: 'Ds4',  43: 'E4',  44: 'F4',  45: 'Fs4',  46: 'G4',  47: 'Gs4',  48: 'A4',  49: 'As4',  50: 'B4',
        51: 'C5',  52: 'Cs5',  53: 'D5',  54: 'Ds5',  55: 'E5',  56: 'F5',  57: 'Fs5',  58: 'G5',  59: 'Gs5',  60: 'A5',  61: 'As5',  62: 'B5',
        63: 'C6'
    }

    """
    Old Version
    """
    # length_to_nibble = {
    # 4.0: 0b0001,    # Quarter
    # 8.0: 0b0101,    # Half
    # 12.0: 0b1001,   # Dotted Half
    # 16.0: 0b1101,   # Whole

    # 2.0: 0b0010,    #Eighth
    #     #0b0110 ;6 Riff Call
    # 6.0: 0b1010,    # Dotted Quarter
    #     #0b1110 ;e Riff Call


    # 1.33: 0b0011,   # Quarter-Triplet
    # 2.66: 0b0111,   # Half-Triplet
    # 5.33: None,     # Deprecated: Whole-Triplet   
    #     # 0b1011 ;B Bass Note Shift
    #     # 0b1111 ;F env Change / Special Sfx

    # 1.0: 0b0000,    # 16th
    # 3.0: 0b0100,    # Dotted Eighth
    # 5.0: 0b1000,    # Quarter + 16th
    # 7.0: 0b1100,    # Half - 16th
    # }
    length_to_nibble = {}

    # A reverse lookup for note length
    nibble_to_length = {}


    nibble_to_opcode = {
        0: "_16th",
        1: "8th",
        2: "qtr",
        3: "dqt",
        4: "hlf",
        6: "dhf",
        8: "whl"
    }

    # Automatically generate the reverse mapping
    opcode_to_nibble = {v: k for k, v in nibble_to_opcode.items()}


    # Changing variables (e.g., mutable state or data)
    env_name_to_pointer = {}
    env_pointer_index = 0
    vibrato_sequence_to_pointer = {}
    vibrato_data_byte_count = 1  # already wrote 1 byte for ID 0
    vibrato_data_lines = [
        "Table_Vibrato_Data:",
    ]

    @classmethod
    def add_env(cls, env_name, pointer):
        """Add a new env to the catalog."""
        cls.env_name_to_pointer[env_name] = pointer
        cls.env_pointer_index += 1

    @classmethod
    def reset_vibrato_data(cls):
        """Reset vibrato data."""
        cls.vibrato_data_byte_count = 1  # reset to initial value
        cls.vibrato_data_lines = [
            "",
            "Table_Vibrato_Data:", 
            ".byte $ff  ; ID 0 waits 255f before reading garbage data", 
            ""
        ]


