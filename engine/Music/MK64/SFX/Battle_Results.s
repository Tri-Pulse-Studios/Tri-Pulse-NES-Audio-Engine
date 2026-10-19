_8th .set 7

.align 256


;Size $b6

py_Segment Battle_Results_Sq0, PageFit
    _8th .set 7

    Channel Battle_Results_Sq0, BR_Sq0
        Header F2, Pad_d75_8_0, d50_Kick
            
        _1:
            Duration _4444, rest,B2,C3,Cs3

        End_Intro:
        If_Alt "Toggle"

        _2:
                Notes dqt,D3, dqt,D3, dqt,D3, dqt,D3 ;can Repeat "1b", 3 as a two byte. External repeats though.
                Notes hlf,D3

            _3:

                If_Alt -1 ;B2, C2
                Shift_Pitch D3, E3
            _3_BP:
            Riff _2, _3

            _4:
            Repeat "2b", 1 ;Riff _2, _3

            _5:
                If_Alt +1 ;C2, B2
                Shift_Pitch E3, D3
            Riff _2, _3

            _6:
            Riff _2, _6

        ;

        _10:
            Riff _3, _5 ;E3*2

            ;12
            If_Alt +1
            Shift_Pitch E3, C3
            Riff _2, _3

            ;13
            Shift_Pitch C3, D3
            Riff _2, _3

    
            Shift_Pitch D3, F3
            Riff _3, _4 ;F3->G3

            ;15
            Riff _5, _6 ;G/Ds -> F/D

            ;16
            If_Alt -1 ;D3,C3
            Shift_Pitch F3, E3
            Riff _3_BP, _5

        _18:

    Loop Battle_Results_Sq0, End_Intro


    Channel Battle_Results_Sq1, BR_Sq1
        Header D2, Pad_d75_8_0

        _1:
            Duration _4444, rest,G2,A2,As2 ;G2 would need If_Alt

        End_Intro:
        Riff BR_Sq0::_2, BR_Sq0::_18, "3b" ;$c1 Loop's cannot be Riff'ed
    Loop Battle_Results_Sq1, End_Intro  


    Channel Battle_Results_Tri
        Header D3, T_M11__d25 

            Riff BR_Sq1::_1, BR_Sq1::End_Intro

        End_Intro:
        Env_Change T_1f_12v__d25

        _2: 
                Duration _111_R, B3,G3,E3, Repeat_x4
                Notes 8th,G3

            _3:
                Duration _111_R, C4,A3,Fs3, Repeat_x4
                Notes 8th,A3

            _4:
                Duration _111_R, C4,A3,F3, Repeat_x4
                Notes 8th,A3

            _5:
            Riff _2, _3

            _6:
            Riff _2, _6

        ;

        _10:
        Riff _4, _5

        _11:
                Duration _111_R, C4,G3,E3, Repeat_x4
                Notes 8th,G3

        ;12
                Duration _111_R, A3,F3,D3, Repeat_x4
                Notes 8th,F3

                ; Shift_Pitch B2, A2
                ; Riff _2, _3
                ; Shift_Pitch A2, B2  ;Shift Breaks Even

        ;13
        Riff _2, _3

        ;14
        Shift_Pitch C4, Ds4
        Riff _4, _6 ;Well Worth the Shift.
        Shift_Pitch D4, B3

        ;16
        Riff _3, _5

    Loop Battle_Results_Tri, End_Intro

py_Segment_End Battle_Results_Sq0




py_Segment Battle_Results_dmc, PageFit
    _8th .set 7

    Channel Battle_Results_dmc
        Header G1, T_0f__d25

        Duration _4444, rest,G1,G2,G1

        End_Intro:

        _2:
                Notes qtr,C2, qtr,G2
                Repeat _2, 3

            _3:
                Notes qtr,D2, qtr,A2
                Repeat _3, 3

            _4:
                Notes qtr,G2, qtr,D2
                Repeat _4, 3

            _5:
                Notes qtr,C2, qtr,G1
                Repeat _5, 3

            _6:
            Riff _2, _6


        _10:

            Shift_Pitch D2, F2
                Riff _3, _4 ;D2,A2 -> F2,C3

            _11:
                Notes qtr,E2, qtr,C3
                Repeat _11, 3

            ;12
            Shift_Pitch F2, D2
                Riff _3, _4 ;D2,A2

            _13:
                Notes qtr,C2, qtr,G2
                Repeat _13, 2

                Env_Change T_2f__d12
                Notes qtr,As1, qtr,F2

            _14:
                Notes qtr,Gs1, qtr,Ds2
                Repeat _14, 3

            _15:
                Notes qtr,G1, qtr,D2
                Repeat _15, 3

            _16:
            Env_Change T_0f__d25
            Riff _3, _4 ;D2,A2
            Riff _15, _16

    Loop Battle_Results_dmc, End_Intro

py_Segment_End Battle_Results_dmc




py_Segment Battle_Results_Noise, PageFit
    _8th .set 7

    Channel Battle_Results_Noise
        Noise_Header ::Raceway_NB, d25_Kick

        Duration _2222, Hat_2, Hat_2, Snare_6, Hat_2
        Notes hlf, Snare_6


        Notes 8th,Snare_6, 8th,Hat_2 
        Duration _00, Hat_2 ,Hat_2 
        Repeat "2b", 1

            ; Duration _00, Snare_6, Hat_2 ;-2b
            ; Notes 4, Hat_2, 
            ; Repeat "2b", 2
            ; Notes 3, Hat_2


        ; 2.1
        Notes qtr,Crash_3

        End_Intro:


            ;May Need a pitch shift to DK's Region.

        _2:
                Riff _4, _5 -2
                Duration "Cont", Shaker_Kick, Hat_2  ;lo,hat
                Duration "Cont", Shaker_Kick, Hat_2 ;Double Kick

            _3:
                Riff _4, _5
 
            _4:
                Duration _8x1, Shaker_2, Hat_2, 
                Duration "Cont", Shaker_Kick, Shaker_2, Hat_2, Shaker_2 ;lo,lo, hat, high
                Duration "Cont", Hat_Kick, Shaker_2

                _4_5:
                Duration _8x1, Hat_2, Shaker_2 
                
                Duration "Cont", Shaker_Kick, Hat_2,  Shaker_2, Hat_2 ;lo,hat, lo,hat
                Duration "Cont", Shaker_Kick, Hat_2

            _5:
            

            Riff _2, _4

            Riff _2, _4_5 +2
                Duration "Cont", Shaker_Kick, Hat_2,  Shaker_2, Hat_2 ;highs, only
                Duration "Cont", Shaker_Kick, Shaker_2 ;double shaker

            _10:
            Riff _4, _5 ;Again w/o Extra Double Kick at start.
            Riff _3, _10

    Loop Battle_Results_Noise, End_Intro

py_Segment_End Battle_Results_Noise

