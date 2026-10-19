_8th .set 7
.align 256
py_Segment DKs_Jungle_Parkway_Sq0, PageFit
    _8th .set 7

    Channel DKs_Jungle_Parkway_Sq0
        Header Cs3, Pad_d75_8_0

        Duration _8x1, Ds4,rest,Fs3,Cs4,Ds3,rest,Ds3,Cs3
        Duration _8x1, Gs3,Cs4,rest,Ds3,Cs3,Ds4,rest,Fs3

        _2:
        Duration _8x1, As3,Gs3,rest,Fs3,Cs3,Ds4,rest,Cs4
            _2_5:
            Duration _8x1, Cs3,Gs3,Cs3,Ds3,rest,Cs4,Cs3,Fs3

        _3:
        Duration _8x1, rest,Ds4,Cs4,Cs3,rest,As3,Cs3,Fs3
            _3_5:
            Duration _8x1, rest,Cs4,Cs3,Fs3,rest,As3,Cs4,rest

        _4:
        Duration _8x1, Fs3,Cs3,Ds4,rest,Cs4,Cs3,Fs3,Gs3  ;Matches 6 Notes, offset, starting 2.3

            Riff _3_5, _4
            Duration "Cont", rest,Ds4,Cs3,Fs3

        _5:
        Duration _8x1, As3,rest,Fs3,As3,Gs3,Cs4,Ds3,Cs3
        Duration _8x1, As3,Cs4,rest,Gs3,Cs3,As3,rest,Cs4

        _6:
        Duration _8x1, As3,Gs3,rest,Cs4,Cs3,Ds4,rest,As3
        Riff _2_5, _3 +1


        _7:
        Duration "Cont",As3,Ds3,rest,As3,Gs3,As3,Cs3,Cs4
        Duration _8x1,  rest,Gs3,Cs3,Fs3,rest,Fs3,Ds3,rest

        _8:
        Duration _8x1, Fs3,Cs3,As3,Fs3,Ds4,Cs3,Cs4,Fs3
        Duration _8x1, rest,As3,Cs3,Fs3,Cs4,As3,Cs3,Fs3


        ;
    Loop DKs_Jungle_Parkway_Sq0

py_Segment_End DKs_Jungle_Parkway_Sq0



py_Segment DKs_Jungle_Parkway_Sq1, PageFit
    _8th .set 7

    Channel DKs_Jungle_Parkway_Sq1
        Header Ds2, Pad_d75_8_0
        End_Intro:


        Notes 8th,rest, 

        _1_2:
            Notes qtr,Ds2, qtr,Cs3, 5*_8th,As2, 

        _2_3:
        Notes hlf,Ds2,  dqt,As2, 
        

        _3_2:
            Notes 8th,Cs3, dqt,Ds2, 

            Shift_Pitch Ds2, As2
            Notes 8th,Gs3, 8th,As2, 5*_8th,Fs3, 

            Shift_Pitch As2, Ds2
            Notes hlf,Ds2


        _5:
        Notes hlf,As2, hlf,Ds2, 

        _6:
            Notes hlf,As2, dqt,Ds2
            Notes hlf,As2, 8th,Ds2,   

        _7_5:
        Notes hlf,Ds3, hlf,As2,   5*_8th,Ds2



        ;9.2
        Riff _1_2, _2_3 
        Notes 8th,Ds2, dqt,Ds3,  8th,As2, qtr,Fs2, 

        ;11.2
        Riff _3_2, _5


        ;13
        Notes qtr,Cs3, 8th,As2, 8th,Fs2, dqt,Ds2, 8th,Fs2

        ;14
        Riff _6, _7_5

        Notes dqt,As2, 8th,As2
        Notes hlf,As2, hlf,Ds2

    Loop DKs_Jungle_Parkway_Sq1

py_Segment_End DKs_Jungle_Parkway_Sq1



py_Segment DKs_Jungle_Parkway_Tri, PageFit
    _8th .set 7

    Channel DKs_Jungle_Parkway_Tri
        Header B2, T_0f__d25 


        _Long:
        _Short:

            ;1
            Notes 1,B3, 1,B2, _8th-2,rest
            _:
            Notes 8th,rest
            __:

        ;

        _1_3:
            Riff _Long, __ ;Repeat _Long, 2   ;Needs T_M1 to save a single byte.
            Riff _Long, __ 

            _1_7:
                Riff _Short, _
                Riff _Short, _  ;Repeat _1_7, 1

        ;
        _2:
            Riff _1_7, _2 

            Riff _1_3, _2

            ;3
            Repeat _2, 2

        ;

    Loop DKs_Jungle_Parkway_Tri

py_Segment_End DKs_Jungle_Parkway_Tri







py_Segment DKs_Jungle_Parkway_Noise, PageFit
    _8th .set 7

    Channel DKs_Jungle_Parkway_Noise
        Noise_Header ::DKs_NB, d50_Kick ;d25_Kick  

        Volume_Set Vol_75

        ;5
        Duration _8x1, __1_d50, __2, __3, __2, __3,     __2, __2, __1
        Duration _8x1, __2,     __1, __2, __4, __1_d12, __3, __2, __1

        ;6
        Duration _8x1, __1_d50, __1, __2, __4, __2,     __1, __2, __4
        Duration _8x1, __1,     __2, __4, __1, __1_d12, __2, __1, __2

        ;7
        Duration _1111, __1_d50, __2, __3, __2

        Notes 8th,__1, 8th,__2
        Repeat "2b", 3

        Duration _1111, __1_d12, __2, __4, __2

        ;8
        Duration _8x1, __1_d50, __2, __4, __2, __1,     __2, __1, __2
        Duration _8x1, __3,     __2, __1, __2, __1_d12, __2, __4, __2


    Loop DKs_Jungle_Parkway_Noise


    ;Channel DKs_Jungle_Parkway_Noise
        ;     ;5
        ;     Duration _8x1, __1, __2, __3, __2, __3, __2, __2, __1
        ;     Duration _8x1, __2, __1, __2, __4, __1, __3, __2, __1

        ;     ;6
        ;     Duration _8x1, __2, __1, __2, __4, __2, __1, __2, __4
        ;     Duration _8x1, __1, __2, __4, __1, __2, __2, __1, __2

        ;     ;7
        ;     Duration _8x1, __1, __2, __3, __2, __1, __2, __1, __2
        ;     Duration _8x1, __1, __2, __1, __2, __1, __2, __4, __2

        ;     ;8
        ;     Duration _8x1, __3, __2, __4, __2, __1, __2, __1, __2
        ;     Duration _8x1, __3, __2, __1, __2, __1, __2, __4, __2


    ; Loop DKs_Jungle_Parkway_Noise

py_Segment_End DKs_Jungle_Parkway_Noise
