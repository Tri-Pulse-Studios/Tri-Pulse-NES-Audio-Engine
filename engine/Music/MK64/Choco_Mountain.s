_8th .set 6 ;6

.align 256
py_Segment Choco_Mountain_Tri, PageLead, CM_Sq0_Cont

    _8th .set 6
    Channel Choco_Mountain_Tri, CM_Tri
        Header Cs3, T_M6, 
    
        _1:
        Notes qtr,rest, ;Ending Syncs with its own free qtr,rest
                        ;Then its re-used  for Riff _1, _9
            _1_2:
        
                
                Riff _5, _6
                Repeat "2b", 2
                Duration _4444, G3,G3, G3,G3,

                _5:
                    Duration _4444, G3,G3, Fs3,Fs3
                _6:
                Duration _4444, A3,A3, G3,G3

            _7:
            Duration _4444, A3,A3, A3,A3

            ;8
            Notes hlf,A3, qtr,A3, whl,A3, 
            
            
            ;9
                Riff _1, _7
            ;15.2
            Duration _4444, Fs3,Fs3, Fs3,Fs3 ;Can _8x4 Cont

            ;16.2
            Notes hlf,B3, qtr,B3, whl,B3, 
        ;
    
        
        Env_Change T_1f_v8__d12
        _17_BP:
        Shift_Pitch Cs3, G3 ;+6
        _17:
        
            ;
                Riff _21, _23 ;A

                ;19  ;B
                    If_Alt As3, A3
                    Notes whl,As3, 

                    _19_5:
                    If_Alt Gs3, A3
                    Notes hlf,Gs3
                    Repeat "2b", 1

                    ;20
                    Notes qtr,G3, qtr,G3, qtr,rest

                    If_Alt Gs3, A3
                    Notes qtr,Gs3, qtr,rest

                    If_Alt A3, As3
                    Notes qtr,A3, 

                    If_Alt As3, B3
                    Notes hlf,As3

                _21: ;A
                        Notes whl,C4, 

                        If_Alt Ds4, E4 
                        Notes hlf,Ds4, 

                    _21_7:
                    Notes hlf,C4


                    ;22
                    If_Alt As3, B3
                    Notes qtr,As3, 

                    _22_2:
                        If_Alt Ds4, D4
                        Notes 14*_8th,Ds4

                _23: ;C
                        Notes hlf,D4, dqt,D4, 8th,D4, 

                    _23_5:

                If_Alt F4, C4, 
                Notes 8th,F4

                    _23_6:
                        Notes 8th,rest, 

                        If_Alt Ds4, D4
                        Notes hlf,Ds4 

                    _23_8:
                Notes 8th,C4, 8th,rest, 

                If_Alt Ds4, B3
                Notes 12*_8th,Ds4, hlf,rest

            ;25


                Riff _17, _21_7  
            ;Riff _17, _21  ;A+B


            ;29
            ;Riff _21, _21_7 ;A*
            If_Alt G4, E4
            Notes hlf,G4, 

            ;30
            If_Alt F4, D4
            Notes qtr,F4, 

                Riff _22_2, _23_5 ;D
            Notes 8th,D4, 


                Riff _23_6, _23_8 ;8th,rest, G3 if-alt'ed

            If_Alt F4, D4
            Notes 8th,F4, 8th,rest, 

            If_Alt F4, D4
            Notes 12*_8th,F4,  hlf,rest,

            ;
        _33: 



        
        Shift_Pitch G3, Cs3
        Env_Change T_M6 ;Reset to Header

        ;33
            Notes qtr,rest 

            Notes hlf,G3
            Repeat "1b", 31 ;8 measures of just G3




            ;41
            Riff _5, _6 ;G,G,Fs,Fs
            Repeat "2b", 3

            _45:
            Duration _4444, E3,E3,D3,D3 
            Repeat _45, 1

            ;47
            Riff _5, _6 ;G,G,Fs,Fs
            Repeat "2b", 1

            _49:
                Notes hlf,Fs3, hlf,Fs3,  qtr,Fs3,
                _49_7:
                Notes qtr,F3, hlf,F3

                Notes hlf,E3,  hlf,E3,   qtr,E3,
                Notes qtr,F3, hlf,F3
            _51:

            Riff _49, _51
            Repeat "2b", 1

            _55:
                Riff _49, _49_7
                Notes qtr,Fs3, hlf,Fs3
            Repeat _55, 1
        ;

    Loop Choco_Mountain_Tri, _1_2 ;Starting rest sync


    Channel Choco_Mountain_Sq0, CM_Sq0  ;Sq1 Ds2
        Header G2, Lead_12to25_s6_v12, 
                ;Range F2-G2
        If_Alt "Toggle"

        _1:
                    ;Notes hlf,D3, dqt,D3, 8th,D3, 
                Riff CM_Tri::_23, CM_Tri::_23_5

                If_Alt B2, As2
                Notes qtr,B2

                Notes hlf,D3, qtr,D3

                _2:
                If_Alt E3, Ds3
                Notes qtr,E3

                .byte Volume_Slow_Fade  ;How to reset this properly...
                Notes 14*_8th,D3
                
                ;3
                Riff _1, _2

            _4:
            If_Alt G3, Ds3
            Notes qtr,G3, 
            
            .byte Volume_Slow_Fade
            If_Alt G2, Ds3
            Notes 10*_8th,G2, 

            _4_6:
            Notes qtr,G2, qtr,A2,  ;Duration _22_431_5 

            _5:
            Notes hlf,B2, dqt,B2, 8th,B2
            _5_5:
            Duration _8x1, A2,rest, A2,rest, D3,rest, C3,rest
            _6:


            ;6
            Notes hlf,B2, dqt,B2, 8th,D3
            Notes hlf,G3, 
            
            _6_7:
            Notes qtr,E3, qtr,D3,  ;Duration _22_431_5 
            
            ;7
            Notes hlf,Cs3, dqt,Cs3, 8th,Cs3
            _7_5:
            Duration _8x1, Cs3,rest,Cs3,rest,D3,rest,E3,rest

            ;8
            Notes whl,D3, whl,rest, 
            


            ;9
            Riff _1, _6 -2
            Duration "Cont", B2,rest, A2,rest

            ;14
            Notes hlf,G2, dqt,G2, 8th,C3, 
            Notes hlf,E3,  ;qtr,D3, qtr,C3, 
            

            Shift_Pitch Fs2, E2

            ;15
            Riff _6_7, _7_5 +1 ;Duration _8x1
            Duration "Cont", C3,rest, A2,rest, G2,rest, Fs2,rest

            ;16
            Notes whl,G2, whl,rest, 
        ;
            
        _17:
            Riff CM_Tri::_17_BP, CM_Tri::_33, "3b"
            BP .set BP+6 ;Internal -> As2
            
        ;33

    Inc_Page CM_Sq0_Cont, "Scoped"

        
    Channel Choco_Mountain_Sq1, CM_Sq1
        Header E2, Choir_v12_1f
                ;Range D2, E2 to Match Sq0

        _1:

            Riff CM_Sq0::_1, CM_Sq0::_4_6

                Notes qtr,rest

                Env_Change Pad_d12_6_0

                Notes hlf,C3, 
                
                _5:
                    Duration _4444, D3,D3, D3,D3
                    
                _6:
                Notes hlf,F3, hlf,F3, 

                ;6.5
                Notes hlf,E3, hlf,E3,
            _7:
            Repeat "2b", 2

            
    
            _8:
                Notes hlf,Fs3, qtr,Fs3, whl,Fs3
            _9:



            
            Env_Change Choir_v12_1f
            Riff _1, _7
                ;Internal Env_Change Pad_d12_6_0

            Riff _5, _6


            Shift_Pitch E2, F2
            Riff _8, _9
        ;17
    Inc_Page CM_Sq1_Cont, "Scoped"

