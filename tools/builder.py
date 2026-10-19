from pathlib import Path
import shutil
import platform
import subprocess


# ============================================================
# Project Root
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent


# ============================================================
# Find cc65 Tools
# ============================================================

def find_tool(name):
    """
    Find a cc65 executable.

    Search order:
        1. System PATH
        2. Common cc65 installation locations
    """

    tool = shutil.which(name)

    if tool:
        return Path(tool).resolve()

    candidates = []

    if platform.system() == "Windows":
        candidates += [
            Path("C:/cc65/bin") / f"{name}.exe",
            Path("C:/Program Files/cc65/bin") / f"{name}.exe",
            Path("C:/Program Files (x86)/cc65/bin") / f"{name}.exe",
        ]

    else:
        candidates += [
            Path("/usr/bin") / name,
            Path("/usr/local/bin") / name,
            Path("/opt/cc65/bin") / name,
        ]

    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve()

    return None


def find_cc65():
    """Find ca65 and ld65."""

    ca65 = find_tool("ca65")
    ld65 = find_tool("ld65")

    missing = []

    if ca65 is None:
        missing.append("ca65")

    if ld65 is None:
        missing.append("ld65")

    if missing:
        names = ", ".join(missing)

        raise RuntimeError(
            f"Could not find {names}.\n"
            "Please install cc65 and either add it to PATH "
            "or install it in a standard location."
        )

    return ca65, ld65


# ============================================================
# Build
# ============================================================

def build(ca65, ld65):

    

    source = PROJECT_ROOT / "engine" / "main.s"
    object_file = PROJECT_ROOT / "engine" / "main.o"
    config = Path(__file__).resolve().parent / "builder.cfg"
    output = PROJECT_ROOT / "Tri_Pulse_Engine.nes" #Change to alter default build location

    print()

    try:
        print(f"================================================================================")
        print(f"Building Project: {PROJECT_ROOT.name}")
        print(f"================================================================================")

        subprocess.run(
            [
                str(ca65),
                "-I",
                str(PROJECT_ROOT),
                str(source),
                "-o",
                str(object_file),
            ],
            check=True,
        )

        subprocess.run(
            [
                str(ld65),
                "-C",
                str(config),
                str(object_file),
                "-o",
                str(output),
            ],
            check=True,
        )

        print()
        print(f"Build successful: {output}")
        print()

    except subprocess.CalledProcessError:
        print()
        print("Build Failed")
        print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    ca65, ld65 = find_cc65()
    build(ca65, ld65)

    print()