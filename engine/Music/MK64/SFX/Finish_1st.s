_8th .set 8;$11 ;9-8

Channel Finish_1st_Sq0, _1st_Sq0
    Header E3, Lead_12to25_s6_v12

    _1:
    Notes dqt,E3, hlf,G3, dqt,A3, 
    Notes qtr,B3, 8th,Cs4, 8th,rest, 8th,Ds4, 17*_8th,F4

    _3:
    Riff ::Inf_Wait_2, 3
Loop Finish_1st_Sq0, "Riffed"
_1st_Sq0_Loop:


Channel Finish_1st_Sq1
    Header G2, Lead_12to25_s6_v12

    Riff _1st_Sq0::_1, _1st_Sq0_Loop
Loop Finish_1st_Sq1, "Riffed"



Channel Finish_1st_Tri
    Header C4, Lead_12to25_s6_v12

    Riff _1st_Sq0::_1, _1st_Sq0_Loop
Loop Finish_1st_Tri, "Riffed"




Channel Finish_1st_dmc
    Header C1, T_0f_v8__d12

    Riff _1st_Sq0::_1, _1st_Sq0_Loop
Loop Finish_1st_dmc, "Riffed"



Channel Finish_1st_Noise
    Noise_Header ::Lose_Race_NB, As3_Tom

    End_Intro:

    Notes dqt,Crash_7, dqt,Crash_3

    Duration _00, Snare_6, Snare_6
    Notes 8th,Crash_7, qtr,Snare_6

    Notes qtr,Hat_2, qtr,Hat_2, 8th,Hat_2

    Notes 12,Crash_7 ;1.5*_8th
        Notes qtr,Solo_Kick ;1

        Notes 12,Solo_Kick ;2
        Repeat "2b", 2 ;3,4

        Notes 14,Solo_Kick ;5
        Repeat "2b", 1 ;6
            ;1.75*_8th

        Notes 4+5*_8th, Solo_Kick ;5.5*_8th

    Notes whl,Crash_7
    
    Riff ::Inf_Wait_2, 3
Loop Finish_1st_Noise, "Riffed"



