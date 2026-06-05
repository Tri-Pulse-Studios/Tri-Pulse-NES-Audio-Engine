; ============================================================
; Tri-Pulse NES Audio Engine - Public API Include
; ============================================================
;
; Purpose:
;   This file defines the official interface for the Tri-Pulse
;   NES Audio Engine when using the recommended build pipeline
;   (packer-generated object files + ld65 linker workflow).
;
; Intended Use:
;   - Include this file in game projects that use the audio engine
;   - Provides .import declarations for engine API functions
;   - Defines constants, channel IDs, and queue interfaces
;   - Assumes music/sfx data is compiled into separate .o files
;     via the tools/packer pipeline
;
; Build Model:
;   engine + generated music.o + generated sfx.o → ld65 → ROM
;
; DO NOT:
;   - Modify this file for per-project data
;   - Include user music/SFX definitions here
;
; See Also:
;   README.md Section: "Build System"
;   README.md Section: "Runtime API"
;
; ============================================================



; ------------------------------------------------------------
; Init_Song
;
; A = Song ID
;
; Initializes song state machine.
; Must be called before Update_Music.
; ------------------------------------------------------------
.import Init_Song



; ------------------------------------------------------------
; Update_Music
;
; No Arguments
;
; Updates the audio engine state machine.
; Should be called once per frame (typically at end of NMI).
;
; ------------------------------------------------------------
.import Update_Music

    ; jsr Update_Music
    ;
    ; WARNING:
    ;   Must not be called before Init_Song.
    ;
    ;   Undefined behavior includes:
    ;     - garbage audio output
    ;     - system hang (Engine can get stuck reading garbage data)
    ;
    ; Typical Song Performance:
    ;   Average     ~1500 cycles/frame  (~5%)
    ;   Worst 10%   ~3000 cycles/frame  (~10%)
    ;   Worst 1%    ~6000 cycles/frame  (~20%)



; ------------------------------------------------------------
; Queue_SFX
;
; Arguments:
;   A = SFX_Index (not SFX ID; see README section x.x)
;   X = Channel Index
;
; Requests playback of a sound effect on the specified channel.
; SFX execution is handled by the audio engine update loop.
;
; Channel Constants (for X register):
;
    TP_CH_SQ0   = $00
    TP_CH_SQ1   = $04
    TP_CH_TRI   = $08
    TP_CH_NOISE = $0C
    TP_CH_DMC   = $10
;
; ------------------------------------------------------------
.import Queue_SFX

    ; jsr Queue_SFX
    ;
    ;   See README section x.x for SFX Priority System
