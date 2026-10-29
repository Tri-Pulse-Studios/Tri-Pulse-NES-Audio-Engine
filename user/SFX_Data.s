;============================================================
; SFX Data
;============================================================

    ; Noise Period / DMC Rate Aliases
        ; Do not alter these. The `SFX` macro validates Noise vs Pulse by them.

        R0  = $0
        R1  = $1
        R2  = $2
        R3  = $3
        R4  = $4
        R5  = $5
        R6  = $6
        R7  = $7
        R8  = $8
        R9  = $9
        R10 = $a
        R11 = $b
        R12 = $c
        R13 = $d
        R14 = $e
        R15 = $f

    ;     R0  = $fff0
    ;     R1  = $fff1
    ;     R2  = $fff2
    ;     R3  = $fff3
    ;     R4  = $fff4
    ;     R5  = $fff5
    ;     R6  = $fff6
    ;     R7  = $fff7
    ;     R8  = $fff8
    ;     R9  = $fff9
    ;     R10 = $fffa
    ;     R11 = $fffb
    ;     R12 = $fffc
    ;     R13 = $fffd
    ;     R14 = $fffe
    ;     R15 = $ffff
            
    ; ;



    ;Musical Noise SFX 
    @non_musical_Noise:
        SFX Hat_4_sfx, R4
        SFX Hat_2_sfx, R2, 1, Hat_env,\
            0,R2

        SFX Rasp_d_sfx, R13
        SFX Rasp_c_sfx, R12, 1, Shaker_env, \
            0,R12

        SFX Shaker_5_sfx, R5
        SFX Shaker_4_sfx, R4
        SFX Shaker_2_sfx, R2, 3, Shaker_env,\
            1,R1, 1,R2, 0,R3

    ;

    Musical_Noise_SFX_Index .set SFX_Data_Index
        ;Above SFX queued by Noise Channel play via in-game SFX slots.
        ;Below play via Music-Only slot. in-game is prioritized.

    @dmc:
        SFX A2_Tom_sfx, R6            ;2-semitone for BC

        SFX F4_Tom_sfx, R14
        SFX A3_Tom_sfx, R12      ;The three 3-semitone intervals
        SFX D3_Tom_sfx, R9, 2, DMC_d25_9_81, \
            1,R9, 0,R8 ;Volume 18

        SFX d25_Kick_sfx, R9, 3, DMC_d25_9_81, \
            1,R9, 1,R5, 0,R3 ;Volume 18

        SFX d50_Kick_sfx, R9, 2, DMC_Tri, \     
            1,R9, 0,R4 ;Volume 34

    ;

    @musical_noise:
        SFX Crash_3_sfx, R3
        SFX Crash_7_sfx, R7, -1, Crash_env, \
            1,R14, 2,R10, 3,R9, 5,R8, 0,R7


        SFX Snare_8_sfx, R8
        SFX Snare_6_sfx, R6, -1, Snare_env, \
            1,R10, 0,R6

        SFX Pre_Cymbal_4_sfx, R4, -1, Pre_Cymbal_env, \
            0,R4

        SFX Rasp_w_Shaker_3_sfx, R3
        SFX Rasp_w_Shaker_2_sfx, R2, -1, Shaker_env, \
            1,R12, 0,R2

    ;

;============================================================
; Noise Bank
;============================================================

    Default_NB .set NoiseFX_Index 

        ;0
        NoiseFX Crash_3,       Crash_3_sfx,  "Kick"
        NoiseFX Crash_7,       Crash_7_sfx,  "Kick" 

        NoiseFX Snare_6,       Snare_6_sfx   
        NoiseFX Snare_6_Kick,  Snare_6_sfx,  "Kick"

        ;4
        NoiseFX Shaker_2,      Shaker_2_sfx
        NoiseFX Shaker_Kick,   Shaker_2_sfx, "Kick"
        NoiseFX Shaker_D3,     Shaker_2_sfx, D3_Tom_sfx ;Pair w/ the A3_Tom Kick

        NoiseFX Hat_2,         Hat_2_sfx  
        NoiseFX Hat_Kick,      Hat_2_sfx,    "Kick"    
        NoiseFX Hat_D3,        Hat_2_sfx,    D3_Tom_sfx ;Pair w/ the A3_Tom Kick

        ;10
        NoiseFX Rasp_d,      Rasp_d_sfx
        NoiseFX Rasp_c,      Rasp_c_sfx

        NoiseFX Rasp_2,      Rasp_w_Shaker_2_sfx
        NoiseFX Rasp_2_Kick, Rasp_w_Shaker_2_sfx, "Kick"

        ;15
        NoiseFX Pre_Cymbal_4,  Pre_Cymbal_4_sfx


            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate Default_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
    Kick_Type _d50_K, d50_Kick_sfx
    Kick_Type _d25_K, d25_Kick_sfx
    Kick_Type _d25_tom, A3_Tom_sfx
    ;Kick_Type Unused

;`
