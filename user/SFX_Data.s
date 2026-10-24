;============================================================
; SFX Data
;============================================================
    ; WARNING: A complete over-haul of the SFX format is planned.


    ; Since the SFX data format is fairly obtuse, a Starter set is provided.
    ;       Examples of them playing can be found in the inlcuded FamiStudio file's Noise and DMC Channels: Tri_Pulse_Demo.fms
    ;
    ; See the README for the complete SFX format.



    ;LUT_SFX_Data:

    ;.byte $00 ;Index $00 Is current treated as "No SFX"
    LUT_SFX_Data = *- ($80 - $29)
        @Sqr:
            ; Simple_SFX @Char_Jump_Low, G2, +2
            ; Simple_SFX Char_Jump_SFX,  A2, +2, 6, Snare_env

        @Noise:
            Simple_SFX Hat_d_adr, $d, 0
            Simple_SFX Hat_2_adr, $2, 0, 1,   Hat_env

            Simple_SFX  Rasp_d_adr, $d, 0
            Simple_SFX  Rasp_c_adr, $c, 0, 1, Shaker_env

            Simple_SFX Shaker_7_adr, $6, +2
            Simple_SFX Shaker_5_adr, $4, +2
            Simple_SFX Shaker_3_adr, $2, +2
            Simple_SFX Shaker_2_adr, $1, +2, 3, Shaker_env

            


        @Tri:
            


            ; Simple_SFX Kick, D2, -5, 4, Crash_env

            ; Simple_SFX G3_Sweep, G3, -2
            ; Simple_SFX F3_Sweep, F3, -2, 12, Crash_env

        @dmc:
            ;Simple_SFX Water_Hit, $7, +2, 4, DMC_Tri


            Simple_SFX DK_d12_Kick, $f,   -2, 12, DMC_d12_1_17
    
            Simple_SFX d12_Tom_High, $e, -2  ;Train
            Simple_SFX d12_Tom_Low, $c, -2, 2, DMC_d12_4_65 ;2-semitone intervals
                d12_Tom_adr = d12_Tom_High
    
            Simple_SFX A2_Tom,  $6, -2 ;2-semitone for BC

            Simple_SFX F4_Tom,      $e, -2
            Simple_SFX As3_Tom_adr, $c, -2  ;The 3 3-semitone intervals
            Simple_SFX Ds3_Tom,     $9, -2, 2, DMC_d25_9_81 


            ;Simple_SFX d25_kick_lo, $6, -6
            Simple_SFX d25_Kick_adr, $9, -6, 3, DMC_d25_9_81 ;Volume 18 


            ;Simple_SFX d50_Kick_lo,  $6, -8
            Simple_SFX d50_Kick_adr, $9, -8, 2, DMC_Tri ;Volume 34

    ;

    Musical_SFX: 
    .assert (Musical_SFX-LUT_SFX_Data >= $80), warning, "Musical Index Too Early"
    .assert (Musical_SFX-LUT_SFX_Data <= $80), warning, "Musical Index Too Late"
            ;If this gets annoying, I can unrolled loop .assert when the ($80-index) should be.


    ; .if (Musical_SFX-LUT_SFX_Data)< $80
    ;     .error "Musical_SFX not starting with bit 7 set."
    ; .endif

        @Sqr:
        ;     Complex_SFX @Side, F2
        ;     Complex_SFX Side_Flip_FX, Ds2, 8, Snare_env
        ;     .byte $11, $15, $18, $1a, $1b, $3c

        @Tri:
        ;     Complex_SFX Hoot_Fs5, Ds5
        ;     Complex_SFX Hoot_F5,  D5
        ;     Complex_SFX Hoot_C5,  A4, 8, T_0f__d25
        ;     .byte $11, $64, $11 ;1f, 6f, 1f,   A4, C5, Ca4

        @Noise:
                ;[WARN] The Length Param is ignored for Complex Noise SFX
                    ;The length is over-ridden by the Timer for New_Note
            Complex_SFX Crash_4_adr, $4 
            Complex_SFX Crash_6_adr, $6, 36, Crash_env 
            .byte $18, $34, $43, $52, $01

            Complex_SFX Snare_4_adr, $4 
            Complex_SFX Snare_6_adr, $6, 9, Snare_env
            .byte $15, $01


            Complex_SFX Pre_Cymbal_4_adr, $3, 15, Pre_Cymbal_env
            .byte $01 ;Static (In Complex so hats over-write it)

        
            Complex_SFX  Rasp_w_Shaker_3_adr, $3
            Complex_SFX  Rasp_w_Shaker_2_adr, $2, 3, Shaker_env
            .byte $1b, $01 ;c - 2





        ; @Tri: ;And other depreciated

            ;     Complex_SFX C4_Blip, C4
            ;     Complex_SFX D3_Blip, D3, 9, Crash_env ;env always on. 
            ;     .byte $31,$30,$31,$00 ;On-off-On every 3f (The $00 is safety that it doesn't stay on)

            ; Complex_SFX Tamberine, $1
            ; Complex_SFX Tamb_3_adr, $3, 21, Tamberine_env
            ; .byte $16, $22, $01
    

            ; Simple_SFX Lo_Sweep, $0a, -1
            ; Simple_SFX Hi_Sweep, $06, -1, 6, Sweep_env



            ; Simple_SFX Tick_1_adr,  $01, +0
            ; Simple_SFX Tick_11_adr, $0b, +0
            ; Simple_SFX Tick_12_adr, $0c, +0, 1, Crash_env

            ; Complex_SFX Metroid_Sweep_11, $b
            ; Complex_SFX Metroid_Sweep_12, $c
            ; Complex_SFX Metroid_Sweep_13, $d, 15, Metroid_Sweep
            ; .byte $11, $32, $03


    ;




    .if (*-LUT_SFX_Data)> $ff
        .error "Musical_SFX Overflowing Allocated $80-$ff Range."
    .endif








;============================================================
; Noise Bank
;============================================================

    Star_Cave_NB .set NoiseFX_Index 
    Rubify_NB .set NoiseFX_Index

        ;0
        NoiseFX Solo_Kick,     $00, "Kick"

        NoiseFX Crash_4,       Crash_4_adr,  
        NoiseFX Crash_6,       Crash_6_adr,  

        NoiseFX Snare_4,       Snare_4_adr   
        NoiseFX Snare_4_Kick,  Snare_4_adr,  "Kick"

        NoiseFX Snare_6,       Snare_6_adr   
        NoiseFX Snare_6_Kick,  Snare_6_adr,  "Kick"


        NoiseFX Shaker_2,      Shaker_2_adr
        NoiseFX Shaker_Kick,   Shaker_2_adr, "Kick"

        NoiseFX Hat_2,         Hat_2_adr  
        NoiseFX Hat_Kick,      Hat_2_adr,    "Kick"    

        NoiseFX Rasp_c_Kick, Rasp_c_adr,     "Kick"

        NoiseFX Rasp_2_Kick, Rasp_w_Shaker_2_adr, "Kick"

        ;15
        NoiseFX Pre_Cymbal_4,  Pre_Cymbal_4_adr  


            ;More than 15 NoiseFX can be defined, but not accessed all at once.
            ;Shift_Pitch instructions can change the defined window mid-song as well.

    NB_Validate Star_Cave_NB ;Simple check that all NoiseFX fit in 15 window.

;============================================================
; Kick Types
;============================================================

    
        Kick_Type _d50_K,   d50_Kick_adr
        Kick_Type _d25_K,   d25_Kick_adr
        Kick_Type _d25_tom, As3_Tom_adr
        ;Kick_Type Unused 4th Slot
    ;
