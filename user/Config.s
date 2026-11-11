;============================================================
; Engine Settings
;============================================================

    ;========================================================
    ;RAM Allocation
    ;========================================================
        ZP_RAM_Start = $00
            ;Reserves $16 (22) Bytes of contiguous ZP RAM.
            ;Valid range is $00-$ea

        RAM_Start = $16
            ;Reserves $a0 (160) Bytes of contiguous standard RAM.
            ;Valid range is $300-$760  or  $00-$60
                ;Presumes OAM is Page 2.
                

        Riff_Buffer_Start = $300
            ;Reserves $50 or $a0 (80 or 160) Bytes of contiguous standard RAM.
            ;Valid range is $300-$7b0 or $300-$760

        ;All RAM allocations must be Non-Overlapping.

        Expand_Max_Riff_Depth = 1
            ;0 = Max depth 4. Uses 80 Bytes of RAM  
            ;1 = Max depth 8. Uses 160 Bytes of RAM
            ;
            ; Disable only if the extra RAM can't be spared.
                ; CURRENTLY UNIMPLIMENTED

    ;========================================================
    ;Runtime Debugging Tools
    ;========================================================

        ;See the README for details

        Debugging_Enabled = 0
            ;Enables various NES runtime checks in the code.
                ;The console hardlocks if an exception is detected.

            
        Debugging_Address = -1
            ; After an NES Runtime Hardlock, set `Debugging_Address` to the 16-bit address of the STOP opcode. (The $02 Byte)
                ; After setting, rebuild the ROM.
                ; A ca65 `.error` will identify the offending code, along with a description of the error.

    ;
    ;========================================================
    ;Engine Options
    ;========================================================
        ; These are Unimplemented. 
            ; Planned for v0.3 
            ; See TODO.md for details.

        Include_UI_Engine = 1
            ; Disable for a custom project.
                ; The Reset and UI_Update routines are omitted.
                ; The user is responsible for a custom handler that calls:
                    ; `lda #<Song_Name>_Index   jsr Init_Song` 
                    ; `jsr Update_Music`

        Enable_Page_Binner = 0
            ; Enable the 2-Stage ROM Build.
                ; Re-organizes Song Data and Engine Code.
                ; Eliminates the need for `.align 256` padding in Song Data.

                ; Requirements:
                    ; The external Binning Tool in `tools/`.
                    ; The Binning Instructions in the `.s` files (currently planned as `py_segment`. Syntax TBD).
;