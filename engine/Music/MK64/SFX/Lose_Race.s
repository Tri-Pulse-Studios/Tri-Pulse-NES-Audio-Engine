    _8th .set 9+9


    ;[NOTE] This one is very un-optimized.

.align 256

py_Segment Lose_Race_Sq0, PageFit
    _8th .set 9+9

    Channel Lose_Race_Sq0, Lose_Sq0
        Header E2, Lead_12to25_s6_v12,  

        _1:
                Notes 1,C3
                Shift_Pitch +1
                Repeat "3b", 3
                    BP .set BP+3

                Shift_Pitch -5
                
                _1_2:
                Notes 7*5 +3, E3 ;4*9 +2
            _1_3:

            ;Ds3
            Riff _1, _1_3
                BP .set BP-1

            ;D3
            Riff _1, _1_2
                BP .set BP-1
            Notes 7*7 +3, D3 ;5*9 +7

            ;Cs3
            Riff _1, _1_2
                BP .set BP-1
            Notes 7*23 +3, Cs3 ;18*9 +2

            Notes 7*20, rest
            
        ;

        _5: 
        
            Set_Pitch A2 ;Set makes it same before and after Intro
            Env_Change Pad_d75_8_0
            
        _5_Post_BP:
        Duration _2222, E3,E3, Ds3,Ds3
        Notes qtr,E3, 8th,E3

        Notes _8th/2,rest, 9*_8th/2,Ds3
        ;7
    Loop Lose_Race_Sq0, _5


    Channel Lose_Race_Sq1, Lose_Sq1
        Header Cs2, Lead_d12_s7_v8_1f,  

            Riff Lose_Sq0::_1, Lose_Sq0::_5

        _5:

        Riff Lose_Sq0::_5, Lose_Sq0::_5_Post_BP
        BP .set A2

        _5_Post_BP:
            Duration _2222, A2,A2, A2,A2

            Notes qtr,A2, 8th,A2
            _6_4:
            Notes 4,rest, 4*_8th +9+5,A2 ;9*_8th/2 +5
        ;7
    Loop Lose_Race_Sq1, _5


    Channel Lose_Race_Tri
        Header {Ds5, +Octave}, SFX_Hoot_M8,  

            Notes (8+3)*14,rest

            Notes 14,F5 ;8th
            Repeat "2b", 3

            Notes 21,F5 ;d.8th
            Repeat "2b", 1

            Notes (6+8)*14,F5

        _5:
        Set_Pitch Fs2
        .byte Set_Env_Bank_Byte, T_M6 ;Env_Change T_M6

        Riff Lose_Sq1::_5_Post_BP, Lose_Sq1::_6_4
        Notes 5*_8th,Fs2

    Loop Lose_Race_Tri, _5


    Channel Lose_Race_dmc
        Header G1, T_0f__d25, d25_Kick

            Riff Lose_Sq0::_1, Lose_Sq0::_5

        _5:
        Set_Pitch F1
        Env_Change T_2f__d12

        ;Pitch Shift
        _5_Post_BP:
        Notes hlf,Fs1, hlf,B1,dqt,Fs1, 
        _6_3:
        Notes 5*_8th,B1

        ;7
        Riff _5_Post_BP, _6_3
        Notes qtr,B1, dqt,F1 ;Loops every 4-measures, as opposed to just 2

    Loop Lose_Race_dmc, _5

py_Segment_End Lose_Race_Sq0



py_Segment Lose_Race_Noise, PageFit
    _8th .set 9+9

    Channel Lose_Race_Noise
        Noise_Header ::Lose_Race_NB, d25_Kick

        Notes 6*7,Crash_3 ;dhf
        Repeat "2b",1

        Notes 8*7,Crash_3 ;whl


        Notes 20*7 +10,Crash_7
        Duration _00, Snare_6,Snare_6 ;Triplets just happen to be 10-9-9 for 4*7

        Notes 20*7, Solo_Kick

        _5:

        Notes 9+9+6, Shaker_2, 3+9,Hat_2
        ;Quarter-Triplets
        ;_8th*4/3  _8th*2/3

    Loop Lose_Race_Noise, _5

py_Segment_End Lose_Race_Noise
