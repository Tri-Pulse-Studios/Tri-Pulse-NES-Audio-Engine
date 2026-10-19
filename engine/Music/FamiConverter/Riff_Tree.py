import re
import os
from tkinter import Tk, filedialog
import sys

def parse_lines(text):
    """Split text by channels and keep only labels and Riffs."""
    all_channels = []
    current_lines = []

    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue

        # Remove inline comments
        line = re.split(r";", line)[0].strip()
        if not line:
            continue

        # Start of a new channel
        if line.startswith("Channel"):
            if current_lines:
                all_channels.append(current_lines)
            current_lines = [line]
            continue

        # Keep labels
        if re.match(r"^_[\w.]+:", line):
            current_lines.append(line)
            continue

        # Keep Riff calls
        if line.startswith("Riff"):
            m = re.match(r"Riff\s+([_\w.:]+)\s*,\s*([_\w.:]+)", line)
            if m:
                start, end = m.groups()
                current_lines.append(f"Riff {start}, {end}")
            else:
                current_lines.append(line)  # complex or unresolvable Riffs
            continue

    if current_lines:
        all_channels.append(current_lines)

    return all_channels


def find_label_indices(lines):
    """Return mapping label -> index in lines"""
    return {line[:-1]: idx for idx, line in enumerate(lines) if line.endswith(":")}


def traverse(idx, lines, label_indices, depth=0, end_label=None, out_lines=None):
    """Recursive function that appends lines to out_lines instead of printing."""
    if out_lines is None:
        out_lines = []

    while idx < len(lines):
        line = lines[idx]

        # Check if we reached the end of current Riff
        if end_label and line.startswith(end_label + ":"):
            return idx  # Return to caller

        # Label line
        if line.endswith(":"):
            label = line[:-1]
            if depth == 0:
                next_idx = idx + 1
                if next_idx < len(lines) and lines[next_idx].startswith("Riff"):
                    out_lines.append("")
                    out_lines.append(f"{label}")  # Only keep interesting root labels
            idx += 1
            continue

        # Riff line
        if line.startswith("Riff"):
            m = re.match(r"Riff\s+([_\w.:]+)\s*,\s*([_\w.:]+)", line)
            if m:
                start_label, new_end_label = m.groups()
                start_idx = label_indices.get(start_label)
                end_idx = label_indices.get(new_end_label)

                # Only recurse if both labels exist
                if start_idx is not None and end_idx is not None:
                    prefix = " └─ " if idx == len(lines) - 1 else " ├─ "
                    out_lines.append(" ├   " * depth + prefix + line)
                    traverse(start_idx, lines, label_indices, depth + 1, new_end_label, out_lines)
                else:
                    # One or both labels missing → treat as unresolvable
                    out_lines.append(" ├   " * depth + " └─ " + line)
                    out_lines.append(" ├   " * (depth + 1) + " └─ " + "?")
            else:
                # Complex Riff (no match)
                out_lines.append(" ├   " * depth + " └─ " + line)
                out_lines.append(" ├   " * (depth + 1) + " └─ " + "???")
            idx += 1
            continue

        # Skip unknown lines
        idx += 1

    return idx



def collapse_leaf_riffs(out_lines):
    """
    Collapse 3+ consecutive leaf Riffs at the same branch depth
    into a single line with ... xN, plus an extra indentation line.
    """
    collapsed = []
    i = 0

    def get_depth(line):
        """Count the number of '├' or '└' characters before '─'."""
        match = re.match(r"^([├└]+)─", line.replace(" ", ""))
        if match:
            return len(match.group(1))
        return 0

    def get_indent(line):
        """Return the string of characters before the last '─' (for extra line)."""
        return line.rsplit('─', 1)[0] if '─' in line else line

    while i < len(out_lines):
        line = out_lines[i]
        depth = get_depth(line)

        # Only consider lines that contain "Riff"
        if "Riff" in line:
            riff_lines = [line]
            j = i + 1

            # Collect consecutive lines with the same depth
            while j < len(out_lines):
                next_line = out_lines[j]
                if "Riff" in next_line and get_depth(next_line) == depth:
                    riff_lines.append(next_line)
                    j += 1
                else:
                    break

            if len(riff_lines) >= 3:
                # Collapse group
                collapsed.append(f"{riff_lines[-1]}  x{len(riff_lines)}")
                # Add extra indentation line
                collapsed.append(get_indent(riff_lines[-1]))
                i = j
                continue

        collapsed.append(line)
        i += 1

    return collapsed




if __name__ == "__main__":
    # File picker
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    parent_dir = os.path.dirname(script_dir)

    Tk().withdraw()
    file_path = filedialog.askopenfilename(
        title="Select your music file",
        initialdir=parent_dir,
        filetypes=[("Text or Source Files", "*.txt *.s *.asm *.inc"), ("All Files", "*.*")]
    )

    if not file_path:
        print("No file selected. Exiting.")
        sys.exit(0)

    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()

    all_channels_lines = parse_lines(text)

    for channel_lines in all_channels_lines:
        print(channel_lines[0])  # Channel name
        label_indices = find_label_indices(channel_lines)
        idx = 1
        out_lines = []
        while idx < len(channel_lines):
            line = channel_lines[idx]
            if line.endswith(":"):  # Root label
                idx = traverse(idx, channel_lines, label_indices, depth=0, out_lines=out_lines)
            else:
                idx += 1

        # Collapse repeated leaf riffs
        out_lines = collapse_leaf_riffs(out_lines)

        # Print final output
        for l in out_lines:
            print(l)
        print()

print()