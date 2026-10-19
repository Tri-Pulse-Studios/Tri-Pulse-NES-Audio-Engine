_8th .set 7
 
 py_Segment Yoshi_Valley_Sq1, PageFit

    _8th .set 7
    Channel Yoshi_Valley_Sq1
        Header {C3, -Octave}, Lead_12to25_s6_v12,  
        BP .set C3 ;-Octave for Whistle

        ;1
            Notes qtr,G3, 8th,rest, 8th,G3, 
        
                Env_Change Lead_25to12_v6
                Notes 8th,D4, dqt,D4
                
            _1_3_env:
            Env_Change Lead_12to25_s6_v12
            Notes qtr,D3, 8th,rest, 8th,D3

            _1_5:
                Env_Change Lead_25to12_v6
                Notes 8th,C4, dqt,C4
            
            ;2
            Riff _1_3_env, _1_5 ;D3s
            Notes qtr,E3, qtr,E3, qtr,F3, 

                Env_Change Lead_25to12_v6
                Notes hlf,D4, qtr,rest, 


        End_Intro: ;$17 Bytes 


        _3_env: ;$26 Bytes
            Env_Change Pad_d12_6_0 
                _3:
                    Notes qtr,rest

                    _3_3:
                            ;Technically Should have a C4,G3,E3 Lead In
                                ;Costs 5B tho
                    Duration _111_R, C4,E3,G3, Repeat_x4
                        ;15 8ths + qtr = 17
                            ;+ another 15 = 32 

                _4:
                Riff _3_3, _4 

                ;5
                Riff _3, _4
                Duration _111_R, Cs4,D4,G3, Repeat_x4
        
                ;7
                Riff _3, _4
                Duration  _111_R, C4,A3,Gs3, Repeat_x4 ;Can't Riff Call out the Duration (The Repeat needs it)

                ;9
                Duration _111_R, F3,G3,C4, Repeat_x4

            _10:
            Notes 8th,G3, qtr,F3

            Duration _111_R, D4,B3,G3, Repeat_x1

            _10_6:
            Notes qtr,D4 ;Should this be inside?

                Env_Change Lead_25to12_v6
                Notes 8th,D4, 8th,rest, 
            _10_7:
                Notes hlf,C4


            ;11
            Riff _3_env, _10

            Notes 8th,G3 

            Duration _111_R, E3,G3,C4, Repeat_x1

            Notes 8th,G3,8th,E3,  whl,C4

        ;


        _19: ;$1c Bytes
            ;_1111 based has the exact same size, with a LOT more CC-Hungry Riff Calls

                ;There is lots of  $PP, $PP, $PP  overlap, but it never syncs with the start of two seperate Durations
            _A:
                
                Riff _a, 3  
                Duration "Cont", C4,A3,F3,C4 ;b

                _a:
                _ac:
                Duration _8x1,   F3,A3,C4,A3 ;a  ;a6,ad
                Duration "Cont", F3,C4,F3,A3 ;c

            _B:
                _cb:
                Duration _8x1,   F3,C4,F3,A3 ;c
                Duration "Cont", C4,A3,F3,C4 ;b

                Riff _ac, 5  

            _C:
                Duration _8x1,   C4,A3,F3,C4 ;b
                Duration "Cont", F3,A3,C4,A3 ;a

                Riff _cb, 5
            
            Riff _B, *

            Riff _A, _C
            Riff _B, _C

        ;


        ;27  ;$18 Bytes
            Notes 8th,rest 

            _27:
                Notes 8th,rest 
                Duration _111_R, D4,As3,F3, Repeat_x1
                _27_5:
                    Duration _111_R, C4,A3,F3, Repeat_x2

                    _28:
                    Notes 8th,G3

                    Duration _111_R, As3,G3,C3, Repeat_x1
                    Duration _111_R, A3,F3,C3, Repeat_x2

                _29:
                Notes 8th,F3
                Duration _111_R, As3,F3,D3, Repeat_x1

                _29_5:
                Riff _27_5, _28
            _30:
            Riff _28, _29

            ;31
            Riff _27, _30 

        ;


        _34: ;$10 Bytes
            ;8th,D4 Ommited to save 5 Bytes. (Replaced w/ F3)
            Notes qtr,D4  

                ;qtr,D4

                ; Env_Change Lead_25to12_v6
                ; Notes 8th,D4, 8th,rest, 

                Riff _10_6, _10_7  ;Wistle

            _34_5:
            Notes dhf,C4,  dqt,rest, ;vs hlf,C4

            ;35
            Env_Change Pad_d12_6_0
            Notes 8th,D4 
            Riff _34, _34_5
            Notes 8th,D4

            Env_Change Pad_d12_6_0
            Notes 8th,B3, qtr,B3, qtr,B3, dqt,rest

        ;

    Loop Yoshi_Valley_Sq1, End_Intro

