
 
@LUT_Periods:
    
    py_Segment LUT_12_Periods, Free
        LUT_12_Periods:
        .byte $ef, $0f, $36, $65, $a4, $eb, $43, $a2, $0a, $79, $f0, $70
            ; A0,  As0, B0,  C1,  Cs1, D1,  Ds1, E1,  F1,  Fs1, G1,  Gs1 

    
            ;$7FD, $7E1, $7C6, $6AC, $695, $57D, $568, $554, $541, $42F, $41F, $40E, 
                    ; but lsrn3 16bit, ror 8bit

    py_Segment_End LUT_12_Periods
;


@dmc_LUTs:
    py_Segment LUT_dmc_rates, Free
        LUT_dmc_rates:

        ;Note Indexes
            ;0-2, Underflow 12.5%
            ;3-e, Low 12.5% B0-A1
            ;f-1d High 12.5% / Low 25% A#1-C3
            ;1e-2c High 25% C#3-D#4
            ;2d-ff Overflow 25%


            ; dmc_low_25 = Pre_25-LUT_dmc_rates+3 ;$e
            ; dmc_high_12_5 = dmc_low_25+dmc_overlap+3    ;$1d 
                ;the 3 is offset of lowest 12.5 vs lowest Tri

        LUT_dmc_d12_rates:
        _12_5_Only:
        ;B0-D#1
        .byte $50,$30,$51,$31,$52 ;$52=$40 (Row is Pretty much unusably low. Also, $30 and $31 are -28c and -22c)
        ;E1-A1
        .byte $53,$41,$54,$42,$55, $35 ;<-A1 (-25c)

        Pre_25:
        ;A#1-D2
        .byte $56,$57,$45,$58,$46
        ;D#2-F#2
        .byte $47,$59,$48,$5a
        ;G2(-18c)-A2(-38c)
        .byte $3a,$49,$3b
        ;A#2-C3  ;+9c,-12c 
        .byte $4a,$5c,$3c 


        ;The 15 bytes to either side represent the same notes, just w/ a different Duty Cycle.

        ;all of bit 7s MUST be 0
        LUT_dmc_d25_rates: ;25%
        @25: ;to Get @12.5%, just ora #$40
        ;A#1-D2
        .byte $00,$10,$01,$11,$02 ;$12(-3c) = $03(-1c)
        ;;D#2-A2
        .byte $03,$13,$04,$14,$05,$15,$06 ;$16 (+3c) = $07(-5c)
        ;A#2-D3
        .byte $07,$17,$08,$18, $28 ;<- D2 (-22c)
        ;D#3-F#3             ; G3,  G#3, A3
        ;                    ;-15c,-17c,-38c
        .byte $09,$19,$0a,$1a, $0b, $1b, $2b
            ; A#3 , B3, C4
            ;+10c,+9c,-12c
        .byte $0c,$1c;,$2c
            ; C#4, D4, D#4
            ;N/A,-7c,-8c

        .if Emit__Unused
            .byte $2c
            .byte $18,$0d,$1d,  $2d ;E4. VERY badly out of tune.
            ;     ;/\ Octave Down
        .endif

            ;Above D4 is Never used.
                ;Above As3 is Very Rarely used.

        dmc_overlap = LUT_dmc_d25_rates-Pre_25
            ;$0f

        py_Segment_End LUT_dmc_rates
    ;

    

    py_Segment LUT_dmc_length, Free
        LUT_dmc_length:
        .byte $05, $01, $04 ;25%
        .byte $04, $05, $01 ;12.5%
        .byte $01 ;50%, Double Volume, 2-17
        .byte $00 ;A single $00 Byte. Used to Ensure the DMC output remains low.
    
        py_Segment_End LUT_dmc_length
    ;

   

    ;Order is so the 17-1/17-2 are Instrucment 1 or 5,  and the 81s are 0/4 (Which show in debugger as just 1 and 0 respectively)
    py_Segment LUT_dmc_addr, Free
        LUT_dmc_addr:
        .byte <(DMC_Sample_9_81/64), <(DMC_Sample_2_17/64), <(DMC_Sample_8_65/64) ;25%
        .byte <(DMC_Sample_4_65/64), <(DMC_Sample_6_81/64), <(DMC_Sample_1_17/64) ;12.5%
        .byte <(DMC_Sample_Tri_Kick/64) ;$50%, Double Volume
        .byte <(Zero_Sample_Addr/64)

        DMC_d25_9_81 = 0
        DMC_d12_4_65 = 3 
        DMC_d12_1_17 = 5
        DMC_Tri =      6 
        Zero_Sample =  7

        py_Segment_End LUT_dmc_addr
    ;

    


;

