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
        SFX Hat_2_sfx, R2, 2, Hat_env,\
            1,R4, 0,R2

    ;

    Musical_Noise_SFX_Index .set SFX_Data_Index
        ;Above SFX queued by Noise Channel play via in-game SFX slots.
        ;Below play via Music-Only slot. in-game is prioritized.

    @dmc:
        SFX d50_Kick_sfx, R9, 2, DMC_Tri, \     
            1,R9, 1,R6, 0,R3 ;Volume 34

    ;

    @musical_noise:
        SFX Crash_3_sfx, R3
        SFX Crash_7_sfx, R7, -1, Crash_env, \
            1,R14, 2,R10, 3,R9, 5,R8, 0,R7

        SFX Snare_6_sfx, R6, -1, Snare_env, \
            1,R12, 0,R6

        SFX Wash_5_sfx, R5
        SFX Wash_8_sfx, R8, -1, Wash_env, \
            2,R7, 0,R8

    ;

;============================================================
; Noise Bank
;============================================================


    Overworld_NB .set NoiseFX_Index
    Khevari_NB .set NoiseFX_Index
        NoiseFX Crash_3,      Crash_3_sfx, "Kick"
        NoiseFX Crash_7,      Crash_7_sfx, "Kick"
    
        NoiseFX Snare_6,      Snare_6_sfx
        NoiseFX Snare_6_Kick, Snare_6_sfx, "Kick"

        NoiseFX Hat_2,        Hat_2_sfx
        NoiseFX Hat_2_Kick,   Hat_2_sfx,   "Kick"
        NoiseFX Hat_4,        Hat_4_sfx
        NoiseFX Hat_4_Kick,   Hat_4_sfx,   "Kick"

        NoiseFX Wash_5,       Wash_5_sfx
        NoiseFX Wash_5_Kick,  Wash_5_sfx,  "Kick"
        NoiseFX Wash_8,       Wash_8_sfx
        NoiseFX Wash_8_Kick,  Wash_8_sfx,  "Kick"
        
        NoiseFX Solo_Kick,    $00,         "Kick"
            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate Khevari_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
    Kick_Type _d50_K, d50_Kick_sfx
    ;Kick_Type Unused
    ;Kick_Type Unused
    ;Kick_Type Unused

;`
