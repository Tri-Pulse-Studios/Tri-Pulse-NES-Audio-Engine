_8th .set $0b ;6-5

Channel Star_Power_Sq0
    Header A0, $00
    End_Intro:


    Notes qtr,C4, qtr,C4, 8th,C4, qtr,C4, qtr,C4

    _2_2:
    Notes qtr,C4, 8th,C4, qtr,C4, qtr,C4

    _3:
    Notes qtr,B3, qtr,B3, 8th,B3, qtr,B3, qtr,B3

    _4_2:
    Notes qtr,B3, 8th,B3, qtr,B3, qtr,B3

    _5:
Loop Star_Power_Sq0



Channel Star_Power_Sq1
    Header A0, $00
    End_Intro:


    Notes qtr,F3, qtr,F3, 8th,F3, qtr,F3, qtr,F3

    _2_2:
    Notes qtr,F3, 8th,F3, qtr,F3, qtr,F3

    _3:
    Notes qtr,E3, qtr,E3, 8th,E3, qtr,E3, qtr,E3

    _4_2:
    Notes qtr,E3, 8th,E3, qtr,E3, qtr,E3

    _5:
Loop Star_Power_Sq1



Channel Star_Power_Tri
    Header A0, $00
    End_Intro:


    Notes qtr,rest, 8th,Ds5, 6,Fs5, 1,Ds5, 8th,A4, 6,C5, 1,A4, 8th,rest, 1,rest, 8th,Ds5, 6,Fs5

    _2_1_1:
    Notes 1,Ds5, 8th,Ds5, 6,Fs5, 8th,A4, 6,C5, 1,A4, 8th,A4, 6,C5, 1,A4

    _2_6_2:
    Riff _2, _1

    _3_6_2:
    Repeat "2b", 1

    _4_6_2:
    Notes _16th,rest, 8th,Ds5, 6,Fs5, 1,Ds5, 8th,A4

    _5_1_4:
    Notes 6,C5, 1,A4, 8th,rest, 1,rest, 8th,Ds5, 6,Fs5, 1,Ds5, 8th,Ds5, 6,Fs5, 8th,Ds5, 6,Fs5, 1,Ds5, 8th,A4

    _6_1_2:
Loop Star_Power_Tri



Channel Star_Power_dmc
    Header A0, $00


    Notes whl, rest

Loop Star_Power_dmc



Star_Power_Noise_Bank .set NoiseFX_Index

NoiseFX @Placeholder, $00, $00, $00

Channel Star_Power_Noise
    Noise_Header ::Star_Power_Noise_Bank, Intro

    End_Intro:

    Notes whl, rest

Loop Star_Power_Noise



