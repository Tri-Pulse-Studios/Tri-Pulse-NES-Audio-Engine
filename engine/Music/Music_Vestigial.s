
    ; .macro Update_Music_Impl_V1 ;Original 

    ;     lda APU_Channel_Enable
    ;     ora #$0f
    ;     sta APU_Channel_Enable ;Enable NT10. Leave DMC unchanged.
    ;             ;This is handled in DMC_Update_Regs
    ;             ;It alone is not enough though

    ;     ldx #$0c ;39B
    ;     Noise:
    ;         jsr Common_Tasks

    ;             ;Update Volume is through SFX
    ;         jsr Noise_Update_Regs  ;508cc
    ;     ;



    ;     ldx #$08 ;Loop Tri,Sq1,Sq0
    ;     Loop_Tri_Sq:

    ;         jsr Common_Tasks
    ;         jsr Update_Volume ;81 / 79

    ;         jsr Update_Sweep ;Not Inline b/c Tail-cails to Note_Conditional_Write_Period_High
    ;         jsr Sq_Tri_Update_Regs  ;292 / 144 / 144

    ;     dexn 4
    ;     bpl Loop_Tri_Sq


        


    ;     ldx #$10
    ;     DMC:
    ;         jsr Common_Tasks
    ;         jsr Update_Volume ;81
                

    ;         jsr DMC_Update_Regs
    ;     ;

    ; .endmacro 




;Channel Kalamari_Desert_Noise ;v3 for 8/16 
    ; Noise_Header ::Kalamari_Desert_NB

        ;This save 10b here.
            ;Est Cost to other channels in minimum 13b
                ;6 dhf's, 7 whl's.
                ;Some probs riffable, but also the  Dur _8x6


    ; _1:
    ;     Duration _8x1,   Train_Hi,rest,  Hat_4,    Train_Lo ;Costs 5b to swap Hat_4 -> Shaker_2
    ;     Duration "Cont", Train_Hi,rest,  Train_Hi, Hat_4

    ;     _2:
    ;     Riff _1, _2
    ;     Repeat "2b", 34 ;8b

    ; ;

    ; _19:
    ;         Duration _8x1,   Train_Hi,rest,  Shaker_2, Train_Lo
    ;         Duration "Cont", Train_Hi,rest,  Train_Hi, Shaker_2 
        
    ;         Duration _1111,  Train_Hi,rest,  Shaker_2, Train_Lo

    ;     _19_7:
    ;     Riff _35_3, _35_5 ;32nds

    ;     _20:
    ;         Riff _19, _19_7
    ;     Duration _1111,  Train_Hi,Shaker_2, Train_Hi, Shaker_2

    ; _21: ;15\23b

    ; Riff _19, _21
    ; Repeat "2b", 5

    ; ;33
    ; Riff _20, _21 ;Backwards
    ; Riff _19, _20 

    ; _35: ;7\30b

    ;         Riff _35_3, 3
    ;     Duration "Cont",     Shaker_2,Shaker_2, Train_Lo,Shaker_2

    ;     _35_3:
    ;         Duration _8x0,   Train_Hi,Shaker_2, Shaker_2,Shaker_2
    ;     Duration     "Cont", Train_Hi,Shaker_2, Shaker_2,Shaker_2 ;9b


    ; _35_5:

    ; Riff _35, _35_5
    ; Repeat "2b", 2 ;52b, excluding headers. A 10x Increase in size from V1

;Loop Kalamari_Desert_Noise




;Channel Kalamari_Desert_Noise ;V1
    ; Noise_Header ::Kalamari_Desert_NB

    ; Duration _8x0,   Train_Hi,rest,  Shaker_2, Train_Lo
    ; Duration "Cont", Train_Hi,rest,  Train_Hi, Shaker_2 

;Loop Kalamari_Desert_Noise

    ;Noise V2

   



;Conditional_Jmp
    ; tya ;bit zero 0 of Y w/ bit zero of If_Alt Flag
    ; eor Alt_If_Flag,x
    ;
    ; lsr ;-> C
    ; bcs Riff_Jmp_To  ;lda (data,x). sta data,x, rts
    ;
    ; rts

    ;     ;Unconditional_Jmp Can just beline to it.
   ;A 2-byte Instruction, Like a Riff, just w/ no Auto-Return.   3 $f- slots do it all: jmp, jne, jeq  (Unconditional is for If/Else blocks using external signals to ensure consistant playback.)
;




If_Alt_Stores_Delta:
    tay
    bne @skip
    
        inc Alt_If_Flag,x ;inc toggles bit 0. The other 7 bits are ignored.
        @rts:
        rts

    @skip:
    lda Alt_If_Flag,x
    lsr
    bcs @rts

        sty If_Alt_Delta
        jmp New_Note_w_If_Alt_Delta

    ; Give the next instruction's opperands an alternate version.
    ;     Select one via the flag toggle-able w/ $70
    ;         Used for two channels playing the same melody-harmony.

