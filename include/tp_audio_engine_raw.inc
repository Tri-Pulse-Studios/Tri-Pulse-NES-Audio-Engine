; ============================================================
; Tri-Pulse NES Audio Engine - Manual Build Include
; ============================================================
;
; Purpose:
;   This file defines macros and integration helpers for users
;   who prefer a fully manual ca65 build process without the
;   packer pipeline or generated .o files.
;
; Intended Use:
;   - Direct .include ordering of engine + music + SFX sources
;   - Manual control over assembly order and segment layout
;   - Debugging, experimentation, or minimal-tool workflows
;
; Build Model:
;   engine.s + song.s + sfx.s → ca65 → ld65 → ROM
;
; This mode:
;   - Does NOT require tools/packer.py
;   - Does NOT use tools/generated/*.o outputs
;   - Relies on explicit include ordering and ca65 scope rules
;
; DO NOT:
;   - Mix with packer-generated object workflow in the same build
;   - Assume compatibility with automated layout or compression
;
; See Also:
;   README.md Section: "Manual Build Method"
;   README.md Section: "Audio Engine Architecture"
;   README.md Section: "Music DSL vs Raw Format"
;
; ============================================================