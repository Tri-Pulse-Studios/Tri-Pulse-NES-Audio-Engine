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

    @non_musical_Noise:
        SFX Hat_c_sfx,  R12
        SFX Hat_b_sfx,  R11
        SFX Hat_1_sfx,  R1, 1, Hat_env, \
            0,R1

    Musical_Noise_SFX_Index .set SFX_Data_Index
        ;Above SFX queued by Noise Channel play via in-game SFX slots.
        ;Below play via Music-Only slot. in-game is prioritized.

    @dmc:
        SFX d25_Kick_sfx, R0, 3, DMC_d25_V18, \     
            1,R10, 1,R7, 0,R4 

    

    @musical_noise:
        SFX Snare_9_sfx, R9
        SFX Snare_8_sfx, R8, -1, Snare_env, \
            1,R10, 0,R8


        SFX Timpani_d_sfx, R13
        SFX Timpani_c_sfx, R12
        SFX Timpani_b_sfx, R11, -1, Timpani_env, \ 
            1,R9, 2,R10, 0,R11

    ;

;============================================================
; Noise Bank
;============================================================

    Green_Brinstar_NB .set NoiseFX_Index 

        ;0
        
        NoiseFX Snare_8,     Snare_8_sfx

        NoiseFX Snare_8_K,   Snare_8_sfx, "Kick"
        NoiseFX Snare_9_K,   Snare_9_sfx, "Kick"

        NoiseFX Hat_c,     Hat_c_sfx
        NoiseFX Hat_b,     Hat_b_sfx
        NoiseFX Hat_1,     Hat_1_sfx

        NoiseFX Timpani_d, Timpani_d_sfx
        NoiseFX Timpani_c, Timpani_c_sfx
        NoiseFX Timpani_b, Timpani_b_sfx

    NB_Validate Green_Brinstar_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================
 
    Kick_Type d25_K, d25_Kick_sfx

;` 
