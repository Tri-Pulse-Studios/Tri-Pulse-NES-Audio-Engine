_8th .set 6
.align 256

py_Segment Raceway_Sq0, PageFit
    _8th .set 6

    Channel Raceway_Sq0, R_Sq0
        Header D3, Lead_12to25_s6_v12

        _1:
                Notes hlf,rest, 12*_8th,D3, whl,Ds3, 
            _4:

            Notes dhf,E3

            Env_Change  Lead_d12_12_0 
            Duration _0000, Fs3,G3,A3,B3
        ;

        _5:
            Notes qtr,C4,
            _5_3:
            If_Alt "Toggle"
            Notes qtr,C4, qtr,C4, qtr,As3
            Notes 8th,C4, qtr,As3, 

            If_Alt Ds4, G3
            Notes qtr,Ds4

            Notes 5*_8th,rest

            _7_3:

            
            Riff _5_3, _7_3
            Repeat "2b", 5

        ;
        
        ;19
        Notes 18*_8th,rest

        _21_5:
            Riff _29_5, _34_6
            BP .set A2

            _26_6:
            Notes 8th,A2, 8th,As2
            Notes 8th,rest, 9*_8th,As2, qtr,rest


            If_Alt 5, (-4 & $f)
            Shift_Pitch 5   
        

            _28_5_Init:

            If_Alt Lead_d12_12_0, Pad_d25_8_3_v12  ;.byte $70 | (Pad_d25_8_3_v12 - Lead_d12_12_0) & $f
            Env_Change Lead_d12_12_0 

            _28_5_No_Env:
            Duration _1111, C4,C4,As3,C4
            Notes hlf,rest

            Env_Change Lead_d12_s7_v8_1f ;For later




            ; If_Alt 0, 4
            ; Shift_Pitch 0



            _29_5:
            Env_Change Lead_12to25_s6_v12
            Duration _00, As3,B3
            Notes dqt,C4, hlf,As3

            Shift_Pitch D3, A2  

            ;30.5
            If_Alt A3, Gs3
            Notes hlf,A3

            Notes hlf,G3, hlf,F3,

            ;32
            If_Alt E3, Ds3
            Notes hlf,E3

            If_Alt D3, Cs3
            Notes qtr,D3

            Notes         8th,rest
            Notes qtr,C3, 8th,rest
            Notes whl,As2, qtr,rest, qtr,As2


            _34_6:
            Notes 8th,C3

            If_Alt D3, Cs3
            Notes 8th,D3

            Notes 8th,rest

            If_Alt E3, Ds3
            Notes 12*_8th,E3

            _36_6:



            ;Env_Change OLD_Pad_d75_8_0
            Notes 1,B3
            Shift_Pitch -1
            Repeat "3b", _8th*4 -1
            Set_Pitch D3
        ;



        _37:
            Env_Change Lead_25to12_v6
            Notes 5*_8th,rest


            Notes 8th,Ds3, 8th,rest
            Repeat "2b", 3

            _39:
            Notes 8th,D3, qtr,Ds3, dqt,rest,


            ;39.5
            If_Alt Lead_d12_12_0, Pad_d25_8_3_v12
            Env_Change Lead_d12_12_0

            Notes dqt,C4, 8th,C4
            Notes hlf,rest
            



            Riff _44_5, _45

            Riff _37, _39
            Notes 8th,F3, 
            _43:

            Notes qtr,Ds3

            _43_2:
                Notes dqt,rest 
                Riff _28_5_Init, _29_5  ;C-C-As-C

                _44_5:
                    Env_Change Lead_25to12_v6

                    If_Alt A2, F3 ;Replaces A2 w/ F3 as target
                    Shift_Pitch D3, A2

                    Notes 8th,G3
                    Notes hlf,A3

                    _45_No_BP:

                    If_Alt F3, A2   ;Undoes
                    Shift_Pitch A2, D3





            _45:
                Riff _37, _43

            Notes qtr,G3 ;Replaces Ds3 w/ G3

                Riff _43_2, _45_No_BP
                BP .set BP-5 ;D3->A2
        ;


        Shift_Pitch A2, E3
        If_Alt 0, 1
        Shift_Pitch E3, Gs3


        If_Alt Lead_12to25_s6_v12, Lead_25to12_v6
        Env_Change Lead_12to25_s6_v12

        
        _53:
                Notes dqt,rest

                If_Alt A3, Gs3
                Notes 8th,A3
                Notes 8th,As3, 8th,rest


                Vol_Fade_Out Vol_100, Vol_50, 3 ;16th
                .byte Tie_Next_Note

                Notes hlf,C4

                Vol_Fade_In Vol_50, Vol_100, 9 ;d_8th
                Notes whl,C4


                Notes 8th,rest, qtr,C4

                If_Alt D4, Cs4
                Notes qtr,D4

                ;56
                Notes hlf,C4

                If_Alt D4, Cs4
                Notes hlf,D4

                Notes hlf,Ds4

                If_Alt D4, Cs4
                Notes hlf,D4

            _58:
                Notes hlf,C4, 8th,As3, qtr,rest

            _59:
                Vol_Fade_Out Vol_100, Vol_25, 2  ;_32nd
                .byte Tie_Next_Note

                If_Alt A3, Gs3
                Notes whl,A3

                Vol_Fade_In Vol_25, Vol_100, 12 ;qtr
            _60:
            If_Alt A3, Gs3
            Notes 10*_8th,A3



            ;61
            Riff _53, _58
        
            _66:
                Notes hlf,F4, hlf,Ds4

            _67:
                If_Alt G4, Fs4
                Notes hlf,G4
                Notes 8th,F4,8th,rest

                If_Alt A4, Gs4
                Notes hlf,A4
                If_Alt G4, Fs4
                Notes 8th,G4, 8th,rest

                Notes hlf,As4
        ;



        _69:
            ;
                If_Alt -1
                Notes qtr,A4, 
                
                If_Alt C4, rest
                Notes 8th,C4, 
            _69_4:

            If_Alt -1
            Notes 8th,G4, ;hlf,rest

            _69_5:
                Notes hlf,rest


                ;70
                Notes qtr,F4, 
                
                If_Alt As3, rest
                Notes 8th,As3, 
            _70_3:

            
            Notes 8th,Ds4, hlf,rest
            
            
            Shift_Pitch A4, D4 ;BP =? Cs3
            ;71
                Riff _69, _69_4


            Notes 8th,C4, ;hlf,rest

            ; ;72
                Riff _69_5, _70_3
            
            If_Alt -1
            Notes 8th,A3, hlf,rest
                



            _73:
            Shift_Pitch +5 ;Also Needed for _77

            Riff _59, _60 ;Fast Fade, Slow Recover

            If_Alt -1 
            Notes 24*_8th,G3 

        ;


        Env_Change Lead_12to25_s6_v12 ;Sq1 set to Sq0

        _77:
                Notes hlf,rest, 

                If_Alt -1
                Notes dqt,D4, 8th,rest,

                If_Alt -1 
                Notes dqt,D4

            _78_4:
            Notes 8th,C4, hlf,rest
            
            ;79
            Riff _77, _78_4

            Notes 8th,Ds4, hlf,rest

            _81:
            Riff _77, _81
        ;
        

    Loop Raceway_Sq0
    R_Sq0_Loop:

    Channel Raceway_Sq1 ;Uses If_Alt almost entirely.
        Header As2, Lead_12to25_s6_v12

        _1:
            Riff R_Sq0::_1, R_Sq0::_4

            Notes hlf,C3

            Riff R_Sq0::_36_6, R_Sq0::_37 ;Slide Up
            BP .set D3

            Shift_Pitch -Octave 
            Env_Change Pad_d25_8_3_v12
        ;

        ;5
        Riff R_Sq0::_5, R_Sq0::_21_5

        If_Alt "Toggle"
        _21_5:
            
            Set_Pitch B2  ;Shift -3, +Octave Vibrato Depth
            ;Riff R_Sq0::_21_5, R_Sq0::_36_6, "3b"

            Riff R_Sq0::_21_5, R_Sq0::_29_5


            Set_Pitch B2  ;Shift +9
            Riff R_Sq0::_29_5, R_Sq0::_36_6
            BP .set Fs2
        ;

        Notes hlf,rest
        Shift_Pitch Fs2, D2
        
        
        _37:
        Riff R_Sq0::_37, R_Sq0_Loop, "3b"  ;R_Sq0::_69, "3b"

    Loop Raceway_Sq1, "Riffed"

