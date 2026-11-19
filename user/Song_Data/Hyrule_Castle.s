;============================================================
; Statistics
;============================================================
; Total Size: 397 Bytes
    ; Sq0 133 B 
    ; Sq1 64 B
    ; Tri 74 B
    ; DMC 43 B
    ; Noise 83 B

_Env .set 0
_8th .set 6+7

    ;NOTE Intro phrase uses Custom Note lengths for _8th = 9

.align 256

;============================================================
; Square 0
;============================================================

Channel Hyrule_Castle_Sq0, HC_Sq0
    Header Ds2, Lead_d25_s5_v12

    _0_7:
        Notes -6 + 4*(9) +6,rest ;-6 for Noise starts 6f later.

        _1_2:
            Notes 6,G2 ;triplets
        Repeat _1_2, 1

        Duration _1111, G2,rest,F2,rest
        Notes hlf,G2

        _1_7:
        Notes dqt,Gs2

        If_Alt B2,As2
        Notes 8th,B2

        _2:
        Notes 14*(9),G2, qtr,rest

    _3:
    
    .byte Set_Tempo, 6+7
    Notes whl,rest

    _4: ;Intro
    Notes whl,rest


    _5_env:
        Set_Env Pad_d25_10_0
        _5:
                Notes 8th,rest
                Notes qtr,G2, 8th,G2

            _5_5:
            Notes qtr,F2, 8th,F2

            _5_8:
                Notes qtr,G2, 
                Set_Env Pad_d25_10_0 ;Sq1 Uses at _17_8
                Notes 8th,G2

               
                Notes 8th,G2
                Duration _00, G2,G2
            _6_5:
            Duration _1111, G2,G2, Gs2,Fs2

        _7:

        Riff _5, _7
        _9:
        Repeat "2b", 3

        _15:
        Shift_Pitch G2,C3
        Riff _5, _9

        _19:
        Shift_Pitch C3,G2
        Riff _5, _9

    ;

    _23: ;<- Sq1
        Notes 10*_8th,rest

        _23_3:
            Vol_Fade_In Vol_75, Vol_100, 4
            Notes 4,D3
            Repeat "2b", 1

            Notes 9,D3 ;8-9-9 Triplets.
            Repeat "2b", 1

            _24_5:
            Notes 8th,D3, 8th,Ds3
            Notes 8,F3, 9,Ds3, 9,D3

        _25:
        Riff _23, _25

        _27:
        Shift_Pitch D3,F3
        Notes hlf,rest
        
        

        _27_5:
        Notes 9+9,rest
        Riff _23_3, _24_5 ;;4+4,  9,9
        Notes 8,F3

        _28: ;-> Sq1
        Shift_Pitch F3,G3  ;Sq1 would want to Gs3.
        Set_Env Lead_d25_s5_v12
        
        _28_env:
            Notes hlf,G3
            Riff _27_5, _28

        _29:
        Riff _28_env, _29 ;Internal Repeat

Inc_Page Hyrule_Castle_Sq0_Cont, HC_0_BP, HC_0_EB


;============================================================
; Triangle
;============================================================

