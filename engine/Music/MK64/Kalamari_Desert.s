_8th .set 7+7
;_16th .set 7
.align 256
 
    ;Time Stamps are written in 16-8 time

py_Segment Kalamari_Desert_Sq0, PageFit

    _8th .set 7+7
    Channel Kalamari_Desert_Sq0, Kal_Sq0
        Header C3, Lead_12to25_s6_v12_6f ;t25

        If_Alt "Toggle" 

        _1:
            Notes 16*_8th,rest ;2x whl

            _5: ;1-3-4
                Notes qtr,G3, qtr,G3,

                    If_Alt A3, Gs3
                    Notes 8th,A3
                    If_Alt A3, Gs3 
                Notes qtr,A3

                _7:
                Notes qtr,As3, 8th,As3, qtr,As3

                    If_Alt A3, Gs3
                    Notes 8th,A3
                    If_Alt A3, Gs3
                Notes dqt,A3 ;qtr vs dqt

            _9:
            Riff _5, _9

            _13:
            Notes 8th,G3
            Notes 15*_8th,G3 
            
            _17:
            Notes 8th,F3
            Notes 15*_8th,G3



            _21: ;1-2-4 
                If_Alt A3, Gs3
                    Notes qtr,A3,
                Repeat "2b", 1

                Notes 8th,As3, qtr,As3
                ;23
                Notes qtr,C4,  8th,C4, qtr,C4

                Notes 8th,As3, dqt,As3 

            _25:
            Riff _21, _25
            _29:


            If_Alt C4, As3
            Notes 8th,C4
            If_Alt C4, As3
            Notes 15*_8th,C4 

            Riff _13, _17 ;G3
            
        _37_Sq1_Exit:



        Env_Change Lead_d12_s7_v8_1f 
        _37:
                    Notes dhf,G3, ;qtr,A3
                    ; Notes 3*_8th/2,A3, 
                    
                    ; Slide:
                    ; Notes 3,A3, 4,Gs3
                    Notes 3*_8th/2 +3,A3, 
                    
                    
                    Notes 4,Gs3

                _39:
                Notes whl,G3,

                Notes 11*_8th/2,G3, 
                    Slide:
                    Notes 3,Fs3, 4,F3  
                    _42_7:
                Notes qtr,E3

                ;43
                Notes whl,F3

            _45:
            Shift_Pitch A3,G3
            Riff _37, _39

    
            ;47
            Notes dhf,F3, qtr,E3
            Notes dhf,E3, qtr,C3

            ;51
            Notes dqt,E3

            Notes _8th/2,Fs3, ;3,F3, 4,E3
                Shift_Pitch G3,Gs3
                Riff Slide, _42_7

            Notes hlf,Ds3


            ;53
            Shift_Pitch Gs3, A3 ;Reset
            Riff _37, _45

            ;61
            Notes dqt,F3, hlf,A3, 7*_8th,C4

            ;64
            Notes qtr,As3, dhf,A3, qtr,F3

            ;67
            Notes hlf,E3, hlf,D3

        ;

        _69:
        Notes 16*_8th,C3

    Loop Kalamari_Desert_Sq0
    Kal_Sq0_Loop:


    Channel Kalamari_Desert_Sq1
        Header A2, Lead_12to25_s6_v12_6f

        Riff Kal_Sq0::_1, Kal_Sq0::_37_Sq1_Exit, "3b"


        Env_Change Choir_v12_1f
        Shift_Pitch -5

        _37:
            Duration _6x8, D3,Cs3,C3,B2,As2,As2
            _49:
            Notes whl,A2, whl,A2


            Riff _37, _49
            ;65
            Notes whl,C3, hlf,F2, hlf,G2
            

            _69:
            Riff Kal_Sq0::_69, Kal_Sq0_Loop

        ;

    Loop Kalamari_Desert_Sq1, "Riffed"


    Channel Kalamari_Desert_Tri
        Header {C4,+Octave}, T_1f_12v__d25 

        _1:
            Notes 16*_8th,rest ;whl x2

            _5:
                Repeat _1, 2 ;whl x4

                _13:
                    Notes whl,rest
                    Duration _0000, G4,C5,G4,C5 ;0 = 16ths
                _14_3:
                Notes dhf,G4, 
                
                ;15
                Riff _13, _14_3
                Notes dhf, C5

            _21:
            
            ;31
            Riff _5, _21
        ;

        ;37
        Shift_Pitch -Octave
        Riff Kal_Sq0::_37, Kal_Sq0_Loop, "3b"

    Loop Kalamari_Desert_Tri, "Riffed"

py_Segment_End Kalamari_Desert_Sq0


