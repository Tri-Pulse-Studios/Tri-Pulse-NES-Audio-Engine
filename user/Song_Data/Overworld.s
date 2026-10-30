;See Template_Annotated.s for some guidance.

;10-29-26 23:11

;Statistics:

;Total Size: 695 Bytes

;Sq0: 219  ;153 -4 + 79 -9
;Sq1: 147  ;40 +4 + 94 +9
    ;The 14 If_Alt Bytes in Sq0's data are considered Sq1's data.

;Tri: 190 Bytes
;DMC: 26 Bytes
    ;The 5 If_Alt Bytes in Tri's data are considered DMC's data.

;Noise: 113 Bytes

_8th .set 9
_BP .set 0
_Env .set 0

.align 256

;============================================================
; Square 0
;============================================================

Channel Overworld_Sq0, OW_Sq0
    Header Fs2, Lead_d12_s9_v8

    _1:
        Notes dqt,Cs3
        Duration _6x0, Fs2,rest, As2,rest, Cs3,rest
        Duration _2222, Ds3,As2,Gs2,C3


        _2:
        Set_Pitch As2
        
        If_Alt -5
        Shift_Pitch 0

        Set_Env Lead_d12_25_s8_v8
        Duration _8x0, As3,As3, As3,rest, As3,rest, As3,rest

        If_Alt A3,As3
        Notes dqt,A3
        
        If_Alt A3,As3
        Notes 8th,A3
        
        Notes 8th,F3
        Shift_Pitch -Octave
        Notes 8th,F2, 

    ;

    _3:
        Notes 8th,As1, qtr,rest

        Set_Pitch As2, Vib_Shallow
        _3_3:
            Notes 8th,As2, qtr,rest, dqt,F3
            Duration _6x1, rest,Ds3,D3,Ds3, rest,C3

        _4_3:
        Shift_Pitch As2, F2 
        Notes whl,G2, hlf,rest

        Riff _3_3, _4_3 -1
        Duration "Cont", rest,F2

        Shift_Pitch F2, Gs2 ;= Gs3
        Notes dhf,D3

        _7:
        Duration _111_3, A2,D3,F3, G3
        Duration _111_3, rest,A3,As3, F3
        Duration _111_3, D3,rest,As2, Ds3

        _8:
        Shift_Pitch Gs2, D2
        Duration _3_111, C3, D3,rest,D2 ;Can extend _3_111_21
        Notes qtr,F2, 8th,As2

        _9:
        Notes dqt,C3, 8th,rest
        Duration _0000, C3,rest, C3,rest

        Duration _2121, C3,Gs2, As2,C3

        _10:
        Notes dhf,As2, dhf,A2
    ;

    _11:
        Set_Pitch A2 ;, Vib_Standard
        Set_Env Lead_d25_12_s9_v12

        Notes dqt,rest, dqt,As2
        Notes hlf,F3, 8th,Ds3, 8th,D3,

        _12:
        Notes 8th,Ds3, 8th,rest, 8th,As2
        Notes dhf,G3
        Duration _111_3, Ds3,D3,Ds3, F3

        Notes 8th,C3, 8th,D3, 8th,F3

        Shift_Pitch +Octave
        Notes qtr,A3, qtr,As3, qtr,C4

        _14:
        Notes dhf,D4, qtr,C4,qtr,D4,qtr,C4 ;Duration _6_222, D4, C4,D4,C4 ;No other instances.

        _15:
        Notes hlf,As3

        Shift_Pitch -Octave
        Notes 8th,G3, 8th,D3, dqt,A3, 
        
        Notes qtr,F3,8th,D3,  

        _16:
        Duration _2121, G3,As2, Ds3,G3
        
        Shift_Pitch A2,F2
        Notes 8th,F3,8th,rest,8th,F2

        Notes qtr,As2,8th,D3

        _17:
        Duration _3_111, Ds3, rest,C3,D3
        Duration _2121, Ds3,D3, C3,D3

        Notes dhf,As2

    ;

    _18_5:
        Set_Env Lead_sqr_s6_v12

        Duration _6x1, As2,F2,As2,D3,Ds3,F3

        Shift_Pitch F2, C3

        _19:
            Notes dhf,Fs3
            Duration _666_633_6222, As3,Gs3,Ds3, \
                F3,Ds3,F3,\
                D3,D3,Ds3,F3

        _23:
            Riff _19, 3 ;Fs3, Dur, As3,Gs3
            Duration "Cont",  C4, \
                D4,C4,D4,\
                As3,As3,F3,D3

        _27:
            Riff _19, 3 ;Fs3, Dur, As3,Gs3
            Duration "Cont",  Ds3, \
                A3,As3,C4,\
                Cs4,Cs4,C4,Gs3


        _31:
            Notes dhf,As3,dhf,Fs3, 
            Notes dhf,As3,dhf,Ds3

            Notes 12*_8th,C4

    ;

    _34:

