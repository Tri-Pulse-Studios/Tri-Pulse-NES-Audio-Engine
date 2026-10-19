_8th .set 9

.align 256

py_Segment Banshee_Boardwalk_Sq0, PageFit
    _8th .set 9

    Channel Banshee_Boardwalk_Sq0, BB_Sq0
        Header A3, Pad_d75_8_0

        

        _1_Vol:
            Vol_Fade_In  Vol_25, Vol_82, 27 ;dqt
            _1:
                    Riff _8, _8_3
                    _1_3:
                    Repeat _1, 3
                _2:

                Vol_Fade_Out Vol_82, Vol_25, 27 ;dqt
                Riff _1, _2 ;x4
            ;

            _3:
            Riff _1_Vol, _3

        ;



        _5: ;Sq1 <-
            Riff _8_Vol, _9

            _6:
            Riff _8_p1, _9

            _7:
                Shift_Pitch -1
                Riff _8_Vol, _9


            _8_p1:
            Shift_Pitch +1

                _8_Vol:
                    If_Alt Vol_37, Vol_50
                    Vol_Fade_In Vol_37, Vol_100, 18 ;qtr
                _8:
                    Duration _1111, A3,C4,D4,F4 
                    _8_3:
                    Repeat _8, 1
                _8_5:

                If_Alt Vol_82, Vol_100  ;Sq1 is 1/8th quieter
                Vol_Fade_Out Vol_82, Vol_50, 18 ;qtr
                Riff _8, _8_5 ;x2

            _9:
                Riff _8_p1, _9

            ;
            _10:
            Riff _7, _10

        ;

        _13:
        Shift_Pitch C4, A3
        Riff _5, _13

        _21: ;Sq1 ->

    Loop Banshee_Boardwalk_Sq0

    Channel Banshee_Boardwalk_Sq1 ;Optimize, just simplify, re-use Sq1
        Header D3, Pad_d75_8_0

        

        _1:
            Notes 8th,D3, 
            _1_2_Intro:

            Volume_Set Vol_62 ;Has to be after Intro
            Notes 8th,E3
        Repeat _1, 31  ;Add in the Echo Later

        ;5
        Notes 4,rest
        If_Alt "Toggle"
        Riff BB_Sq0::_5, BB_Sq0::_21
        Notes 5,rest


    ;V1 with "echo"  OST doesn't even seem to do this, and its expensive.
        ;     _5:
        ;         Riff _8, _9

        ;         _6:
        ;         Riff _8_p1, _9

        ;         _7:
        ;             Shift_Pitch -1
        ;             Riff _8, _9

        ;             _8_p1:
        ;                 Shift_Pitch +1

        ;                 _8:
        ;                     Duration _8x0, D3,D3, E3,F3, D3,G3, E3,As3
        ;                     _8_3:
        ;                     Repeat "5b", 3

        ;             _9:
        ;             Riff _8_p1, _9

        ;         ;
        ;         _10:
        ;         Riff _7, _10

        ;     ;

        ;     _13:
        ;     Shift_Pitch F3, D3
        ;     Riff _5, _13
    ;

    Loop Banshee_Boardwalk_Sq1, _1_2_Intro

py_Segment_End Banshee_Boardwalk_Sq0




py_Segment Banshee_Boardwalk_Tri, PageFit
    _8th .set 9

    Channel Banshee_Boardwalk_Tri
        Header A2, T_2f__d12 

        _1:
            Notes 8th,A2, 8th,A2
        Repeat "2b", 4


        _1_5:
            Shift_Pitch -1
            Notes 8th,Gs2, 8th,Gs2  ;To be able to use a sweep, 
        Repeat "3b", 5              ;I need a sweep mode that does not affect current pitch.
        BP .set BP -5                   ;Expensive though.


        ;2.3
            Notes 8th,Ds2  ;Two sets of 2b x4
        Repeat "1b", 19


        ;3.5
            Shift_Pitch +1
            Notes 8th,E2, 8th,E2 
        Repeat "3b", 5
        BP .set BP +5

        ;4.3
        Riff _1, _1_5

    Loop Banshee_Boardwalk_Tri

py_Segment_End Banshee_Boardwalk_Tri




py_Segment Banshee_Boardwalk_dmc, PageFit
    _8th .set 9

    Channel Banshee_Boardwalk_dmc
        Header E2, T_2f__d12

        ;1
        ; Notes whl,rest
        ; Repeat "1b", 23

        ;13
        ; Notes qtr,rest 

        Notes qtr,rest
        Repeat "1b", 96 

        _13:
            Duration _2222, E2,F2,Fs2,G2
            Notes whl,Gs2, 
            
            Env_Change T_1f_12v__d25  ;Lead_12to25_s6_v12_6f
            Notes whl,C3, whl,B2
        _15:
        Notes 20*_8th,F2, 14*_8th,rest

        ;17
        Env_Change T_2f__d12
        Shift_Pitch -2
        Riff _13, _15

        ;19
        Notes 12*_8th,E2

        Env_Change T_2f__d12

        Shift_Pitch -1
        Notes 8*_8th/3, Ds2  ;9/3 = 3 by coincidence.
        Repeat "3b", 2
            BP .set BP-2
        
        Notes whl,C2

    Loop Banshee_Boardwalk_dmc

py_Segment_End Banshee_Boardwalk_dmc




py_Segment Banshee_Boardwalk_Noise, PageFit
    _8th .set 9

    Channel Banshee_Boardwalk_Noise
        Noise_Header ::Banshee_Boardwalk_NB, d12_Tom ;d25_Kick    ;2f D50 Kick works fine

        _1:
            Notes 8th,Hat_2, 8th,Hat_2
            Repeat "2b", 2 

            ;1.4
            Duration _00, Hat_2, Snare_6_Kick  ;D12 Train Hi (From Kal)

            _Triplets:
                Notes 6,Hat_2 ;Triplets
                Repeat "2b", 5
            _x6:

            Notes 6,Snare_6

            Notes 6,Hat_2
            Repeat "2b", 1



            Notes 8th,Hat_2, 8th,Hat_2
            Duration _00, Hat_2, Snare_6

        _2:
            Notes 8th,Hat_2
            Repeat "1b", 15


        ; _3:  ;Deleted For Simplification.
        ; Riff _1, _2


        ; _4:
        ;     Notes 8th,Hat_2, 8th,Hat_2

        ;     ;4.2
        ;     Riff _Triplets, _x6

        ;     ;4.4
        ;     Notes 8th,Hat_2, 8th,Hat_2
        ;     _4_5:
        ;     Riff _4, _4_5
        ;     ;Repeat "2b", 4

    Loop Banshee_Boardwalk_Noise

py_Segment_End Banshee_Boardwalk_Noise


