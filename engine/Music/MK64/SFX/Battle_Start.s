_8th .set 6


Channel Battle_Start_Sq1, BS_Sq1
    Header C4, Pad_d75_8_0

    _1:
    Notes dqt,rest

    _1_3:
        Notes dqt,C4, dqt,C4, 
         
    
        _2:
        Env_Change Lead_12to25_s6_v12
        Notes 10*_8th,C4

        _3:
        Riff RS_Sq1::_4, RS_Sq1_Inf_Wait
Loop Battle_Start_Sq1, "Riffed"
Inf_Wait_BS_Sq1:




Channel Battle_Start_Sq0
    Header E1, Pad_d75_8_0
    
    _1:
        Notes 1,F1
        Shift_Pitch +2

        Repeat _1, 17 ;6*3
    ;
   
    BP .set E4
    Riff BS_Sq1::_1_3, BS_Sq1::_3

    Riff RS_Sq0::_4, RS_Sq0_Inf_Wait
Loop Battle_Start_Sq0, "Riffed"


Channel Battle_Start_Tri
    Header C2, T_M11__d25 

    Riff BS_Sq1::_1, BS_Sq1::_2 +1 ;Env
    
    ;Env_Change T_0f__d25 ;Not in bank

    Notes dhf,C2 
    .byte Init_Sweep, 18 ;C2-F1
    Notes hlf,C2 ;Not bothering w/ No Env reset. No cutoff.

    Riff RS_Sq0::_4, RS_Sq0_Inf_Wait ;This Sweep Costs 7B
Loop Battle_Start_Tri, "Riffed"


Channel Battle_Start_dmc
    Header C3, T_M11__d25
    
    Riff BS_Sq1::_1, Inf_Wait_BS_Sq1
Loop Battle_Start_dmc, "Riffed"


Channel Battle_Start_Noise
    Noise_Header ::Raceway_NB, d25_Kick

    Notes 8th,rest
    Duration _0000, Hat_2, Hat_2, Hat_2, Hat_2

    Notes dqt,Crash_3, dqt,Crash_3, 

    Notes whl,Crash_7 ;If nothing after Crashes.

    Riff ::Inf_Wait, 3

Loop Battle_Start_Noise, "Riffed"


