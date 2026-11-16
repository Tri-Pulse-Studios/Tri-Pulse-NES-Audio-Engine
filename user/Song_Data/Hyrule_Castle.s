;============================================================
; Statistics
;============================================================
; Total Size: 397 Bytes
    ; Sq0 133 B 
    ; Sq1 64 B
    ; Tri 74 B
    ; DMC 43 B
    ; Noise 83 B

_Env .set 0
_8th .set -1

.align 256

;============================================================
; Square 0
;============================================================

Channel Hyrule_Castle_Sq0
    Header A0, _Env

    Notes whl,rest

Loop Hyrule_Castle_Sq0


;============================================================
; Square 1
;============================================================

Channel Hyrule_Castle_Sq1
    Header A0, _Env

    Notes whl,rest

Loop Hyrule_Castle_Sq1


;============================================================
; Triangle
;============================================================

Channel Hyrule_Castle_Tri
    Header A0, _Env

    Notes whl,rest

Loop Hyrule_Castle_Tri


;============================================================
; DMC
;============================================================

Channel Hyrule_Castle_dmc
    Header A0, _Env

    Notes whl,rest

Loop Hyrule_Castle_dmc


;============================================================
; Noise
;============================================================

Channel Hyrule_Castle_Noise
    Noise_Header HC_NB, Unused ;Write Undef check

    Notes whl,rest

Loop Hyrule_Castle_Noise