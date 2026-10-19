





    ;SFX_format:
    ;2 Types:
        ;Sweep_Sfx:
            ;Starting pitch, linear sweep, duration, volume env. Thats it.
            ;Call via index $00-$7f 
                  ;BP, Length, Env
            ;.byte $28,  $02,   $0a
            ;.byte $70 ;Sweep Rate. (Load BP, sweep that rate.)
                            ;Except here, Sweep rate means In Notes/f

                ;Note that these use the exact same Header Structure to re-use code.
                ;This will re-use the Volume structure of Music, but can reference additional ones specific for SFXs.

        ;Musical:
            ;Call via $80-$ff (Value is index to sfx Data. Limit 128 Bytes of this type.)
            ;Format
                ;.byte $XY
                    ;X = Length (in raw frames, 1-15. (0 means hold until sfx stops))
                    ;Y = Pitch

                    ;ex, Solstice's Crash =
                    ;Header to define
                          ;BP, Length, Env (For Noise, BP can be Garbage.)
                    ;.byte $00,   $30,  $0b
                    ;.byte $1b, $19, $18, $16, $1a, $36, $45, $54, $03
                            ;RLE takes too much code to save too little data.
                    ;Solstice Snare
                    ;.byte .byte $a1, $c0 





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


;header format:
;$Pitch, $Env, $Length, $Env_Dampen
    ;Pitch, 
        ;0-1f. *2 for BP (Tracks in half steps. Noise stores a 0-f directly)

    ;Length

    ;Env 0-7 
        ;One of Eight Duty/Volume profiles.
        ;Also 1/2, 3/4, Full, or 3/2 Volume via damped? (Presently Unimplimented)


;Can easily compress to \/ 

;%ppppp eee, %llllll EE, $s
;p = Starting pitch, 0-15, asln (Sweeps Start there, decend down.) 
;l = length in frames
;e = env
;s = sweep speed (2's comp, half-notes/f)

;musical
;%ppppp eee, %llllll EE, $XY, $XY, $XY
;p = BP asln 2, add 1-15 for next note. (No way to shift BP)
;l = length
;e = env
    ;E= volume damp mask.
; $XY
    ;X = length of this note in frames. (0 means hold forever.)
    ;Y = 1-15 Pitch. (0=Rest Unimplimented)





