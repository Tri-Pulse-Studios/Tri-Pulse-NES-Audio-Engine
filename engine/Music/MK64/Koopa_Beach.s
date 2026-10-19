
.align 256

py_Segment Koopa_Beach_dmc, PageFit
    _8th .set 8+7

    Channel Koopa_Beach_dmc
        Header B1, T_0f__d25

        ;1
            Duration _8x0, B1,B1,rest,B1,rest,B2,rest,B1
            Notes hlf,rest

        ;End Intro

        _3:
            Riff _5, _7_no_BP
            Shift_Pitch B1, Cs2

            _5:
                Notes qtr,Fs2, qtr,Cs3

                ;6
                Notes 8th,Fs2
                Duration _00, rest,Fs2
                _6_5:
                Notes 8th,Cs3, 8th,Cs2
            _7_no_BP:
            Shift_Pitch Cs2, B1

            _7:
            Riff _3, _7
            Repeat "2b", 7

            Riff _3, _6_5
                BP .set BP+2 
            Notes 8th,F2, 8th,E2
        ;

        ;43
            Shift_Pitch Cs2, A1
            Riff _3, _7
            Repeat "2b", 2

            _55:
                Notes 8th,A2,8th,rest, 
                Notes hlf,A1
                Notes 8th,A2,8th,rest
            Repeat _55, 1
        ;

    Loop Koopa_Beach_dmc, _3

py_Segment_End Koopa_Beach_dmc



py_Segment Koopa_Beach_Tri, PageLead, KTB_Sq0_Cont
    _8th .set 8+7

    Channel Koopa_Beach_Tri, KTB_Tri ;Change 2f
        Header B3, T_1f_12v__d25

        _1:
                Duration _8x0,   Ds4,Ds4,rest,Ds4,
            _1_5:
            Duration "Cont", rest,E4,rest,Ds4
            Notes hlf, rest

        ;End Intro

        _3_BP:
        Env_Change Lead_sqr_13_0


        _3:
            ;_3 to _5 Re-reads _5 to _7
                ;Just If-Alt'ed (And to support Sq0)

                            ;This MOUNTAIN of commands takes 50 scanlines to update.   
                                ;Fine for the demo, but its too much for real game.
                                    ;Est savings 15-20 Bytes  (Sq0 is essentially free)

                        If_Alt "Toggle"
                                If_Alt +1
                                Shift_Pitch -2 ;B3 -> A3
                            Riff _5, _7

                                If_Alt -1 ;Sq0 Only Gs2-A2
                                Shift_Pitch +2 ;A3 -> B3
                        _5_Toggle:
                        If_Alt "Toggle"

                    _5:
                    Notes 8+_8th,Cs4, 
                    
                    If_Alt -1
                    Notes 7+_8th,E4+1, 8th,Gs4
                    Duration _0000, rest,Cs4,rest,Cs4

                _6_5:
                If_Alt -1
                Notes 8th,E4+1, 8th,Gs4

                _7:



                Riff _3, _6_5
            _9_5:
            Duration _00, Gs4, E4 ;No If_Alt Needed (Sq0 Would leave at _9_5)
            Notes 8th,Cs4

        ;

        _11:
        Riff _3, _11
        Repeat "2b", 3
        

        Shift_Pitch B3, A3
        Riff _3, _11
        Riff _3, _7
        Riff _5, _7
        Repeat "2b", 1

    Loop Koopa_Beach_Tri, _3_BP

    Channel Koopa_Beach_Sq0, KTB_Sq0_w_Tri
        Header {G2,+Octave}, Lead_sqr_13_0

            ;+OCtave is for Pad's Vibrato

            ;1
                    Riff KTB_Tri::_1, KTB_Tri::_1_5
                Duration "Cont", rest,B2,rest,B2
                Notes hlf,rest
                
            ;End Intro

            _3:
                If_Alt "Toggle"
                Riff KTB_Tri::_3, KTB_Tri::_9_5 +1
                Duration "Cont", E3, Cs3 ;_00
                Notes 8th,A2

            ;

            ;11

    Inc_Page KTB_Sq0_Cont, "Scoped"

