
.macro Res_RAM_Set_Page page_num

    Page .set $100*page_num
    RAM_Index .set 0

.endmacro
 
.macro Res_RAM Var_Name, Res_N_Bytes



    .ifdef Var_Name
        .if .not .xmatch(Var_Name, Unused)

            .Warning "Res RAM Warning"
            .out "Var Name is already in use"
        .endif

        .ifblank Res_N_Bytes
            RAM_Index .set RAM_Index +1
        .else
            RAM_Index .set RAM_Index +Res_N_Bytes
        .endif

        .exitmacro
    .endif


    Var_Name = Page+RAM_Index


    .ifblank Res_N_Bytes
        RAM_Index .set RAM_Index +1
    .else
        RAM_Index .set RAM_Index +Res_N_Bytes
    .endif

    .if RAM_Index > 256
        .if Page = 0
            .warning .sprintf("ZP RAM Overflowed. ZP,x instructions may not function.")
        .elseif (Page+RAM_Index) >= $800
            .error .sprintf("2k of RAM Overflowed. Index: $%X", (Page + RAM_Index))
        .endif
    .endif

.endmacro


.macro Res_5_Channels Var_Name_1, Var_Name_2, Var_Name_3, Var_Name_4

    Res_RAM Var_Name_1 ;Define Them each
    Res_RAM Var_Name_2
    Res_RAM Var_Name_3
    Res_RAM Var_Name_4

    RAM_Index .set RAM_Index +16 ;a group of 4 res 5 bytes each.

    .if RAM_Index > 256
        .fatal .sprintf(" RAM Page: $%x is already full", Page)
    .endif

.endmacro

 


ZP_RAM:


    Res_RAM_Set_Page 0
    RAM_Index .set ZP_RAM_Start

    ;$00
    Res_RAM Note_Data
    Res_RAM Note_Data_High ;Sq0
    Res_RAM irq_tmp_0 ;Scratch RAM
    Res_RAM irq_tmp_1

    Res_RAM ND_Sq1 ;Note_Data_Sq1. 
    Res_RAM NDH_Sq1 ;Channel data is spaced 4 bytes apart (To match APU Register spacing format.)
    Res_RAM irq_tmp_2
    Res_RAM irq_tmp_3
 
    ;$08
    Res_RAM ND_Tri
    Res_RAM NDH_Tri
    Res_RAM Song_ID 
    Res_RAM Song_Pointer ;ID*5
    
    Res_RAM ND_Noise
    Res_RAM NDH_Noise
    Res_RAM Eighth_Length
    Res_RAM DMC_MIDI

    ;$10
    Res_RAM ND_DMC
    Res_RAM NDH_DMC


    ;For UI Text 
    Res_RAM Held_Button
    Res_RAM Pressed_Button
    Res_RAM Track_Index ;Displayed Name
    Res_RAM Silence_APU_Flag

;



Normal_RAM:
    Res_RAM_Set_Page >RAM_Start
    RAM_Index .set <RAM_Start

    
    ;Order of all of these is, Sq0 0-3, Sq1 4-7, Tri 8-b, Noise c-f, DMC 10-13

    ;All SFX are +1 of the mirrored Music RAM (For jsr function re-use)
        ;The Indented ones RELY on inx/jsr/dex between SFX and Music
                ;Noise Alts are for Primary/Secondary inx,jsr,dex re-use.

    ;$00
    Res_5_Channels  Note_Period_High, \
                    Note_Period_Low, \
                    Vibrato_Timer, \
                    Vibrato_Depth

                    ;This group only read by Sq-Tri
                        ;Only Vib_Depth is written by dmc-Noise (Depth read by Noise as Kick Ptr)


    Res_5_Channels  Riff_Depth, \
                    Repeat_Counter, \
                    Read_by_Nibble_Flag, \
                    Length_Nibble_Index

    ;$28
    Res_5_Channels  Base_Pitch, \
                    Ignore_If_Alts_Flag, \
                    No_Reset_Env_Flag,\
                    Sweep_Speed
                    
                    
                                  
    Res_5_Channels  Note_Volume_Damped, \
                    Volume_Target, \
                    Volume_Timer_Reload, \
                    Volume_Timer ;0 = full Volume,  1 = -13% Volume,  7 = -87% Volume ;Frames to wait per update.


    ;$50 ;Mixed Music/SFX
    Res_5_Channels  Note_Timer, \
                        SFX_Timer, \
                    Note_Env_Timer, \
                        SFX_ATK_Timer


    Res_5_Channels  Note_Volume, \
                        SFX_Volume, \
                    Note_Env_ID, \
                        SFX_Env_ID 
                        ;DMC SFX Volume / Env is entirely ignored.


    ;$78  SFX Only
        ;The Noise_Alts are for inx/jsr/dex re-use when nothing else needs that.
    Res_5_Channels      SFX_MIDI_Noise_Alt, \
                    SFX_MIDI, \  
                        SFX_Index_Noise_Alt,\
                    SFX_Index


                ;For Complex, the timer between each pitch.
    Res_5_Channels      SFX_pitch_timer_Noise_Alt,\
                    SFX_pitch_timer, \
                    No_Reset_F_Effects_Flag,\
                    SFX_Queued

    ;$a0
OAM:
    OAM_Buffer_Page = 2
    Res_RAM_Set_Page OAM_Buffer_Page
    Res_RAM OAM_Buffer, $100

Riff_Stack:

    .if Expand_Max_Riff_Depth
        Res_RAM Riff_Ends_At, 5*8
        Res_RAM Riff_Returns_To, 5*8
    .else
        Res_RAM Riff_Ends_At, 5*4
        Res_RAM Riff_Returns_To, 5*4
    .endif
    ;Recursion depth of 7 per channel. idx 0 = "In Root"
        ;Only DMC and Noise realistically need this much.


Page6: ;Unusued
    Res_RAM_Set_Page 6



Page7: ;Unusued
    Res_RAM_Set_Page 7
       
    
;End of RAM



Misc_Constants:


    ;This is for anything that the game relies on it existing

    Joy_Pad_1 = $4016
    Joy_Pad_2 = $4017

    ;Button_Consts
        butA = $80
        butB = $40
        select = $20
        start = $10
        up = $08
        down = $04
        left = $02
        right = $01
    ;


    ;8th = 1
    ; qtr = 2 ;These are .xmatched
    ; dqt = 3
    ; hlf = 4
    ; dhf = 6
    ; whl = 8

    
    APU_Volume = $4000
    APU_Sweep = $4001
    APU_Period_Low = $4002
    APU_Period_High = $4003

    APU_Noise_Volume = $400c
        ;Unusued
    APU_Noise_Period = $400e
    APU_Init_Noise = $400f

    DMC_Rate = $4010
        ;DMC_Direct_Load = $4011
    DMC_Address = $4012
    DMC_Length = $4013

    APU_Channel_Enable = $4015




;End of Constants