;============================================================
; Statistics
;============================================================
;Total Size: 243 Bytes
;Sq0: 104B
;Sq1: 44B
;Tri: 36B
;Noise: 45B
;DMC: 14B


_8th .set 7+7
.align 256

;============================================================
; Square 0
;============================================================


Channel Star_Cave_Sq0, SC_Sq0
    Header Cs2, Pad_6_15_7_v12

    Notes 16*_8th,rest

    Set_Volume Vol_62
    _3:
        Notes whl,Fs2, hlf,Cs2, hlf,Fs2
        Notes whl,E2, hlf,Cs2, hlf,E2

        _7:
        Riff _3, _7
        Repeat "2b", 1

    ;

    _15_Env:
        Set_Pitch E2

        Set_Volume Vol_50
        Env_Change Pad_6_15_7_v12

        _15:
        Notes qtr,E2, dqt,E3, 8th,Fs3, qtr,E3
        Notes 8th,A2, dqt,Cs3, qtr,E3, qtr,Cs3

        _17:
        Notes qtr,B2, dqt,Cs3, 8th,E3, qtr,Cs3
        Duration _2222, A2,Cs3, A2, Fs2 ;

    _Pre_19:
    .byte Clear_Special_Effects
    Env_Change Lead_25to50_7_9_0

    _19_BP:
    Set_Pitch A3
    
    _19:
                Notes 8th,A3, qtr,Cs4, 8th,E4, 
            _19_3:
            Notes qtr,Fs4, qtr,E4

            _20:
            Riff _19, _19_3
            Duration _1111, Fs4, A4, Gs4, E4

            _21: ;An If_Alt can probably save a little ROM here, but I'm lazy.
            Shift_Pitch A3, B3

            Notes 8th,B3, qtr,E4, 8th,Fs4, 
            Notes qtr,A4, qtr,E4

            _22:
            Notes 8th,B3, qtr,E4, 8th,A4, 
            _22_3:
            Duration _1111, B4,Cs5,B4,A4
        ;

        _23:
        Riff _19_BP, _23
        ;Internal Set A3, Shift B3

        Shift_Pitch B3, A3
        _27:
            Notes 8th,A3, qtr,E4, 8th,Fs4, 
            Notes qtr,A4, qtr,Fs4

            _28:
            Shift_Pitch A3, B3
            Notes 8th,E4, qtr,A4, 8th,Cs5, 
            Riff _22_3, _23 ;Duration _1111, B4,Cs5,B4,A4

            _29:
            Notes 8th,B3, qtr,Fs4, 8th,A4, 
            Notes qtr,Cs5, qtr,B4

            _30:
            Shift_Pitch B3, D4
            Notes 8th,A4, qtr,Cs5, 8th,E5, 
            Duration _1111, B4,Cs5,B4,Gs4
        ;
        
        _31:
        Shift_Pitch D4, A3
        Riff _27, _31
        BP .set BP-5

    ;

    _35:
    Riff _15_Env, _Pre_19
    Riff _15, _35, "3b"

    _59:
    Riff _19_BP, _23
    Repeat "2b", 3

    Riff _19_BP, _22

    _78:
    Notes whl,rest, whl,rest, whl,rest

Loop Star_Cave_Sq0
SC_Sq0_Loop:


;============================================================
; Square 1
;============================================================


Channel Star_Cave_Sq1, 
    Header Cs5, Pad_10_5_0

    _1:
    Notes 16*_8th,rest

    _3:
        Riff _11, _11_3
        Notes hlf,Cs5

        _4:
        Notes whl,rest

    _5:
    Repeat _3, 1

    _7:
    Riff _3, _4
    Riff _3, _5

    _10:
    Riff _14, _15

    _11:
        Notes 8th,A5, qtr,Fs5, 8th,E5
        _11_3:
        Notes qtr,Cs5, qtr,E5

        _12:
        Riff _11, _12 -1
        ;Notes qtr,A5

        _13:
        Riff _14 -1, _15 -2
        Notes qtr,E5, qtr,A5

        _14:
        Notes 8th,B5, qtr,Gs5, 8th,Fs5, 
        Notes qtr,Cs5, qtr,E5

    _15:
    Riff _11, _15
    Repeat "2b", 10


    
    _59:
    Riff SC_Sq0::_15_Env, SC_Sq0::_Pre_19
    Repeat "2b", 3

    _75:
    Riff SC_Sq0::_15, SC_Sq0::_17

    _77:
    Notes 16*_8th,rest
    Repeat "2b", 1

