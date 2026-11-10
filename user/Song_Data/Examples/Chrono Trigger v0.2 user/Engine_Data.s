;============================================================
; Vibrato
;============================================================

    ; Up to 3 vibrato cycles can be defined. A fourth is hardcoded as No Vibrato
        ; If you want to define your own cycles, see the README for details 

    ;MOVE BELOW TO README

        ; Vibrato cycle values pitch deltas, and they are not cummulative.
        ; The engine can repeatedly halve the deltas, as defined in the Song's Data. (Vib_Deep Halves 0 times. Vib_Very_Shallow halves 3 times.
        ;
        ; This is to maintain a constant percieved vibrato depth across octaves.
        ;
        ; Halving rounds toward negative infinity:
        ;    3 /2  = 1
        ;            1 /2 = 0

        ;   -3 /2 = -2
        ;           -1 /2 = -1
        ;
        ; Negative values never reach 0 when halved. The minimum values
        ; are therefore 0 and -1.

    ;
    Vibrato_Cycle Vib_None
    Vibrato_Cycle Vib_Fast,     4,6,4,      -4,-6,-4
    Vibrato_Cycle Vib_Med,    4,6,6,4,      -4,-6,-6,-4
    Vibrato_Cycle Vib_Slow, -2,-4,-6,-6,-4,-2,2,4,6,6,4,2, 


    Vibrato_Delay 0, No_Delay
    Vibrato_Delay 12, Short_Delay
    ;Vibrato_Delay 15, Med_Delay
    Vibrato_Delay 44, Long_Delay


;


;============================================================
; Envelopes
;============================================================

    ; Defines the instrument Envelopes used by the music DSL.
    ; The Env name in the definition is used to reference it in Channels.
    ;
    ; Envelopes can be used by any channel, though not all channels support all features.
    ;       Tri / Tri-Pulse Envs alias Pulse Envs to better express how they function.
    ;
    ; Envelopes are organized into banks of 16.
    ;       Switching between Envs within a bank is simple.
    ;       Switching between banks mid-song is possible, but not recommended for beginners.
    ;
    ; Since the Envelope data format is fairly obtuse, a Starter set is provided.
    ;       Their names match the inlcuded FamiStudio file: user/Song_Data/Example_Instruments.fms
    ;
    ; See the README for the complete Envelope format.
    

    ;============================================================
    ; Envelope Optimization
    ;============================================================
    ; This attempts to omit unused envelope data.
    ;       WARNING: This should be a final step.
    ;       It easy to mess up, hard to debug, and leaves the Env organization brittle.
    ;
    ; See the README for Envelope Optimization.

        Enable_Env_Optimization = 0
        Suppress_Env_Optimization_Warnings = 1


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
            ;0 has no attack phase. 1 doesn't use Decay Rate, and discontinuous jumps to Decay Init on frame 2



        Vib_Deep         = 0
        Vib_Norm_Depth   = 1 ;An Undefined Vibrato Depth defaults to Normal.
        Vib_Shallow      = 2
        Vib_Very_Shallow = 3

    ;============================================================
    ;Bank 0 Primary Instruments
    ;============================================================
        Env_Bank "Init_Index", 0


        Env "5b", Pad_d50_6_3_1, \
            $60, -$08, $3c, -$04, $10, \
            _d50, atk_10, _d50, _0f, _d50, \
            Vib_None, No_Delay

        Env "4b", T_12v_0f__d25, \
            $10, -$04, $10, \
            _d12, _0f, _d12, \
            Vib_Slow, Short_Delay, \
            dmc_d25

        Env "4b", T_0f__d12, \
            $10, -$04, $10, \
            _d12, _0f, _d12, \
            Vib_None, No_Delay, \
            dmc_d12

        Env "3b", T_12v_3f_m3, \
            $30, -$10, $10, \
            _d12, _3f, _d12, \
            Vib_Slow, Long_Delay

    ;============================================================
    ; Bank 1 Noise Channel
    ;   Envelopes are automatically handled per-Note by the Noise Channel.
    ;   The bank is also ignored.
    ;============================================================
        Env_Bank

        ;Duty for Noise is irrelevant.

        ;All Noise Envs should end with a sustain volume of Zero.
            ;Otherwise, it's unintuitive when the channel is silenced.

        Env "5b", Tamb_env, \
            $a0, -$20, $58, -$04, $00, \
            _d12, atk_3, _d12, _0f, _d12, \
            Vib_None, No_Delay


        Env "5b", Hat_env, \
            $70, -$00, $30, -$10, $00, \
            _d12, atk_1, _d12, _0f, _d12, \
            Vib_None, No_Delay
    
;