py_Segment_End Koopa_Beach_Tri



.align 256 
py_Segment KTB_Sq0_Cont, PageFollow, Koopa_Beach_Tri
    _8th .set 8+7

    Channel KTB_Sq0_Cont, KTB_Sq0
        Header KTB_Sq0_w_Tri::KTB_Sq0_Cont_BP, Lead_sqr_13_0, "Cont"

        Shift_Pitch G2, D3
            ;Set BP D3

        _11:
                Duration _8x0, rest,E4,Gs3,E4,Ds4,Fs3,Ds4,Fs3
                Duration _8x0, Cs4,Cs4,E3,B3,Ds3,B3,Ds3,B3
                Shift_Pitch D3, B2
                Duration _8x0, A3,Cs3,A3,Cs3,Gs3,B2,Gs3,A3
                Duration _8x0, Cs3,A3,Cs3,A3,B3,Ds3,B3,Ds3

            _15:
            Duration _0000, Cs4,B3,Cs4,B3

            _15_5:
            Vol_Fade_Out Vol_82, Vol_12, 30 ;qtr

            Notes 5,Ds3, 5,B3 ;1/12th notes
            Repeat "4b", 20

            .byte Clear_Special_Fade


            _19:
                Duration _8x0, rest,Gs3,B2,Gs3,B3,Ds3,B3,Ds3,
                Duration _8x0, Gs3,B2,Gs3,B2,B3,D3,As3,A3,

                Duration _0000, Cs3,A3,Cs3,Cs4
                Shift_Pitch B2, E3
                Duration _0000, E3,Cs4,E3,Fs4,

                Duration _8x0, Fs3,Fs4,Fs3,E4,Gs3,Ds4,Cs4,Fs3

            _23:
            Duration _0000, B3,Fs3,Ds4,B3
            Shift_Pitch E3, B2
            Riff _15_5, _19



            _27:
            Shift_Pitch B2, D3
            Riff _11, _19 +3, "3b"
            BP .set B2 ; Reset Internally

            _35:
                ;Duration _8x0,rest,Gs3,B2,Gs3,  ;<-  +3 is ;Riff _19, 3   
                Duration "Cont", A3,Cs3,A3,Ds3,
                Duration _8x0, B3,B3,B2,Gs3,B2,Gs3,Gs3,B2
                Duration _8x0, A3,Cs3,A3,E3,Cs4,Fs3,Cs4,Fs3,
                Shift_Pitch B2, E3
                Duration _8x0, Fs4,Gs3,Fs4,E4,Fs3,Ds4,Cs4,Fs3

            ;39
            Duration _0000, E4,A3,Fs4,E4

            Riff _15_5, _19 ;Shift  B3, E4
            
        ;



        .if .const(Lead_sqr_13_0)
            .fatal "Success. Env Names are now Constant"
        .endif

        .assert (Lead_sqr_13_0 & $f) = $08, warning, "Invalid Manual Env_Change" ;c
        .assert (Pad_d12_s3_v8 & $f) = $05, warning, "Invalid Manual Env_Change" ;2
            ;env names not being constant is annoying.

        BP .set E3
        Env_Change Pad_d12_s3_v8


        _43:
            Notes qtr, A3
            Duration _0_00_0_Es, \
            $e8, D4, \
            $e5, A3, A3, \
            $e8, D4, \
            $e5
            Notes hlf,A3



            _45: 
            Notes qtr, B3
            Duration _0_00_0_Es,  \
            $e8, B3, \
            $e5, B3,B3,  \
            $e8, A3, \
            $e5

            _45_8 = *-1 ;Except the A3

            Notes dqt,D4, 8th,Cs4


            ;47  ;Swappable
            Notes qtr, A3
            Duration _0_00_0_Es,  \
            $e8, B3, \
            $e5, A3, A3,  \
            $e8, A3, \
            $e5

            Notes hlf,A3


            _49:
            Riff _45, _45_8
            Duration "Cont",\
            Cs4, \
            $e5

            Notes hlf,B3

            _51:

                Notes qtr,Cs4

                Duration _00_0_0_4_Es,\
                $e8, Fs3,Fs3,\
                $e5, Cs4,\
                $e8, $b0, Fs3, \
                $e5,Cs4



            ;53
            Notes qtr, E4
            Duration _0_00_0_Es, \
            $e8, B3, \
            $e5, E4, E4,  \
            $e8, B3, \
            $e5

            Notes hlf,E4


            ;55
                Notes qtr,D4
                Duration _00_0_0_4_Es,\
                $e8, B3,B3,\
                $e5, D4,\
                $e8,$b0, B3, \
                $e5,D4




            Shift_Pitch B3, Cs4
            _57:
            Riff _45, _45_8
            Duration "Cont",\
            Cs4, \
            $e5

            Notes hlf,Cs4

            _59:
        ;



    Loop KTB_Sq0_Cont, KTB_Sq0_w_Tri::_3


    Channel Koopa_Beach_Sq1
        Header {A2,+Octave}, Pad_d12_s3_v8

        ;For an Env Change and BP shift, This can Riff Sq0's for an Octave like Raceway

        ;1
            Notes 8*_8th,rest ;2-byte whl,rest
            Repeat "2b", 4
        ;End Intro

        _11:
            Notes whl,Gs3, whl,A3, 
            
            ;15
            Notes whl,Gs3

            Notes dqt,A3, 
            Duration _00, Gs3,G3, 
            Notes hlf,Fs3

            _19:
                Notes whl,Gs3

                Notes hlf,A3, dqt,B3, 
                Duration _00, As3,A3

                ;23
                Notes whl,Gs3
                
                Notes hlf,A3, dqt,Fs3,  ;+5 Bytes
                Duration _00, G3,Gs3


            _27:
            Notes whl,Gs3, whl,A3,

            ;31
            Repeat "2b", 1

            _35:
                Riff _19, _27

        ;

        ;43
            Notes qtr, A2
            Duration _0_00_0_Es, \
            $e8, A3, \
            $e5, A2, A2, \
            $e8, A3, \
            $e5

            Notes hlf,A2


            ;45
            Shift_Pitch A2, C3
            Riff KTB_Sq0::_45, KTB_Sq0::_45_8
            Duration "Cont", Fs3, $e5

            Notes hlf,G3


            ;_47
            Notes qtr, Fs3 ;Fs3 vs F3
            Duration _0_00_0_Es,  \
            $e8, G3, \ 
            $e5, Fs3, Fs3,  \  
            $e8, Fs3, \
            $e5

            Notes hlf,Fs3


            ;49
            Riff KTB_Sq0::_49, KTB_Sq0::_51  
            


            _51:
                Notes qtr,A3

                Duration _00_0_0_4_Es, \
                $e8, A3,A3,\  
                $e5, A3,\
                $e8, $b0, A3, \
                $e5,A3


            _53:

            Riff KTB_Sq0::_57, KTB_Sq0::_59


            ;55
            Shift_Pitch C3, A2
            ; Set_Pitch A2
            Riff _51, _53


            ;57
            Shift_Pitch A2, B2
            Riff KTB_Sq0::_43, KTB_Sq0::_45

        ;


        Env_Change Pad_sqr_s4

        Volume_Set Vol_50
            ;[WARN] The F-Effect Flag is NOT cleared by Loop Channel.
                    ;Which... Why?? It REEEALLY Should be channel specific.


        Set_Pitch B4, 3  ;To ++Octave  ;Shift +Octave only gets to B3, 2
        BP .set B4

        _59:
            Notes qtr,rest
            Duration _00, B4,rest,
            Notes 7,B4
            Notes dhf,B5 

            Duration _00, rest,Gs5
            Notes   _8th,Gs5 ;Saves one byte, costs a mid-note ATK reset.

        _61_8:
        Notes     8  +  4*_8th,Fs5

        _63:
        Riff _59, _61_8

        Notes 4,B5, 4,Gs5, hlf,Fs5

    Loop Koopa_Beach_Sq1, _11

py_Segment_End KTB_Sq0_Cont



;KTB's Noise is w/  KD's


