
.align 256
py_Segment Bowsers_Castle_Sq0, PageFit
    _8th .set 8+7

    Channel Bowsers_Castle_Sq0, BC_Sq0 
        Header G2, Lead_d25_2_9_6_v12

        _1:
            Notes 16*_8th, rest
            Repeat "2b", 1

        ;

        _5: ;End Intro
            Notes whl,Fs3, whl,F3, whl,E3

            .byte Tie_Next_Note
            Notes 16*_8th, Ds3

            _10:
            .byte Volume_Slow_Fade
            Notes whl,Ds3
            Notes 16*_8th, rest

            _13:
            Riff _5, _13

        ;

        ;21
        Notes whl,rest

        Shift_Pitch -1

        _22:
            Duration _8x1, Fs3,Cs3,Fs3,Cs3, F3,Cs3,F3,Cs3
            ; Duration _2222, Fs3,Fs3, F3,F3
            Repeat _22, 6

            ;29
            Env_Change Lead_d12_s7_v8_1f ;Riff Sq1
            _29:
            Notes 5*_8th,Fs2, dqt,Gs2
            _30:
            Notes 16*_8th,As2

        ;


        Env_Change Lead_d25_2_9_6_v12
        _32:
            Notes dqt,Cs3, 8th,C3
            Notes dqt,Ds3, 8th,Cs3
            _33:
            Notes dqt,F3, 8th,Ds3

            Shift_Pitch Cs3, Fs3 ;Irrelevent to Sq0, or to before / after
            Riff _32, _33
            ; Notes dqt,Fs3, 8th,F3
            ; Notes dqt,Gs3, 8th,Fs3

            .byte Tie_Next_Note
            Notes hlf,F3
            Repeat "2b", 4

        ;

    Loop Bowsers_Castle_Sq0, _5

    
    Channel Bowsers_Castle_Sq1
        Header {E2, +Octave}, Lead_d12_s7_v8_1f

        Riff BC_Sq0::_1, BC_Sq0::_5

        _5: ;End Intro
            
            Notes whl,Cs3
            .byte Tie_Next_Note
            Repeat "2b", 3

            ;9
            
            Notes whl,C3 ;2
            
            ;Volume_Slow_Fade
            Riff BC_Sq0::_10, BC_Sq0::_13

            _13:
            Riff _5, _13

        ;

        Shift_Pitch -Octave ;
        ;Shift_Pitch E2, As1  ;save 1b, vs too little vibrato

        ;21
            .byte Tie_Next_Note
            Notes whl,As1
            Repeat "2b", 4 ;No Reset into 26 
            
            _26:
            ;Riff BC_Sq0::_29, BC_Sq0::_30
            Notes 5*_8th,As1, dqt,C2
            Notes 5*_8th,Cs2, dqt,Ds2
            Notes 5*_8th,F2, dqt,Fs2

            _29:
            Riff _26, _29

            ;32
            .byte Tie_Next_Note
            Notes whl,Fs2
            Repeat "2b", 4 

        ;

    Loop Bowsers_Castle_Sq1, _5

py_Segment_End Bowsers_Castle_Sq0


py_Segment Bowsers_Castle_Tri, PageFit
    _8th .set 8+7

    Channel Bowsers_Castle_Tri
        Header A2, Choir_v12_1f

            Riff _9, _13_BP    

        _5: ;End_Intro
            .byte Tie_Next_Note
            Notes whl,A3
                Repeat "2b", 3
            _9:

            Shift_Pitch -Octave

            .byte Tie_Next_Note
            Notes whl,A1
                Repeat "2b", 3
            _13:
            Shift_Pitch +Octave
            _13_BP:


            Riff _5, _13
                BP .set BP-12

        ;

        _21:
            Shift_Pitch A1, Fs1
            Notes whl,Fs1

            Set_Pitch A3
            _22:
                Duration _8x1, As3,As3,As3,As3, A3,A3,A3,A3
                ;Repeat "5b", 14
                _23:
            Riff _22, _23
            Repeat "2b", 13

        ;


    Loop Bowsers_Castle_Tri, _5

py_Segment_End Bowsers_Castle_Tri


py_Segment Bowsers_Castle_dmc, PageFit
    _8th .set 8+7

    Channel Bowsers_Castle_dmc
        Header Fs1, T_0f__d25 ;All Notes Sub d25. All I care about is 0f

        Notes 16*_8th, A1
        Repeat "2b", 1

        _5:
            Notes 16*_8th, A1
            Repeat "2b", 7

            ;21
            Notes 16*_8th, Fs1
            Repeat "2b", 7

        ;

    Loop Bowsers_Castle_dmc, _5

py_Segment_End Bowsers_Castle_dmc


py_Segment Bowsers_Castle_Noise, PageFit
    _8th .set 8+7

    Channel Bowsers_Castle_Noise
        Noise_Header ::Bowsers_Castle_NB, d50_Kick

        _1:
            Duration _00, Solo_Kick, Hat_2

            Notes 8th,rest, 
            Duration _6x1, Shaker_2, Snare_6
            Duration "Cont", rest, Solo_Kick, Solo_Kick, Snare_6

        _2:
        Riff _1, _2
        Repeat "2b", 2


        _5:
            Duration _8x0,   Shaker_Kick, Shaker_2, Hat_2,    Hat_2
            Duration "Cont", Shaker_A2,   rest,     Snare_6,  Hat_2    

            Duration _8x0,   Shaker_A2,   rest,     Hat_Kick, Hat_2
            Duration "Cont", Shaker_Kick, rest,     Snare_6,  Hat_2   

            ;repeat inf

    Loop Bowsers_Castle_Noise, _5

py_Segment_End Bowsers_Castle_Noise