Loop Star_Cave_Sq1


;============================================================
; Triangle
;============================================================


Channel Star_Cave_Tri
    Header Cs3, T_0f_12v__d25

    _1:
    Notes whl,rest
    Repeat "1b", 9

    _11:
            Notes whl,A3
            Duration _2222, Fs3,Cs3, A3,Fs3
            
            _13:
            Notes whl,Gs3
            Duration _2222, Cs3,E3, Fs3,Gs3
        
        _15:
        Riff _11, _15
        Repeat "2b", 2

        _27:
            Notes whl,A3
            Duration _2222, Cs4,A3, B3,Gs3
            
            _29:
            Notes whl,Fs3
            Duration _2222, E3,Fs3, Gs3,B3

        _31:
        Riff _27, _31
    ;

    _35:
    Riff _11, _35

    _59:
    Riff _11, _27

    _75:
    Riff _11, _13
    Notes hlf,Gs3, hlf,rest
    
    Riff SC_Sq0::_78, SC_Sq0_Loop

Loop Star_Cave_Tri, "Riffed"


;============================================================
; DMC
;============================================================

Channel Star_Cave_dmc
    Header Cs2, T_M12__F2
        ;M12 is Max 12f. Channel silences after 12f.

    _1:
    Notes 8th,Cs2, dqt,Cs3 ;<- 8th,Cs3 + qtr,rest

    Notes 8th,Cs2, 8th,Cs3
    Repeat "2b", 2
    Notes qtr,rest

    
    Shift_Pitch Cs2, Gs1
    _2_3:
        Notes 8th,Gs2, 8th,Gs1

    Shift_Pitch Gs1, B1
    Repeat _2_3, 1 ;Notes 8th,B2, 8th,B1
        ;Base Pitch is corrupted, but fixed on Loop

Loop Star_Cave_dmc


;============================================================
; Noise
;============================================================


Channel Star_Cave_Noise
    Noise_Header ::Star_Cave_NB, 0;_d50_Kick
        ; The "::" allows the global NoiseFX_Index variable to be read.


    _1_vol:
        Set_Volume Vol_50

        _1:
            Notes 8th,Solo_Kick, 8th,Crash_6, qtr,Crash_4

        _1_3:
        Repeat _1, 2

        _2_3_keep_vol_50:
        .byte Clear_Special_Effects

    ;


    _2_3:
            Duration _00, Snare_6_Kick, Snare_6
            Notes 8th,Snare_6, 8th,Snare_4
            Duration _00, Snare_4, Snare_6

        
        _3:
            Notes 8th,Rasp_c_Kick, 8th,Snare_6
            Duration _0000, Snare_4,  Hat_2,Shaker_2,Hat_2

            _3_5:
            Duration _1111, Solo_Kick, Snare_6, Snare_4, Shaker_2
            

        _4:
        Riff _3, _4 -1
        Duration "Cont", Snare_4, Snare_4

        _5:
        Riff _3, _4

        _6:
        Riff _3_5, _4 ;External Repeat
    ;

    _6_3:

    Riff _2_3, _6_3
    Repeat "2b", 16

    _74_3:
        Riff _2_3, _6

        _78:
        Riff _1_vol, _1_3 ;Vol_50 r,4,6,4

        _78_3:
            Duration _1111, Solo_Kick,Crash_6, Crash_4,Crash_4

        _79:
        Riff _1, _2_3_keep_vol_50
        Riff _78_3, _79

    ;

Loop Star_Cave_Noise


