 
 
reset:
sei		; disable IRQs. Permanently.

; ldy #$40 ;-> Y
; sty $4017	; disable APU frame IRQ

ldx #$00
stx $2000	; disable NMI
stx $2001 	; disable rendering

; stx $4010 	; disable DMC IRQs
; txs 


bit $2002 ;Not flushed on reset. Must flush manually.
; :
;     bit $2002 ;5-Bytes to make start time deterministic.  like SP, non-determinite is irrelevent.
;     bpl :-



ldy #$0c
;ldx #$00
stx $2006 ;v-RAM = $0000
stx $2006

lda #$ff ;_spc ora $c0



@loop:
    sta $2007 ;Clear v-RAM  $0000-$3eff  (Writes to CHR-ROM, which does nothing.)

    dey
    bne @loop

    dex
    bne @loop
;
;vRAM is now $ff0c, the 4th pallette. (This takes nearly a full second.)


dey ;ldy #$ff,   pallete = $3f, same black as $0f
sty $2007
sty Track_Index ;Overflow to $00 for Title

;ldx #$00 ;I Want $2d. Its a tad darker.
stx $2007

lda #$30
sta $2007

;Permanent Text
    ldx #$e9
    lda #_CURRENT_TRACK__
    jsr Set_PPU_ADDR_Display_Word

    ldx #$07
    lda #_LOGO
    jsr Set_PPU_ADDR_Display_Word

    ldx #($20 + SUBTITLE_OFFSET)
    lda #_SUBTITLE
    jsr Set_PPU_ADDR_Display_Word
        ;A = $80 | _B  or $8c
            ;I want to store $0c to $2001, and $80 just is BLue Emphasis

    .if Debugging_Enabled
        cmp #$8C
        beq :+
            .byte $02 ;STP Excepted $8c from _B|$80 of Logo's 8KB
        :
    .endif

lda #%000001110 ;Enable bkgrd, disable Sprites
sta $2001


lda #butA|down ;This also prevents serious non-deterministic issues.
sta Pressed_Button ;Init Track Text to 01, and Play it.

lda #%10000000 ;Render Full Screen
sta $2000 ;Enable NMI 

@inf_wait:
bal @inf_wait, bmi

