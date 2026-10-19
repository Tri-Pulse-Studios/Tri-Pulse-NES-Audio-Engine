_8th .set 7+8

    ;My BPM modifier ideas code likely takse only $20 bytes. This song alone is worth it.

Channel Race_Start_Sq0, RS_Sq0
    Header F3, Pad_d75_8_0

    ;1
    Notes 8th,F3, 7,rest, 8th,Cs4, 8th,Cs4, 
    
    Notes 8+5,F3
    
    Shift_Pitch F3,Gs3
    ;
    _2:
            Notes 10,A3, 10,Fs4, 
        _2_5:
        Notes 10,A3

            Shift_Pitch +1
            Riff _2, _2_5
        Notes 5,As3
    ;

    _3:
        Notes 9,C4, ;16th, doubly rounded up.
        
        Notes 8th,C4, 8th,C4

        ;
            Notes _8th+7,Cs4,  ;3x 16ths, rounded down.
            Shift_Pitch +1
        Repeat "3b", 2
        BP .set BP+2

        Notes 8th,E4

        Env_Change Lead_12to25_s6_v12
        Notes dhf,E4

    ;
    _4:
        Set_Pitch G3
        Env_Change Lead_sqr_13_0

        _4_BP:
        Notes 90,rest ;dhf raw

        Notes 60,G3 ;Yes, hlf raw. Battle needs it raw.
        Repeat "2b", 1
        Notes 30,G4


    ::Inf_Wait:
    Notes whl,rest

Loop Race_Start_Sq0, ::Inf_Wait
RS_Sq0_Inf_Wait:


Channel Race_Start_Sq1, RS_Sq1
    Header F3, Pad_d75_8_0
    
    ;1
    Duration _1111, rest,Gs3,F4,Gs3
    

    _2:
        Notes 10,Fs3, 10,D4, 10,D4
        _2_5:
        Shift_Pitch +1
        Riff _2, _2_5


    _3:
        Riff RS_Sq0::_3, RS_Sq0::_4

        _4:
        Set_Pitch G2
        Env_Change Pad_d25_8_3_v12

        Riff RS_Sq0::_4_BP, RS_Sq0_Inf_Wait

Loop Race_Start_Sq0, "Riffed"
RS_Sq1_Inf_Wait:


Channel Race_Start_Tri
    Header {F3, +Octave}, T_M11__d25

    Notes 8th,F3
    Duration _6x0, Gs3,Cs4,F4, Cs4,Gs3,F3

    _2:
    Notes 5,Fs3, 5,A3, 5,D4, 
    Notes 5,Fs4, 5,D4, 5,A3  ;Gross
    _2_5:
    Shift_Pitch +1
    Riff _2, _2_5

    Set_Pitch D4,+Octave    ;Fs3, D4  is +8
    Riff RS_Sq0::_3, RS_Sq0_Inf_Wait
Loop Race_Start_Sq0, "Riffed"

Channel Race_Start_dmc
    Header Ds2, T_1f_12v__d25

    Notes hlf,Ds2, qtr,E2, qtr,F2

    Duration _6x0, G2,G2, rest,G2, rest,E2

        Env_Change T_6f_m5_v12__d25 
        Notes 8th,rest, 22,F2, 23,Fs2, 8th,G2

    Env_Change T_1f_12v__d25
    Notes dhf,G2

    Riff RS_Sq1::_4, RS_Sq1_Inf_Wait
Loop Race_Start_Sq0, "Riffed"



Channel Race_Start_Noise
    Noise_Header ::Raceway_NB, As3_Tom

    ;1
        Notes hlf,Crash_3, qtr,Crash_3, qtr,Crash_3

    ;2
        Notes qtr,Crash_7

        Vol_Fade_In Vol_25,Vol_100, 18 ;Tweak this

        Notes 5,Snare_6
        Repeat "2b", 17  ;3*30 = 90f or 15*6 = dhf

    ;3
        .byte Clear_Special_Fade ;Vol Set 100
        Notes 5*_8th,Crash_3

        Notes 5,Snare_6
        Repeat "2b", 2
        Notes whl,Snare_8_Kick

    ;

    Riff ::Inf_Wait, 3

Loop Race_Start_Sq0, "Riffed"