py_Segment_End Yoshi_Valley_Sq1



.align 256
py_Segment Yoshi_Valley_Sq0, PageFit

    _8th .set 7
    Channel Yoshi_Valley_Sq0, YV_Sq0  ;[NOTE] A Specialized Lead_13_0 for tri w/ 2f cutoff would save like 10 bytes.
        Header As2, Lead_sqr_13_0,  
    
        Notes dqt,D3, 5*_8th,D3 
        Notes dqt,B2, 5*_8th,B2

        ;1
        Notes 8th,B2, qtr,B2, 8th,B2
        Notes qtr,C3, qtr,Cs3, whl,D3  ;I save more bytes leaning on Lead sqr's auto stop,  then trying to force Tri to re-use bits and pieces.


        End_Intro:
        Env_Change Lead_12to25_s6_v12
    
        If_Alt "Toggle" ;Disable. Tri leaves it Enabled.

        _3:
            ;
                If_Alt Ds3, Gs3
                Notes 8th,Ds3, 

                If_Alt E3, A3
                Notes 8th,E3, 

                Notes 8th,C4

                If_Alt D3, G3
                Notes 8th,D3,  

                ;5.3
                If_Alt Ds3, A3
                Notes 8th,Ds3

                If_Alt G3, A3
                Notes qtr,G3


                Notes 8th,C3
                Duration _1111, rest,C3,D3,C3
                
                _3_7:
                If_Alt Ds3, F3
                Notes 8th,Ds3

                Notes 8th,rest 

            _3_8:

            If_Alt E3, F3
            Notes 14*_8th,E3, 

            Notes hlf,rest

            _5:
                Riff _3, _3_8

            If_Alt E3, F3
            Notes 8th, E3
            
            If_Alt D3, C3
            Notes 13*_8th,D3
                
            Notes hlf,rest


            _7:
            Riff _3, _3_7
            Notes 8th,D3, qtr,C3, 

            

            _8:
            Notes 8th,rest, 
            
            If_Alt F3, D3
            Notes 8th,F3
            Repeat "3b", 2

            If_Alt D3, As2
            Notes 8th,D3,  8th,rest

            If_Alt C3, As2
            Notes whl,C3,  8th,rest
            

            _9:
            Duration _111_R, Ds3,E3,G3, Repeat_x2

            ; If_Alt Ds3, E3  ;I cannot hear weather one is more accurate or not.
            ; Notes 8th,Ds3, 
            
            ; If_Alt E3, F3
            ; Notes 8th,E3, 
            
            ; Notes 8th,G3
            ; Repeat _9, 2

            Duration _1111, rest,G3,rest,G3
        _9_7:

        If_Alt A3, G3
        Notes 8th,A3, 

        Notes 8th,rest, 9*_8th,G3, whl,rest


        _11:
        Riff _3, _9_7 -1, "3b"
        Duration "Cont", Fs3,F3

        Shift_Pitch As2, Ds2 ;Second Ending is a 5th Lower, but Identical
        Riff _9_7, _11
        


        ;19 
        If_Alt 0, 2, 'F'
        Shift_Pitch 0  ;Tri Shifts Higher

        Shift_Pitch +Octave  ;Sq0 at Ds3


        If_Alt Lead_sqr_13_0, T_1f_12v__d25 ;No notes long enough for vibrato
        Env_Change Lead_sqr_13_0

    


        _19:
            If_Alt 0, -1, 'F'
            Shift_Pitch 0

                If_Alt F3, E3
                Notes qtr,F3,
                Repeat "2b", 1

                Notes qtr,A3, qtr,E4, ;Costs 5b to give each of these an If_Alt
                Notes 8th,D4, qtr,D4, 8th,D4,  
                
            If_Alt 0, 1, 'F'
            Shift_Pitch 0 ;Costs 4b to double shift.


            _19_7:
            Duration _2222, C4,C4,As3,As3

            If_Alt A3, Gs3
            Notes 8th,A3,
            Notes qtr,As3, 

            _20_5:
            Notes qtr,C4, 7*_8th,rest 

        _21:
        Riff _19, _21



        _23:
                Notes 8th,B3, qtr,C4
                
                If_Alt A3, Gs3
                Notes qtr,A3,
            _23_3:

            Repeat _23, 1 
            Notes dhf,rest

            ;24
            Riff _23, _23_3
            Notes 8th,B3, qtr,C4,

            _24_5:
            Duration _2222, rest,C4,C4,rest

            ;25
            Riff _23, _24_5 
            Notes whl,rest


        Shift_Pitch Ds3, Gs3


        _27:
            Notes 8th,rest, qtr,F4, 8th,F4,  
            _27_3:

            If_Alt D4, Cs4 ;DD-EE-CC
            Notes qtr,D4, 
            Repeat "2b", 1

            _27_5:

            If_Alt E4, Ds4
            Notes qtr,E4, 
            Repeat "2b", 1

            Notes qtr,C4, qtr,C4, 

            If_Alt D4, Cs4
            Notes qtr,D4, 
            Notes qtr,C4, qtr,As3

            If_Alt A3, Gs3
            Notes 8th,A3, 
            _28_5:
            Notes qtr,C4, 7*_8th,rest 


        _29:
        Riff _27, _29



        _31:
            Riff _27, _27_3 ;rest-F-F

            If_Alt As4, Gs4
            Notes qtr,As4, 8th,rest,

            Notes 8th,F4,  
            Notes qtr,C4, qtr,C4,  
        _31_7:
        Notes qtr,F4,8th,rest, 8th,C4, 

        Riff _27_3, _27_5 ;Double qtr,D3 w/ If_Alt

        Notes qtr,F4, 
        
        If_Alt D3, Cs3, 'F'
        Notes 8th,D4, 
        Riff _28_5, _29 ;C4, Rest


        ;33
        Riff _31, _31_7
        Notes qtr,C4, qtr,rest ;6
        


        Shift_Pitch -Octave

        If_Alt 1, -4, 'F'
        Shift_Pitch 1 

        _34:
        Notes 8th,As3, qtr,As3, qtr,As3

        _34_3:
        Duration _1111, F3,D3,As2, D3

        _34_5:
        Notes qtr,D3, qtr,D3, dqt,rest

        
        _35:
        Notes 8th,B3, qtr,B3, qtr,B3
        Duration _1111, G3,D3,B2, D3

        Riff _34_5, _35
    Loop Yoshi_Valley_Sq0, End_Intro


    Channel Yoshi_Valley_Tri
        Header B3, T_1f_v8__d12,  


        Notes qtr,B4, 8th,rest, 8th,B4, hlf,rest
        Notes qtr,G4, 8th,rest, 8th,G4, hlf,rest

        ;1
        Notes 8th,F4, qtr,F4, 8th,F4
        Notes qtr,E4, qtr,Ds4, qtr,D4, dhf,rest


        End_Intro:
        Shift_Pitch -6
        Riff YV_Sq0::_3, YV_Sq0::_34_3 +1, "3b"
        BP .set Cs3


        ;34
        ;D3's
        Duration "Cont", As3,F3,D3, As3
        Notes qtr,As3, qtr,As3, dqt,rest

        ;35
        ;D3's
        Riff YV_Sq0::_34, YV_Sq0::_34_3 +1
        Duration "Cont", B3,G3,D3, B3

        Notes qtr,B3, qtr,B3, dqt,rest


    Loop Yoshi_Valley_Tri, End_Intro

