
;Stats
;Sq0 59 + 124
;Sq1 94

;Tri 57
;DMC 66

;Noise 66

_8th .set 6+6



.align 256
Channel Khevari_Sq0, KD_0
    Header A0, Lead_d12_s9_v6, Vib_Deep

    _1:
            Duration _111_2_111_b, B0,rest,Fs1,F1,Fs1,F1,Fs1,$b0

            _2:
            Duration _111_2_111_b, D1,B0,rest,C1,D1,C1,As0,$b0

            _3:
            Riff _1, _2 -1
            Duration "Cont", Fs1,$b3
                BP .set BP+3

        _4:
        Notes 8th,B1,8th,D2,8th,rest
        Notes qtr,Cs2, qtr,As1, 8th,Cs2

        Shift_Pitch -3
        Shift_Pitch +Octave ;Re-read again, so not Set_Pitch.


        Riff _1, _4
            BP .set BP+3
        _8:
        Duration _111_3, G2,Fs2,F2, Fs2
        Shift_Pitch -3

        _8_6:
        Notes qtr,Cs2

        _9:
        Riff _1, _9
            BP .set A2

    ;


    Set_Env Pad_d25_v12
    _17:
            Notes dhf,Fs3

            If_Alt B2, Cs3
                Notes qtr,B2

            Notes dqt,Fs3
            Duration _00, E3,Fs3 ;Inaccurate, but doesn't sound bad.

            If_Alt A3,G3
                Notes 3*_8th/2,A3
                
            If_Alt G3,A3
                Notes 3*_8th/2,G3, 
                
            If_Alt E3,G3
                Notes 8th,E3

            Notes whl,Fs3
        _20:
        Notes dqt,B3,dqt,As3,qtr,Fs3

        _21:
        Shift_Pitch Fs2,B2
        If_Alt "Toggle"
        Riff _17, _20

        Notes dqt,G3,qtr,Fs3

         ;Sync 

        ; Notes dhf,Fs3, qtr,B2

        ; Notes dqt,Fs3
        ; Duration _00, E3,Fs3
        ; Notes 3*_8th/2,A3, 3*_8th/2,G3, 8th,E3

        ; Notes whl,Fs3
        ; Notes dqt,B3,dqt,As3,qtr,Fs3

        ; _21:
        ; Shift_Pitch B2,Fs3

        ; Notes dhf,B3, qtr,Fs3

        ; Notes dqt,B3
        ; Duration _00, Fs3,B3
        ; Notes 3*_8th/2,C4, 3*_8th/2,D4, 8th,C4

        ; Notes whl,B3
        ; Notes dqt,G3,qtr,Fs3

    ;


    _24_6:
    Set_Env Lead_d12_s9_v6
    Duration _1111, Fs3,G3,A3,B3
    .byte _8th_Cont_Sweep, 8


    Duration _f_0000_f_1001, Minus_Octave, E3,G3,B3,E4, Plus_Octave, \
       B3, Cs4,rest, D4

    _26:
        Notes dqt,Cs4
        _26_2:
            .byte _8th_Cont_Sweep, 4


        Notes qtr,Fs3

        Shift_Pitch -Octave
        Notes 8th,Fs2
        .byte _8th_Cont_Sweep, 12

        Set_Pitch As0, Vib_Deep
        Notes 8th,Fs1



    _27:
        Notes 8th,As0

        _27_2:
            If_Alt "Toggle" ;Prev Toggle in _21

            Duration _00, B1,rest
            If_Alt As1,C2
            Notes 8th,As1

        Repeat _27_2, 2

    _28:
        Notes qtr,As0
        Duration _00, B1,rest

        Notes 8th,As0, 

        Shift_Pitch As0, A0
        Riff _28, 3

        
        Set_Pitch G1 ;+11
        Notes 8th,Cs2, 8th,Fs2, 
        
        _29:
        Notes 8th,G2
        _29_2:
        .byte _8th_Cont_Sweep, 12

                                ;NOP
        Duration _f_0000_f_1001, Clear_Special_Effects, G1,B1,D2,G2, Plus_Octave
            BP .set BP+12
        Duration "Cont", B2, Cs3,rest, D3

        _30:
        Notes qtr,E3, 8th,E3, 8th,G3, 8th,Fs3
        .byte _8th_Cont_Sweep, 12

        Set_Pitch As1
        Notes qtr,Fs2, 8th,D2

    _31:
        If_Alt "Toggle" ;Reset
        Riff _27, _28

    _32:
    Notes qtr,B2

    Set_Pitch Cs3, Vib_Shallow    
    Duration _00, D3,rest

    Notes 8th,A3, qtr,G3, qtr,Fs3, 8th,D3

    _33:
    Notes 8th,E3
    Riff _29_2, 3 ;Sweep, Dur Init

    Duration "Cont", Minus_Octave, E3,G3,B3,D4, Plus_Octave,\
        E3, Fs3,rest, G3

    _34:
    Notes dqt,As3
    .byte _8th_Cont_Sweep, 3

    Notes qtr,Fs3, 8th,Cs3, 8th,As3, 8th,Cs4
    .byte _8th_Cont_Sweep, 3

    Notes 8th,As3, 8th,rest

    Shift_Pitch As3,D4
    Notes qtr,E4, 8th,D4, 8th,Cs4
    _36:
    Riff _34, 3

    Notes qtr,B3



