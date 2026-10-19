

.align 256
py_Segment Toads_Turnpike_Sq0, PageFit

    _8th .set 6+7
    Channel Toads_Turnpike_Sq0, TT_Sq0
        Header Cs3, Choir_v12_1f

        _1: 
        .byte Tie_Next_Note ;Beats 64, Cs3
        Notes whl,Cs3
        Repeat "2b", 7

        _9_Init:
        Env_Change Lead_12to25_4_11_3_v12
        Notes dqt,rest

        _9:
        Duration _00, G3,Gs3;-20
        Notes dqt,As3, 8th,Gs3 ;6b

        ;10
        Notes dqt,G3, qtr,F3, (3*_8th+1)/2,Gs3, (3*_8th)/2,G3 

        ;11
        Notes whl,Ds3

        _12_BP_Env:
        Set_Pitch Gs1
        _12_Env:
        Env_Change Pad_sqr_4_0
        _12:
            
            
            Up:
            Duration _0000,Gs1,As1,Cs2,Ds2

            Shift_Pitch +Octave
            Riff Up, 3
            

                _12_5:
            BP .set Gs2
            Down:
            Duration _0000,Gs3,Ds3,Cs3,As2

            Shift_Pitch -Octave
            Riff Down, 3


        ;13
        Riff _12, 12
        End_13:

        ;14
        Set_Pitch Cs3
        Riff _9_Init, 12
        ;16
        Notes whl,G3

        ;17
        Riff _12_BP_Env, End_13 
        ;19
        Riff _12, 12


        Init_Pad:
        .byte Tie_Next_Note ;Not confident this is needed.
        Env_Change Pad_d25_8_3_v12
        Set_Pitch Cs4,+Octave

        ;20
        Notes whl,F4  ;Beats 24,F4
        .byte Tie_Next_Note
        Repeat "2b", 2
        ;23
        Notes _8th*16,G4



        _25_Init:
        Set_Pitch Fs3
        Env_Change Lead_12to25_4_11_3_v12
        Notes dqt, rest

        _25:
        BP .set Fs3
        Duration _00, Fs3,Gs3
        Notes dqt,A3, 8th,B3

        ;26
        Notes 5*_8th,Gs3, qtr,A3, 9*_8th,Fs3

        _28:
        Set_Pitch A1
        Riff _12_Env, 13
        Repeat "2b", 2

        _31:
        Riff Init_Pad, 3
        BP .set Cs4
        Notes 16*_8th,Fs4

        ;33
        _33:
        Riff _25_Init, 11
        
        _35:
        BP .set Fs3
        Notes dhf,B3, qtr,Cs4, 9*_8th,D4


        ;37
        Riff _28, 4
        ;38
        Riff _12, 6
        ;38.5
        Riff _31, 4
        ;40.5
        BP .set Cs4
        Notes hlf,Fs4 ;20*13 = 260, Not in range. 


        Shift_Pitch -Octave
        BP .set Cs3

        _41_Init:
        Env_Change Choir_v12_1f
        _41:
            BP .set Cs3
        Notes hlf,Cs3, hlf,D3, hlf,Ds3, hlf,E3 ;Duration
        Repeat "4b", 1

    Loop Toads_Turnpike_Sq0

    
    Channel Toads_Turnpike_Sq1
        Header F3, Choir_v12_1f

        ;1
        Riff TT_Sq0::_1, 3


        ;9
        _9_Init:
        Notes 8th, rest
        _9_Short_Rest:
        Notes 2*_8th+7,rest ;dqt + 16th melody delay
        Env_Change Pad_sqr_s4
        Set_Pitch Cs4, +Octave
        
        Riff TT_Sq0::_9, 10
        BP .set Cs3

        ;11
        Notes whl,Ds3 ;Ds4 Technically

        _12:
        Notes 6,rest ; +16th for arpeggio delay
        Riff TT_Sq0::_12_BP_Env, 17

        ;14.2
        Riff _9_Short_Rest, 7 ;-16th for Melody Delay

        BP .set Cs3
        Notes whl,G3

        ;17
        ;Riff 4, _12 ;Riff Depth of 4
        Notes 6,rest ; +16th for arpeggio delay
        Riff TT_Sq0::_12_BP_Env, 17

        _19:
        Notes dqt,rest
        Riff TT_Sq0::Init_Pad, 3
        BP .set Cs4

        .byte Tie_Next_Note ;Beats 24,As4
        Notes whl,As4
        Repeat "2b", 2
        ;22.5
        .byte Tie_Next_Note ;Beats 20,Ds4
        Notes hlf,Ds4
        Repeat "2b", 3 ;2.5x measure
        Notes hlf,Ds4

        _25_Init:
        Riff _9_Init, 4
        Shift_Pitch Cs3, Fs3
        Riff TT_Sq0::_25, 9
            

        _28:
        Notes 6, rest ;+8th arpeggio delay
        Riff TT_Sq0::_28, 4
        Repeat "2b", 1


        _30:
        Riff _19, 3
        BP .set Cs4

        .byte Tie_Next_Note ;Beats 20,B4
        Notes hlf,B4
        Repeat "2b", 3 ;2.5x measure
        Notes hlf,B4

        ;33
        Riff _25_Init, 3 ;Exceeds max depth
        ; Riff 4, _9_Init
        ; Shift_Pitch Cs3, Fs3

        Riff TT_Sq0::_25, 7
        ;34.8
        Riff TT_Sq0::_35, 4

        ;37
        ;Riff 4, _28 ;Exceeds max riff depth
        Notes 6, rest ;+8th arpeggio delay
        Riff TT_Sq0::_28, 4


        ;38
        Riff _30, 6

        ;40
        Set_Pitch A2
        Riff TT_Sq0::_41_Init, 7

    Loop Toads_Turnpike_Sq1, "Riffed"


    Channel Toads_Turnpike_Tri, TT_Tri
        Header Gs1, T_1f_12v__d25 

        .byte Tie_Next_Note ;Beats 64,Cs2
        Notes whl,Cs2
        Repeat "2b", 7 ;Already didn't Riff Sq0.

        _9:

            Riff TT_Sq0::_12, TT_Sq0::_12_5 +2 
            BP .set BP+12

            ;Duration _0000,Gs3,Ds3,
            Duration "Cont", Gs3,Ds3

            Duration _00, Cs3,As2
            Shift_Pitch -Octave
            Duration _00, Gs2,Ds2

            _10:

            Riff _9, _10
            Repeat "2b", 14

        ;

        _25:
            Shift_Pitch Gs1, A1
            Riff _9, _25 ;x16

        ;

        _41:
            Notes 12*_8th,B1

            Shift_Pitch +Octave
            Duration _00,B2,B3 
            Shift_Pitch -Octave

            Notes dqt,rest

            .byte Init_Sweep, 1 ;B1-G1 over 240f
            Notes 12*_8th,B1

            Notes hlf,rest

        ;

    Loop Toads_Turnpike_Tri
    TT_Tri_Loop:


    Channel Toads_Turnpike_dmc
        Header Cs1, T_2f__d12

        _1:
                    Riff _2, _2_4
                Notes qtr,Ds2
                    Riff _2_6, _3


                _2:
                    Notes _8th+7,Ds1, _8th+6,As1
                    _2_4:

                Notes 8th, Ds2
                _2_5: ;end
                Duration _00, Cs1, rest  ;Duration _1111, Cs1,Cs1,A1,Cs2 ;-2b

                _2_6:
                    Notes 8th,Cs1, 8th,A1, 8th,Cs2  

                
            
            _3:

            Riff _1, _3
            Repeat "2b", 10

        ;

        ;25
            Shift_Pitch Cs1, D1
            Riff _1, _3
            Repeat "2b", 6

            ;39
            Riff _1, _2_5
            Duration _6x0, Ds2,rest, Ds2,Ds2, Cs2,Cs2
            Notes 8th,Cs2

        ;

        ;41
        Shift_Pitch D1, A0
        Riff TT_Tri::_41, TT_Tri_Loop

    Loop Toads_Turnpike_dmc, "Riffed"