;
    
        ;Alt Apply damped (Divisor Based)

        ; lda Music_Fadeout
        ; add {Note_Volume_Damped,x}



    ;Fixed_Damping  (This is faaar simpler, runs in fixed time, and for MK64, is enough.)
        ; lda Note_Volume,x
        ; sub {Note_Volume_Damped,x}
        ; bcs @skip

        ; @underflowed:
        ; and #$0f ;Underflowed. Mute.

        ; @skip:
        ; rts

Vibrato_Delay_Factor_by_BPM:
    eor LUT_Env_AT_Init,y ;---- II -- ;Vibrato Delay
    lsrn 2
    tay ;Vibrato Delay Factor


    lda Eighth_Length
    asln 2 ;hlf

    @loop:
    lsr
    dey
    bpl @loop ;Out: qtr, 8th, >16th, >>32nd

    eor #$ff
    sta Vibrato_Delay,x
rts

Vibrato_Delay_by_LUT:
    eor LUT_Env_AT_Init,y ;---- II -- ;Vibrato Delay
    tay
    lsrn 2
    lda LUT_Vibrato_Delays,y
rts
LUT_Vibrato_Delays:
.byte <~0, <~8, <~16, <~28


List_of_Songs_per_Cup:
    ; LUT_Course_to_Song_Index:
    ;     .byte Raceway_Index
    ;     .byte Yoshi_Valley_Index ;Moo Moo Farm
    ;     .byte Koopa_Beach_Index 
    ;     .byte Kalamari_Desert_Index

    ;     .byte Toads_Turnpike_Index
    ;     .byte Frappe_Snowland_Index
    ;     .byte Choco_Mountain_Index
    ;     .byte Raceway_Index

    ;     .byte Raceway_Index
    ;     .byte Frappe_Snowland_Index
    ;     .byte Raceway_Index
    ;     .byte Bowsers_Castle_Index

    ;     .byte DKs_Jungle_Parkway_Index
    ;     .byte Yoshi_Valley_Index
    ;     .byte $ff ;.byte Banshee_Boardwalk_Index
    ;     .byte Rainbow_Road_Index




    ;Call Long (Different Page) Idea needs this: On return to root layer (annoying to test) always set page to default (annoying to fetch. Store in RAM?)

        ;lsr Riff_Page,x
        ;beq @Loop_Song
        ;bcc @Preserve_High_Byte

        ;Fetch High Byte

        ;@Preserve_High_Byte

        ;Could also track this via a single byte. (Which can also double as calculating riff depth? PITA tho...)
            ;When returning, lsr it. Pulled a 1? Also return to Default Page
                ;Made it Zero? Reset Channel. 
                    ;Also makes it real cheap to have an Intro Phrase.
                        ;

                ;When reading max depth, I just care if = 1
                    ;Finding Y index though is... annoying. 


        ;Song Green_Brinstar, $0d, Vol_7,hlf ;6-7

        ;Song Schala, $16 ;11-11

        ;Song Khevari, $0c ;6-6


        ;[IDEA] Can have all 5 Page numbers in a single byte
            ;.byte $abcd xxxx
                ;x= 0-f page of dmc
                ;abcd, if 1, indicate the next channel is on the next page.
                    ;Requires a LOT more padding data though.
;


;OLD

    ;In A=Song ID
    OLDSong_Init:
    
    tay 

    lda LUT_Song_Headers_Low,y
    sta irq_tmp_2
    lda LUT_Song_Headers_Hi,y
    sta irq_tmp_3


    ldx #$03;BPM_Header_Size
    ldy #$00
    @Loop:
    lda (irq_tmp_2),y
    iny
    sta Eighth_Length,x ;Loops All Rate Data (Does Triplets first, cuz they can be garbage data if unusued.)
    dex
    bpl @Loop

    
    ldx #$10 
    @Loop2:
    lda #$08
    sta APU_Sweep,x ;Disable Sweep (Tri And Noise are unused here.)
        ;[WARN] This is DMC Direct Load. Could make Popping.

    lda (irq_tmp_2),y
    iny
    sta Loop_Return_To,x ;Loop Location

    lda (irq_tmp_2),y
    iny
    sta Note_Data_High,x

    phy
    jsr Reset_Channel
    ply

    dex ;-4
    dex
    dex
    dex
    bpl @Loop2

    rts


;


;$70- Instruction
; If_Else_Instruction:
    tay 
    beq @Pitch__Respect__Key_Signature  

    eor Alt_If_Flag,x ; 0 or 1
    lsr 
    beq @Toggle_Flag

    bcc @Match

        @Else: ;Read all the other bytes. 
        inc Note_Data,x
        rts

    @Match: 
        lda (Note_Data,x)
        sta irq_tmp_3 ;Read The one Byte

        
        
        tya

        lsr
        add {Note_Data,x} ;Advance Past Else Block
        sta Note_Data,x

        lda irq_tmp_3
        @Prep_Hardcode_Instruction:
        jsr Normal_Instruction_Formatting
        jmp Music_Dynamic_Jump
    ;End_If




        ;Toggle flag saves 3-bytes of code not having to lda Alt_If_Flag

    @Toggle_Flag:
    rol ;A=0  ;C = ~Alt_If_Flag
    sta Alt_If_Flag,x
    rts  ;37b


    ;F-effect like thing for MK64's habit of notes being 1-pitch off cuz scales alternate half-whole steps
    @Pitch__Respect__Key_Signature:
    lda (Note_Data,x)
    inc Note_Data,x

    sub {Alt_If_Flag,x} ;One or the other Has higher pitch.
    jmp @Prep_Hardcode_Instruction
        ;48b

        ;The Above and Flag toggle can easily be Two $f-  commands if I have to drop the If/Else command.




    ; $70 is a wierd exception, its more like one of the Misc $F- Commands, 
    ; but it uses the $7- flag, so I put it here. 

    ; $71 swaps the Conditional flag for branching. (Think Sec/Clc) 

    ; $72-$7f does: 
        ; bcc 

            ; ;One Byte Command 
            ; bcs skip_else 

        ; ;N Bytes 
        ; skip_else: 

    ; Where $7x 
        ;x = %NNNC
            ;N = Number of Bytes in Else block (If block always has exactly 1)
            ;C = Condition  (Swaps bcc / bcs)