py_Segment_End Raceway_Sq0


.align 256
py_Segment Raceway_Tri, PageFit
    _8th .set 6

    Channel Raceway_Tri, Raceway_Tri
        Header F2, T_2f__d12

        If_Alt "Toggle"


        _1:
            Notes qtr,F3, qtr,F2, 

            
            If_Alt 0, 7
            Shift_Pitch 0

            _3:
            Notes 12*_8th,G2, whl,Gs2, whl,A2 ;D2,Ds2,E2
            
            
        ;

        _5:
            Riff _21_BP, _23
            Repeat "2b", 6
            BP .set C2

            _19: 
            .byte Init_Sweep, 5
            .byte Tie_Next_Note
            Notes dhf,C2

            Shift_Pitch -4
            .byte Init_Sweep, 33 ;Down to the Basement.
            Notes hlf,A1


            _20_3:
            Notes dhf,rest


        ; ;

        _21_BP:
            Set_Pitch C2
            _21:
                Notes qtr,C3, qtr,C2, 
                Notes qtr,As2, 8th,Ds2, 8th,As2
                Duration _2222, E2,F2,Fs2,G2  
            _23:

            Riff _21, _23
            Repeat "2b", 14

        ;

        _53:
            If_Alt F2, F1
            Shift_Pitch C2, F2

            Riff _21, _53 
        ;

    Loop Raceway_Tri
    Raceway_Tri_Loop:

    Channel Raceway_dmc
        Header F1, T_1f_v8__d12

        Riff Raceway_Tri::_1, Raceway_Tri::_19
        BP .set C2

        Notes hlf,C2, dhf,rest 

        ;Second dhf,rest
        Riff Raceway_Tri::_20_3, Raceway_Tri_Loop
    Loop Raceway_dmc, "Riffed"

