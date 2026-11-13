;============================================================
; Statistics
;============================================================
; Total Size: 342 Bytes
    ; Sq0 128 B
    ; Sq1 46 B
    ; Tri 39 B
    ; DMC 77 B
    ; Noise 52 B


_8th .set 8+8

.align 256
;============================================================
; Square 0
;============================================================

Channel HotHead_Bop_Sq0, HB_Sq0
    Header A1, Pad_d25_3_0

    _1:
        Set_Pitch A1
        Notes 8th,A2

        Shift_Pitch A1,E1
        Duration _6x0, E1,A1, rest,E2, rest,A1

        _1_5:
        Riff _1, _1_5
        Repeat "2b", 14

    ;
    _9:
        Notes 16*_8th,rest
        Repeat "2b", 1 ;3*11_8th
    
        Set_Env Echo_d25_10_5_0
        Set_Pitch G3
        _13:
            Notes 8th,rest

            Notes 8th,C4, 8th,B3, _8th/2,C4
            _13_4:
            Notes 8th,B3, 5*_8th/2,A3

        Notes 8th,rest

        _14:
        Riff _13, _13_4
            _14_4:
            Notes 3*_8th/2,D4,8th,C4, ;G4,F4
            _14_7:
        Notes 8th,B3,8th,C4
        _15:
            Notes 8th,B3,8th,A3,8th,A3

            Notes _8th/2,G3, 25*_8th/2,A3

        _17:
        Riff _13, _14 -1
        Notes 8th,A3

        _18:
        Duration _2222,D4,C4,B3,C4
        Riff _15, _17

    ;
    
    _21_Vol: ;<- Sq1
            Vol_Fade_Out Vol_100, Vol_12, _8th

            _21:
                If_Alt E4,C4
                Notes 8th,E4, 
                
                If_Alt A3, E4
                Notes 8th,A3, 
                
                If_Alt C4,A3
                Notes 8th,C4
            Riff _21, *

            .byte Clear_Special_Effects

            If_Alt E4,C4
            Notes 8th,E4
            
            If_Alt A3,F4
            Notes 8th,A3

            _22_vol:
            Vol_Fade_Out Vol_100, Vol_12, _8th ;Self If_Alt Breaks even. Wether Shift Up/down, or 3 Note If_Alts.
                                                 ;Maybe Sq0 If_Alt?
            _22:
                If_Alt G4,D4
                Notes 8th,G4, 

                If_Alt B3, G4
                Notes 8th,B3, 

                If_Alt D4,B3
                Notes 8th,D4
            Riff _22, *

                If_Alt G4,D4
                Notes 8th,G4
            Repeat "2b",1 

        _23:
        Riff _21_Vol, _23

        _25:
        Shift_Pitch -Octave
        Set_Env Lead_d12_d25_9_4_0

        Riff _21_Vol, _25

        .byte Clear_Special_Effects
    ;

    _29: ;-> Sq1
        Set_Env Pad_d25_3_0

        Riff _1, _1_5
        Repeat "2b", 7

    _33:
        Set_Env Echo_d25_10_5_0 
        Set_Pitch C4
        
        Notes 9*_8th,rest

        _34:
            Riff _37, _37_6
            Riff _14_4, _14_7 ;Notes 3*_8th/2,G4, 8th,F4

            Notes qtr,E4
        _35:
        Notes 8th,C4, dhf,C4

        _36:
        Riff _34, _35
        Notes 8th,F4, qtr,E4, hlf,C4

        _37:
        Notes 8th,E4, 8th,F4, 8th,G4

            Notes 3*_8th/2,C5,
            _37_6:
            Repeat "2b", 1

            Notes 8th,D5, 16*_8th,D5


    _41:
        Set_Env Lead_sqr_1f_v12
        Set_Pitch Gs2

        Notes 16*_8th,E3, 16*_8th,C3, 
        
        _45:
            Notes 16*_8th,A2, 16*_8th,Gs2
            
        _49: ;Sq1


Loop HotHead_Bop_Sq0


;============================================================
; Square 1
;============================================================

Channel HotHead_Bop_Sq1
    Header B3, Pad_s1_d12_v12

    _1:
        Riff HB_Sq0::_45, HB_Sq0::_49  
            ;Notes 16*_8th,C4, 16*_8th,B3

        _5:
        .byte Tie_Next_Note
        Notes 16*_8th,E4
        Repeat "2b", 1

    ;

    Set_Pitch G2
    Set_Env Lead_d12_d25_9_4_0
    _9:
        Duration _8x1, A2,E3,D3,G3,D3,E3,B2,C3

        Riff _9, *
        Repeat "2b", 10 ;"5b", 11 

    ;

    Shift_Pitch +Octave
    Notes 8,rest

    Set_Env Echo_d25_10_5_0
    _21:
        If_Alt "Toggle"
        Riff HB_Sq0::_21_Vol, HB_Sq0::_29, "3b"
            BP .set BP-12


        _29:
        Notes 16*_8th -4,rest ;sync after delay.
        Repeat "2b", 1

    _33:
            Duration _8x1, E3,C3,E3,F3,E3,G2,E3,C3
        Repeat _33, 5

        _39:
            Duration _8x1, D3,B2,D3,E3,D3,G2,D3,B2
        Repeat _39, 1

        _41:
        Riff _33, _41

Loop HotHead_Bop_Sq1


;============================================================
; Triangle
;============================================================

