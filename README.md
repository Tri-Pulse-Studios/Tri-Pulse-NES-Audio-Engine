# Tri-Pulse-NES-Audio-Engine

NES audio engine featuring 5-channel music playback and game SFX, using Tri-Pulse DMC samples for bass.

New here? Start with [Getting Started](#getting-started). If you're ready to write music, jump to [Song Authoring](#song-authoring).

# Table of Contents

* [Getting Started](#getting-started)
* [Project Organization](#project-organization)
* [ca65 Syntax](#ca65-Syntax)
* [User Data Authoring](#user-data-authoring)
* [Song Authoring](#song-authoring)
* [Troubleshooting](#troubleshooting)
* [License](#license)



# Overview
- The Tri-Pulse NES Audio Engine supports 5 channel playback, designed around compact sound data, efficient playback, and flexibility to compose a wide variety of music and SFX.

- For reference, Super Mario Bros. (1985), like other NES games without additional mapper hardware, operates within tight hardware constraints: 2kB of RAM, 32kB of Code/Data, and roughly 30k CPU cycles per frame.

- A full game can only devote a small percent of those recourses to audio. This engine was designed with these constraints in mind.

- As such, the engine prioritizes compact music data first, and ease of authoring sound data second.


## Features

* Five-channel audio playback:
  * Pulse 1
  * Pulse 2
  * Triangle
  * Noise
  * DMC, repurposed to play Tri-Pulse samples for bass

* SFX both for gameplay, and musical percussion effects.

* A realistic maximum of 32 unique Envelopes
    * Envelopes have a simple Attack, Decay, Sustain, and Release phase.
    * Four configurable vibrato speeds. (Including no vibrato.)
    * Four configurable vibrato delay amounts.
    * Four run-time swappable vibrato depth factors.

* A stand-alone ROM with a UI for playing back music.

## Tri-Pulse soundwaves
Just as a Square wave is the simplest Pulse wave, a Triangle wave is the simplest Tri-Pulse wave.

The 25% and 12.5% duty-cycle Pulse waves are extensions of the Square wave family.

In exactly the same way, the 25% and 12.5% duty-cycle Tri-Pulse waves are extensions of the Triangle wave family.

For Pulse waves, duty cycle is how long the output is high. For Tri-Pulse waves, it is how long the output ramps upward. Hence, a Triangle wave is a 50% duty-cycle Tri-Pulse.

A Square wave and Triangle wave share the same harmonic profile, but Pulse harmonics decay as 1/n, while Tri-Pulse harmonics decay as 1/n². The same relationship applies to the 25% and 12.5% duty-cycle waveforms: each Tri-Pulse has the same harmonic profile as its corresponding Pulse wave, but with 1/n² decay instead of 1/n.

### Mathematical Definition

For a Tri-Pulse wave with a duty cycle, `d`:

```text
f(t) = t/d,           0 <= t < d
       1 - (t-d)/d,   d <= t < 2d
       0,             2d <= t < 1


f(t)
 1 |     /\
   |    /  \
   |   /    \
   |  /      \
 0 | /        \__________
   +---------------------------- t
     0    d    2d        1
```
where `0 < d <= 1/2`.

For `1/2 < d < 1`, the waveform is the vertical inversion of the waveform with duty cycle 1-d, similar to how 25% and 75% Pulse waves are inverted.
### Harmonics Formulae

The magnitude of the n-th harmonics are proportional to:

**Pulse:**
```text
H(n) ∝ |sin(π*n*d)| / n
```

**Tri-Pulse:**
```text
H(n) ∝ sin²(π*n*d) / n²
```


## Resource Usage

**CPU**

* Average: ~2,000 clock cycles per frame (about 8% CPU usage).
* 10% Worst: ~4,500 clock cycles per frame (about 15% CPU usage).

    VERIFY 

**ROM**

* Engine code and shared data: approximately 2 KB. (Tri-Pulse Samples take only a few hundred.)
* Typical one-minute song: approximately 300-700 bytes, depending on complexity.

**RAM**

* Total: 338 bytes. (Downgradable to 258 Bytes)
* Zero-page: 18 bytes.



    

# Getting Started

## Dependencies

**Required**

* [ ] **ca65 and ld65** ([CC65 toolchain](https://cc65.github.io/)) - Assemble and link the engine.
* [ ] **Python 3** - Run the build scripts.

**Recommended**

* [ ] **Visual Studio Code** - Recommended code editor.
* [ ] **Tri-Pulse Studios Theme** - Recommended FamiStudio theme.
* [ ] **Mesen** - Recommended NES emulator.
* [ ] **FamiStudio** - Recommended music editor. Open `user/Example_Songs.fms` in FamiStudio.
* [ ] **YY-CHR.net** - Recommended NES tile editor.

## Building the ROM

1. Clone or download the repository.
2. Open the project in Visual Studio Code.
3. Run the default build task with `Ctrl+Shift+B`.
4. Open `Tri_Pulse_Engine.nes` in Mesen. The ROM is generated in the project root.

## Playing the Example Songs

The `user/Song_Data/Examples/` directory contains completed example songs playable in the ROM.

**ROM Controls**

**Up / Down:** Cycle through tracks.
**A:** Play the highlighted track.
**B:** Stop playback.



## Installing the Tri-Pulse Studios Theme

*Instructions coming soon.*

## Making Your Own Music

Start by composing music in FamiStudio. Other DAWs, such as FL Studio, can also be used, but designing Envelopes and other NES-specific sound features is more difficult without NES-accurate audio tools.

Support for alternative DAWs, including plugins for Tri-Pulse soundwaves, is planned for a future release.

Start with opening `user/Song_Data/Blank_Template.s` and `user/Example_Songs.fms`, then follow the [Song Authoring](#song-authoring) guide.


# ca65 Syntax
- Common ca65 assembler syntax and conventions used throughout this README.

**`<Variable_Name>`:** A placeholder representing a variable name or value. Replace it with the appropriate name or value. Do not include the angle brackets.
**`::<Variable_Name>`:** References a global symbol, allowing it to be accessed outside its local scope.
**`_` in names:** Underscores are used to separate words or encode parameters in names, such as `No_Vib` and `T_2f__d25`.
**{<Params>, <Comma>, <Separated>}:** Groups comma-separated parameters into a single macro argument. The brackets are required. Only required by a few macros.


**Hexadecimal values:** Prefixed with `$`. For example, `$a5`.
**Binary values:** Prefixed with `%`. For example, `%10100101`.

**`$xx`:** A placeholder byte.
**Upper nibble, lower nibble unspecified:** `$0-` through `$F-`
**Lower nibble, upper nibble unspecified:** `$-0` through `$-F`
- The hypen is a placeholder for the nibble not currently being discussed.

 - **`.set`:** Assigns a value to a symbol that can be reassigned later. For example, `Song_NB .set NoiseFX_Index`.
**`=`:** Assigns a value to a symbol that can **not** be reassigned later. For example, `As0 = 1`.

**Backticks in this README:** Surround code names and short code examples, such as `Shift_Pitch` or `Kick_Types`.
**Code blocks:** Larger code examples are displayed in fenced code blocks, often with `asm` specified for syntax highlighting.
 - **`#`, `##`, and `###` headings:** Used to organize the README into sections, files, and individual topics, respectively.

**`ALL_CAPS`:** Text displayed on-screen by the engine.






# Project Organization
- The file and folder hierarchy of this project.

```text
Tri-Pulse-NES-Audio-Engine/
├── README.md
├── TODO.md
├── LICENSE
├── Tri_Pulse_Engine.nes
├── engine/
├── include/                       [Planned]
├── tools/
│   ├── builder.cfg
│   ├── builder.py
│   └── packer.py                 [Planned]
│   └── song_validator.py         [Planned]
└── user/
    ├── Song_Data/
    │   ├── Blank_Template.s
    │   └── Examples/
    ├── Config.s
    ├── Engine_Data.s
    ├── SFX_Data.s
    └── UI_Data_and_Song_Registry.s
```

## Root Directory

**`README.md`**: Project documentation. If you're reading this, you've already found it.
**`TODO.md`**: Project roadmap. 
**`LICENSE`**: Project license. See [License](#license).
**`Tri_Pulse_Engine.nes`**: Bundled Example Songs ROM and default output location for new ROM builds.

## `engine/`
- Contains the music and sound effects engine code.

## `include/`
*Planned for a future release.* Will contain API settings and instructions.

## `tools/`

- Contains the project build tools and configuration.

**`builder.cfg`**: Build configuration.
**`builder.py`**: Default ROM build script.
**`packer.py`**: *Planned for a future release.*
**`song_validator.py`**:*Planned for a future release.*

## `user/`

- Contains user-configurable engine data and song definitions.

**`Song_Data/`**: 
- Contains song source files.
- User-created `song.s` files should go here or in user-created subfolders. 

  **`Blank_Template.s`**: Template and scaffolding for new songs.
  **`Examples/`**: Song Data for completed songs playable in the Bundled ROM

**`Config.s`**: User-adjustable engine settings, including RAM allocation and debugging options.
**`Engine_Data.s`**: Envelope, Vibrato, and Duration Set definitions.
**`SFX_Data.s`**: SFX definitions, Noise Bank configuration, and Kick Types.
**`UI_Data_and_Song_Registry.s`**: UI text definitions and the song registry.



# User Data Authoring
- Where and how to configure various engine-wide settings and data

## `user\Config.s`
- This file contains engine configuration settings for memory allocation and runtime debugging.

**RAM Allocation:** Configures the starting addresses for ZP RAM, standard RAM, and the Riff Buffer.
**Runtime Debugging Tools:** Configures the engine's runtime debugging tools.


### RAM allocation

Configure the starting addresses for ZP RAM, standard RAM, and the Riff Buffer.
Each allocation reserves a fixed amount of contiguous memory, so the configured regions must fit within their valid address ranges and avoid overlapping other allocations. 
The comments in Config.s detail valid ranges and memory requirements.

### Runtime Debugging Tools
If a check detects an error, the NES deliberately crashes. This is to help identify where things went wrong, and prevent execution in an invalid state.


To identify the cause of an error:

1. Set Debugging_Enabled = 1 and Rebuild the ROM
2. Open the ROM in Mesen and reproduce the error.
3. Open Mesen's debugger and copy the address of the STP opcode. This should match the current Program Counter (PC).
4. Set Debugging_Crash_Address to that address. For example, Debugging_Crash_Address = $8AC7.
5. Rebuild the ROM. The specified crash address will identify the code responsible for the runtime error, along with an explanation of the error and any additional debugging instructions.

*Crash error descriptions and debugging instructions planned for a future release*



## `user\Engine_Data.s`
- This file contains engine-wide data, including Envelopes, Vibrato, and Duration Sets.

**Envelopes:**     Defines how instrument Envelopes are specified, named, organized, and optimized.
**Vibrato:**       Defines the Vibrato Cyles, and Delay Timers.
**Duration Sets:** Defines the available Duration Sets for data compression.
**DMC Samples:** *Details to be released in a future update.*

### Envelopes

#### Envelope definitions


Envelopes are defined using the Env macro. Each definition specifies an Envelope size, a name, and the parameters controlling its behavior.


**Example:** 
```asm
Env "6b", Lead_sqr_13_0, \
    $d0, -$20, $6c, -$0c, $00, \
    _d50, atk_4, _d50, _0f, _d50, \
    Vib_None, No_Delay, \
    dmc_d25
```

- The first argument specifies the Envelope's storage size. (From 3 to 6 bytes.) 
- The second assigns it a name. (Used to reference the Envelope in a song's data.) 
- The remaining arguments define the Envelope's parameters.

Envelopes omit unused features to reduce ROM usage.
See [Envelope optimization](#envelope-optimization) for organization requirements.

Four Envelope sizes are supported:
```text
+------+--------+------------------------------+
| Size | Params | Special behavior             |
+------+--------+------------------------------+
| "6b" | 13     | All functions                |
| "5b" | 12     | No DMC pitch                 |
| "4b" | 9      | No Attack phase              |
| "3b" | 8      | No Attack phase or DMC pitch |
+------+--------+------------------------------+
```
- The `Env` macro expects the exact number of Params supplied for a given size.
    - Params specified to be (Optional) below **must** be omitted when a given size omits those functions.

See [Envelope Naming](#envelope-naming-shorthand) convention for suggested naming.

##### **Params Row 1. Volume and Rate Parameters **

The first row of parameters define, in order:
- Attack Volume
- Attack Rate
- Decay Volume
- Decay Rate
- Sustain Volume

The Attack Rate and Decay Volume params are omitted by `"4b"` and `"3b"` Envs


**Syntax**
- Volume values use quarter-fixed-point notation, for smoother volume ramps.
    - Values range from `0` to `15.75` in increments of `0.25`. 
    - They are multiplied by `$10 (16)` and written in hexadecimal.

    - For example, a volume of `4.75` is encoded as `$4c`:

        * The upper nibble represents the whole-number portion (`$0-` to `$f-`).
        * The lower nibble represents the fractional portion: `$-0`, `$-4`, `$-8`, or `$-c`, corresponding to `.00`, `.25`, `.50`, or `.75`.

- When volume values are written to the APU, the fractional portion is truncated. 
    - For example, a volume of `4.75` is truncated to `4`



**Attack Volume:** Initial volume of an Envelope. 
- Valid `$10..$f0`. Only integers, no quarters.


**Attack Rate (Optional):** Volume change per frame of Attack phase.
- Range: `-$20` (`-2.00/f`) to `+$1c` (`+1.75/f`), in increments of `0.25`.
- The attack phase lasts for X frames according to attack_length (see below)

- **WARNING:** The attack phase has no bounds checks.
    - An under/overflow results in undefined behavior.


**Decay Volume (Optional):**  Initial volume of decay phase.
- Valid `$10..$fc`. Quarters allowed.
- May be discontinuous with Attack phase. (Allows for an echo effect.)


**Decay Rate:** Volume change per frame of Decay phase.
- Range: `-$04` (`-0.25/f`) to `-$80` (`-8.00/f`), in increments of `0.25`. 
- The decay phase lasts until the volume would decrease below sustain

- Attack rates can increase or decrease volume, while decay rates are always negative.


**Sustain Volume:** Sustained volume.
- Valid `$00..$f0`. Only integers, no quarters.
- A value of `$00` eventually silences the channel.




**Triangle/Tri-Pulse:**
- The Triangle and DMC channels remain active while volume is nonzero.
- The volume level does not affect output amplitude.


**Example:** 
```asm
Env "6b", Lead_sqr_13_0, \
    $d0, -$20, $6c, -$0c, $00, \
    _d50, atk_4, _d50, _0f, _d50, \
    Vib_None, No_Delay, \
    dmc_d25
```

- Attack Init: $d0 (13.0) then -$20 (-2.0/f) which outputs:
      - 13.0, 11.0, 9.0, 7.0, before Attack timer expires

- Decay Init: $64 (6.25) then -$0c (-0.75/f) which outputs:
      - 6.25, 5.5, 4.75, 4.0, 3.25, 2.5, 1.75, 1.0, 0.25 before Sustaining at 0.00

- Combined, Truncated APU Volumes:
    - 13, 11, 9, 7, 6, 5, 4, 4, 3, 2, 1, 1, 0, 0...

##### **Params Row 2. Pulse Duty, Attack Length, and Cutoff Timers**

The second row of parameters define, in order:
- Attack Duty, 
- Attack Length (Optional)
- Decay Duty (Optional)
- Cutoff Timer
- Sustain Duty

The Attack Length and Decay Duty params are omitted by `"4b"` and `"3b"` Envs


**Pulse Duty Cycle**
- _d12, _d25, _d50, and _d75 specify the Pulse channel's duty cycle.
- The three duty parameters allow the duty cycle to change when the 
Attack, Decay, and Sustain phases begin, respectively.

- **NOTE:** These values control the Pulse channels' duty cycle only.
- Triangle ignores.
- Noise duty is configured per SFX definition.  See [SFX Data](#user-sfx_data-s)
- Tri-Pulse duty is configured below. See [dmc_lowest_d25](#params-row-4-tri-pulse-duty)


**Attack Length (Optional)**
- Specifies how many frames the attack phase lasts. (From 1 to 14 frames)
- Use the variables atk_1 through atk_14 (Internally the values are 2..15)

**Cutoff Timer**
- Specifies how many frames the channel silences at the end of a note. (From 0 to 6 frames)
- Use the variables `_0f` through `_6f`
- A Cutoff of `_0f` will not silence the channel.

##### **Params Row 3. Vibrato Speed and Delay**

The third row of parameters defines, in order:

- Vibrato Speed 
- Vibrato Delay

**Vibrato Speed**

* Specifies the vibrato speed.
* Use one of the following constants:

  * `Vib_None`: No vibrato
  * `Vib_Fast`: Cycles every 6 frames
  * `Vib_Med`:  Cycles every 8 frames
  * `Vib_Slow`: Cycles every 12 frames

- The vibrato speeds can be configured. See [Vibrato](#vibrato-delays)

**Vibrato Delay**

* Specifies the delay before vibrato begins.
* Use one of the following constants:

  * `No_Delay`: No vibrato delay
  * `Short_Delay`: Delays 8 frames
  * `Med_Delay`:   Delays 15 frames
  * `Long_Delay`:  Delays 28 frames

- The vibrato delays can be configured. See [Vibrato](#vibrato-cycles)




##### **Params Row 4. Tri-Pulse Duty**

The fourth row specifies when to play 25% or 12.5% Tri-Pulse duty cycles.

The Tri-Pulse duty param is omitted by `"5b"` and `"3b"` Envs

**Usage**
- Use `dmc_d25` for 25% Duty Tri-Pulse.
- Use `dmc_d12` for 12.5% Duty Tri-Pulse.

The other duty cycle will automatically be used if an out-of-bound pitch 
for the current duty cycle is used.

- Most of the time, use `dmc_d25` or `dmc_d12` 
to maximize the available pitch range for the desired duty cycle

- A custom threshold can be set to switch duty cycles based on pitch. 
    - For example, setting the threshold to F♯2 `(Fs2)` results in B0 to F2 playing as 12.5%, and F♯2 to C4 playing as 25% 

    - Valid custom range: A♯1 `(As1)` through C♯3 `(Cs3)`.

**Pitch Ranges**

The available pitch ranges for each duty cycle are:

- **12.5% Tri-Pulse:** B0 to C3
- **25% Tri-Pulse:** A♯1 to C4


#### Envelope banks
Envelopes are organized into banks of 16.

- Switching between envelopes within a bank is simple.
    - It takes only One Byte of music data to do this swap.
    - The macros error check if an out-of-bank swap is attempted.

- Switching banks mid-song is possible, but not recommended for beginners. 
    - It takes Two Bytes of music data.
    - Bank error checking is disabled for the rest of that channel’s data, making debugging harder.

- See [Set_Env Instruction](#env_change-and-set_env-instructions)for details


**NOTE:** This does not apply to Noise Channel envelopes.
- Noise sets the envelope per-note, and ignores the bank.

**Defining Banks**

- The first bank must be initialized using:`Env_Bank "Init_Index", <Starting_Index>`
    - The `"Init_Index"` can be anything, but that makes the macro clearer
    - `<Starting_Index>` can be from 0..15, leaving the preceding spots empty. (This does not waste ROM.)
    - See [Envelope Optimization](#envelope-optimization) for details.

- All subsequent banks are defined using just: `Env_Bank`

- Empty slots in banks are filled with unused ROM bytes, so fill banks to capacity where possible.
- Noise envelopes are ideal for filling unused slots, since the Noise channel ignores the bank.




#### Envelope naming shorthand
The minimum data needed for an Envelope to be recognizable is included

##### Pulse Channels

- `Lead` / `Pad` = General instrument type
- `sqr` / `d12` / `d25` / `d75` = Duty cycle
- `_X_Y` = Volume Init markers,   Attack, Sustain        
- `_X_Y_Z` = Volume Init markers, Attack, Decay, Sustain 
- `_sX` = X is Sustain Volume (0 - 15)
- `_vX` = Vibrato speed, in frames per cycle
- `_Xf_Ym` = X is Note Cutoff, in frames.
  - Channel is silenced for X frames at the end.
  - Channel will not be silnced for first Y frames. (If not specified, its a short time, like 2-4 frames.)

**Example: `Pad_d12_6_0`**

A "quiet" instrument, with 12.5% Duty (thin), and volume decaying from 6 to 0.

The note ends on its own, so there is no Cutoff marker.

The lack of a v6/v8/v12 marker means no vibrato.

##### Triangle / Tri-Pulse

- `T` = Identifier for Tri / Tri-Pulse
- `d12` / `d25` = Tri-Pulse's prefered Duty Cycle (Triangle ignores.)
- `_Xf_Ym` = X is Note Cutoff, in frames. (Same as Pulse.)
- `_vX` = Vibrato speed, in frames per cycle (Same as Pulse. Tri-Pulse ignores.)

**Example: `T_1f_2m_12v__d25`**

A Triangle / Tri-Pulse instrument. Tri-Pulse duty is 25% (Medium)

`1f_2m` = The channel silences for one frame at the end of a note.
- The channel will not attempt to silence until frame 3 or later of a note.

`12v` = slow vibrato.

`__d25` = Tri-Pulse defaults to using 25% Duty cycle.
- If a pitch is too low for 25%, it swaps to 12.5%
- The double underscore is intended, since only Tri-Pulse uses it.



#### Envelope optimization
- This section will cover how to organize envelopes of different sizes (The `"3b"` to `"6b"`) to minimize data usage.

*Details to be released in a future update.*









### Vibrato definitions
- This section will cover how to define custom vibrato cycles and delays.

*Details to be released in a future update.*

#### Vibrato Delays

#### Vibrato Cycles

### Duration Set definitions
- This section will cover how to define custom Duration Sets for song compression. 

- Duration Sets define common patterns of Note durations. 
These sets can then be invoked to compress Note Data to just the pitches.

*Details to be released in a future update.*

**NOTE:** The opcode `$0-` is hardcoded to be 16th Notes in Duration Sets.
- Normally, `$0-` is for the Two-Byte, Special Note Lengths.

- See [Duration Instruction](#duration-instruction) for Usage.

#### Limitations of 16th Notes.
- Every Duration Set must contain an even number of 16th notes.
- Those 16ths note must also be equally split amount the Set's upper and lower nibbles.

- Examples:
- `$00` is valid (Double 16ths) 
    - One 16th in the upper nibble, One 16th in the lower nibble.

- `$01, $0b` is invalid. (16th-8th-16th, followed by `Shift_Pitch`)
    - Both 16ths in Upper. None in Lower.
    - Use `$01, $b0`, or `$0b, $10` instead, where the placeholder `$b- Shift_Pitch` Opcode sits in the middle.

- Unbalanced 16th note Duration Sets may not stay synced to the beat.
- Specifically, odd Tempos will drift forwards or backwards a frame every time the Set is used.




#### Limitations of 16th Notes

- Every Duration Set must contain an equal number of 16th-note subdivisions in its upper and lower nibbles.
    - For example, `$00` encodes one 16th note in each nibble, producing two consecutive 16th notes.
    - `$01, $0b` is invalid because it encodes a 16th-eighth-16th pattern, followed by a `Shift_Pitch` instruction.
        - Duration Sets using this format may cause the channel to drift out of sync with the beat.
        - Specifically, odd Tempos may drift forwards or backwards by one frame.

- To encode this pattern correctly, use either `$01, $b0` or `$0b, $10`.
    - `$b0` is the no-operation form of `Shift_Pitch`, which serves as a placeholder between the two halves of the Duration Set.
    - The `$b-` opcode must occupy the midpoint so that both nibbles contain an equal number of 16th-note subdivisions.


## `user\SFX_Data.s`

- this file contains the data used to define sound effects and configure the Noise channel.

**SFX Definitions:** Defines sound effects used by the engine.
**Noise Bank:** Maps pitches to SFX.
**Kick Types:** Defines the default DMC SFX used in conjuction with Noise SFX.

### SFX Definitions

- Defines how to specify custom SFX for use both in-game and by the Noise channel.

*Details to be released in a future update.*

### Noise Bank
- Defines how to specify the list of SFX the Noise channel can play, and how to link a Noise Bank to a Song's Data.

**NB Overview**
- `NB` is a commonly used shorthand for Noise Bank.

- The Noise Bank maps "pitches" to SFX, similar to how electric keyboards can assign a unique sound to each key.
- As with the other channels, this is limited to a 15-"pitch" window, with an additional slot hardcoded as a rest.
- `Shift_Pitch` and `Set_Pitch` instructions can still move this window, 
though doing so with the Noise channel makes it harder to keep track of which pitches are playable.

#### Defining Custom NoiseFX entries
*Details to be released in a future update.*


#### Linking NB to Song Data

- A Noise Bank is linked to a song by defining a song-specific variable in the Noise Bank data, 
then referencing it in the song's header.

- In the Noise Bank definition, assign the desired `NoiseFX_Index` to a variable named after the song.
  For example:

  ```asm
  <Song_Name>_NB .set NoiseFX_Index
      NoiseFX <Data>
      ...
      NoiseFX <Data>
  Validate_NB <Song_Name>_NB
  ```

- Then in the song's header, reference the appropriate Noise Bank variable:

  ```asm
  Channel <Song_Name>_Noise
      Header ::<Song_Name>_NB, <Kick_Type>
  ```
- The `::` prefix accesses the global variable from outside the `Channel`'s local scope.

- The `Validate_NB` macro counts how many NoiseFX definitions are between the specified NoiseFX Index and the validator itself.
  - It produces an error if 16 or more definitions are found.
  - This is because the Noise Channel cannot play more than 15 pitches at a time. (Like all channels.)

- Definitions for different songs' NoiseFX can be interwoven in the same data.
- Different songs' Noise Banks can use the same NoiseFX Index. 
  - This is a requirement for a `Riff` instruction to reuse Noise data from another song.
  - See [Riff Instruction](#riff-instruction) for details.

- To use more than 15 NoiseFX in one song, use `Shift_Pitch` instructions.
  - Define additional `_NB` variables with their own `Validate_NB` calls.
  - Then use `Shift_Pitch <Old_NoiseFX_Index>, <New_NoiseFX_Index>`
  - See [Shift_Pitch Instruction](#shift_pitch) for details.



### Kick Types
- Defines how to specify the available DMC Kick Types, and how to link a Kick Type to a Song's Data.

- Each Noise Bank entry defines the Noise SFX and the corresponding DMC SFX to play simultaneously. When the DMC SFX is set to `"Kick"`, it uses the Kick Type selected in the song's header.
**NOTE:** This does not affect hardcoded DMC SFX in a Noise Bank entry.
  - Examples: 
    `NoiseFX Hat_2,    Hat_2`         will not play any DMC SFX
  - `NoiseFX Hat_A3,   Hat_2, A3_Tom` will always play A3_Tom
  - `NoiseFX Hat_Kick, Hat_2, "Kick"` will play the song's selected Kick Type

#### Linking Kick Types to Song Data
  ```asm
  Channel <Song_Name>_Noise
      Header ::<Song_Name>_NB, <Kick_Type>
  ```

- The Kick Type can be changed mid song with:
  - `Set_Pitch ::<Song_Name>_NB, <Kick_Type>`
  - See [Set_Pitch Instruction](#set_pitch) for details.

#### Defining Custom Kick Types
*Details to be released in a future update.*




## `user\UI_Data_and_Song_Registry.s`
- This file contains the data used to configure on-screen text and list all the songs playable by the engine.

**UI Text:** Defines tile aliases, compressed text aliases for Song Names, and the customizable subtitle.
**Song Registry:** Defines the list of songs and their displayed text.

### UI Text

#### Character Dictionary

- Maps characters to the tile IDs used to display them on screen.

- Alphanumeric characters `0`-`9` and `a`-`z` use indices `$00`-`$23`(0 - 35), respectively.
- A fairly comprehensive selection of symbols is available, though most are unlikely to be needed.

- The tile data is located at `engine/Tri_Pulse_UI_Tiles.bin`. 
Modify it as needed, but ensure the Character Dictionary is updated to match.

- **WARNING:** Tile IDs `$80`-`$ff` are not supported by the text engine. Using a tile ID greater than `$7f` results in undefined behavior.

- **WARNING:** Tile IDs `$3f` and `$ff` must remain empty.


#### Compressed Text Dictionary

- Defining static text elements, including the customizable Subtitle.

- Also defining reusable text sequences in Displayed Song Names for data compression.
- See [Using Text](#compressed-text-dictionary)

- A maximum of 127 characters can be defined in this dictionary.

**Format**

```asm
UI_Word <_Alias>, <_T, _E, _X, _T|$80>
```

* Defines reusable text character by character. `|$80` marks the end of a complete text entry.
**Note:** `UI_Word` entries cannot nest other `UI_Word` entries.

* Aliases start with `_`, primarily to allow names beginning with numbers to remain valid ca65 identifiers.


**Data Savings**

* Defining an entry requires the same amount of data as storing its raw character sequence once.
* Referencing an alias takes one byte, regardless of the number of characters it represents.

* A three-character sequence saves data if it appears at least two times.
* A two-character sequence saves data if it appears at least three times.

* Longer sequences and more frequent reuse provide greater savings.


**Advanced Combined Format**

* A text entry can reuse the trailing characters of another entry, gaining more dictionary options without any additional overhead costs.

* For example, if `TEXT` is already defined and `NEXT` appears elsewhere:

  ```asm
  UI_Word _TEXT, _T
  UI_Word _EXT, _E, _X, _T|$80
  ```

* Notice that `_TEXT` has no `|$80` terminator. Its final characters are supplied by the `_EXT` entry.

* Both _TEXT and _EXT can now be used as text entries. The raw sequence `_N, _EXT` takes two bytes instead of four, with no additional data overhead.







#### Custom Subtitle

- A customizable subtitle is displayed immediately below `TRI-PULSE STUDIOS`.

**Usage:** `UI_Word _SUBTITLE, <_T, _E, _X, _T|$80>`
- Like all complete text fragments, the subtitle must end with the `|$80` terminator
    - See [Compressed Text Dictionary](#compressed-text-dictionary) for details.

* Define `SUBTITLE_OFFSET = <Offset>` to specify the number of blank tiles inserted to the left of the subtitle.

**Note:** Like all `UI_Word` entries, the Subtitle cannot nest other `UI_Word` entries.

- Song names can still reuse the trailing characters of `CURRENT_TRACK_` and the custom subtitle. 
    - See [Using Text Definitions](#compressed-text-dictionary)for details.




### Song Registry

- Defines the song list, links song names to their corresponding song data, and explains how to use compressed text definitions in displayed song names.

**Usage:** `Song <Song_Name>, <Tempo>, {<UI_text>}`
  - `Song_Name` is the internal name used to find each channel's Song Data.
  - `Tempo` is an integer that determines the song's playback tempo. Typically, it specifies how many frames an eighth note plays.
  - `UI_Text` defines the text displayed on screen while the song plays, specified character by character.

**Example:** `Song Fanfare, 12, {_F, _A, _N, _F, _A, _R, _E}` 

  - If `FAN` has a defined alias, `UI_Text` can be shortened to `{_FAN, _F, _A, _R, _E}`
  - See [Compressed Text Dictionary](#compressed-text-dictionary) for details on when and how to make aliases.

- The list of Songs is the ordered list in which to cycle the tracks.



# Song Authoring
- The complete documentation of the Domain-Specifc-Language used to write Song Data, along with recommended workflows and label conventions.

- The following sections are ordered by their importance.

**NOTE:** Authoring a song directly using this engine is **way** too diffuclut.
- First, compose or remix a song in a DAW. 
- Once that is fully completed, Author the data for this sound engine using the DAW for reference.

## Overview
- In the simplest case, one note is played by one byte.
    - With more data, virtually any sequence of notes and many effects are possible.
    - When redundancy exists, multiple instructions can compress music data in different ways.

- The engine reads instructions one at a time, executing them until the next note is played.
    - After setting up the Note's length and pitch, that note, along with any pre-queued effects,are played.
    - Once that Note's length timer expires, new instructions are once again read.

    - By default, the envelope is reset and any special effects are cleared between notes.


- The Envelope and Base Pitch are defined in the header, and stay unchanged until told otherwise.
- The Base Pitch is the lowest pitch of the 15-pitch window that can be played at any one time.
- Example:
    - If the Base Pitch is C3, then `F3` to `G4` inclusive are playable.
    - If a note outside this range needs to be played, `Shift_Pitch` or `Set_Pitch` instructions
    need to shift the pitch window. 
    - See [Shift Pitch instruction](#shift_pitch) intstruction for details.

- BP is a common shorthand of Base Pitch


### Page Confinement

- The NES CPU uses a 16-bit address space.
  - The high byte of an address is the **Page Number**.
  - For example, Zero Page RAM occupies addresses `$0000` to `$00FF`, all within Page `$00`.

- Some 6502 ASM instructions have quirks regarding crossing page boundaries. This engine likewise has restrictions.
  - Specifically, it's like the `Zero Page Indexed` addressing mode of instructions. Reads are confined to one page (Hardcoded to $00 by hardware). A different kind of isntruction is needed to access data outside that Page.

- Song Data specifies the Page it is lcoated at, then keeps using that Page until explicity told to update it.
- This means the Music Engine can only see 256 bytes of data, per channel, at a time.
- If one channel wants to Riff the data of another channel, they must execute from the same page.

- If more than 256 bytes of data are used by a Channel, (or a group of Riffed Channels), explicity page incrimentes are required.
**NOTE:** If a Channel does not specify how to advance to the next page, it will loop back to the beginning of the current page, resulting in garbage data being read.

- See [Inc Page Instruction](#incriment-page) for details.


- With many songs, fitting everything without wasted ROM space is like fitting a bunch of round pegs in a series of square holes. The Page Binner tool automates this process.
*Page Binner to be released in a future version.*


### Timestamped Labels
- The recommended format for labels throughout the song is: `_<Measure_Number>_<Beat_Number>_<Frame_Number>`
  - The leading underscore makes numbers a valid ca65 label.

- Most often, just the Measure suffices. ie `_5:` marks the start of the 5th measure. 
    - Use a plain Measure Timestamps everywhere, except where it decreases legibility by splitting Notes lines or highly related structres.

- Only specify `_Measure_Beat:` where a `Riff` starts mid-measure.

- Only specify the Frame if the `_Measure_Beat:` label already exists.
    - Otherwise, truncating to `_Measure_Beat:` for readability is often worthwhile.

- When two labels with the same Timestamp are needed, (ie, to include or exclude an `Env_Change` with different Riffs), add a short word or abbreviation.
    - Examples include `_5_BP:, _5_Env:, _5_Pre_BP:`



## Scaffolding
- Scaffolding refers to the structural elements of a song file that the engine and build tools rely on. 

- These elements are not merely organizational. Changing or removing them can break the assembly or playback.

```asm
Channel <Song_Name>_<Channel>, [<Global_Designator>]
    Header {<BP>}, <Env>

    ...

    Loop <Song_Name>_<Channel>, [<Intro_Phrase>]
```

- The song template provides the required scaffolding. Channel, Header, and Loop must remain in place. 

**NOTE:** The Noise Channel has a slightly different scaffolding. See [Noise Channel Scaffolding](#noise-channel-scaffolding) below for details.


- **WARNING:** All Channels need to have atleast one Note in them, even if that is just `Notes whl,rest`.
- Otherwise, the engine softlocks, possibly even crashing the entire NES console.


### Channel Syntax
- `Channel` opens a ca65 `.scope`, named by the optional parameter `<Global_Designator>`.


- Replace `<Song_Name>` throughout the template with the song's name as defined in `User/UI_Data_and_Song_Registry.s`. The song's registry entry and channel names must match, including capatalization.

- Replace `<Channel>` with the mnemonic of this Channel's type.
    - They are `Sq0, Sq1, Tri, Noise, dmc`
    - Capatalization must match.

- The optional `<Global_Designator>` can be anything. Leave it blank unless it is needed.
    - It is recommended to name it  `<Shorthand_of_Song_Name>_<Channel>`

**Example:**
`Channel Fanfare_Sq0, FF_Sq0`

### Header Syntax
- The Header defines some intial state for the engine. 

`Header {<BP>}, <Env>`

- `<Env>` is the alias of the starting Envelope to use.
    - It also defines the Envelope Bank.

- `{<BP>}` is split into two sub-parameters: `{<BP>, [<Vibrato_Depth>]}`
    - If both parameters are used, the both must be wrapped with {}s.
    - If only `<BP>` is used, the brackets aren't needed.

- `<BP>` is the Base Pitch, the lowest of the 15 playable semi-tones
    - ie, if `BP = A0` then `A0` to `B1` are playable.
**Pitch range:** `A0..C6`

- `<Vibrato_Depth>` is the depth factor applied to Vibrato.
**Vibrato Depth Constants:** `Vib_Deep`, unspecified, `Vib_Shallow`, or `Vib_Very_Shallow`.

  * If unspecified, defaults to a standard, or medium depth. Leaving it unspecified is recommended for this setting.
    - **WARNING:** `Vib_Med` specifies Vibrato Speed, and is undefined behavior here.

**NOTE:** The perceived depth of vibrato depends on the playing pitch. 
- Higher pitches have deeper perceived vibrato, so a shallower Vibrato Depth setting may be needed to compensate.




**Loop Syntax:**

Upon executing the Loop statement, the Engine State is completely reset to how it was upon Initialization.

- The Envelope and Base_Pitch are reset according to `Header {<BP>}, <Env>`
- Execution is reset to the top, just below the Header, before beginning anew.
    - The provided label in `Loop` is used only for validating all the Channel's data is in one page. See [Page Confinement](#page-confinement) for context.

- Duration, If_Alt, the Riff Stack, and Repeat instructions all are reset to their starting state.

- All special effects are reset.


**Channel Sandboxes:**

Each channel is assembled in its own sandbox. Variables defined outside a channel are not automatically available inside it. The complete list of variables redefined inside each channel's scope is:
- The `_8th` variable, for custom Note Lengths. See [Custom Length Notes](#length-naming) Notes
- The Note Names `A0..C6` are `$00..$3f`
- The Duration Set Aliases
- The Kick Types



### Intro Phrases
- The `Loop` instruction can jump back to a custom location, skipping some intructions every time except the first playthrough.
    - Re-initializing a song through `jsr Init_Song` always resets it to start at the start of any Intro Phrase.

**Usage:**
```asm
Channel <Song_Name>_<Channel>, [<Global_Designator>]
    Header <BP>, <Env>

    ...

    <Intro_Label>:

    ...

    Loop <Song_Name>_<Channel>, <Intro_Label>
```

**NOTE:** The Engine State is fully reset to how it was when the Song was first Initialized, **not** the state it was upon reaching the end of the Intro Phrase the first time.


### Noise Channel Scaffolding
The only real difference is the `Header`

```asm
Channel <Song_Name>_Noise, [<Global_Designator>]
    Noise_Header <NB>, <Kick_Type>

    ...

    Loop <Song_Name>_<Channel>, [<Intro_Phrase>]
```
- `Noise_Header` expects the Noise Bank, then Kick Type.
    - These arguments are in the same format as `Set_Pitch` only Noise specific.
    - See [Noise Bank](#noise-bank) for details.

- The envelope is not specified at all
    - Noise Envelopes are set per-note, and the Bank does not matter

### _8th Variable
This variable is located at the top of all `Song.s` files, including `user\\Song_Data\Blank_Template.s`

Its purpose is to automatically calculate Custom Note Lengths that are inconvenient to write manually.
- Example: `Notes 16*_8th,rest` is a two-measure rest.

`_8th .set -1` is undefined.
- Attempts to use it when undefined result in assembly errors.



**Usage:**
- Typically, set it equal to the song's Tempo as definied in the Song Registry.
    - See [Song Registry](#song-registry)

- This variable is automatically redefined inside each Channel's sandbox
- No other variables are automatically passed into Channels.


**WARNING:** The engine does not enforce or validate these values.



## `Notes` Instruction

**Syntax:**
- Notes <Length>,<Pitch>, <Length>,<Pitch>, ...
  - The spacing between each Length, Pitch pair is optional, but reccomended for legibility.
  - Up to ten Length/Pitch pairs can be specified on one line. Five or fewer pairs are reccomended for legibility.
  - Simple and Custom Length notes can be mixed on one line.

**NOTE:** The pitch a `Notes` instruction plays is **not** hardcoded. 
will change if a Transposed Riff re-reads it.
    - See [Transposed Riffs](#transposed-riffs) for details.

- **WARNING:** The Engine's uses a hidden, ca65 assembly-time variable `BP` to calculating the pitch to play during execution.
    - In simple cases, `BP` is automatically updated to calculate pitches correctly.
    - In many cases, however, this variable does **not** accurately calculate the pitch. (Or incorrectly error out, thinking a pitch is not in range.)
        - See [Base Pitch Track](#base-pitch-tracking) Track


### Length Naming
Mnemonics for the six One-Byte Note Instructions are as follows:

```text
+----------+-------------------+-------------------+
| Mnemonic | Name              | Calculated Length |
+----------+-------------------+-------------------+
| 8th      | Eighth Note       | Tempo * 1         |
| qtr      | Quarter Note      | Tempo * 2         |
| dqt      | Dotted Quarter    | Tempo * 3         |
| hlf      | Half Note         | Tempo * 4         |
| dhf      | Dotted Half       | Tempo * 6         |
| whl      | Whole Note        | Tempo * 8         |
+----------+-------------------+-------------------+
```

- Tempo is defined in the Song's Registry. 
    - See [Song Registry](#song-registry)

- Example: `Notes 8th,C4` will play Middle C for the length of an Eighth Note.

**Custom Note Lengths:**
- Two-Byte Note Instructions specify the raw number of frames to play a note for.
- Examples: 
    - `Notes 5, C4` will play Middle C for five frames.
    - `Notes _8th*16,rest` will play a double-whole note rest.

- The `_8th` variable is normally defined to equal the Tempo.
    - See [_8th Variable](#_8th-variable) for details on defining the _8th variable.

- Custom Note Lengths have a range of 1..256 frames. (Notes 0,<Pitch> plays for 256 frames.) 
  - To play a Note that lasts longer than 256 frames, use `.byte Tie_Next_Note`
    - [Legato](#legato-tied-notes) for details.

- **WARNING:** Riffs that reread another song's data do **not** adjust custom note lengths to account for differences in tempo.
- This also means a Song cannot be defined to play at multiple different speeds.

### Pitch Naming
- The engine provides named pitch aliases for A0 to B5. (For reference, a grand piano is A0 to C8)
  - Pitch names consist of the note letter (A–G) followed by the octave number, such as `C3` or `A4`.
  - Sharps and flats are written using `s` and `b`, respectively. ie, F♯ is `Fs` and B♭ is `Bb`

  - Lower octave numbers are lower pitches.
    - For the Triangle/DMC Channels, C4 is middle C. 
    - For Pulse Channels, its C3
    - See the warning below for details.

- To play a rest, define the Pitch as `rest`.
  - It must be lowercase.


**Pitch Limitations:**
- At any one time, the engine can only play one of 15 consequtive semitones.
- The lowest of these pitches is the Base Pitch, as defined in the `Header`.
  - Example: `Header C3, <Env>`, can play `C3` to `D4` inclusive.
  - To change this window mid-song, See [Shift_Pitch Instruction](#shift_pitch)



- **WARNING:**  Pitch names can be confusing when using a DAW other than FamiStudio for reference.
- To clarify, the convention used matches FamiStudio's note-naming conventions. (The lowest pulse pitches display as `A0`)

- The Triangle and DMC channels use standard A4 = 440Hz tuning.

- The Pulse channels play notes one octave higher than written.
- For example, `A0` (27.5 Hz) is the lowest possible Triangle pitch, but the Pulse channels play `A1` (55 Hz) when instructed to play `A0`.
    - The reason for this is, `A0` really means play the lowest pitch the **hardware** supports, which is different for the different channels.



*Methods to support alternative DAWs coming in a future update.*


### Base Pitch Tracking



- The hidden, ca65 assembly-time variable `BP` tracks the **expected** runtime Base Pitch.
- This variable is automatically updated after 
    - `Header`
    - `Shift_Pitch` 
    - `Set_Pitch` 


Manual updates to the ca65 assembly-time variable `BP` may be required to keep it synchronized with the engine's runtime state.
- Example: `BP .set BP-12` or `BP .set F3`





The most common case where the ca65 var does not update is when `Riff` or `Repeat` re-reads a `Shift_Pitch` or `Set_Pitch` instruction.

Example:
```
_1:
    Notes whl,C4
    Shift_Pitch +2

_2:

Repeat _1, 3
BP .set BP + (2*3) 

...

Riff _1, _2
BP .set BP +2
```
- After `Repeat`, the Base Pitch is a total of 8 semitones higher.
    - The `Shift_Pitch +2` is executed once, then `Repeat _1, 3` executes it 3 additional times.

- The ca65 `BP` var is automically only 2 semitones higher. (When the `Shift_Pitch +2` is executed the first time.)
- `BP .set BP + (2*3)` immediately following `Repeat _1, 3` keeps `BP` in sync with the run-time Base Pitch.

- After `Riff _1, _2` the Base Pitch is further increased by 2 semitones.
- `BP .set BP +2` immediately following the Riff again keeps `BP` in sync with the run-time Base Pitch.








## Engine State

### `Shift_Pitch` and `Set_Pitch` Instructions

- These instructions modify the Base Pitch, which defines the lowest note in the 15-pitch window currently available to the channel.

#### Shift_Pitch

* One-byte instruction that shifts the current Base Pitch by a relative amount.

**Usage:** 
- `Shift_Pitch <Old_Pitch>, <New_Pitch>` 
- `Shift_Pitch <Raw_Delta>`

**Range:** `+12`, `-12`, and `-7` through `+7` semitones. (12 semitones is one octave.)
- Example: `Shift_Pitch C3, G3` is equivalent to `Shift_Pitch +7`

- Use the Old/New format where possible.
    - The Old Pitch does not need to match the current Base Pitch.
    - Use whichever pitch names are most meaningful. The delta between them is calculated automatically.

- Recommended use cases for Raw Delta format:
    - Full octave shifts.  
        - Recommended Syntax:
        - `Shift_Pitch -Octave`
        - `Shift_Pitch +Octave` 

    - Very brief shifts back and forth. (The exact Base Pitch needs to be unimportant.)
        - Example:
        ```asm
        ; BP = C3

        Shift_Pitch +7
        Notes G4,8th
        Shift_Pitch -7

        ```
        - `G4` is not in range of `BP = C3`. 
        - If the BP should stay C3 both before and after, the brief shift enables playing a much higher note.

    - Advanced combinations with the Compression Instructions.
        - See [Advanced Data Compression](#advanced-compression-techniques) for Examples.

- **WARNING:** There is no bounds checks on the Base Pitch or a played notes pitch.
    - Pitches above `B5` mostly work.
        - The tuning is bad, simply due to lower period resolution at high pitches.

    - Pitches below `A0` underflow to the highest possible period.
        - This also takes an unusually large amount of CPU time to calculate the underflowed period.

- The DMC Tri-Pulse waves and Noise Channel behave slightly differently.
    - Garbage data for the Note's pitch and duty cycle, or Noise SFX are read.



**Vibrato Depth:**
* Shifting by an octave also changes Vibrato Depth. This helps compensate for the greater perceived depth to vibrato at higher pitches.

  * For example, start at the unspecified, or `Standard` Vibrato Depth.

    * `Shift_Pitch -Octave` would increase depth to `Vib_Deep`
    * `Shift_Pitch +Octave` would decrease depth to `Vib_Shallow`


- **WARNING:** Vibrato Depth incriment/decriment bounds checks are somewhat unintituive.
- `Shift_Pitch -Octave` while at `Vib_Deep` has no effect on the Vibrato Depth. 
    - This is bounds checked.
    - The Base Pitch is modified, as before.

- `Shift_Pitch +Octave` while at `Vib_Very_Shallow` increases a counter to beyond the intended range.
    - Vibrato continues getting shallower until the minimum vibrato of 0 and -1.
        - The default Vibrato Cycles are already at the minimum with `Vib_Very_Shallow`

    - Further `Shift_Pitch +Octave` shifts will not change the vibrato, but then a `Shift_Pitch -Octave` also will not change the vibrato until the counter decreases back to the intended range.

    - The engine will take more and more CPU time to calculate the minimum period.
        - If the Vibrato Cycle is set to `No_Vib` this is not a problem
        - Likewise for the dmc Channel.

    - If 128 `Shift_Pitch +Octave` instructions are executed, undefined behavior occurs.
        - Unrelated code is executed, potentially crashing the NES.
        - Though given the Base Pitch will have overflowed 6 times by then, theres already been a problem.

**Noise Channel Differences:**
* Since pitches are mapped to SFX, use the Noise Bank variable instead of `A0..C6`
    - The raw delta format is impractical for Noise. Only use `Shift_Pitch <Old>, <New>`

**NOTE:** `Shift_Pitch +/-Octave` should not be used for the Noise Channel.
- See [Bad Ideas](#bad-ideas) for details.

#### Set_Pitch
* Two-byte instruction that sets the Base Pitch and Vibrato Depth directly.

**Usage:** `Set_Pitch <Pitch>, [<Vibrato_Depth>]`
- This is the exact same format as the Header.

- `<BP>` is the Base Pitch, the lowest of the 15 playable semi-tones
    - ie, if `BP = A0` then `A0` to `B1` are playable.
**Pitch range:** `A0..C6`

- `<Vibrato_Depth>` is the depth factor applied to Vibrato.
**Vibrato Depth Constants:** `Vib_Deep`, unspecified, `Vib_Shallow`, or `Vib_Very_Shallow`.

  * If unspecified, defaults to a standard, or medium depth. Leaving it unspecified is recommended for this setting.
    - **WARNING:** `Vib_Med` specifies Vibrato Speed, and is undefined behavior here.

**NOTE:** The perceived depth of vibrato depends on the playing pitch. 
- Higher pitches have deeper perceived vibrato, so a shallower Vibrato Depth setting may be needed to compensate.


**Noise Channel Differences:**
* Since pitches are mapped to SFX, use the Noise Bank variable instead of `A0..C6`
* The Vibrato Depth paramater is replaced with `Kick Type`

* See [Noise Bank](#noise-bank) for details.




### `Env_Change` and `Set_Env` Instructions
- These instructions modify the current Envelope used by notes.

#### Env_Change

- One-Byte instruction to set the Envelope Index within the current `Env_Bank`.

**Usage:** `Env_Change <New_Env_Name>

#### Set_Env_Bank
- Two-Byte instruction to set both the Envelope Bank, and Index.

**Usage:** `Set_Env <Set_Env_Bank>

- **WARNING:** Using this instruction disables error checking for out of bank swaps for that Channel.




### Miscelanious Effects

- **WARNING:** Executing any custom Volume Instructions disables reseting many special effects between notes.
- Use `.byte Clear_Special_Effects` to manually clear the effects.

#### `Volume` Instruction
- Custom Volume instructions are two-byte instructions. They modify the channel's Volume Factor, and can queue Fade-In and Fade-Out effects.

**NOTE:** `Volume` instructions set a flag that disable reseting some other one-time effects between notes. 
    - See [Clear Special Effects](#clear-special-effects) for Details.

- The Volume Factor is multiplied by the Envelope's raw output volume, then truncated to an integer.
- The available Volume Factors are 100% (Full) down to 12.5% (12.5% of Full) in incriments of 12.5%.
- The constants are: `Vol_100, Vol_87, Vol_75, Vol_62, Vol_50, Vol_37, Vol_25, Vol_12`

- The APU's coarse volume resolution results in many different input values converging to the same output amplitude.
  - `Vol_87` (87.5% of Full) guareentees a quieter amplitude than `Vol_100` (Full).
  - `Vol_12` (12.5% of Full) silences the channel unless the Envelope's raw output volume is 8.0 or higher.

    
**Usage:**
`Vol_Fade_Out <Initial>, <Target>, <Speed>`
`Vol_Fade_In  <Initial>, <Target>, <Speed>`
`Set_Volume   <Initial>`

- `Vol_Fade_In` and `Vol_Fade_Out` immediately set the Volume Factor to `<Initial>`, then adjust it toward `<Target>` every <Speed> frames until the target is reached.
  - Specifically, every `<Speed>` frames, the next/previous Volume incriment is used until Target is reached.
  - Example: `Vol_Fade_Out  <Vol_87>, <Vol_62>, 5`
    - The Volume Factor is set to 87.5% immediately, and used for 5 frames.
    - Then changes to 75%, again used for 5 frames.
    - Then it reaches 62.5%, and remains there until another Volume instruction is executed.

- `Vol_Fade_Out` and `Vol_Fade_In` validate that the Volume Factor changes in the intended direction.
- `Set_Volume` simply sets the Volume Factor for until another Volume instruction is executed. No fade is initiated.

**NOTE:** `Set_Volume Vol_100` is not valid syntax. 
- Use `.byte Clear_Special_Effects` instead. 


**One-Byte Common Fade Out**
`.byte Common_Fade_Out` is equivalent to `Vol_Fade_Out Vol_100, Vol_12, 13`
- Differences:
    - It's a one-byte, vs two-byte isntruction
    - Once a new note is started, the Volume is reset to 100%

- **WARNING:** If custom Volume instructions have been executed, `.byte Common_Fade_Out` will **not** reset the volume to 100%, just like other Volume instructions. 
- This includes `Vol_Fade_In <Initial>, Vol_100, <Speed>`.

- Use `.byte Clear_Special_Effects` to manually reset Volume to 100% when needed.



**Advanced Envelope Design:**
- Due to quarter-fixed-point Volume precision, the slowest an envelope can ramp down its volume is one step every 4 frames.
- Combining `Set_Volume` with custom designed Envelopes can overcome this restriction.

- `Vol_50` is likely the most usable. It halves max volume from 15 to 7, but doubles an Envelope's ramp precision to eighth-fixed-point.



**Triangle and DMC with Volume Instructions:** 
- The Triangle Channel can in principle use Volume instructions to turn sustained Envelopes into percussive ones of varying length.
    - Doing so is not intuitive, and not recommended.

- The DMC with Tri-Pulse wave could have the same effect.
*DMC Volume Instructions are not currently supported, and there are no plans to add support.*



#### Pitch Sweep

- A two-byte instruction that applies a continuous pitch sweep to the next Note, either upward or downward.

**Usage:**
`.byte Init_Sweep <Rate>`

- The Sweep Rate is added to the Note's Period every frame.
**Range:**
- Downward Pitch Sweep: (1 .. 127)
- Upward Pitch Sweep: (-1 .. -128)
- `Period = 1 / Pitch`. A increase to Period is a decrease to Pitch.
    - The period added is constant, so the pitch sweep is non-linear.
    - Higher pitches produce faster perceived pitch sweeps for the same Sweep Rate.
*Tools to calculate the Sweep Rate are planned for a future update.*


**NOTE:** DMC and Noise Channels ignore Pitch Sweeps.

- **WARNING:** The Period is not bounds-checked. If it over/underflows, the pitch wraps around to the opposite end of the range.

- **WARNING:** If custom Volume instructions have been executed, the Pitch Sweep will **not** reset between notes.
- Use `.byte Clear_Special_Effects` to manually clear the persistent effect.


- A dummy Volume instruction can be used if multiple consequtive notes need to sweep.
  - This can be used for the Triangle Channel for percussion.

#### Legato (Tied Notes)

- This misc effect disables the next notes Cutoff and the following note does not reset its Envelope.
- The effect is the pitch changing without any interupts or resets.

**Usage:**
```asm
.byte Tie_Next_Note
Notes <Length>, <Pitch> ;Cutoff disabled
Notes <Length>, <Pitch> ;Envelope reset disabled
```
- The effect flags are persistent state and carry over through `Repeat` and `Riff` instructions
- A single note can have both its Envelope Reset and Cutoff disabled with two `Tie_Next_Note` instructuions.

**NOTE:**
- `Notes <length>,rest` will still silence the channel after `.byte Tie_Next_Note`, and future tied notes will remain silenced.


##### Very Long Custom Note Lengths
- Using `.byte Tie_Next_Note`, a single, uninterrupted note can exceed the normal 256-frame limit.

- For reference, One Beat is 1 * Tempo, usually an Eighth Note.

The following durations are possible using the specified amount of Song Data:
**3 bytes:** Up to 64 beats (~15 seconds), using `whl`, `dhf`, etc with `Repeat "2b", <1..7>`
**4 bytes:** Up to 2,048 frames (~30 seconds), using Custom Note Length with `Repeat "3b", <1..7>`
**5 bytes:** Up to 32,768 frames (~10 minutes), using Custom Note Length with `Repeat "3b", <8..128>`

**Example:** A 32-beat note (four measures).
```asm
_label:
    .byte Tie_Next_Note
    Notes whl,<Pitch>

Repeat _label, 3
```
- Total note length = (`<Repeat_Count>` + 1) * `<Note_Length>`

**Side Effect:** The tie also carries over to the note following the Repeat, disabling that note's Envelope Reset.
this is also ties into whatever Note comes after the Repeat. 
  - Fixing requires an extra byte.
  - Example:
    ```asm
        _label:
            .byte Tie_Next_Note
            Notes whl,<Pitch>

        Repeat _label, 2
        Notes whl,<Pitch>
    ```
    - Now the "Next Note" is just an explicit copy of the repeatly tied note.


**Very Long Rests**
- Long rests are simpler to encode and do not require `.byte Tie_Next_Note`, since the channel is silent anyway.

 - Because `Repeat "1b", <1..7>` is not a One-Byte instruction, the ranges are:
**3 bytes:** Up to 2,048 frames (~30 seconds), Custom Note Length with `Repeat "2b", <1..7>`
**4 bytes:** Up to 32,768 frames (~10 minutes), Custom Note Length with `Repeat "2b", <8..128>`

- Example of a 32-Beat (Four Measure) rest:
```asm
Notes 16*_8th,rest
Repeat "2b",1

```
- Total rest length = (`<Repeat_Count>` + 1) * `<Note_Length>`


#### Incriment Page
- Manually advances the Song Data Pointer to the next ROM page and sets its 8-bit index.

- See [Page Confinement](#page-confinement) for context.

**Syntax:**
`Inc_Page <Target_Label>, <tmp_ca65_BP_copy>`

- Target Label is verified the be in the page after this Macro. (ie, If `Inc_Page` is at `$80ff`, `<Target_Label>` can be at `$8100` to `$81ff`)
  - During execution, it jumps to the provided label, like a `Riff`

- `tmp_ca65_BP_copy` makes a temporary backup of the ca65 assembly-time variable `BP`. It is restored in the next section's Header.


**Usage:**
- This instruction **modifies the scaffolding**. Take extra care to follow the syntax closely.

``` 
Channel Fanfare_Sq0, FF_Sq0  
    Header <BP>, <Env>

    ... <Notes>

Inc_Page Fanfare_Sq0_Cont, FF_Sq0_BP


... <Unrelated Data>


Channel Fanfare_Sq0_Cont
    Header FF_Sq0::FF_Sq0_BP, <Env>, "Cont"

... <Notes>

Loop Fanfare_Sq0_Cont
```



- The `Inc_Page` macro closes a Channel's scope, just like `Loop` does.
    - Thus, a new `Channel` macro is needed to open a new scope for the continuation.

- `"Cont"` in the Header just restores internal ca65 variables. it does not emit data.
  - `BP` is restored from the alias defined in the `Inc_Page` macro.
  - The continuation must reference that alias using the original channel's global identifier. (`FF_Sq0::` in the example.)
  - For simplicity, the Header could instead just be 
    `Header <BP>, <Env>, "Cont"`
    `   Set_Pitch <BP>`
    to manually set the BP and not worry about the complex syntax. 

- `Loop` Error checks that the provided label is in the same page as itself.
  - After an `Inc_Page` it should **not** reference the label defined in the first Channel.



#### Clear Special Effects
- Executing any custom Volume Instructions disables reseting many special effects between notes.
- This instructions re-enables reseting those special effects, and resets them immediately.

**Usage:** `.byte Clear_Special_Effects`

- The one-time effects that are not reset, that this instruction affects are:
    - `Volume`
    - `Init_Sweep`


*This instruction could in principle re-enanbled a queued `Tie_Next_Notes`'s disabled Envelope reset. There is not plan for thi sin future updates.*


## Basic Compression Techniques

- Each of the Compression Instructions address different kinds of redundancy in music data. 

- Understanding how they compliment eachother along with the Engine State instructions is what allows songs to be compressed so much.

- The `If_Alt` Instruction is listed under Advanced Compression Techniques.

### `Riff` Instruction
- Two-Byte Instruction that re-reads a segment of Song Data.


- Instead of storing the same data twice, store it once, then store a pointer to the original.
    - Riffs can re-read any amount of data in the same page.
        - This includes data for a different Channel, or even a different Song.

    - Segments as small as 3-bytes save data when Riff'ed. 
        - Riffs are a two-byte isntruction.
        - Returning has no overhead 

    - Different Riffs can re-read partially overlapping data with few restrictions.

    - Riffs can recursively call other Riffs.
        - The maximum Riff Depth is 8 layers deep, far more than is needed.
  

**Usage:** `Riff <Jump_Label>, <Return_Label>`
- Music Data Execution continues at `<Jump_Label>`
- Once Exection reaches `<Return_Label>`, it automatically returns to the instruction immediately after the Riff.
    - See [Label Format](#timestamped-labels) for the recommended label name convention.
    - Indenting the re-read data is not required, but helps readability.

- If a Riff re-reads 32 to 255 bytes, instead use `Riff <Jump_Label>, <Return_Label>, "3b"`
    - this becomes a Three-Byte instruction.
    -The exact "3b" text is unimportant. Any text sets sets the flags.
        - "3b" just clearly announces this as a Three-Byte Riff.

- Both formats validate the required instruction size. 
- If the wrong format is used, an error prompts the user to use the other format.
    - Silent updates would break the simple syntax for Repeated Riffs. 
        - See [Repeated Riffs](#repeated-riffs)

- **WARNINGS:** 
- While a Riff re-reads the exact same data, it does **not** automatically give the same output.
    - The biggest change is the Base Pitch. To play the same notes, a Riff needs to re-read the data with the same Base Pitch the original data had.

    - Deliberatly having a differnt Base Pitch can be useful, but is more complicated. 
        - See [Transposed Riffs](#transposed-riffs)


- No two-byte instructions can be split by a Riff.
    - All bytes of each instruction are processed before checking if a Riff should return.

- Infinite recursions cause undefined behavior.
    - ie, Riff A calls Riff B, and Riff B calls Riff A
    - Memory outside the Riff Stack's allocation is corrupted.

#### Limitations

##### Minor Differences

- Take the seqence AB,C, AB,D

- C and D could each be just a single Note, where all of AB can be de-duplicated.




##### Highly overlapping reads (Complicated):

- Two different Riffs can read partially overlaping data perfectly.
    - If a third Riff wants to read a different set of overlapping data, it can't always find it all in one continuous segment.

- Take the seqence ABC,ABD,BC,BD
- In isolation, AB, BC, and BD all appear twice and can be Riff'ed:
- But because B is shared in all three pairs, it is not possible to optimally Riff everything.

Example:
```
_1:
    _AB:
    _A:

    _BC:
    _B:

    _C:

_2:
Riff _AB, _C ;A + B

    _D:


_3:
Riff _BC, _2 ;B + C

_4:
Riff _BD, _3  ;B + D
```
Would be optimal, but the label `_BD` cannot exist. (It would start in the middle of  `Riff _AB, _C`)
- `Riff _BD, _3`'s data is now scattered in two different locations.
- This requires two seperate Riffs `Riff _B, _C` and `Riff _D, _3` to call both halves.

- By shuffling around where the original data, `Riff _BD, _3` can become valid, but something else becomes invalid.
- The problem is, of `Riff _AB, _C`, `Riff _BC, _2`, and  `Riff _BD, _3`, `_B` is overshared, and can't be found next to all the data that wants to be re-used.



#### Behavior Clarifcations
- Riff/Return behaves just like function calls and returns in coding.

- In a nested call structure, the innermost Riff returns first, following last-in, first-out order.
- Multiple Riffs can return before processing the next instruction.
- A Riff can immediately call another Riff.

- The **only** state modified by Riff is where to execute the next instruction.
    - The Base Pitch, Envelope, and Effects remain what they are when Calling and Returning.
    - The BP in particular can be a major issue if it changes inside a Riff.

    - See [Base Pitch Tracking](#base-pitch-tracking) for Details.

- The `Loop` Instruction clears the Riff Stack, starting from a blank slate.

#### Raw Byte-Count Format:
- The purpose of this format is to reduce source-code clutter by removing labels.

- However, the labels automatically calculate addresses, mark locations of interest, and organize the timestamps of the song as a whole, so deleting them often does more harm than good.

- It is **highly** recommended to use this format only if **all** of these conditions are met.

- 1) No other Riffs use the same Return_Label.
    - the label can be deleted after changing syntaxes

- 2) The label density in the area is high.
    - deleting the label significantly improves readability.
    - this mostly matters when the labels are complicated.

- 3) Optimization of the Riff'ed area is complete. 
    - The re-read data **must** not change.
    - If the bytes to re-read changes, the instruction breaks spectacularly.

- 4) This Riff is very short. 
    - Computing and understanding what is re-read is easy.
    - Only 3, maybe 4 bytes should be re-read.

- 5) The Riff'ed data is nearby.
    -Seeing what the 3 re-read bytes are should not require scrolling.

**Usage:**
 `Riff <Jump_Label>, <Raw_Number_of_Bytes_to_re-read>`

 Example:

```asm
 _5: ;Timestamp for measure 5
    Env_Change <Name>
    Set_Pitch <BP>

...<Notes>

Riff _5, 3

...<Notes>
```
- This Riff only re-reads a new Envelope and Base Pitch.
- The return_label would be an inconvient name. (The timestamp would be identical.)




### `Repeat` Instruction
- A One-Byte Instruction 

- Executes the previous few bytes of Song Data the specified number of times.

**Usage:** `Repeat <Jump_Label>, <Count>`

- Music Data Execution continues at `<Jump_Label>`
- Each time execution falls back down to the `Repeat` instruction, it jumps back to `<Jump_Label>` until it has jumped back a total of `<Count>` times. 
- Execution then continues past the `Repeat`.

**Range:**
- Up to Five bytes of data can be Repeated.
    - If more than Five Bytes need to be Repeated, use a Repeated Riff. 
    - See [Repeated Riffs](#repeated-riffs)

- If `<Count>` is 8 or more, the `Repeat` becomes a two-byte isntruction. 
    - The maximum number of repeated bytes is also decreased from Five to Four.


Example:
```asm
_1:
    Notes 8th,rest, 8th,A3

Repeat _1, 2
```
Unrolled, the execution is:
```asm
Notes 8th,rest, 8th,A3 ;Original

Notes 8th,rest, 8th,A3 ;Repeat 1
Notes 8th,rest, 8th,A3 ;Repeat 2
```

- **WARNING:** 
- Only a single Repeat instruction can be in use at one time.
    - If a second Repeat instruction is encountered before the first one completes, the Repeat Count becomes corrupted, leading to an infinite loop.

    - This is mostly a problem when Repeating a Riff.
        - A lot more instructions can be Repeated, and they can be spread out in multiple different places.

        -See [Repeated Riffs](#repeated-riffs) for Details.

#### Behavior Clarifcation

- All bytes between the Repeat instruction and the `<Jump_Label>` are executed every time.

- The original execution is not included in `<Count>`. A count of 1 executes the data twice in total.
    - For a total desired execution of N times, `<Count>` is N-1

    - The `Repeat` instruction itself is executed `<Count> + 1` Times.
        - It jumps back `<Count>` times, then executes once more before moving on.

        - When `Repeat` executes that final time without jumping back, the Engine State is reset to allow others `Repeat` instructions to work.


- Repeating a Single byte is always a Two-Byte instruction.
    - That one byte needs to be executed 4 for more times, or the `Repeat` is pointless.
- Repeating Five bytes can only be done 1..7 times.

    - The reason for those restrictions is this:
        - Only Two to Five bytes are actually repeated.
        - With a Large Repeat Count, that second byte is treated as one of the Two to Five bytes repeated. (The syntax does **not** count that byte, however.)





#### Raw Byte-Size Format:
- The purpose of this format is to reduce source-code clutter by removing labels.

**Usage:** `Repeat <Size>, <Count>`
- Size must be one of: `"1b", "2b", "3b", "4b", "5b"` including the quotation marks.
    - The qutoes differenate `<Size>` from `<Count>`. Otherwise, both would be just numbers.


- It is recommended to use the Raw Byte-Size Format only when the repeated data is on a single line, such as a Riff, Duration, or Notes instruction.
 - Otherwise, the label makes it explicit where execution jumps back to.
 - Multiline Repeats often involve an Advanced Technique, where clarity matters more than brevity.

Example:
```asm
Riff <_Start>, <_End>
Repeat "2b", <Count>
```
- Repeating Riffs is the most common use of the Repeat instruction.
    - If it's a 3-Byte Riff, "3b" is also an explicit parameter of the Riff.


### `Duration` Instruction
- Compresses Song Data to two notes per byte by specifying only the pitch and reading the length from a small look-up-table.

- Also reduces typing by omitting redundant note lengths.

**Usage:** `Duration <Duration_Set_Alias>, <Pitch>, <Pitch>, ...`

**Example:**
`Duration _0000, G4,C5,G4,C5`

- `_0000` is shorthand for four 16th notes.
**NOTE:** 16th notes can only be played efficently in a Duration.
    - 16th Notes generally must come in pairs. See Limitations of Duration Sets for details.

    - See [Duration Sets](#duration-set-definitions) for details on making custom sets and the alias format.


- **WARNING:** `Duration` cannot validate whether the correct number of pitches were supplied for the given Duration Set.
- Supplying the incorrect number results in undefined behavior.

**NOTE:** Once a Duration begins executing, there is no way to stop it early.

#### Multi-line Duration Syntax
- Long Durations can be impractical to fit on one line, especially on the Noise channel.

- Replace `Duration <Duration_Set_Alias>, ...` with `Duration "Cont", ...`, including the quotation marks, to continue a single Duration Set on another line.
- `"Cont"` omits the Duration Set ID.

**Example:**
```asm
Duration _8x1,   Shaker_Kick, Shaker_2, Hat_2,   Hat_2
Duration "Cont", Shaker_Kick, rest,     Snare_6, Hat_2
```
- Where `_8x1` is shorthand for eight 8th Notes.


#### Non-Note Duration Syntax
- In principle, any instructions can be executed through a Duration.
- In practice, `Notes` are used very nearly exclusively. 

- Occasionally, `Shift_Pitch`, `Env_Change`, and some Misc Effects are used.
    - See [Bad Ideas](#bad-ideas) for details on the other instructions.
    - In short, most other instructions would only fuction as the second nibble read in a byte, and have extremely obtuse syntax.

*The following syntax is difficult to write.*
- *For `Shift_Pitch` and `Env_Change`, clearer syntax is planned for a future release.*

To use Non-Notes in a Duration, the **raw hexadecimal values** needs to be supplied.
- See [Reading Raw Byte-Code](#reading-raw-byte-code) for details.

Specifically, both the instruction Operand **and** Opcode must be supplied.
- The Operand is stored directly
- The Opcode is used to confirm this is a non-Note.
- **WARNING:** These raw hex values are **not** validated.


##### Duration with Shift_Pitch:
- `Shift_Pitch` is the best place-holder when an odd-number of pitches are needed in a Duration Set.
    - `$b0` is the No-Operation instruction.
    - Shifts -7 .. +7 can be done with no additional cost.
        - Though the internal va65 variable `BP` needs to be manually edited. 
            - See [Tracking Base Pitch](#base-pitch-tracking)
        - If a Shift is in the middle of a Duration, the multi-line `"Cont"` syntax must be used.
        - That way, the `BP .set BP+<Delta>` line can update `BP` so future Notes are computed correctly.

        - Example:
        ```asm
        Duration _01b0, C3,D4,
        BP .set BP-1
        Duration "Cont" $bf,B2`
        ```

        - Where `$b-` is the Opcode for `Shift_Pitch` and `$-f` is -1
        - The primary purpose here is to ensure the two 16th notes function as intended.
            - See [16th Notes Limitations](#limitations-of-16th-notes)

**NOTE:** `Shift_Pitch +/-Octave` instructions do function correctly in Duration Sets, but are **not** interchangable with `Shift_Pitch -7..+7`
- See [Misc_Effects](#duration-with-misc-effects) for details.


##### Duration with Change_Env
- `Change_Env` can be helpful in seqences where the Envelope rapidly changes back and forth.
    - Otherwise Duration Sets are too inflexible to be generally useful for `Change_Env`.

- **WARNING:** The way Envelope IDs are calculated, their aliases are **not** usable in Duration instructions.
- Example: `Duration _<Set_Alias>, $e0 | <Used_Raw_Index>, ...`  
- Then somewhere nearby: `.assert (<Env_Alias> & $0f) = <Used_Raw_Index>, .error, "Invalid Manual Env_Change"`  
    - Where `<Used_Raw_Index>` is the 0..15 index of the Envelope within in Bank.
    - `$e-` is the Opcode for Envelope change.


- Trying to use `Change_Env` as a No-Operation is hard.
    - It will **set** the Env to whatever its provided with
    - Only if that always matches the current envelope does it behave like a NOP


##### Duration with Misc Effects:
- The one-byte Misc Effects can all be used interchangablly.

- They listed roughly in order of usability.
    - All of these are normally written with `.byte <Operation>` anyway, so the "raw hex values" are just the Operation aliases. 



`Tie_Next_Note`

`Clear_Special_Effects`
- The closest No-Operation of the Misc Effects.
    - Only `Volume` Instructions set the flag.
    - Only `Volume` and `Init_Sweep` instructions are affected.

`Plus_Octave`
- Misc Effect alias for `Shift_Pitch +Octave`

`Minus_Octave`
- Misc Effect alias for `Shift_Pitch -Octave`

`Common_Fade_Out` 

- Example: `Duration <Set_Alias>, Tie_Next_Note, C3, E3, ...`


- The two-byte Misc Effects are all distincly LINK Bad Ideas



### Repeated Riffs



## Advanced Compression Techniques
- Most of these involve combining instructions, usually by abusing their quirks.


### `If_Alt` Instruction
- Let's just say there's a reason this entire opcode is relegated to Advanced Compression.

**Term Definitions:**
- Primary: The channel reading these instructions with If_Alt disabled.  (Usually, this is the channel the data is written under.)
- Secondary: The channel reading these instructions with If_Alt enabled. (Usually, this is the channel Riffing another channel's data.)


**Syntax:** 
- `If_Alt "Toggle"`
  - Swaps whether a channel ignores future If_Alt instructions.
  - This instruction always executes, regardless of whether the Channel is currently ignoring If_Alt commands.

- `If_Alt <Primary>, <Secondary>`
- Primary should match the pitch, or other data supply by the next isntruction.
- The Secondary is the alternate data to override the next instruction with. (If Enabled.)

- **WARNING:** The Primary is not validated in any way. Error checking on the Secondary is also limited. (For example, it will not check if an Envelope is outside the current Bank.)
- A mismatched Primary pitch will corrupt the Secondary Channel's pitch.

- Example:
`If_Alt C2, Cs2`
`Notes 8th,C2`
- A channel with If_Alt disabled plays C2, as usual.
- A channel with If_Alt enabled instead plays the pitch a semitone higher than it otherwise would. 
  - The actual ptich the secondary channel plays depends on the secondary's Base Pitch, but the pitch has to be written relative to the **primary channel's BP**
  - See [Transposed Riffs](#transposed-riffs) for context on using the secondary's Base Pitch.


**Usage:**
- It is **highly** recommended to follow this workflow.

- 1) Write the entire Primary Channel's data with no `If_Alt` instructions, and optimize it alone. (Exception. use `Set_Pitch` instead of `Shift_Pitch`. Everywhere. Optimize that last.)
  - Personally, I still use all `Duration` instructions for text compactness and organization, even though most need to be uncompressed later.

- 2) In Famistudio, duplicate the song. (So destructive edits aren't accidentally saved. Learned this one the hard way.) 

- 3) In the Secondary Channel, shift up/down its pitch until its Notes overlap with the Primary Channel's as much as possible.
    - Click the little eye by the channel's name to the left. It toggles visibility of that channel while view other channels.

- 4) Use the Header or a `Set_Pitch` instruction, specifically, to set the relative Base Pitch of the Secondary Channel before its Riff.
  - Example. If Primary's BP = E3, and Secondary is 4 semitones lower, use `Set_Pitch C3` or `Set_Pitch E3-4`, whichever is clearer.

- 5) Insert the `If_Alt <Primary>, <Secondary>` lines with the Secondary pitch what Famistudio says the secondary's new **altered** pitch is.
  - If If_Alt'ed `Shift_Pitch` instructions are used, shift and write one section at a time. (That, or save yourself the headache and just don't.)

- 6) Once **both channels** are complete, optimize the `Set_Pitch` instuctions to `Shift_Pitch` instructions where possible.
    -Breaking an If_Alt because a Shift_Pitch was tweaked is especially obnoxious to debug.




- **WARNING:** `Loop` Instructions reset Toggled If_Alt Channels.
  - `If_Alt "Toggle"` is one of many instructions that are **NOT** consistant with Intros. 
  - This one in particular is annoying to keep consistant, given how slow it is to debug.   
    - See [intro-phrases](#intro-phrases) for Details.)

- Intro Example:
```asm
Channel <Song_Name>
    Header <BP>, <Env>

    If_Alt "Toggle"

    ...
    Notes
    ...

    If_Alt "Toggle"

    End_Intro:

    If_Alt "Toggle"

```
- Toggling twice in the Intro ensures the channel is in the same state both pre-Loop and post-Loop, with the third setting the post-Intro state.


- **WARNING:** Do not, I repeat, **DO NOT** attempt to have a Riff split the If_Alt and the intruction it modifies.
- The results are unintuitive, and because two different channels are simultaniously reading the same data, this is extremely difficult to debug.

- The two channels can desync from eachother.
    - The channel that ignores the If_Alts will immediately return from its Riff, as expected.
    - The other channel treats the If_Alt and following instruction as a single instruction, and will **not** return until after the following instruction completes.

### Defining 16th Note length as the Tempo
- The only reason I'm putting this in Advanced is it clashes with the names of Note Lengths.

Syntax is trivial. `Song <Name>, <Tempo>`
- Just define Tempo to be the 16th length, not 8th length.

Because of the restrictions on cheap 16th notes, and lack of cheap dotted-eighths, changing those to `8th` and `dqt` respectively can save a lot of data. 
- This comes at the cost of cheap whole-notes, and entirely breaks several Duration Sets.

- The main problem is, the 8th Length has to be even. Otherwise, the rounded Tempo is significantly different. 

### Transposed Riffs
- Since a Riff can read the same Notes, yet still play different pitches, this can be done deliberately.

- As this is is abusing the Base Pitch. It is reccomended to use explicit `Set_Pitch` instructions at first. During a final optimization phase, engineer the desired BP with `Shift_Pitch` instructions, where needed.
    - See [Base Pitch Tracking](#base-pitch-tracking) for context.

**Example**
```asm

Set_Pitch C4
_1:

    <Notes>

_2:

Set_Pitch C3
Riff _1, _2

Set_Ptich Cs3
Riff _1, _2

```
- The Riff now re-plays the pitches an octave lower than originally written, then a key-change re-reads it one-semitone higher.

- This can be done with any combination of unique Base Pitches, Envelopes, and Misc Effects. 



### Riffs ending mid-Duration
- Normally, Riffs cannot return after reading only some of an instructions bytes.

- Duration is the only exception, and then Duration itself is really only a one byte instruction.
    - Duration simply changes the data format of the next few bytes.

- A Riff can return in the middle of this temporary new format. 

### Riffed Loop Labels
- The `Loop <Song_Name>` line of the scaffolding emits data that can be Riff'ed, just like all data.

- As this is a modification to the scaffolding, extra care must be taken.


- Example:
```asm

Channel Fanfare_Sq0, FF_Sq0
    Header <BP>, <Env>

    _1:

    <Notes>

Loop Fanfare_Sq0
FF_Sq0_Loop:


Channel Fanfare_Sq1
    Header <BP>, <Env>

    Riff FF_Sq0::_1, FF_Sq0_Loop

Loop Fanfare_Sq1, "Riffed"
```

- Here, Sq1 re-uses all of Sq0's data, including the `Loop` command.
    - The `Loop Fanfare_Sq0, "Riffed"` validates page confinent, exits the Channel sandbox, but does not emit any data.

- The `FF_Sq0_Loop:` label, despite being global scope, does not require the `::<Label>` syntax. 

**Alternative Syntax**
- This is arguably messier, but the following keeps all labels inside a Channel's sandbox.

```asm
    ...

    _Loop:
Loop Fanfare_Sq0



Channel Fanfare_Sq1
    Header <BP>, <Env>

    Riff FF_Sq0::_1, (FF_Sq0::_Loop)+1

Loop Fanfare_Sq1, "Riffed"

```
- Here, all the labels are within Sq0's sandbox, but the byte after the _Loop label needs to be read, hence the +1.


- **WARNING:** Song's with an Intro Phrase can **not** have their `Loop` commands Riff'ed.
    - Trying to do so results in both channels using the exact same Re-Entry Label.

    - This is why the Loop syntax is either `Loop <Validation_Label>, "Riffed"` **OR** `Loop <Validation_Label>, <Re-Entry_Label>`

### Repeated Shift_Pitches

### Bad Ideas
- This is an informal section where I spitball some things that are technically possible, 
but probably shouldn't be attempted.

- It's also a chance for me to complain about how difficult If_Alts are.

#### Octave Shifts for Noise Channel
- "Pitch" shifts for the Noise Channel are already difficult to do.
- an "octave" shift doesn't make sense in this context, but still has two interesting and technically usable effects that save a byte over `Set_Pitch`

- 1) Shifting outside range +/-7 with one-byte.
- 2) Changing Kick Type with one-byte.

- The issue is these depend on the exact order of the Noise Bank and the Kick Types.
  - Also, both the NB index **and** the Kick Type and changed are simultaniously changed in a difficult to understand way.

#### Data Overloading.
- Techncially already doing this. The Unused Envelope data for the Attack Timer actually has to be $00. Lucklily, I have a bunch of $00 bytes. In the dmc samples. Its just... more complicated to keep things lined up.

- In general though, there are several 2-byte instrctions where teeeechnicaly a Riff / Repeat could access these a second time as an actual instruction. 
- For example, having the stars align so a Riffs jump address creates an instruction that a different Riff reads as an `Env_Change` so it can play the same section, but with a new instrument AND without specifying the `Env_Cange` with a new byte.
    - Of course, saving this one single byte then relies on:
        1) The index order of the envelopes.
        2) The address the first Riff jumps to.



#### Mixing Duration and If_Alt
- Unlike with Base Pitch, there isn't a convienent NOP.
- The closest is the `$70` Toggle. Changing which channel ignores the If_Alt *midway through a Duration* sounds like a pain to debug. Even more so than usual for If_Alt.
    - Also, If_Alts would only function correctly if the pitch is stored as the low nibble of the Duration data. It would also require a change to the Duration code, which probably isn't worth the Duration slot in the first place. 

    - Also, also. Doing this with 16th notes would only work if the Tempo was an even number. Which, the primary reason for this would be using it for 16th notes when the Tempo wants to be odd. (Cuz if its Even... just make the 16th note length the tempo and If_Alt the "8ths".)

#### Mixing custom Volume and If-Alt
- I've actually done this. It's a total pain, since you only control the Initial volume.
- The only reason I got away with it was both pulse channels just endlessly cycled loud and soft. The Volume never reached it's Target Volume, so Sq1 could consistantly stay quieter.


#### Mixing Repeat and If- Look mixing anything with If_Alt is just asking for trouble. 
- An If_Alt can give two versions of the Repeat Count (and also technically the Repeat Size. *Shudders*)
- This could save data in large, complex structures. Which are exactly the structures If_Alt is hardest to keep straight so.... yeah. Bad Idea.

- Ditto with mixing Riff and If_Alt. (Different Return addresses.) The syntax that would require alone makes my head spin...

#### Dynamic Music.
    -Waaay outside the scope of this engine alone.
        -However, I have a couple ideas for simple changes that external game logic could enforce.
        - For example, when a boss spawns, force the Noise channel to start reading different data.
        - Or... *sigh* Toggling If_Alt.

        -Or imagine underground areas forcibly swapping the pulse instruments to percussive versions.



#### Oversized Tempo
    -Defining a Songs Tempo to be more than `$20` results in the 6 cheap note lengths not being clean multiples of eachother. Who knows. Maybe there's a clever use case for a really large "Tempo".


## Debugging
-

*More debugging options to be explained in future updates.*

### Run-time catchable errors.
- These errors are caught when building a ROM with `Debugging_Enabled = 1`

*Options and explanations to be explained in future updates.*

### Non-Runtime catchable errors.
- Some errors cannot reliably be determined by code.

#### Note Timing Desyncs

There are two main culprits for single-frame drifting: custom note lengths and 16th notes in Durations.

**Custom Note Lengths:** These do not automatically sync back to a beat. Exact frame counts must be specified.
  - For long notes, such as `Notes 16*_8th, rest`, confirm that `Song <name>, <Tempo>` matches `_8th .set <Tempo>`.

**16th Notes in Durations:** If you are only using the default Duration Sets, this is not an issue.
  - For custom Duration Sets, confirm that the upper nibbles contain the same number of `$0` opcodes as the lower nibbles.


- If you did anything in LINK Bad Ideas, you're on your own.


#### Incorrect Notes
`Notes 8th,C4` is assembled using the hidden, ca65 variable `BP`

- `BP` is what the **expected** Base Pitch is. 
- If this does not match the actual runtime Base Pitch, the wrong pitch is played.

The two main culprits are:

- A Riff re-reading notes with a different Base Pitch than the original data.
    - See [Transposed Riffs](#transposed-riffs) for details.

- A `Riff` or `Repeat` reading a `Shift_Pitch` instruction again.
    - See [Base Pitch Tracking](#base-pitch-tracking) for details.

#### Infinite Loops
- More than two `Repeat` Instructions cannot be executed simultaniously.
    - This includes a Repeat buried deep inside a Repeated Riff.

- See [Repeat Instruction](#repeat-instruction) for details.




# Reading Raw Byte-Code:
- Understanding the Raw Bytes and Data Format is **not neccessary** for using the engine.
- However, for complete documentation and to aid runtime debugging, the data format is documented here.

- The majority of instructions are a single byte. 
- The upper nibble specifies the Opcode. (What function to run.)
- The lower nibble specifies the Operand. (What data the function uses.)

- When a second byte is needed, its format is varied.

- Understanding the Opcodes alone provides at least 90% of the useful information.
- The Opcodes use mnemonic names intended to make them easier to recognize and remember. 
  - Some mnemonics are just a bit more of a stretch than others.

**NOTE:** Most of the Operands are difficult to decypher, but less freqently the problem, thankfully.

## Header

*This data is not human readable*

- The first byte is the Env Bank, and the Env Index.
    - Format: `$BI`, where `B` is the Bank and `I` is the Index.

- The second byte is the Base Pitch and the Vibrato Depth
    - Format: `%PPPPPPvv` where `P` is the `A0..C6` Base Pitch and `v` is the Vibrato Depth.

**NOTE:** The Noise Channel reads unrelated data as its "Envelope".
  - The Envelope is set per-Note, and ignores the Envelope Bank.


## `Loop` Instruction

- There are Three versions of the Loop instruction.

- `Loop <Song_Name>_<Channel>` emits `$c0`

- `Loop <Song_Name>_<Channel>, "Riffed"` emits no data.
  - The `$c0` byte is read during a `Riff` of another Channel's data.

- `Loop` <Song_Name>_<Channel>, <Label> is `$c1, $xx`, where $xx is the 8-bit absolute address at which playback re-starts.
    - This is why Songs with an Intro cannot Riff the Loop. Each channel's re-starting address is unique.


## Opcodes `$0-, $1-, $2-, $3-, $4-, $6-, $8-` are `Notes`
- A Note's length is `Opcode * Tempo`, where Tempo is usually the 8th Length.

 -The following is a table of which opcodes corespond to which Note Length.
 ```text
+--------+----------------+
| Opcode | Note Length    |    
+--------+----------------+
| $0   - | Custom         |
| $1   - | Eighth         |
| $2   - | Quarter        |
| $3   - | Dotted-Quarter |
| $4   - | Half           |
| $6   - | Dotted-Half    |
| $8   - | Whole          |
+--------+----------------+
```

- `$0-, $xx` is the two-byte Note instruction, where `$xx` is the integer number of frames the Note lasts.
  - `$xx = 0` is treated as 256 frames.

**The Operands:** 
- `$-0` is a rest. 
- `$-1 .. $-f` are the pitch indexes, low to high.
  - The resulting pitch is `BP + Operand`.

- Reading a long string of `$00` bytes is a very long, but finite rest.
  - This usually happens with invalid pointers.

## Opcode `$5-` is `Duration`
Mnemonic : `5` for five is half of ten, and `Duration` makes Notes half a byte.
- Yeah... I know.

*This data is extremely not human readable*
- The Operand is the ID of the Duration Set to execute.

- Both nibbles of the next 1..5 bytes are Pitch Indexes, or rests if Zero. 
    - See [Note Operands](#opcodes-0-1-2-3-4-6-8-are-notes)
- Confusingly, while the bytes are read left to right, the nibbles are read right to left.

## Opcode `$7-` is `If_Alt`
Mnemonic : `7` is for... uh... Look, it was just what was left over, OK?

- A `$70` byte Toggles wether a Channel ignores If_Alt instructions.

*This data is very much, extremely not human readable. Just pray its written correctly. Fixing with trial and error is faster than hex decoding.*
- The Operand is a signed 4-bit integer.
- That delta is added to the next Byte's Operand (Confined to 4 bits).


## Opcodes `$9-, $a-` are `Repeat`
**Mnemonic :** `A` for Again. 
- Yeah it's a stretch...

- The Operands `$-0` and `$-1` are the Two-Byte Repeat Instructions.
- The second byte is the Repeat Count. (A `$00` or `$81..$ff` will Repeat indefinitely.)

*This data is very much not human readable*
- The format of the One-Byte Instruction is: `%10ssCCCs`
- `s` is the Repeat Size. (There is no typo. `s` is indeed bits 0, 4 and 5)
- `C` is the Repeat Count. 
  - The Two-Byte format is `%10ss000s, $CC`



## Opcode `$b-` is `Shift_Pitch`
**Mnemonic :** `B` for Base Pitch.

- The Operand is a signed 4-bit integer
    - `$b1 .. $b7` shifts +1 to +7 semitones
    - `$b9 .. $bf` shifts -7 to -1 semitones
    - `$b0` no operation.

    - `$b8, $xx` overrides to `Set_Pitch` 
        - Where `$xx` sets both the Base Pitch and Vibrato Depth.

        *This data is not human readable*
        - The format of the second byte is `%ppppppvv`
        where `v` is the Vibrato Depth and `p` is the `A0..C6` Base Pitch.
          - This is the same format as the Header.

- The `Shift_Pitch +Octave / -Octave` instructions use `$f-` opcodes.

    *This data is not human readable*
    - Their Operands depend on the order of the Misc Effects.



## Opcodes `$c-, $d-` are `Riff`

**Mnemonic :** `C` for riff Call, like calling a subroutine.


- `$c0` and `$c1` are overridden as `Loop` instructions.
    - `$c0` is the standard loop.
    - `$c1, $xx` is the intro-phrase loop
        - `$xx` is the 8-bit absolute address to jump to.
  - See [Loop Instruction](#loop-instruction)

- `$c2` is the 3-Byte Riff Instruction.

*This data is not human readable*
- Functionally, Riffs have a 3-bit opcode and a 5-bit Operand.
    - `%110rrrrr, $xx`
        - `r` specifies how many bytes to reread before returning (3..31)
        - `$xx` is the 8-bit absolute address to jump to.

    - `$c2, $rr, $xx` is the 3-Byte Riff.
        - `$rr` specifies how many bytes to reread before returning (32+)
        - `$xx` is the 8-bit absolute address to jump to.

## Opcode `$e-` is `Env_Change`
**Mnemonic :** `E` for Envelope.

    *This data is not human readable*
    - The Operand is the Env Index.

- The Two-Byte `Set_Env` Instruction uses an `$f-` opcode.

    *This data is not human readable*
    - The Operand depends on the order of the Misc Effects.

    - The second byte sets both the Bank and Index. (The same format as the Header)


## Opcode `$f-` is the Misc Effects.
**Mnemonic :** `F` for eFfects.

*This data is very much not human readable*
- The Operand depends on the order of the Misc Effects. 
    - This is not guareenteed to be consistant across engine versions.

- Those with a second byte have wildly different formats.
    - `Volume` picks apart 11-bits for Initial Volume, Target Volume, and Speed
    - `Pitch_Sweep` uses a signed 8-bit integer.
    - `Inc_Page` uses an 8-bit absolute address (Like the `Riff` instruction.)

- `Shift_Pitch +/-Octave` and `Set_Env` both use `$f-` opcodes as well. 



# License

- This project is licensed under the MIT License. 
- See the [LICENSE](LICENSE) file for the full license text.

## Waveform and Branding Disclaimer
The Tri-Pulse waveform is a waveform concept that Tri-Pulse Studios does not claim to have invented. The name Tri-Pulse Studios identifies this project's branding and does not imply ownership of the underlying waveform concept.

The DMC sample files and tools for generating them included with this project are specific implementations and digital representations of the waveform for use with NES audio hardware. Any MIT license applicable to these files and tools applies to those specific works, not to the underlying waveform concept.