py_Segment_End Toads_Turnpike_Sq0

.align 256
py_Segment Toads_Turnpike_Noise, PageFit

    _8th .set 6+7
    Channel Toads_Turnpike_Noise
        Noise_Header ::Toads_Turnpike_NB, d50_Kick

        _1:
        Notes 8th,Crash_7

            _1_2:
            Riff _8_2, _9

            ;2
            Riff _8, _9
            _3:
            Repeat "2b", 5

            _8:
                Duration _00, Shaker_Kick, Hat_2
                _8_2:
                    Duration _00, Hat_2, Hat_2
                    Notes 8th,Snare_6

                    _8_4:
                    Duration _6x0,   Hat_2, Pre_Cymbal_4, 
                    Duration "Cont", Hat_2, Snare_6,     Hat_Kick, Hat_2

                    _8_7:
                    Notes 8th,Snare_6 
                    Duration _00, Hat_2, Hat_2
        ;

        
        _9:
        Notes 8th,Crash_3
            Riff _1_2, _9

        ;

        _17:
            Notes 8th,Crash_3
            Riff _1_2, _8_7

            Duration _0000, Snare_6, Snare_6,  Hat_2, Hat_2

        ;

        _25:
            Riff _1, _9 ;Crash_7
            Riff _17, _25 ;Crash_3 w/ Double Snare

        ;

        _41:
            Riff _1, _3
            ;43 
            Riff _8, _9
            ;44
            Riff _8, _8_4
            Duration _00, Pre_Cymbal_4, Solo_Kick

            Notes 8th,Snare_6, 8th,Snare_6
            Duration _00, Snare_6, Snare_6

            Notes 8th,rest

    Loop Toads_Turnpike_Noise

py_Segment_End Toads_Turnpike_Noise


