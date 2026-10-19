

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


        dmc_low_25 = Pre_25-LUT_dmc_rates+3 ;$e
        dmc_high_12_5 = dmc_low_25+dmc_overlap+3    ;$1d 
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

        .if Emit_MK64_Unused
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

    

    ;likely exmpale:
    ;.byte $02,$04,$05
    ;.byte $01,$00,$01 ;Lots of data overlap in the 12.5%
;


@Vibrato_Data:
    py_Segment LUT_Vibrato_NonRel_Data, Free
        LUT_Vibrato_NonRel_Data:
        .byte $7f,0,0,0,0,0,0 ;Hoot  
            ;Designed for +Octave

        .byte      8,12,8,       <-8,<-12,<-8          ;6v Fast
        .byte   8,12,12,8,       <-8,<-12,<-12,<-8     ;8v Medium
        .byte 4,8,12,12,8,4, <-4,<-8,<-12,<-12,<-8,<-4 ;12v Slow

            ;4,6,8,10,12 -4,-6,-8,-10,-12
            ;2,3,4,5,6   -2,-3,-4,-5,-6 ;+Octave
            ;1,1,2,2,3   -1,-2,-2,-3,-3
            ;0,0,1,1,1   -1,-1,-1,-3,-2 ;-Octave
            ;0,0,0,0,0   -1,-1,-1,-1,-1

        py_Segment_End LUT_Vibrato_NonRel_Data
    ;

    

    py_Segment LUT_Start_Vib_Index, Free
        LUT_Start_Vib_Index:
        .byte 0,  7,  7+6,  7+6+8

        LUT_End_Vib_Index:
        .byte 7+6+8+12

        py_Segment_End LUT_Start_Vib_Index
    ;

    

    py_Segment LUT_Vibrato_Delays, Free
        LUT_Vibrato_Delays:
        .byte <~0, <~8, <-16, <-28



            ;I want 8, 4, 2,  ZERO, not -1 
                ;Only way to do this is to explicit check for 2, and double lsr it.
                ; @loop:
                ;     cmp #2
                ;     bne @skip  
                ;         lsr
                ;     @skip:

                ;     asr
                ;     dey
                ;     bpl @loop

        ; .byte 1,3,1, <-1,<-3,<-1  ;6v Fast
        ; .byte 1,3,3,1, <-1,<-3,<-3,<-1 ;8v Medium
        ; .byte 1,2,3,3,2,1, <-1,<-2,<-3,<-3,<-2,<-1 ;12v Slow

        ;;.byte $06, $0e, $1a
        ;.byte $0e, $1a, $2a ;For testing longer Vibrato
        ;.byte 1,2,3,4,4,3,2,1, <-1,<-2,<-3,<-4,<-4,<-3,<-2,<-1 ;16v Very Slow
        py_Segment_End LUT_Vibrato_Delays
    
    ;    

    

;


