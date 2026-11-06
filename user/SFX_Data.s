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
        SFX Hat_5_sfx,  R5
        SFX Hat_7_sfx,  R7
        SFX Hat_10_sfx, R10, 4, Hat_env, \
            2,R10, 0,R11

    Musical_Noise_SFX_Index .set SFX_Data_Index
        ;Above SFX queued by Noise Channel play via in-game SFX slots.
        ;Below play via Music-Only slot. in-game is prioritized.

    @dmc:
        SFX Water_Hit_sfx, R0, 4, DMC_Tri, \     
            1,R4, 1,R6, 1,R8, 1,R9 ;Volume 34

    ;

    @musical_noise:
        SFX Tamb_1_sfx, R1, -1, Tamb_env, \
            1,R8, 1,R3, 2,R2, 0,R1


    ;

;============================================================
; Noise Bank
;============================================================

    Schala_NB .set NoiseFX_Index 

        ;0
        NoiseFX Tamb_1,   Tamb_1_sfx

        NoiseFX Hat_10,    Hat_10_sfx
        NoiseFX Hat_7,    Hat_7_sfx
        NoiseFX Hat_5,   Hat_5_sfx

        NoiseFX Hat_10_Water,  Hat_10_sfx, Water_Hit_sfx
        NoiseFX Solo_Water,   $00,       Water_Hit_sfx

            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate Schala_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
    Kick_Type Unused, $00  ;_d50_K, d50_Kick_sfx
    ; Kick_Type _d25_K, d25_Kick_sfx
    ; Kick_Type _d25_tom, A3_Tom_sfx
    ;Kick_Type Unused

;`