Channel Hyrule_Castle_Tri, HC_Tri
    Header As2, T_1f_12v

    _0_7:
    If_Alt "Toggle"
    Riff HC_Sq0::_0_7, HC_Sq0::_3
    If_Alt "Toggle"

    _3:
    Shift_Pitch +Octave ;C4, Shallow

        Notes 16*_8th,rest ;Sq1 Cont has one. No easy way to Riff.
        Repeat "2b", 1

        _7:
        Riff _19, _23
        Repeat "2b", 1

        _15:
        Shift_Pitch D4,G4
        Riff _19, _20_5

        Notes _8th+4,F5, _8th+4,Ds5
        Notes 9,Cs5, 9,B4 ;Triplets.

        Riff _21, _23
        Shift_Pitch G4,D4

        _19:
                Set_Env T_0f__E2
                Notes dqt,G4

                .byte Init_Sweep, 2
                Notes _8th+7,G4

                Set_Env T_1f_12v
            _19_5:
            Notes 6*_8th+6,D4

            Notes 8th,G4, 

            _20_5:
            Notes 8th,Gs4
            Notes _8th+8,As4, 9,Fs4, 9,As4 ;Triplets.

            _21:
            Riff _19, _19_5
            Notes 7*_8th+6,D4 ;One byte for well times end.

            Notes hlf,rest

    ;

    _23:
        ; Notes 2*_8th+8,F4, 9,Ds4, 9,D4
        ; Notes 8th,C4
        Riff _28, _28_6
        ;_23_6:
        Notes 8th,Ds4

        Notes 8th,F4, 8th,C5

        _24:
        Notes dhf,G4, qtr,rest

        _25:
        Riff _23, _25

        _27:
        Riff _28, _28_7 +1 
        Duration "Cont", F4,rest, G4,rest 

        
        Shift_Pitch F4,As4
        _28:
            Notes 2*_8th+8,As4, 9,Gs4, 
            
            _28_4:
            Notes 9,G4
            Notes 8th,F4
        _28_6:
        Notes 8th,G4 
        _28_7:
        Duration _0000, A4,rest, As4,rest 
        _29:

        Shift_Pitch As4,C5
        _29_BP:
            Riff _28, _28_7 +1
            Duration "Cont", As4,rest, C5,rest 

        _30:
        Notes whl,D5

    ;

    Set_Pitch As3
    _31:
            ;31
                Notes 8th,As3, 8th,rest

                Notes 8,As3
                Notes 9,As3
                Repeat "2b", 1       

                Notes 8th,As3, 8th,rest
                Repeat "2b", 1

            _32: 
            Shift_Pitch As3,Cs4
            Riff _31, _32

            Riff _41, _43 ;C4, As3

        _35:
        Riff _31, _35

        Shift_Pitch As3,C4
        _39:
            Riff _41_BP, _43 ;C4, As3

            _41:
            Shift_Pitch As3,A3 ;A3
            _41_BP:
            Riff _31, _32

        _42:
        Shift_Pitch A3,G3 ;G3
        Riff _31, _32

        _43:
        Shift_Pitch G3,C4
        Riff _39, _42

Loop Hyrule_Castle_Tri, _3



;============================================================
; Square 1 (Riffs both Sq0 and Tri.)
;============================================================

Channel Hyrule_Castle_Sq1, HC_Sq1
    Header As2, Lead_d25_s5_v12

    _0_7:
        
        Riff HC_Tri::_0_7, HC_Tri::_3

    _3_BP:
            Set_Pitch As1 ;Repeatedly Re-used.

                If_Alt C2,F2 ;For _15
                Shift_Pitch 0 ;NOP

            Riff HC_Sq0::_5_env, HC_Sq0::_7

        _5:
        Repeat "2b", 2

        _9:
            Riff HC_Sq0::_5, HC_Sq0::_5_5
            Notes 2*_8th -5,C2

                If_Alt Pad_d25_10_0, Lead_d25_s5_v12 ;For _15
                Set_Env Pad_d25_10_0 ;NOP

            _9_7:
                Notes  5,G2,  4,A2 ;triplets *4
                Shift_Pitch 3
            Repeat _9_7, 1 
                BP .set BP +3

            _9_8:
            Shift_Pitch +6 ;+Octave Total
            Riff HC_Sq0::_5_8, HC_Sq0::_6_5

            Notes 8th,F3, 8th,F3
            Duration _0000, Ds3,D3,Cs3,C3

        _11:
            Riff _3_BP, _5
            Riff _9, _11
                ;BP .set C2 +12

            _15: 
            If_Alt "Toggle"
        Riff _11, * ;Internal Repeat

        _19:
        Riff _11, _15

    ;

    _23:
    Set_Pitch C2 ;Pretty sure Shift -8
    Riff HC_Sq0::_23, HC_Sq0::_28
        BP .set BP-C2+Ds2

    _28:
    Shift_Pitch Ds2,Fs2 ;Set Fs2
    Set_Env Lead_sqr_1f_v12
    

        Notes 2*_8th+8,D3, 9,C3, 
        
        Riff HC_Tri::_28_4, HC_Tri::_29 -1
        ; Notes 9,As2  ;Riff _28_3c, _29 -1
        ; Notes 8th,Gs2
        
        ; _23_6:
        ; Notes 8th,As2

        ; Duration _0000, C3,rest, 

        Duration "Cont", D3,rest, 

        Shift_Pitch Gs2,B2
    _29:
    Riff HC_Tri::_29_BP, HC_Tri::_30 -1

    Duration "Cont", Ds3,rest ;



Inc_Page Hyrule_Castle_Sq1_Cont, HC_1_BP, HC_1_EB



