_8th .set 11

.align 256

py_Segment Race_Results_Tri, PageFit
    _8th .set 11

    Channel Race_Results_Tri ;, R_Tri
        Header G3, Lead_sqr_13_0

        Notes 11*_8th,rest
        Repeat "2b", 7

        _9:
            Notes 6,Ds4,  3*_8th -6,E4,  7*_8th,G4

            ;10
            Duration _00, Ds4,E4
            Notes 10*_8th,C4, 8th,A3,  8th,C4, 8th,A3,

        _11_2:
        Notes 6,C4,  3*_8th -6,D4,
        Notes 17*_8th, D4

        _13:
            Riff _9, _11_2
        Notes 6,D4,  2*_8th -6,Ds4,  8th,D4, ;Can Riff Ds4, E4
        Notes 19*_8th, C4

        ;17.3
        Notes 6,F4,  2*_8th -6,G4,

        Notes 8th,F4, qtr,Ds4, 
        Notes qtr,D4, qtr,C4, 

        Notes 10*_8th,G3 

        _19:
        Notes 8th,A3, 8th,As3, 10*_8th,C4, 
        
        _20:
        Notes hlf,rest, qtr,F4, (5 +2)*_8th,F4

        ;21.3
        Env_Change T_1f_12v__d25
        Shift_Pitch G3,C4
        Duration _8x0, C5,As4,G4,F4, As4,Gs4,F4,Ds4

        Shift_Pitch C4, F3
        Duration _8x0, D4,C4,As3,A3, G3,A3,F3,F3
        Notes 8th,F3, 

        ;22
        Env_Change Lead_sqr_13_0
        
        Notes hlf,G3, whl,C4, 21*_8th,Ds4
    Loop Race_Results_Tri

py_Segment_End Race_Results_Tri




py_Segment Race_Results_Sq0, PageFit
    _8th .set 11

    Channel Race_Results_Sq0, Results_Sq0
        Header G2, Lead_12to25_s6_v12

        If_Alt "Toggle"

        Riff _18, _19
        Repeat "2b", 15

        _17:
            .byte Volume_Slow_Fade
            If_Alt A2, Gs2
            Notes whl,A2, dqt,rest

            _18:
            .byte Volume_Slow_Fade
            Notes whl,G2, dqt,rest
            
        _19:
        Riff _17, _19
        Repeat "2b", 2 ;x4



    Loop Race_Results_Sq0
    Results_Sq0__Loop:


    Channel Race_Results_Sq1
        Header E2, Lead_12to25_s6_v12

        

        _1:
        Riff Results_Sq0::_17, Results_Sq0::_19
        Repeat "2b", 7 ;x8

        ;17
        Shift_Pitch E2, D2
        Riff Results_Sq0::_17, Results_Sq0__Loop

    Loop Race_Results_Sq1, "Riffed"

py_Segment_End Race_Results_Sq0




py_Segment Race_Results_dmc, PageFit
    _8th .set 11

    Channel Race_Results_dmc
        Header C2, T_M11__d25 ;T_0f__d25

        _1:
            Notes qtr,C3, qtr,C2, qtr,C3
            Notes 8th,C2, qtr,C2, qtr,C3  ;8th,qtr  cannot combine. M11 means its not re-init
        _2:


        Riff _1, _2
        Repeat "2b", 14 ;Total 16

        Shift_Pitch C2, F1
        Riff _1, _2
        Repeat "2b", 6 ;Total 7

        Notes 11*_8th,rest ;F2

    Loop Race_Results_dmc

py_Segment_End Race_Results_dmc
 



py_Segment Race_Results_Noise, PageFit
    _8th .set 11

    Channel Race_Results_Noise
        Noise_Header ::Results_NB, d25_Kick

        _1:
            Notes 8th,Crash_3
            Duration _00, Hat_2, Hat_2

                Riff _7_3, _8

            ;2
            Duration _0000,   Shaker_2,    Hat_2,    Hat_Kick,  Hat_2,  
            Repeat "3b", 1  ;Offset Kicks

                ;2.5
                Riff _8_5, _9 -1
            Duration "Cont", Shaker_2, Hat_2 


            _3:
            Riff _7, _9

            _5:
                Riff _7, _7_7 -1
            Duration "Cont", Shaker_Kick, Hat_Kick ;Double Kick in Middle

                Riff _7_7, _9 -1
            Duration "Cont", Shaker_2, Hat_2 ;No Double Kick at End





            _7:
            Duration _0000, Hat_2, Hat_2, Shaker_Kick, Hat_2

            _7_3:
                    Duration _8x0,   Hat_Kick,  Hat_2,  
                    Duration "Cont",  Shaker_2,    Hat_2,   Snare_6,   Hat_2, 
                    Duration "Cont",  Shaker_2,    Hat_2,    

                    _7_7:
                    Duration _6x0,                          Hat_2,     Hat_2, ;4
                    Duration "Cont", Shaker_Kick, Hat_2,    Snare_6,   Hat_2,  

                    _7_10:
                    Duration _0000,  Shaker_Kick, Hat_2,    Hat_2,     Hat_2,  ;3
                    
                _8:
                Repeat _7_10, 2 

                _8_5:
                    Duration _8x0,   Snare_6,   Hat_2,    Hat_Kick,  Hat_2,  
                    Duration "Cont", Shaker_2,    Hat_2,    Hat_Kick,  Hat_2,  

                    ;4.9
                    Duration _6x0,   Shaker_Kick, Hat_2,    Snare_6,   Hat_2, 
                    Duration "Cont", Shaker_Kick, Hat_Kick  ;Double Kick
                    
        ;



        _9:
        Riff _1, _9, "3b"


        ;17
        Riff _1, _7_10, "3b" ;By ONE Byte  (Don't Fuss. I likely have to tear this to the ground to "Fix" the off-timing anyway.)
        Duration _00,  Shaker_Kick, Hat_2,

        Duration _0000,  Hat_2, Hat_2,  Shaker_2, Hat_2,   
        Repeat "3b", 3

        Duration _0000, Snare_6, Hat_2, Shaker_Kick, Hat_Kick
        Repeat "3b", 1


    Loop Race_Results_Noise

py_Segment_End Race_Results_Noise
