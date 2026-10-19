_8th .set 8


Channel Award_Lose_Sq0, AL_Sq0 
    Header {D3, +Octave}, Pad_d25_8_3_v12

    If_Alt "Toggle"

    _1:
        Duration _1111, E3,rest, E3,rest

        If_Alt G3, E3
        Notes qtr,G3

        _1_4:

        If_Alt C4, B3
        Notes 8th,C4 ;Tri Can't Use.

        _1_5:
        Duration _8x1, A3,rest, A3,rest, A3,Gs3, rest,Gs3
        Notes 8th,rest
    ;

    _2:
        Notes qtr,G3, 
        _2_2:
        Notes 12*_8th,rest

        _3:
        Notes 16*_8th,D3
    ;
    ::Inf_Wait_2:
    Notes whl,rest
Loop Award_Lose_Sq0, ::Inf_Wait_2
 AL_Sq0_Inf_Wait:

Channel Award_Lose_Sq1
    Header {As2, +Octave}, Pad_d25_8_3_v12

    Riff AL_Sq0::_1, AL_Sq0_Inf_Wait
Loop Award_Lose_Sq1, "Riffed"

Channel Award_Lose_Tri
    Header F3, T_1f_12v__d25

    Riff AL_Sq0::_1, AL_Sq0::_1_4
    Notes 8th,C4
    Riff AL_Sq0::_1_5, AL_Sq0::_2

    ;2

        Shift_Pitch +Octave
        .byte Set_Env_Bank_Byte,   SFX_Hoot_M8

        Notes 11,C5

        Notes 11,Fs5
        Repeat "2b", 2

        Notes 11,C5
        Repeat "2b", 2

        Notes ((14*_8th)-77),rest ;77 is triplet * 7

    ;3
    .byte Set_Env_Bank_Byte,   T_1f_12v__d25
    Set_Pitch E3 ;-13
    Riff AL_Sq0::_3, AL_Sq0_Inf_Wait

Loop Award_Lose_Tri, "Riffed"

Channel Award_Lose_dmc
    Header C2, T_0f__d25 

    ;1
        Notes qtr,C3, 8th,rest, 8th,C3

        Notes dqt,E2, dqt,F2, 8th,rest, 8th,F2

        Notes qtr,Fs2, 8th,rest, 8th,Fs2, 
    ;

    ;2
    Notes qtr,G2
    Riff AL_Sq0::_2_2, AL_Sq0_Inf_Wait
Loop Award_Lose_dmc, "Riffed"


Channel Award_Lose_Noise
    Noise_Header ::Raceway_NB, d25_Kick

    ;1
    Notes qtr,Crash_3, qtr,Shaker_2

    Duration _6x1, Hat_Kick,Hat_2, Shaker_2,Solo_Kick, 
    ;1.5
    Duration "Cont", Hat_2,Hat_2
    Notes qtr, Shaker_2

    Duration _1111, Hat_Kick,Hat_2, Shaker_2,Hat_2

    ;2
    Notes hlf,Crash_3, hlf,Hat_2, hlf,Hat_2, qtr,Hat_2

    ;3
    Notes 14*_8th,Crash_7

    Duration _0000, Hat_2, Hat_2, Hat_2, Shaker_2

    Notes whl,Crash_3
    Riff ::Inf_Wait_2, 3
Loop Award_Lose_Noise, "Riffed"

