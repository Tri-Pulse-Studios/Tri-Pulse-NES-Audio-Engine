_8th .set 7

py_Segment Battle_Tri, PageFit
    _8th .set 7

    Channel Battle_Tri
        Header D4, T_1f_12v__d25

        
        _1:
                    Notes qtr,rest

                    Notes 8th,G4, 8th,rest
                    Repeat "2b", 5

                    Notes 8th,G4, qtr,G4
                _2:
                
                Notes qtr,B4, 13*_8th,rest

                Riff _1, _2
                Notes qtr,D4, (13+14)*_8th,rest



                _6_BP:
                Shift_Pitch D4, G3
                _6:
                    Notes 8th,B3, 8th,rest, 8th,B3, qtr,D4

                _6_2:
                Notes dqt,G3, (10+14)*_8th,rest

                ;8
                Riff _6, _6_2
                
            _8_2:
            Notes dqt,D4, 10*_8th,rest


            ;9
            Shift_Pitch G3, D4
            Riff _1, _8_2
            BP .set G3
            Notes dqt,G4, 10*_8th,rest

        ; Via Hoot Env
            ;BP D4->G3

            .byte Set_Env_Bank_Byte, SFX_Hoot_M8 ;Env_Change SFX_Hoot_M8
            Shift_Pitch +Octave

            _17:
                        Notes qtr,rest, qtr,Fs5, hlf,C5, dqt,Fs5,  
                    _17_6:

                    Notes dqt,Fs5, qtr,C5

                    _18:
                    Riff _17, _17_6
                _18_6:
                Notes dqt,C5, 8th,C5, 8th,C5


                _19:
                Riff _17, _19
                Repeat "2b", 1

                Riff _17, _18_6
                Notes dqt,Fs5, 8th,Fs5, 8th,Fs5

            ;


            .byte Set_Env_Bank_Byte, T_1f_12v__d25  ;Env_Change T_1f_12v__d25
            Shift_Pitch G4, D4
        ;

        
        
        _25:
            ;25
                Notes qtr,rest
                Duration _1111, Ds4,Ds4,E4,C5
                Notes 8th,rest, 9*_8th,C5

                ;26
                Duration _6x1, A4,rest, G4,rest, A4,rest,
                Notes 8th,G4
                Notes 9*_8th,E4

                ;27
                Notes 14*_8th,rest
                Duration _1111, G4,rest,E4,G4

                Notes 14*_8th,rest
            
            ;


            _29:
                    Shift_Pitch D4, A3
                    Notes dhf,rest

                    _29_3:
                    Duration _1111, A3,As3,B3,G4
                    _29_5:
                Notes dhf,rest

                ;30
                Notes hlf,rest, dqt,B4, dhf,G4, dqt,rest

                ;31
                Notes dhf,rest
                _31_4:
                    Riff _29_3, _29_5
                    Notes 8th,rest
                Repeat _31_4, 1

                ;32
                Notes hlf,rest, dqt,B4, dqt,G4, dhf,B3

                Shift_Pitch A3, D4 ;Undo

            ;


            ;33
            Riff _25, _29 

        ;

        _37:
            Notes hlf,rest
            Notes qtr,A4, qtr,rest, qtr,Fs4
            Notes 8th,rest, qtr,D4, dqt,rest

            _38:
            Duration _8x1, E4,rest, E4,rest, G4,rest, E4,G4
            Notes whl,rest

            _39:
            Riff _37, _39
            Repeat "2b", 1


            Riff _37, _38 +1
            Duration "Cont", C5,rest, C5,rest, B4,rest, B4,A4
            Notes dqt,rest, 5*_8th,C5


    Loop Battle_Tri

py_Segment_End Battle_Tri



.align 256
py_Segment Battle_Sq0, PageFit
    _8th .set 7

    Channel Battle_Sq0, B_Sq0
        Header Ds3, Pad_d75_8_0
        
        Notes 8th,rest ;The whole channel is shifted forward

        _1:
            Env_Change Pad_d75_8_0
            Notes 8th,rest, hlf,E3, hlf,E3, dqt,E3

            Env_Change Lead_12to25_s6_v12
            Notes hlf,E3
            
            _2:

            Riff _1, _2
            Repeat "2b", 21
            Riff _32, _33 ;Ds3

        ;

        _25:
                If_Alt -1, -2
                Shift_Pitch -1 ;Sq1
                Riff _1, _2
            _26:
            Repeat "2b", 3



            _29:
                If_Alt 1, 2
                Shift_Pitch 1 ;Sq1
                Riff _1, _2
            _30:
            Repeat "2b", 2

            _32:
                Riff _1, _2 -1

                If_Alt E3, Ds3
                Notes hlf,E3 ;Sq1
            _33:

            Riff _25, _29
            BP .set BP-2

        ;

        _37:
            Riff _29, _30 ;+2
            Riff _25, _26 ;-2

            Repeat _37, 3

        ;

        _45: ;Sq1 Cannot riff a $c1, $ptr Loop

    Loop Battle_Sq0, _1


    Channel Battle_Sq1
        Header B2, Pad_d75_8_0

            Notes 8th,rest ;The whole channel is shifted forward

        _1: ;Sq1 Cannot riff a $c1, $ptr Loop

            If_Alt "Toggle"
            Riff B_Sq0::_1, B_Sq0::_45, "3b"

    Loop Battle_Sq1, _1

