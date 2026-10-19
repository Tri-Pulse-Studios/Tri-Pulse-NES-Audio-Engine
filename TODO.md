


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
	- `Env_Change`

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



## v0.3 Plans

### Tools
-  Song Validator

-  Page Binner for managing Song Data page confinement.

-  Pitch Sweep Rate calculator.

-  Alternate DAW Support
-	A Tri-Pulse wave plugin
-	Pitch-Naming compability

- NES Runtime Debugging tools.

### API
- documentation to integrate the engine into a game or other user projects.

- the subroutines `Update_Music`, `Init_Song`, and `Queue_SFX` will be documented and generally usable.

### vsCode Theme
- Releasing a more comprehensive and usable theme (or themes)