Channel HotHead_Bop_Tri
    Header F1, T_0f__C3

    _1:
        Notes whl,rest
        Repeat "1b", 19

    _21:
        Duration _8888, A1,A1,F1,G1
    Repeat _21, 1

    _29:
        Notes whl,rest
        Repeat "1b", 12


    Set_Pitch C4,Vib_Shallow
    Set_Env T_1f_12v
    _42:
        Duration _1111, rest,E4,F4,G4

        Notes 3*_8th/2,G4, 3*_8th/2,F4, 8th,E4

        _43:
        Notes whl,E4

        _44:

        Riff _42, _43
        Notes qtr,E4, 8th,C4, 5*_8th,C4

        _46:
        Riff _42, _43
        Notes whl,D4

        _48:
        Duration _6x1, rest,D4,D4,E4,F4,E4
        Notes qtr,D4

    ;

Loop HotHead_Bop_Tri

.align 256
;============================================================
; DMC
;============================================================

Channel HotHead_Bop_dmc
    Header E1, T_2f__d12

    Init_BP .set E1 -A1

    _1:
        Riff _31, _32_5 +1
        Duration "Cont", rest,E1,G1,Gs1

        
        _3:
    Repeat _1, 7

    _17:
        Shift_Pitch A1,F1
        Riff _31, _32

        _18:
        Shift_Pitch F1,D1
        Riff _32, _32_5 +1
        Duration "Cont", rest,E1,G1,Gs1

        Shift_Pitch D1,A1

    _19:
        Riff _1, _3


    _21:
        Notes 16*_8th,rest

        _23:
            Riff _17, _18 ;F1, _31, _32
                BP .set Init_BP +F1

            Shift_Pitch F1, G1  ;Not Sure I can If_Alt _17, _19
            Riff _32, _32_5 +1
            Duration "Cont", rest,E1,G1,Gs1

            Shift_Pitch G1,A1

        _25:
        Riff _1, _3

        _27:
        Riff _23, _27 ;F,G,A,   A


        _31:
            ;31
                Duration _00, A1,A1
                Notes qtr,rest
            Riff _31, * ;External Repeat

            _31_7:
                Notes 3*_8th/2,rest, 3,A1, 5,rest

                _32:
                Duration _00, A1,A1
            Riff _31_7, * ;External Repeat

            _32_5:
            Duration _1111, rest,A1,As1,B1


        ;

        _33:
            Shift_Pitch A1,C2 ;+3
            Riff _31, _32_5 +1
            Duration "Cont", rest,A1,Gs1,G1     


        _35:
            Shift_Pitch C2,F1 ;-7
            Riff _43_BP, _45_BP
            ;Duration "Cont", rest,F1,E1,Ds1    
            ;Shift_Pitch Shift_Pitch F1,D1 -3

        BP .set Init_BP +D1
        _37_BP:
            Riff _31, _32_5 +2
            Duration "Cont", E1,F1    
            ;Duration "Cont", rest,D1,E1,F1    

        _39:
            Shift_Pitch D1,G1 ;+5
            _39_BP:
            Riff _31, _32_5 +2
            Duration "Cont", G1,Gs1
            ; Duration "Cont", rest,G1,G1,Gs1    

        _41: 
            Shift_Pitch G1,A1 ;+2

            _41_BP:
            Riff _31, _32_5 +2
            Duration "Cont", Gs1,G1  
            ; Duration "Cont", rest,A1,Gs1,G1    

        _43: ;Rel -1
            Shift_Pitch A1,F1  ;-4
            _43_BP:
            Riff _41_BP, _43 ;Internal Repeat
            ;Duration "Cont", rest,F1,E1,Ds1    

        _45:
            Shift_Pitch F1,D1 ;-3                
            _45_BP:

            Riff _39_BP, _43 -1
                BP .set Init_BP +E1

            Duration "Cont", G1,Gs1

        _49:
Loop HotHead_Bop_dmc


;============================================================
; Noise
;============================================================

Channel  HotHead_Bop_Noise
    Noise_Header HHB_NB, _d25_K

    _1:
        If_Alt Hat_2,rest
        Notes 8th,Hat_2
        Repeat _1, 26

        _4_4:
            Notes 6,Shaker_Kick
                Notes 5,Shaker_Kick
            Repeat "2b", 1 ;Triplets.

            Duration _00, Snare_6,Snare_6
            Notes _8th/2,Hat_2

                Notes _8th/4, Shaker_Kick
            Repeat "2b", 1 ;32nds 

            Duration _00, Snare_6,Snare_6
            Notes 8th,Snare_6
    ;

    _5:
        Riff _6, _7 -1
        Duration "Cont",Hat_2,Shaker_3

        _6:
            Notes 8th,Hat_2_Kick
            Duration _00, Hat_2, Solo_Kick

            Notes 8th,Snare_6
        
        _6_4:
        Duration _0000, Hat_2,Shaker_3, Hat_2,Snare_6

        Notes 8th,Hat_2_Kick
        Duration _0000, Snare_6,Solo_Kick, Snare_6,Snare_6


        _7:
        Riff _5, _7
        Repeat "2b", 6
    
    ;

    _21:
    If_Alt "Toggle"
    Riff _1, _5 
        ; Notes _8th*27/2,rest 
        ;   Repeat "2b", 1
        ;
        ; Riff _4_4, _5

    _25:
        Riff _5, _7
        Repeat "2b", 2  

        _31:
        Riff _5, _6_4
        Riff _4_4, _5

    _33:

        Riff _7, _21 ;_5, _7 x7
        Riff _31, _33


Loop HotHead_Bop_Noise