;
    ;Kinda too complicated.




ALT_Compressed_Song_Init:
    ;sta Song_Pointer ;1-ABS Byte.
    tay
    lda LUT_Song_Header,y
    sta Eighth_Length



    lda LUT_Song_Header+1,y ;+2
    sta tmp_3 ;Low bits irrelevant.

    and #$0f
    ;add #<All_Songs_Data ;Hi
        ;Stick at the front of the 

    ldx #$10
    @loop:
    sta Note_Data_High,x 

    iny
    lda LUT_Song_Header+2,y ;+1
    sta Note_Data,x


    phy ;Probably not needed.
    jsr Reset_Channel
    ply

    lda #$08
    sta APU_Sweep,x ;Disable Square's Sweep (Tri And Noise are unused here.)
        ;[WARN] This is DMC Direct Load. Could make Popping.
        ;In INIT b/c SFX may actually use it. 

    lda Note_Data_High,x
    asl tmp_3 ;[WARN] Low scratch. (Name it til rts of Init Channel) 
    adc #$00 ;inc if sec

    dexn 4
    bpl @loop
    rts



    ALT_LUT_Song_Header: ;Format
    ; .byte $8th_length

    ;.byte %abcd xxxx
    ;abcd, 1 if this channel is on the next page. (sq0 is always last in ROM. )
    ;xxxx 0-f page of dmc
        ;[NOTE] Fitting these into pages is harder when I squash this data.
            ;tldr, I need a lot more filler data, because the order of each songs data is pre-determined. 
            ;Likely could weave smaller songs through, but it'll be a bitch to figure out. 
                ;Saves est. 30 Bytes (Costs 10 Bytes Code, 10 songs use 40 Bytes less data.)

        ;To go all in, I could swap the RAM of dmc and Noise. Then dmc and tri can share a page w/o having to squeeze in Noise too.
            ;For the most part, they each do their own seperate thing

    ; .byte $dmc, $noise, $tri, $sq1, $sq0
    ;ptr Low
;



;Goal:
;Input One or Two bytes, and it plays the whole 3-12 bytes of the arpeggio up or down, or both the scale.

;Least RAM would be to re-use the Base Pitch to store things in. On the ones going one way I'd probs want to have it return to base.

;Probably simpler to just store it seperately. 

;Length: Could hard-code to 8th. Could also allow picking 16th, 8th, and maybe 4th, but mostly 16th for things like bosses.


;IDEA:
;Arpeggios assume they go Up. 
;It goes down, only if there are two arpeggios in a row. (The second one sees the last thing was an arpeggio, and just picks up where it left of.)
    ;The defualt is, Read a new Note thats an actual Note? Clear Arpegio Base offset. 
    ;Reading an Arpegio w/ a base Offset already set? Presume its negetive.


;To get the 7 or 4 notes up, can do $A2/$AA to do the note 12 Up / 24 Up  (12 up is pointless tho.)





;Ax, x = even (lsr, bcc) -> One byte Arpeggio. Up 3 or 6 notes. Fixed Anchor for Base Pitch.

;Odds



Arpeggios_Init:


and #$03
lsr
tay

lda LUT_Arpeggio_Inits,y
sta Arpeggio_Timer,x

lda #$00
sta Arpeggio_Index,x

jmp New_Note


LUT_Arpeggio_Inits:
;No Down,  W/ Down
.byte $40, $c0 ;Long
.byte $08, $88 ;Short

; .byte $06, $86
; .byte $03, $83 


;If equal, carry clear: No Arpeggio
;If Not Equal, carry clear; Next Step Arpeggio
;If Not Equal, Carry Set; Init Down half.
    ;equal, carry set; Treat like no arpeggio, but first inc note_timer


; lsr Arpeggio_Timer,x
; jne Update_Arpeggio
Update_Arpeggio:
bcc @skip

@Init_Down_Half:
asl Arpeggio_Index,x
sec ;ora #$80 ;+5cc, -1Byte
ror Arpeggio_Index,x

lsr Arpeggio_Timer,x
bne @skip ;I THINK that the short one happens to sync up so it works right w/o further loads. 

lda #$20 ;$40 lsr
sta Arpeggio_Timer,x

@skip:


Arpeggio_Update:
lda Eighth_Length ;HardCode.
sta Note_Timer,x

