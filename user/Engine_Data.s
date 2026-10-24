;============================================================
; Envelopes
;============================================================

    ; Defines the instrument Envelopes used by the music DSL.
    ; The Envelope name in the definition is used to reference it in Channels.
    ;   ie:
    ;       Env Pad_d12_6_0, \
    ;           <Env_Data>
    ;
    ;       Channel <Song_Name>
    ;           Header <BP>, Pad_d12_6_0
    ;
    ; Envelopes can be used by any channel, though not all channels support all features.
    ;       Tri/Tri-Pulse alias Pulse Envelopes to better express how they function.
    ;
    ; See the README for the naming convention 
    ;
    ;
    ;
    ; Envelopes are organized into banks of 16.
    ;       Switching between Envelopes within a bank is simple.
    ;       Switching between banks mid-song is possible, but not recommended for beginners.
    ;
    ;
    ;
    ; Since the Envelope data format is fairly obtuse, a Starter set is provided.
    ;       Their names match the inlcuded FamiStudio file: Tri_Pulse_Demo.fms
    ;
    ; See the README for the complete Envelope format.
    ;
    ;
    ;
    ;
    ;
    ; WARNING: Unused Envelope data can be optimized, but this should be a final step.
    ; It easy to mess up and hard to debug.
    ;
        Enable_Env_Optimization = 1
        Suppress_Env_Optimization_Warnings = 1
    ;
    ; See the README for Envelope Optimization.



    ;============================================================
    ; Envelope Constants
    ;============================================================

        ;Leave these alone

        dmc_d25 = As1
        dmc_d12 = Cs3
            ;Lowest Pitch that plays as 25% Tri-Pulse
                ;A custom pitch, ie Fs2, can be used.
                

        _d12 = %00
        _d25 = %10
        _d50 = %01
        _d75 = %11
            ;Bits are stored backwards.

        _0f = 0
        _1f = 2
        _2f = 3
        _3f = 4
        _4f = 5
        _5f = 6
        _6f = 7
            ;Cutoff length
            ;0 and 1 both Don't Release 

        atk_1  = 1
        atk_2  = 2
        atk_3  = 3
        atk_4  = 4
        atk_5  = 5
        atk_6  = 6
        atk_7  = 7
        atk_8  = 8
        atk_9  = 9
        atk_10 = 10
        atk_11 = 11
        atk_12 = 12
        atk_13 = 13
        atk_14 = 14
        atk_15 = 15
            ;Attack Length
            ;0 and 1 both have no Attack phase.
                ;1 Uses Attack Init frame 1, then Decay Init frame 2, which are discontinuous.


        Vib_None   =  $00 << 2
        Vib_Fast =  %01 << 2
        Vib_Med  =  %10 << 2
        Vib_Slow =  %11 << 2
            ;Vibrato Speed

        No_Delay    = %00 << 2 
        Short_Delay = %01 << 2 
        Med_Delay   = %10 << 2 
        Long_Delay  = %11 << 2 
            ;Vibrato Delay

        Vib_Deep = 0
        Vib_Shallow = 2
        Vib_Very_Shallow = 3

    ;============================================================
    ;Bank 0 Primary Instruments
    ;============================================================
        Env_Bank "Init_Index", 0


        Env "5b", Pad_6_15_7_v12,\
            $60, +$10, $cc, -$04, $70, \
            _d50, atk_10, _d50, _0f, _d50, \
            Vib_Slow, Med_Delay


        Env "5b", Pad_10_5_0,\
            $a0, -$20, $50, -$08, $00, \
            _d50, atk_2, _d50, _0f, _d50, \
            Vib_None, No_Delay


        Env "5b", Pad_12_7_0,\
            $c0, +$00, $70, -$18, $00, \
            _d50, atk_1, _d50, _0f, _d50, \
            Vib_None, No_Delay

            ;1f atk allows -$50 atk rate when out of range.

        Env "5b", Lead_25to50_7_9_0,\
            $70, +$10, $94, -$0c, $00, \
            _d25, atk_3, _d50, _0f, _d50, \
            Vib_Slow, Med_Delay

        Env "4b", T_M12__F2,\
            $c0, -$10, $00, \
            _d50, _0f, _d50, \
            Vib_None, No_Delay, \
            F2
            ;Pitch >= F2 is d25. Else < F2 is d12.

        Env "4b", T_0f_12v__d25,\
            $10, -$04, $10, \
            _d50, _2f, _d50, \
            Vib_Slow, Long_Delay,\
            dmc_d25

    ;============================================================
    ; Bank 1 Noise Channel
    ; (Envelopes are automatically handled per-Note by the Noise Channel,
    ;  and ignore the bank.)
    ;============================================================
        Env_Bank

        ;Duty for Noise is irrelevant.

        ;All Noise Envs should end with a sustain volume of Zero.
            ;Otherwise, it's unintuitive when the channel is silenced.

        Env "5b", Crash_env, \
            $b0, -$1c, $68, -$04, $00, \
            _d12, atk_3, _d12, _0f, _d12, \
            Vib_None, No_Delay


        Env "5b", Snare_env, \
            $a0, -$1c, $50, -$10, $00, \
            _d12, atk_3, _d12, _0f, _d12, \
            Vib_None, No_Delay

        Env "5b", Pre_Cymbal_env, \
            $20, +$08, $40, -$10, $00, \
            _d12, atk_6, _d12, _0f, _d12, \
            Vib_None, No_Delay



        Env "3b", Shaker_env, \
            $a0, -$30, $00, \
            _d12, _0f, _d12, \
            Vib_None, No_Delay


        Env "3b", Hat_env, \
            $40, -$40, $00, \
            _d12, _0f, _d12, \
            Vib_None, No_Delay








