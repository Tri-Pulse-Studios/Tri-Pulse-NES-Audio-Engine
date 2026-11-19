;============================================================
; Statistics
;============================================================
; Total Size: 253 Bytes
    ; Sq0 85 B ;10 If-Alts 
    ; Sq1 37 B
    ; Tri 67 B ;9 If-Alts
    ; DMC 15 B
    ; Noise 51 B


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
                ;5
                       If_Alt C3,As2
                    Notes 2*_8th +3,C3, 5,rest, ;899
                    
                    _5_4:
                        Notes 9,G2, ;Triplets.

                        _Ds3_9:
                           If_Alt Ds3,D3
                        Notes 9,Ds3
                _5_5:
                Riff _5, *

                _6:
                   If_Alt C3,As2
                Notes 8th,C3, 8th,rest, hlf,G2


            _6_7:
                   If_Alt C3,As2
                Notes 8,C3, 
                
                Riff _Ds3_9, 3 ;899

            _6_8:
            Notes 9,G3 

        ;

        _7:
            Shift_Pitch 1
            Notes hlf,As3
            Shift_Pitch -1

            Notes 2*_8th +8,Gs3, ;899
            
            _7_7:
                   If_Alt Fs3,F3
                Notes 9,Fs3

                Notes 9,Gs3
            _8:

            Notes whl,G3
        ;
            

        _9:
            Riff _5, _6_7 

            _10_7:
            Notes 9,G2 ;989
            Riff _6_7, _6_8 ;vs C3,Ds3, G3

        ;

        _11:
            Notes 2*_8th +8,G3
            Riff _7_7, _8 ;Fs3,Gs3 Triplets.


            Notes 8th,G3, 
            
               If_Alt Ds3,D3
            Notes 8th,Ds3


               If_Alt B2,A2
            Notes 8,B2, ;899
            
            Riff _5_4, _5_5 ;_5_8, _6

            _12:
               If_Alt C3, As2
            Notes whl,C3

    ;

    _13:
    Riff _5, _13, "3b"

    Set_Env Lead_d25_s6_1f_v12
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


Channel Death_Mountain_Tri, DM_Tri
    Header G3, T_m3_5f

    _1:
        Duration _6x1, G3,rest, G3,rest, G3,rest ;External Repeat
        ; Notes 8th,G3, 8th,rest
        ; Repeat _1, 2

        _1_7:
            Notes 8th,As3
            Duration _00, As3,As3

    _2:
        Riff _1, _1_7

        _2_7:
        Notes 9,As3
        Notes 8,As3 ;External Repeat.
        Notes 9,As3

        _3:
        Riff _1, _3

    _5:
        Repeat _3, 1 ;Riff _1, _3

        _7_BP:
        Shift_Pitch G3,Gs3
        _7: ;<- Noise 
            Assert_BP Gs3

            Riff _1, _1_7

            _7_7:
            Shift_Pitch As3,G3
            _7_7_BP:

            Riff _1_7, _2
            Shift_Pitch G3,As3

        _8: ;-> Noise 
        Shift_Pitch Gs3,G3
        Riff _2, _5

        _11:

               If_Alt C3,D3 
            Shift_Pitch G3,C3
                Riff _1, _1_7

                Shift_Pitch C3,D3
                Riff _7_7, _8

               If_Alt D3,C3
                Shift_Pitch D3,G3

                _12:
                Riff _2, _3

        _13:
        Riff _5, _13

    _21:
          If_Alt 0, 4
        Shift_Pitch 0
        Riff _7, _8

          
        Shift_Pitch 1 ;Can't be Riffed.
        _22: ;<- Noise 
            Riff _7, _7_7_BP ;As3,G3   
            Riff _2_7, _3
            Shift_Pitch G3,As3
            _23: ;-> Noise 

          If_Alt -3, -7
        Shift_Pitch -3
        _23_BP:
        Riff _7, _8

          If_Alt 2,5 
        Shift_Pitch 2
        _24_BP:
        Riff _22, _23  ;Internal +1

        _25:
          If_Alt -4, -7
        Shift_Pitch -4
        Riff _7, _8

          If_Alt 2,6
        Shift_Pitch 2
        Riff _22, _23

          If_Alt 0, -7
        Shift_Pitch 0
        _27_BP:
        Riff _23_BP, _24_BP
        ; Riff _7, _8

        ;   If_Alt 2, 5
        ; Shift_Pitch 2
        _28_BP:
        Riff _2, _3 ;Start


        ;    If_Alt 5, 4
        ; Shift_Pitch 5
        ; Riff _7, _8

    ;        If_Alt -2, +1
    ;     Shift_Pitch -2
    ;     _22: ;<- Noise 
    ;         Riff _7, _7_7_BP ;As3,G3
    ;         Riff _2_7, _3
    ;         Shift_Pitch G3,As3
    ;         _23: ;-> Noise 

    ;            If_Alt -5, -7
    ;         Shift_Pitch -5
    ;         Riff _7, _8
    ;     _24:

    ;        If_Alt 2, 5
    ;     Shift_Pitch 2
    ;     Riff _22, _23

    ; ;

    ; _25:
    ;        If_Alt -4, -7
    ;     Shift_Pitch -4
    ;     Riff _7, _8

    ;        If_Alt 4, 6
    ;     Shift_Pitch 4
    ;     Riff _22, _24


    ;     ;    If_Alt -5, -7
    ;     ; Shift_Pitch -5
    ;     ; Riff _7, _8

    ;     ; Shift_Pitch D3,G3
    ;     ; Riff _2, _3
    ;     Riff _12_BP, _13

    ;