dec Note_Data,x 
lda (Note_Data,x) ;Keeps re-reading this byte.
inc Note_Data,x

and #%1001 ;Works out this is where the data is.
sta irq_tmp_0
 
add {Arpeggio_Index,x}

    bpl @inc
    dec Arpeggio_Index,x
    jmp @skip_inc

    @inc:
    inc Arpeggio_Index,x
    @skip_inc:

and #$7f
tay
lda LUT_Arpeggio_Shifts,y

ldy irq_tmp_0
sub {LUT_Arpeggio_Shifts,y} ;Data is cummulative w/ overlap.
add #$01 ;Notes epects the base note to be -1
pha ;DEBUG, same as the Normal Pitches
jmp Argpeggio_Compute_Pitch
;A = Shift to add to Base Pitch.





LUT_Arpeggio_Shifts: ;read table -1
;actually seen:

;5,4,3
;4,3,5
;5,3,4
;3,4,5 ;Only once it seems.

;5,4,3 that doesn't play along: idx 9
.byte 0,3,7,12,15,19,24,27 ;3,4,5
;.byte +3,4,9, 12,16,21,24, ;4,5,3

.byte 0,4,7,12,16,19,24,28 ;4,3,5
;.byte -4,3,5, 4, 3, 5, 4

; .byte 0,3,8,12,15,20,24,27 ;3,5,4
; ;.byte +3,5, 9,12,17,21,24 +3 ;5.4.3

;If I make the code add 12 if the timer is over 3, then I can half the table again by just storing the cumulative 



;.byte 0,5,10,12,17,22,24,29 ;5,5,2 idx 16 (for boey base)
                             ;5,2,5 idx 17



End_Arpeggios:










Misc_FXs:

    @Init_Sweep: ;Sweep resets w/ the Env-Reset.
    sta Sweep_Speed,x
    rts


    @Inc_Vol:
        dec Note_Volume_Damped,x
        bpl @rts

        lda #$00
        sta Note_Volume_Damped,x
    rts

    @Dec_Vol:
        inc Note_Volume_Damped,x ;increase dampen.
    rts




    .byte <(@Slow_Fade_Out - 1) ; $f3
    .byte <(@rts           - 1) ; $f6
    .byte <(@Note_Bend     - 1) ; $f7

    .byte <(@Note_Bend     - 1) ; $f8
    
    .byte <(@Inc_Vol       - 1) ; $fa
    .byte <(@Dec_Vol       - 1) ; $fb

        Inc_Vol = $fa
        Dec_Vol = $fb
    .byte $ff, $ff ;Using Immediate sbcs.

        Bend_Shallow = $f7
        Bend_Steep = $f8
    .byte $04, $08 ;Bend Speeds

    @Init_Sweep_Note: ;<- Except 
        lda #$01
        sta No_Reset_Env_Flag
            ;This isn't right...
                ;More like set it to $80, cuz it just needs to not Reset part of it?
                ;Otherwise, Env with a Cutoff won't function (Kinda like issue w/ NoResetEnv to begin with.)

    ;     lda (Note_Data,x)  ;Init Volume starts almost idendically.
    ;     inc Note_Data,x

    ;     pha
    ;         and #$07
    ;         tay

    ;     pla
            ; lsrn 3
            ; cmp #$08
            ; bcc @pos

            ; ora #$f0 ;neg

            ; @pos:
            ; sta Sweep_Speed,x

    
        ; lda #$00

        ; @loop:
        ; add Eighth_Length
        ; dey
        ; bpl @loop
        ;sta Note_Timer,x ;just a copy of the Note Instruction.

        ; plp
        ; plp
        ; rts


    @Note_Bend: ;[Note] is affected by Octave Shifts. 
    sta Sweep_Speed,x ;[NOTE] Overwrite, not add?
    sta No_Reset_Env_Flag ;Non-Zero = Don't Reset

    lda Eighth_Length ;Hardcoded lasts an extra 8th.
    sta Note_Timer,x
    
    @plp_rts:
    plp
    plp ;Clear rts -> New_Note

    @rts:
    rts
        ;Can be a single, 2-byte Instruction.
            ;$f-, %F XXX YYYY
            ;(X+1)*8th = Duration of Bend 
            ;Y = 8 to -7 2's comp strength.     

            ;F a flag of whether or not to reset env + init new pitch (As it would for a new note that bends the whole time.)
                ;TLDR, If Pre-Note or Note-Extension.


    @Slow_Fade_Out:
    lda Note_Volume,x ;This lasts Sus_Volume-1 * Eighth Length 8 2
    sub #$10
    sta Note_Volume,x

    and #$f0
    beq @rts ;Once silenced, read next instruction

        sta No_Reset_Env_Flag ;Over-ride
        ;Still Playing? Clear rts -> New_Note
        plp
        plp
        dec Note_Data,x ;Re-read $f3 again

        lda Eighth_Length
        sta Note_Timer,x ;-1 Volume per 8th

    rts 
        ;Replace this with the Fade-Out via div8 





