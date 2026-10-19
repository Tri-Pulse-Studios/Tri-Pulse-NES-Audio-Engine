

py_Segment Song_Init, Free


Song_Init:
    .if Debugging_Enabled
        cmp #(256/5)
        bcc :+

            cmp $810a
            .byte $02 ;TOo big song ID
        :
    .endif

    tay ;-> Y
    sta Song_ID

    asln 2
    add Song_ID, clc  
    sta Song_Pointer ;A*5


    lda LUT_Song_8th_Length,y ;<- Y
    sta Eighth_Length


    ldx #$10
    @loop:
        jsr Reset_Channel ;-> A = 0

        ;lda #$00
        sta SFX_Timer,x
        sta SFX_Queued,x 


        lda #$08
        sta APU_Sweep,x ;Disable Square's Sweep (Tri And Noise are unused here.)
            ;[WARN] This is DMC Direct Load. Minor Popping.

        dexn 4
        bpl @loop

rts
py_Segment_End Song_Init





py_Segment Reset_Channel, Free
Reset_Channel:
    txa     
    lsrn 2 ;0..4
    add Song_Pointer, clc ;ID*5 + 0..4 
    tay

    lda LUT_Song_Ptr_Low,y
    sta Note_Data,x

    lda LUT_Song_Ptr_High,y
    sta Note_Data_High,x 
 

    jsr Set_BP_and_Vibrato_Depth ;First Byte, Init like a Set Pitch


    cpx #$0c
    beq @skip ;Noise Sets Env w/ SFX Engine.
                    ;Not only not needed. It causes a problem.

        lda (Note_Data,x)
        inc Note_Data,x     
        sta Note_Env_ID,x ;Full Note_Envelope + Env_Bank
        
    @skip:

    txa
    asl ;Range 1..7,  0 = In Root
    sta Riff_Depth,x


    lda #$01
    sta Note_Timer,x ;Set so Channel will start over on its first unpaused update.


    lda #$00
    jsr Reset_Volume_Damping  ;After Reset doesn't do Pre-New-Note, so must manually reset damping.

    sta Read_by_Nibble_Flag,x ;Ensure reading whole Bytes.
    sta Repeat_Counter,x ;Ensure not Repeating.

    sta No_Reset_F_Effects_Flag,x 
    sta No_Reset_Env_Flag,x ;Ensure Volume is 100% 

    sta Alt_If_Flag,x  ;Enable by Default
                            ;Set/Clear by a bit in LUT takes too much Code.




rts ;OUT A = 0
py_Segment_End Reset_Channel
;OUT Y= Pointer 






