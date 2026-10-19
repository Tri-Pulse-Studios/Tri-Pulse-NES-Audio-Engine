
.align 256

py_Segment Award_Win_Sq0, PageFit
    _8th .set 12
    Channel Award_Win_Sq0, AW_Sq0
        Header D2, Lead_12to25_s6_v12

        _1:
                Notes 10*2, rest

                _1_2:
                If_Alt Ds2, E2
                _1_2_IA:
                    Notes 10, Ds2 ;C,D,E / Ds, F, G
                    Shift_Pitch +2
                Repeat _1_2_IA, 2
                BP .set BP +4

                Notes 10, rest

                If_Alt Gs2, A2
                    Notes 10,Gs2

                Notes 10, rest, 
                _1_5:
                Notes 10*10,As2

            Env_Change Lead_25to12_s6_v8_2f
            Shift_Pitch +6 ;Total +12
            Riff _1_2, _1_5
            BP .set BP+6

            _2_5: ;Sq1 Leaves

            .byte Volume_Slow_Fade
            Notes 4*10 +8, As3 ;the +8 lets the following sync up cheaply.

            Env_Change Pad_sqr_s4
            Shift_Pitch +4
            Duration _8x0, C4,D4, E4,F4, G4,A4, B4,C5 ;5b vs lots to have 2-byte Notes.

            Duration _00, D5,C5
            Repeat "2b", 11
        ;
        

        End_Intro:

        Set_Pitch A2

        _4:
        Env_Change Lead_12to25_s6_v12
        

        If_Alt E3, F3
        Notes 8th, E3, dqt,rest

        If_Alt Cs3, C3
        Notes 8th,Cs3, dqt,rest

        Notes qtr,A2

        _4_6:
            If_Alt Cs3, F3
            Notes 8,Cs3 ;Triplets
        Repeat _4_6, 2

            If_Alt Cs3, F3
            Notes qtr, Cs3
            

        If_Alt A2, rest 
        Notes 18,A2
        If_Alt B2, rest
        Notes 6,B2

        ;5
        Notes 8th,A2, 8th,rest

        If_Alt -1
        Notes 8th,B2, 8th,rest

        If_Alt +1
        Notes 8th,B2, 8th,rest

        Notes 8th,D3, 8th,rest


        If_Alt Cs3, C3
        Notes qtr,Cs3
        _5_6:

            If_Alt E3, A3
            Notes 8,E3 ;Triplets
        Repeat _5_6, 2

        If_Alt E3, A3
        Notes dqt,E3, 8th,rest

        If_Alt Lead_12to25_s6_v12, Lead_25to12_s6_v8_2f
        Env_Change Lead_12to25_s6_v12 ;Sq0 Change to d12


        _6:
        Notes dqt,D3
        Duration _00, rest,D3

        Repeat _6, 1

        If_Alt -1
        Notes 8th,Ds3, 8th,rest, 
        
        If_Alt -1
        Notes dhf,Ds3

        ;7
        Notes dqt,E3
        Duration _00, rest,E3 

        Notes 8th,E3, 8th,rest
        If_Alt -1
        Notes 8th,Fs3, 8th,rest 

        Notes whl,E3



        _8:
    Loop Award_Win_Sq0, End_Intro


    Channel Award_Win_Sq1
        Header B1, Lead_12to25_s6_v12

        ;1
            If_Alt "Toggle"
            Riff AW_Sq0::_1, AW_Sq0::_2_5
            If_Alt "Toggle" ;Grumble

            BP .set BP+18
            Notes 24*10, G3

        ;
            
        End_Intro:

        ;4
            Set_Pitch F2 

            If_Alt "Toggle" 
            Riff AW_Sq0::_4, AW_Sq0::_8, "3b"
        ;

    Loop Award_Win_Sq1, End_Intro


    Channel Award_Win_Tri ;2+8+80 Bytes
        Header {D4, +Octave}, Pad_sqr_s4 ;Subtle Vibrato

        ;1
            Notes 10*10, rest
            Riff AW_Sq0::_1_2, AW_Sq0::_1_5
            BP .set BP+6

            .byte Tie_Next_Note
            Notes 16*10, As4
            Repeat "2b", 1 


        End_Intro:

        Set_Pitch As3,-Octave ;Extreme Vibrato

        _4:
            Env_Change T_M6
            Notes qtr,rest, 
            
            Notes qtr,F4, qtr,A4, 
            
            If_Alt C5, C4
            Notes qtr,C5

            _4_5:
            Env_Change T_v6_0f
            If_Alt A4, F4
            Notes dhf,A4
        ;

        _5:
                Env_Change T_M6
                Notes hlf,rest
                If_Alt 2, 0
                .byte $b2 

            _5_3:
                If_Alt Ds4, E4
                Notes 8th,Ds4
                Duration _00, rest,F4
            _5_4:
            
            Notes 8th,G4
            Duration _00, rest,F4

            Riff _5_3, _5_4 -1
            Duration "Cont", rest,D4
        
            _5_5:
            Env_Change T_v6_0f  ;Can Riff _4_5.  Can get BP shift for free using the $b0
            If_Alt Ds4, C4
            Notes dhf,Ds4

        ;

        _6:
            Riff _5, _5_3
            ;Env_Change T_M6

            Notes 16,As3
        
            _6_3:
                Notes 8,As3
                If_Alt Cs4, D4
                Notes 8,Cs4, 

            Repeat _6_3, 1

            If_Alt Fs4, F4
            Notes hlf, Fs4



            _6_5:
            If_Alt -1, 0
            .byte $bf

            Notes 16,B3

            _6_7:
                Notes 8,B3
                    ;The ONLY change here is the missing If_Alt.  Change is buried deep though.
                Notes 8,D4 
            Repeat _6_7, 1

            If_Alt Gs4, G4
            Notes hlf, Gs4 

        ;

        _7:
            Set_Pitch As3,-Octave
            ; If_Alt -3,0
            ; .byte $bd

            Notes 8th,C4
            Duration _00, rest,E4
            Notes 8,G4, 8,E4, 
            If_Alt G4, C4
            Notes 8,G4

            If_Alt C4, D4
            Notes 8,C4, 8,E4, 
            
            If_Alt G4, F4
            Notes 8,G4

            _7_5:
            Env_Change T_v6_0f
            Notes whl,E4

        ;

        _8: 
        If_Alt "Toggle"
        Riff _4, _8, "3b"

    Loop Award_Win_Tri, End_Intro

