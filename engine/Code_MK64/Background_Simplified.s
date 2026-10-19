



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
        cmp #Max_Track_Index+1 ;+1 for after end. +2 cuz Display is 1-Based
        bcs @down ;dec to cancel inc

        jsr Update_Track_Cursor ;Not Inline. No point when a beq skips over it.

        ;If can be fancy, a hold -> Scroll faster Would be nice.

    @skip_UD:

    lda Pressed_Button
    and #select+start
    beq @skip_SS


        lda Track_Index
        cmp #3 ;Raceway
        bcc @skip_play_SFX  ;play buzzer sfx?

        cmp #14 +1 ;Star
        bcs @skip_play_SFX


            lda #$03 -1 ;Lap_3.  (!= 0 = Lap 3.  = 2 Displays as 3.)
            bal MK64_Start_Song, bne


        @skip_play_SFX:
        ;A buzzer sfx?  Can use Noise Alt Timbre. 
            ;And "AH- AH" with a rest could be perfect. Requires SFX Engine Re-write to V2 idea 


    @skip_SS:

    bit Pressed_Button
    bpl skip_A ;A_Button

        lda #$01 -1  ;Lap_1
        MK64_Start_Song:
        sta Lap_3_Flag

        lda #$04
        sta Music_Speed_Up_Timer
        ;sta Music_Slow_Down_Timer ;YV and Star

        lda Track_Index
        jsr Song_Init

        jsr Update_Now_Playing

    skip_A:

    bit Pressed_Button
    bvc @skip_B ;B_Button

        lda #Song_Silence_Index
        jsr Song_Init

    @skip_B:

    lda #$00
    sta $2005 ;Set Scroll
    sta $2005

    Inline OAM_DMA_Controller_Read

    jsr Update_Music

    Inline Update_Music_if_Lap_3
rti ;go back to inf-wait in reset.




Update_Now_Playing:
    lda #$22
    sta $2006
    lda #$06 ;Set PPU isn't flexible enough. Also, more space desired.
    sta $2006

    ;Display Lap 1 / Lap 3 or Blank it.
    lda Song_ID
    cmp #3 ;Raceway
    bcc @clr_7

    cmp #14 +1 ;Star
    bcs @clr_7

            lda #_LAP__ ;No PPU needed. Right after Track xx Lap x
            jsr Display_Word

            ldy Lap_3_Flag ;is 0 or 2
            inyn 2
            sty $2007 ;sty _1 or _3 

            lda #__dash__
            jsr Display_Word
            bal @skip_else, bpl 

        @clr_7:
        ldy #$08
        jsr Clear_Y_Tiles

    @skip_else:
    ldx Song_ID
    bal Display_Track_Name, bpl ; ;Tail Call



    ;In A= Display Index (+1 of Song Index)
Update_Track_Cursor:
    ldx #$83
    lda #_TRACK__
    jsr Set_PPU_ADDR_Display_Word ;OUT X= Track Index


    ;BCD two-digit display
    inx ;to display as 1-based
    txa ;lda Track_Index
    ldy #0
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

            and #$1f ;Confine Tile Range
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

