
; High: -edcba98
; Low:  01234567

  ; OUT A = (High << 1) XOR Low.
    ; Same 32,767 Cycle length of 15-bit LSFR.
    ; Improvement: Every successor is different. (2 Reads are Highly-Decorrelated.)
        ; though there are still local correlations with 3 or mroe reads.

Call_RNG:
  lda RNG_high ;$bit $e
  asl 
  clc ;default incoming to clear

  eor RNG_low  ;$bit $0
  bpl @skip

    sec ;set incoming

  @skip:
  ror RNG_low 
  rol RNG_high
rts
    ;32/33 clock cycles. (28/29 if ZP)