Inc_Page OW_Sq0_Cont, OW_0_BP, OW_0_EB
    ;



;============================================================
; Square 1
;============================================================

Channel Overworld_Sq1
    Header Fs1, Lead_d12_s9_v8, Vib_Deep

    If_Alt "Toggle"
    Riff OW_Sq0::_1, OW_Sq0::_3

    _3_F2:
        Set_Pitch F2
        Set_Env Pad_d12_s3_v12

        Notes dhf,D3, dhf,F3, 12*_8th,G3
        Notes dhf,C3, dhf,F3, dhf,D3, dqt,As2, dqt,C3 ;Dur _66_633_6 using Sqr Solo's

        _7:
        Shift_Pitch F2, D2
        Notes dhf,As2, dhf,A2, 
        Notes dqt,G2, dqt,As2, dqt,F2, dqt,D2

        _9:
        Notes dhf,Ds2, dhf,Gs2, 
        
        _10:
        Notes dhf,F2

        
        Set_Env Lead_d12_25_s8_v8
        _10_5_BP:
        Shift_Pitch D2,A1
        _10_5:
            Notes 8th,A1, 8th,C2, 8th,F2
            Shift_Pitch +Octave
        Repeat _10_5, 1

    ;

    _11:
        Riff _3_F2, _10
        BP .set D2 ;Shift F2, D2


    ;

    _18:


Inc_Page OW_Sq1_Cont, OW_1_BP, OW_1_EB

.align 256 
;============================================================
; Sq0 / Sq1 Cont
;============================================================

Channel OW_Sq0_Cont, OW_Sq0_C
    Header OW_0_BP, OW_0_EB, "Cont"

        
    _34:
        Notes qtr,F3, hlf,rest

        _34_5:
            Set_Pitch F2
            Set_Env Lead_d12_25_s8_v8

            Duration _6x1, F3,A2,F3,Ds3,Cs3,C3

        _35_F2:

        Shift_Pitch +Octave ;F3
        Set_Env Lead_d25_12_s9_v12

    _35: ;<- Sq1
        Notes dhf,As3, 
        If_Alt F3, G3
        Notes dqt,F3,dqt,As3

        Notes dhf,C4
        If_Alt F3, A3
        Notes dhf,F3

        If_Alt 1
        Shift_Pitch 0

        _37:
        Notes dqt,Cs4
        If_Alt Gs3, A3
        Notes dqt,Gs3, dqt,Cs4,
        If_Alt F4, E4
        Notes dqt,F4

        Notes dhf,Ds4
        _38_3:
        If_Alt C4, B3
        Notes qtr,C4, qtr,Cs4, qtr,Ds4

        _39:
        If_Alt Cs4,D4
        Notes dhf,Cs4, 
        If_Alt As3,A3
        Notes qtr,As3,

        Riff _38_3, _39 -1
        ; If_Alt C4,B3
        ; Notes qtr,C4, qtr,Cs4

        Notes dhf,Cs4, 
        
    _40_5: ;-> Sq1
    Notes dqt,As3,dqt,F3

    _41:
    Notes dhf,C4, hlf,As3, 8th,C4, 8th,As3

    Notes dhf,A3
    Riff _34_5, _35_F2
    BP .set F2

    _43:
    Set_Env Lead_d12_s9_v8

    Notes dqt,As2, dqt,Cs3, dqt,Ds3, dqt,F3
    Notes dhf,F3, qtr,C3,qtr,Ds3,qtr,F3

    _45:
    Notes dhf,F3, dhf,Cs3
    Notes whl,Ds3

    Shift_Pitch F2, As1
    Duration _1111, C2,F2,As2,C3

    _47:
    Notes dhf,As2
    Duration _1111, As1,Cs2,Fs2,As2

    Shift_Pitch As1, B1
    Notes 8th,C3, 8th,Cs3, dhf,C3

    _48_5:
    Shift_Pitch B1, Gs1
    Duration _1111, Gs1,C2,Ds2,Gs2

    Shift_Pitch Gs1, C2
    Notes 8th,As2, 8th,C3

Loop OW_Sq0_Cont