py_Segment_End Choco_Mountain_Tri

.align 256

    ;Is a PageFit + Must follow the page of next operand.
py_Segment CM_Sq0_Cont, PageFollow, Choco_Mountain_Tri

    _8th .set 6
    Channel CM_Sq0_Cont, CM_Sq0_Cont
        Header CM_Sq0::CM_Sq0_Cont_BP, Choir_v12_1f, "Cont"

        ; _33_Env:
        Shift_Pitch As2, F2

        _33:
                .byte Volume_Slow_Fade
                Notes 16*_8th,B2

            _34:
            Notes 8th,C3, 
            
            _34_2:
                Notes 8th,rest, 
                
                .byte Volume_Slow_Fade
                Notes 14*_8th,B2

            _35:
            Riff _33, _34  ;B2, Fade

            ;36
            If_Alt -2
            Notes 8th, As2

            Riff _34_2, _35

        _37:
        Riff _33, _37

        Env_Change Choir_v12_1f

        _41:    
            Notes hlf,B2, hlf,B2, hlf,B2, 
            _41_6:

            Notes qtr,B2, qtr,As2, 

            ;42
            Notes qtr,A2 

            If_Alt G2, Fs2
                Notes qtr,G2, 

            Notes qtr,rest, 

            If_Alt G2, Fs2
                Notes whl,G2, 
            
            _42_8:
                Shift_Pitch +1
                Notes 4,Gs2, 
            Repeat "3b", 2
            BP .set BP+2 ;E2 -> G2  /Fs2 -> A2

            ;43
            Notes hlf,B2, hlf,B2, hlf,B2,  ;Riff _41, _41_6 ;B2's  (BP changed)
            Notes qtr,As2, qtr,B2, 

            If_Alt D3, Ds3
            Notes qtr,D3, 
            
            If_Alt D3, Ds3
            Notes hlf,D3

            If_Alt D3, Ds3
            Notes 10*_8th,D3
            
            ;45
            If_Alt C3,B2
                Notes dhf,C3, 

            If_Alt C3,B2
                Notes qtr,C3, 


            Notes dhf,E3, 
            Duration _2222, E3,E3, Ds3,E3

            If_Alt G3, Gs3
            Notes 10*_8th,G3


            ;47
            Notes hlf,B2, hlf,B2, 
            _47_5:
            If_Alt D3, Ds3
            Notes qtr,D3
            Repeat "2b", 1

            Notes qtr,rest, 
            _48:
            Notes qtr,B2, 

            Riff _47_5, _48
            Notes dhf,B2,hlf,rest,  



            If_Alt 0, -4
            Shift_Pitch 0

        _49:
                Notes hlf,D3, qtr,rest
                Repeat "2b", 1

                Notes qtr,D3, qtr,Cs3, 
                
                _50:
                    Notes hlf,C3, qtr,rest, 
                    Notes dhf,C3, hlf,rest, 

                _51:

            If_Alt A2, As2
            Notes hlf,A2, qtr,rest
            Repeat "3b", 1

            If_Alt A2, As2
            Notes qtr,A2, qtr,B2

                ;52
                    Riff _50, _51

            ;53
            Riff _49, _51


            

            If_Alt A2, As2
            Notes qtr,A2, qtr,rest
            Repeat "3b", 1

            Shift_Pitch -Octave ;A2 - A1 / Cs2 - Cs1 
            _55:
            
            Duration _8x2, Fs2,rest, D2,rest, A1,D2, D2,Fs2
            Notes hlf,A2, hlf,rest
        ;

    Loop CM_Sq0_Cont


    Channel CM_Sq1_Cont
        Header CM_Sq1::CM_Sq1_Cont_BP, Choir_v12_1f, "Cont"  ;BP, Env_Bank, "Type"
        _17:
                Duration _8x1, G2,G3,C3,E3,G3,G2,E3,C3
                Duration _8x1, G3,E3,C3,G3,C3,E3,G2,C3

                _18:
                Duration _8x1, G3,D3,B2,G3,D3,B2,G3,B2
                Duration _8x1, D3,G2,B2,G3,D3,G2,D3,B2

                _19:
                Duration _8x1, Fs2,Fs3,A2,D3,A2,Fs3,D3,A2
                Duration _8x1, Fs3,Fs2,A2,Fs2,A2,D3,Fs3,A2

                _20:
                Riff _18, _19

                ; 
                ; Duration _8x1, G2,G3,B2,D3,G3,G2,D3,B2
                ; Riff _20, * ;External Repeat

            _21:
            Riff _17, _21, "3b" ;By ONE byte
            Repeat _21, 1

            Riff _17, _20

            ;32
            Shift_Pitch F2, G2
            Duration _8x1, A3,Fs3,D3,A3,A2,D3,A3,D3
            Notes whl,A3, 
            
        ;33
        
        
        Env_Change Choir_v12_1f

        ;Plan is for most of below to If_Alt Sq0

        Shift_Pitch G2, D2 ;C2
        Riff CM_Sq0_Cont::_33, CM_Sq0_Cont::_55, "3b"
        BP .set Cs1

        ;55
        ;Shift_Pitch B1,Fs1
        Duration _8x2, A1,rest, A1,rest, Fs1,Fs1, A1,D2
        Notes hlf,D2, hlf,rest

    Loop CM_Sq1_Cont

py_Segment_End CM_Sq0_Cont

;DMC and Noise w/ Yoshi_Valley




