# Tri-Pulse NES Audio Engine — v0.2.0

Version 0.2 introduces substantial improvements to the engine's organization, usability, and development workflow. Several existing systems have been overhauled, new macros have been introduced, and some basic debugging and optimization tools are now included.

Documentation remains based on v0.1, and it does not reflect the changes introduced in v0.2. Updated documentation is planned for a future hotfix. (Likely after the New Year.)

### Overhauled Macro Systems
- `SFX`
    - Removed the seperate sweep system. (If it is re-introduced, it will be integrated as an extension of the new format rather than a separate format.)
    - Added aliases for Noise Period / DMC Rate `R0`..`R15`.
- `Env`
    - Introduced a new argument format.
    - Fixed a design flaw with envelopes updating before being used.

### New Macros
- `Vibrato_Cycle`
    - Defines available vibrato cycles (including none) used by envelopes.

- `Vibrato_Delay`
    - Defines available delay timers used by envelopes.

- `Kick_Type`
    - Defines which registered DMC SFX can be selected by `Noise_Header`.

- `Duration_Set`
    - Defines user-configurable duration sets.

- `MiscFX`
    - Defines various one-time effects.
        - *Macro implementation is incomplete.*

### Song Data DSL Changes
The Domain-Specific-Language (DSL) is mostly unchanged, although numerous tweaks have been made. The following changes are not comprehensive.
- Renamed `Env_Change` to `Set_Env`. (To match `Set_Volume` and `Set_Pitch`.)
- Removed the requirement for curly braces `{}` around certain macro arguments.
- Expanded the types of arguments accepted by `Duration` and other macros.
    - The current system is somewhat fragile. A robust type-validation system is planned for a future release.
- Increased error checking.

### Miscellaneous Notes

#### Organization
- Macro Definitions are seperated topically.
    - Multiple seperate `.s` files for very different subjects. 
    - Subheaders within files for related subjects.
- ROM Data organization, with sections aligned to 8 kB boundaries.
    - Song Data begins at $8000.
    - UI code and LUTs begin at $a000.
    - Music Engine code and LUTs begin at $c000.


#### Debugging Tools:
- Basic Implimentations in `user/Config.s`.
    - Some crash error descriptions and deubgging instructions are done.



#### VS Code Theme
- Updated the Tri-Pulse Studios CA65 theme.
    - Noise SFX are now highlighted.
    - Instruction Macros (e.g., `Notes`, `Set_Env`) and Registration Macros (e.g., `Song`, `Env`) are now colored seperately.
- Reorganized theme definitions for improved maintainability.


#### Tools
- Added `tools/Raw Byte Riff Analyzer.py`. 
    - It scans raw Song Data and highlights some potential optimizations.