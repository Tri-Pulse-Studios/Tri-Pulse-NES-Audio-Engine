.macro Validate _Name
    .assert NoiseFX_Index - _Name < 16, error, "Exceeded 15 Noise_FX window"
.endmacro

 


;NoiseFX Defined Order

    Menu_NB               .set NoiseFX_Index
    ;Most NB start here

        Raceway_NB            .set NoiseFX_Index ;R
        Yoshi_Valley_NB       .set NoiseFX_Index ;YV
        
        Frappe_Snowland_NB    .set NoiseFX_Index ;FS
        Choco_Mountain_NB     .set NoiseFX_Index ;CM
        Bowsers_Castle_NB     .set NoiseFX_Index ;BC

        Banshee_Boardwalk_NB  .set NoiseFX_Index ;BB
        
        Results_NB            .set NoiseFX_Index ;R
        Lose_Race_NB          .set NoiseFX_Index

        Battle_NB             .set NoiseFX_Index
    ;  

        NoiseFX Hat_D3,        Hat_2_adr,       Ds3_Tom  ;YV
        NoiseFX Shaker_As3,    Shaker_2_adr,    As3_Tom_adr  ;YV

        NoiseFX Shaker_A2,     Shaker_2_adr,    A2_Tom ;BC
        
    
    Title_NB          .set NoiseFX_Index

    Toads_Turnpike_NB .set NoiseFX_Index ;TT
    Rainbow_Road_NB   .set NoiseFX_Index ;RR

    Award_Win_NB      .set NoiseFX_Index

    ;Highly Common FX
        NoiseFX Solo_Kick,     $00,          "Kick"

        NoiseFX Snare_8,       Snare_8_adr     
        NoiseFX Snare_8_Kick,  Snare_8_adr,  "Kick"
                    
        NoiseFX Snare_6,       Snare_6_adr   
        NoiseFX Snare_6_Kick,  Snare_6_adr,  "Kick"

    Star_Power_NB .set NoiseFX_Index ;Needs Rasp_2_Kick. Otherwise fits perfect w/ Group 2

        NoiseFX Hat_2,         Hat_2_adr  
        NoiseFX Hat_Kick,      Hat_2_adr,    "Kick"    

        NoiseFX Crash_3,       Crash_3_adr,  "Kick"
        NoiseFX Crash_7,       Crash_7_adr,  "Kick" 
            
        
    Kalamari_Desert_NB .set NoiseFX_Index ;KD
    Koopa_Beach_NB .set NoiseFX_Index ;KTB  
    DKs_NB .set NoiseFX_Index ;DK   

        NoiseFX Shaker_2,  Shaker_2_adr
        NoiseFX Shaker_Kick,      Shaker_2_adr,    "Kick"
        
        NoiseFX Pre_Cymbal_4,  Pre_Cymbal_4_adr   

    ;End Highly Common FX
    Validate Raceway_NB ;And many more.


    ;KTB and Title
        NoiseFX Rasp_d,      Rasp_d_adr ;AW 
        NoiseFX Rasp_c,      Rasp_c_adr

        NoiseFX Rasp_2,      Rasp_w_Shaker_2_adr
    Validate Title_NB
        NoiseFX Rasp_2_Kick, Rasp_w_Shaker_2_adr, "Kick"
    Validate Star_Power_NB


    ;KD and DK
        NoiseFX Shaker_3, Shaker_3_adr
        NoiseFX Shaker_5, Shaker_3_adr
        NoiseFX Shaker_7, Shaker_3_adr

        NoiseFX Hat_4, Hat_4_adr 


        ;DK Aliaises
            __1 .set Shaker_2
            __2 .set Shaker_3
            __3 .set Shaker_5
            __4 .set Shaker_7

        ;NoiseFX __1_d50, Shaker_2_adr, "Kick"
        __1_d50 .set Shaker_Kick
        NoiseFX __1_d12, Shaker_2_adr, DK_d12_Kick

    ;KD Solos
        NoiseFX Train_Lo,  Rasp_w_Shaker_3_adr, d12_Tom_Low
        Train_Hi .set Rasp_2_Kick ;NoiseFX Train_Hi,  Rasp_w_Shaker_2_adr, d12_Tom_High
        
 
    ;KTB's Solos
 
        Rasp_c_Bb3 .set Rasp_2_Kick ;NoiseFX Rasp_c_Bb3, Rasp_w_Shaker_2_adr, As3_Tom_adr 
        Shaker_Bb3 .set Shaker_Kick ;NoiseFX Shaker_Bb3, Shaker_2_adr,        As3_Tom_adr 

        NoiseFX Rasp_F4,    Rasp_w_Shaker_2_adr, F4_Tom
        NoiseFX Shaker_F4,  Shaker_2_adr,        F4_Tom

    Validate Koopa_Beach_NB
    Validate DKs_NB
;

 

