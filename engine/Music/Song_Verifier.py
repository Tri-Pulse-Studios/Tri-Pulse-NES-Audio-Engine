import os, re
from tkinter import Tk, filedialog

TIMESTAMP_RE = re.compile(r"^\s*;(\d+)(?:\.(\d+))?(?:\.(\d+))?$") #ex  ;4  ;15.2  ;5.2.13

NOTE_RE = re.compile(r"([A-Ga-g])([sb]?)(\d+)?([+-]?)")

NOTE_MAP = {

    "C": 3,
    "Cs": 4, "Db": 4,
    "D": 5,
    "Ds": 6, "Eb": 6,
    "E": 7,
    "F": 8,
    "Fs": 9, "Gb": 9,
    "G": 10,
    "Gs": 11, "Ab": 11,
    "A": 0,
    "As": 1, "Bb": 1,
    "B": 2,

}

LABEL_RE = re.compile(r"^[@a-zA-Z_][a-zA-Z0-9_:]*$")

DURATION_KEYWORDS  = {
        "8th": (1, 0),
        "qtr": (2, 0),
        "dqt": (3, 0),
        "hlf": (4, 0),
        "dhf": (6, 0),
        "whl": (8, 0),
    }

DURATION_PATTERNS = {
    
    '"Cont"': [],

    "_00": ["(_8th+1)//2", "_8th//2"],  # 16th notes, first rounded up
    "_0000": ["(_8th+1)//2", "_8th//2", "(_8th+1)//2", "_8th//2"],  # 16th notes, first rounded up

"_1111": ["8th", "8th", "8th", "8th"],
"_332_x2": ["dqt", "dqt", "qtr", "dqt", "dqt", "qtr",],
"_11_100_x2": ["8th", "8th", "8th", "(_8th+1)//2", "_8th//2",   "8th", "8th", "8th", "(_8th+1)//2", "_8th//2",],
"_111_2_111_b": ["8th", "8th", "8th",  "qtr",  "8th", "8th", "8th", 0],  #The 0 is really a Base Pitch. Ignoring it for now.
"_f_0000_f_1001": [0, "(_8th+1)//2", "_8th//2", "(_8th+1)//2", "_8th//2",0, "8th", "(_8th+1)//2", "_8th//2",   "8th" ]
}


