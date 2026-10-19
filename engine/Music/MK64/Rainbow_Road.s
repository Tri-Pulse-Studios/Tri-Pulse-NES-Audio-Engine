_8th .set 7+6

.align 256
py_Segment Rainbow_Road_Sq0, PageFit
    _8th .set 7+6

    Channel Rainbow_Road_Sq0, RR_Sq0
        Header E2, Choir_v12_1f

        Notes 16*_8th,A2, 16*_8th,Gs2, 
        
        _5:
        Duration _8x8, A2,Gs2,Fs2,Gs2, A2,Gs2,B2,A2
        Repeat "5b", 1

        _21:
        Duration _8x8, E2,Fs2,Gs2,A2, A2,A2,A2,Gs2
        Repeat "5b", 1

        _37:
        .byte Tie_Next_Note
        Notes 16*_8th,A2
        Repeat "2b", 1

        _41:

        Env_Change Lead_d12_s7_v8_1f
        Riff ::RR_Tri_5, ::RR_Tri_41, "3b"

    Loop Rainbow_Road_Sq0


    Channel Rainbow_Road_Sq1, RR_Sq1 ;BP = B2
        Header B2, Choir_v12_1f

        If_Alt "Toggle"


        Notes 16*_8th,B2
        Repeat "2b", 2

        _7:
        Notes 12*_8th,B2
        _8_5:

            Env_Change Pad_d12_s3_v8  
            Shift_Pitch +Octave
            Notes qtr,E4, qtr,B3
            Shift_Pitch -Octave

        _9:
        Env_Change Choir_v12_1f  
        _9_env:

        Notes 16*_8th,Cs3
        Repeat "2b", 1



        _13:
        Notes dqt,rest
        Duration _00, B2,rest

        _13_5:
        Notes qtr,E3,
        Duration _00, B2,rest
        Notes dhf,E3, 

        Notes 8th,rest
        Duration _00, Gs3,A3 ;A3 needs to be As3

        _14_7:
        Notes hlf,Gs3
        Duration _00, Fs3,rest

        If_Alt E3, F3
        Notes qtr,E3
        Duration _00, Ds3,rest


            If_Alt 0, 2, 'F'
            Shift_Pitch 0

            Notes dqt,B2,8th,rest
            Duration _00, B2,rest


        _16_5:
        Riff _8_5, _9_env
        Notes dqt,E3

        _17_4:
            Duration _00, Fs3,rest
            If_Alt A3, As3
            Notes qtr,A3

            Shift_Pitch +Octave
            Duration _00, Cs4,rest
            
            If_Alt 0, 2, 'F'
            Shift_Pitch 0

            Notes 9*_8th,E4, 16*_8th,B3
            Shift_Pitch -Octave


        _21:
        Duration _8x8, Cs3,D3,E3,D3, Cs3,Cs3, B2,B2 ;the 1f cutoff is not noticable timed w/ a Kick


        _29:
        Notes dqt,rest
        Duration _00, Cs4,rest
        Notes qtr,B3 
        ;Riff would need Shift +2, Shift -2.  


        _29_6:
        Duration _00, A3,rest ;Duration w/ If_Alt Required.
        Notes hlf,Fs3

        Duration _00, Fs3,rest
        Notes 8th,E3, 8th,rest ;Different (And cheat-y so Tri doesn't have to change at all)
        Duration _00, E3,rest


        _30_7:
        
            Riff RR_Tri_30_7, RR_Tri_32_8
            BP .set BP+14
            Shift_Pitch -2

        _32_8:
        Notes 16*_8th,A4

        ;34_8
        Notes 8th,E4, whl,Fs4, whl,E4
        
        .byte Tie_Next_Note
        Notes 16*_8th,F4 
        Repeat "2b", 1




        _41:
        Shift_Pitch -Octave
        Notes 16*_8th,B2
        Riff _7, _13

        Env_Change Lead_d12_s7_v8_1f
        Shift_Pitch -Octave
        Riff _13, _16_5

        ;52.5
        Shift_Pitch +Octave
        Riff _8_5, _9
        Notes dqt,E3

        Env_Change Lead_d12_s7_v8_1f
        Shift_Pitch -Octave

        ;53.4

        Riff _17_4, _21

        ;57
        Env_Change Choir_v12_1f
        Shift_Pitch +Octave
        Riff _21, _41

    Loop Rainbow_Road_Sq1
    

    Channel Rainbow_Road_Tri ;BP = E2
        Header {E2, -Octave}, Choir_v12_1f

        Notes 16*_8th,E2, 
        Repeat "2b", 1

        Shift_Pitch +Octave

        ::RR_Tri_5:
        Riff _13, _14_6 -1
        Notes dhf,B3
        Riff _14_6, _21


        _13: 
            Riff RR_Sq1::_13,  RR_Sq1::_13_5

            Notes qtr,B3
            Duration _00, E3,rest
            Notes dhf,Gs3 ;Notes dhf,B3

            _14_6:
            Notes 8th,rest
            Duration _00, B3,Cs4

            Shift_Pitch -2
            Riff RR_Sq1::_14_7,  RR_Sq1::_16_5
            BP .set BP+2

                Notes 7*_8th,B3 ;Sq1 Does the High Pitched Thing
                Shift_Pitch -2

                Riff RR_Sq1::_17_4,  RR_Sq1::_21
                BP .set BP+2


        _21:
            Riff _29, _32_5
            BP .set BP+12

        _24_5:
        Notes 7*_8th,A4

        Shift_Pitch -Octave

        ;25.4
        Duration _00, E4,rest
        Notes whl,E4,

        _26_5:
        Notes _8th+7,D4, _8th+6,Cs4, 8th,A3, 
        Notes 16*_8th,B3





        _29:
            Notes dqt,rest
            Duration _00, E4,rest
            Notes qtr,D4

            _29_6:
            Duration _00, Cs4,rest
            Notes hlf,B3

            Notes dqt,A3
            Duration _00, A3,rest

            ::RR_Tri_30_7:
                Shift_Pitch +Octave
                Notes 5*_8th,A4


                If_Alt 2, 0, 'F'
                Shift_Pitch 2 ;Only Sq1 shifts  (The If_Alts are backwards from normal. )
                BP .set BP-2 

                If_Alt G4, Gs4
                Notes _8th+7,G4 



                Notes _8th+6,A4
                Duration _00, B4,rest

                _32:
                Notes dqt,B4
                Duration _00, A4,rest


        _32_5:

                Notes qtr,A4
                Duration _00, B4,rest

            ::RR_Tri_32_8:

        Notes 13*_8th,Cs5

        _34_5:
        Riff _26_5, _29 ;+Octave

        ;37
        Riff RR_Sq0::_37, RR_Sq0::_41



        ::RR_Tri_41:
        Shift_Pitch -Octave


        Riff RR_Sq0::_5, RR_Sq0::_41

    Loop Rainbow_Road_Tri

py_Segment_End Rainbow_Road_Sq0



.align 256
py_Segment Rainbow_Road_dmc, PageFit

    _8th .set 7+6
    Channel Rainbow_Road_dmc, RR_dmc
        Header E2, T_1f_12v__d25

        ; _1:
        ;     Duration _0000, E2,rest, E2,E2
        ;     _1_3:
        ;     Repeat "3b", 2
        ;     Duration _0000, E2, E3, E2,E2 ;High E3

        ;     _2:
        ;     Duration _0000, E2,rest, E2,E2 ;Would Riff _1, 3  ,but Riff_Depth
        ;     Repeat "3b", 3
        ; _3:

        _1:
            Duration _8x0,   E2,rest, E2,E2
            Duration "Cont", E2,rest, E2,E2

            Riff _1, 3
            Duration "Cont", E2,E3, E2,E2 ;w/ E-Three

            _2:
            Riff _1, _2 -2
            _2_7: ;For SR
            Duration "Cont", E2,E2,  E2,E2 ;Extra E-Two (Technically Wrong for RR, but SR needs it.)
            

            _3:
            Riff _1, _3

        ;

        _5: ;A
                Riff _1, _5 

                _9:
                Shift_Pitch E2, D2
                Riff _1, _5 
                Shift_Pitch D2, E2
                ;

            _13:
            Riff _5, _13


            _21: ;B
                Shift_Pitch E2, A2 ;+5
                Riff _1, _2

                _22: ;SR
                    Shift_Pitch A2, B2 ;+2
                    Riff _2, _3

                
                Set_Pitch Cs2 ;-10  (Though Kinda cool how ear hears +2)
                _23_Set_Cs2:
                Riff _1, _2

                Shift_Pitch Cs2, D2 ;+1
                Riff _2, _3

                ;25
                Shift_Pitch D2, E2 ;+2
                Riff _1, _5 
            ;

            _29:
            Riff _21, _29


            ;37
            Shift_Pitch E2, F2
            Riff _1, _5 
            Shift_Pitch F2, E2

        ;

        _41:
        Riff _5, _41


    Loop Rainbow_Road_dmc


    _8th .set 7+7
    Channel Staff_Roll_dmc
        Header E2, T_1f_12v__d25 

        _1:
        Riff RR_dmc::_1, RR_dmc::_9

        _9:
            Repeat _1, 2
            ; Riff RR_dmc::_1, RR_dmc::_3
            ; Repeat "2b", 7 ;1..9 x2
        

            Riff _73, _81
            Repeat "2b", 1


            _41:
            Riff _9, _41
        
        ;

        _73:
            Shift_Pitch E2,Gs2 ;+4
            Riff RR_dmc::_1, RR_dmc::_3

            Shift_Pitch Gs2,A2 ;+1
            Riff RR_dmc::_1, RR_dmc::_3

            Shift_Pitch A2,B2 ;+2
            Riff RR_dmc::_1, RR_dmc::_3

            ;Shift_Pitch B2,Cs3 ;+2
            Riff RR_dmc::_22, RR_dmc::_23_Set_Cs2 ;[WARN] There is No Cs4 for DMC
                BP .set Cs3              

            Shift_Pitch Cs2, Ds2 ;-12, +2
            Riff RR_dmc::_2, RR_dmc::_3 


            Shift_Pitch Ds2,E2 ;+1

        ;

        _81:
        Riff RR_dmc::_1, RR_dmc::_9

        Notes whl,rest ;Space for Noise.

    Loop Staff_Roll_dmc

py_Segment_End Rainbow_Road_dmc




py_Segment Rainbow_Road_Noise, PageFit

    _8th .set 7+6
    Channel Rainbow_Road_Noise, RR_Noise
        Noise_Header ::Rainbow_Road_NB, d25_Kick

        _1:
            Notes 8th, Crash_7
            Riff _9_2, _13 

        _5:
            ;Riff _1, _5
            Repeat _1, 1

            _9:
            Notes 8th, Crash_3
            _9_2:
                Duration _00, Hat_2, Hat_2 ;Riff _9_6, _10

                _9_3:
                    Notes 8th, Snare_6
                    Duration _00, Hat_2, Hat_2 


                _9_5: ;Kick
                    Notes 8th, Hat_Kick
                    _9_6:
                    Duration _6x0, Hat_2,  Hat_2


                _9_7: ;Snare
                Duration "Cont",  Snare_6, Hat_2, ;Extra Hat
                Duration "Cont",  Hat_2,   Hat_2

            ;


            _10:
                Notes 8th, Hat_Kick
                Riff _9_2, _9_6 +1
                ;6.5
                    ;Notes 8th, Hat_Kick
                    ;Duration _6x0 ...
                    _10_6:
                    Duration "Cont", Hat_Kick,     Hat_2 ;Double Kick
                        
                    Duration "Cont", Snare_6,      Hat_2, ;Also Extra Hat
                    Duration "Cont", Pre_Cymbal_4, Hat_2
            ;

            _11: 
                Duration _00, Hat_Kick,  Shaker_2
                Riff _9_2, _10 ;Includes Extra Hat

            ;


            _12: 
                Notes 8th, Hat_Kick
                Riff _9_2, _9_5

                Notes 8th, Hat_2 ;Offset Kick
                Duration _00, Hat_Kick, Hat_2

                Riff _9_3, _9_5

            ;

            _13:
            Riff _5, _13
        ;

        


    ;If Alt _5 and _21

        ; _9:
        ;     Notes 8th,Crash_3
        ;         _9_2:

        ;             _00:  
        ;             If_Alt Hat_2, Shaker_2
        ;             Notes 7,Hat_2,  6,Hat_2 ;raw _00
        ;             _Hat_Hat:

        ;         Notes 8th,Snare_6
        ;         Riff _Hat_Hat, _00

        ;     _9_5:
        ;         Notes 8th,Hat_Kick
        ;         _9_6:
        ;         Riff _Hat_Hat, _00

        ;         Duration _00, Snare_6,Hat_2 ;Extra Hat
        ;         Riff _Hat_Hat, _00
        ;             ;16B  vs 11B
        ; _10:

        ;     Notes 8th, Hat_Kick
        ;     Riff _9_2, _9_6 +1

        ;             _Alt:  
        ;             If_Alt Hat_Kick, Shaker_Kick
        ;             Notes 7,Hat_2,  6,Hat_2 ;raw _00
        ;             _Kick_Hat:

        ;         Duration _00, Snare_6,Hat_2 ;Extra Hat

        ;         If_Alt Pre_Cymbal_4, Shaker_2
        ;         Notes 7,Pre_Cymbal_4,  6,Hat_2 ;raw _00

    ;

    ;Below is $19 or 25 Bytes.  Above needs to use less than 21 Extra to be worth while.
        ;Raw 0s get expensive though, and its done several times.


        
        _21:
            Notes 8th,Crash_3
            _21_2:
                Duration _00, Shaker_2, Hat_2
                _21_3:
                Notes 8th, Snare_6
                Duration _00, Shaker_2, Hat_2 

            _21_5:
                Notes 8th, Hat_Kick
                Riff _21_2, _21_5

                    ;Inserting the 4th hat here is too expensive.

            _22:
                Repeat _21_5, 1 ;Riff _21_5, _22

                Notes 8th, Hat_Kick ;Double Kick
                _22_6:
                    Duration _00, Shaker_Kick ,Hat_2 
                    Riff _21_3, _21_5


            _23:
                Riff _21_5, _22 
                Repeat "2b", 2

                ;24.5
                Notes 8th, Hat_2 ;Offset Kick
                Riff _22_6, _23

            _25:
            Riff _9, _13

            _29:
            Riff _21, _29    

        ;

        ;37
        Riff _1, _5

        _41:
        Riff _5, _41, "3b"


    Loop Rainbow_Road_Noise

    _8th .set 7+7
    Channel Staff_Roll_Noise
        Noise_Header ::Rainbow_Road_NB, d25_Kick


        
        _1:
            ;Crash _3
            Riff RR_Noise::_9, RR_Noise::_10

            _2:
                Notes 8th,Hat_Kick
                Riff RR_Noise::_9_2, RR_Noise::_10

            _3:
            Repeat _2, 6
        ;

        _9:
            Riff _1, _9
            Riff _1, _9 ;Internal repeat

            _25:
                Riff RR_Noise::_21, RR_Noise::_21_5

                Riff RR_Noise::_21_5, RR_Noise::_22
                ;26
                Repeat "2b", 13
            _32_5:
            Riff RR_Noise::_21_5, RR_Noise::_22


            _33:
                Riff _25, _32_5

            ;40.5
                Vol_Fade_In Vol_50, Vol_100, 14 ;qtr

                Duration _8x0, Snare_6_Kick, Snare_6, Snare_6, Snare_6
                Duration "Cont",Snare_6, Snare_6, Snare_6, Snare_6


                .byte Clear_Special_Fade
        ;

        _41:
        Riff _9, _41

        ;73
        Riff _33, _41 ;Short Snare End

        ;81
        Notes 8th, Crash_7
        Riff RR_Noise::_9_2, RR_Noise::_10

        Riff _2, _3 ;Hat, _9_2 .. _10
        Repeat "2b", 5

        ;88
        Duration _8x0, Snare_6_Kick,rest, Snare_6,Snare_6
        Duration "Cont",Snare_6,    rest, Snare_6,Snare_6

        Duration _8x0, Snare_6_Kick,Snare_6, Snare_6,Snare_6 ;Riff 40.5
        Duration "Cont", Snare_6_Kick,Snare_6_Kick,Snare_6_Kick,Snare_6_Kick,

        Notes whl, Crash_3

    Loop Staff_Roll_Noise

py_Segment_End Rainbow_Road_Noise



