_8th .set 7+6

.align 256
;============================================================
; Square 0
;============================================================

Channel Scale_Demo_Sq0
    Header A0, Pad_d12_8_0



        Notes 8th,rest
    Repeat "1b", $49 
        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 


    Notes 8th,A0
    Shift_Pitch +1
    Repeat "2b", $3f ;To max pitch

        Notes 8th,rest
    Repeat "1b", $3f 

Loop Scale_Demo_Sq0

;============================================================
; Square 1
;============================================================

Channel Scale_Demo_Sq1
    Header A0, Lead_sqr_13_0

        Notes 8th,rest
    Repeat "1b", $49 

    Notes 8th,A0
    Shift_Pitch +1
    Repeat "2b", $3f ;To max pitch


        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 

Loop Scale_Demo_Sq1


;============================================================
; Triangle
;============================================================

Channel Scale_Demo_Tri
    Header A0, T_2f__d12

        Notes 8th,rest
    Repeat "1b", $49 
        Notes 8th,rest
    Repeat "1b", $3f 

    Notes 8th,A0
    Shift_Pitch +1
    Repeat "2b", $3f ;To max pitch

        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 

Loop Scale_Demo_Tri

;============================================================
; DMC
;============================================================

Channel Scale_Demo_dmc
    Header B0, T_2f__d12


    Notes 8th,B0
    Shift_Pitch +1
    Repeat "2b", $24 ;To max pitch

    Env_Change T_2f__d25
    Set_Pitch B0

    Notes 8th,B0
    Shift_Pitch +1
    Repeat "2b", $24 ;To max pitch

        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 


        Notes 8th,rest
    Repeat "1b", $3f 

Loop Scale_Demo_dmc

;============================================================
; Noise
;============================================================

Channel Scale_Demo_Noise
    Header $00, _d50

        Notes 8th,rest
    Repeat "1b", $49 
        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 
        Notes 8th,rest
    Repeat "1b", $3f 

    Notes hlf,A0
        Shift_Pitch +1
        Repeat "2b", $0f ;To max pitch

Loop Scale_Demo_Noise