class Channel:
    def __init__(self, ch_type, scope, line_number, song_raw_lines, parent):
        self.parent = parent
        self.bpm = parent.bpm

        self.raw_lines = song_raw_lines
        self.ch_type = ch_type   # Sq0, Sq1, Tri, Noise, Dmc
        self.scope = scope         # Scope/label if provided
        self.starting_line_number = line_number

        self.tokens = []
            #Emulated Values
        self.measure = 1 
        self.beat = 1
        self.frame = 0

        self.bp = None
        self.bp_var = None
        self.riff_depth = 0
        self.in_repeat = False

        self.out = Print_Handler()

    def __repr__(self):
        return f"<Channel type={self.ch_type} line={self.starting_line_number}>"

        #TODO Check Riff-Returns
            #Either byte counters, or a label to return to. Byte counter can directly decriment the top Riff's counter, if it exists.
            #This checks, before decrimenting, that it is exactly 0 for normal,  and negetive for             [WARN] mis-aligned Riff Return.  (Which is harmless on its own)

    def tokenize_raw_lines(self):
        """
        Turn raw channel lines into a flat list of Token objects.
        Stops at 'Loop' line for now.
        """
        for line_number, line in enumerate(self.raw_lines[self.starting_line_number:], start=(self.starting_line_number+1)):
            line = strip_inline_comments(line)

            # if line_number == 120:
            #     pass

            if not line:
                continue 

            if line.startswith("Loop") or line.startswith(".endscope"):
                self.tokens.append(Token_Loop(line_number, line, self))
                break

            elif line.endswith(":"):
                if line.startswith("End_Intro:"):
                    self.tokens.append(Token_End_Intro(line_number, line, self))
                else:
                    continue # Other labels, skip for now

            elif line.startswith(";"):
                
                match = TIMESTAMP_RE.match(line)
                if match:
                    self.tokens.append(Token_Timestamp(line_number, line, self))
                else:
                    # Skip Normal comments
                    continue
                
            elif line.startswith("Header") or line.startswith("Set_Pitch"):
                self.tokens.append(Token_Set_Pitch(line_number, line, self))


            elif line.startswith("Shift_Pitch"):
                self.tokens.append(Token_Shift_Pitch(line_number, line, self))


            elif line.startswith("BP .set"):
                self.tokens.append(Token_Manual_BP(line_number, line, self))


            elif line.startswith("Duration"):
                self.parse_duration(line_number, line)

            elif line.startswith("Notes"):
                self.parse_notes(line_number, line)


            elif line.startswith("Env_Change"):
                pass #I could validate Env_Change stays consistant by Riff, but meh.


            elif line.startswith("Riff"):
                self.dispatch_riff(line_number, line)

            elif line.startswith("Repeat"):
                self.parse_repeat(line_number, line)

            elif line.startswith(".byte"):
                self.parse_raw_bytes(line_number, line)

            else:
                self.out.error(f"Unknown Line: {line_number}, {line}")

        return self.tokens


    def parse_repeat(self, repeat_line_number, repeat_line):
        if getattr(self, "in_repeat", False):
            raise RuntimeError(f"[FATAL] Nested Repeats at line {repeat_line_number}")
            return

        self.in_repeat = True

        # Parse Repeat line
        # Repeat "2b", 2
        match = re.match(r'Repeat\s+"(\d+)b"\s*,\s*(\d+)', repeat_line)
        if not match:
            self.out.error(f" Malformed Repeat at line {repeat_line_number}: {repeat_line}")
            self.in_repeat = False
            return

        bytes_remaining = int(match.group(1))
        repeat_count = int(match.group(2))

        # Walk backwards through self.tokens to collect byte_count tokens
        prev_tokens = self.tokens.copy()
        self.tokens = []
        repeat_tokens = []

        idx = repeat_line_number - 1  # start at the line just before the Repeat
        while bytes_remaining > 0 and idx > 0:
            idx -= 1
            line = self.raw_lines[idx].strip() #idx is 1-based, pre-dec'ed
            line = strip_inline_comments(line)

            if not line or line.startswith(";") or line.endswith(":") or line.startswith("BP .set"):
                continue

            elif line.startswith("Loop") or line.startswith(".endscope"):
                self.tokens.append(Token_Loop(repeat_line_number, line, self))
                self.out.warn(f" Loop triggered while inside a Repeat: Line {repeat_line_number}")
                break


            elif line.startswith("Duration"):
                self.parse_duration(repeat_line_number, line)

                body = line[len("Duration"):].strip()
                parts = [p.strip() for p in body.split(",")]
  
                pitches = parts[1:]
                if len(pitches) % 2 != 0:
                    self.out.warn(f" Duration has Odd number of pitches. Timestamps may be innacurate")  # the notes or rests (ignored here)
                bytes_remaining -= (len(pitches))//2
                bytes_remaining -= 1


            elif line.startswith("Notes"):
                # Strip comments
                line_clean = line.split(";", 1)[0].strip()
                body = line_clean[len("Notes"):].strip()
                parts = [p.strip() for p in body.split(",")]

                if len(parts) % 2 != 0:
                    self.out.error(f" Malformed Notes line in Riff at line {repeat_line_number}: {line}")
                    continue

                for i in range(0, len(parts), 2):
                    if bytes_remaining <= 0:
                        break  #Handle notes one at a time, and break if Riff returns mid-line.
                    duration = parts[i]
                    beat, frame = self.duration_expr_to_frame(repeat_line_number, duration)
                    token = Token_Note(repeat_line_number, beat, frame, self)
                    self.tokens.append(token)
                    
                    if frame == 0 and beat in (1,2,3,4,6,8):
                        bytes_remaining -= 1
                    else:
                        bytes_remaining -= 2



            elif line.startswith("Riff"):
                parts = [p.strip() for p in line[len("Riff"):].split(",")]

                if len(parts) == 3: 
                    bytes_remaining -= 3

                else:
                    try:
                        # Evaluate safely, only arithmetic expressions
                        value = eval(parts[0], {"__builtins__": None})
                        if value > 32:
                            bytes_remaining -= 3
                        else:
                            bytes_remaining -= 2
                    except:
                        bytes_remaining -= 2

                self.dispatch_riff(repeat_line_number, line)


            elif line.startswith("Set_Pitch"):
                bytes_remaining -= 2
                self.tokens.append(Token_Set_Pitch(repeat_line_number, line, self))


            elif line.startswith("Shift_Pitch"):
                bytes_remaining -= 1
                self.tokens.append(Token_Shift_Pitch(repeat_line_number, line, self))

            elif line.startswith("Env_Change"):
                bytes_remaining -= 1
                pass

            elif line.startswith(".byte"):
                self.parse_raw_bytes(repeat_line_number, line)

                parts = [p.strip() for p in line[len(".byte"):].split(",") if p.strip()]
                for part in parts:
                    bytes_remaining -= 1

            else:
                self.out.error(f" Unknown Line in Repeat: {repeat_line_number}, {line}")

            repeat_tokens = self.tokens + repeat_tokens
            self.tokens = []



        if bytes_remaining > 0:
            print(f"       [ERROR] Not enough bytes for Repeat at line {repeat_line_number}, repeating what we have")

        elif bytes_remaining != 0:
            self.out.warn(f" Repeat not instruction aligned.")

        # Append copies
        self.tokens = prev_tokens
        for _ in range(repeat_count):
            self.tokens.extend(repeat_tokens)

        self.in_repeat = False



    def parse_raw_bytes(self, line_number, line):  
        # Strip off ".byte" and split into parts
        parts = [p.strip() for p in line[len(".byte"):].split(",") if p.strip()]
        if not parts:
            return

        # ignore list (validator doesn't care about these)
        ignored = {
            "Plus_Octave",
            "Minus_Octave",
            "Music_nop",
            "No_Reset_Env",
        }

        for part in parts:
            # case 1: raw numeric literal
            if part.startswith(("$", "%")) or part.isdigit():
                self.out.warn(f" raw byte seen at line {line_number}: {part}")
                continue

            # case 2: ignored constants
            elif part in ignored:
                continue

            # case 3: bend notes
            elif part in ("Bend_Shallow", "Bend_Steep"):
                beat, frame = (self.duration_expr_to_frame(line_number, "8th")) #Or just beat, frame = (1,0)
                token = Token_Note(line_number, beat, frame, self)
                self.tokens.append(token)
                continue

            elif part in ("Slow_Fade_Out"):
                print (f"            [WARN] Unable to compute FX duration.")

            # fallback: unknown symbol
            else:
                self.out.warn(f" unrecognized byte at line {line_number}: {part}")


        return


    def dispatch_riff(self, line_number, line):  
        if line_number == 51:
            pass    
    
        self.riff_depth += 1

        if self.riff_depth > 7:
            raise RuntimeError (f"Excessive Riff Depth. Its likely a circular infinite involving line {line_number}")
        elif self.riff_depth > 3:
            print (f"            [WARN] Intended Max Riff depth is 3. Reached {self.riff_depth} at line: {line_number}")


        parts = [p.strip() for p in line[len("Riff"):].split(",")]
        if len(parts) != 2:
            #raise ValueError(f"Malformed Riff at {line_number}: {line}")
            pass

        left, right = parts[0], parts[1]


        # Case: label riff (both parts must look like labels)
        if LABEL_RE.match(left) and LABEL_RE.match(right):
            self.unroll_label_riff(line_number, line)
            self.riff_depth -= 1
            return
        else:

            try:
                count_val = eval(left, {}, {})
                if isinstance(count_val, int):
                    self.unroll_count_riff(line_number, line)
                    self.riff_depth -= 1
                    return

            except Exception as e:
                raise ValueError(f"Called from Riff {line_number}: {line}.  Error: {e}")




    def unroll_label_riff(self, riff_line_number, riff_line):
        parts = [p.strip() for p in riff_line[len("Riff"):].split(",")]
        if len(parts) != 2:
            #raise ValueError(f"Malformed Riff at {line_number}: {line}")
            pass

        end_label, start_label = parts[0], parts[1]

        if "::" in start_label or "::" in end_label:
            print (f"[UNIMPLIMENTED] Scoped Riffs not implemented at line {riff_line_number}")
            return

        start_label_line = start_label + ":"
        end_label_line   = end_label + ":"


        if "::" in start_label:
            scope_name, inner_label = start_label.split("::", 1)

            # Look for the channel with matching scope
            target_channel = None
            for ch in self.parent.channels:
                if ch.scope == scope_name:
                    target_channel = ch
                    break

            if target_channel is None:
                self.out.error(f" Scope {scope_name} not found for Riff at line {riff_line_number}")
                return

            # Use the scoped channel's raw lines and starting line number
            search_lines = target_channel.raw_lines
            start_idx = target_channel.starting_line_number
            start_label_line = inner_label + ":"
        else:
            # No scope, default to current channel
            search_lines = self.raw_lines
            start_idx = self.starting_line_number
            start_label_line = start_label + ":"

        # Search for the riff start label
        riff_start = None
        for idx in range(start_idx, len(search_lines)):
            raw = search_lines[idx].strip()

            if raw.startswith("Loop") and "::" not in start_label:
                self.out.error(f" Label Riff start label {start_label} not found before Loop at line {idx+1}")
                return

            if raw == start_label_line:
                riff_start = idx
                break

        if riff_start is None:
            self.out.error(f" Start label {start_label} not found for  Label Riff at line {riff_line_number}")


        # riff_start = None
        # for idx in range(self.starting_line_number, len(self.raw_lines)):
        #     raw = self.raw_lines[idx].strip()
        #     if raw.startswith("Loop"):
        #         self.out.error(f" Riff start label {start_label} not found before Loop at line {idx+1}")
        #         return
            
        #     if raw == start_label_line:
        #         riff_start = idx
        #         break

        # if riff_start is None:
        #     print(f"Start label {start_label} not found for Riff at line {riff_line_number}")


        for line_number, line in enumerate(self.raw_lines[riff_start:], start=(riff_start+1)): 
            if line_number == riff_line_number:
                raise RuntimeError (f"Riff at line {riff_line_number} Self-Calls.")

            line = line.strip()
            line = strip_inline_comments(line)

            if line == end_label_line:
                break  # stop once end label is hit

            elif line == end_label_line:
                break #Finished with this Riff.

            elif line.startswith("Loop") or line.startswith(".endscope"):
                self.tokens.append(Token_Loop(riff_line_number, line, self))
                self.out.warn(f" Loop triggered while inside a Riff: Line {riff_line_number}")
                break

            elif not line or line.startswith(";") or line.endswith(":") or line.startswith("BP .set"):
                continue #Ignore assembler markers inside Riffs

            elif line.startswith("Duration"):
                self.parse_duration(riff_line_number, line)

            elif line.startswith("Notes"):
                self.parse_notes(riff_line_number, line)


            elif line.startswith("Env_Change"):
                pass #I could validate Env_Change stays consistant by Riff, but meh.


            elif line.startswith("Riff"):
                self.dispatch_riff(line_number, line)   #Will Recurse.

            elif line.startswith("Repeat"):
                self.parse_repeat(line_number, line)



            elif line.startswith("Set_Pitch"):
                self.tokens.append(Token_Set_Pitch(line_number, line, self))

            elif line.startswith("Shift_Pitch"):
                self.tokens.append(Token_Shift_Pitch(line_number, line, self))


            else:
                self.out.error(f" Unknown Line in label Riff: {line_number}, {line}")


        return



    def unroll_count_riff(self, riff_line_number, riff_line):
        parts = [p.strip() for p in riff_line[len("Riff"):].split(",")]
        if len(parts) != 2:
            #raise ValueError(f"Malformed Riff at {line_number}: {line}")
            pass

        count_expr, start_label = parts[0], parts[1]

        # Evaluate the count expression safely
        try:
            bytes_remaining = int(eval(count_expr, {}, {}))
        except Exception as e:
            self.out.error(f" Unable to eval Riff count at line {riff_line_number}: {count_expr} ({e})")
            return

        # Find start label line
        start_label_line = start_label + ":"

        if "::" in start_label:
            scope_name, inner_label = start_label.split("::", 1)

            # Look for the channel with matching scope
            target_channel = None
            for ch in self.parent.channels:
                if ch.scope == scope_name:
                    target_channel = ch
                    break

            if target_channel is None:
                self.out.error(f" Scope {scope_name} not found for Riff at line {riff_line_number}")
                return

            # Use the scoped channel's raw lines and starting line number
            search_lines = target_channel.raw_lines
            start_idx = target_channel.starting_line_number
            start_label_line = inner_label + ":"
        else:
            # Figure out what channel scope this riff call belongs to
            riff_line_num = riff_line_number

            target_channel = None
            best_start = -1
            for ch in self.parent.channels:
                if ch.starting_line_number <= riff_line_num and ch.starting_line_number > best_start:
                    target_channel = ch
                    best_start = ch.starting_line_number

            if target_channel is None:
                self.out.error(f" Could not resolve scope for riff at line {riff_line_num}")
                return

            # Use that channel’s raw lines and starting line number
            search_lines = target_channel.raw_lines
            start_idx = target_channel.starting_line_number
            start_label_line = start_label + ":"


        # Search for the riff start label
        riff_start = None
        found_in_scope = True
        idx = start_idx
        while idx < len(search_lines):
            raw = search_lines[idx].strip()

            if raw.startswith("Loop") and "::" not in start_label:
                if found_in_scope:
                    found_in_scope = False
                    idx = 0  # restart search from beginning
                    continue
                else:
                    idx += 1
                    continue

            if raw == start_label_line:
                riff_start = idx
                break

            idx += 1

        if riff_start is None:
            self.out.error(f" Start label {start_label} not found for Riff at line {riff_line_number}")

        if not found_in_scope and ENBALE_NOTES:
            self.out.note(f" Riff found only outside scope.")

        # riff_start = None
        # for idx in range(self.starting_line_number, len(self.raw_lines)):
        #     raw = self.raw_lines[idx].strip()
        #     if raw.startswith("Loop"):
        #         self.out.error(f" Riff start label {start_label} not found before Loop at line {idx+1}")
        #         return

        #     if raw == start_label_line:
        #         riff_start = idx
        #         break

        # if riff_start is None:
        #     print(f"Start label {start_label} not found for Riff at line {riff_line_number}")
        #     return

        # Process lines until count is exhausted
        for line_number, line in enumerate(self.raw_lines[riff_start:], start=(riff_start + 1)):
            line = line.strip()
            line = strip_inline_comments(line)


            if bytes_remaining <= 0:
                if bytes_remaining != 0:
                    
                    next_line = self.raw_lines[riff_line_number].strip() if riff_line_number < len(self.raw_lines) else ""
                    if next_line.startswith('Duration "Cont"'):
                        self.out.note(f"Riff returned mid-duration at line {riff_line_number}: {riff_line}")
                    else:
                        self.out.warn(f"Riff Return not instruction-aligned at line {riff_line_number}: {riff_line}")
                                        
                break

            if line_number == riff_line_number:
                raise RuntimeError(f"[FATAL] Riff self-calls at line {riff_line_number}")


            # Ignore non-executable lines
            if not line or line.startswith(";") or line.endswith(":") or line.startswith("BP .set"):
                continue

            # Dispatch commands just like label riff
            if line.startswith("Duration"):
                self.parse_duration(riff_line_number, line)

                body = line[len("Duration"):].strip()
                parts = [p.strip() for p in body.split(",")]
  
                pitches = parts[1:]
                if len(pitches) % 2 != 0:
                    self.out.warn(f" Duration has Odd number of pitches. Timestamps may be innacurate")  # the notes or rests (ignored here)
                bytes_remaining -= (len(pitches))//2
                bytes_remaining -= 1

            elif line.startswith("Notes"):
                # Strip comments
                line_clean = line.split(";", 1)[0].strip()
                body = line_clean[len("Notes"):].strip()
                parts = [p.strip() for p in body.split(",")]

                if len(parts) % 2 != 0:
                    self.out.error(f" Malformed Notes line in Riff at line {riff_line_number}: {line}")
                    continue

                for i in range(0, len(parts), 2):
                    if bytes_remaining <= 0:
                        break  #Handle notes one at a time, and break if Riff returns mid-line.
                    duration = parts[i]
                    beat, frame = self.duration_expr_to_frame(riff_line_number, duration)
                    token = Token_Note(riff_line_number, beat, frame, self)
                    self.tokens.append(token)

                    if frame == 0 and beat in (1,2,3,4,6,8):
                        bytes_remaining -= 1
                    else:
                        bytes_remaining -= 2


            elif line.startswith("Riff"):
                parts = [p.strip() for p in line[len("Riff"):].split(",")]

                if len(parts) == 3: 
                    bytes_remaining -= 3

                else:
                    try:
                        # Evaluate safely, only arithmetic expressions
                        value = eval(parts[0], {"__builtins__": None})
                        if value > 32:
                            bytes_remaining -= 3
                        else:
                            bytes_remaining -= 2
                    except:
                        bytes_remaining -= 2

                self.dispatch_riff(line_number, line)

                

            elif line.startswith("Set_Pitch"):
                bytes_remaining -= 2
                self.tokens.append(Token_Set_Pitch(line_number, line, self))

            elif line.startswith("Shift_Pitch"):
                bytes_remaining -= 1
                self.tokens.append(Token_Shift_Pitch(line_number, line, self))

            elif line.startswith("Repeat"):
                self.parse_repeat(line_number, line)
                bytes_remaining -= 1

            elif line.startswith(".byte"):
                self.parse_raw_bytes(line_number, line)

                parts = [p.strip() for p in line[len(".byte"):].split(",") if p.strip()]
                for part in parts:
                    bytes_remaining -= 1


            elif line.startswith("Env_Change"):
                bytes_remaining -= 1
                pass

            elif line.startswith("Loop") or line.startswith(".endscope"):
                self.tokens.append(Token_Loop(riff_line_number, line, self))
                self.out.warn(f"Loop triggered inside count Riff at line {riff_line_number}")
                break
            else:
                bytes_remaining -= 1
                self.out.error(f" Unknown line in count Riff: {line_number}, {line}")
                if ENBALE_NOTES:
                    self.out.note("Assumed line consumes One Byte.")


        return



    def parse_notes(self, line_number, line):
        line = line.split(";", 1)[0].strip()
        #Strip Comment

        # Strip "Notes" prefix
        body = line[len("Notes"):].strip()

        # Split into duration,note pairs
        parts = [p.strip() for p in body.split(",")]

        if len(parts) % 2 != 0:
            raise ValueError(f"Malformed Notes line at {line_number}: {line}")

        for i in range(0, len(parts), 2):
            duration = parts[i]
            # pitch = parts[i+1]  # ignored for validator

            beat, frame = self.duration_expr_to_frame(line_number, duration)
            token = Token_Note(line_number, beat, frame, self)
            self.tokens.append(token)



    def parse_duration(self, line_number, line):
        """
        Parse a 'Duration' line like:
        Duration _1111, As4, Cs5, Ds5, rest
        Only cares about the first token (_1111), uses LUT to expand durations,
        then generates a Token_Note for each pitch.
        """
        body = line[len("Duration"):].strip()
        parts = [p.strip() for p in body.split(",")]

        if len(parts) < 2:
            raise ValueError(f"Malformed Duration line at {line_number}: {line}")

        pattern = parts[0]  # e.g., "_1111"
        pitches = parts[1:]  # the notes or rests (ignored here)

        if pattern not in DURATION_PATTERNS:
            self.out.error(f"Unknown Duration pattern '{pattern}' at line {line_number}")

        duration_exprs = DURATION_PATTERNS[pattern]

        if duration_exprs and len(duration_exprs) != len(pitches):
            self.out.warn(
                f"Pattern {pattern} expects {len(duration_exprs)} notes but found {len(pitches)} at line {line_number}"
            )

        # Create tokens using the helper
        for expr, pitch in zip(duration_exprs, pitches):
            beat, frame = self.duration_expr_to_frame(line_number, expr)
            token = Token_Note(line_number, beat, frame, self)
            self.tokens.append(token)


    def duration_expr_to_frame(self, line_number, duration_expr):
        bpm = self.bpm  # frame per 8th
        duration_expr = duration_expr.strip() 

        if duration_expr in DURATION_KEYWORDS:
            # Direct keyword mapping
            beat, frame = DURATION_KEYWORDS[duration_expr]

        elif re.match(r"^\d+$", duration_expr):
            # Plain integer → frame count directly
            total_frame = int(duration_expr)
            beat, frame = divmod(total_frame, bpm)

        else:
            # Complex math expression (_8th, * / + -)
            # Replace "_8th" with bpm before eval
            expr = duration_expr.replace("_8th", str(bpm))
            try:
                total_frame = eval(expr, {}, {})
            except Exception as e:
                raise ValueError(
                    f"Bad duration expression at line {line_number}: {duration_expr} ({e})"
                )

            if not isinstance(total_frame, (int, float)):
                raise ValueError(
                    f"Duration must evaluate to a number, got {total_frame}"
                )

            total_frame = int(total_frame)
            beat, frame = divmod(total_frame, bpm)
            
        return beat, frame

