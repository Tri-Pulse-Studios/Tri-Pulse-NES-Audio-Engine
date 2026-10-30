
 
; 

py_Segment Update_Music, Free

    .macro Update_Fade 
        ;For an external, all channel fade-out, should I just Have a "6th" Channel that is global, and summed w/ the per-channel and if sum >7 silence?

        lda Note_Volume_Damped,x
        cmp Volume_Target,x ;-> C
        beq @exit

            dec Volume_Timer,x
            bne @exit


                lda Volume_Timer_Reload,x 
                sta Volume_Timer,x

                bcs @dec ;<- C

                    inc Note_Volume_Damped,x
                    bcc @exit

                @dec:
                dec Note_Volume_Damped,x

        @exit:
    .endmacro


    .macro Update_Sweep
            lda Sweep_Speed,x
            ;beq @rts ;2b saves  ~30/cc every frame.

                add {Note_Period_Low,x} ;2's comp
                sta Note_Period_Low,x

                bvc @Exit_Sweep

                    ;@dec
                    .if Emit__Unused
                        bmi @inc

                        ; @dec:
                            dec Note_Period_High,x
                            jsr Note_Conditional_Write_Period_High

                            jmp @Exit_Sweep
                            ;can bal Conditional, bpl
                    .endif

                    @inc:
                        inc Note_Period_High,x ;Tail Calls
                        jsr Note_Conditional_Write_Period_High 


            @Exit_Sweep: 
    .endmacro


    .macro Check_Init_SFX

        lda SFX_Queued,x
        beq @skip2
         
            ;cmp SFX_Index,x
            ;bcs @skip   ;<- Priority.  SFX w/ Smaller Index will overwrite Larger. 

            jsr Init_SFX 
        @skip2:

    .endmacro


    .macro DMC_Update_Regs
        lda SFX_Timer,x
        beq @Mute_Check

            dec SFX_Timer,x
            bne Update_SFX ;Tail Call


                @Restore_Note:
                lda DMC_MIDI
                jsr dmc_rate ;New Note -> Prime DMC

        @Mute_Check:

        ldy #Zero_Sample ;Reset Output to 0. (Basically finish the last wave.)

        lda Note_Volume+$10 
        and #$f0 ;%VVVV vv DD
        beq Prime_DMC ;(Y = Zero_Sample)  ;Tail Call

            
        ;Tri/Dmc will need their own function to play for Max N frames
        ;rts
    .endmacro


    Update_Music:
        lda Silence_APU_Flag
        bne @play        

            ;lda #$00
            sta APU_Channel_Enable
            rts


        @play:
        lda APU_Channel_Enable
        ora #$0f
        sta APU_Channel_Enable ;Enable NT10. Leave DMC unchanged.
                ;This is handled in DMC_Update_Regs, but its not stable.

 
        ldx #$00
        Loop_All_Channels:

            jsr Update_Volume 

            dec Note_Timer,x
            bne @skip

                jsr Pre_New_Note 

            @skip:

            Inline Update_Fade
            Inline Update_Sweep 
            Inline Check_Init_SFX
            
            
            cpx #$c 
            beq @noise
            bcs @dmc

                @sqr_tri:
                    jsr Sq_Tri_Update_Regs  

                    inxn 4
                    bal Loop_All_Channels, bne 
                        ;on inx to $c, cpx $c diverts to noise.


                @noise:
                    jsr Noise_Update_Regs ;An Inline Fits. Has internal Tail-Calls though

                    ldx #$10
                    bal Loop_All_Channels, bne


                @dmc:            
                    Inline DMC_Update_Regs  ;Internal Tail Calls rts from Update_Music   
    rts

    Noise_Update_Regs:
        dex ;Secondary (Crash, Snare, Etc, Anything w/ the "Musical"/"Complex" type that are usually longer.)
        jsr SFX_Write_Regs   ;"Normal" Music SFX updates volume by default.
        inx 


        lda SFX_Timer,x  ;Primary ;(Hat, Game SFX)
        beq @skip_primary

            dec SFX_Timer,x
            bne Update_SFX ;Tail Call


        @skip_primary:
        ;No Action needed on SFX Release.
    rts


    ;In A= Pointer to SFX data.
        ;Negetive = Musical
        
        ;Positive = Sweep

            ;Both pointers go to same table. (The header is same format too.)
    Init_SFX:

        .if Debugging_Enabled
            .if Emit__Unused
                cpx #$0b
                bcs @valid2  ;Only Noise and DMC sfx are supported in  build
                    Runtime_Exception "Runtime_Exception: Unimplimented Feature. SFXs cannot be played thorugh Pulse or Triangle Channels yet."

                @valid2:
            .endif
        .endif

        tay

        lda LUT_SFX_Data-2,y
        and #$7f ;bit 7 set means its a Base Period.  Its so multiple Pitches to the same sound are usable.
        sta SFX_MIDI,x ;Noise Base-Period

        @loop:
            iny
            lda LUT_SFX_Data-2,y
            bmi @loop    
                    ;iny til reached the length byte (range 0..127)



        cpx #$0b ;If Noise secondary (Crash/Snare) it uses Musical RAM. ie,  Timer is for jsr New_Note,  not SFX_Update.  Must be skipped.
        beq @Skip_Secondary_Noise ;SPAGHETTI

            sta SFX_Timer,x
                
            lda #$00
            sta SFX_Queued,x  ;Queue and Timer are NOT used by Secondary Noise (Which Uses "Normal" Music RAM)



        @Skip_Secondary_Noise:
        lda #$01 ;Inits like Note Timer
        sta SFX_pitch_timer,x 

        tya
        sta SFX_Index,x

        lda LUT_SFX_Data-1,y
        sta SFX_Env_ID,x ;sty 
        
        tay ;ldy SFX_Env_ID,x

        cpx #$0f
        bcs Prime_DMC

        SFX_Reset_Env:
            ; AT Duration
                lda LUT_Env_AT_Rate,y  
                and #$0f ;== 0 Skips Decay_Init Entirely.
                sta SFX_ATK_Timer,x

            ;Volume
                lda LUT_Env_AT_Init,y 
                and #%11110011 ;VVVV -- DD 
                sta SFX_Volume,x ;and Duty
            ;OUT A = Note_Volume (Note Reset eor.)
    rts

    ;.res 106  Max Insert Size w/o breaking.
        ;Full __Update_Music is waaay beyond that.

    ;IN Y = Sample ID
    Prime_DMC:
        lda #$0f
        sta APU_Channel_Enable ;Disable Dmc

        lda LUT_dmc_addr,y 
        sta DMC_Address

        lda LUT_dmc_length,y 
        sta DMC_Length 

        lda #$1f
        sta APU_Channel_Enable ;Enable Dmc (Only way to tell it to start reading at the new address)
    rts
  




    Update_SFX: ;For Primary.
        jsr SFX_Write_Regs
        ;Update Volume
        inx
        jsr SFX_Update_Volume
        dex

    rts

    SFX_Write_Regs:

        ;Update Pitch
        ldy SFX_Index,x

            ; .if Debugging_Enabled
            ;     lda SFX_pitch_timer,x
            ;     bne @repeat_current_pitch ;Prevents endless garbage read.
            ; .endif

            dec SFX_pitch_timer,x
            bne @repeat_current_pitch

                @read_next_pitch:                 ;Read a Flag to know if each "New Note" Resets the Env or not. (ie, SMB3's 1-up sound resets the Env each note.)
                inc SFX_Index,x 
                iny ;The iny is needed for consistancy with whether it re-inits the same pitch or a new one.

                lda LUT_SFX_Data-1,y 
                lsrn 4 ;If 0, Sustains
                sta SFX_pitch_timer,x ;A 0 means, hold indefinitely.

            @repeat_current_pitch: 
            lda LUT_SFX_Data-1,y
            and #$0f

            .if Emit__Unused
                bne @sfx_note
                
                @sfx_rest:
                ;lda #$00
                sta SFX_Volume,x  ;With volume silenced, pitch is irrelevant.
                                    ;For this to be useful for the whole engine, Musical needs a flag of some kinda that tells it to jsr Reset_Envelepe
                @sfx_note:

                .elseif Debugging_Enabled

                    bne @valid
                    pha
                        lda SFX_Volume,x ;If un-muted, crash
                        and #$f0
                        beq :+

                        Runtime_Exception "Runtime Exception. SFX Error. Garbage Data is read while the Noise Channel is unmuted."

                        :
                        pla
                    @valid:


                
            .endif

            add {SFX_MIDI,x} 
            ; jmp @Update_Pitch_APU


        ;A = Pitch Index / Noise Period / dmc Rate
        @Update_Pitch_APU: 
        cpx #$0f
        bcs @Update_dmc

 
        .if Emit__Unused
            cpx #$0b ;Cant bcs/beq cuz Noise is both $0b and $0c
            bcs @Update_Noise 
                        ;Store Noise APU "Writes" to a tmp. Let the Secondaries get overwritten w/o writting them to APU

            @Update_Sq_Tri:
                ;[NOTE] This is run EVERY frame a sfx is playing. 

                ;In A= MIDI
                jsr sq_tri_calc_period ;-> C
                sta APU_Period_High,x      
                    ;[ERROR]: Causes clicking for Pulse SFX to write High every frame.

                lda irq_tmp_1 ;tmp_period_low
                adc #$ff ;<- C 
                    ;adc #$00 ;<- C for rounding
                    ;add #<-1 to fix period off-by-one quirk
                sta APU_Period_Low,x

                lda SFX_Volume,x
                jmp Write_APU_Volume_no_dampen ;Just a bunch of Bit shifts.
                    ;Tail-Call

                .elseif Debugging_Enabled
                    cpx #$0b ;Cant bcs/beq cuz Noise is both $0b and $0c
                    bcs @Update_Noise 

                        Runtime_Exception "Runtime_Exception: Unimplimented Feature. SFXs cannot be played thorugh Pulse or Triangle Channels yet."
        .endif


        @Update_Noise:
            sta APU_Noise_Period;sta irq_tmp_2 ;tmp_period

            ;Primary/Secondary AND Game SFX will all be volume damped.
                ;Can filter out Game SFX by the queue priority idea I have
                ;Basically, all Music SFX will have low priority. And only low priority sounds will be affected here.
            phx
            lda SFX_Volume,x 

            ldx #$0c
            ldy Note_Volume_Damped+$c ;Needed for when Volume is damped.
            jsr Write_APU_Volume_Noise_LDY_BEQ_RELIANT ;Just a bunch of Bit shifts.
                ;Can Write to APU_Noise_Volume+1  w/o effect ($400d is ignored)

                ;Noise Does not use $400c's Duty bits like Pulse.
                    ;Entirely Ignored. Save to Or-In garbage to those bits.

            plx                ;
        rts

        ;


        @Update_dmc:
        ora #$40 ;loop
        sta DMC_Rate

        .if Debugging_Enabled
            bpl :+
            Runtime_Exception "Runtime_Exception: DMC IRQs: The DMC is configured to use IRQs, when it should. Bad LUT data or index is the likely cause."
            :
        .endif
    rts

    ;



    .macro Vibrato_LUT_by_ID
        ldy Note_Env_ID,x
        lda LUT_Env_Sustain,y ;%VVVV II DD ;I = Vibrato ID
        and #$0c
        beq @Vib_Nonerato
            ;bne @skip

                ; cpy #SFX_Hoot_M8 ;Env_ID for it
                ; bne @Vib_Nonerato

        @skip:
        lsrn 2
        tay ;ID 0= None / Hoot. 1=fast  2=medium  3=slow

        inc Vibrato_Timer,x
        bmi @Vib_Nonerato ;Delay Timer active.
            bne @skip_init ;==0 Delay Timer Expired.

                @init:
                lda LUT_Start_Vib_Index,y
                sta Vibrato_Timer,x

            @skip_init:
            lda Vibrato_Timer,x
            cmp LUT_End_Vib_Index,y 
            beq @init ;inf Loop Warning.

            tay
            lda LUT_Vibrato_Period_Deltas,y ;2's comp
            
            ldy Vibrato_Depth,x  
            @loop:
                asr
 
                dey
                bpl @loop
                bmi @exit

            ;rts

            @Vib_Nonerato:
            lda #$00

        @exit:
        ;rts
    .endmacro

    .macro Prepare_APU_Period_Low
        Inline Vibrato_LUT_by_ID
            ;Out, A= Vibrato Offset.
        add {Note_Period_Low,x} ;Fake-2's comp.
        bvc Vibrato_Didnt_Overflow

            lda #$7f ;Clamp to max [-128, 127]
            adc #$00  ;If Overflow, CLC, If Underflow, Sec

        Vibrato_Didnt_Overflow:

        eor #$80 ;fix fake 2's comp
    .endmacro

    Sq_Tri_Update_Regs:
        .if Emit__Unused
            lda SFX_Timer,x
            beq @Update_Low

                dec SFX_Timer,x
                bne Update_SFX ;Tail Call


                @Restore_High: ;Sfx Ended, Restore High Byte.
                lda Note_Period_High,x
                sta APU_Period_High,x

                .elseif Debugging_Enabled

                    lda SFX_Timer,x
                    beq @Update_Low

                        Runtime_Exception "Runtime_Exception: Unimplimented Feature. SFXs cannot be played thorugh Pulse or Triangle Channels yet."

        .endif

        @Update_Low:
        Inline Prepare_APU_Period_Low
        sta APU_Period_Low,x

        jmp Write_APU_Volume ;Tail Call
        ;sta APU_Volume,x

    ;rts

;

py_Segment_End Update_Music




py_Segment Update_Volume, Free
    SFX_Update_Volume: ;inx/dex
    Update_Volume:
        ldy Note_Env_ID,x

        lda Note_Volume,x
        and #$f0 ;and #$fc would also get the sub-pixel volumes.
        beq @rts ;If its already silenced, don't change that.


        dec Note_Env_Timer,x ;Dec til Timer Expires
            beq @Decay_Init ;== 1, Init
            bpl @Attack ;> 1, AT

        inc Note_Env_Timer,x ;Once Expired, stay Static
            beq @Decay ;== 0 Decay
            ;bne @Sustain ;== -1 Sustain -> Release
    

        @Sustain:
            lda No_Reset_Env_Flag,x ;[WARN] SFX shares this execution
            bmi @rts

                lda LUT_Env_Decay_Rate,y
                and #$07 ;== 0 Doesnt release

                cmp Note_Timer,x
                bcc @rts

                    @Released:
                    lda #$03   ;Also from Decay w/ Anything
                    sta Note_Volume,x
        
            @rts:
        rts


        @Attack:
            lda LUT_Env_AT_Rate,y ;lda, and #$f0
            and #$f0

            asr ;Range +1.75 .. -2.00 /f
            asr
            add {Note_Volume,x}, clc
            sta Note_Volume,x ;Blindly added w/ NO bounds check. 
        rts 


        @Decay_Init:
            lda LUT_Env_Decay_Init,y ;%VVVV vv DD 
            sta Note_Volume,x
        rts

        ;
        
        @Decay:
            lda LUT_Env_Decay_Rate,y ;lda, and #$f8
            and #$f8

            sec ;asr, but always negetive  (Range is -0.25 to -8.0 /f)
            ror 
            add {Note_Volume,x}, clc
            bcc @Sustained ;Underflowed.

            cmp LUT_Env_Sustain,y
            bcs @Not_Sustained 

                @Sustained:
                dec Note_Env_Timer,x ;$00 -> $ff means Sustained.

                lda LUT_Env_Sustain,y ;%VVVV -- DD


            @Not_Sustained:
            sta Note_Volume,x 
    rts
py_Segment_End Update_Volume


py_Segment Write_APU_Volume, Free
    Write_APU_Volume:

        ;%VVVV vv dD
        ;V= 0-f written volume (0 Mutes Tri, Otherwise, full Volume.)
        ;v= stored quarter-resolution
        ;D = Duty

        lda Note_Volume,x
        ldy Note_Volume_Damped,x

            Write_APU_Volume_Noise_LDY_BEQ_RELIANT: ;SFX
        beq Write_APU_Volume_no_dampen

                ;%_Damping

            ;In Y= Damp level 1-7
            
            and #%11110000 ;Clear the fractional-volume (Causes wierd aliasing otherwise)

            pha
                lsrn 3
                sta irq_tmp_0 

            pla
            @loop:
                sub irq_tmp_0 ;subtract 12.5%  1-7 times. (or 256 if unintended  sneaks in)
                dey
                bne @loop

            eor Note_Volume,x 
            and #$fc
            eor Note_Volume,x ;Or- in duty bits.

        @skip:
        ;

        Write_APU_Volume_no_dampen: ;<- SFX
        ;IN A = lda Note_Volume,x

        ;A= %VVVV-vv-dD
        lsr ;D->C
        php ;   C->SP
        lsr ;d->C

        ;A= %00-VVVV-vv, C=d, SP=D

        ror ;d->A
        plp ;D->C
        ror ;   C->A
        ;A = %Dd 00 VVVV ([NOTE] the Duty bits are now backward.)

        ora #$30 ;A = %Dd 11 VVVV for Square, Noise

        cpx #$08
        bne @Skip_Tri

            and #$0f
            ora #$80 ;A = %1 000 VVVV ,where if V == 0, Triangle Mutes
                
        @Skip_Tri:
        sta APU_Volume,x

        ;DMC Doesn't use this function. 
            ;It just needs %---- VVVV, and Mutes a totally different way.
    
    rts    



py_Segment_End Write_APU_Volume




