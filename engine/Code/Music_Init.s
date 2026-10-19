

py_Segment Song_Init, Free

Song_Init:
    .if Debugging_Enabled
        cmp #(256/5)
        bcc :+

            cmp $810a
            .byte $02 ;Too big song ID
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
        lda #$08
        sta APU_Sweep,x ;Disable Square's Hardware Sweep (Tri And Noise are unused here.)
            ;[WARN] This is DMC Direct Load. Minor Popping.


        jsr Reset_Channel ;-> A = 0

        ;lda #$00
        sta SFX_Timer,x ;Probably only DMC and Noise should be cleared?
        sta SFX_Queued,x 



        dexn 4
        bpl @loop

rts
py_Segment_End Song_Init