#Class Tokens organized alphabetically



class Token_End_Intro:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

    def __repr__(self):
        return f"   <Line {self.starting_line_number}, End_Intro>"

    def execute(self, ch):
        p = self.parent
        print(f"    <Line {self.starting_line_number}, End_Intro, Timestamp: {p.measure}.{p.beat}.{p.frame}>")


class Token_Loop:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Loop>"

    def execute(self, ch):
        p = self.parent
        print(f"    <Line {self.starting_line_number}, Loop, Timestamp: {p.measure}.{p.beat}.{p.frame}>")


class Token_Note:
    def __init__(self, line_number, beat, frame, parent):
        self.starting_line_number = line_number
        self.parent = parent
    
        self.beat = beat
        self.frame = frame


    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Note, Duration: {self.beat}.{self.frame}>"



    def execute(self, ch):
        p = self.parent

        # Check that bp_var and bp are both set and equal
        if not hasattr(p, "bp_var") or not hasattr(p, "bp") or p.bp_var != p.bp or p.bp is None:
            p.out.note(f" Missing explicit BP .set at line {self.starting_line_number}: {getattr(p, 'bp', None)}")
            pass

        # Add frame to parent's frame counter
        p.frame += self.frame
        while p.frame >= p.bpm:  # overflow based on BPM frame per 8th
            p.frame -= p.bpm  # Zero-Based
            p.beat += 1

        # Handle beat overflow for 8/8 time
        p.beat += self.beat
        while p.beat > 8: #1-Based
            p.beat -= 8
            p.measure += 1