py_Segment Kalamari_Desert_dmc, PageFit

    _8th .set 7+7
    Channel Kalamari_Desert_dmc
        Header C2, T_0f__d25

        _1:
        Duration _8x0, C2,C2, E2,C2, F2,Fs2,G2,C3
        _2:

        Riff _1, _2
        Repeat "2b", 18 ;Repeat "5b", 19 ;5-byte range is 1..7

            ;21
            Shift_Pitch C2, F2  ;Riffable $b5s, except can't split the repeats.
            _x8:
            Riff _1, _2
            Repeat "2b", 7

        ;29
        Shift_Pitch F2, C2
        Riff _x8, 3




        Shift_Pitch C2, As1
        _37:
                Riff _x2, 3

            _BF_x2:
            Shift_Pitch As1, A1 ;Riff, $bf
            Riff _x2, 3

                    _41:

                    _B5_x2:
                    Shift_Pitch A1, D2
                    _x2:
                    Riff _1, _2
                    Repeat "2b", 1


            Shift_Pitch D2, G1
            _x4:
            Riff _1, _2
            Repeat "2b", 3

                ;47
                Riff _B5_x2, 4   ;G-C
                        Riff _B5_x2, 4 ;C-F                                                                                                                                                                                                                                                                                                                                                 
                        ;Has Internal Repeat
        _51:
        BP .set F2

                Shift_Pitch F2, B1

                Riff _BF_x2, _41
            ;     Riff _x2, 3

            ; ;53
            ; Shift_Pitch B1, As1 ;Riff, $bf
        Riff _37, _51
        BP .set F2

                    Shift_Pitch F2, D2

                    Riff _1, _2
                Shift_Pitch D2, Cs2
            Repeat "3b", 1

        BP .set C2
        Riff _x4, 3

    Loop Kalamari_Desert_dmc

py_Segment_End Kalamari_Desert_dmc

.align 256

py_Segment Kalamari_Desert_Noise, PageFit

    _8th .set 7+7
    Channel Kalamari_Desert_Noise, Kal_Noise
        Noise_Header ::Kalamari_Desert_NB, d12_Tom ;d12_Tom


        _1:
                Duration _8x0,   Train_Hi,rest,  Hat_4,    Train_Lo ;Costs 5b to swap Hat_4 -> Shaker_2
                Duration "Cont", Train_Hi,rest,  Train_Hi, Hat_4

            _2:
            Riff _1, _2
            Repeat "2b", 34  ;Repeat "5b", 35

        ;

        _19:
                    Duration _8x0,   Train_Hi,rest,  Shaker_3, Train_Lo ;5 + 5+3   ;vs  8 + 1+2+2
                    Duration "Cont", Train_Hi,rest,  Train_Hi, Shaker_3 
                
                    Duration _0000,  Train_Hi,rest,  Shaker_3, Train_Lo
                    _19_7:
                Riff _35_3, _35_5 ;32nds

                _20:
                    Riff _19, _19_7

                Duration _0000, Train_Hi,Shaker_3,  Train_Hi,Shaker_3

            _21: ;15\23b

            Riff _19, _21
            Repeat "2b", 5

            ;33
            Riff _20, _21 ;Backwards
            Riff _19, _20 

        ;

        _35:
            Notes 3,Train_Hi, 4,Shaker_2

                _35_1: ;KTB In
                        Notes 3,Shaker_2, 4,Shaker_2 
                    _35_2:
                    Riff _35_1, _35_2 ;External Repeat

                _35_KTB: ;Out

            _35_3_KTB: ;Seperate In
            Notes 3,Train_Lo, 4,Shaker_2
            _35_3_5_KTB:

            _35_3: ;<- Reused as a 2x Call
                Riff _35, _35_2 ;External Repeat
                Riff _35, _35_2

            _35_5: ;18/49b

            Riff _35, _35_5 ;Could nest two riffs for Internal Repeats
            Repeat "2b", 2 ;52b, excluding headers. A 10x Increase in size from V1

        ;g

    Loop Kalamari_Desert_Noise


    _8th .set 8+7
    Channel Koopa_Beach_Noise
        Noise_Header ::Koopa_Beach_NB, As3_Tom

        _1:
            Duration _8x0, Rasp_2,Rasp_2,rest,Rasp_2, rest,Rasp_2,rest,Rasp_2

            Duration _0000, rest, Rasp_c, Rasp_c, Rasp_F4
            Notes 8th,Shaker_F4,  8th,Shaker_Bb3 

        ;End Intro
 
        _3:
            Duration _8x0,   Shaker_Bb3, Rasp_c, Rasp_F4,   Shaker_F4
            Duration "Cont", Rasp_2,    Rasp_c, Shaker_Bb3, Rasp_2

            _4:
            Notes 8th, Shaker_Bb3
            Duration _0000, Rasp_F4, Shaker_F4, Shaker_2, Rasp_c

            _4_6: ;32nds
            ;Riff Kal_Noise::_35_3_KTB, Kal_Noise::_35_3_5_KTB
            Notes 4,Rasp_c_Bb3, 4,Shaker_2 ;4,Rasp_c_Bb3, 4,Shaker_2  ;Only Difference from KD is a Different Kick. (And change 4-4-3-4 to 3-4-4-4)
            Notes 3,Rasp_2, 4,Shaker_2 

        _5:
        Riff _3, _5
        Repeat "2b", 17

    
        ;41
            Riff _3, _4

            ;42
            Duration _00, Shaker_Bb3, Rasp_c

            Notes 4,Rasp_F4, 4,Shaker_2 ;32nds
            Repeat "4b", 1

            Riff Kal_Noise::_35_1, Kal_Noise::_35_KTB                
                ;4,Shaker_2  3,Shaker_2   x2

            Riff _4_6, _5 ;32nds
        ;

        ;43
        Riff _3, _5
        Repeat "2b", 7


    Loop Koopa_Beach_Noise, _3

py_Segment_End Kalamari_Desert_Noise