.align 256
;============================================================
; Cont
;============================================================

Channel Hyrule_Castle_Sq0_Cont, HC_0_Cont
    Header HC_0_BP, HC_0_EB, "Cont"


    _30:
    Notes dhf,A3, qtr,rest


    Set_Env Pad_sqr_1_4_2_v12
    Set_Pitch Fs1, Vib_Deep
    _31:

        Notes hlf,G1
        Duration _1111, rest,A1,As1,D2

        Notes hlf,Cs2, hlf,A1

        Notes hlf,C2
        Notes 17,As1, 18,Fs1, 17,As1 ;Triplets

        _34:
        .byte Clear_Special_Effects, Common_Fade_Out ;Mostly for Sq1
        Notes whl,G1

        _35:
        Set_Pitch Fs4, Vib_Shallow

        Riff _31, _34
        Notes 5*_8th +6,G4
    ;

    _38_7:
    Set_Env Lead_d25_s5_v12
    Shift_Pitch -Octave 

    Notes 7,G3
    Duration _0000, A3,As3, C4,D4

    _39_BP: ;BP Fs3
            Notes dqt,Ds4
            Duration _00, Ds4,Ds4

            Duration _8x0, Ds4,rest, C4,rest, G3,rest, Ds4,rest

        _40:
        Notes dhf,D4, qtr,rest

        _41:
        Shift_Pitch Ds4,C4
        _41_BP:
        
        Riff _39_BP, _40 -3
        Duration "Cont", G3,rest, Ds3,rest, C4,rest

        _42:
        Notes dhf,As3, qtr,rest

        _43:
        Shift_Pitch C4,Ds4
        _43_BP:
        Riff _39_BP, _40

        _44:
        Shift_Pitch Ds4,D4
        _44_BP:
            Riff _39_BP, _40 -3
            Duration "Cont", As3,rest, G3,rest, D4,rest

            _45:
            Shift_Pitch D4,C4
        _45_BP:
        Riff _41_BP, _42

    ;

    _46: ;-> Sq1
    .byte Common_Fade_Out
    Notes whl,As3

Loop Hyrule_Castle_Sq0_Cont,  HC_Sq0::_4


Channel Hyrule_Castle_Sq1_Cont
    Header HC_1_BP, HC_1_EB, "Cont"

        _30:
        Notes hlf,G3, hlf,Fs3

    Set_Pitch Fs2
    _31:

        Riff HC_0_Cont::_31, HC_0_Cont::_35
        Repeat "2b", 1

        _39:
        Notes 16*_8th,rest
        Repeat "2b", 1

    _43:

    Shift_Pitch Fs2,As2
    Set_Env Lead_d25_s5_v12

    Riff HC_0_Cont::_44_BP, HC_0_Cont::_45_BP ;G3
        BP .set BP-G3+F3
    _44:
    ;F3
    Riff HC_0_Cont::_39_BP, HC_0_Cont::_40 -2 
    Duration "Cont", As2,rest, F3,rest

    Shift_Pitch F3,Ds3 ;Set Fs2
    Riff HC_0_Cont::_39_BP, HC_0_Cont::_40

    ; _43, _44 ptr 31  (Lowest Note is only +1. Test it.)
        ; else _44 -2 custom.

    ;_44, _45 ptr 30

    ;_39, _40 ptr 32
Loop Hyrule_Castle_Sq1_Cont, HC_Sq1::_3_BP
;============================================================
; DMC
;============================================================

Channel Hyrule_Castle_dmc
    Header F2, T_0f__E2

    _0_7:
        Notes -6 + 2*(9),rest 
        _1:
        Notes 12*(9),G2, hlf,Gs2
        Notes 14*(9),G2, qtr,rest

        ;Set Tempo 6+7
    _3:
            Notes hlf,G2, hlf,F2
            Notes hlf,G2, qtr,Gs2,qtr,Fs2
        _5:
        Repeat _3, 5

        Shift_Pitch G2,C3
        _15:
            Riff _3, _5
            Repeat "2b", 1
        _19:
        Shift_Pitch C3,G2

        Riff _15, _19

    ;
    Shift_Pitch -Octave
    _23:
        Duration _8x8, Gs1,G1, Gs1,G1, As1,Gs1,A1,D2

        _31:
            Duration _8888, G1,A1,Fs1,G1
        Repeat _31, 1

        _39:
        Duration _6x8, C2,As1,A1,G1, C2,As1
        Notes whl,A1