Inc_Page KD_0_Cont, KD_0_BP, KD_0_EB



Channel Khevari_Sq1 ;88 Bytes
    Header A0, Pad_d12_s3_v12, Vib_Deep

    Echo .set 7

    _1:
        Notes Echo,rest
        Riff KD_0::_1, KD_0::_3

        _3: ;Intro
        Riff KD_0::_3, KD_0::_8_6 ;_16_6
        BP .set BP+12

        Notes 2*_8th -Echo, Cs2

        Shift_Pitch +Octave
        Set_Env Pad_d25_v12

    ;

    _9:
        Duration _332_x2, B2,Fs3,B2, Fs3,G3,E3

        _11:
        Duration _332_x2, B2,Fs3,B2, G3,Fs3,Cs3

    ;

    _13:
        Shift_Pitch A2, B2
        Set_Env Lead_sqr_s5_v8
        _13_no_BP:
        
        Duration _111_2_111_b, Fs3,rest,B3, As3, B3,As3,B3, $b0
        _14:
        Duration _111_2_111_b, Fs3,D3,rest, G3, A3,G3,F3, $b0
        Riff _13_no_BP, _14

        Notes 8th,B3, 8th,G3, 8th,B3

        Notes qtr,Cs4
        .byte _8th_Cont_Sweep, 8

        Notes qtr,Fs3

    ;

    _17:
        Set_Pitch A1
        Riff _9, _13 

        Shift_Pitch +Octave
        Riff _9, _13 -2
        Duration "Cont", B2,D3,Cs3,A2

    ;

    _25:
        Set_Env Pad_d25_v12
        Shift_Pitch A2, F2
        Duration _332_x2, E3,Fs3,G3, Fs3,Cs3,Fs2

        _27:
        Set_Pitch A1, Vib_Deep
        Riff _9, _11 -1
        Duration "Cont", E2,D2

        _29:
        Shift_Pitch +Octave
        Duration _332_x2, D3,E3,G3, G3,Fs3,E3

        _31:
        Notes whl,Fs3
        Duration _332_x2, D3,E3,Fs3, E3,Fs3,G3
        Notes whl,Fs3

        _35:
        Duration _332_x2, Fs3,As3,Fs3, B3,D3,Fs3
        Duration _332_x2, D3,E3,Fs3, G3,E3,G3

        _39:
        Notes whl,Fs3

        Shift_Pitch A2,Fs2
        Notes dqt,Fs3,dqt,E3,qtr,Fs2

    ;

    _41:
        Set_Env Lead_sqr_s5_v8

        .byte Tie_Next_Note
        Notes whl,B2
        Vol_Fade_Out Vol_100, Vol_12, 12

        Notes 8*_8th + Echo,B2 ;Setup echo on loop

    ;

    _43:
Loop Khevari_Sq1, _3


.align 256
Channel KD_0_Cont
    Header KD_0_BP, KD_0_EB, "Cont"

    ;Shift_Pitch +2


    Shift_Pitch -7
    Set_Env Lead_sqr_s5_v8

    Notes 8th,B2, 8th,A3
    _37:
    Notes 5*_8th,G3, 8th,rest

    Notes 8th,D3, 8th,A3, qtr,G3
    Duration _1111, Fs3,D3,E3,rest

    Notes qtr,A3
    .byte _8th_Cont_Sweep, 3

    .byte Tie_Next_Note
    Notes hlf,Fs3
    .byte Init_Sweep, 1
    Notes hlf,Fs3

    Shift_Pitch -7
    Notes dqt,As2, dqt,Fs2, qtr,Cs3

Loop KD_0_Cont
;



Channel Khevari_Tri, KD_T  ;Tri Mostly is full of SFX, so it just uses DMC data for free. 
    Header As2, T_2f__E2


    _1: ;<- Tri
        ;_1
            Duration _111_2_111_b, B2,B3,rest, B2, B2,B3,As2, $b0


            _2:
            Duration _111_2_111_b, B2,B3,rest, C3, C4,As2,As3, $b0


            _3:
            Riff _1, _2 -1
            Duration "Cont", As2, $bb 
                BP .set BP-5

            _4:
            Notes 8th,G2, 8th,G3, 8th,rest,   
        _4_4: ;DMC
        Notes qtr,Fs2, 
        _4_5:
        Notes 8th,Fs3
        _4_7: ;-> Tri
        Notes 8th,Fs2, 8th,Cs3

    ;

    _5:

    Shift_Pitch -7
    Riff _1, _4_7



    Set_Pitch D4
    Set_Env T_M12

    _8_7:
        Riff _10_7_Sweep, _12_7

        _10_7_Sweep:
            Set_Volume Vol_100, "F"
            .byte Init_Sweep, 15 ;Sweep No Longer Resets.

            Notes 8th, Fs4
            Notes hlf, E4

            _11:
            Notes dqt, Fs4, 5*_8th, Fs4

            If_Alt "Toggle" ;Run Every Sub-Loop. 

            _12:
            Notes qtr,Fs4

            .byte Clear_Special_Effects


        

        _12_6_Clr:
            If_Alt D4, C5 ;C5, D4, C5, rest 
            Notes 3,D4, 3,rest

        Repeat _12_6_Clr, 1
        
        

        _12_7:
        
        Riff _8_7, _12
        Notes dqt,rest
    ;

    _16_7:
    Riff _8_7, _16_7
    _24_7:
    Riff _8_7, _24_7 ;Repeat "2b", 2  Internal Repeat

    Notes qtr,rest

