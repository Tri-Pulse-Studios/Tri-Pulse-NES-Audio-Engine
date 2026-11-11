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
        SFX Hat_e_sfx, R14

        SFX Hat_b_sfx, R11
        SFX Hat_a_sfx, R10
        SFX Hat_9_sfx, R9
        SFX Hat_8_sfx, R8
        SFX Hat_7_sfx, R7

        SFX Hat_2_sfx, R2, 1, Hat_env,\
            0,R2



        SFX Shaker_3_sfx, R3
        SFX Shaker_2_sfx, R2, 3, Shaker_env,\
            1,R1, 1,R2, 0,R3

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

        SFX Snare_6_sfx, R6, -1, Snare_env, \
            1,R10, 0,R6

        SFX Cymbal_4_sfx, R4, -1, Cymbal_env, \
            0,R4


;============================================================
; Noise Bank
;============================================================

    FF_NB .set NoiseFX_Index 


        ;0
        NoiseFX Snare_6,       Snare_6_sfx   
        NoiseFX Snare_6_Kick,  Snare_6_sfx,  "Kick"

        NoiseFX Shaker_3,      Shaker_3_sfx
        NoiseFX Shaker_Kick,   Shaker_3_sfx, "Kick"

        NoiseFX Hat_2,         Hat_2_sfx  
        NoiseFX Hat_2_Kick,    Hat_2_sfx,    "Kick"    

        NoiseFX Hat_e,         Hat_e_sfx  
        NoiseFX Hat_e_Kick,    Hat_e_sfx,    "Kick"  

        NoiseFX Solo_Kick,     $00,          "Kick"  


        NoiseFX Hat_7,         Hat_7_sfx  
        NoiseFX Hat_8,         Hat_8_sfx  
        NoiseFX Hat_9,         Hat_9_sfx  
        NoiseFX Hat_a,         Hat_a_sfx  
        NoiseFX Hat_b,         Hat_b_sfx  


        NoiseFX Cymbal_4,  Cymbal_4_sfx


            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate FF_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
    Kick_Type _d50_K, d50_Kick_sfx
    Kick_Type _d25_K, d25_Kick_sfx
    ;Kick_Type _d25_tom, A3_Tom_sfx
    ;Kick_Type Unused

;`
