;147 Bytes

_8th .set 11+11


.align 256

;============================================================
; Square 0
;============================================================

Channel Schala_Theme_Sq0
    Header F4, Pad_d50_6_3_1

    Duration _8x2, As4,F4, Gs4,F4,   As4,F4, C5,Gs4

Loop Schala_Theme_Sq0


;============================================================
; Square 1
;============================================================

Channel Schala_Theme_Sq1
    Header As3, Pad_d50_6_3_1

    Notes whl,rest, whl,rest

    _5:
    Notes 8th,As3, 8th,Cs4, qtr,Ds4

Loop Schala_Theme_Sq1, _5


;============================================================
; Triangle
;============================================================

Channel Schala_Theme_Tri
    Header As3, T_12v_0f__d25, Vib_Very_Shallow

    _1:
        Duration _8888, rest,rest, As4,Gs4
        Notes whl,F4, hlf,Ds4, qtr,Cs4, qtr,C4


        Shift_Pitch -Octave ;Just want Vib Shallow

        _13:
            .byte Tie_Next_Note
            Notes whl,As3
        Repeat _13, 2
            Notes whl,As3

    ;

    _21:
        Set_Env T_12v_3f_m3
        Set_Pitch Gs3

        Notes 7*_8th, Ds4
        Duration _00, Cs4,As3

        Notes hlf,F4, hlf,Cs4

        _25:
        Notes 5,C4, 5,Cs4, 1+ 11+ _8th*6,C4, 8th,Cs4

        _27:
        Notes hlf,Ds4, hlf,Gs3, 7*_8th,As3

        
    ;
    Notes 8th,As3

    _31:
        Notes hlf,As4, dqt,Gs4, 8th,Fs4

        _33:
        .byte Tie_Next_Note
        Notes whl,F4, whl,F4
        

    _37:
    Riff _21, _31 -1

    Notes 7,C4, 8,Cs4, 7,C4 ;Triplets.

    _47:
    Notes 7*_8th,As3, 8th,Gs3

        .byte Tie_Next_Note
        Notes whl,As3, whl,As3

    _53:
    Notes hlf,rest
    Repeat "1b", 6

    _60m:
    Set_Env T_0f__d12

    Shift_Pitch -Octave
    _60:
    Notes 6,As2, 5,C3, 6,Cs3, 5,F3

    _60_3:
    Shift_Pitch +Octave
    Riff _60, _60_3

    _60_5:
    Riff _60, _60_5

Loop Schala_Theme_Tri,_21


;============================================================
; DMC
;============================================================

_BP .set 0
_Env .set 0

Channel Schala_Theme_dmc, ST_dmc
    Header F2, T_12v_0f__d25

    _1:
        Notes whl,rest
        Repeat "1b", 5

        _13:
        Notes whl,As2
        Repeat "1b", 3

    ;

    _21:
            Set_Env T_0f__d12
            Notes whl,Fs2, hlf,Gs2

            Set_Env T_12v_0f__d25
            Notes hlf,Gs2

        _25:
        Notes whl,F2, whl,F2

        Riff _21, _25
        Notes whl,As2, whl,As2

    ;
    _37:

    Riff _21, _37

    _53:
    Notes whl,rest
    Repeat "1b", 3

Loop Schala_Theme_dmc, _21


;============================================================
; Noise
;============================================================


Channel Schala_Theme_Noise
    Noise_Header Schala_NB, Unused

    Riff ST_dmc::_1, ST_dmc::_13



    _13:
        Notes 8th,Hat_10_Water, 8th,Hat_10_Water, 8th,Hat_7

        _13_7:
        Duration _6x0, Hat_10, Hat_10, rest, Solo_Water, Hat_10, Hat_10  

        _14_5:
        Notes 8th,Tamb_1
        Duration _00, Hat_5, Hat_10

        _15:
        Riff _13, _13_7 +1
        Duration "Cont", Hat_10, Hat_10_Water, rest, rest, Hat_10, Hat_10  
        
    _16_5:
    Riff _14_5, _15


    _17:

    Riff _13, _16_5

    Notes 14,Tamb_1 ;Triplets.
    Notes 15,Hat_5
    Repeat "2b", 1
    

Loop Schala_Theme_Noise, _13



; Channel Schala_Theme_Noise
;     Noise_Header Schala_NB, Unused
;         ; The "::" allows the global NoiseFX_Index variable to be read.

;     Riff ST_dmc::_1, ST_dmc::_13



;     _13:
;         Riff _19, _19_5

;         Notes 8th,Tamb_1
;         Duration _00, Hat_5, Hat_10
;     ;

;     _15:
;     Repeat _13, 2

;     _19:
;         Notes 8th,Hat_10_Water, 8th,Hat_10_Water, 8th,Hat_7
;         Duration _6x0, Hat_10, Hat_10, rest, Solo_Water, Hat_10, Hat_10   
;     _19_5:

;     Notes 15,Hat_5
;     Repeat "2b", 1
;     Notes 14,Hat_5 ;Triplets.

; Loop Schala_Theme_Noise, _13

.align 1024