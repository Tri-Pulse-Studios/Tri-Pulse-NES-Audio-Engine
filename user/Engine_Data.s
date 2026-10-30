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
    Vibrato_Cycle Vib_Fast,     -4,-6,-4,      4,6,4
    Vibrato_Cycle Vib_Med,      -4,-6,-6,-4,   4,6,6,4
    Vibrato_Cycle Vib_Slow, -2,-4,-6,-6,-4,-2, 2,4,6,6,4,2


    Vibrato_Delay 0, No_Delay
    Vibrato_Delay 10, Short_Delay
    Vibrato_Delay 15, Med_Delay
    Vibrato_Delay 28, Long_Delay


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
            ;0 has no attack phase. 1 doesn't use Decay Rate, and discontinuous jumps to Decay Init. Frame 2



        Vib_Deep         = 0
        Vib_Norm_Depth   = 1 ;An Undefined Vibrato Depth defaults to Normal.
        Vib_Shallow      = 2
        Vib_Very_Shallow = 3

    ;============================================================
    ;Bank 0 Primary Instruments
    ;============================================================
        Env_Bank "Init_Index", 0

            ;d12
            Env "3b", Lead_d12_s9_v8, \
                $d0, -$0c, $90, \
                _d12, _0f, _d12, \
                Vib_Med, Short_Delay

            Env "3b", Lead_d25_12_s9_v12, \
                $d0, -$20, $90, \
                _d25, _0f, _d12, \
                Vib_Slow, Short_Delay




            ;d25
            Env "3b", Lead_d12_25_s8_v8, \
                $d0, -$30, $80, \
                _d12, _0f, _d25, \
                Vib_Med, Short_Delay



            ;d50
            Env "3b", Lead_sqr_s6_v12, \
                $d0, -$60, $60, \
                _d50, _0f, _d50, \
                Vib_Slow, Long_Delay


            ;Pad
            Env "3b", Pad_d12_s3_v12, \
                $50, -$10, $30, \
                _d12, _0f, _d12, \
                Vib_Med, Long_Delay


            Env "5b", Pad_d25_8_5_0, \
                $80, -$18, $50, -$14, $00, \
                _d25, atk_5, _d25, _0f, _d25, \
                Vib_None, No_Delay


            
            ;Tri
            Env "4b", T_1f__d25, \
                $50, -$10, $30, \
                _d50, _1f, _d50, \
                Vib_None, No_Delay,\
                dmc_d25

            Env "4b", T_2f__d12, \
                $50, -$10, $30, \
                _d50, _2f, _d50, \
                Vib_None, No_Delay,\
                dmc_d12

            Env "4b", T_M8__d25, \
                $80, -$10, $00, \
                _d50, _2f, _d50, \
                Vib_None, No_Delay,\
                dmc_d25
                


            ;Khevari
            Env "3b", Lead_d12_s9_v6, \
                $f0, -$80, $90, \
                _d25, _0f, _d12, \
                Vib_Fast, No_Delay   

            Env "3b", Lead_sqr_s5_v8, \
                $d0, -$30, $50, \
                _d50, _0f, _d50, \
                Vib_Fast, No_Delay  

            Env "5b", Pad_d25_v12, \
                $80, -$0c, $80, -$0c, $40, \
                _d25, atk_6, _d25, _0f, _d25, \
                Vib_Slow, No_Delay


            Env "4b", T_1f__E2, \
                $d0, -$30, $50, \
                _d50, _0f, _d50, \
                Vib_Fast, No_Delay,\
                E2 
    ;============================================================
    ; Bank 1 Noise Channel
    ;   Envelopes are automatically handled per-Note by the Noise Channel.
    ;   The bank is also ignored.
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
            $c0, -$20, $60, -$10, $00, \
            _d12, atk_3, _d12, _0f, _d12, \
            Vib_None, No_Delay

        Env "5b", Wash_env, \
            $90, -$14, $40, -$04, $00, \
            _d12, atk_3, _d12, _0f, _d12, \
            Vib_None, No_Delay


        Env "3b", Hat_env, \
            $70, -$20, $00, \
            _d12, _0f, _d12, \
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



        ;Index $54:
        Duration_Set _1111, 2
        Duration_Set _6x1, 3
        Duration_Set _8x1, 4, 8th,8th, 8th,8th, 8th,8th ;8th,8th

        Duration_Set _111_2_111_b, 4, 8th,8th,8th, qtr, 8th,8th,8th, $b0  ;$b0 for Shift_Pitch

        
        ;Index $58
        
        Duration_Set _3_111, 2, dqt,8th, ; 8th,8th
        Duration_Set _111_3, 2, 8th,8th, 8th,dqt 
  
            
        Duration_Set _666_633_6222, 5, dhf,dhf,dhf, dhf,dqt,dqt, dhf,qtr,qtr,qtr ;Net saving of 6 Bytes.
            Duration_Set Unused, 1   ;Duration_Set _6_222, 2, dhf,qtr,qtr,qtr

   

        ;Index $5c
        Duration_Set _2222, 2, qtr,qtr, qtr,qtr
        Duration_Set _2121, 2, qtr,8th, qtr,8th

        Duration_Set _332_x2, 3, dqt,dqt,qtr, dqt,dqt,qtr
        Duration_Set _11_100_x2, 5, 8th,8th,8th, 16th,16th,  8th,8th,8th;, 16th,16th
        
        ;Index $50:
        Duration_Set _00,   1
        Duration_Set _0000, 2
        Duration_Set _6x0,  3
        Duration_Set _8x0,  4, 16th,16th, 16th,16th, 16th,16th, 16th,16th

        

    ;

    .else
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

        ;

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

;


