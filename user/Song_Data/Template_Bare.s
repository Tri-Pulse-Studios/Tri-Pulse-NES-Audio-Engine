;See Template_Detailed.s for some explanations.

_8th .set -1


.align 256


;============================================================
; Square 0
;============================================================

Channel Song_Name_Sq0
    Header Init_BP, Env_Name

    Notes whl,rest

Loop Song_Name_Sq0


;============================================================
; Square 1
;============================================================

Channel Song_Name_Sq1
    Header Init_BP, Env_Name

    Notes whl,rest

Loop Song_Name_Sq1


;============================================================
; Triangle
;============================================================

Channel Song_Name_Tri
    Header Init_BP, Env_Name

    Notes whl,rest

Loop Song_Name_Tri


;============================================================
; DMC
;============================================================

Channel Song_Name_dmc
    Header Init_BP, Env_Name

    Notes whl,rest

Loop Song_Name_dmc


;============================================================
; Noise
;============================================================

Channel Song_Name_Noise
    Noise_Header ::Song_Name_Noise_Bank, Kick_Type
        ; The "::" allows the global NoiseFX_Index variable to be read.

    Notes whl,rest

Loop Song_Name_Noise

