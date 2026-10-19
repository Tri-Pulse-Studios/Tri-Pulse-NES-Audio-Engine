

.align 256

;[WARN] Due to 256f limit to a rest duration,  this song loops 2*_8th less than FamiStudio Implies it should. (The rest is a qtr shorter than normal.)

py_Segment MK64_Title_Sq0, PageFit
    _8th .set 6

    Channel MK64_Title_Sq0, Title_Sq0
        Header B2, Choir_v12_1f
        If_Alt "Toggle"

        _1:
            Notes _8th*32, G3
            Notes _8th*32, A3

            ;3
            If_Alt A3, Gs3
            Notes _8th*32, A3

            _4:
            Notes _8th*32, G3
        ;

        ;5
            Riff _1, _4

            ;8
            Notes _8th*26, G3
            Notes dqt,F3, dqt,Fs3

        ;

        ;9
            Riff _1, _4

            ;12
            Notes dhf,G3, 
            If_Alt C4, B3
            Notes dhf,C4, 
        
            _12_3: ;Sq1 Out. Tri In
            If_Alt +1   
            Notes _8th*40,As3

        ;

        Notes _8th*42, rest


    Loop MK64_Title_Sq0
    Title_Sq0_Loop:


    Channel MK64_Title_Sq1
        Header Gs2, Choir_v12_1f

        Riff Title_Sq0::_1, Title_Sq0::_12_3


        Notes _8th*36,F3 ;Can't If_Alt. Different Length

        Env_Change Pad_sqr_s4
        Duration _1111, Gs2,Ds3, Gs3,As3

        Shift_Pitch +7
        Notes 8th,Ds4,  _8th*41,rest

    Loop MK64_Title_Sq1


    Channel MK64_Title_Tri
        Header F3, T_M6

        _1:
            Notes whl,rest
            Duration _1111, G4,G3, rest,G3
            Notes hlf,G4
        _5:
        Repeat "5b", 6 ;Riff _1, _5 ;x5

        Notes 16*_8th,rest

        Env_Change T_1f_12v__d25

        _5_no_Env:
            Notes _8th*24,G3, dhf,A3, qtr,G3

            ;6
            Notes dhf,Fs3, _8th*20,D4

            _6_7:
            Notes _8th*5,A3
            Duration _00, As3,B3

            ;7
            Notes _8th*10,C4, dhf,B3, 
            Notes _8th*10,A3, dhf,B3

            ;8
            Notes _8th*16, C4
            Notes _8th*10,G3, dqt,F3, dqt,Fs3

        ;

        ;9
            Riff _5_no_Env, _6_7
            
            ;10.7
            Notes dhf,C4
            ;11
            Notes dhf,F4, _8th*10,C4
            Notes _8th*10,B3, dhf,D4

        ;

        ;12
        Notes dhf,C4, dhf,Ds4

        Riff Title_Sq0::_12_3, Title_Sq0_Loop
    Loop MK64_Title_Tri, "Riffed"

py_Segment_End MK64_Title_Sq0



py_Segment MK64_Title_dmc, PageFit
    _8th .set 6

    Channel MK64_Title_dmc
        Header C1, T_1f_v8__d12

        _1:
            Notes _8th*32, C2, _8th*26, C2
            Notes dqt,G1, dqt,Fs1

            Notes _8th*32,F1,  _8th*32,C2

        _5:

                Riff _5_5, _5_8
                Notes hlf,D2, qtr,G1

                _5_5:
                    Notes hlf,C1, hlf,G1, 
                    Notes 8th,C2, 8th,rest

                _5_8:
                Notes hlf,C2, qtr,G1

            _6:

            Shift_Pitch C1, D1
            Riff _5, _6

            ;7
            Shift_Pitch D1, G1
        _7_BP:
        Riff _5_5, _6
        Repeat "2b", 1

        ;8
        Shift_Pitch G1, C1
        Riff _5_5, _6

        ;8.5
        Riff _5_5, _5_8
        Notes dqt,As1, dqt,B1

        ;9
        Riff _5, _7_BP
        BP .set G1

        ;11
        Riff _5, _6

        ;12
        Notes dhf,C2, dhf,As1
        Notes whl,Gs1

        Duration _1111, Gs1,rest,Cs2,Gs1, 
        _12_7:
            Duration _8x1, Gs1,Ds2,Gs1,Gs1, Gs1,rest,Gs1,rest
            Repeat _12_7, 1

        ;13.3
        Duration _8x1, Gs1,Gs1,Gs1,Ds2, Gs1,rest,Cs2,rest, 
        Duration _111_R, Gs1,Ds2,rest, Repeat_x2

        ;13.7
        Duration _8x1, rest,Ds2,rest,  Gs1,rest,Ds2,rest,   Gs1,
        Duration _8x1, rest,Gs1,Ds2,   Gs1,rest,Gs1,Ds2,    Gs1,

        ;14.3
        Notes _8th*21,rest ;-2 of full measure


    Loop MK64_Title_dmc

