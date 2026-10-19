_8th .set $0e ;7

Channel Battle__Sq0
    Header A0, $00
    End_Intro:


    Notes qtr,rest, dqt,E3, 8th,rest, dqt,E3

    _2_2:
    Riff _2, _1

    _4_2:
    Repeat "2b", 21

    _25_2:
    Notes 8th,rest, dqt,E3, hlf,E3, 8th,rest, dqt,E3, 8th,rest, dqt,E3

    _26_2:
    Notes 8th,rest, dqt,E3, hlf,Ds3, 8th,rest, dqt,D3, 8th,rest, dqt,D3

    _28_2:
    Riff _26, _25

    _30_2:
    Repeat "2b", 2

    _32_2:
    Riff _2, _1

    _33_2:
    Repeat "2b", 2

    _35_2:
    Notes 8th,rest, dqt,D3, hlf,D3, 8th,rest, dqt,E3, 8th,rest, dqt,E3

    _36_2:
    Riff _26, _25

    _38_2:
    Repeat "2b", 3

    _41_2:
    Notes 8th,rest, dqt,E3, hlf,Ds3, 8th,rest, dqt,E3, 8th,rest, dqt,E3

    _42_2:
    Notes 8th,rest, dqt,E3, hlf,E3, 8th,rest, dqt,D3, 8th,rest, dqt,D3

    _44_2:
    Riff _39, _37

    _47_2:
    Repeat "2b", 2

    _51_2:
Loop Battle__Sq0



Channel Battle__Sq1
    Header A0, $00
    End_Intro:


    Notes qtr,rest, dqt,C3, 8th,rest, dqt,C3

    _2_2:
    Riff _2, _1

    _4_2:
    Repeat "2b", 22

    _26_2:
    Notes 8th,rest, dqt,C3, hlf,C3, 8th,rest, dqt,B2, 8th,rest, dqt,B2

    _27_2:
    Riff _26, _25

    _29_2:
    Repeat "2b", 2

    _31_2:
    Riff _2, _1

    _32_2:
    Repeat "2b", 3

    _35_2:
    Riff _26, _25

    _36_2:
    Repeat "2b", 3

    _39_2:
    Notes 8th,rest, dqt,B2, hlf,B2, 8th,rest, dqt,C3, 8th,rest, dqt,C3

    _40_2:
    Notes 8th,rest, dqt,C3, hlf,C3, 8th,rest, dqt,B2, 8th,rest, dqt,B2

    _42_2:
    Riff _39, _37

    _45_2:
    Repeat "2b", 2

    _49_2:
Loop Battle__Sq1



Channel Battle__Tri
    Header A0, $00


    Notes whl, rest

Loop Battle__Tri



Channel Battle__dmc
    Header A0, $00


    Notes whl, rest

Loop Battle__dmc



Battle__Noise_Bank .set NoiseFX_Index

NoiseFX @Placeholder, $00, $00, $00

Channel Battle__Noise
    Noise_Header ::Battle__Noise_Bank, Intro

    End_Intro:

    Notes whl, rest

Loop Battle__Noise



