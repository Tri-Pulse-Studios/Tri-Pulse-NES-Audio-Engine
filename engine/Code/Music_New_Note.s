py_Segment Pre_New_Note, Free
 
    .macro Read_Instruction
        lda Read_by_Nibble_Flag,x
        beq @Normal_Read        ;Should be $00 When Not active


            @Read_by_Nibble:
            ;lda Read_by_Nibble_Flag,x
            lsr                     ;-> C Reading Upper/Lower nibble.

            dec Read_by_Nibble_Flag,x ;Acts like eor #$01, AND a timer together.

            ;Operand
            lda (Note_Data,x)       ;$PP, $PP  ;Carry picks which Pitch to read.
            bcc @skip               ;<- C

                inc Note_Data,x     ;Inc only after reading both nibbles.
                lsrn 4              ;Read low nibble first, then high. (Yes, Right to Left
                sec                 ;Restore Carry

            @skip:
            and #$0f               
            sta irq_tmp_3

            ;Opcode
            ldy Length_Nibble_Index,x
            lda LUT_Length_Nibbles,y ;$LL, $LL  ;Carry picks which Pitch to read

            bcc @skip2              ;<- C

                inc Length_Nibble_Index,x
                lsrn 4
                sec                 ;Restore Carry for RAM-less 16ths.

            @skip2:
            and #$0f
            bne Not_16th_Length

                ;beq @_16th_Length
                @_16th_Length: ;CARRY MUST BE PRESERVED.
                    lda Eighth_Length       ;<-C
                    adc #$00                ;If _8th is odd, and SEC, will round Up.
                    lsr                     ;Otherwise, rounds down.

                jmp Store_Duration  ;bal Store_Duration, bpl  ;Not in Range
        ;



        @Normal_Read:
            lda (Note_Data,x) ;Operand
            If_Alt_Read_Instruction_Insert:
            and #$0f
            sta irq_tmp_3

            lda (Note_Data,x) ;Opcode
            inc Note_Data,x
            lsrn 4

        Not_16th_Length:
        tay

        ; rts
    .endmacro

    ;Returned from a Riff 50cc
    ;Normal instruction Read 60cc
        ;Repeat 60cc +60cc for another instruction read
        ;Enter Riff 100cc  +60cc
        ;Init Nibble 70cc  +80cc   for read Nibble-Instruction

        ;Execute Note: 100cc

        ;So ~150cc per instruction


    ;Tri execute note took 250cc to execute note
    ;Reset Env takes additional 100cc

    ;other instrcutions average ~150cc including reading the instruction.

    ;Update SFX is ~300cc


    .macro Reset_F_Effects
        lda No_Reset_F_Effects_Flag,x
        ora No_Reset_Env_Flag,x 
        bne @skip

            ;lda #$00 
            jsr Reset_Volume_Damping ;These reset per note (DMC only uses it for multi-note fades.)
            
        
        @skip:
            ;0 out sweep speed here too, and any other F-Effects.
    .endmacro



    .macro Check_Riff_Return
        @Check_Riff_Return:
        ldy Riff_Depth,x

        tya
        and #$07 ;Max Depth.
        beq @Not_Returned

            lda Note_Data,x
            cmp Riff_Ends_At -1,y ;y=0 is "in root" 
            bcc @Not_Returned

                lda Riff_Returns_To -1,y
                sta Note_Data,x
                inc Note_Data,x ;like how jsr pushes -1

                dec Riff_Depth,x 
                rts

        @Not_Returned:
    .endmacro

    

    Pre_New_Note:
    Inline Reset_F_Effects


    New_Note:
        lda #>(New_Note-1)
        pha
        lda #<(New_Note-1) 
        pha ;rts = jmp New_Note

        Inline Check_Riff_Return

        Inline Read_Instruction ;OUT: Y = Opcode, irq_tmp_3 = Opperand

        Music_Dynamic_Jump:
        lda #>(All_Music_Opcodes-1)
        pha
        lda LUT_Music_Opcodes_Low,y
        pha

        lda irq_tmp_3 ;Opperand. Most use it immediately.
    rts ;dynamic jmp
;

py_Segment_End Pre_New_Note




;Another rts will return back to New_Note.
;




py_Segment LUT_Music_Opcodes_Low, Free
    .assert >(Misc_FXs -1) = >(Special_Length - 1), warning, "Not All Music Instructions fit in a Page."
        ;This is presuming that Special Length is stored last, and Misc Sfx stored first.

    LUT_Music_Opcodes_Low:
    .byte <(Special_Length - 1)   ; Special = 0 [NOTE] Hardcodes to 16th-Length during Nibble-Read.
    .byte <(Add_8ths - 1)         ; Eighth = _8th
    .byte <(Add_8ths - 1)         ; Quarter 2*_8th
    .byte <(Add_8ths - 1)         ; Dotted Quarter 3*_8th

    .byte <(Add_8ths - 1)         ; Half 4*_8th
    .byte <(Duration_Mode_Init - 1)    ; Read-by-Nibble Mode. 
    .byte <(Add_8ths - 1)         ; Dotted Half 6*_8th
    .byte <(If_Alt_Instruction - 1) ;7   ;Alt-If 

    .byte <(Add_8ths - 1)         ; Whole 8*_8th
    .byte <(Repeat_Instruction - 1)                     ; Repeat 2-3 Bytes
    .byte <(Repeat_Instruction - 1) ;A = repeat Again   ; Repeat 4-5 Bytes
    .byte <(Shift_Base_Pitch - 1) ;B = Base pitch change

    .byte <(Riff_Call_Short - 1) ;C = Call riff  ;Re-read  3-16 bytes
    .byte <(Riff_Call_Medium - 1)                ;Re-read 17-32 bytes
    .byte <(Change_Envelope - 1) ;E = Env change
    .byte <(Misc_FXs - 1) ;F = misc eFfects

;
py_Segment_End LUT_Music_Opcodes_Low



py_Segment LUT_Misc_FXs_Data, Free
    LUT_Misc_FXs_Data:

        ;Macros that assign Misc Effect Indicies and Data.

            ;SFX_Index .set $f8
        SFX_Type Init_Sweep   ;Reads (Note_Data,x)
        SFX_Type Set_Env_Bank_Byte

                SFX_Type_Offset .set (SFX_Type_Index & $0f)

        SFX_Type Tie_Next_Note, $40
        SFX_Type Clear_Special_Effects, 0

        SFX_Type Plus_Octave, 12
        SFX_Type Minus_Octave, <-12

            ;Common_FadeOut
        SFX_Type Common_Fade_Out,    13 << 3 | Vol_12
        SFX_Type Inc_Page_Byte ;manual lda (Note_Data,x)
        


      ;Format of Volume:
        ;%11110vvv, %DDDDDVVV  //  $fv,$DV

            ;v = Set Init Volume
            ;V = Target Volume.  0 = Full,  1 = -1/8th  4 = Half, 7 = Near Silenced
            ;D = Delay,  every 1-31f,  inc/dec volume toward Target Volume
;
py_Segment_End LUT_Misc_FXs_Data



py_Ignore

    .align 256

    ;Push toward end of page.
    .if Note_Volume_Damped < $100 ;if is ZP

        .res $c0  ;$d2 - $ff as zp 

    .else
        .res $b0 ;$c5 - $d7 as abs

    .endif

py_Ignore_End

;[WARN]  I made these ranges up. Py can compute them via two Print PCs, but its harder to describe. 
 ;Can have an error check .assert space range is valid. (Is accurate will be annoying to pop up constantly.)

py_Segment Reset_Channel_and_F_Effects, IndexRange, $d2, $fe 
 
Reset_Channel:
    txa     
    lsrn 2 ;A = 0..4

    add Song_Pointer, clc ;ID*5 + 0..4 
    tay

    lda LUT_Song_Ptr_Low,y
    sta Note_Data,x

    lda LUT_Song_Ptr_High,y
    sta Note_Data_High,x 
 

    jsr Set_BP_and_Vibrato_Depth ;First Byte, Init like a Set Pitch


    cpx #$0c
    beq @skip ;Noise Sets Env w/ SFX Engine.
                    ;Not only not needed. It causes a problem when a loop would corrupt a Crash's Envelope.

        lda (Note_Data,x)
        inc Note_Data,x     
        sta Note_Env_ID,x ;Full Note_Envelope + Env_Bank
        
    @skip:

    txa
    asl ;Range 1..7,  0 = In Root
    sta Riff_Depth,x


    lda #$01
    sta Note_Timer,x ;Set so Channel will start over on its first unpaused update.

    sta Ignore_If_Alts_Flag,x  ;Ignore by Default.
    

    lda #$00
    sta Note_Volume,x ;Noise Channel may not initialize.

    sta Read_by_Nibble_Flag,x ;Ensure reading whole Bytes.
    sta Repeat_Counter,x ;Ensure not Repeating.

    sta No_Reset_Env_Flag,x ;Ensure Volume is 100% 

    
    
    


;jmp Func_Clear_Special_Effects  ;Tail-Call ;After Reset doesn't do Pre-New-Note, so must manually reset damping.
    ;OUT A = 0

;Misc Effect branch backs.

    Func_Clear_Special_Effects:
        ;lda #$00 ;Max Vol
            .assert Vol_100 = 0, error, "lda #$00 must be lda #Max_Vol"
        
        sta No_Reset_F_Effects_Flag,x

        Reset_Volume_Damping:
        sta Sweep_Speed,x ;Common JSR Entry
        sta Note_Volume_Damped,x
        sta Volume_Target,x
    rts


    ;In A= (Note_Data,x)
        ;Y = Opperand
    Set_Volume_w_Custom_Ramp:

        sec
        rol No_Reset_F_Effects_Flag,x ; != 0 Activates. (Disables Reseting for Multi-Note Fades.)

        ;sty Note_Volume_Damped,x 
        .if Note_Volume_Damped < $100 

                ;if is ZP
                sty Z:Note_Volume_Damped,x 

            .else
                pha
                tya 
                sta A:Note_Volume_Damped,x 
                pla

        .endif


        Common_Fade_Out_Code: ;<- Auto Clears at Note's End
        tay
            and #$07
            sta Volume_Target,x

        tya
            lsrn 3
            sta Volume_Timer_Reload,x
            sta Volume_Timer,x
    @rts:
    rts




    Func_Inc_Page: ;$ff
        jsr Riff_Jmp_To ;lda (Note_Data,x) ;
                        ;sta Note_Data,x 

        inc Note_Data_High,x
    rts

    

    Set_BP_and_Vibrato_Depth:
        lda (Note_Data,x)
        and #$03
        sta Vibrato_Depth,x ;For Noise, Kick ID

        lda (Note_Data,x)
        inc Note_Data,x
        lsrn 2
        sta Base_Pitch,x 

    rts

;

    Loop_Song: 
        lsr 
        bcc Reset_Channel ;Tail-Call

            @Two_Byte_Loop:
            lda (Note_Data,x)
            pha

            jsr Reset_Channel ;Re-init Everything.

            pla
            sta Note_Data,x ;Jump to End of Intro.
    rts

All_Music_Opcodes: 
    ;
        ;$f-:
    Misc_FXs:

        tay
        ;beq Func_Clear_Special_Effects ;Idea
        lda LUT_Misc_FXs_Data - SFX_Type_Offset,y ;Only the last few need data.


        cpy #(Common_Fade_Out & $f)
            beq Common_Fade_Out_Code ;$fe
            bcs Func_Inc_Page ;$ff

        cpy #(Plus_Octave & $f)
            beq @Up_Octave ;$fc
            bcs @Down_Octave ;$fd

        cpy #(Tie_Next_Note & $f)
            beq @Tie_Next_Note ;$fa
            bcs Func_Clear_Special_Effects ;$fb
        

        lda (Note_Data,x)
        inc Note_Data,x

        cpy #(Init_Sweep & $f)
            bcc Set_Volume_w_Custom_Ramp ;$f0-$f7
            
            bne Func_Set_Env_Bank ;$f9
            ;beq @Init_Sweep ;$f8


            ; @Init_Sweep: 
                sta Sweep_Speed,x
            rts


            @Tie_Next_Note:
                ;lda #$40
                ora No_Reset_Env_Flag,x ;May be $80 already.
                sta No_Reset_Env_Flag,x
            rts
            
            @Down_Octave:
                ;lda #<-12
                dec Vibrato_Depth,x
                bpl Octive_Pitch_Shift
                    ;If underflowing to deeper than Vib_Deep, remain there.

            @Up_Octave:
                ;lda #12
                inc Vibrato_Depth,x
                bal Octive_Pitch_Shift, bpl
            ;       ;Overflowing Vib_Very_Shallow is uninituitive.


            ;

        ;



    ;



        ;$e-:
    Change_Envelope: ;
        eor Note_Env_ID,x
        and #$0f
        eor Note_Env_ID,x ;OR-in the Env_Bank

        Func_Set_Env_Bank:
        sta Note_Env_ID,x
        rts
    ;


        ;$c-/$d-:
    Riff_Call_Medium:
        ora #$10 ;bit 5 of operand.

        Riff_Call_Short:
        cmp #$02
        bcc Loop_Song ;$c0/$c1

        bne @2_Byte_Call

            ;beq @Riff_Call_Long ;$c2

            @Riff_Call_Long:
            lda (Note_Data,x) ;Riffs longer than 32 Bytes Need a third byte.
            inc Note_Data,x


        @2_Byte_Call:
        inc Riff_Depth,x
        ldy Riff_Depth,x

        .if Debugging_Enabled
            pha
                lda Riff_Depth,x
                and #$07
                cmp #$07
                bcc @valid ;Riff Depth 1..6,  0 = In Root.
                                ;Can Expand to 1..8 just needs a different check.
                cmp $800c
                .byte $02 ;Riff Depth Overflow

                @valid:
            pla
        .endif

        ;A = bytes to read in Riff
        clc
        adc (Note_Data,x) ;Riff_jsr_address
        sta Riff_Ends_At -1,y 

        lda Note_Data,x ;pha PC 
        sta Riff_Returns_To -1,y 

        Riff_Jmp_To:
        lda (Note_Data,x) ;Riff_jsr_address
        sta Note_Data,x 
        rts 
    
            ;c0 ->    ;Loop Song
            ;c1, $yy  ;Loop Song, Intro jmp to $yy

            ;c2, $xx, $yy ;Read $xx Bytes at $yy

            ;$c3 - $df, $yy read $03-$1f Bytes at $yy 


    ;

            ;$b-:
    Shift_Base_Pitch:
        cmp #$08

            beq Set_BP_and_Vibrato_Depth ;Tail_Call

        @Shift_Pitch:
        bcc @pos ;$01..$07

            ora #$f0  ;$ff..$f9
                ;could  add $f0 -1, sec
                    ;Problem is Octave Shifts don't follow.

        @pos:
            Octive_Pitch_Shift: ;In A = +/-12
        add {Base_Pitch,x}
        sta Base_Pitch,x
        rts


        ;$b0 = NOP (Needed for If_Alts)
        ;$bx = Add x to BP (Range, +/- 7)
        ;$b8, $xx = Set BP to x


    ;



        ;$9-/$a-:
    Repeat_Instruction: ;Takes in Y=Opcode
        
        lsr ;-> C  (back an extra byte if clc)
        bne @skip

            lda (Note_Data,x)
            inc Note_Data,x
            ; A= Repeat Count
                ;[WARN] This decreases the Bytes repeated by One. (This Byte is included in that repeat count.)

        @skip:
        dec Repeat_Counter,x     
        beq @Done_Repeating
            bpl @skip_init

                ;Decs from 0 to -1 on first encounter.
                sta Repeat_Counter,x
                    ;Then decs from Count to 0. 
                        ; Dec -> 0 meaning done repeating.

            @skip_init:
            lda Note_Data,x
            sbc @LUT_Branch_Offsets-9,y ;<- C  
            sta Note_Data,x

        @Done_Repeating:
        rts 

        @LUT_Branch_Offsets:
        .byte $03, $05 
            ;Y=$9, Y=$a ; Y = Opcode
            ;2/3  4/5


    ;


        ;$7-:
    If_Alt_Instruction:
        tay ;-> tmp
        beq @Toggle_Flag
        

        @If_Alt_Instruction:
            lda Ignore_If_Alts_Flag,x
            lsr
            bcs @rts

                tya ;<- tmp. Alt Operand Delta.
                add {(Note_Data,x)}, clc
                jmp If_Alt_Read_Instruction_Insert


        @Toggle_Flag:
            inc Ignore_If_Alts_Flag,x ;inc toggles bit 0. The other 7 bits are ignored.
                
        @rts:
        rts


        ; Give the next instruction's opperands an alternate version.
        ;     Select one via the flag toggle-able w/ $70
        ;         Used for two channels playing the same melody-harmony.

        ;[WARN] Acts like a 2-byte Note. The bytes are NOT Riff-Splitable.
            ;Also Incompatable w/ Duration

    ;


        ;$5:
    Duration_Mode_Init:
        tay
        lda LUT_Read_Nibbles_Init,y

        ; Lower 5 bits = LUT index for length pattern
        and #%00011111
        sta Length_Nibble_Index,x

        eor LUT_Read_Nibbles_Init,y ;lda, and #%1110 0000
        lsrn 4 
        sta Read_by_Nibble_Flag,x ;%---- LLL0
        ;A = Total Nibbles to read  ($2-$e)

        rts
        ;16 preset Length Opcodes, re-assemble full byte on the fly

        ;Notes are Normally:  $LP, $LP, $LP, $LP   ; L = Length, P = Pitch
            ;This strips the Length Nibble out, compressing to $5X, PP, $PP
                ;The Lengths are then fetched from a small LUT of common patterns  (ie: dqt,dqt,qtr // 8th,8th....)

    ;

    ; Non_LUT_Duration_Init:
        ;     tay 

        ;     lda #$10 ;whl << 1

        ;     @loop: ;div 3
        ;         lsr ; -> C

        ;         deyn 3 
        ;         bmi @exit ; Y = -1 .. -3

        ;         bcc @loop ;On A == 0 and Y == 0, exit.


        ;     @exit:
        ;     sta Dur_Opcode,x ;A = 8, 4, 2, 1, or 0

        ;     dey
        ;     tya
        ;     asl
        ;     sta Read_by_Nibble_Flag,x ;-2 .. -4 *2 (Or -1 w/ Opcode 0)
        ; rts

        ; Non_LUT_Duration_Read:
            ; lda Read_by_Nibble_Flag,x
            ; beq @Normal_Read        ;Should be $00 When Not active

            ;     @Read_by_Nibble:
            ;     ;lda Read_by_Nibble_Flag,x
            ;     lsr                     ;-> C Reading Upper/Lower nibble.

            ;     inc Read_by_Nibble_Flag,x ;Acts like eor #$01, AND a timer together.

            ;     ;Operand
            ;     lda (Note_Data,x)       ;$PP, $PP  ;Carry picks which Pitch to read.
            ;     bcs @skip               ;<- C

            ;         inc Note_Data,x     ;Inc only after reading both nibbles.
            ;         lsrn 4              ;Read low nibble first, then high. (Yes, Right to Left
            ;         clc                ;Restore Carry

            ;     @skip:
            ;     and #$0f                ;Required as 16th doesn't respond to If_Alt
            ;     sta irq_tmp_3

            ;     ;Opcode
            ;     ldy Dur_Opcode,x
            ;     bne Not_16th_Length

                ;14B less code
                ;25B less in LUT.

                    ;Downside is limited Duration Types. 

            ; Operand 0-f is 8x8, 6x8, 4x8, 4s, 2s, 1s, 0s, _00 = $5f

    ;

        ;$1-/$8-:
    Add_8ths:
        lda #$00
        ;ldy opcode

        @loop_add_8th:
            add Eighth_Length

            dey 
            bne @loop_add_8th 

        bal Store_Duration, beq ;@exit_loop

    ;Out A= _8th*Y


        ;$0-: 
    Special_Length:
        ;.assert (<(Special_Length - 1) < $fc), warning, "Special_Length is past $XXfc"

        lda (Note_Data,x) 
        inc Note_Data,x   
        ;jmp Store_Duration

        ;Any Unique Length can be stored, but it costs an extra byte.
        ;[NOTE] Duration Hardcodes these to 16ths (Auto-Rounds)

    ; Out A= Length


    .macro Reset_Envelope
        ldy Note_Env_ID,x


        ;AT Duration
            lda LUT_Env_AT_Rate,y  
            and #$0f ;== 0 Skips Decay_Init Entirely.
            sta Note_Env_Timer,x

        ;Volume
            lda LUT_Env_AT_Init,y 
            and #%11110011 ;VVVV -- DD 
            sta Note_Volume,x ;and Duty

        ;Vibrato Delay Factor  (Noise/Dmc Never Reads This.)
            eor LUT_Env_AT_Init,y ;---- II -- 
            ;and #$0c
            lsrn 2
            tay  ;-> TRASHES ENV ID

            lda LUT_Vibrato_Delays,y 
            sta Vibrato_Timer,x
    .endmacro


    Store_Duration:
        sta Note_Timer,x

        ;Calculate_Pitch:
        pla
        pla ;clear rts = jmp New_Note

        asl No_Reset_Env_Flag,x ;Destructive Read. Set as $40 -> $80=No Env Release -> Sec=No_Reset_Env
        bcs @skip

            cpx #$0c
            beq @skip ;Noise Handles all Env via SFX Engine

            Inline Reset_Envelope 
        @skip:


        lda irq_tmp_3 ;Note Opperand.
        bne Calc_Pitch

            @Rest:
            ;lda #$00
            sta Note_Volume,x
            Rest_RTS:
            rts



        Calc_Pitch:
        add {Base_Pitch,x} ;For noise, essentially a Bank selector.
        ;and #$3f ;Clear Octave Flags.

        cpx #$0c
        bcc sq_tri_pitch
        beq noise_sfx
        ;bcs @dmc_rate ;dmc is x = $10


        ;A= Note Midi
        dmc_rate:
            sta DMC_MIDI

            ldy SFX_Timer+$10 ;If SFX Playing, queue for restart only.
            bne Rest_RTS

            
            ldy Note_Env_ID,x
            cmp LUT_env_dmc_lowest_25_pitch,y 

            bcc @d12
                
                @d25:
                add #dmc_overlap -1, sec

            @d12:
            tay
            lda LUT_dmc_rates-3,y ;-3 syncs data w/ Normal Notes' 
        
            
            .if Debugging_Enabled
                bpl @skip_debug
                .byte $02 ;stp. Bit 7 must be clear. (Read either garbage, or the hole at C#4)
                cmp $6005
                @skip_debug:
            .endif
            
            pha
                ora #$70 ;Loop
                sta DMC_Rate ;Must write %01--rrrr  ;bit 7 MUST be 0 (Or IRQs. Bad.)
                                        
            pla
                lsrn 4
                tay ;DMC Sample ID

            jmp Prime_DMC ;bal Prime_DMC, bpl ;Not in Range.
        ;Tail-Call Returns from New_Note


        noise_sfx:
            sta APU_Init_Noise ;Seems to just be Write Anything To Enable. Write FX ID. Why not.

            tay 
            lda SFX_Queued+$10  ;Needed for full game only.
            bne @skip_DMC

 
                lda LUT_DMC_SFX_Ptr-1,y 
                bpl @Hardcoded

                    ;Kick selector
                    ldx Vibrato_Depth +$c  ;Init w/ Set_BP 0..3
                    lda LUT_Kick_Ptr,x
                    ldx #$0c ;Restore

                @Hardcoded:
                sta SFX_Queued+$10 ;If A = $00 Init nothing.
                

            @skip_DMC:


            lda LUT_Noise_SFX_Ptr-1,y ;-1 cuz 0 is hardcoded as rest via engine. 
            bpl @simple_sfx
                    ;bmi @musical_note ;as in handled by the RAM for notes, not for sfx.

                    ;[WARN] All Complex NoiseFX must have Sustain 0 env. (The Timer is Ignored)
                    @complex_sfx:
                    dex
                    jsr Init_SFX ;[WARN] Default behavior overwrites the Note_Timer for Secondary.
                    inx
                    ;Forcibly start new Musical SFX, regardless of current playing.
                
                rts 


            @simple_sfx:
            ldy SFX_Queued+$c ;This is shared by In-game sfx. Needs to not overwrite the queue.
            bne @Noise_queued 
            
            sta SFX_Queued+$c

            @Noise_queued:
        rts ;Return from New_Note


        sq_tri_pitch: ;RE-USED BY SFX
                ;Takes ~ 22*(N+2) cycles. Where N is octave. (~ scanline for C4)

            jsr sq_tri_calc_period
            sta Note_Period_High,x  

            lda irq_tmp_1 ;tmp_period_low
            adc #$80 -1  ;<- C 

                ;adc #$00 ;<- C for rounding

                ;eor #$80 so bvc works for vibrato/sweep

                ;add #<-1 to fix period off-by-one quirk

                    ;combined its just adc #$7f
            sta Note_Period_Low,x
            ;jmp Note_Conditional_Write_Period_High

    ;Fall-Through Returns from New_Note




    Note_Conditional_Write_Period_High:
        .if Emit__Unused
            lda SFX_Timer,x
            bne @rts
            
            .elseif Debugging_Enabled
                lda SFX_Timer,x
                beq @valid

                    .byte $02
                    cmp $800f

                @valid:
        .else
 
        lda Note_Period_High,x
        sta APU_Period_High,x ;Only if Sfx isn't playing. ( doesn't have sqr/tri)

        .endif 



            .if Debugging_Enabled
                cmp #$08
                bcc @debugskip
                .byte $02 ;STP. Overflowed Max Period.

                cmp $800a
                @debugskip:
            .endif

        @rts:
        rts ;Return from New_Note
    ;
 
;

py_Segment_End Pre_All_Music_Opcodes





;In: A = MIDI

;Out: A = Period_High
    ; irq_tmp_1 = Period_Low
    ; Carry Still needed for Low's Rounding.
py_Segment sq_tri_calc_period, Free
    sq_tri_calc_period:

        tmp_period_low .set irq_tmp_1 ;name_tmp
            ;[WARN] tmp re-used in SFX_Engine
        tmp_octave_count .set irq_tmp_0

        ;A = Pitch ID 
        ldy #<-1
        clc  ;-1 to fix range 1..15 + BP, not 0..14
        @loop_Div_12:
            iny

            ;sec  ;Except the first time around.
            sbc #$0c 
            bcs @loop_Div_12

        sty tmp_octave_count

        ;A = -12 to -1 Index within an octave
        tay
        lda LUT_12_Periods - <-$0c,y  ;Format:  Lllll HHL (whole thing is rol'ed)
        sta tmp_period_low   ;<-12 cuz Y is -12 to -1 instead of 0 to 11


        and #$07 
        ora #$08 ;---- 1HHL, Lllll HHL  always lsr'ed atleast once.

        @loop_lsr:
            lsr
            ror tmp_period_low ;-> C  Rounding

            dec tmp_octave_count ;octave count
            bpl @loop_lsr

        tmp_octave_count .set -1
        tmp_period_low .set -1 ;clear_tmp
    rts
    ;OUT A = Period High
    ; C = Period Low Rounding.
py_Segment_End sq_tri_calc_period