Envelopes:   

    py_Segment Envelopes, Defines
    Duty_12 = %00
    Duty_25 = %10
    Duty_50 = %01
    Duty_75 = %11
    

    Vib_Inst = %00 << 2 
    Vib_16th = %01 << 2 
    Vib_8th =  %10 << 2 
    Vib_qtr =  %11 << 2 
    
    No_vib   =  $00 << 2
    Vib_Fast =  %01 << 2
    Vib_Med  =  %10 << 2
    Vib_Slow =  %11 << 2
    
    Vib_Hoot =  %00 << 2;Tri-SFX, A special over-ride case.


         ;AT Init----- |-------AT Rate------- |--Decay Init--| ----Decay Rate---- | ---Sustain---
    



    ;[NOTE] Release does not trigger until Sustain.

    Env_Bank ;3b Tri + Noise

        ;first index $0a

        Env_Index .set Env_Index + $0e ;Only a couple in the first bank

        First_3b_Env_Index .set Env_Index


        Env SFX_Hoot_M8, \
            $90 | Vib_Hoot, \
            $00, $00, \
            (-4 & $1f) << 3 | $00, \
            $00 | Vib_Inst, \
            $ff 
        ;No_Vib is over-written for this Env ID. Hardcoded check.


        ; Env Hat_Env, \
            ; $50,                            \
            ; $00, $00, \
            ; (-$4 & $1f) << 3,           \
            ; $00,                            \
            ; $ff
        ; 

        Env Shaker_env, \
            $d0,\
            $00, $00, \
            (-12 & $1f) << 3, \
            $00,\
            $ff
        ;

        ;Old MK64 Tri
            ; Env T_2f__d12, \
            ;     $10|Duty_12, $00, $00, \
            ;     (-4 & $1f) << 3 | $02, \
            ;     $10, \
            ;     dmc_high_12_5
            ;     ;m1 
            ; ;

            ; Env T_0f__d25, \
            ;     $10|Duty_25, $00, $00, \
            ;     (-4 & $1f) << 3 | $00, \
            ;     $10, \
            ;     dmc_low_25
            ;     ;m1
            ; ;


                ;All Replaced w/ m5_6f
            ; Env T_4f_m5__d25, \
            ;     $60 | No_vib | Duty_25, \
            ;     $00, $00, \
            ;     (-4 & $1f) << 3 | $4, \
            ;     $10 | No_vib , \
            ;     dmc_low_25
            ; ;4f_m5 meaning 4f cutoff, minimum 5f length.
        ;

    ;

    Env_Bank ;MK64 Primary
        ;YV Wistle, R Harmony
        Env Lead_25to12_v6, \
            $e0 | Vib_16th | Duty_25, \
            $00, $00, \
            (-$c & $1f) << 3 | $00, \
            $70 | Vib_Fast | Duty_12, \
            $ff  
            T_v6_0f .set Lead_25to12_v6
        ;no_dmc 

        Env Pad_sqr_4_0, \
            $40 | Duty_50, \
            $00, $00, \
            (-$2 & $1f) << 3 | $00, \
            $00 | No_vib |Duty_50, \
            $ff
            T_M6 .set Pad_sqr_4_0
        ;no_dmc

        First_DMC_Env_Index .set Env_Index

        Env Lead_25to12_s6_v8_2f, \
            $80 | Vib_qtr | Duty_25, \
            $00, $00, \
            (-2 & $1f) << 3 | $02, \
            $60 | Vib_Med | Duty_12, \
            dmc_high_12_5

            T_2f__d12 .set Lead_25to12_s6_v8_2f

        ;y

        Env Pad_sqr_s4, \
            $70 | Vib_qtr | Duty_50, \
            $00, $00, \
            (-$4 & $1f) << 3 | $00, \
            $40 | Vib_Med | Duty_50, \
            dmc_low_25

            T_0f__d25 .set Pad_sqr_s4
        ;y

        Env Choir_v12_1f, \
            $90 |Vib_qtr | Duty_50, \
            $00, $00, \
            (-$6 & $1f) << 3 | $01, \
            $50 | Vib_Slow | Duty_50, \
            dmc_low_25
            T_1f_12v__d25 .set Choir_v12_1f

        ;y

        Env Pad_d12_s3_v8, \
            $60 | Vib_8th | Duty_12, \
            $00, $00, \
            (-$4 & $1f) << 3 | $00, \
            $30 | Vib_Med | Duty_12, \
            dmc_high_12_5
            T_0f_v8__d12 .set Pad_d12_s3_v8

        ;y


        Env Pad_d25_8_3_v12, \  
            $90 | Vib_Inst | Duty_25, \
            $00, $00, \
            ( -4 & $1f) << 3 | $0, \
            $30 | Vib_Slow | Duty_25, \
            dmc_low_25
                ;Used by Countdown
            
        ;y

        ;Common d12 Lead
        Env Lead_d12_s7_v8_1f, \
            $b0 | Vib_qtr | Duty_12, \
            $00, $00, \
            (-$4 & $1f) << 3 | $01, \
            $70 | Vib_Med | Duty_12, \
            dmc_high_12_5

            T_1f_v8__d12 .set Lead_d12_s7_v8_1f
        ;y

        ;/\ No Decay Init / AT_Rate  ;Lead_25to12_v6 is also 3b. Exceeding Max

        First_5b_Env_Index .set Env_Index
            ;with 81-6, max double saves by overlaoding is only 10


        ;

        ;KTB Lead
        Env Lead_sqr_13_0, \
            $f0 | Duty_50, \
            (-$8 & $f) << 4 | $04, \
            $78 | Duty_50, \
            (-$3 & $1f) << 3 | $00, \
            $00 | Duty_50, \
            dmc_low_25
            T_M11__d25 .set Lead_sqr_13_0 

        ;y


        ;Common D25 Lead
        Env Lead_12to25_s6_v12, \  
            $c0 | Vib_16th | Duty_12, \
            (-$8 & $f) << 4 | $02, \
            $80 | Duty_25, \
            (-$1 & $1f) << 3 | $00, \
            $60 | Vib_Slow | Duty_25, \
            dmc_low_25 ;Battle Start via Riff.

        ;y

        ;Kalamari D25 Lead  (Otherwise a duplicate w/ 6f Release)  ;Its 5b is unneccesary, though I can't fit more.
        Env Lead_12to25_s6_v12_6f, \  
            $c0 | Vib_16th | Duty_12, \
            (-$8 & $f) << 4 | $02, \
            $7c | Duty_25, \
            (-$1 & $1f) << 3 | $06, \
            $60 | Vib_Slow | Duty_25, \
            dmc_low_25
            T_6f_m5_v12__d25 .set Lead_12to25_s6_v12_6f

            ;KD / CM Uses $06 Release as a 16th rest.
        ;y

        Last_DMC_Env_Index .set Env_Index 



        Env Pad_d75_8_0,\
            $c0 | No_vib | Duty_75, \
            (-6 & $f) << 4 | $04, \
            $60 | Duty_75 , \
            (-2 & $1f) << 3 | $00, \
            $00 | Duty_75 ,\
            $ff ;dmc_low_25 ;Battle Start alone.
        ;n?


        ;Banjo
        Env Pad_d12_6_0, \
            $b0 | Duty_12, \
            (-$8 & $f) << 4 | $03, \
            $48 | Duty_12, \
            (-$1 & $1f) << 3 | $01, \
            $00 | Duty_12, \
            $ff  
        ;n

        ;TT_Lead
        Env Lead_12to25_4_11_3_v12, \
            $30 | Vib_16th | Duty_12, \
            (+$7 & $f) << 4 | $04, \
            $c0 | Duty_25, \
            (-$1 & $1f) << 3 | $00, \
            $30 | Vib_Slow | Duty_25, \
            $ff
        ;n
        Hat_Env .set Lead_12to25_4_11_3_v12 ;Hat Plays for 1f at Volume 4.  This duplicates behavior

        ;BC Lead
        Env Lead_d25_2_9_6_v12, \  
            $20 | Vib_8th | Duty_25, \
            (+$2 & $f) << 4 | 11, \
            $90 | Duty_25, \
            (-$1 & $1f) << 3 | $00, \
            $60 | Vib_Slow | Duty_25, \
            $ff
        ;n

        ;Raceway Lead
        Env Lead_d12_12_0, \
            $d0 | No_vib | Duty_12, \
            (-4 & $f) << 4 | $5, \
            $40 | Duty_12, \
            ( -1 & $1f) << 3 | $0, \
            $00 | No_vib | Duty_12, \
            $ff
        ;n

    ;

    Env_Bank ;5b SFX
        Env Crash_env, \
            $d0,                            \
            (-7 & $f) << 4 | $3, \
            $6c,                            \
            (-$01 & $1f) << 3 | $0,        \
            $00,                            \
            $ff

                ;Can Tune the $6c/$70 etc for a smoother ramp.
        ;n

        Env Snare_env, \
            $c0 | Duty_50,                            \
            (-$8 & $f) << 4 | $3,        \
            $60 | Duty_50,                            \
            (-$04 & $1f) << 3, \
            $00,                            \
            $ff
        ;n

        Last_Sustain_Index .set Env_Index
        Last_Decay_Rate_Index .set Env_Index


        Env Pre_Cymbal_env, \
            $20, \
            (+$1 & $f) << 4 | $e, \ 
            $00, \
            $00, \
            $00, \
            $ff


            ;Instantly Silences after 14f. That can be smoothed out.

                ;Rare case of need AT_Init, cuz Decay Init can only Fade.
                    ;Also Rare case of Sustain never being Read.
                        ;Noise doesn't need vibrato

                        ;Likely Doesn't Need Decay Rate either.
                            ;With "Decay Init" already silenced, Rate and Cutoff can't do anything.
        ;n



    ;


    

    ;Env_Bank ;Other Music


        ; Env Lead_25to12_s6_v6, \
        ;     $d0 | Vib_Inst | Duty_25,      \
        ;     (-$4 & $f) << 4 | $03,       \
        ;     $90 | Duty_12,                 \
        ;     (-$00 & $1f) << 3 | $00,       \
        ;     $90 | Vib_Fast | Duty_12,      \
        ;     $ff

        ; Env Pad_12to25_v12, \
        ;     $b0 | Vib_Inst | Duty_12,       \
        ;     (-$5 & $f) << 4 | $03,        \
        ;     $60 | Duty_25,                  \
        ;     (-$00 & $1f) << 3 | $01,        \
        ;     $60 | Vib_Slow | Duty_25,       \
        ;     $ff

        
        
        ; Env Harmony_sqr_v8, \
        ;     $b0 | Vib_Inst | Duty_50,       \
        ;     (-$6 & $f) << 4 | $03,        \
        ;     $60 | Duty_50,                  \
        ;     ($00 & $1f) << 3 | $00,        \
        ;     $60 | Vib_Med | Duty_50,        \
        ;     $ff

        ; ;
        ; ;


        ; ;
        ; Env Echo_sqr, \
        ;     $70 | Duty_50, \
        ;     (-$2 & $f) << 4 | $0b, \
        ;     $60 | Duty_50, \
        ;     (-$02 & $1f) << 3 | $00, \
        ;     $10 | No_vib | Duty_50, \
        ;     $ff

        ; Env T_12v_3f, \
        ;     $f0 | Vib_qtr, \
        ;     $00, $00, \
        ;     $03,\
        ;     $f0|Vib_Slow,\
        ;     $ff


        ;   
        ;
        


        ;Other Games
            ; Env Metroid_Sweep, \
            ;     $a0,                            \
            ;     (-$8 & $f) << 4 | $3,        \
            ;     $40,                            \
            ;     (-$1 & $1f) << 3 | $0,        \
            ;     $00,                            \
            ;     $ff

            ; Env Tamberine_env, \
            ;     $90,\
            ;     (-$1 & $f) << 4 | $c, \
            ;     $60,\
            ;     (-$2 & $1f) << 3, \
            ;     $00,\
            ;     $ff

            ; Env Sweep_env,\
            ;     $a0,\
            ;     (-$8 & $f) << 4 | $3, \
            ;     $40,\
            ;     (-$4 & $1f) << 3, \
            ;     $00, \
            ;     $ff

            ;From Metroid
            ; Env Lead_d25_14_0_2f, \
            ;     $f0 | Duty_75, \
            ;     (-$8 & $f) << 4 | $03, \
            ;     $90 | Duty_75, \
            ;     (-$5 & $1f) << 3 | $02, \
            ;     $10 | No_vib |Duty_75, \
            ;     $ff
            ; ; 

            ; Env Lead_sqr_v12_s4_a11, \
            ;     $10 | Vib_qtr | Duty_50, \
            ;     (+$2 & $f) << 4 | $0f, \
            ;     $b0 | Duty_50, \
            ;     (-$1 & $1f) << 3 | $00, \
            ;     $40 | Vib_Slow | Duty_50, \
            ;     $ff

    ;



    ;Format
    
    
    
    
    ;AT_Init_Format:
    ;%VVVV II dD
        ;II = Vibrato ID. (vv is 0-ed for Attack.)
        ;dD = Duty Cycle bits. (The bits are stored backwards, ie, %01 means 50% Duty.)
        ;V = Volume. [NOTE] it is decayed before used.


    ;AT_Rate_Format:
    ;%SRRR tttt 
    ;R= Attack Rate (Range +1.75 to -2.0 /f)
    ;t = Frames Duration of Attack  (==0 Skips AT_Rate and Decay_Init)

    ;Decay_Init_Format:
    ;%VVVV vv dD
        ;Set Volume/Duty to this after Attack finishes
            ;Volume can be disjoint. (For echoing effect, or for a massive 1f Volume drop.)
        ;v = vol_fraction
            ;Usefull here to have more lee-way to work low sustains.

        ;dD = New Duty bits
 
    ;Decay_Rate_Format:
    ;%RRRRR ttt 
    ;R= Decay Rate (Range +1.75 to -2.0 /f)
    ;t = frames at end to silence. (Cut Off Timer)


    ;Sustain_Format:
    ;%VVVV II DD

        ;II = Vibrato Speed. 

    ;cmp it. If quieter, store Sustain instead

    ;DMC_Type:
        ;$Midi of Lowest 25% Duty Note.
            ;As full Byte vastly Simplifies Code.

    py_Segment_End Envelopes
