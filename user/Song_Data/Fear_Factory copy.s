_8th .set 7

;202 + 148

.align 256
Channel Fear_Factory_Sq0, FF_Sq0
    Header D4, Echo_d25_10_5_0

    _1:
        Notes 32*_8th,rest

        _3:
            Set_Volume Vol_62
            Notes qtr,E4
            _3_2:
                Duration _2222, Fs4,G4,D5,B4

            _3_5:
            Set_Volume Vol_25
            Riff _3_2, _3_5



            _4_2:
            Riff _3, _3_5 -1
            Duration "Cont", Fs4,G4
            Notes qtr,Fs4, qtr,D4

        _5:
        Notes 32*_8th,rest
        Repeat "2b", 3

        _13:
        Riff _3, _5
        Repeat "2b", 1

    ;
    .byte Clear_Special_Effects

    _17_env: ;Sq1 Entry
        Set_Env Pad_d75_10_0

        Set_Pitch A2 ; /Fs2
        If_Alt -3
        Shift_Pitch 0


        _17:
            Notes dhf,rest

            Notes 8th,A2,8th,A2
            

                If_Alt B2,As2
                Notes 8th,B2
            Repeat "2b", 1

            If_Alt D3,C3
            Notes qtr,D3

            If_Alt E3,D3
            Notes qtr,E3, qtr,G3

            _18:
            Notes dhf,rest

                If_Alt E3,D3
                Notes 8th,E3
            Repeat "2b", 1

            Notes 8th,G3,8th,G3, qtr,G3, 

            Riff _21_6, _21_8 ;qtr, Fs3/F3, dqt,D3


        _19:
        Riff _17, _19

        _21:
                Notes dhf,rest
                _21_4:
                If_Alt E3,Ds3
                Notes 8th,E3

                If_Alt Fs3,F3
                Notes 8th,Fs3

                Notes 8th,G3,8th,G3

                _21_6:
                    If_Alt Fs3,F3
                    Notes qtr,Fs3
                    
                    _21_7:
                    Notes qtr,D3
                
            _21_8:
            If_Alt E3,Ds3
            Notes qtr,E3

        _22:
        Riff _21, _22




    _23:
        Riff _21, _21_7

        Shift_Pitch A2, E3
        Notes 8th,G3,8th,A3

        If_Alt B3,As3
        Notes 8th,B3

        If_Alt D4,C4
        Notes 8th,D4

        If_Alt E4,Ds4
        Notes hlf,E4

        _24:
        Set_Env Lead_d12_d25_s6_v12

        Vol_Fade_In Vol_25, Vol_100, _8th 

        If_Alt C4,G3
        Notes whl,C4, hlf,rest



    _25:
    Riff _17_env, _23, "3b" ;Swap em, and _61 can clean Riff. 
    Riff _19,_21_4 ;17, _19  dhf,rest

    ;_33:
        ;Notes dhf,rest
        _33_4:
        .byte Clear_Special_Effects

        Set_Pitch C4, Vib_Shallow
        Set_Env Lead_sqr_1f_v12
        
        
        _33_T:
        Notes qtr,C4, hlf,G4, 
        
        If_Alt A4,D4
        Notes qtr,A4


        If_Alt "Toggle"
        .byte Common_Fade_Out
        
        _34:
        Notes whl,E4
    

        Riff _33_T, _34
        Notes 10*_8th,E4 
        _35_BP:
            Set_Volume Vol_50
            Set_Env Echo_d25_10_5_0

            Shift_Pitch -Octave ;C3

            _35:
                Duration _2222, Fs3,G3,D4,B3
                Shift_Pitch +Octave
            Repeat _35, 1
                BP .set BP+12

            Duration _6x2, Fs5,G5,A5,Fs5,G5,D5

            Shift_Pitch -1
            Notes qtr,B4

        Riff _33_4, _35_BP -2
            BP .set C4
        

        _38_7:
            Notes 16*_8th,E4

            Notes 10*_8th,rest
            Repeat "2b", 4 ;qtr + 3*2x_whl

    _43_BP:
        Set_Env Lead_d12_d25_s6_v12
        Shift_Pitch C4,F3 ;A3,Ds3


        _43:
            Notes hlf,rest, qtr,A3

            Notes dqt,rest

        _43_5:
        If_Alt Fs3,F3
        Notes qtr,Fs3, 8th,rest
        Notes qtr,G3, qtr,rest

        _44:
        Riff _43, _43_5

        If_Alt D4,C4
        Notes qtr,D4, 8th,rest
        If_Alt E4,D4
        Notes qtr,E4, qtr,rest

    _45: ;<-Sq1 
        Riff _17_env, _33_4, "3b"

    _61: ;-> Sq1
    Riff _21_4, _23
    Riff _17, _19