Loop Khevari_Tri




Channel Khevari_dmc 
    Header As1, T_2f__E2

    Notes 16*_8th,rest
    Repeat "2b", 3

    _9:
            Riff KD_T::_1, KD_T::_5
            Shift_Pitch +5 ;Tri -7s
            
        Repeat _9, 2

        Riff KD_T::_1, KD_T::_4_5
            BP .set BP -5

        Notes 8th,As1,8th,Cs2,8th,Fs2

    ;

    Shift_Pitch Fs1, E1
    BP .set Ds1
    _25:
        Riff KD_T::_1, KD_T::_2 -1
        Duration "Cont", F1, $b1
            BP .set BP+1

        _26:
        Riff KD_T::_4, KD_T::_4_4

        _26_4:
        Notes qtr,Fs1
        
        _26_6:
        Notes qtr,D2,8th,Cs2


    _27:
        Shift_Pitch F1, B1

        Riff KD_T::_1, KD_T::_3 -3
        Duration "Cont", rest, As1, As1,Cs2,Fs2, $bc
            BP .set BP-4


    _29:
    Riff KD_T::_1, KD_T::_2 -2
    Duration "Cont", G2,A1,G1, $be 
        BP .set BP -2

    _30:
    Riff _26, _29 -1
        BP .set BP +6

        Duration "Cont", D2, $b9
            BP .set BP -7


    _33:
    Riff _25, _26_6
        BP .set BP+1
    Notes qtr,Fs2, 8th,As1


    _35:

    Duration _111_2_111_b, Fs1,Fs2,rest, As1, D2,Cs2,B1, $b5
        BP .set BP+5

    
    _36:
        Riff _26, _26_6

        Shift_Pitch As1, G1
        Notes qtr,A1, 8th,Fs1

    _37:
        Riff KD_T::_1, KD_T::_2 -1
        Duration "Cont", Fs1, $bc
            BP .set BP-4

    _38:
        Riff _26, _26_6

        Shift_Pitch +2
        Notes qtr,E2, 8th,F2

    _39:
        Notes dhf,Fs2, 8th,Cs2,8th,As1

    _40:
        Notes 5*_8th,Fs1, qtr,As1,8th,Cs2



Loop Khevari_dmc



Channel Khevari_Noise
    Noise_Header Khevari_NB, _d50_K 

    Set_Volume Vol_87

    _1:
            Notes 8th,Crash_3
            Riff _1_5 +1, _2

            _1_5:
                Notes 8th,Hat_2, 
                _1_6:
                Notes 8th,Hat_2, 
                _1_7:
                Notes 8th,Wash_5
                _1_8:
                Duration _00, Hat_2, Hat_2

        ;

        _2:
        Notes 8th,Hat_2

        Riff _1 +1, _2 -1
        Duration "Cont", Hat_2_Kick, Hat_2

        _3:
        Riff _1, _2

        _4:
        Notes 8th,Hat_2

        Riff _1 +1, _2 -4
        _4_6:
            Notes 8th,Hat_2_Kick, 8th,Wash_5
            Duration _00, Hat_2_Kick, Hat_2 ;19b

    ;

    _5:   
        Riff _1, _4

        _8:
        Notes 5*_8th,Crash_7
     
        _8_6:
        Notes 8th,Hat_2_Kick, ;Offset Kick
        Riff _1_7, _2

    ;



    _9:
    Riff _33, _40_6 ;Redefine Data here for _17 Repeat.
    Riff _36_6, _37

    _17:
    Repeat "4b", 1


    _25:
    Riff _33, _39_8
    Notes dhf,Crash_7 ;Offset Crash
    Riff _36_6, _37




    _33:
        Riff _35, _37

        _35:
            Notes 8th,Crash_3,

            Riff _36 +1, _37 -2
            Duration _00, Hat_2, Hat_2 ;Need to fully seperate out Duration for _32
            ;

            _36:
            Notes 8th,Hat_2_Kick, 
            
            Riff _1_6, _2 -1
            Duration "Cont", Wash_8_Kick, Hat_2


            Notes 8th,Hat_2, 

            _36_6:
            Notes 8th,Hat_2_Kick, 8th,Wash_8
            Duration _00, Wash_8, Hat_2


        _37:

        Riff _33, _36 -2
        _39_8:
        Duration _00, Hat_2, Hat_2

        _40:
        Notes dqt,Crash_7, qtr,Solo_Kick
        _40_6:
        Riff _8_6, _9 

    ;

    _41:
Loop Khevari_Noise




.align 1024