;


Nibble_Read_Mode:

    py_Segment LUT_Read_Nibbles_Init, Free

        ;Format:
        ;%yyy xxxxx ;32 Bytes for 15 Lines, with a 16th able to spill over the edge. That's gonna be tight.
        ;y = Bytes to read ;1-7 (0 would disable it?)
        ;x = starting index

        LUT_Read_Nibbles_Init:
            Duration_List Emit_LUT ;Macro

        py_Segment_End LUT_Read_Nibbles_Init

    ;

    py_Segment LUT_Length_Nibbles, Free
        LUT_Length_Nibbles:

        adr_00:
        adr_0000:
        adr_6x0:
        adr_8x0:
        .byte $00,$00,$00,$00

        adr_1111:
        adr_6x1:
        adr_8x1:
        .byte $11,$11,$11
        adr_111_R:
        .byte $11, $91  ;$9- is repeat "3b" or "2b"

        adr_2222:
        adr_6x2:
        adr_8x2:
        .byte $22,$22,$22,$22

        adr_4444:
        .byte $44,$44;,$44,$44

        adr_6x8:
        adr_8x8:
        .byte $88,$88,$88,$88




            ;Koopa Beach
        adr_0_00_0_Es: ;$e0, $e0,$0  -e, $0e
        .byte $0e 
        adr_00_0_0_4_Es: ;$e0,$0  -e,$0 -e,$b0 $e4
        .byte $0e, $e0, $e0, $0b, $4e


        .assert (*-LUT_Length_Nibbles)<$20, error, "Duration Lengths don't fit."
            ;This can be before the last one.



                ;Khevari Stuff
        ; adr_11_100_x2:
        ; .byte $11,$01,$10,$11 ;,$00   ;1&-2&a-3&-4&a (Noise)

        ;     adr_111_221:
        ;     .byte $11,$21,$12 ;1& 2& -& -&

        ;     adr_111_2_111_b:
        ;     .byte $11,$21,$11,$b1 ;1& 2&- &4& 
        ;         ;Ends w/ a base note shift so that it can do it for free if needed. (And $b0 is NOP.)

        ;     adr_332_x2:
        ;     .byte $33,$32,$23 ; 3-3-2 | 3-3-2 (sq1)

        ;     adr_f_0000_f_1001:
        ;     .byte $0f,$00,$f0,$01,$10 ;(sq0-C) ;$f-,1e&a,$f-,-2&a-3    
        ;         ;The two fs are to drop the Octave, then raise back up.
        py_Segment_End LUT_Length_Nibbles

    ;