Loop Fear_Factory_Sq0
FF_Sq0_Loop:

Channel Fear_Factory_Sq1
    Header D4, Pad_s1_d12_v12

    


    _1: 
        .byte Tie_Next_Note
        Notes 32*_8th,E4
        Repeat "2b", 1

        _2:
        Shift_Pitch E4, G4
        Riff _1, _2

        Shift_Pitch G4, D4
        Riff _1, _2

        .byte Tie_Next_Note
        Notes 32*_8th,B4 ;BP +9
        Repeat "2b", 1

    ; ;



    If_Alt "Toggle"
    _17:
    Riff FF_Sq0::_45, FF_Sq0::_61 ;Riff FF_Sq0::_17_env, FF_Sq0::_33_4, "3b"

    _33:
        Set_Pitch A4, Vib_Shallow ;Sq0's _43_BP relies on A4, Shift -Octave
        Set_Env Echo_d25_10_5_0
        Notes (18 -6)*_8th,rest

        _34:
        Vol_Fade_Out Vol_100, Vol_12, 2*_8th

        Notes qtr,B4, qtr,G5
        Repeat "2b", 2

        Notes qtr,B4
        _35:
        Notes qtr,rest
        Riff _34, _35

        _36:
        Notes (18+16)*_8th,rest
        _38:
        Riff _34, _36

    _40:
        .byte Clear_Special_Effects

        Shift_Pitch -Octave ;F3
        Set_Env Pad_s1_d12_v12

        .byte Tie_Next_Note
            Notes 3*16/2*_8th,E4
        Repeat "2b", 1

    _45:
    Riff FF_Sq0::_43_BP, FF_Sq0_Loop

Loop Fear_Factory_Sq1, "Riffed"

.align 256
Channel Fear_Factory_Tri
    Header B2, T_1f_12v

    _1:
    Notes whl,rest
    Repeat "1b", 47

    _25:
        Notes dhf,Fs3, dhf,G3, 

        Shift_Pitch +Octave
        Notes hlf,D4, dhf,Fs4, dhf,G4, hlf,D4

        _27:
        Notes 22*_8th,E4, 
        Notes qtr,G4, hlf,Fs4, qtr,D4

        Notes 14*_8th,C4

        _29_7:
            Notes qtr,Fs4, qtr,G4, hlf,A4, qtr,G4, dhf,Fs4
            
        _30_7:
        If_Alt G4, D4 ;Only If_Alt in Tri.
        Notes qtr,G4, 26*_8th,E4, whl,rest

    ;


    Set_Pitch E2, Vib_Shallow
    _33: 
        
        Notes 16*_8th,C3, 16*_8th,A2, 32*_8th,E2
        _37:
        Riff _33, _37

        Notes 32*_8th,rest

        Set_Pitch Fs3 
        _43:
            Notes hlf,rest, qtr,D4

            Notes dqt,rest

        _43_5:
        Notes qtr,A3, 8th,rest
        Notes qtr,B3, qtr,rest

        _44:
        Riff _43, _43_5

        Notes qtr,Fs4, 8th,rest
        Notes qtr,G4, qtr,rest


        _45:
        Notes 16*_8th,rest
        Repeat "2b", 7

    ;

    _53:
    Shift_Pitch Fs3,B2
    Riff _25, _30_7
        BP .set BP +12

    _58_7:
    Notes hlf,D4, hlf,B3
    Notes 10*_8th,Fs4, qtr,E4, 
    Notes 24*_8th,Fs4, hlf,rest 

    _61_7:
    If_Alt "Toggle"
    Riff _29_7, _33

