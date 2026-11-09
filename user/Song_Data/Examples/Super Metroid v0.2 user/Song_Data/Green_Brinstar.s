; Statistics
; --------------------------------
; Total: 439 Bytes
;
;   SQ0: 111 Bytes
;   SQ1: 76 Bytes
;   TRI: 60 Bytes
;   NOISE: 94 Bytes
;   DMC: 98 Bytes

_8th .set 6+7


.align 256
Channel Green_Brinstar_dmc, GB_dmc 
    Header C2, T_2f_v12__d12 

        Notes 16*_8th,rest 
        Repeat "2b", 1


    _5_BP:
        Set_Pitch C2, Vib_Deep ;Riffed a Lot. Vib_Deep for Sq0

        _5_Env:
        Set_Env T_2f_v12__d12

            _5:
            Duration _0000, C2,C3,rest,C3
 
            _5_3:
            Set_Env T_M11__d25
            Notes 8th,As2, 8th,C3


        _5_5:
        Set_Env T_M6__d25
        Riff GB_Sq0_1_5, GB_Sq0_3

        
        _7:
        Riff _5_Env, _7
        Repeat "2b", 2


    ;


    _13:
        Riff _5_BP, _5_5
            BP .set C2

        Set_Env T_0f__d25
        _13_BP: ;Sq0

        Shift_Pitch C2, G2
        Notes 8th,rest, 8th,C3, 8th,rest, dqt,C3, qtr,rest
        
        _14_5:
        Notes qtr,F3, qtr,rest


        _15:
        Riff _13, _14_5
            BP .set G2

        _16_5:
        Shift_Pitch G2, D3
        Notes qtr,D4, qtr,rest 


        ;17
        Riff _13, _16_5
        BP .set G2

        ;20.5
        Notes qtr,G3, qtr,rest


    ;





    _21:
            Riff _27, _28_3 +1
                BP .set C2
            Duration "Cont", rest,G2,rest,As2

            Riff _27_7, _28

        _23:
        Riff _21, _23
        Repeat "2b", 1 ;Repeat _21, 2



        _27:
    
            Riff _5_BP, _5_5
            BP .set C2

            Set_Env T_2f_v12__d12
            Notes 8th,rest, 8th,C3, 

            _27_7:
                Notes 8th,rest
                Duration _00, C3,C3


            _28:
            Riff _5, _5_3

        _28_3:
        Duration _1111, rest,C3,rest,C3
        Riff _27_7, _28


        _29:
        Riff _21, _27

        _35:
        Duration _0000, C2,G2,rest,G2

        Notes 8th,rest, 8th,G2
        Repeat "2b", 2


        _36:
        Riff _35, _36


    ;

    _37:
            Notes qtr,G2,8th,rest, 8th,G2, 
            Notes qtr,rest, 8th,G2,8th,rest

            _38:
            Riff _37, _38

            _39:
            Repeat "2b", 2

        
        _41:
        Shift_Pitch G2, Gs2
        Riff _37, _41

        _45:
        Shift_Pitch Gs2, G2
        Riff _37, _45
            BP .set BP+1

        _53:
        Shift_Pitch Gs2, As2
        Riff _37, _39

        _55:
        Repeat _53, 1
            BP .set BP+2

    ;

    _57:
    Shift_Pitch C3, G2
    Riff _37, _41

Loop Green_Brinstar_dmc, _5




Channel Green_Brinstar_Sq0, GB_Sq0
    Header C3, Lead_d25_13_0


    _1_Vol:
        Vol_Fade_In Vol_25, Vol_100, _8th*4 ;52 not in range of 1..32. Everything is doubled.

        _1:
            Duration _1111, C3,G3,F3,G3, 
            
            _1_5:

            ::GB_Sq0_1_5: ;DMC
                Duration _1111, F3,Ds3,D3,Ds3
                
                _2:
                Riff _1, _1_5 +1
                Duration "Cont", F3,G3,As3,C4 
            ::GB_Sq0_3:

        _3:
        Riff _1, _3 
    
    ;

    _5:
    Repeat _3, 4 ;Riff _1, _3 x4







    _13_BP:
            Set_Pitch C1
            Riff GB_dmc::_5_Env, GB_dmc::_5_5

            _13_5_Init:
                    Set_Pitch G4, Vib_Shallow

                    If_Alt -7
                    Shift_Pitch 0

                    Set_Env Pad_d25_s3  
                    Vol_Fade_In Vol_37, Vol_100, _8th

                _13_5:
                    If_Alt G5,F5
                    Notes 8th,G5, 8th,G4, 8th,C5
                Repeat _13_5, 1

            _14_3:
            Vol_Fade_Out Vol_100, Vol_37, _8th
            Riff _13_5, _14_3

            .byte Clear_Special_Effects
        
        If_Alt "Toggle"
        _15:

        Riff _13_BP, _15

        _17:
        Riff _13_BP, _17
        



    ;



    Set_Pitch C3;Shift_Pitch -Octave
    _21:
                Set_Env Lead_sqr_2_10_4_v12
                Duration _6x8, G3,As3,D4,C4,G3,As3

            _27:
            Notes whl,C3

            
            Riff GB_dmc::_5_BP,GB_dmc::_5
                BP .set C2
            Riff GB_dmc::_28, GB_dmc::_29

        ;


        Shift_Pitch +Octave
        _29:
        Riff _21, _27
        ;35
        Notes whl, D4



        ;Shift_Pitch -Octave
        _36:
        Riff GB_dmc::_5_BP,GB_dmc::_5
            BP .set C2
        Riff GB_dmc::_35, GB_dmc::_36
 

    ;   


    
    _37: ;-> Sq1