;============================================================
; Vibrato
;============================================================

    ; Up to 3 vibrato cycles can be defined. A fourth is hardcoded as No Vibrato
    ; If you want to define your own cycles, see the README for details 

    ;TODO
        ;A macro that auto-generates 

    ;MOVE BELOW TO README

        ; Vibrato cycle values are 2x the maximum vibrato depth.
        ; The engine halves the delta's between 1 and 4 times, as defined in the Song's Data.
        ;
        ; This is to maintain a constant percieved vibrato depth across octaves.
        ;
        ; Halving rounds toward negative infinity:
        ;    3 / 2  = 1
        ;             1 / 2 = 0
        ;   -3 / 2  = -2
        ;             -1 / 2 = -1
        ;
        ; Negative values never reach 0 when halved. The minimum values
        ; are therefore 0 and -1.

    ;


        LUT_Vibrato_NonRel_Data:
                .byte      8,12,8,       <-8,<-12,<-8          ;6v Fast
                .byte   8,12,12,8,       <-8,<-12,<-12,<-8     ;8v Medium
                .byte 4,8,12,12,8,4, <-4,<-8,<-12,<-12,<-8,<-4 ;12v Slow

            LUT_Start_Vib_Index:
                .byte 0,  6,  6+8

            LUT_End_Vib_Index:
            ;   .byte 0,  6,  6+8
                .byte 6+8+12



            LUT_Vibrato_Delays:
            .byte <~0, <~8, <~19, <~45

    ;

;============================================================
; Duration Instruction Data
;============================================================

    ; Defines the Duration sets available to the music DSL
    ; for song compression.
    ;
    ; This "Starter" set is sufficient for most songs.
    ;
    ; See the README for details on defining custom duration sets.

        ;py_Segment LUT_Length_Nibbles, Free
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

                adr_6x8:
                adr_8x8:
                .byte $88,$88,$88,$88


            .assert (*-LUT_Length_Nibbles)<$20, error, "Duration Lengths don't fit."
                ;This can be before the last one.

            LUT_Read_Nibbles_Init:
                Duration_List Emit_LUT ;Macro Emitted Data


            ;py_Segment_End LUT_Length_Nibbles


;