py_Segment_End MK64_Title_dmc





            ;This Noise is a total Dissaster.
                ;Its waaay more Complex than it needs to be.
                    ;I can't dechiper it well.
py_Segment MK64_Title_Noise, PageFit
    _8th .set 6

    Channel MK64_Title_Noise
        Noise_Header ::Title_NB, d50_Kick

        _1:
                Notes qtr,Crash_3
                _1_2:
                    Duration _6x1,   Hat_2, Hat_2, 
                    Duration "Cont", Rasp_2, Rasp_c, Hat_2, Rasp_c

                    Notes qtr, Hat_2
                    Duration _6x1,  Rasp_2, Rasp_c, 
                    Duration "Cont", Hat_2, rest, Hat_2, Rasp_c

                _1_5:

                Notes 8th,Hat_2, 8th,Rasp_c
                Riff _1_2, _1_5


                ;2
                ;Riff _1_5, _2
                Repeat "4b", 1 

            _2_5:
            Duration _8x1, Snare_6, Snare_6, Snare_6, Rasp_c
            Duration "Cont", Rasp_2, Rasp_c, Hat_2, Rasp_c

            ;2.7
            Notes qtr,Hat_2, qtr,Crash_7, 
            _2_8:
            Notes 8th,Hat_2, 
            Notes qtr,Crash_3, 8th,Hat_2
            
            ;3
            Notes qtr,Crash_7
            _3_2:
            Riff _1_2, _2_5


            ;3.5
            ;Volume to half, ascend slowly
            Vol_Fade_In Vol_50, Vol_100, 4*_8th

            Notes 8th,Snare_6
            Repeat "1b", 15
        ;
    

        _5:
        Notes qtr,Crash_3 ;Future loops lead w/ Crash_7
        _5_2: 
            Riff _6_2, _6_5
            
            ;5.5
            Riff _6, _6_4
            Notes 8th,Snare_6, 8th,Snare_6, qtr,Hat_2

            _6:
                Notes qtr,Hat_Kick
                _6_2:
                Notes 8th,Hat_2, 8th,Hat_Kick  ;Should be Solo_Kick, but doesn't fit.
                Duration _2222, Snare_6, Hat_Kick, Hat_2, Hat_Kick, 
                _6_4:
                Notes qtr,Snare_6, qtr,Hat_2
            _6_5:

            Riff _6, _6_4 -1
            _6_7:

            Duration "Cont", Hat_2, Crash_7
            Riff _2_8, _3_2 ;Crash 3, Crash 6

            _7_2:
            Riff _6_2, _6_5
            Riff _6,   _6_5

        ;


        _8:
            Riff _6, _7_2
            Riff _5_2, _8

            ;12
            Notes qtr,Crash_7, 8th,Hat_2, 8th,Hat_Kick ;Kick is Offset

            Duration _6x2,                    Snare_6, Crash_3, 
            Duration "Cont", Hat_2, Hat_Kick, Crash_7, Hat_2

            ;12.5
            Riff _6, _6_5
            Repeat "2b", 1

        ;13.5
        Vol_Fade_Out Vol_100, Vol_25, 24 ;hlf
        Riff _6, _6_7
        Duration "Cont", Hat_2, Hat_2,

        Notes 18*_8th, Snare_6 

    Loop MK64_Title_Noise

py_Segment_End MK64_Title_Noise


