


# TODO

- This file tracks planned improvements and ideas for future versions of the Tri-Pulse NES Audio Engine.

- The initial v0.1 release prioritizes making the engine available for demonstration and experimentation. 
- Documentation, usability, and supporting tools will be refined over time.

## Known Issues and Limitations

- **Song Data Page Confinement:** Each Song's Channel must fit within individual 256-byte ROM pages. Support for handling more than 256-byte is current extremely limited.

- **Assembly Macro Complexity:** Some macros are not convienent to use.

- **Limited Tooling:** Some workflow tasks require manual work.

- **Documentation:** Usage examples, macro documentation, and integration guidance are still being refined.

- **Pre-Alpha Stability:** The engine has not yet reached a polished, user-friendly release. Expect rough edges and potential bugs as development continues.

## v0.2 Plans 

### README Updates

-  Refine README organization and presentation.
	- Consistant formating.
	- Improve documentation of assembly macros and engine behavior.
	- Add more complete usage examples.

- Document more Advanced Compression Techniques.

- Likely splitting the README into multiple files, as it is rather long.

### Macro Syntax
- Simplify UI text syntax.
	- `UI_Word` 
	- `Song`

- Removing any {}s required .
	- `Header`
		- The params will be re-ordered, making `{<BP>}` into `<BP>, [Vib_Depth]`
	- `Song`

- Duration Non-Note syntax.
	- `Shift_Pitch`
	- `Set_Env`

### Names of Constants
- Vibrato related constants are not cohesive.

### Data Customizations
- Kick Types
- Vibrato Cycles
- Duration Sets

- Custom DMC samples.

#### SFX
- An overhaul of the SFX engine format.
	- Noise Channel exclusively uses the SFX engine.



### vscode Theme
- Updates to highlight more kinds of text.
	- Noise SFX Names with Famistudio matching tints.
	- The Noise Period Aliases, matching Pulse piano key Aliases.

- Highlighting all Macros.
	- Possibly making a subset of macros different colors
		- `add, lsrn`, and `Riff, Notes`, etc are proper "instructions"
		- `Env, SFX`, their data emitters, and `Channel, Header, Loop` are fundamentally different. The classify and organize data, and aren't intructions.
			- Maybe a slightly Redder shade of purple for them? Sorta halfway between ca65 directives and macros?

## v0.3 Plans

### Tools
-  Song Validator

-  Page Binner for managing Song Data page confinement.

-  Pitch Sweep Rate calculator.

-  Alternate DAW Support
-	A Tri-Pulse wave plugin
-	Pitch-Naming compability

- NES Runtime Debugging tools.

- Misc Effect Expansion
	- A set of macros to only include the code/data for used Misc Effects.
		- Repalcing all `.byte <Effect>` with Macros, for logging purposes. 

	- I have more ideas for Misc Effects. Too many for only 16 slots.
		- The SPecial Volume by default uses 8, but in practice won't need that many.


### API
- documentation to integrate the engine into a game or other user projects.

- the subroutines `Update_Music`, `Init_Song`, and `Queue_SFX` will be documented and generally usable.

### vsCode Theme
- Releasing a more comprehensive and usable theme (or themes)
	- At minimum, bundling several theme options.
	- If possible, an additional option for fully customizable theme.