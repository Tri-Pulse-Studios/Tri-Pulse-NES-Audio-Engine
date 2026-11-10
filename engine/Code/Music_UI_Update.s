

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

 

.macro Update_Displayed_Addresses
    lda Pressed_Button
    bne @exit ;not enough time to update in nmi if Song also changes.

    ldy #$04
    @Loop_5_Channels:
    sty irq_tmp_0

        lda LUT_Addr_Possitions,y
        tax

        lda LUT_Addr_Words,y ;lda #`Sq0`
        
        ldy #$22
        jsr Set_16bit_PPU_ADDR_Display_Word 


        lda #_Hex ;`: $`
        jsr Display_Word

        ;Display Pointer
            lda irq_tmp_0
            asln 2
            tax

            lda Note_Data_High,x
            lsrn 4
            tay
            lda LUT_Hex_Tiles,y
            sta $2007

            lda Note_Data_High,x
            and #$0f
            tay
            lda LUT_Hex_Tiles,y
            sta $2007

            lda Note_Data,x
            lsrn 4
            tay
            lda LUT_Hex_Tiles,y
            sta $2007

            lda Note_Data,x
            and #$0f
            tay
            lda LUT_Hex_Tiles,y
            sta $2007

    ldy irq_tmp_0
    dey
    bpl @Loop_5_Channels

    @exit:
.endmacro


.macro Update_Selected_Track
    lda Pressed_Button
    and #up+down+left+right 
    beq @skip_UD

        and #up+right
        beq @up

            ;else down or left.

            @down:
            dec Track_Index
            bpl @Draw_New_Name

                ;lda_GameFX Buzzer
                ;sta SFX_Queue+$10 ;Have it be a DMC Tri effect.

                    

            @up:
            inc Track_Index

        @Draw_New_Name:
        lda Track_Index
        cmp #Max_Track_Index+1 ;+1 to stop going beyond it.
        bcs @down ;dec to cancel inc

        jsr Update_Track_Cursor ;Not Inline. No point when a jeq skips over it.

        ;If can be fancy, a hold -> Scroll faster Would be nice.

    @skip_UD:
.endmacro

.macro Check_Init_Song

    bit Pressed_Button
    bpl skip_A ;A_Button

        lda #$80
        sta Silence_APU_Flag ;Clear when Set.

        lda Track_Index
        jsr Song_Init

        jsr Update_Now_Playing

    skip_A:

    bit Pressed_Button
    bvc @skip_B

        asl Silence_APU_Flag ;Clear Flag.

    @skip_B:


.endmacro 

nmi:
    .if Debugging_Enabled
        

        lda Spinning_Flag
        beq @skip

            Runtime_Exception "Runtime Exception: Frame Overrun. NMI fired before the previous frame finished. Debug the code that hung."
        
        @skip:
        lda #$01
        sta Spinning_Flag
    .endif

    Inline Update_Selected_Track
    Inline Check_Init_Song

    Inline Update_Displayed_Addresses

    lda #$00
    sta $2005 ;Set Scroll
    sta $2005

    lda #%000001110 ;Enable bkgrd, disable Sprites
    sta $2001

    Inline OAM_DMA_Controller_Read

    jsr Update_Music

    .if Debugging_Enabled
        lda #$00
        sta Spinning_Flag
    .endif
rti ;go back to inf-wait in reset.

 


Update_Now_Playing:
    lda #$22
    sta $2006
    lda #CURRENT_PLAYING_OFFSET ;Set PPU can't Display a Song Name.
    sta $2006

    ldx Song_ID
    bal Display_Track_Name, bpl


;Tail Call

    ;In A= Display Index (+1 of Song Index)
Update_Track_Cursor:
    ldx #$80 + TRACK_OFFSET
    lda #_TRACK__
    jsr Set_PPU_ADDR_Display_Word ;OUT X= Track Index

    ;BCD two-digit display
    txa ;lda Track_Index
    ldy #'0'-1
    @loop_div10:
        iny
        sub #10
        bcs @loop_div10


    add #'0' +10 +1, clc  ;+10 undos div 10. +1 as Display is 1-based, not 0-based
    sty $2007 ;tens
    sta $2007 ;ones


    ;Disp Track Name
    lda #__dash__
    jsr Display_Word

    ;bal Display_Track_Name, bpl
; Fall Through


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
        lda #' ' ;lda tile ID of space.
        @loop_clr: ;Clear a bit of space so old names don't stick around.
            sta $2007
            dey 
            bne @loop_clr
rts


    ;In X= Low Byte
    ;   Y= High Byte ;Optionally Hardcoded $21

    ; A= UI_Word 
Set_PPU_ADDR_Display_Word:
    ldy #$21
    Set_16bit_PPU_ADDR_Display_Word:
        ;In Y= High Byte.
            ;Set to #$21 w/ jsr Set_PPU_ADDR_Display_Word
    sty $2006
        ;In X= Low Byte
    stx $2006
    ; jmp Display_Word

; Fall Through

;In A= UI_Word 
Display_Word:
    ;and #$7f
    tax ;Trashes Track_Index

    @loop_word:
        inx ;pre-inx
        lda LUT_Words_Text -1 -$80,x 
            pha

            and #$7f ;Confine ASCII Tile Range
        sta $2007

            pla ;Not required by Hardware. Mesen Doesn't mirror though.
        bpl @loop_word


    @rts:
ldx Track_Index ;restore
rts
;OUT X= Track Index
;    NFlag = ldx 




LUT_Addr_Possitions:
    .byte $65,  $71,  $a5,  $ea,  $b1

LUT_Addr_Words:
    .byte _Sq0, _Sq1, _Tri, _Noi, _DMC

LUT_Hex_Tiles:
    .byte "0123456789abcdef"
