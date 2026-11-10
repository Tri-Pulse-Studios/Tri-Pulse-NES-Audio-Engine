 
 
reset:
sei		; disable IRQs. Permanently.


ldy #$00
sty $2000	; disable NMI
sty $2001 	; disable rendering

; stx $4010 	; disable DMC IRQs
; ldy #$40 ;-> Y
; sty $4017	; disable APU frame IRQ


bit $2002
:
    bit $2002 ;Deterministic start time.
    bpl :-


tya  ;lda #$00
sta $00

ldx #$07
stx $01
@clr_RAM:
    sta ($00),y
    iny
    bne @clr_RAM

    dec $01
    bpl @clr_RAM ;Clear $000 - $7ff

;ldy #$34 ;v-RAM = $3400, Mirror of $2000 and $2c00


ldx #$34
stx $2006 
;lda #$00
sta $2006  ;v-RAM = $3400 (Mirror of $2000)

ldx #$0b ;vRAM is $3f00 after loop.

;lda #$00 ;ASCII Null.
@loop:
    sta $2007 ;Clear v-RAM  $3400-$3eff  (Writes to CHR-ROM, which does nothing.)

    dey
    bne @loop

    dex
    bne @loop


;



dex ;ldx #$ff 
txs ;

stx $2007 ;Black
stx Track_Index ;Overflow to $00 for Title

;lda #$00 
sta $2007 ;Dark Grey

lda #$30
sta $2007 ;White

;Permanent Text
    ldx #$a7
    ldy #$20
    lda #_LOGO
    jsr Set_16bit_PPU_ADDR_Display_Word

    ldx #$00 + SUBTITLE_HI_OFFSET
    lda #_SUBTITLE_HI
    jsr Set_PPU_ADDR_Display_Word

    ldx #$20 + SUBTITLE_LOW_OFFSET
    lda #_SUBTITLE_LOW
    jsr Set_PPU_ADDR_Display_Word

    ldx #$e0 + 9 ;Centered.
    lda #_CURRENT_TRACK__
    jsr Set_PPU_ADDR_Display_Word



lda #butA|down 
sta Pressed_Button ;Init Track Text to 01, and Play it.

.if Debugging_Enabled
    Res_RAM Spinning_Flag

    lda #$00
    sta Spinning_Flag

.endif

lda #%10000000
sta $2000 ;Enable NMI 



@inf_wait:
bal @inf_wait, bmi

