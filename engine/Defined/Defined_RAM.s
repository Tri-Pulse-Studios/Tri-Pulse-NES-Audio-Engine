
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
        .fatal .sprintf(" RAM Page: $%x is already full", Page)
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

 
;This is for MUSIC DEMO ONLY

Page0:
    Res_RAM_Set_Page 0

    Res_RAM  irq_tmp_0 ;irq_tmp_0 = $00 ;IRQ needs its own seperate scratch
    Res_RAM  irq_tmp_1
    Res_RAM  irq_tmp_2
    Res_RAM  irq_tmp_3
 
    Res_RAM Song_Pointer
    Res_RAM Song_ID ;Playing Song
    Res_RAM Track_Index ;Displayed Name
    Res_RAM Unused

    Res_RAM Eighth_Length
    Res_RAM Music_Fade_Out_Flag
    Res_RAM Music_pause_Flag
    Res_RAM DMC_MIDI
    

    Res_RAM Unused
    Res_RAM Unused
    Res_RAM Held_Button
    Res_RAM Pressed_Button



    ;$10
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
    ;$38
 
    Res_5_Channels  Base_Pitch, \
                    Alt_If_Flag, \
                    No_Reset_Env_Flag,\
                    Sweep_Speed
                    
                    
                                  
    Res_5_Channels  Note_Volume_Damped, \
                    Volume_Target, \
                    Volume_Timer_Reload, \
                    Volume_Timer ;0 = full Volume,  1 = -13% Volume,  7 = -87% Volume ;Frames to wait per update.


    ;$60 ;Mixed Music/SFX
    Res_5_Channels  Note_Timer, \
                        SFX_Timer, \
                    Note_Env_Timer, \
                        SFX_ATK_Timer

    Res_5_Channels  Note_Volume, \
                        SFX_Volume, \
                    Note_Env_ID, \
                        SFX_Env_ID 
                        ;DMC SFX Volume / Env is entirely ignored.


    ;$88  SFX Only
        ;The Noise_Alts are for inx/jsr/dex re-use when nothing else needs that.
    Res_5_Channels      SFX_MIDI_Noise_Alt, \
                    SFX_MIDI, \  
                        SFX_Index_Noise_Alt,\
                    SFX_Index


                ;For Complex, the timer between each pitch.
    Res_5_Channels  SFX_pitch_timer_Noise_Alt,\
                    SFX_pitch_timer, \
                    No_Reset_F_Effects_Flag,\
                    SFX_Queued



    ;$b0
    Res_5_Channels  Note_Data,\
                    Note_Data_High, \
                    Unused,\
                    Unused2

    Res_RAM Lap_3_Flag
    Res_RAM Music_Speed_Up_Timer ;MK64 Specific
    Res_RAM Music_Slow_Down_Timer
    Res_RAM Stored_Song_ID



Page1: ;Stack
    Res_RAM_Set_Page 1

    ;Trashed by nmi w/o rti

Page2: ;OAM
    Res_RAM_Set_Page 2


    Res_RAM OAM_Buffer, $100
    OAM_Buffer_Page = OAM_Buffer/$100

Page3: ;Unusued
    Res_RAM_Set_Page 3



Page4: ;Unusued
    Res_RAM_Set_Page 4



Page5: ;Music Overflow
    Res_RAM_Set_Page 5

    ;Order of all of these is, Sq0 0-3, Sq1 4-7, Tri 8-b, Noise c-f 
        ;If dmc needs it too, it uses a whole extra line. Fill gaps w/ unrelated Data.

    ;All SFX are +1 of the mirrored Music RAM (For jsr function re-use)
        ;The Indented ones RELY on inx/jsr/dex between SFX and Music
                ;Noise Alts are for Primary/Secondary inx,jsr,dex re-use.

    ;$a0
    ;Riff Stack
    Res_RAM Riff_Ends_At, 5*8
    Res_RAM Riff_Returns_To, 5*8
    ;Recursion depth of 7 per channel. idx 0 = "In Root"
        ;Only DMC and Noise can use this much.


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



    ; .ifndef Loop
    ; Loop = $c0
    ; .endif



    _A = $0B
    _B = $0C
    _C = $0D
    _D = $0E
    _E = $0F
    _F = $10
    ;G
    _H = $11
    _I = $12
    ;J
    _K = $13
    _L = $14
    _M = $15
    _N = $16
    _O = $01
    _P = $17
    ;Q
    _R = $18
    _S = $19
    _T = $1A
    _U = $1B
    ;V
    _W = $1C
    ;X
    _Y = $1D
    ;Z

    _apo_S = $1E
    _dash = $1F
    _spc = $00
    ; _A = $0A
    ; _B = $0B
    ; _C = $0C
    ; _D = $0D
    ; _E = $0E
    ; _F = $0F
    ; ;G
    ; _H = $10
    ; _I = $11
    ; ;J
    ; _K = $12
    ; _L = $13
    ; _M = $14
    ; _N = $15
    ; _O = 0
    ; _P = $16
    ; ;Q
    ; _R = $17
    ; _S = $18
    ; _T = $19
    ; _U = $1A
    ; ;V
    ; _W = $1B
    ; ;X
    ; _Y = $1C
    ; ;Z

    ; _apo_S = $1d
    ; _dash = $1e
    ; _spc = $1f


;End of Constants