Channel OW_Sq1_Cont
    Header OW_1_BP, OW_1_EB, "Cont"

    Shift_Pitch D2,A1
    Set_Env Lead_d12_25_s8_v8

    _18:
    Riff _19, _19_4

    Notes 5*_8th,rest

    ;
    _19_Env:
    Set_Env Pad_d25_8_5_0
    _19_F2:
        Set_Pitch F2 ;Fs2 -1

        _19: ;1,5,8 ;+4,+3,+5
                If_Alt F2,Fs2 ;Enabled for _19
                Notes 8th,F2, 8th,As2, 8th,Cs3

                Shift_Pitch +Octave
            Repeat _19, 1

            _19_3:
                Shift_Pitch -Octave

                If_Alt F3,Fs3
                Notes 8th,F3
                _19_4:
                Notes 8th,Cs3, 8th,As2
            Repeat _19_3, 1

        _20:
        Shift_Pitch Fs2, Gs2
        Riff _19, _20

        _21_F2:
        Set_Pitch F2 ;
        _21: ;1,6,10  ;+5,+4,+3
                If_Alt G2, F2 ;Enabled for _21
                Notes 8th,G2, 8th,As2, 8th,D3

                Shift_Pitch +Octave
            Repeat _21, 1

            _21_3:
                Shift_Pitch -Octave
                
                If_Alt G3, F3
                Notes 8th,G3, 8th,D3, 8th,As2
            Repeat _21_3, 1

        _22:
        Riff _21, _22

        _23:
        Riff _19_F2, _20
   
    
        _24:
        Shift_Pitch F2, Ds2
        Riff _21, _22    
    
        _25:
        Riff _21_F2, _22
        Riff _21_F2, _22 ;Internal Repeat
    
    
        _27:
        Riff _19_F2, _21


        _29:    ;BP set to F2
        Shift_Pitch Fs2,F2
        Riff _19, _20
        
        _30:
            If_Alt "Toggle" ;F2, As2, Cs3
            Riff _19_F2, _20

        _31:
        Riff _30, _31 ;Internal Repeat

            ; If_Alt "Toggle" ;Fs2, As2, Cs3
            ; Riff _19_F2, _20
    
        _32:
        Shift_Pitch Fs2,D2 ;wtf does D2 mean?
        If_Alt "Toggle"
        Riff _21, _22
    
        _33:
        Shift_Pitch D2, F2

        _33_Toggle:
        If_Alt "Toggle"
        Riff _19, _20
    
    
        _34:
        Set_Env Lead_d12_25_s8_v8
        Riff _18, _19
        BP .set F2

    ;

    Set_Env Lead_sqr_s6_v12
    Set_Pitch Gs3 ;From F2. Maybe Vib Shallow?

    Riff OW_Sq0_C::_35, OW_Sq0_C::_40_5

    BP .set BP+1

    Notes dhf,Cs4

    _41:
    Notes dhf,Ds4, dhf,Cs4
    Notes whl,C4, qtr,C4,qtr,Cs4

    _43:
    Notes dhf,As3, dqt,C4, dqt,Cs4
    Notes whl,C4, qtr,As3,qtr,C4

    _45:
    Notes dhf,Cs4, dhf,F4
    Notes whl,G4, hlf,rest

    _47:
    Riff _19_Env, _20

    _48:
    Riff _33_Toggle, _34

Loop OW_Sq1_Cont


.align 256
;============================================================
; Triangle
;============================================================

