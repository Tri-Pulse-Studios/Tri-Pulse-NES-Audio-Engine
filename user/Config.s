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
            ;and not overlapping w/ ZP_RAM_Start

        Riff_Buffer_Start = $300
            ;Reserves $50 or $a0 (80 or 160) Bytes of contiguous standard RAM.
            ;Valid range is $300-$7b0 or $300-$760

        Expand_Max_Riff_Depth = 1
            ;0 = Max depth 4. Uses 80 Bytes of RAM  
            ;1 = Max depth 8. Uses 160 Bytes of RAM
            ;
            ; Disable only if you can't spare the RAM

    ;========================================================
    ;Runtime Debugging Tools
    ;========================================================
        Debugging_Enabled = 0
            ;Enables various NES runtime checks in the code.
            ;If an exception is detected, the console is crashed.
            ;
            ;See the README for details

        Debugging_Crash_Address = -1
            ;When a runtime error crashes, set this to the PC of the STP opcode.
            ;On rebuilding the ROM, this will point to the region of code responsible for the error.
            ;Further debugging instructions may be included.

    ;
;