Update_Sweep:
    lda Sweep_Speed,x
    beq @rts ;2b saves  ~30/cc every frame.

        add {Note_Period_Low,x} ;2's comp
        sta Note_Period_Low,x

        bvc @rts

            bpl @dec

            @inc:
                inc Note_Period_High,x
                jmp Note_Conditional_Write_Period_High ;Tail-Call

            @dec:
                dec Note_Period_High,x
                jmp Note_Conditional_Write_Period_High ;Tail-Call

    @rts:
rts 








;Old Volume:



lda Note_Volume,x
and #$3f

ldy Note_Volume_Damped,x
beq @skip
bpl @Boosted ;$00 x1, $80 x0.5, $01 x1.5, $81 x0.75 (bmi Tells Tri to halve volume. Which also lower's Noise's volume.)
                ;The flat saw can still be compabable w/ this. Its cycle-neutral. (the 2-1 can just do an extra 1,0)

lsr ;x0.5

@Boosted:

sta irq_tmp_0 ;x1.5
lsr
adc irq_tmp_0 ;Rounds Up 0.75 to 1.0 when truncating.

cmp #$3f
bcc @skip
lda #$3f ;Clamp


@skip:
lsrn 2 ;stored as x4 for resolution.

ora Note_Duty,x
sta APU_Volume,x


;Only a single decay value, not 2.
    ;Duty Still Swaps on Sustain.

SIMPLER_Update_Volume:
ldy Note_Env_ID,x
lda LUT_Env_Decay_Rate,y
and #$07 ;Release_Time

cmp Note_Timer,x
bcs @Released


eor LUT_Env_Decay_Rate,y
;and #$f8

asr ;Decay Can Only Lower Volume
add {Note_Volume,x}
bcc @Released ;Underflowed.

cmp LUT_Env_Sustain,y
bcc @Not_Sustained ;It assumes I'm subtracting a negetive

lda LUT_Env_Sustain,y

@Not_Sustained:
sta Note_Volume,x

@rts:
rts


@Released:
lda #$01
sta Note_Volume,x
rts ;43 Bytes. 