py_Segment_End Yoshi_Valley_Sq0




.align 256
py_Segment Yoshi_Valley_dmc, PageFit

    _8th .set 7
    Channel Yoshi_Valley_dmc, YV_dmc
        Header C2, T_1f_12v__d25,  

        Shift_Pitch C2, G1

        _1:
            Notes qtr,G2, 

            Riff _1_5, _2 ;G2 rest

            Notes qtr,G1,  
            _1_5:
            Notes 8th,rest,
        _1_6:
        Notes              8th,G2, hlf,rest

        _2:
        Notes 8th,G1, qtr,G1, 8th,G2
        Shift_Pitch G1, C2
        Notes qtr,A2, qtr,As2, qtr,B2, dhf,rest


        End_Intro:

        _3:
            Notes hlf,C3, hlf,G2
            Repeat "2b", 5


            _6:
                Notes hlf,G2, hlf,D2
                Repeat "2b", 1

            _7:
            Notes hlf,C3, hlf,G2
            Repeat "2b", 1

            _8:
            Notes hlf,F2, hlf,C2
            Repeat "2b", 1

                Riff _6, _7


        _10:
        Notes hlf,G2, hlf,D2

        _10_5:
            Notes 8th,G2, 8th,rest, qtr,G2, qtr,A2, qtr,B2


        _11:
            Riff _3, _10

        Notes hlf,C3, hlf,G2

        Shift_Pitch C2, F1  ;G2, C2

        _18_5:
        Riff _10_5, _11
        ;Notes 8th,C2, 8th,rest, qtr,C2, qtr,D2, qtr,E2

        ;19
        Notes hlf,F2, hlf,C2
        _19_5:
        Repeat "2b", 14

        Shift_Pitch F1, As1
        _26_5:
                Riff _18_5, _19_5
                ; Riff _10_5, _11
                    ; ;Notes 8th,F2, 8th,rest, qtr,F2, qtr,G2, qtr,A2
                ; Notes hlf,As2, hlf,F2, 
                
                Notes hlf,A2

            _27_7:
            Notes hlf,F2, hlf,G2, 

            _28_3:
                Notes hlf,C2
                Riff _26_5, _27_7

        _29_7:
        Shift_Pitch As1, C2
        Notes hlf,D3,  hlf,C3, 
        Shift_Pitch C2, As1

        ;30.3
        Notes hlf,C2 
        Riff _26_5, _29_7
        Notes hlf,F2 

        ;34
        Shift_Pitch As1, G1

        Riff _1, _1_6
        Notes 8th,G1, hlf,rest
        Repeat "4b", 1


    Loop Yoshi_Valley_dmc, End_Intro


    _8th .set 6
    Channel Choco_Mountain_dmc
        Header C2, T_6f_m5_v12__d25


        _1:
                Duration _6x2, G2,G2, B2,B2, D2,D2 ;_7x2_f?

                _1_7:
                .byte Tie_Next_Note
                Notes qtr,E2, 
                
                .byte Tie_Next_Note
                Notes qtr,Fs2
                

            _2:
                Riff _1, _2
            _3:
            Repeat "2b", 1

            _4:
            Duration _6x2, C2,C2, G2,G2, C3,C3,

            ;4.6
            Duration _2222, G2,C2, G2,G2

            _5_3:
            .byte Tie_Next_Note  
            Duration _2222, B2,D3, Fs2,Fs2, 

            _5_7:
            Riff _5_3, _5_7 -1
            Duration "Cont", F2,F2,    
            
            
            ;6.3
            Shift_Pitch C2, Ds2

            Riff _5_3, _5_7 -1 ;D3,F3
            Duration "Cont", C3,C3

            Shift_Pitch Ds2, C2

            .byte Tie_Next_Note
            Notes qtr,G2,qtr,C3
            

        _7:
        Shift_Pitch C2, G1  ;From Ds2  ;Wants A1, Riff starts D2
        Riff _49, _49_7
        ;Duration _6x2, A1,A1, Cs2,Cs2, E2,E2, 
        Shift_Pitch G1, C2

        ;7.7
        Duration _6x2, A2,E2,   D2,D2, Fs2,D2
        Notes qtr,D3, dhf,rest


        ;9
            Riff _1, _7, "2b"

        ;15
        Duration _8x2, D2,D2, D2,D2, Fs2,Fs2, A2,D2


        ;16
        Shift_Pitch C2, G1

        Duration _2222, G2,G2, G1,D2
        Notes qtr,G1, dhf,rest

        Shift_Pitch G1, C2




        Env_Change T_1f_12v__d25

        _17:
            Riff YV_dmc::_7, YV_dmc::_8
            ; Notes hlf,C3, hlf,G2
            ; Repeat "2b", 1

            Riff YV_dmc::_6, YV_dmc::_7
            ; Notes hlf,G2, hlf,D2
            ; Repeat "2b", 1

        _19:
        Notes hlf,D3, hlf,A2
        Repeat "2b", 1


        Riff YV_dmc::_10, YV_dmc::_11

        ;Notes hlf,G2, hlf,D2
        ;Notes 8th,G2, 8th,rest, qtr,G2, qtr,A2, qtr,B2



        _21:
            Riff _17, _19

            ;23
            Notes hlf,D3, hlf,G2, hlf,D2
        _23_7:
        Repeat "3b", 1

        Riff YV_dmc::_10_5, YV_dmc::_11
        ;Notes 8th,G2, 8th,rest, qtr,G2, qtr,A2, qtr,B2

        ;25
        Riff _17, _23_7
        ;31.7
        Notes hlf,D3, hlf,D2, hlf,D3

        Notes 8th,D2, 8th,rest
        Notes qtr,D2, qtr,D3, qtr,D2



        ;33
        Notes hlf,G2, hlf,D2, hlf,E2, hlf,Fs2
        Repeat "4b", 7

        

        Env_Change T_6f_m5_v12__d25

        ;41
        Riff _1, _4

        Riff _1, _1_7
        Riff _49_7, _50



        ;49
        Shift_Pitch C2, G1
        Riff _1, _2
        Riff _1, _1_7

        .byte Tie_Next_Note
        Notes qtr,D2, 

        .byte Tie_Next_Note
        Notes qtr,Fs2

        Shift_Pitch G1, C2

        ;47
        Riff _1, _3


        _49:
            Duration _6x2, D2,D2, Fs2,Fs2, A2,A2
            _49_7:
            .byte Tie_Next_Note
            Notes qtr,D2, 
            _49_8:
            .byte Tie_Next_Note
            Notes qtr,Cs2
        _50:

            Shift_Pitch C2, As1
            Riff _49, _49_8

                .byte Tie_Next_Note
                Notes qtr,Cs2

            Shift_Pitch As1, C2
        _51:

        Riff _49, _51
        Repeat "2b", 1

        Riff _49, _49_7
        Notes qtr,Fs2, qtr,Fs2

        ;56
        Notes qtr,D2, qtr,D2
        Repeat "2b", 3

    Loop Choco_Mountain_dmc

