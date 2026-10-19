_8th .set 7
.align 256
py_Segment Frappe_Snowland_Sq0, PageFit
_8th .set 7

    Channel Frappe_Snowland_Sq0
        Header E3, Pad_d25_8_3_v12

        _1:
                Notes qtr,E3, qtr,E3, qtr,E3, 8th,rest
                _1_5:
                Notes qtr,F3, qtr,F3, 8th,F3, qtr,F3, qtr,rest

                _2:
                Notes qtr,G3, qtr,G3, qtr,G3, 8th,rest
                _2_5:
                Riff _1_5, _2

            _3:

            Riff _1, _3
            Repeat "2b", 7
        ;

        _19:
                Riff _2, _2_5 ;G3

                Shift_Pitch E3, Fs3
                _19_5:
                Riff _1_5, _2  ;F3-G3
                
            _20:
            Shift_Pitch Fs3, E3

            _20_BP:
            Riff _19, _20
            BP .set BP+2 ;E3 -> Fs3

        ;

        _21:
            Riff _2, _2_5 ;A3

            Shift_Pitch Fs3, G3
            _21_5:
            Riff _1_5, _2  ;F3-Gs3
            Riff _1, _1_5 ;E3-G3

            _22_5:
            Shift_Pitch G3, Fs3


            Riff _19_5, _20_BP
            BP .set BP-2 ;G3-F3

            Notes qtr,F3, qtr,F3, qtr,F3, 8th,rest


            Riff _21_5, _22_5

            

            Notes qtr,G3, qtr,G3, 8th,G3
            _24_8:
            Notes qtr,Fs3, qtr,rest

        ;


        ;25
            Shift_Pitch E3, Fs3 ;If This moves to 24_5, It can Riff to _1. An Exit shift to _29 is required though.
            Riff _21, _24_8

            BP .set E3
            Notes qtr, G3, qtr,rest

        ;

        Riff _1, _3
        Repeat "2b", 1

    Loop Frappe_Snowland_Sq0

py_Segment_End Frappe_Snowland_Sq0


py_Segment Frappe_Snowland_Sq1, PageFit
_8th .set 7

    Channel Frappe_Snowland_Sq1
        Header Fs3, Pad_sqr_s4

        _1:
            Duration _8x1, E4,G3,C4,G3,E4,G3,C4,G3
            _1_5:
            Duration _8x1, F4,A3,C4,A3,F4,A3,C4,A3

            _2:
            Duration _8x1, G4,B3,D4,C4,G4,B3,D4,C4
            Riff _1_5, _2

            _3:
            Riff _1, _3
            Repeat "2b", 7

        ;


        _19:
            Duration _1111, G4,B3,D4,B3
            Repeat "3b", 1

            Duration _1111, G4,As3,Cs4,As3
            Repeat "3b", 1

            _20:
            Duration _1111, G4,C4,A3,C4
            Repeat "3b", 1

            Duration _8x1, G4,D4,B3,D4, G4,B3,D4,G3

        ;

        _21:
            Duration _1111, A3,C4,E4,G4 ;May start w/ G3 isntead
            Repeat "3b", 3

            

            ; _22_BP:
                Shift_Pitch Fs3, E3

                Duration _1111, G3,B3,D4,E4
                Repeat "3b", 1

                Duration _1111, G3,B3,C4,E4, ;4-1-4
                Repeat "3b", 1


                _23:
                Duration _1111, F3,A3,C4,E4,
                _23_5:
                Repeat "3b", 3

            _24:
            Duration _1111, E3,G3,B3,D4,
            Repeat "3b", 2

            Duration _1111, E4,C4,A3,C4
            Shift_Pitch E3, Fs3
        ;


        _25:
            ; Duration _1111, G3,C4,E4,G4
            ; Repeat "3b", 1
            
            ; Duration _1111, Fs3,C4,E4,G4 ;Only Difference is First two notes are Down Whole-Step. Doesn't make much sense.
            ; Repeat "3b", 1


            Riff _21, _24 ;_22_BP, _24
                BP .set BP-2

            ;27
            Riff _23, _23_5
            Repeat "2b", 1

            Duration _8x1,  F3,A3,B3,D4,
            Duration "Cont",E4,D4,B3,G3
            Shift_Pitch E3, Fs3


        ;


        _29:
            Riff _1, _3
            Repeat "2b", 1

        ;

    Loop Frappe_Snowland_Sq1