class Token_Shift_Pitch:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

        raw = line[len("Shift_Pitch"):].strip()

        # Mode 1: +Octave / -Octave
        if raw.lower() in ("+octave", "-octave"):
            self.mode = "relative"
            self.shift = 12 if raw.startswith("+") else -12
            self.raw_note_name = raw

        # Mode 2: integer shift
        elif re.match(r"^[+-]?\d+$", raw):
            self.mode = "relative"
            self.shift = int(raw)
            self.raw_note_name = raw

        # Mode 3: Before, After (explicit notes)
        elif "," in raw:
            self.mode = "before_after"
            left, right = [x.strip() for x in raw.split(",", 1)]

            # Parse before
            m_before = NOTE_RE.match(left)
            if not m_before:
                self.parent.out.warn(f" Invalid 'before' note at line {line_number}: {left}")
                self.shift = 0
                return

            b_letter = m_before.group(1).upper()
            b_acc = m_before.group(2).lower()
            b_oct = int(m_before.group(3))
            b_flag = m_before.group(4)

            before_name = b_letter + b_acc if b_acc else b_letter
            b_pitch = NOTE_MAP[before_name] + b_oct * 12
            if b_flag == "+": b_pitch += 12
            elif b_flag == "-": b_pitch -= 12

            # Parse after
            m_after = NOTE_RE.match(right)
            if not m_after:
                self.parent.out.warn(f" Invalid 'after' note at line {line_number}: {right}")
                self.shift = 0
                return

            a_letter = m_after.group(1).upper()
            a_acc = m_after.group(2).lower()
            a_oct = int(m_after.group(3))
            a_flag = m_after.group(4)

            after_name = a_letter + a_acc if a_acc else a_letter
            a_pitch = NOTE_MAP[after_name] + a_oct * 12
            if a_flag == "+": a_pitch += 12
            elif a_flag == "-": a_pitch -= 12

            self.before_pitch = b_pitch
            self.after_pitch = a_pitch
            self.shift = a_pitch - b_pitch
            self.raw_note_name = f"{left},{right}"

        else:
            self.parent.out.warn(f" Malformed Shift_Pitch line at {line_number}: {line}")
            self.mode = "bad"
            self.shift = 0

    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Shift_Pitch, {self.raw_note_name}, shift={self.shift}>"

    def execute(self, ch):
        if self.mode == "before_after":
            if self.parent.bp_var is None:
                self.parent.out.warn(f" Shift_Pitch at line {self.starting_line_number} but bp_var is None")
            else:
                if self.parent.bp_var == self.before_pitch:
                    pass  # perfect match
                elif (self.parent.bp_var % 12) == (self.before_pitch % 12):
                    self.parent.out.warn(f"Off-by-Octave at line {self.starting_line_number}: expected {self.before_pitch}, got {self.parent.bp_var}")
                else:
                    self.parent.out.error(f"Off-by-Pitch at line {self.starting_line_number}: expected {self.before_pitch}, got {self.parent.bp_var}")

        # Apply shift no matter what
        if self.parent.bp_var is not None:
            self.parent.bp_var += self.shift
            self.parent.bp = self.parent.bp_var




