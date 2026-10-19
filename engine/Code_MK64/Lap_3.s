


;Idea  Speed up by One by Double-Updating every few frames.
    ;To avoid issues with ATK/Kick changes, double update will be exactly frame 4

    ;Insert just before Song_Init
py_Segment Lap_3_Macros, Defines

Lap_3_Macros:




.macro Update_Music_if_Lap_3
    lda Lap_3_Flag
    beq @rts

    dec Music_Speed_Up_Timer
    bne @rts

        lda Eighth_Length
        cmp #8
        bcs @skip_3
        
            asl ;Assumes <8  is 16/16 time.  Double to 8/8 time for consistancy.

        @skip_3:
        sta Music_Speed_Up_Timer
        

        jsr Update_Music ;Double Update every 8th Length Frames.
        dec Music_Speed_Up_Timer ;The double update consumes this frame

    @rts:
.endmacro



py_Segment_End Lap_3_Macros