py_Segment_End Battle_Sq0



py_Segment Battle_dmc, PageFit
    _8th .set 7

    Channel Battle_dmc
        Header D1, T_0f_v8__d12


            ;Only One Byte more than rests via Env Cut-off.
                ;I don't have a ready-to-use Env either.
        ;1

            Riff _21, _23
            Repeat "2b", 9


            _21:
            Riff _22, _23 -1
            Notes dqt,D1

            _22:
                Duration _8x1,  G1,rest,G1,rest
                Duration "Cont",B1,rest,B1,rest 
                Duration _1111, D2,rest,D2, D1

                _22_7:
                Notes 8th,rest, dqt,Fs1

            _23:
            Riff _21, _22_7 -1
            Duration "Cont", D2,Cs2

            Notes 8th,rest, dqt,Cs2

        ;

        _25:
                Shift_Pitch D1,G1
                Riff _21, _23

                Riff _21, _23 -1
                Notes dqt,G2

            _29:
            Shift_Pitch G1,D1
            Riff _21, _25

            ;33
            Riff _25, _29
            BP .set G1

        ;

        _37:
            Shift_Pitch +2 ;A1
            Riff _21, _22

            Shift_Pitch -2
            Riff _21, _22

            Riff _37, 3;  +2

            Shift_Pitch -2
            Riff _22, _23 -1
            BP .set G1
            Notes dqt,G2

            _41:
            Riff _37, _41

    Loop Battle_dmc

py_Segment_End Battle_dmc



py_Segment Battle_Noise, PageFit
    _8th .set 7

    Channel Battle_Noise
        Noise_Header ::Battle_NB, d25_Kick

        _1:
            Notes qtr,Crash_3
            Riff _2_2, _3


            _2: 
                Notes 8th,Hat_Kick, 
                _2_1:
                Notes 8th,Hat_2

                _2_2:
                Duration _8x1,   Snare_6, Hat_2, Hat_Kick, Hat_2
                Duration "Cont", Snare_6, Hat_2, Hat_Kick, Hat_2 ;A Riff saves no data. External Repeats.
                _2_6:
                Duration _1111,   Snare_6, Hat_Kick, Hat_2, Hat_Kick 
                _2_8: ;Heavy _17 Riff Use.
                Notes 8th,Snare_6, 8th,Hat_2
            _3:

            Riff _2, _3
            _4:
            Repeat "2b", 5 

            _9:
            Riff _1, _9

        ;

        _17:
            ;Just Complex Timing
            Notes qtr,Crash_3
            Riff _2_2, _2_8
        
                Riff _20_8, _21_1
                ;Notes 8th,Snare_6_Kick

            ;18.1
            Riff _2_1, _2_8 -1 ;_1111
            Duration "Cont", Snare_6,Snare_6_Kick

            Duration _00, Snare_6,Snare_6 ;Offset.
            Notes 8th,Snare_6


            ;19
            Riff _2, _3 -1
            Notes 8th,Snare_6



            ;20
            Riff _22, _22_6
                ; Duration _8x1, Snare_6_Kick, Hat_2, Snare_6, Snare_8,   Hat_Kick, Hat_2, Snare_6, Hat_2
                ; Notes 8th,Hat_Kick, 8th,Hat_2,  ;Snare 6's and 8's swapped. Minor Change saves 5b

            _20_6:
                Duration _1111, Snare_6, Snare_6_Kick,  Hat_2, Hat_Kick
                _20_8:
                Notes 8th,Snare_6
                Duration _00, Snare_6,Snare_6 



                _21:
                Notes 8th,Snare_6_Kick
            _21_1:
            Riff _2_1, _2_6 -2 ;_8x1
            Duration "Cont", Snare_6,Snare_6, Hat_Kick,Hat_2 ;One Extra snare Costs 4b. Seems important.

            Riff _2_6, _2_8
            Notes 8th,Snare_8, 8th,Hat_2


            _22:
                Duration _8x1, Snare_8_Kick, Hat_2, Snare_8, Snare_6,   Hat_Kick, Hat_2, Snare_6, Hat_2
                Notes 8th,Hat_Kick, 8th,Hat_2

            _22_6:
            Duration _00, Snare_6,Snare_6,
            Notes 8th,Snare_8_Kick

            Duration _1111, Hat_2,Hat_Kick,Snare_6,Hat_2


            ;23
            Riff _2, _2_6 -1
            Duration "Cont", Snare_6_Kick, Hat_2

            Riff _20_6, _21 


            ;24
            Duration _1111, Snare_6_Kick,Hat_2, Snare_6,Hat_2
            Repeat "3b", 1

            Duration _8x1,  Snare_6_Kick, Hat_2, Snare_6, Snare_6_Kick
            Duration "Cont",Snare_6, Snare_6_Kick, Snare_6, Snare_6

        ;

        _25:
                Riff _1, _4
                Riff _2, _3
            ;29
            Repeat _25, 4

        ;

    Loop Battle_Noise

py_Segment_End Battle_Noise
