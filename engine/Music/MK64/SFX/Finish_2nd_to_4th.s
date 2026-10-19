 _8th .set 8
Channel Finish_2nd4th_Sq0, Fin_2nd_Sq0
    Header D3, Lead_12to25_s6_v12


    _1:
    Notes qtr,rest
    Duration _1111, D3,rest,E3,E3
    
    _1_4:
    Notes 8th,rest, 
    If_Alt Fs3, F3
    Notes dqt,F3+1, 

    If_Alt Fs3, F3
    Notes 8th,F3+1
    Repeat "2b", 1 ;dqt, 8th, 8th

    _1_6:
    Notes qtr,G3, 8th,G3, 8th,G3

    _2:
    Notes 12*_8th,B3

    Riff ::Inf_Wait_2, 3
Loop Finish_2nd4th_Sq0, "Riffed"

Loop_Fin_2nd_Sq0:


Channel Finish_2nd4th_Sq1
    Header B2, Lead_12to25_s6_v12

    Notes qtr,rest
    Duration _1111, B2,rest,C3,C3

    Riff Fin_2nd_Sq0::_1_4, Fin_2nd_Sq0::_2

    _2:
    Notes 12*_8th,G3

    Riff ::Inf_Wait_2, 3
Loop Finish_2nd4th_Sq1, "Riffed"


Channel Finish_2nd4th_Tri, Fin_2nd_Tri
    Header G3, T_1f_12v__d25

    If_Alt "Toggle"
    Riff Fin_2nd_Sq0::_1, Loop_Fin_2nd_Sq0

Loop Finish_2nd4th_Tri, "Riffed"



Channel Finish_2nd4th_dmc
    Header C2, T_1f_v8__d12

    If_Alt "Toggle"
    Riff Fin_2nd_Sq0::_1, Fin_2nd_Sq0::_2
    Notes 12*_8th,C2

    Riff ::Inf_Wait_2, 3
Loop Finish_2nd4th_dmc, "Riffed"




Channel Finish_2nd4th_Noise
    Noise_Header ::Lose_Race_NB, As3_Tom


    Notes qtr,Crash_3, qtr,Snare_6, qtr,Snare_6, 8th,Snare_6, 8th,Solo_Kick

    ;1.5
    Notes qtr,Hat_2, 8th,Hat_2, 8th,Snare_6, qtr,Snare_6, qtr,Snare_6

    ;2
    Notes 10*_8th +1, Crash_7
    Notes 5,Snare_6
    Repeat "2b", 2 ;Triplets

    Notes whl,Crash_3

    Riff ::Inf_Wait_2, 3
Loop Finish_2nd4th_Noise, "Riffed"