Inc_Page GB_Sq0_Cont, GB_0_BP, GB_0_EB


Channel Green_Brinstar_Sq1, GB_Sq1
    Header C1, Lead_d25_13_0  

    Riff GB_Sq0::_1_Vol, GB_Sq0::_5


    _5_init:
        Set_Pitch G3
        Set_Env Lead_sqr_2_10_4_v12
        _5:
        Duration _6x8, C4,G4,D4,As3,  C4,G4

        ;11
        Shift_Pitch +Octave
        Notes whl,D5, whl,As4

    ;




    _13:
        Riff GB_dmc::_13, GB_dmc::_13_BP
            BP .set C2
            ;Set_Env Pad_d75_8_1 
            
            Notes qtr,rest, 8th,C2, 8th,G2

            _14:
            Notes 8th,C2, qtr,F2, qtr,As2
            _14_6:
            Notes 8th,F2, qtr,G2

        _15:
        Riff _13, _14_6, 
        Notes 8th,D3, qtr,As2


        _17:
        Riff _13, _15
        Riff _13, _14

        _20:
        Notes 8th,Ds2, qtr,F2, qtr,As2, 8th,G2, qtr,D3  ;Not worth a Custom _2111_2212 Dur Set
    

    _21:
    Riff _5_init, _5 +1
        BP .set G3
    Duration "Cont", C4,D4,F4,Ds4,C4,D4


    _27:
        Riff _36, 3
            BP .set C1
        Riff GB_dmc::_28, GB_dmc::_29

    Repeat _27, 1


    _29:
    Riff _21, _27
        BP .set G3
    _35:
    Notes whl,G4


    _36:
    Set_Pitch C1
    Set_Env Pad_d12_s4_2f
    
    Riff GB_dmc::_35, GB_dmc::_36







    Riff _5_init, _5
    BP .set G3
    _37:
    Notes 16*_8th,G3
    Notes whl,D4, whl,As3

        _41:
        Shift_Pitch G3, Gs3
        Riff _37, _41

            Shift_Pitch Gs3, G3 ;Rest back to G3
            _45:
            Riff _37, _45
            BP .set G3 

    _53:
    Notes 16*_8th,As3

    _55:
    Notes 16*_8th,C4



    _57:

    Notes whl,G4,  whl,G4

    Repeat "2b", 1 

    ; Shift_Pitch G3, C3
    ; Notes qtr,rest, dhf,D3
    ; Notes dhf,C3,  whl,D3
    ; Notes hlf,As3, hlf,G3, qtr,D4

Loop Green_Brinstar_Sq1, _5_init



.align 256
Channel GB_Sq0_Cont, GB_0_Cont
    Header GB_0_BP, GB_0_EB, "Cont"

    _37:
        Set_Env Pad_d75_8_1 

            Duration _8x1,   G2, As2, A2, G2
            Duration "Cont", As2, A2, G2, As2
        _38:
        Repeat "5b", 1

        _39:
            Set_Env Lead_sqr_2_10_4_v12
            
            If_Alt Plus_Octave, Clear_Special_Effects ;NOP
            Shift_Pitch +Octave

            
            If_Alt rest,As3 ;Tri sounds bad when it mutes.
            Notes 8th,rest
            
            
            Notes whl,As3, 7*_8th,G3 

            If_Alt Minus_Octave, Clear_Special_Effects ;NOP
            Shift_Pitch -Octave

        _41:
        Shift_Pitch G2, Gs2  
        Riff _37, _41

            _45:
            Shift_Pitch Gs2, G2
            Riff _37, _45
            BP .set BP+1

        _53:
            Shift_Pitch Gs2, As2
            Riff _37, _39

            ;55
            Shift_Pitch As2, C3
            Riff _37, _38
            Duration _8x1,   C3, D3, Ds3, C3
            Duration "Cont", D3, Ds3, C3, Ds3

    ;

    Set_Env Lead_sqr_2_10_4_v12

    _57:
    Shift_Pitch +7
    Notes qtr,rest, dhf,D3
    Notes dhf,C3,  whl,D3
    Notes hlf,As3, hlf,G3, qtr,D4