py_Segment_End Award_Win_Sq0

.align 256
py_Segment Award_Win_dmc, PageFit
    _8th .set 12
    Channel Award_Win_dmc
        Header A1, T_6f_m5_v12__d25  ;T_4f_m5__d25

        _1:
        .byte Tie_Next_Note
        Notes 10*16, C2 ;whl *3
        Repeat _1, 2

        End_Intro:
        Duration _2222, F2,E2,D2,C2
        Repeat "3b", 3

        Duration _2222, As1, As1, As1, As1
        Shift_Pitch +1
        Repeat "4b", 2
        BP .set BP+2

        Duration _2222, C2,C2,D2,E2
    Loop Award_Win_dmc, End_Intro

py_Segment_End Award_Win_dmc



py_Segment Award_Win_Noise, PageFit
    _8th .set 12
    Channel Award_Win_Noise
        Noise_Header ::Award_Win_NB, d25_Kick

        Notes 10*2,Crash_3

        Volume_Set Vol_25

        

        _1_3:
        Notes 2,Rasp_c, 3,Rasp_d
        _1_4:
        Repeat _1_3, 27+32

        Vol_Fade_In Vol_37, Vol_100, 31 ;Max

        Riff _1_3, _1_4
        Repeat "2b", 31

        End_Intro:

        Notes qtr,Crash_3
        _4_3:
        Riff _5_3, _6

        _5:
        Notes qtr,Shaker_Kick
        _5_3:
        .byte $91, 6 ;R "1b", 5
        Notes 8th,Shaker_Kick

        Notes 3,Rasp_c, 3,Rasp_d
        Repeat "4b",1
        _6:

        Riff _5, _6 ;Internal Repeat
        Riff _5, _6
    Loop Award_Win_Noise, End_Intro

py_Segment_End Award_Win_Noise