Loop Hyrule_Castle_dmc, _3


;============================================================
; Noise
;============================================================

Channel Hyrule_Castle_Noise
    Noise_Header HC_NB, _d50_K

    _f .set ::Timpani_f
    _e .set ::Timpani_e
    _d .set ::Timpani_d
    _c .set ::Timpani_c

    _0_7:
        ;Notes 6,rest  ;Omit all channels start 6f rest.
        Notes 6, Timpani_e
        Repeat "2b", 1

        _1:
        Notes 12*(9), Crash_6

            Vol_Fade_In Vol_25, Vol_62, (9)
            _1_7:
                Duration _00, Timpani_d,Timpani_d
            
            Repeat _1_7, 2
            Notes 8th,Timpani_d

        Vol_Fade_In Vol_25, Vol_62, (9)*3
        _2:
    
        Duration _00, Timpani_e,Timpani_e
        Repeat _2, 9

        Notes 4,Timpani_e, 
        Notes 5+(9),Timpani_e

        Repeat "2b", 1
        Notes 4+(9)*2, Timpani_e

    ;

    _3_vol:

    Vol_Fade_In Vol_50, Vol_62, _8th*16 ;Inc Volume when Sq0 comes in.

    _3:
        Riff _19, _21
        _5:
        Repeat "2b", 5

        _15:
            Shift_Pitch _e, _d

            Riff _3_vol, _5
            Repeat "2b", 1; Set Vol 50

            Shift_Pitch _d, _e

    _19:
        Notes 8th,Timpani_e, qtr,Timpani_e, 8th,Timpani_e
        Notes dqt,Timpani_f, 
        
        Notes qtr,Timpani_e, 8th,Timpani_e, 8th,Timpani_e
        Duration _00, Timpani_e,Timpani_e
        Duration _1111, Timpani_e,Timpani_e, Timpani_d, Timpani_f

        _21:

        Riff _19, _21
    ;
    
    _23:
            Vol_Fade_In Vol_25, Vol_62, 3*(4)

            Notes 4,Timpani_e
            Repeat "2b", 12 ;4*13 = hlf  Slightly fast Triplets.

            Notes 8th,Timpani_e
            Repeat "1b", 3
            
        _24:
            Notes 2*_8th +8, Timpani_f

            Riff _24_8, _25

            _24_5:
                Notes 8th,Timpani_f, 8th,Timpani_f
                _24_7:
                Notes 8,Timpani_f
                _24_8:
                Notes 9,Timpani_f,9,Timpani_f ;External Repeats at _40

        _25:
        Riff _23, _25

        _27:
        Shift_Pitch _e, _d
        Riff _23, _25

        _29:
        Shift_Pitch _d, _f
        Riff _23, _24

        Shift_Pitch _f, _c ;overal _f, _d
        Riff _24, _25

    ;

    _31:
        Notes 7*_8th,Timpani_e 
        _31_8:
            Duration _00,Timpani_d, Timpani_d
            Notes 7*_8th,Timpani_d
        _32_8:

        Shift_Pitch _d, _f
        _32_8_BP:
            Riff _31_8, _32_8

            Shift_Pitch _f, _e  
        Repeat _32_8_BP, 1
            BP .set BP-_f+_e ;Cancels _d, _f

        _34_8:
        Duration _00,Timpani_e, Timpani_e

        _35:
        Riff _31, _34_8
        

    ;

    Shift_Pitch _f, _e
    
    ; _38_8_Vol:
    ; Vol_Fade_In Vol_50, Vol_75, 16*_8th
    _38_8:
        Duration _00, Timpani_c, Timpani_c
        _39:
        Notes qtr,Timpani_c

            Assert_BP ::HC_NB-_f+_c            
        Riff _24_7, _25 

        _39_5:                                                  
        Notes dqt,Timpani_c

        _39_8:
            Shift_Pitch _c, _d 
            Riff _38_8, _39_8
        Repeat _39_8, 2 ;Repeat "7b", 3
            BP .set BP-_d+_f

        Shift_Pitch _f, _c
        Duration _00, Timpani_c, Timpani_c ;Riff _38_8_Vol, _39

        _43:
            Riff _39, _39_5
            Riff _24_5, _25 
            Shift_Pitch _c, _d
        Repeat _43, 2


Loop Hyrule_Castle_Noise, _3_vol