Loop Fear_Factory_Tri


Channel Fear_Factory_dmc
    Header E2, T_0f__C3

    _1:
        Set_Env T_0f__C3 ;Swaps Duty so E2/E3 and A2/A3 are different.

        If_Alt E3,E2 
        Notes 8th,E3

        Set_Env T_3f__d25
        Notes 8th,E2, 8th,E2, 8th,E2,

        _1_3:

            Riff _1, _1_3

            If_Alt "Toggle"

        _1_5:
        Riff _1, _1_5

        _2:
        ; Riff _1, _2
        ; Repeat "2b", 18
        Repeat "2b", 38

    ;

    
    _21:
        Riff _29, _32
        Notes 12*_8th,E2, hlf,rest

        _25:
        Riff _1, _2
        Repeat "2b", 3


        _29:
            Shift_Pitch E2, A2
            Riff _1__2, _x2
            Shift_Pitch A2, E2


            _1__2:
                Riff _1, _2
                _32:
                Repeat "2b", 1
            _x2:

    ;

    _33:
    Notes 32*_8th,rest
    Repeat "2b", 2


    _39:
    Riff _1, _2
    Repeat "2b", 9  

    Riff _21, _33
    Riff _29, _33


Loop Fear_Factory_dmc ;45B  (+2 to not use 16/8 time)


Channel Fear_Factory_Noise
    Noise_Header FF_NB, _d50_K

    _1:
        Notes 32*_8th,rest
        Repeat "2b", 1

        _5:
        Riff _7, _7_3
        Repeat "2b", 1
        
        Notes 24*_8th,rest

        _7:
            Notes qtr,Hat_e
            Notes 8th,Hat_2, 8th,Hat_2
        _7_3:
            Notes qtr,Hat_e, 

            Notes 8th,Hat_7, 
            Duration _00, Hat_7, Hat_7


            _7_5:
                Shift_Pitch ::Hat_7, ::Hat_8
                Duration _0000, rest,Hat_8,Hat_8,Hat_8
            Repeat _7_5, 2
                BP .set BP + 2*(::Hat_8 - ::Hat_7)

            Duration _0000, Hat_b,Hat_b, rest,Hat_b,
                
            Shift_Pitch ::Hat_a, ::Hat_7
        _8:
        Notes 16*_8th,rest

    _9:
    Riff _5, _9

    _13:
        Notes qtr, Hat_e_Kick
        Notes 8th,Hat_2, 8th,Hat_2

        _13_3:
            Notes qtr, Snare_6
            _13_4:
            Notes 8th,Hat_2, 8th,Hat_2

        _13_5:
        Duration _1111, Hat_e_Kick, Hat_2, rest, Hat_2
            ;Doesn't Need to be Duration.

        Riff _13_3, _13_5

        _14:
        Riff _13, _14
        Repeat "2b", 2

    _17:
        Riff _13, _14 ;Combined uses long-repeat, and deduplication needed anyway.
        Repeat "2b", 5

        _23:
            Riff _13, _13_4
            
            Duration _8x1,  Snare_6, Snare_6, Hat_e_Kick, Hat_e_Kick
            Duration "Cont", rest,  Hat_e_Kick, Snare_6, Snare_6_Kick

            Notes qtr,Hat_e_Kick

            _24:
            Notes 10*_8th,Snare_6_Kick, qtr,Cymbal_4, hlf,Snare_6_Kick

    ;

    _25:
    Riff _13, _14 
    Repeat "2b", 6

    _32:
        Notes qtr,Hat_e_Kick
        Notes 8th,Hat_2, 8th,Cymbal_4

        Riff _13_3, _13_5 +1
        Duration "Cont", Hat_e_Kick, Snare_6, rest, Hat_e_Kick
        Riff _13_3, _13_5

    _33:
    Notes 16*_8th,rest
    Repeat "2b", 6

    _40:
    Riff _32, _33
    Repeat "2b", 4

    _45:
    Riff _17, _25

    Riff _13, _17 ;_14 x4

    Riff _25, _33

Loop Fear_Factory_Noise