Channel Overworld_Tri, OW_Tri
    Header Fs2, T_1f__d25

    Duration _3_111, Fs2, rest,Cs3,Fs3
    Notes qtr,Gs3, qtr,Ds3, qtr,Gs2

    Shift_Pitch Fs2, F2
    _2:
    Notes qtr,F2, 8th,rest
    Duration _00, F3,rest
    Repeat "2b", 2
    Notes qtr,F3, 8th,rest


    _2_4:
    Notes dqt,F2

    _3_BP:
    Set_Pitch As1
    Set_Env T_M8__d25

    _3:
            Duration _3_111, As1, As1,As1,As1
            Duration _3_111, As2, As1,As1,As1

        _4:
        Shift_Pitch As1,Ds2
        Riff _3, _4

        _5:
        Duration _3_111, F2, F2,F2,F2
        _5_3:
        Shift_Pitch -Octave
        Duration _3_111, F1, F1,F2,F1 

    _6:
    Shift_Pitch Ds1, Gs1
    Duration _3_111, As1, A1,D2,F2

    Set_Env T_1f__d25
    Notes dqt,As2, dqt,A2

    _7:
    Duration _3_111, G2, A1,D2,G2
    Notes dqt,F2, qtr,D2, 8th,F2

    _8:
    Notes dqt,Ds2
    Duration _3_111, F2, As2,rest,F2
    Notes dqt,As1

    _9:
        Notes dqt,Gs2

        If_Alt Gs1,Gs2
        Notes dqt,Gs1
        _9_5:
    Repeat _9, 1

    _10:
    Shift_Pitch Gs1, Ds2 ;Set_Pitch F2

    Duration _6x1, F3,F2,F2, F3,F2,F2, 


    Shift_Pitch Ds2,A1 ;Set_Pitch A1 
    _10_5:
        Notes 8th,A1, 8th,C2, 8th,F2
        Shift_Pitch +Octave
    Repeat _10_5, 1



    _11_BP:
    Riff _3_BP, _3 ;Env Set Pitch
    BP .set As1

    _11: ;-> DMC

            Notes qtr,As1
            Duration _1111, As1,As2, As1,As1
            _11_5:
        Repeat _11, 1

        _12:
        Shift_Pitch As1, Ds2
        Riff _11, _12

        _13:
        Notes qtr,F2
        Duration _1111, F2,F3, F2,F2

        _13_3: ;<-DMC
        Riff _5_3, _9
        BP .set Gs1

        _17:
        Shift_Pitch Gs1, F1
        Riff _9, _9_5

        Shift_Pitch F1, A1
        Riff _9, _9_5

        _18: ;Riff Sq1
            Notes 8th,As1, 8th,D2, 8th,F2
            Shift_Pitch +Octave
        Repeat _18, 1
        BP .set BP+12

        Notes 8th,As3, 5*_8th,rest

    ;
    Set_Env T_2f__d12
    Set_Pitch Ds1

    _19:
        ;19
            Notes 12*_8th,Fs1, 12*_8th,Gs1
            
            _21:
                Notes 12*_8th,As1

                _22:
                If_Alt Plus_Octave, Clear_Special_Effects ;NOP
                Shift_Pitch +Octave

                Notes dhf,As2
            _22_3:

            Notes qtr,As2,qtr,Gs2,qtr,F2 ;Can't Riff and Dur. 

            If_Alt Minus_Octave, Clear_Special_Effects ;NOP
            Shift_Pitch -Octave
        ;

        _23:
            Notes 12*_8th,Fs1, dhf,Gs1,dhf,C2

            _25:
            Riff _21, _22_3
            BP .set BP+12

            If_Alt Minus_Octave, Clear_Special_Effects ;NOP
            Shift_Pitch -Octave

            Notes qtr,As1,qtr,C2,qtr,D2

        ;

        _27:
            Riff _19, _21
            _29:
            Notes dhf,F1, dhf,A1, dhf,As1, dqt,As1,dqt,Gs1

        ;

        _31:
            Notes 12*_8th,Fs1, 12*_8th,Ds1, 12*_8th,F1

            _34:
            Duration _6x1, F1,rest, F1,F1,F1,F1

            Shift_Pitch Ds1, A1

            _34_5:
            Duration _6x1, F2,A1,F2,Ds2,Cs2,C2

        ;

    ;BP = A1
    Set_Env T_1f__d25

    _35:
        If_Alt As1, As2
        Notes dhf,As1, dhf,As2

        Shift_Pitch -1
    ;

    _36:
    Repeat _35, 4
    BP .set BP-4

    Shift_Pitch +5
    Riff _35, _36 -1 ;No BP

    _41:
    Notes dhf,Ds2, dhf,E2, dhf,F2

    Riff _34_5,_35 ;BP = A1 again.
    ;

    
    ;Set_Pitch As2
    _43_no_BP:
    Shift_Pitch +Octave

    _43:
        Notes qtr,As2
        Duration _1111, As2,As2,Cs3,F3
        _43_3:

        Notes qtr,As3
        _43_4:
        Duration _1111, As2,As2,Cs3,As2

    _44:
    Shift_Pitch A2, Gs2
    Riff _43, _44

    _45:
    Repeat _44, 1
    BP .set BP-1 ;G2

    _46:
    Shift_Pitch -1
        Notes qtr,G2
        Riff _43_4, _44
        Duration _2121, Ds3,As2, G2,As2

    Shift_Pitch -1
    _47:
    Riff _43, _43_3
    Duration _2121, Fs3,Cs3, Fs2,G2

    _48:
    Shift_Pitch +2
    Riff _47, 3
    Duration "Cont", Gs3,Gs2, Ds3,Gs3

