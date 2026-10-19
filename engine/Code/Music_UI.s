

 

;The idea

;Just hardcode a location in the middle of the screen
    ;Display Track XX
            ;<Track Name>
            
            ;If I can splurge, a
                ;Current/Total Time  counter would be fun.

.macro OAM_DMA_Controller_Read
  ;Copy OAM
  ldx #OAM_Buffer_Page 
  stx $4014   ; takes 513-514 Cycles.

  ;End Vblank.


  ;Cycle Parity Critical: Using Get/Push Cycles to avoid DPCM Audio Bug.
    lda Held_Button
    sta irq_tmp_0 ;prev_frame_Held_Button

    ldx #$01
    stx Z:Held_Button 

    stx A:Joy_Pad_1
    dex ;ldx 0
    stx A:Joy_Pad_1  ;Latches both P1 and P2
    @loop:
      ;lda $4017
      ;lsr
      ;rol P2_Held_Button,x  ;needs ,x to be 6cc. Cycle Parity

      lda A:Joy_Pad_1
      lsr 
      .byte $26 + ((<@loop / $F8) * $10), Held_Button ; (Cycle Parity w/ OAM)
      ;rol Held_Button ;Auto switches to rol,x w/ ldx 0 to maintain cycle Parity w/ OAM

      bcc @loop ;If branching over page boundary, waste a second cycle w/ rol,x

  ;End Cycle Parity Critial

  lda Held_Button
  eor irq_tmp_0 ;prev_frame_Held_Button
  and Held_Button
  sta Pressed_Button
.endmacro





nmi:
    lda Pressed_Button
    and #up+down ;And left/right?
    beq @skip_UD

        and #up
        beq @up ;yes, backwards


            @down:
            dec Track_Index
            bpl @Draw_New_Name

                ;lda_GameFX Buzzer
                ;sta SFX_Queue+$10 ;Have it be a DMC Tri effect.

                    ;Fall Through to @up to cancel the dec

            @up:
            inc Track_Index

        @Draw_New_Name:
        lda Track_Index
        cmp #Max_Track_Index+1 ;+1 for after end. (Song Silence is normally end.)
        bcs @down ;dec to cancel inc

        jsr Update_Track_Cursor ;Not Inline. No point when a beq skips over it.

        ;If can be fancy, a hold -> Scroll faster Would be nice.

    @skip_UD:


    bit Pressed_Button
    bpl skip_A ;A_Button

        lda Track_Index
        jsr Song_Init

        jsr Update_Now_Playing

    skip_A:

    ; TODO Song "Silence"
    ; bit Pressed_Button
    ; bvc @skip_B ;B_Button

    ;     lda #Song_Silence_Index
    ;     jsr Song_Init

    ; @skip_B:

    lda #$00
    sta $2005 ;Set Scroll
    sta $2005

    Inline OAM_DMA_Controller_Read

    jsr Update_Music
rti ;go back to inf-wait in reset.

 


Update_Now_Playing:
    lda #$22
    sta $2006
    lda #$06 ;Set PPU isn't flexible enough. Also, more space desired.
    sta $2006

    @skip_else:
    ldx Song_ID
    bal Display_Track_Name, bpl ; ;Tail Call



    ;In A= Display Index (+1 of Song Index)
Update_Track_Cursor:
    ldx #$83
    lda #_TRACK__
    jsr Set_PPU_ADDR_Display_Word ;OUT X= Track Index


    ;BCD two-digit display
    txa ;lda Track_Index
    ldy #$ff
    @loop_div10:
        iny
        sub #10
        bcs @loop_div10


    add #10 +1, clc  ;+1 as Tiles are 1-Based.
    sty $2007 ;tens
    sta $2007 ;ones


    ;Disp Track Name
    lda #__dash__
    jsr Display_Word

;   bal Display_Track_Name, bpl ; ;Tail Call


;In X= Track Index
Display_Track_Name:

    ldy LUT_Name_Start_Indexes,x 
    @loop_name:
        lda LUT_Song_Names_Text,y
        bpl @letter

            jsr Display_Word
            bal @skip_else, bpl  
                ;Track Index is 0..24 iirc

            @letter:
            sta $2007

        @skip_else:
        iny
        
        tya
        cmp LUT_Name_Start_Indexes +1,x 
        bcc @loop_name

    ;jmp Clear_7_Tiles ;Tail-Call

    ;IN  y = Num to clear.
        ldy #14 ;So Menu Erases KTB
    Clear_Y_Tiles:
        lda #_spc
        @loop_clr: ;Clear a bit of space so old names don't stick around.
            sta $2007
            dey 
            bne @loop_clr
rts


    ;In X= Low Byte
        ;High Byte hardcoded $21

    ; A= Fallthrough Word_ID 
Set_PPU_ADDR_Display_Word:
    ldy #$21
    sty $2006
        ;In X= Low Byte
    stx $2006
;jmp Display_Word

;In A= Word Index to Display
Display_Word:
    ;and #$7f
    tax ;Trashes Track_Index

    @loop_word:
        inx ;pre-inx
        lda LUT_Words_Text -1 -$80,x 
            pha

            and #$3f ;Confine Tile Range
        sta $2007

            pla ;Not required by Hardware. Mesen Doesn't mirror though.
        bpl @loop_word


@rts:
ldx Track_Index ;restore
rts
;OUT X= Track Index
;    NFlag = ldx 


; Recursive_Diplay_Word:
    ;     and #$7F
    ;     tax

    ;     @loop_word:
    ;         lda LUT_Words_Text,x ;the ora #$80 only works b/c Tiles are Repeated.
    ;         bpl @letter

    ;             @word:
    ;             tay
    ;             phx ;Trashes A
    ;             tya

    ;             jsr Recursive_Diplay_Word
    ;             plx
    ;             jmp @loop_word

    ;         @letter:
    ;         sta $2007
    ;         inx

    ;         and #%01000000
    ;         beq @loop_word

    ; @rts:
    ; ldx Track_Index ;restore
; rts