;

     
Song_List:  ;LUT_Song_Header: ;Format ;11 bytes/song

    py_Segment Song_List, Free
        Song MK64_Title,      6   ;245 B   ;D50 Kick?
        Song MK64_Menu,       6+7 ; 92 B  ;torn on Kick

        Song Race_Start,      15   ;wants to be 2+3   ;7+8 ;7 ;Wants to be 7+8

        Song Raceway,         6   ;300 B
        Song Yoshi_Valley,    7   ;500 B ;(too fast. Should be 6+7, but lots of awkward 16ths.) ;Manually fix by my idea for speeding up for 3rd lap  
        Song Koopa_Beach,     7+8 ;300 B
        Song Kalamari_Desert, 7+7 ;216 B
  
        Song Toads_Turnpike,  6+7 ;300 B
        Song Frappe_Snowland, 7   ;300 B
        Song Choco_Mountain,  6   ;500 B

        Song Bowsers_Castle,  7+8 ;150 B  ;d50 sounds GOOD
        
        Song DKs_Jungle_Parkway, 7
        Song Banshee_Boardwalk, 9   ;150 B    
        Song Rainbow_Road, 6+7    ;350 B
            
        Song Star_Power, 6 ;68 B  ;Wants to be 5+6
        
        Song Finish_1st, 8  ;wants to be 9+8
        Song Finish_2nd4th, 8 ;also wants to be 9+8
        Song Race_Results, 5+6
        Song Award_Win, 12 ;259 B

        Song Lose_Race, 9+9
        Song Award_Lose, 8


        Song Battle_Start, 6
        Song Battle, 7 ;300 B
        Song Battle_Results, 8  ;164 B    ;wants to be 7+8

        Song Staff_Roll, 7+7 ;Re-uses some of RR

        Max_Track_Index = Song_Index-1

        Song_Silence_Index = Song_Index
        Song "Silence" ;For B-Press = Mute.

    
            Output_All_Songs  ;Macro

        py_Segment_End Song_List
    ;
;

