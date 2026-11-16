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
_8th .set 7+6

.align 256

;============================================================
; Square 0
;============================================================

Channel Death_Mountain_Sq0, DM_Sq0
    Header G2, Lead_d12_s7_1f_v8

    _1:
        Notes 16*_8th,rest
        Repeat "2b", 1

        _5:
                If_Alt C3,As2
                Notes 2*_8th +8,C3, 9,G2, 
                
                If_Alt Ds3,D3
                Notes 9,Ds3 ;Triplets
            Riff _5, *

            _6:
            If_Alt C3,As2
            Notes 8th,C3, 8th,rest, hlf,G2
        _6_7:
        If_Alt C3,As2
        Notes 9,C3, 
        
        If_Alt Ds3,D3
        Notes 8,Ds3, 9,G3

        _7:
        Shift_Pitch G3,As3
        Notes hlf,As3
        Notes 2*_8th +8,Gs3, 
        
        If_Alt Fs3,F3
        Notes 9,Fs3, 9,Gs3
 
        Notes whl,G3
        Shift_Pitch As3,G3

        _9:
        Riff _5, _6_7
        Notes 9,G2, 
        
        If_Alt C3, As2
        Notes 8,C3,
        If_Alt Ds3,D3
        Notes  9,Ds3

        _11:
        Notes 2*_8th +8,G3, 9,Fs3, 9,Gs3

        Notes 8th,G3, 
        
        If_Alt Ds3,D3
        Notes 8th,Ds3

        If_Alt B2,A2
        Notes 9,B2, 
        
        If_Alt G2,Fs2
        Notes 8,G2, 
        
        If_Alt Ds3,D3
        Notes 9,Ds3

        _12:
        If_Alt C3, As2
        Notes whl,C3

    ;

    _13:
    Riff _5, _13, "3b"

    Set_Env Lead_sqr_1f_v12
    Shift_Pitch G3,B3
        ;Following Shifts written as If G3,C4
    _21_env: ; -> Sq1
        ;21
            Notes dqt,C4
            Duration _00,C4,C4
            Notes qtr,C4
            
            _21_7:
            Notes 8th,G3,8th,C4

            _22:
            Notes 2*_8th +8,As3
            
            If_Alt 0, +1
            Shift_Pitch 0

            Notes 9,Gs3, 9,G3    ;Riff _7_5
            Notes hlf,Gs3

            _23: ;Toggle Riff _21, _23?
            If_Alt "Toggle"

        _23_T:
        Shift_Pitch C4, As3

        
        Riff _21_env, _23_T
            BP .set BP+1 ;As3,B3
        
        _25:
        Shift_Pitch B3,F3
        Riff _21_env, _21_7

        Shift_Pitch F3, A3
        Notes 8th,G3, 8th,Gs3

    
        Riff _22, _23

        _27:
        Shift_Pitch -1
        Assert_BP G2
        Riff _11, _13



Loop Death_Mountain_Sq0


;============================================================
; Square 1
;============================================================

Channel Death_Mountain_Sq1
    Header C2, Lead_d12_s7_1f_v8

    If_Alt "Toggle"
    Riff DM_Sq0::_1, DM_Sq0::_21_env, "3b"
        BP .set BP -G3+B3

    _21:
        Notes hlf,E3, qtr,C3,

        _21_7:
            Notes qtr,E3

            Notes 6*_8th +8,F3, 9,E3, 9,Ds3

            Notes hlf,D3, 
    _23_5:
        Notes qtr,C3, qtr,D3

        Notes dhf,As2, qtr,B2

    _25:
        Notes dhf,C3

        Shift_Pitch F3,D3
        Riff _21_7, _23_5

        _27_5:
        Notes hlf,G2

        Notes whl,G2

Loop Death_Mountain_Sq1


;============================================================
; Triangle
;============================================================
.align 256

Channel Death_Mountain_Tri, DM_Tri
    Header G3, T_2f__d25

    _1:
        Notes 8th,G3, 8th,rest
        Repeat _1, 2

        _1_7:
            Notes 8th,As3
            Duration _00, As3,As3

    _2:
        Riff _1, _1_7

        _2_7:
        Notes 8,As3, 
        
        Notes 9,As3;, 9,As3 ;Triplets.
        Repeat "2b", 1

        _3:
        Riff _1, _3

    _5:
        Riff _1, _3 ;Internal Repeats.

        Shift_Pitch G3,Gs3
        _7:
            Riff _1, _1_7

            _7_7:
            Shift_Pitch As3,G3
            _7_7_BP:

            Riff _1_7, _2
            Shift_Pitch G3,As3

        _8:
        Shift_Pitch Gs3,G3
        Riff _2, _5

        _11:

            If_Alt C3,D3 
            Shift_Pitch G3,C3
                Riff _1, _1_7

            If_Alt D3,C3
            Shift_Pitch C3,D3
                Riff _7_7, _8

            Shift_Pitch D3,G3

        _12:
        Riff _2, _3

        _13:
        Riff _5, _13

    _21:
        If_Alt 5, 4
        Shift_Pitch 5
        Riff _7, _8

        If_Alt -2, +1
        Shift_Pitch -2
        _22:
            Riff _7, _7_7_BP ;As3,G3
            Riff _2_7, _3
            Shift_Pitch G3,As3
            _23:

            If_Alt -5, -7
            Shift_Pitch -5
            Riff _7, _8
        _24:

        If_Alt 2, 5
        Shift_Pitch 2
        Riff _22, _23

    ;

    _25:
        If_Alt -4, -7
        Shift_Pitch -4
        Riff _7, _8

        If_Alt 4, 6
        Shift_Pitch 4
        Riff _22, _24


        ; If_Alt -5, -7
        ; Shift_Pitch -5
        ; Riff _7, _8

        Shift_Pitch D3,G3
        Riff _2, _3

    ;

Loop Death_Mountain_Tri
DM_Tri_Loop:

;============================================================
; DMC
;============================================================

Channel Death_Mountain_dmc
    Header C3, T_2f__d25

    If_Alt "Toggle"
    Riff DM_Tri::_1, DM_Tri_Loop, "3b"

Loop Death_Mountain_dmc, "Riffed"


;============================================================
; Noise
;============================================================

Channel Death_Mountain_Noise
    Noise_Header DM_NB, _d50_K

    
    Riff DM_Tri::_7, DM_Tri::_8
    Riff DM_Tri::_22, DM_Tri::_23

Loop Death_Mountain_Noise