py_Segment_End Yoshi_Valley_dmc



 
.align 256
py_Segment Yoshi_Valley_Noise, PageFit

    _8th .set 7
    Channel Yoshi_Valley_Noise, YV_N
        Noise_Header ::Yoshi_Valley_NB, d50_Kick
        BP .set ::Yoshi_Valley_NB

        ;1
            Notes dqt,Crash_3, 8th,Solo_Kick, hlf,Snare_6
            Notes dqt,Crash_7, 8th,Solo_Kick, hlf,Snare_6

            ;2
            Notes dqt,Crash_7;, 8th,Hat_Kick
            Duration _00, Shaker_Kick, rest

            Notes qtr,Crash_7;, qtr,Hat_Kick
            Duration _00, Shaker_Kick, rest ;rests silence the Crash early, the timing is just after the Shaker finished playing.

            Notes 8th,rest
            Notes qtr,Snare_6
            
            _2_6:
                Riff _10_6, _11 ;Can clever-merge w/ 3-19, but Conflicts w/ CM Re-use
    
        End_Intro:

        _3:
                Notes qtr,Crash_3, 

                _3_2:
                    Notes 8th,Snare_6, 8th,Hat_2, qtr,Shaker_Kick
                _3_4: ;CM
                Repeat _3_2, 29
                
                _10_6:
            Notes qtr,Shaker_2, qtr,Shaker_2, qtr,Shaker_2,



            _11:
                Riff _3, _10_6

            _18_6:
            Notes qtr,Snare_8, qtr,Snare_8, qtr,Snare_8, ;Snare vs Shaker


        ;

        _19:
            Notes qtr,Crash_3
            Riff _20_2, _21

            _20:
                Notes 8th,Shaker_As3,  8th,Hat_2
                _20_2:
                Duration _6x1, Shaker_As3, Hat_2,  Snare_6, Shaker_2,   Hat_2, Shaker_As3

                _20_5:
                Duration _8x1,   Hat_2,Shaker_As3,      Shaker_As3, Hat_2,   
                Duration "Cont", Snare_6, Hat_D3,       Shaker_As3, Shaker_As3  
            _21:

            Riff _20, _21
            Repeat "2b", 4

            _26:
            Riff _20, _20_5 +2
            Duration "Cont", Snare_8, Hat_2,  Snare_8, Hat_2,  Snare_8, Hat_2
        ;

        _27:
            Notes qtr,Crash_3
            Riff _28_2, _29

            _28:
                Notes 8th,Shaker_Kick, 8th,Hat_2
                _28_2:
                Duration _6x1, Snare_6, Hat_2,  Shaker_Kick, Shaker_2,  Snare_6, Shaker_2

                _28_5:
                Duration _8x1, Hat_Kick, Shaker_2,  Snare_6, Shaker_2
                Duration "Cont", Shaker_Kick, Hat_2, Snare_6, Hat_2
            _29:

            Riff _28, _29
            _30:
            Repeat "2b", 1

            
            Riff _27, _30 ;A measure gets lopped-off
        ;

        _34:
            Notes 8th,Crash_3, qtr,Crash_3, 5*_8th,Crash_3

            _34_5:
            Notes dqt,Snare_8_Kick, 5*_8th,Snare_8_Kick

            Riff _34, _34_5

            Notes dqt,Crash_3
            Duration _00, Snare_8, Snare_8 ;32nds
            Notes hlf, Snare_8

            ;35.5
        ;


    Loop Yoshi_Valley_Noise, End_Intro

    _8th .set 6
    Channel Choco_Mountain_Noise
        Noise_Header ::Choco_Mountain_NB, d50_Kick
        BP .set ::Choco_Mountain_NB


        Riff YV_N::_3, YV_N::_19 


        _17:
            Riff YV_N::_27, YV_N::_29

            Riff YV_N::_28, YV_N::_29 ;Hat+Shaker
            Repeat "2b", 4

            Riff YV_N::_28, YV_N::_28_5 

            Notes qtr,Shaker_2
            Riff YV_N::_18_6, YV_N::_19 ;3x Snare_8

        _25:
        Riff _17, _25


        _33:
            Riff YV_N::_3, YV_N::_3_4

            Riff YV_N::_3_2, YV_N::_10_6

            Notes 8th,Snare_6, 8th,Hat_2

        _41:
        Riff _33, _41
        Riff _33, _41 ;Sub-Repeat


    Loop Choco_Mountain_Noise

py_Segment_End Yoshi_Valley_Noise