Loop Death_Mountain_Tri
DM_Tri_Loop:

;============================================================
; DMC
;============================================================

Channel Death_Mountain_dmc
    Header C2, T_1f__d12

       If_Alt "Toggle"
    Riff DM_Tri::_1, DM_Tri_Loop, "3b"

Loop Death_Mountain_dmc, "Riffed"


;============================================================
; Noise
;============================================================

;.align 256
Channel Death_Mountain_Noise
    Noise_Header DM_NB, _d50_K


    _1:
        Riff _27, _29
        Repeat "2b", 1
    ;

    _5: 
        ;
               If_Alt Snare_8_w_Timpani_e, Snare_8_w_Timpani_f ; e, f
            Notes qtr,Snare_8_w_Timpani_e, 
            
            _5_3:
            Notes qtr,Snare_8, qtr,Snare_8

               If_Alt Snare_8_w_Timpani_d, Snare_8_w_Timpani_f ; d, f
            _5_7_no_T:
                Notes 8th,Snare_8_w_Timpani_d
                Duration _00, Snare_8, Snare_8
                
                _6:
                Notes qtr,Snare_8_w_Timpani_e

            _6_3:
            Notes qtr,Snare_8
            Notes 8+9,Snare_8,  9,Timpani_e

            _6_7:
            Notes 9,Snare_8_w_Timpani_d
            Notes 8,Snare_8
            Notes 9,Snare_8 ;External Repeat


        _7:
        Notes qtr,Snare_8_w_Timpani_d,
        Riff _5_3, _7


        _9:
            Riff _5, _7

            _11:
               If_Alt "Toggle"
        Repeat _9, 1 


        _13:
        Riff _5, _13
    
    ;

    Assert_BP ::Snare_8 ;Snare_8 is first NoiseFX


    _21:
        Riff DM_Tri::_7, DM_Tri::_8
        Riff DM_Tri::_22, DM_Tri::_23

    _23:
    Repeat _21, 2

    _27:

        Notes qtr,Snare_8_w_Timpani_e, qtr,Snare_8_w_Timpani_e
        Notes 8+9,Snare_8_w_Timpani_e,   9,Timpani_e

        _27_7:
        Riff _5_7_no_T, _6_3

        _28_3:
        Notes qtr,Snare_8_w_Timpani_e, qtr,Snare_8_w_Timpani_e, 

        _28_7:  
            Assert_BP ::Snare_8_w_Timpani_d -As3 +G3 ;8_w_d is 4th NoiseFX
            Riff DM_Tri::_2_7, DM_Tri::_3
                ; Notes 9,Snare_8_w_Timpani_d ;Worth Riffing Tri?  Fragile NoiseFX order.
                ; Notes 8,Snare_8_w_Timpani_d
                ; Notes 9,Snare_8_w_Timpani_d ;External Repeat

        _29:
    ;Riff _1, _3

Loop Death_Mountain_Noise