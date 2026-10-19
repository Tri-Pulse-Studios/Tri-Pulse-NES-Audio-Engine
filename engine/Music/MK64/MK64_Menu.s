



.align 256


py_Segment MK64_Menu_Sq0, PageFit
    _8th .set 6+7

    Channel MK64_Menu_Sq0, Menu_Sq0
        Header G2, Pad_d25_8_3_v12

        _1:
            .byte Tie_Next_Note
            Notes 16*_8th, G2
            Repeat "2b", 1

            Env_Change Lead_sqr_13_0
            Shift_Pitch +Octave

            Notes 14*_8th, rest
        _6_6:


        
        Notes 8th, Gs3
        Duration _00, C4, Fs4

        Shift_Pitch G3, C4
        Notes 16*_8th, C5



        _9:
        Shift_Pitch -Octave
        Shift_Pitch C3, G2
        Env_Change Pad_d25_8_3_v12
        Riff _1, _6_6 

        ;14_6
        Notes 18*_8th, rest


    Loop MK64_Menu_Sq0
    Menu_Sq0__Loop:


    Channel MK64_Menu_Sq1
        Header Ds2, Pad_d25_8_3_v12

        Riff Menu_Sq0::_1, Menu_Sq0::_6_6
        BP .set BP+12

        Notes 6, rest,  7+3, As3,  ;16th, 32nd + 16th
        Notes 6, Ds4 ,             ;16th, 
        Shift_Pitch +5
        Notes           4+16*_8th, G4 ;32nd + 2*whole

        Riff Menu_Sq0::_9, Menu_Sq0__Loop
    Loop MK64_Menu_Sq1, "Riffed"

py_Segment_End MK64_Menu_Sq0


py_Segment MK64_Menu_Tri, PageFit
    _8th .set 6+7

    Channel MK64_Menu_Tri, Menu_Tri
        Header As1, T_6f_m5_v12__d25 ;T_4f_m5__d25

        _1:
        Duration _00, As2, rest

        _1_2:
            Notes 8th,As1, 8th,F2

            Notes 6,As2, 8th,Gs2, 7,Gs2 ;16th, 8th, 16th

            Notes 8th,Fs2, 8th,Gs2, 8th,As2
        ;

        _2:

        Duration _00, rest, As2
        Riff _1_2, _2

    Loop MK64_Menu_Tri
    Menu_Tri__Loop:


    Channel MK64_Menu_dmc
        Header As1, T_1f_12v__d25

        Riff Menu_Tri::_1,  Menu_Tri__Loop

    Loop MK64_Menu_dmc, "Riffed"

py_Segment_End MK64_Menu_Tri




py_Segment MK64_Menu_Noise, PageFit
    _8th .set 6+7

    Channel MK64_Menu_Noise
        Noise_Header ::Menu_NB, d50_Kick

        _1:
            Notes 8th,Crash_3
            Duration _00, Hat_2, Hat_2

            _1_3:
                    Duration _8x0,   Snare_6,  Hat_2,   Hat_2,     Hat_2
                    Duration "Cont", Hat_Kick, Snare_6, Solo_Kick, Pre_Cymbal_4

                _1_7:

                    Riff _1_3, _1_7 -2
                    Duration "Cont", Hat_Kick, Hat_2,   Hat_2,     Hat_2

                _2_3:
                    Riff _1_3, _1_7 -1
                    Duration "Cont",                    Hat_Kick,  Hat_2 

                    _2_7:

                    Riff _1_7, _2_3

            _3_3:

            Riff _1_3, _3_3
            Repeat "2b", 1

            Riff _1_3, _2_7
            Duration _0000, Snare_6, Hat_2, Hat_2, Hat_2
        _9:

        Riff _1, _9 -1
        Duration "Cont", Snare_6, Snare_6

    Loop MK64_Menu_Noise

py_Segment_End MK64_Menu_Noise





    ;/\ Has bug where the Crash doesn't play a second time.


    ;1-byte larger, but likely easier to read
;Channel MK64_Menu_Noise
    ; Noise_Header ::Menu_NB

    ; _1:
    ; Notes 8th,Crash_3
    ; Duration _00, Hat_2, Hat_2

    ; Riff _7_3, _9

    ; ;3
    ; Riff _7, _9
    ; Repeat "2b", 1


    ; _7:
    ;     Riff _8, _8_3
        
    ;     _7_3:
    ;         Riff _8_3, _8_7 -1
    ;         Duration "Cont", Solo_Kick, Pre_Cymbal_4

    ;         Riff _8_7, _9


    ;     _8:
    ;     Duration _0000, Hat_Kick, Hat_2, Hat_2, Hat_2

    ;     _8_3:
    ;     Duration _8x0, Snare_6, Hat_2, Hat_2, Hat_2
    ;     Duration "Cont", Hat_Kick, Snare_6, Hat_Kick, Hat_2

    ;     _8_7:
    ;     Duration _0000, Snare_6, Hat_2, Hat_2, Hat_2
    ; _9:


    ; Riff _1, _9 -1
    ; Duration "Cont", Snare_6, Snare_6

;Loop MK64_Menu_Noise



