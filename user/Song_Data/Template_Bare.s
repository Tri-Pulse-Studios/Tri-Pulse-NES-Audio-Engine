;See Template_Annotated.s for some guidance.

_8th .set -1


.align 256

;============================================================
; Square 0
;============================================================

Channel Song_Name_Sq0
    Header _BP, _Env

    Notes whl,rest

Loop Song_Name_Sq0


;============================================================
; Square 1
;============================================================

Channel Song_Name_Sq1
    Header _BP, _Env

    Notes whl,rest

Loop Song_Name_Sq1


;============================================================
; Triangle
;============================================================

Channel Song_Name_Tri
    Header _BP, _Env

    Notes whl,rest

Loop Song_Name_Tri


;============================================================
; DMC
;============================================================

Channel Song_Name_dmc
    Header _BP, _Env

    Notes whl,rest

Loop Song_Name_dmc


;============================================================
; Noise
;============================================================

Channel Song_Name_Noise
    Noise_Header ::NB, Kick_Type
        ; The "::" allows the global NoiseFX_Index variable to be read.

    Notes whl,rest

Loop Song_Name_Noise

