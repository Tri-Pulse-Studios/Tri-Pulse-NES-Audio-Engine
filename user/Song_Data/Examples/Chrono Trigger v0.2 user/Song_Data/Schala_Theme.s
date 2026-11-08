;============================================================
; Song Statistics
;============================================================
;Song Size: 146 Bytes
;   - Sq0: 8 B
;   - Sq1: 11 B
;   - Tri: 72 B
;   - DMC: 27 B
;   - Noise: 28 B


_8th .set 11


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

Channel Schala_Theme_Sq1, ST_1
    Header As3, Pad_d50_6_3_1

    _1:
        Notes 16*_8th,rest
        Repeat "2b", 1    

    _5:
    Notes qtr,As3, qtr,Cs4, dqt,Ds4, 8th,rest ;Extra Byte for release control.

Loop Schala_Theme_Sq1, _5


;============================================================
; Triangle
;============================================================

Channel Schala_Theme_Tri
    Header As3, T_12v_0f__d25, Vib_Very_Shallow

    _1:
    Riff ST_1::_1, ST_1::_5
        
        Notes 16*_8th,As4, 16*_8th,Gs4, 16*_8th,F4
        Notes whl,Ds4, hlf,Cs4, hlf,C4


        Shift_Pitch -Octave ;Just want Vib Shallow

        _13:
            .byte Tie_Next_Note
            Notes whl,As3
        Repeat _13, 6
            Notes whl,As3

    ;


    _21:
        ;21
            Set_Env T_12v_3f_m3
            Set_Pitch Gs3

            Notes 14*_8th,Ds4, 8th,Cs4, 8th,As3

            Notes whl,F4, whl,Cs4

            _25:
            Duration _00, C4, Cs4
            Notes 13*_8th,C4, qtr,Cs4

            _27:
            Notes whl,Ds4, whl,Gs3, 14*_8th,As3

            
        ;
        Notes qtr,As3

        _31:
            Notes whl,As4, dhf,Gs4, qtr,Fs4

            _33:
                .byte Tie_Next_Note
                Notes whl,F4
            Repeat _33, 2

            Notes whl,F4 ;Needs to reset Env Properly.


        ;
    ;

    _37:
        Riff _21, _31 -1

        Notes 7,C4, 8,Cs4, 7,C4 ;Triplets.

        _47:
        Notes 14*_8th,As3, qtr,Gs3

        ; Shift_Pitch F4, As3
        ; Riff _33, _37
        _49:
            .byte Tie_Next_Note
            Notes whl,As3

        Repeat _49, 3 ;Doesn't Care about Env Reset.



    ;

    _53:
    Notes whl,rest
    Repeat "1b", 6


    Set_Env T_0f__d12
    _60_BP:
    Shift_Pitch -Octave ;Total


    _60:
        Duration _0000, As2,C3,Cs3,F3

        Shift_Pitch +Octave
    Repeat _60, 1

    _60_5:
    Riff _60_BP, _60_5

Loop Schala_Theme_Tri,_21




;============================================================
; DMC
;============================================================

Channel Schala_Theme_dmc, ST_dmc
    Header F2, T_12v_0f__d25

    _1:
        Notes 16*_8th,rest
        Repeat "2b", 5

        _13:;-> Noise

        If_Alt "Toggle"
        _13_No_Toggle: 

        If_Alt rest,As2 ;On Intro, Play Note. On loop, rest.
        Notes whl,rest
        Repeat "2b", 7

    ;

    _21:
            Set_Env T_0f__d12
            Notes 16*_8th,Fs2, whl,Gs2

            Set_Env T_12v_0f__d25
            Notes whl,Gs2

        _25:
        Notes 16*_8th,F2
        Repeat "2b", 1


        _29:
        Riff _21, _25
        
        Notes 16*_8th,As2
        Repeat "2b", 1

    ;
    _37:

    Riff _21, _37


Loop Schala_Theme_dmc, _13_No_Toggle


;============================================================
; Noise
;============================================================


Channel Schala_Theme_Noise
    Noise_Header Schala_NB, Unused

    Riff ST_dmc::_1, ST_dmc::_13


    _13:
        Riff _15, _15_8
        Notes qtr,Hat_10, 8th,Solo_Water
        Riff _16_3, _17

        _15:
            Notes qtr,Hat_10_Water, qtr,Hat_10_Water, qtr,Hat_7

            Notes 8th,Hat_10
        _15_8:
        Notes dqt,Hat_10_Water

        _16_3:
            Notes 8th,Hat_10, 8th,Hat_10 

            _16_5:
            Notes qtr,Tamb_1, 8th,Hat_5, 8th,Hat_10

    ;

    _17:
    Riff _13, _16_5

    _20_5:
    Notes 14,Tamb_1 ;Triplets.

    Notes 15,Hat_5 ;14 + 30 = _8th *4
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