Loop GB_Sq0_Cont, GB_Sq0::_5


Channel Green_Brinstar_Tri
    Header C4, Lead_sqr_2_10_4_v12,  

    Notes 16*_8th,rest
    Repeat "2b", 1


    _5:
        Duration _8888, G4, C4, As4, D4
    Repeat _5, 1  



    _13:
        Shift_Pitch -Octave
        Set_Env T_2f_v12__d12
        Notes dqt,rest

        _13_4:
            Notes dqt,rest, qtr,G3, qtr,F3, dqt,As3
        _14_6:
        Notes dhf,G3


        _15_4:
            Riff _13_4, _14_6
        _16_6:
        Notes dhf,As3

        ;17.4
            Riff _13_4, _16_6
        ;20.6
        Notes dqt, D4 ;14b



    Set_Env Lead_sqr_2_10_4_v12
    _21_BP:
    Shift_Pitch +Octave
    _21:
    BP .set C4
    Notes dhf,Ds4, qtr,C4, dhf,F4, qtr,C4
    _23:
    Notes dhf,Gs4, qtr,As4, whl,G4
    _25:
    Riff _21, _23
    _27:
    
    Shift_Pitch -Octave
    Notes whl,G3, whl,rest

    _29:
    Riff _21_BP, _27 ;15b
    BP .set C4
    Notes whl,G4, whl,rest 



    Set_Pitch C2
    _37:
        If_Alt "Toggle"
        Riff GB_0_Cont::_37, GB_0_Cont::_57, "3b"


    

    _57:
    Set_Pitch As3
    Notes hlf,G4, hlf,As3
    Notes qtr,C4, dhf,As3

    Shift_Pitch 7
    _59:
    Notes dhf,G4, qtr,As4
    Notes hlf,D5, hlf,As4

    _61:
Loop Green_Brinstar_Tri, _5




Channel Green_Brinstar_Noise
    Noise_Header Green_Brinstar_NB, d25_K

    Vol_Fade_In Vol_25, Vol_100, _8th*4

    _1:
        Duration _1111, Hat_1,Hat_1,Snare_8,Hat_1

        Repeat _1, 6
        ;4.5
        Notes 8th,Hat_1,  8th,Hat_1,  
        Duration _0000, Snare_9_K, Hat_1, Snare_8_K, Snare_8_K


    _5:
        Riff _17, _20_7

        _8_7:
        Notes 8th,Snare_9_K
        Duration _00, Snare_8_K,Snare_8_K
        _9:

    Repeat _5, 2


    _17:
        Notes 8th,Hat_c,  8th,Hat_c
        Notes hlf,Snare_8_K,  qtr, Snare_8_K

        _18:
            Duration _0000, Hat_c, Hat_b, rest, Hat_b

            _18_3:
            Duration _1111, Snare_8_K, Hat_1, Hat_1, Hat_1

            _18_7:
            Notes 8th,Snare_8_K,  8th,Hat_1

        _19:
        Riff _17, _18

        _20:
            Riff _18, _18_7


    _20_7:
    Duration _0000, Snare_9_K,Snare_9_K,Snare_8_K,Snare_8_K



    _21:
        Riff _17, _18

        _22:
        Notes qtr,Hat_b
        Riff _18_3, _20

        _24:
        Notes qtr,Hat_b
        Riff _18_3, _18_7
        Riff _8_7, _9


        _25:
        Riff _21, _25
        Repeat "2b", 2


    ;

    _37:
            Notes 8th,Hat_c,  8th,Hat_c,  

            _37_3:
            Notes 8th,Snare_8_K

            Set_Volume Vol_50

        _37_4_vol:
        If_Alt Timpani_d, Timpani_c
        Notes dqt,Timpani_d

        _37_7:
            .byte Clear_Special_Effects

            _37_7_clr:
            Notes qtr,Snare_8_K


        _38:
            Notes qtr,Hat_b
            Riff _37_3, _37_7_clr

            _38_7:
            Riff _8_7, _9

        _39:
        Riff _37, _39

        If_Alt "Toggle"
        _41:
            
        Riff _37, _41
        Repeat "2b", 2


    _53:
        Riff _37, _37_4_vol
        Notes dqt,Timpani_b ;Tertiary If-Alt

        .byte Clear_Special_Effects
        Notes qtr,Snare_8_K


        _54:
        Duration _6x1, Hat_1, Hat_1, Snare_8_K, Hat_1, Hat_1, Hat_1
        _54_7:
        Riff _8_7, _9

        _55:
        Riff _53, _55

    _57:
        Riff _53, _54
        Riff _37, _38

        _59:
        Riff _53, _54_7
        Riff _20_7, _21

Loop Green_Brinstar_Noise, _5

.res 512