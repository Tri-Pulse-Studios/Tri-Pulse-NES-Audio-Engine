

; THIS FORMAT IS TO BE DEPRECIATED


;LUT_SFX_Data:

;.byte $00 ;Index $00 Is current treated as "No SFX"
LUT_SFX_Data = *- ($80 - $29)
    @Sqr:
        ; Simple_SFX @Char_Jump_Low, G2, +2
        ; Simple_SFX Char_Jump_SFX,  A2, +2, 6, Snare_env

    @Noise:
        Simple_SFX Hat_4_adr, $4, 0
        Simple_SFX Hat_2_adr, $2, 0, 1, Hat_Env

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

        Complex_SFX Crash_3_adr, $3 
        Complex_SFX Crash_7_adr, $7, 36, Crash_env 
        .byte $18, $34, $43, $52, $01

        Complex_SFX Snare_8_adr, $8 
        Complex_SFX Snare_6_adr, $6, 9, Snare_env
        .byte $15, $01


        Complex_SFX Pre_Cymbal_4_adr, $3, 15, Pre_Cymbal_env
        .byte $01 ;Static (In Complex so hats over-write it)

       
        Complex_SFX  Rasp_w_Shaker_3_adr, $3
        Complex_SFX  Rasp_w_Shaker_2_adr, $2, 3, Shaker_env
        .byte $1b, $01 ;c - 2








.if (*-LUT_SFX_Data)> $ff
    .error "Musical_SFX Overflowing Allocated $80-$ff Range."
.endif