py_Segment_End Frappe_Snowland_Sq1


py_Segment Frappe_Snowland_Tri, PageFit
_8th .set 7

    Channel Frappe_Snowland_Tri
        Header {C4, +Octave}, Choir_v12_1f

        ;1
            Notes 32*_8th, rest
            Repeat "2b", 1

        ;

        _5:
                Riff _9, _10_8
                Shift_Pitch C4, G3

                Riff _10_8, _13
                Shift_Pitch G3, C4 ;An If-Alt Riff/Repeat breaks even here.

                _9:
                    Notes qtr,rest
                    _5_2:
                    Duration _1111, E4,F4,G4,C5
                    Notes 8th,rest, 15*_8th,G4

                    _6_4:
                    Duration _8x1, F4,rest,E4,rest,F4,E4,rest,C4

                    _10_8: ;Shift C4-G3
                    Notes 8th,rest, 8th,C4,  

                    _11:
                    Notes 8th,D4, 21*_8th,C4,  10*_8th,rest
                        
                _13:
            Riff _5, _11

        ;



        _19:
        Env_Change Lead_d12_s7_v8_1f
        Shift_Pitch C4, E4
        Notes whl,B4, whl,As4, whl,A4, whl,G4, 

        _21:
            Notes qtr,rest
            Duration _1111, A4,B4,C5,E5
            Notes 8th,rest, 7*_8th,D5, qtr,C5,  qtr,B4, 
        _22_2:
        Notes 8th,A4, 13*_8th,G4, 
        

        ;23
        Notes qtr,rest
        Duration _1111, E4,F4,G4,A4
        Notes 8th,rest, 7*_8th,G4, qtr,F4, qtr,E4, 

        ;24.2
        Notes 8th,F4, 13*_8th,G4

        ;25
        Riff _21, _22_2
        Notes 8th,D5, 13*_8th,C5

        ;27
        Notes 7*_8th,E5, 9*_8th,D5
        Notes 7*_8th,C5, 8th,B4, 8th,A4, 8th,rest, whl,D5

        ;29.2
        Shift_Pitch E4, C4
        Riff _5_2, _6_4

        Notes 21*_8th, rest
        Repeat "2b", 1  ;10 + 16 + 16
    
    Loop Frappe_Snowland_Tri

py_Segment_End Frappe_Snowland_Tri


.align 256
py_Segment Frappe_Snowland_dmc, PageFit
_8th .set 7

    Channel Frappe_Snowland_dmc
        Header G1, T_1f_v8__d12

        _1:
                Duration _4444, C2,G1, D2,G1
                Notes hlf,E2, hlf,G1, hlf,D2
            _2_7:
            Notes hlf,G1

            _3:
                Riff _1, _2_7
            _4_7:
            Notes qtr,G1, 8th,A1, 8th,B1

        _5:
        Riff _1, _5
        Repeat "2b", 2

        Riff _1, _3


        _19:
            Duration _4444, E2,E2, Ds2,Ds2
            Duration _4444, D2,D2, G2,G1

            ;21
                Duration _4444, F2,F2, B1,B1

                _22:
                    Duration _4444, E2,E2, A2,A2
                    Duration _4444, D2,D2, G2,G2
                    

                _24:
                
                Duration _4444, C2,C2, G2,Fs2
                
            ;

            ;25
                Shift_Pitch G1, B1
                Duration _4444, F2,F2, B2,B2 ;vs B1
                Shift_Pitch B1, G1

                _26:
                    Riff _22, _24 -1
                    Duration "Cont", A2,D2

                _28:
                Duration _4444, G2,G2,G1,G2

            ;

        ;

        ;29
        Riff _1, _5

    Loop Frappe_Snowland_dmc

py_Segment_End Frappe_Snowland_dmc


py_Segment Frappe_Snowland_Noise, PageFit
_8th .set 7

    Channel Frappe_Snowland_Noise
        Noise_Header ::Frappe_Snowland_NB, 0 
        BP .set ::Frappe_Snowland_NB

        Duration _1111, Hat_2 , Hat_2 , Shaker_2, Hat_2 

    Loop Frappe_Snowland_Noise

py_Segment_End Frappe_Snowland_Noise