Loop Overworld_Tri


;============================================================
; DMC
;============================================================

Channel Overworld_dmc
    Header F2, T_1f__d25
    If_Alt "Toggle"

    Notes (12+9)*_8th, rest

    Riff OW_Tri::_2_4, OW_Tri::_11, "3b"

    _11:
    Riff OW_Tri::_3, OW_Tri::_5_3
    _14:
    Riff OW_Tri::_13_3, OW_Tri::_43_no_BP, "3b"
    BP .set A1

    _43:
        Notes dhf,As2, dhf,rest

        Shift_Pitch -1
    ;
    Repeat _43, 4
    BP .set BP-4

    Shift_Pitch +2 ;E1 -> Fs1
    Notes dhf,Gs2, dhf,rest


Loop Overworld_dmc

.align 256
;============================================================
; Noise
;============================================================

Channel Overworld_Noise
    Noise_Header Overworld_NB, _d50_K

    _1:
        Riff _3, _3_5
        Repeat "2b", 2

        Notes hlf,rest, 8th,Hat_2, 8th,Hat_2
    ;

    _3:
        Notes qtr,Crash_3
            _3_1:
            Riff _6_1, _6_5

            _3_5:
            Notes qtr,Snare_6_Kick
            Riff _6_1, _6_5


        _4:
            Riff _6, _7 -2
            Duration "Cont", Hat_2, \
            Hat_4, Hat_2, Hat_2

        _5:
            Notes qtr,Hat_4_Kick
            Riff _3_1, _4

        _6:
            Notes qtr,Hat_4_Kick
            _6_1:
                Duration _00, Hat_2, Hat_2 ;Common Pattern
                Notes 8th,Hat_2, 
                _6_2:
                Notes 8th,Hat_2, 8th,Hat_2

            _6_5:
            Duration _6x1, Snare_6_Kick, Hat_2, Hat_2, \
                        Snare_6_Kick, Hat_2, Hat_2


        _7:
            Riff _3, _4
            
        _8:
            Notes 8th,Hat_4_Kick
            Duration _00, Hat_2,Hat_2
            Duration _1111, Hat_2, Hat_4_Kick, Hat_2, Hat_2

            Riff _3_5, _4

        _9:
        Notes qtr, Crash_3  ;Riff _3, _3_2
        _9_1:
            Duration _00, Hat_2, Hat_2 
            Notes 8th,Snare_6, 8th,Hat_2, 8th,Hat_2

        _9_5:
        Notes qtr,Hat_4_Kick
        Riff _9_1, _9_5

        _10:
        Riff _9, _9_5
        

        _10_5:
        Repeat "2b", 1

        
        _11:
        Riff _3, _10_5, "3b"

        _18_5:
        Riff _21, _21_3
        

    ;

    _19:
                Repeat _18_5, 1 ;Riff _21, _21_3
                Riff _20_3, _21

            _20:
                Riff _22,  _22_3
                _20_3:
                Notes dqt,Snare_6, qtr,Hat_2, 8th,Hat_2 

            _21:
                Notes hlf,Crash_3, 8th,Hat_2, 8th,Hat_2
                _21_3:
                Notes qtr,Snare_6, qtr,Hat_2, 8th,Hat_2, 8th,Hat_2

            _22:
                Notes hlf,Hat_2, 8th,Hat_2, 8th,Hat_2 ;Riff _20,  _20_3
                _22_3:
                Duration _2121, Snare_6,Hat_2, Snare_6,Hat_2

            _23:
            Riff _19, _20 ; +1

            _24:
            Notes hlf,Hat_2, 
            Riff _21 +1, _22


            _25:
            Riff _21, _21_3
            Notes hlf,Snare_6, 8th,Hat_2, 8th,Hat_2 
        ;

        _26:
        Notes dqt,Hat_2, qtr,Hat_2, ;8th,Hat_2 
        Riff _22_3 -1, _23

        _27:
            Riff _19, _26

            _34:
            Riff _21, _21_3
            Notes dhf,Crash_3

        ;

    ;

    _35:
            Riff _3, _6
            Riff _4, _5

        _39:
            Riff _3, _6

            Notes hlf,Hat_4_Kick

            Riff _6_2, _7

        _43:
            Riff _35, _39

        _47:
            Riff _3, _4

            Notes qtr,Crash_3
            Riff _6_1, _7

    ;

Loop Overworld_Noise

.align 1024 ;Massive padding just for clarity.