py_Segment_End Raceway_Tri


py_Segment Raceway_Noise, PageFit
    _8th .set 6

    Channel Raceway_Noise
        Noise_Header ::Raceway_NB, d50_Kick
        BP .set ::Raceway_NB


        _1:
                Notes qtr,Crash_7,  8th,Shaker_2,    
                    Riff _2_4, _2_8
                Notes 8th,Snare_6

                
                Notes qtr,Hat_Kick, 8th,Shaker_Kick, 
                _2_4:
                    Notes 8th,Hat_2, qtr,Snare_6, 8th,Shaker_2,  
                _2_8: 
                Notes 8th,Hat_2
            ;

            _3:
            Notes qtr,Hat_Kick
                Riff _1 +1, _3 -2

                Shaker_w_Cymbal:
                    Duration _00, Shaker_2, Pre_Cymbal_4
                    Notes 8th,Hat_2
        ;

        _5:
            Notes qtr,Crash_3
            Riff _21_3, _33
            Riff _29_3, _30_5 ;Notes qtr,Shaker_Kick, qtr,Snare_6
                Notes qtr,Shaker_2

            ;19
            Notes whl,Crash_3 
            Notes dqt,Snare_6_Kick,   8th,Snare_8_Kick, 8th,Snare_6_Kick, dqt,Snare_8_Kick 
        ;

        _21:
            Notes qtr,Crash_7
            _21_3:
            Riff _29_3, _37


            _29: 
            Notes 8th,Hat_Kick, 8th,Hat_2
                _29_3:
                        Notes qtr,Shaker_2,    qtr,Snare_6
                            Duration _1111,  Shaker_2, Snare_6, Hat_Kick, Hat_2 ;K_SS

                        _30:
                        Notes qtr,Shaker_Kick, qtr,Snare_6
                            _30_5:
                            Duration  _1111, Shaker_2, Hat_2,   Hat_Kick, Hat_2 ;KK_S
                        
                        _31:
                        Riff _29_3, _30  ;K_SS                                  ;K_SS

                    _32:
                    Duration _00, Shaker_Kick, Pre_Cymbal_4 ;A
                    Notes 8th,Hat_2

                    Duration _6x1, Snare_6,Hat_2 ;B

                        Duration "Cont",     Shaker_2, Hat_2,   Hat_Kick, Hat_2 ;KK_S+
                    
                
                    _33:
                        Riff _29_3, _32

                    _36:
                    Duration _6x1 , Shaker_Kick, Hat_2 ;A

                    Duration "Cont", Snare_6, Hat_2 ;B

                    Duration "Cont", Shaker_2, Hat_2 ;KK_S-


        ;
    
        _37:
        Notes qtr,Crash_3
        _37_3:
            Riff _21_3, _36 +2 ;Shaker_Kick, Hat_2

            Duration "Cont", Snare_8_Kick, Snare_6_Kick, ;B
                    ; _6x1      
            Duration "Cont", Shaker_2, Snare_8_Kick, ;KK_S-
        ;


        _53:
            Riff _21, _37_3

            ;69.3
                ;+1 is  Crash_3
            Riff _21_3, _37
        ;

    Loop Raceway_Noise

py_Segment_End Raceway_Noise