;;Ideas to impliment:
    ;MM echoed notes in one channel: 
        ;Make a byte that says, when this note ends, DONT reset its envelope data.
            ;Lets very long sustain hold notes exist
            ;Lets changing the pitch w/o interupting envelope or vibrato.

    ;Repeate previous x bytes Y times.
        ;say I have 
        ;call-, $--
        ;repeat, %yyyy yxxx 
            ;repeats cannot nest, but a repeat can nest a call. 
                ;(inc a counter each time its seen til the counter matches the operand. It'll let it pass  once they equal (and reset counter), if not, branch back the other operand)
                ;repeat is rare enough it'll need a specific whole byte. call needs 13 bits of opperand to function. repeat doesn't.
                    ;repeat could be the %1--- 0000 of Call, since the asl would briefly be 0 before adc #$00
            ;python of it is fairly simple. When building the final string, see if something it listed 4+ times in a row (or that a short pattern is.)
                ;Do that twice: Once for patterns of channels. (Again, x4 minimum)
                ;And again at the end to catch stray repeated small seqences. (can do an lcp setup on the final byte string. if any lcps of 4+ exist, check if the are conseqetive, and that the whole small seqence repeats x4)
                   
                    ;An idea to layer on top of is, repeat, w/ alternating minor change. 
                        ;Basically, a normal repeat, $xx w/ a alt, $xx 
                            ;alt mod 2s the repeat counter, skip like a branch not taken. If odd, it acts like call, but also branches forward on return.

    ;Speed Change?
    ;Format, $F-, $xx Set 8th Length to $xx
    ;Now that I have only the 8th note stored (I'm ignoring the special types.)
        ;It isn't unreasonable to change the tempo.
            ;As a global thing, may as well stick it in Noise. 
            ;I do have to be REEEEAL careful to sync everything up though. 
        


;[IDEA] Save $F- Instructions.
    ; Song_Volume_Deltas = $5f0 ;Its a Song Global
    ; ;ALT, uses only 1 $F- Command slot instead of 3

    ; @Delta_Modulate_Volume_Dampen:
    ; ldy Note_Volume_Damped,x

    ; lda Song_Volume_Deltas ;rotate 8 bits in place. SEC if inc
    ; lsr
    ; ror Song_Volume_Deltas
    ; bcs @Next

    ; iny ;Prev is +1

    ; @Next:

    ; lda @LUT_Next,y
    ; sta Note_Volume_Damped,x

    ; rts

    ; @LUT_Next:
    ; .byte $01, $02, $00, $01 ;Last 1 is for Prev

    ; @Song_Init: ;Changes to Song_Init: (Skip if 2-commands, not 3.)
    ; ;In A= Song ID
    ; tay
    ; ;lda LUT_Song_Volume_Deltas,y
    ; sta Song_Volume_Deltas

    ; @Update_APU_regs: ;Changes to VOlume update
    ; lda Note_Volume,x
    ; and #$3f

    ; ldy Note_Volume_Damped,x
    ; ;beq @Vol_15
    ; dey ;<- Only Addittion
    ; ;beq @Vol_7

    ; ;@Vol_11
    ; sta irq_tmp_0 ;x1.5
    ; lsr
    ; adc irq_tmp_0 ;Round Up.

    ; ;w/o @Vol_23, don't need to clamp.

    ; @Half:
    ; lsr ;x0.5 

    ; @Full:
;



;Riff Page Call Idea
    ;These are always 3-Byte instructions
    ;$dp, $yy, $xx

    ;$d= opcode
    ;p = page

    ;$yy = bytes to read

    ;$xx = point to jump to.

    ;[IDEA]
    ;In A= page to jump to. 
    Riff_Call_Page:
    add #<All_Songs_Data ;Hi
    pha

    ;jsr @Riff_Call_Long 

    pla 
    sta Note_Data_High,x
    rts ;This RELIES on the pha New_Note rts idea.

        ;Still need to have it either know when to Return to Default Page 
            ;Or have it ALWAYS return to Default Page (Meaning Sub-Calls won't work outside of page. )
;



;[IDEA] If Else block.



    .byte $80 ;If/Else cmd
    ;If
    .byte $19 ;A single byte can be here. 
    ;Else
    .byte $40,$42,$44,$47,$09 ;Same time,  ;1-7 Bytes

    ;Structure:
        ; %NNNC
        ; N = Number of Bytes in Else block 1-7 Bytes   
        ;     -If N=0, Set/Clear the flag
        ; F = Branch Condition (Flag Set/Clear)

            ;If condition is met
                ;Read the next (ignores Nibble Read mode)
            ;Else branch +1 bytes, read normally





    ;This seems impractical for Space-Saving. Even ignoring the severe restrictions, it just makes some Calls a single byte rather than two or three.
            ;It may be enough to about break even.
        
        ;However, this gives the ability for some limited dynamic music. An external source flips the flag, and the song changes. Maybe a busy Tri changes to simpler held notes.

            ;Main issue is, however, that its tricky to explain where this is useful
                ;Also, it puts a ton of extra data into a single song, straining the song size limit.

        ;I can do a Riff Call in If Block, if I hardcode check for it. jsr to it, then modify the return address with the size of the else block. 
            ;Complicates the else block tho. It has to know to skip that check. 
            ;Probably not worth it.





LUT_dmc_rates_A430_Alt:
    ;Lowest 12.5% = Midi $08
    ;Loest 25% = Midi $14

    @25: ;to Get @12.5%, just ora #$40
    ;E1-G#1
    .byte $00,$10,$01,$11,$02 ;$12(-3c) = $03(-1c)
    ;A1-D#2
    .byte $03,$13,$04,$14,$05,$15,$06 ;$16 (+3c) = $07(-5c)
    ;E2-G#2
    .byte $07,$17,$08,$18, $2b ;<- G#2 (+20c)
    ;A2-C3               ; C#3, D3, D#3
    ;                    ;-14c,-11c,+29c
    .byte $09,$19,$0a,$1a, $0b, $1b, $2d
        ; E3 , F3, F#3
        ;+11c,+14c,+17c
    .byte $0c,$1c,$2e
        ; G3, G#3, A3
        ;N/A,+14c,+17c
    .byte $18,$0d,$1d
    ;     ;/\ Octave Down

    .byte $ff ;Stp

    ;$er
    ;r = rate
    ;e = env
    ;$2- = 17-2
    ;$1- = 49-4
    ;$0- = 65-5


    LUT_dmc_addr_A430:
    ;.byte <(DMC_Sample_10_65/64), <(DMC_Sample_8_49/64), <(DMC_Sample_2_17_ALT/64) 
    ;.byte <(DMC_Sample_5_65/64), <(DMC_Sample_4_49/64),  <(DMC_Sample_1_17_ALT/64) 
    LUT_dmc_length_A430:
    .byte $04, $03, $01
    .byte $04, $03, $01
    



;






    ;IN A= Bytes in Else Block
    If_Else_OLD_Block:
    tay ;tmp

    ;lda Alt_If_Flag,x 
    beq @else
    ;@if

    lda (Note_Data,x)
    pha

    tya
    sec
    adc Note_Data,x
    sta Note_Data,x

    pla
    ;rts_Manual_Jump


    @else:
    inc Note_Data,x ;Always a single byte? 
    rts ;24 Bytes of Code for simplest functional.
;Only to help w/ Dynamic Music.
    ;It doesn't really save space.



LUT_Vibrato_Data:
    No_vib = %00

    Vib_Fast = %01<<2
    .byte $06 ;f per half-cycle
    .byte $fe-1 ;Down Spd. (Can be unequal for sfx.) Gotta be one's compliment.
    .byte $08 ;Up Spd 1.5/f

    .byte $ff ;Unusued

    Vib_Med = %10<<2
    .byte $06 ;f per half-cycle
    .byte $fe-1 ;Down Spd. (Can be unequal for sfx.) Gotta be one's compliment.
    .byte $02 ; +1.0/f

    .byte $ff ;Unusued

    Vib_Slow = %11<<2
    .byte $08 ;f per half-cycle
    .byte $fe-1 ;Down Spd. (Can be unequal for sfx.) Gotta be one's compliment.
    .byte $02 ; +0.5/f

    .byte $ff ;Unusued
        ;I can almost hardcode the values based off the ID
            ;Only saves ~10 bytes, and looses all the flexibility of a table.
    ;y = %00
    ;speed = 0.5/f ;y+1 (0.5 rounds up to 1.0 immediately on scaled 1.5* factors.)
    ;half cycle len 6f ;6-y 

    ;y = %01 
        ;No Vibrato? Kidna akward

    ;y = %10 
    ;speed = 1.5/f ;y+1
    ;len 4f        ;6-y

    ;y = %11
    ;speed = 2.0/f ;y+1
    ;len 3f         ;6-y 


    ;


Simpler_Pitch_Alt:
    ldy Vibrato_Index,x
    lda LUT_Vibrato_Data,y
    cmp #$20 ;max index
    bcs @data

    sta Vibrato_Index,x
    bcc Simpler_Pitch_Alt ;[WARN] Infitinite loop if data points to itself.

    @data:
    php

    ;jsr Scale_Vibrato_w_BP ;[NOTE] requires a 1's comp format. 

    cmp #$80 ;1's comp. $ff is Data Zero. $00 is beq Zero
    adc Note_Period_Low,x
    bcc @clc

    @sec:
    plp
    bmi @store

    lda #$ff ;add overflowed. 
    beq @store 


    @clc:
    plp
    bpl @store

    lda #$00 ;sub underflowed
    ;bmi @store
    @store:
    sta Note_Period_Low,x
rts











Fixed_Accel_Vibrato:
    ldy Note_Env_ID,x
    lda LUT_Env_Sustain,y ;%VVVV II DD ;I = Vibrato ID
    and #$0c
    beq @rts ;ID 0 means no Vibrato
    tay ;Vibrato Ptr (4 bytes each.)

    lda Vibrato_Timer,x
    inc Vibrato_Timer,x
    bmi @rts
    beq @init



    clc
    sbc @LUT_Vib_Data+1,y ;Frames
    bcc @Accel_Down

    ;can sbc, but beq means reset, then jump back up.
    sec
    sbc @LUT_Vib_Data+1,y ;Frames
    bne @Accel_Up
    bcc @stp 
    ;beq @Reset
    ;A= 0
    sta Vibrato_Timer,x

    @Accel_Up:
    lda @LUT_Vib_Data,y ;Mag
    bpl @skip


    @Accel_Down:
    lda @LUT_Vib_Data,y ;Mag
    eor #$ff


    @skip:
    ;jsr Scale_Vibrato_w_BP ;A= 1's comp

    cmp #$80 ;1's comp
    adc Sweep_Speed,x
    sta Sweep_Speed,x

    @rts:
    rts

    @init:
    lda #$0f
    adc Sweep_Speed,x
    sta Sweep_Speed,x
    rts

    @stp:
    .byte $02 ;timer should never exceed 2x base
rts




@LUT_Vib_Data:
.byte $ff,$ff,$ff,$ff
;.byte mag, half-frames,  init offset.

.byte $05,   $06-1


















Fixed_Linear_Vibrato:
    ldy Note_Env_ID,x
    lda LUT_Env_Sustain,y ;%VVVV II DD ;I = Vibrato ID
    and #$0c
    beq @rts ;No_Vibrato from ID 0
    tay ;Vibrato Pointer. Room for 4 bytes in each.


    inc Vibrato_Timer,x
    bmi @rts
    beq @Init_Half_Up


    lda Vibrato_Timer,x
    sub {LUT_Vibrato_Data-4,y} ;frame duration
    beq @Init_Down


    sbc LUT_Vibrato_Data-4,y ;cmp, but keep
    bne @rts
    ;beq @Init_up

    @Init_up:
    sta Vibrato_Timer,x
    iny 
    ;jmp @Full_Up

    @Init_Down:
    lda LUT_Vibrato_Data-3,y  ;Down Spd (iny for Up Spd)

    @add_Sweep:

    ;jsr Scale_Vibrato_w_BP

    cmp #$80 ;1's comp
    adc Sweep_Speed,x
    sta Sweep_Speed,x
    @rts:
    rts 



    @Init_Half_Up:
    

    lda LUT_Vibrato_Data-4,y ;Frame duration
    lsr
    sta Vibrato_Timer,x ;Init to halfway through cycle so it stays in tune.

    lda LUT_Vibrato_Data-2,y ;Up SPD
    lsr ;This is why speeds are stored as *2.
jmp @add_Sweep ;61 Bytes. 



;IN A= Unscaled, Vibrato-Depth.
Scale_Vibrato_w_BP:
    sta irq_tmp_0

    lda Base_Pitch,x
    and #$7f ;Clear Octave shift flag. (Base and Vib-Offset are halved together.)

    lsrn 3 ;every 8 notes. (can php to get every 4 notes and do one final *1.25)

    add #$fb ;-$28<<3 (So above $28 will all use the same, smallest vibrato.)
    tay
    bmi @rts

    lda irq_tmp_0
    @loop:
    sta irq_tmp_1 ;Can asr and use 1's Comp
    asr
    adc irq_tmp_1

    dey
    bpl @loop  ;A = A*(1.5^Y) 
    

    @rts:
rts






;y = Vibrato ID
lda Vibrato_Timer,x
bpl @Ongoing

inc Vibrato_Timer,x
bmi No_Vibrato

    ;A=$ff Inits to clc, Possitive
    @init:
    eor #$01 ;Flip Carry
    lsr
    lda LUT_Start_Vib_Index-1,y
    rol
    
@Ongoing:
cmp LUT_End_Vib_Index-1,y ;Have to be stored as *x2. 
bcs @init

lsr
lda LUT_Vibrato_NonRel_Data,y ;2's comp
bcc @skip
;sec
eor #$ff
@skip:


;Idea to halve the table. Too much work to save too few bytes though. (Above also isn't functional. Needs a way to store the accurate Carry without losing it.)







    ;This method Largely works even if I use a cumulative. I found that Y+5 %16 offset (Just move the LUT over by 5) Both has no drift for most vibrato lengths, and is weighted fairly evenly across the Central Pitch.
; Vibrato_Ratio_by_Length: 
;         ;Benefit, Much MUCH more than just 3 Vibrato Cycle lengths. Very easy to configure different Cycle lenghts. Same base cost. No extra increase for more 
;         ;Drawback, More CPU time. No custom SFX shenanigagns. Harder to Read/Understand/Maintain.
;     inc Vibrato_Timer,x
;     bmi No_Vibrato ;Delay Timer.

;     ldy Note_Env_ID,x
;     ;lda LUT_Env_Vibrato_Cycle_Length,y ;env Thing that needs its own byte. (or lower 4 nibbles if i +5)
;     beq No_Vibrato

;     sta irq_tmp_0

;     lda Vibrato_Timer,x
;     asln 3 

;     ldy #$ff
;     @loop:
;     iny
;     sub irq_tmp_0
;     bcs @loop ;div/0 warning. 
;     ;y = Vibrato Cycle 0-7. ; 0, 1, 2, 1,  -0, -1, -2, -1
;         ;8+ Overflows and is treated as +0 by default.

;     cpy #$08
;     bcc @skip


;     ldy #$07 ;Max phase.
;     lda #$00
;     sta Vibrato_Timer,x ;Reset (Should happen if Vibrato Timer > Cycle Length)
;     ;jmp Vibrato_Ratio_by_Length
;         ;Would make it go back and 

;     @skip:
;     lda LUT_Vibrato_Phase_to_Depth,y
;     add {Sweep_Speed,x} ;2's comp

;     ldy Base_Pitch,x
;     bmi @Double_Depth
;     cpy #$40
;     bcc @skip_else ;Normal

;     asr ;+Octave, Halved Depth.
;         ;[NOTE] 2's comp gets rounded towards negetive.
;     rts

;     @Double_Depth:
;     asl ;-Octave, Doubled Depth.
;     @skip_else:
;     rts

;     LUT_Vibrato_Phase_to_Depth:
;     .byte 1,2,2,1, <-1,<-2,<-2,<-1

;     ;This works... Technically for long cycles.
;         ;A 16 Byte LUT could smooth it would if 

;         ; .byte  0, 1, 2, 3, 3, 3, 2, 1
;         ; .byte  0, -1, -2, -3, -3, -3, -2, -1
;             ;Gives slightly funky results for short cycles. And ofc more CPU time, and more Data, and likely more Code too, cuz then I'd deff need to clamp down the Vibrato depth for shorter cycles. 

;     ;No_Vibrato:
;     lda #$00
; rts




Vibrato_Generative_LUT:
    ;Pro, Tiny LUT,  No Loops, No inf loop Risk.  Cheaply expand to 4 Vibrato Options. (Though how to Disable entirely? )
    ;Con, Hard to Maintain. Inflexible.  No Special effect support.  Vibrato is a little deep...

    ldy Note_Env_ID,x
    lda LUT_Env_Sustain,y ;%VVVV II DD ;I = Vibrato ID
    and #$0c
    beq No_Vibrato ;No_Vibrato from ID 0

    lsrn 2
    tay ;Vibrato Pointer

    inc Vibrato_Timer,x
    bmi No_Vibrato ;Delay Timer active.

        lda Vibrato_Timer,x
        pha

        and #$07
        cmp LUT_Vibrato_Branch_Start,y
        bne @skip_Branch

        pla
        add {LUT_Vibrato_Branch_Dest,y}
        and #$0f
        sta Vibrato_Timer,x
        pha

        @skip_Branch:
        pla ;23b (+7 Code. Saves a ton in LUT.)

    tay
    lda LUT_Vibrato_Generative_Data,y ;2's comp
    jsr Halve_Double_Offsets
    rts


    LUT_Vibrato_Generative_Data:
    .byte 1,3,4,5,5,4,3,1, <-1,<-3,<-4,<-5,<-5,<-4,<-3,<-1 ;16v

        ;This idea comes from expanding 1,3,1 to 1,3,3,1 to 1,3,4,4,3,1  to 1,3,4,5,5,4,3,1.
            ;These are all the BEST sine-wave aprox for their size range. 


    LUT_Vibrato_Branch_Start:
    .byte 2,2,3,$ff
    ;If about to read /\
    ;Branch ahead \/ bytes
    LUT_Vibrato_Branch_Dest:
    .byte 5,4,4
;