;============================================================
; Duration Instruction Sets
;============================================================

    Enable_Custom_Duration_Sets = 1
        ;Disabling is Only Half-Implimented at present.


    ; WARNING. Custom Duration Sets are an advanced feature.
    ;   Defining Custom Sets has a lot of quirks.
    ;   It also has a very large overhead. 
    ;       - It costs approx 60 Bytes of Code and Data. 
    ;       - It takes multiple songs making heavy use of custom sets to be worth the overhead.

    ;WARNING: ;Custom Sets currently have ZERO convienent authoring support. 
    ;   You are on your own until a future update.


    .if Enable_Custom_Duration_Sets
        ;Sets are defined with the Opcodes: 16th, 8th, qtr, dqt, hlf, dhf, whl, or by the raw byte that instruction encodes.
            ;ie $e0 = Set_Env,  $b0 = Shift_Pitch
                ;See `Bad Ideas` in the README for the other instructions.

        ; See the README for details on defining custom duration sets.

        ;WARNING Validation on the Custom Sets is limited. See the example set for usage.

        ; Below is the Standard Duration Sets, unrolled. 

            Duration_Set _00,   1
            Duration_Set _0000, 2
            Duration_Set _6x0,  3
            Duration_Set _8x0,  4, 16th,16th, 16th,16th, 16th,16th, 16th,16th

            Duration_Set _1111, 2
            Duration_Set _6x1,  3
            Duration_Set _8x1,  4, 8th,8th, 8th,8th, 8th,8th, 8th,8th

            Duration_Set _2222, 2
            Duration_Set _6x2,  3
            Duration_Set _8x2,  4, qtr,qtr, qtr,qtr, qtr,qtr, qtr,qtr

            Duration_Set _4444, 2
            Duration_Set _6x4,  3
            Duration_Set _8x4,  4, hlf,hlf, hlf,hlf, hlf,hlf, hlf,hlf

            Duration_Set _8888, 2
            Duration_Set _6x8,  3
            Duration_Set _8x8,  4, whl,whl, whl,whl, whl,whl, whl,whl

        ; Here are some misc ideas of custom sets.

            ;Duration_Set _111_R, 2, 8th,8th,8th, $90 
                ;$90 is Repeat this Duration.

            ;Duration_Set _332_x2, 3, dqt,dqt,qtr, dqt,dqt,qtr

            ;Duration_Set _11100_x2, 5,  8th,8th,8th, 16th,16th,  8th,8th,8th, 16th,16th
                ;Notice Paired-16ths.

            ;Duration_Set _01b0, 2, 16th,8th, $b0,16th
                ;$b- is Shift_Pitch. (A $b0 is a No-Operation.)
                    ;16ths are even across nibbles with the $b0 in the middle.


   
    ;

    .elseif .not Enable_Custom_Duration_Sets
     ;These are the aliases for the Simple, Hardcoded Duration Sets
            ;Rename if desired, but their function is hardcoded.

        ; Naming Convention:
        ;   _XXXX    Four repetitions of a note length.
        ;   _6xX     Six repetitions of a note length.
        ;   _8xX     Eight repetitions of a note length.
        ;
        ;   X = Length type:
        ;       0 = 16th note.
        ;       1,2,4,8 = X * 8th-note length.
        ;
        ;   _00 = Two 16th notes.


        ;16th x2, x4, x6, x8
        _00    = $5f
        _0000  = $5e
        _6x0   = $5d
        _8x0   = $5c

        ;8th x4, x6, x8
        _1111  = $5b
        _6x1   = $5a
        _8x1   = $59

        ;qtr x4, x6, x8
        _2222  = $58
        _6x2   = $57
        _8x2   = $56

        ;hlf x4, x6, x8
        _4444  = $55
        _6x4   = $54
        _8x4   = $53

        ;whl x4, x6, x8
        _8888  = $52
        _6x8   = $51
        _8x8   = $50

        ;Usage
            ;Duration <Set_Alias>, <Pitch>,<Pitch>, <Pitch>,<Pitch>, ...
            ;ie Duration _00, As3,B3
    ;

    .endif
;


;============================================================
; Misc Effects
;============================================================

    ;WARNING. This is unfinished. 


    LUT_MiscFXs_Data:

        ;Macros that assign Misc Effect Indicies and Data.

            ;SFX_Index .set $f8
        MiscFX Init_Sweep   ;Reads (Note_Data,x)
        MiscFX Set_Env_Bank_Byte

                MiscFX_Offset .set (MiscFX_Index & $0f)

        MiscFX Tie_Next_Note, $40
        MiscFX Clear_Special_Effects, 0

        MiscFX Plus_Octave, 12
        MiscFX Minus_Octave, <-12

            ;Common_FadeOut
        MiscFX Common_Fade_Out,    13 << 3 | Vol_12
        MiscFX Inc_Page_Byte ;manual lda (Note_Data,x)
        


      ;Format of Volume:
        ;%11110vvv, %DDDDDVVV  //  $fv,$DV

            ;v = Set Init Volume
            ;V = Target Volume.  0 = Full,  1 = -1/8th  4 = Half, 7 = Near Silenced
            ;D = Delay,  every 1-31f,  inc/dec volume toward Target Volume
;


;
