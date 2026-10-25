;============================================================
; Statistics
;============================================================
;Total Size: 134 Bytes
;Sq0: 19B
;Sq1: 62B
;Tri: 21B
;Noise: 21B
;DMC: 11B


_8th .set 10


.align 256

 
;============================================================
; Square 0
;============================================================

Channel Rubify_Sq0
    Header A3, Pad_10_5_0

    _1:
    Notes qtr,A3, qtr,D4, qtr,E4

    _1_3:
        Notes 8th,A3, qtr,D4, qtr,E4
    Repeat _1_3, 1

    _2:
    Notes qtr,C4, qtr,E4, qtr,G4

    Notes 8th,C4, qtr,E4, qtr,A4
    Notes 8th,E4, qtr,G4, qtr,E4

Loop Rubify_Sq0


;============================================================
; Square 1
;============================================================

Channel Rubify_Sq1
    Header $00, Pad_12_7_0

    _1:
        Notes whl,rest

        _1_5:
        Repeat "1b", 5

    ;

    _4:
        Set_Pitch A4

            ;

            Vol_Fade_Out Vol_100, Vol_25, _8th
            _4_1:
                Riff _13_3_Dur, _13_4
                Shift_Pitch -Octave
            Repeat _4_1, 1 ;7B

            _4_5:
            Vol_Fade_In Vol_25, Vol_100, _8th
            Riff _4_1, _4_5

        _5:
        BP .set A0
        Notes whl,A1

        Notes whl,rest

    ;


    _6:
    Repeat "1b",14

    _13:
        Set_Pitch C5
        BP .set C4 ;Written Octave lower.

        _13_1:
        Vol_Fade_Out Vol_100, Vol_25, _8th
            Duration _1111, A4,G4,E4,C4
        Repeat "3b", 1

        _13_3:
        Vol_Fade_Out Vol_100, Vol_25, _8th
            _13_3_Dur:
            Duration _1111, C5,A4,G4,E4
            _13_4:
        Repeat "3b", 1


        _13_5:
        Vol_Fade_Out Vol_100, Vol_25, _8th
            Duration _1111, D5,C5,B4,G4
        Repeat "3b", 1

        _13_7:
        Shift_Pitch +7

        .byte Clear_Special_Effects
        Duration _8x1, E5,D5,C5,A4, C5,B4,A4,G4

        ;Riffs can re-read some data, but it also restarts the fadeout. 

        _15:
        Riff _13, _15

    ;

    _17:
    Notes whl,A4

    _17_5:
        Riff _1_5, _6

        _22:
        Riff _1, _4 

    ;

    _25:
        Riff _13, _17
        Riff _13, _17_5

    ;

Loop Rubify_Sq1, _1_5


;============================================================
; Triangle
;============================================================

Channel Rubify_Tri
    Header E3, T_0f_12v__d25

    _1:
        Notes whl,rest
        Repeat "1b", 15
    ;

    _9:
        Notes hlf,rest, whl,C4, hlf,D4

        Duration _8x2, C4,D4,E4,D4, C4,A3,G3,E3
        _11:

        Riff _9, _11

    _13:
    Riff _1, _9

    _21:
    Riff _9, _11
    Repeat "2b", 5

Loop Rubify_Tri


;============================================================
; DMC
;============================================================

Channel Rubify_dmc
    Header E2, T_0f_12v__d25

    Notes 16*_8th,E2, 16*_8th,G2
    Notes whl,E2, whl,G2, 16*_8th,A2

Loop Rubify_dmc


;============================================================
; Noise
;============================================================

Channel Rubify_Noise
    Noise_Header ::Rubify_NB, 0;_d50_Kick

    _1:
        Notes hlf,Solo_Kick, hlf,Solo_Kick
        Repeat "2b", 6

        _4_5:
        Notes dqt,Solo_Kick

        Notes 8th,Pre_Cymbal_4
     
        Notes hlf,Rasp_2_Kick

    

    _5:
        Notes qtr,Solo_Kick, qtr,Shaker_2
        Repeat "2b", 1

        Notes qtr,Solo_Kick, 8th,Shaker_2

        If_Alt Pre_Cymbal_4, rest
        Notes 8th,Pre_Cymbal_4

        Notes qtr,Rasp_2_Kick, qtr,Shaker_2

    _6:
        If_Alt "Toggle"
        Riff _5, _6


Loop Rubify_Noise, _5