Text_Data:


    LUT_Name_Start_Indexes:
        .byte TITLE              - LUT_Song_Names_Text
        .byte MENU               - LUT_Song_Names_Text

        .byte RACE_START         - LUT_Song_Names_Text

        .byte RACEWAY            - LUT_Song_Names_Text
        .byte YOSHI_VALLEY       - LUT_Song_Names_Text
        .byte KOOPA_BEACH        - LUT_Song_Names_Text
        .byte KALAMARI_DESERT    - LUT_Song_Names_Text

        .byte TOADS_TURNPIKE     - LUT_Song_Names_Text
        .byte FRAPPE_SNOWLAND    - LUT_Song_Names_Text
        .byte CHOCO_MOUNTAIN     - LUT_Song_Names_Text

        .byte BOWSERS_CASTLE     - LUT_Song_Names_Text

        .byte DKS_JUNGLE_PARKWAY - LUT_Song_Names_Text
        .byte BANSHEE_BOARDWALK  - LUT_Song_Names_Text
        .byte RAINBOW_ROAD       - LUT_Song_Names_Text

        .byte STAR_POWER         - LUT_Song_Names_Text

        .byte FINISH_WIN         - LUT_Song_Names_Text
        .byte FINISH_OK          - LUT_Song_Names_Text
        .byte RACE_RESULTS       - LUT_Song_Names_Text
        .byte AWARD_WIN          - LUT_Song_Names_Text
        

        .byte FINISH_LOSE        - LUT_Song_Names_Text
        .byte AWARD_LOSE         - LUT_Song_Names_Text


        .byte BATTLE_START       - LUT_Song_Names_Text
        .byte BATTLE             - LUT_Song_Names_Text
        .byte BATTLE_RESULTS     - LUT_Song_Names_Text

        .byte STAFF_ROLL         - LUT_Song_Names_Text

        .byte END_OF_TEXT        - LUT_Song_Names_Text

    ;

    LUT_Words_Text:

        _RACE .set (*-LUT_Words_Text)|$80
        .byte _R, _A, _C, _E|$80

        _STAR .set (*-LUT_Words_Text)|$80
            .byte _S, _T;, _A, _R|$80
            _AR .set (*-LUT_Words_Text)|$80
            .byte _A, _R|$80

        _BATTLE .set (*-LUT_Words_Text)|$80
            .byte _B, _A, _T, _T;, _L, _E|$80
            _LE .set (*-LUT_Words_Text)|$80
            .byte _L, _E|$80


        _WIN .set (*-LUT_Words_Text)|$80
            .byte _W;, _I, _N|$80
            _IN .set (*-LUT_Words_Text)|$80
            .byte _I, _N|$80


        _LOSE .set (*-LUT_Words_Text)|$80
            .byte _L, _O;, _S, _E|$80
            _SE .set (*-LUT_Words_Text)|$80
            .byte _S, _E|$80

        _RESULTS .set (*-LUT_Words_Text)|$80
        .byte _R, _E, _S, _U, _L, _T, _S|$80



        _AWARD__ .set (*-LUT_Words_Text)|$80
            .byte _A, _W, _A, _R, _D;, _spc|$80
            _Blank_Word .set (*-LUT_Words_Text)|$80
            .byte _spc|$80

        _FINISH__ .set (*-LUT_Words_Text)|$80
        .byte _F, _I, _N, _I, _S, _H, _spc|$80

        _MOO__ .set (*-LUT_Words_Text)|$80 ;YV
            .byte _M, _O;, _O, _spc|$80
            _O__ .set (*-LUT_Words_Text)|$80
            .byte _O, _spc|$80

        _OOPA__ .set (*-LUT_Words_Text)|$80 ;KTB
        .byte _O, _O, _P, _A, _spc|$80


        _OAD .set (*-LUT_Words_Text)|$80
        .byte _O, _A, _D|$80

        _SHE .set (*-LUT_Words_Text)|$80 ;FS / BB
        .byte _S, _H, _E|$80

        _WAY .set (*-LUT_Words_Text)|$80
            .byte _W, _A, _Y|$80 ;<- The only Y

        _BOW .set (*-LUT_Words_Text)|$80
            .byte _B;, _O, _W|$80
            _OW .set (*-LUT_Words_Text)|$80
            .byte _O, _W|$80


        _apo_S__ .set (*-LUT_Words_Text)|$80
        .byte _apo_S, _spc|$80


        ;8-bit type, that are lda #_Word

            _LAP__ .set (*-LUT_Words_Text)|$80
            .byte _L, _A, _P, _spc|$80

            __dash__ .set (*-LUT_Words_Text)|$80
            .byte _spc, _dash, _spc|$80

            _CURRENT_TRACK__ .set (*-LUT_Words_Text)|$80
                .byte _C, _U, _R, _R, _E, _N, _T, _spc

                _TRACK__ .set (*-LUT_Words_Text)|$80
                .byte _T, _R, _A, _C, _K, _spc|$80

            ; _ALBUM__ .set (*-LUT_Words_Text)|$80
            ; .byte _A, _L, _B, _U, _M _spc, $00



            _LOGO .set (*-LUT_Words_Text)|$80
                .byte _T, _R, _I, _dash, _P, _U, _L, _S, _E, _spc
                .byte _S, _T, _U, _D, _I, _O, _S|$80
            _LOGO_pt_2 .set (*-LUT_Words_Text)|$80
                .byte _M, _K, 6+1, 4+1, _spc, _I, _N, _spc, 8+1, _K, _B|$80
                ;Tri-Pulse Studios  MK64 in 8KB


        .assert (*-LUT_Words_Text <= $80), error, "bit 7 type for Word_LUT limit exceeded."
    ;


    LUT_Song_Names_Text:

        TITLE:
        .byte _T, _I, _T, _LE
        MENU:
        .byte _M, _E, _N, _U

        RACE_START:
        .byte _RACE, _spc, _STAR, _T

        RACEWAY:
        .byte _RACE, _WAY ;<- Y can be removed easily.
        ;.byte _C, _I, _R, _C, _U, _I, _T  ;_RACE to _RACE__ only makes this cost One Byte.

        YOSHI_VALLEY:
        .byte _MOO__, _MOO__, _F, _AR, _M
        ;.byte _Y, _O, _S, _H, _I, _spc, _V, _A, _L, _L, _E, _Y ;Used V, and Y
        KOOPA_BEACH:
        .byte _K, _OOPA__, _T, _R, _OOPA__, _B, _E, _A, _C, _H
        KALAMARI_DESERT:
        .byte _K, _A, _L, _A, _M, _AR, _I, _spc, _D, _E, _SE, _R, _T

        TOADS_TURNPIKE:
        .byte _T, _OAD, _apo_S__, _T, _U, _R, _N, _P, _I, _K, _E
        FRAPPE_SNOWLAND:
        ;.byte _F, _R, _A, _P, _P, _E, _spc, _S, _N, _O, _W, _L, _A, _N, _D
        .byte _SHE, _R, _B, _E, _T, _spc, _L, _A, _N, _D

        CHOCO_MOUNTAIN:
        .byte _C, _H, _O, _C, _O__, _M, _O, _U, _N, _T, _A, _IN

        BOWSERS_CASTLE:
        .byte _BOW, _SE, _R, _apo_S__, _C, _A, _S, _T, _LE

        DKS_JUNGLE_PARKWAY:
        .byte _D, _K, _apo_S__, _P, _AR, _K, _WAY   ;_C, _O, _U, _R, _SE
        BANSHEE_BOARDWALK:
        .byte _B, _A, _N, _SHE, _E, _spc, _B, _O, _AR, _D, _W, _A, _L, _K
        RAINBOW_ROAD:
        .byte _R, _A, _IN, _BOW, _spc, _R, _OAD


        STAR_POWER:
        .byte _STAR, _spc, _P, _OW, _E, _R


        FINISH_WIN:
        .byte _FINISH__, _WIN
        FINISH_OK:
        .byte _FINISH__, _O, _K 
        RACE_RESULTS:
        .byte _RACE, _spc, _RESULTS
        AWARD_WIN:
        .byte _AWARD__, _WIN



        FINISH_LOSE:
        .byte _FINISH__, _LOSE
        AWARD_LOSE:
        .byte _AWARD__, _LOSE



        BATTLE_START:
        .byte _BATTLE, _spc, _STAR, _T
        BATTLE:
        .byte _BATTLE
        BATTLE_RESULTS:
        .byte _BATTLE, _spc, _RESULTS


        STAFF_ROLL:
        .byte _S, _T, _A, _F, _F, _spc, _R, _O, _L, _L

        END_OF_TEXT:
        .assert END_OF_TEXT - LUT_Song_Names_Text <= $100, error, "Text Does Not fit in a Page"
    ;

    ;

;

;