class Token_Set_Pitch:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

        if self.line.startswith("$1"Intro""
    
            # Edge case: global noise bank header
            if raw_note_name.startswith("::"):
                raw_note_name = "A0"   # Force substitute

        elif self.line.startswith("Set_Pitch"):
            raw_note_name = self.line[len("Set_Pitch"):].strip()
        else:
            self.parent.out.warn(f" Malformed Set_Pitch/Header line at {line_number}: {line}")

        # Parse note
        match = NOTE_RE.match(raw_note_name)
        if not match:
            self.parent.out.warn(f" Invalid note format at line {line_number}: {raw_note_name}")

        note_letter = match.group(1).upper()
        accidental = match.group(2).lower()
        octave = int(match.group(3))
        self.octave_flag = match.group(4)  # '+', '-', or None

        note_name = note_letter + accidental if accidental else note_letter
        if note_name not in NOTE_MAP:
            raise ValueError(f"Unknown note {note_name} at line {line_number}")

        base_pitch = NOTE_MAP[note_name] 
        base_pitch += (octave * 12)

        # Apply octave flag if present
        if self.octave_flag == "+":
            base_pitch += 12
        elif self.octave_flag == "-":
            base_pitch -= 12

        self.midi = base_pitch
        self.raw_note_name = raw_note_name
        return #End Init

    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Set_Pitch, {self.raw_note_name}, {self.midi}>"

    def execute(self, ch):
        self.parent.bp_var = self.midi
        self.parent.bp = self.midi


class Token_Timestamp:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

        match = TIMESTAMP_RE.match(line)
        measure = int(match.group(1))
        beat = int(match.group(2) or 1)
        frame = int(match.group(3) or 0)

        self.measure = measure
        self.beat = beat
        self.frame = frame

    #Execute, check current timestamp against given. Error if mismatch
    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Timestamp, {self.line.strip()}>"

    def execute(self, ch):
        p = self.parent
        actual_ts = f"{p.measure}.{p.beat}.{p.frame}"

        if self.measure != p.measure or self.beat != p.beat:
            # Rebuild timestamp string like 1.4.5
            
            print(
                f"        [ERROR] Bad Timestamp at line {self.starting_line_number}: expected {self.line.strip()}, "
                f"actual {actual_ts}"
            )

            p.measure = self.measure
            p.beat = self.beat
            p.frame = self.frame  #Correct Only if wrong.


        elif self.frame != p.frame:
            print(
                f"            [WARN] Frame-Misaligned at line {self.starting_line_number}: expected {self.line.strip()}, "
                f"actual {actual_ts}"
            )




class Token_Manual_BP:
    def __init__(self, line_number, line, parent):
        self.starting_line_number = line_number
        self.line = line
        self.parent = parent

        if self.line.startswith("BP .set"):
            raw_note_name = self.line[len("BP .set"):].strip()
        else:
            raise ValueError(f"Malformed BP .set line at {line_number}: {line}")

        # Parse note
        match = NOTE_RE.match(raw_note_name)
        if not match:
            self.parent.out.error(f" Invalid note format at line {line_number}: {raw_note_name}")

            match = NOTE_RE.match("A0")

        note_letter = match.group(1).upper()
        accidental = match.group(2).lower()
        octave = int(match.group(3))
        self.octave_flag = match.group(4)  # '+', '-', or None

        note_name = note_letter + accidental if accidental else note_letter
        if note_name not in NOTE_MAP:
            raise ValueError(f"Unknown note {note_name} at line {line_number}")

        base_pitch = NOTE_MAP[note_name] 
        base_pitch += (octave * 12)

        # Apply octave flag if present
        if self.octave_flag == "+":
            base_pitch += 12
        elif self.octave_flag == "-":
            base_pitch -= 12

        self.midi = base_pitch
        self.raw_note_name = raw_note_name
        return #End Init

    def __repr__(self):
        return f"    <Line {self.starting_line_number}, Set_Pitch, {self.raw_note_name}, {self.midi}>"

    def execute(self, ch):
        self.parent.bp_var = self.midi
        if self.parent.bp != self.midi:
            self.parent.out.note(f" Bad Manual BP .set at line {self.starting_line_number}: expected {self.parent.bp},")




class Song:
    def __init__(self, filepath):
        self.filepath = filepath
        self.channels = []
        self.load_bpm()

    def load_bpm(self):
        """Finds the '_8th .set <value>' line and stores the numeric value. 
        Falls back to prompting the user if not found or malformed."""
        try:
            with open(self.filepath, "r") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("_8th .set"):
                        parts = line.split()
                        self.bpm = int(parts[2])  # "_8th", ".set", <number>
                        print(f"BPM (frame per 8th note) found: {self.bpm}")
                        return
                    
        except (IndexError, ValueError):
            print(f"Malformed BPM line found in {self.filepath}. Line: {line}")
        except FileNotFoundError:
            print(f"File not found: {self.filepath}")

        # Fallback: ask user manually
        while True:
            user_input = input("Enter frame per 8th note (integer): ")
            try:
                self.bpm = int(user_input)
                return
            except ValueError:
                print("Invalid input. Please enter a valid integer.")


    def load(self):
        """Scan the file for channel start lines and register channels."""
        verify_name = []
        with open(self.filepath, "r") as f:
            song_raw_lines = [line.rstrip("\n") for line in f]  # remove trailing newlines
            for i, line in enumerate(song_raw_lines, start=1):  # start=1 so line numbers match text editors
                line = line.strip()
                if line.startswith("Channel "):
                    # Remove inline comments
                    line_no_comment = line.split(";", 1)[0].strip()

                    # Split into keyword + rest
                    _, rest = line_no_comment.split("Channel ", 1)

                    # Split on comma (scope) if present
                    if "," in rest:
                        left, scope = [part.strip() for part in rest.split(",", 1)]
                    else:
                        left, scope = rest.strip(), None

                    # Left part should look like SongName_Type
                    if "_" in left:
                        song_name, ch_type = left.split("_", 1)
                    else:
                        raise ValueError(f"Malformed Channel Name: {left}")

                    self.channels.append(Channel(ch_type, scope, i, song_raw_lines, self))
                    verify_name.append(song_name)
        
        if not all(x == verify_name[0] for x in verify_name):
            raise ValueError("Inconsistant Channel Name")

    def __repr__(self):
        return f"<MusicFile {os.path.basename(self.filepath)} channels={len(self.channels)}>"





def strip_inline_comments(line: str) -> str:
    """
    Strip trailing comments from a line, unless the line
    is just a comment (only whitespace before ';').
    """
    if ";" in line:
        code, comment = line.split(";", 1)
        if code.strip():  # there's real code before the semicolon
            code = code.strip()
            return code
        else:  # comment-only line, keep it
            line = line.strip()
            return line
        
    line = line.strip()
    return line

class Print_Handler:
    def __init__(self):
        # Keep a set of unique warnings/errors
        self._printed_messages = set()

    def note(self, msg):
        """Print a warning only once."""
        if msg not in self._printed_messages and ENBALE_NOTES:
            print(f"                [NOTE] {msg}")
            self._printed_messages.add(msg)

    def warn(self, msg):
        """Print a warning only once."""
        if msg not in self._printed_messages:
            print(f"            [WARN] {msg}")
            self._printed_messages.add(msg)
        elif ENBALE_NOTES:
            print(f"                [DUPLICATE] {msg}")

    def error(self, msg):
        """Print an error only once."""
        if msg not in self._printed_messages:
            print(f"       [ERROR] {msg}")
            self._printed_messages.add(msg)
        elif ENBALE_NOTES:
            print(f"                [DUPLICATE] {msg}")

def load_single_file(initial_dir):
    """Open file dialog and return path to selected .s file."""
    Tk().withdraw()
    filename = filedialog.askopenfilename(
        initialdir=initial_dir,
        title="Select one .s file",
        filetypes=[("ASM files", "*.s")]
    )
    return filename if filename else None

def main():
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    
    #filepath = os.path.join(SCRIPT_DIR, "Toads_TurnPike_Manual.s")
    filepath = load_single_file(SCRIPT_DIR)
    """
    This is to open the dialog box to select a file. Perfect for final product.
    """


    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
    else:
        print(f"Using file: {filepath}")


    song = Song(filepath)
    song.load()

    enabled_channels = (
        "sq0",
        "sq1",
        "tri",    
        "noise",
         "dmc",    
    )

    for ch in song.channels:
        ch_suffix = ch.ch_type.rsplit("_", 1)[-1].lower()

        if ch_suffix not in enabled_channels:
            continue
        try:
            print()
            print(ch) #print(f"<Channel .....)

            ch.tokenize_raw_lines()

            print(f"  <Token Execution:")

            for token in ch.tokens:
                token.execute(ch)
        except Exception as e:   
            print(f"   [EXCEPTION] {e}")
            continue
    return song

ENBALE_NOTES = False

if __name__ == "__main__":
    i = 10
    while i>0:
        print()
        i -= 1

    song = main()

    print()
