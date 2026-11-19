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

 
    ;Musical Noise SFX 
    @non_musical_Noise:
        SFX Snare_8_sfx, R8, 3, Snare_env, \
            1,R11, 0,R8

    ;

    Musical_Noise_SFX_Index .set SFX_Data_Index
        ;Above SFX queued by Noise Channel play via in-game SFX slots.
        ;Below play via Music-Only slot. in-game is prioritized.

    @dmc:
        SFX d25_Kick_sfx, R9, 2, DMC_d25_V18, \
            1,R9, 1,R5, ;0,R3 

        SFX d50_Kick_sfx, R9, 2, DMC_d50_V34, \     
            1,R9, 0,R4 

    ;

    @musical_noise:

        SFX Timpani_c_sfx, R12
        SFX Timpani_d_sfx, R13
        SFX Timpani_e_sfx, R14
        SFX Timpani_f_sfx, R15, -1, Timpani_env, \
            1,R13, 2,R14, 0,R15
        

        SFX Snare_8_w_Timpani_f_sfx, R0, -1, Snare_env, \
            1,R11, 2,R8, 1,R13, 0,R14

        SFX Snare_8_w_Timpani_e_sfx, R0, -1, Snare_env, \
            1,R11, 2,R8, 1,R12, 0,R13

        SFX Snare_8_w_Timpani_d_sfx, R0, -1, Snare_env, \
            1,R11, 2,R8, 1,R11, 0,R12

        SFX Crash_6_sfx, R6
        SFX Crash_7_sfx, R7, -1, Timpani_env, \
            1,R14, 2,R10, 3,R9, 5,R8, 0,R7



;============================================================
; Noise Bank
;============================================================

    DM_NB .set NoiseFX_Index 
    HC_NB .set NoiseFX_Index

        ;0
        NoiseFX Snare_8,       Snare_8_sfx, "Kick" ;G3

        
        NoiseFX Snare_8_w_Timpani_f, Snare_8_w_Timpani_f_sfx, "Kick" ;Gs3
        NoiseFX Snare_8_w_Timpani_e, Snare_8_w_Timpani_e_sfx, "Kick" ;A3
        NoiseFX Snare_8_w_Timpani_d, Snare_8_w_Timpani_d_sfx, "Kick" ;As3
    
        ; May be important to have an easy shift buffer.
        NoiseFX Crash_6,       Crash_6_sfx

        NoiseFX Timpani_c,         Timpani_c_sfx  
        NoiseFX Timpani_d,         Timpani_d_sfx  
        NoiseFX Timpani_e,         Timpani_e_sfx  
        NoiseFX Timpani_f,         Timpani_f_sfx  


            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate DM_NB ;Simple check tTimpani all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
    Kick_Type _d50_K, d50_Kick_sfx
    Kick_Type _d25_K, d25_Kick_sfx

    ;Kick_Type _d25_tom, A3_Tom_sfx
    ;Kick_Type Unused

;`
