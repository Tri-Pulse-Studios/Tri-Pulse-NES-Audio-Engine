_8th .set 7+7
.align 256
py_Segment Staff_Roll_Sq0, PageFit
    _8th .set 7+7

    Channel Staff_Roll_Sq0, SR_Sq0
        Header B2, Pad_d75_8_0


        _1:
            Env_Change Pad_d75_8_0
            Shift_Pitch +Octave
            
            Notes dqt,Fs4, dqt,E4, dqt,B4
            Notes hlf,B3,  dqt,E4

            Notes dqt,Fs4, dqt,E4, (2+8)*_8th,B4
            Shift_Pitch -Octave

            _5:
            Riff _1, _5
            
        ;
    
        _9:

            Env_Change Lead_25to12_s6_v8_2f  ;new 12d25 
            _9_env:

                Notes 12*_8th,Gs3, 3*_8th/2,Gs3, 

                If_Alt Gs3, A3
                Notes 3*_8th/2,Gs3, 8th,Gs3

                ;11
                Notes dqt,Fs3, 
                
                _11_4:
                Notes (3+8)*_8th,B3 ;Sq1 Non-Riffable w/o a Tied-Note.
            _12_7:
            Notes 8th,rest
            Duration _00, Fs3,Gs3

            ;13
            Notes 12*_8th,A3, 3*_8th/2,A3, ;Riffable

            If_Alt A3,Gs3
            Notes 3*_8th/2,A3, 
            If_Alt A3, Fs3
            Notes 8th,A3

            ;15
            Notes dqt,Fs3, 8th,E3, (4+8)*_8th,E3


            _17:
            Riff _9_env, _12_7

            Shift_Pitch B2, E3
            Riff _12_7, _17
            Shift_Pitch E3, B2

        ;

        Env_Change Lead_d25_2_9_6_v12
        _25:
            Notes dqt,B3
            Duration _00, E3,rest
            Notes dhf,E3, 

            ;26
            Notes 8th,rest, 8th,B2
            Notes 3*_8th/2,E3, 3*_8th/2,Fs3, 8th,Gs3

            ;27
            Notes dqt,Gs3, 8th,Fs3, (4+7)*_8th,E3

            ;29
            Notes (1+8+4)*_8th,B3
            Notes 3*_8th/2,A3, 3*_8th/2,Gs3, 8th,E3 ;Riffable to ~_11

            ;31
            Notes dqt,Fs3, 5*_8th,Gs3
            Notes dqt,A3, dqt,Gs3, qtr,A3

            _33:
            Riff _25, _33 -1
            Notes qtr,Fs3

        ;

        _41:
        Riff _9, _41, "3b"

        ;73
            .byte Tie_Next_Note
            Notes 15*_8th,B3, 
            Repeat "2b", 1

            Notes qtr,rest

            ;77
            .byte Tie_Next_Note
            Notes 16*_8th,B3, 
            Repeat "2b", 1

            ;81
            Riff _1, _9
        ;

        ;89
        Notes whl,rest ;Room for Ending Crash.

    Loop Staff_Roll_Sq0


    Channel Staff_Roll_Tri, SR_Tri
        Header E3, Choir_v12_1f

        _1:
            Notes 16*_8th,B3
            Repeat "2b", 1

            Notes 16*_8th,A3
            Repeat "2b", 1


        _9:

            Riff _1, _9
            Riff _1, _9 ;Internal Repeats


            _25:
            Riff _73, _81
            Repeat "2b", 1
                
            ;

            _41:
            Riff _9, _41

            _73: ;73..81 x3 
            If_Alt Gs3, B3
            Notes 16*_8th,Gs3, 
            
            If_Alt Fs3,Cs4
            Notes 16*_8th,Fs3, 16*_8th,A3, 
            
            If_Alt A3,Gs3
            Notes whl,A3, 
            
            If_Alt Gs3,Fs3
            Notes whl,Gs3

        _81:
        Notes 16*_8th,E3
        Repeat "2b", 3

        Notes whl,rest ;Room for Ending Crash.

    Loop Staff_Roll_Tri
    SR_Tri_Loop:


    Channel Staff_Roll_Sq1
        Header Ds3, Choir_v12_1f

        If_Alt "Toggle"

        _1:
            Notes 16*_8th,E3
            Shift_Pitch -1
        Repeat _1, 3
            BP .set BP-3
            ;BP .set B2

        _9:
            Riff SR_Sq0::_1, SR_Sq0::_9 

            Env_Change Lead_12to25_s6_v12
            Shift_Pitch Gs3,E3
            Riff SR_Sq0::_9_env, SR_Sq0::_11_4

            Notes dqt,D3, whl,E3

            Shift_Pitch E3,Gs3
            Riff SR_Sq0::_12_7, SR_Sq0::_17
            
        _25:

        Env_Change Choir_v12_1f
        Riff SR_Tri::_25, SR_Tri::_41

        _41:
        Riff _9, _41    

        ;73
        Riff SR_Tri::_73, SR_Tri_Loop

    Loop Staff_Roll_Sq1, "Riffed"

py_Segment_End Staff_Roll_Sq0


;DMC and Noise w/ Rainbow_Road





