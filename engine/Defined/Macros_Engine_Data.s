

;===============================================================
;Sound Effects
;===============================================================

    ;===========================================================
    ;SFX
    ;===========================================================

    SFX_Data_Index  .set 1 ; 0 is "No SFX"

    .macro SFX Name, BP, Len, Envelope, \
        L1, P1, L2, P2, L3, P3, L4, P4, L5, P5, L6, P6, L7, P7, L8, P8

        ;-----------------------------------------------------------
        ; Validate required arguments
        ;-----------------------------------------------------------

        .ifblank Name
            .error "SFX Error: Missing Name"
            .out "SFX Error: All SFX require a Name"
            .out ""
            .exitmacro
        .endif

        .ifblank BP
            .error "SFX Error: Missing BP"
            .out "SFX Error: All SFX require a Base Pitch"
            .out ""
            .exitmacro
        .endif

        ;.assert BP <= $7F, error, "SFX Error: Base Pitch Range Error: Maximum is $7f."
        
        ;-----------------------------------------------------------
        ; Validate header arguments
        ;-----------------------------------------------------------

        .ifblank Len
            ; Pitch Only Header

            Name .set SFX_Data_Index

            .ident(.sprintf("SFX_Data_%02x", SFX_Data_Index)) = (BP | $80)&$ff

            SFX_Data_Index .set SFX_Data_Index + 1


        .else
            ; Full Header

            .ifblank Envelope
                .error "SFX Error: Missing Env"
                .out "SFX Error: Full SFX Header requires Name, BP, Len, Env, and at least one Length/Pitch pair."
                .out ""
                .exitmacro
            .endif

            .ifblank L1
                .error "SFX Error: Missing Length/Pitch"
                .out "SFX Error: Full SFX Header requires Name, BP, Len, Env, and at least one Length/Pitch pair."
                .out ""
                .exitmacro
            .endif

            Name .set SFX_Data_Index

            .ident(.sprintf("SFX_Data_%02x", SFX_Data_Index)) = (BP | $80)&$ff
            .ident(.sprintf("SFX_Data_%02x", SFX_Data_Index+1)) = Len + 1
            .ident(.sprintf("SFX_Data_%02x", SFX_Data_Index+2)) = Envelope

            SFX_Data_Index .set SFX_Data_Index + 3

            Sub_SFX BP, L1, P1, L2, P2, L3, P3, L4, P4, L5, P5, L6, P6, L7, P7, L8, P8

        .endif

        .if SFX_Data_Index > $ff
            .error "SFX Error: Too Much SFX Data"
            .out "SFX Error: Maximum of 255 bytes of SFX Data exceeded."
            .out ""
            .exitmacro
        .endif

    .endmacro

    .macro Sub_SFX BP, L1, P1, L2, P2, L3, P3, L4, P4, L5, P5, L6, P6, L7, P7, L8, P8

        .ifblank L1
            .exitmacro
        .endif

        .ifblank P1
            .error "SFX Error: Missing Pitch"
            .out "SFX Error: Missing pitch for Length/Pitch pair."
            .out " "
            .exitmacro

        .elseif (P1 < R0) .or (P1 > R15) ;.elseif .not Noise_Period_Alias

            ; Pulse pitch: must be within 0..15 of BP.

            .if (P1 - BP) < 0 .or (P1 - BP) > 15
                .error "SFX Error: Pitch out of Base Pitch Range"
                .out "SFX Error: SFX Pitch out of Base Pitch Range."
                .out " "
                .exitmacro
            .endif

        .endif


        .ident(.sprintf("SFX_Data_%02x", SFX_Data_Index)) = \
            ((L1 << 4) | ((P1 - BP) & $0F))

        SFX_Data_Index .set SFX_Data_Index + 1


        Sub_SFX BP, L2, P2, L3, P3, L4, P4, L5, P5, L6, P6, L7, P7, L8, P8

    .endmacro


    .macro Output_SFX

        ; $00 is "No SFX" 
        ; the +1 allows lda LUT,y Y=$01 to read the first byte of the table.

        LUT_SFX_Data = *+1

        .repeat SFX_Data_Index-1, I
            .byte .ident(.sprintf("SFX_Data_%02x", I+1))
        .endrepeat

    .endmacro


    ;===========================================================
    ;Noise Bank
    ;===========================================================
    NoiseFX_Index .set 0 ;INIT

    .macro NoiseFX _Name, _Noise, _Dmc 

        ; assign row index to provided name
        .ifdef _Name
            .error .sprintf("NoiseFX Error: Name re-used. Old Index: '%d' New Index: '%d' ", _Name, NoiseFX_Index)
            .exitmacro
        .endif

        _Name .set NoiseFX_Index

        ; stash labels and dmc value for this row
        .ident(.sprintf("NoiseRow%02x_Noise", NoiseFX_Index)) = _Noise

        ; .ident(.sprintf("NoiseRow%02x_Tri",   NoiseFX_Index)) = _Tri

        .ifblank _Dmc
            .ident(.sprintf("NoiseRow%02x_Dmc",   NoiseFX_Index)) = 0
        .elseif .xmatch (_Dmc, "Kick")
            .ident(.sprintf("NoiseRow%02x_Dmc",   NoiseFX_Index)) = $ff
        .else
            .ident(.sprintf("NoiseRow%02x_Dmc",   NoiseFX_Index)) = _Dmc
        .endif
        

        NoiseFX_Index .set NoiseFX_Index + 1
    .endmacro


    .macro Output_NoiseFX

        LUT_Noise_SFX_Ptr:
            .repeat NoiseFX_Index, I
                .byte .ident(.sprintf("NoiseRow%02x_Noise", I))
            .endrepeat

        LUT_DMC_SFX_Ptr:
        .repeat NoiseFX_Index, I
            .byte .ident(.sprintf("NoiseRow%02x_Dmc", I))
        .endrepeat

    .endmacro


    .macro NB_Validate _Name
        .assert NoiseFX_Index - _Name < 16, error, "Exceeded 15 Noise_FX window"
    .endmacro

 
    ;============================================================
    ; Kick Types
    ;============================================================

    Kick_Type_Index .set 0

    .macro Kick_Type Alias, Sample_Index

        .if Kick_Type_Index >= 4
            .error "Kick_Type Error: Exceeded Maximum of 4 kick types"
            .out "Kick_Type Error: Exceeded Maximum of 4 kick types"
            .out ""
            .exitmacro
        .endif

        .ident(.string(Alias)) .set Kick_Type_Index

        .ident(.sprintf("Kick_Type_%02x", Kick_Type_Index)) = Sample_Index

        Kick_Type_Index .set Kick_Type_Index + 1

    .endmacro


    .macro Output_Kick_Type

    LUT_Kick_Ptr:
        .repeat Kick_Type_Index, I
            .byte .ident(.sprintf("Kick_Type_%02x", I))
        .endrepeat

    .endmacro

;




;===========================================================
;Enveleope
;===========================================================

    ;Group Boundary Init.

    first_atk  .set -1
    last_atk   .set -1

    first_dmc  .set -1
    last_dmc   .set -1

    first_env .set -1 ;If first is not the start of a bank.

    .macro Env Size, _Name, v1,v2,v3,v4,v5,\
                            v6,v7,v8,v9,v10, \
                            v11,v12, \
                            v13,  v14
        ; 6b = 13 user variables
        ; 5b = 12 user variables
        ; 4b = 9 user variables
        ; 3b = 8 user variables

        .ifndef Env_Index
            .error "Envelope not inside an Env_Bank"
            .exitmacro

        .elseif first_env = -1
            first_env .set Env_Index
        .endif

        ;Catalog Names here? Or in Sub Envs?
        .if .xmatch(Size, "Unused")
            Sub_Env Name, 0,0,0,-$80,0, 0,0,0,0,0, 0,0,0
            ;-$80 gets stored as 0.


        .elseif .xmatch(Size, "6b")
            .ifblank v13
                .error "Not enough Variables for 6-Byte Env."
            .elseif .not .blank (v14)
                .error "Too Many Variables for 6-Byte Env."
            .endif

            .if first_atk = -1
                first_atk .set Env_Index
            .elseif last_atk <> -1
                last_atk .set -1
                .if .not Suppress_Env_Optimization_Warnings
                    .warning "This 6-Byte is after a 4 or 3 Byte. Not optimal."
                .endif
            .endif 

            .if first_dmc = -1
                first_dmc .set Env_Index
            .elseif last_dmc <> -1
                last_dmc .set -1
                .if .not Suppress_Env_Optimization_Warnings
                    .warning "This 6-Byte is after a 5 or 3 Byte. Not optimal."
                .endif
            .endif 

            Sub_Env Name, v1,v2,v3,v4,v5,\
                          v6,v7,v8,v9,v10, \
                          v11,v12, \
                          v13

        .elseif .xmatch(Size, "5b")
            .ifblank v12
                .error "Not enough Variables for 5-Byte Env."
            .elseif .not .blank (v13)
                .error "Too Many Variables for 5-Byte Env."
            .endif

            .if first_atk = -1
                first_atk .set Env_Index
            .elseif last_atk <> -1
                last_atk .set -1
                .if .not Suppress_Env_Optimization_Warnings
                    .warning "This 5-Byte is after a 4 or 3 Byte. Not optimal."
                .endif
            .endif 


            .if (first_dmc <> -1) .and last_dmc = -1
                last_dmc .set Env_Index
            .endif


            Sub_Env Name, v1,v2,v3,v4,v5,\
                          v6,v7,v8,v9,v10, \
                          v11,v12, \
                          0 ;No DMC

        .elseif .xmatch(Size, "4b")
            .ifblank v9
                .error "Not enough Variables for 4-Byte Env."
            .elseif .not .blank (v10)
                .error "Too Many Variables for 4-Byte Env."
            .endif


            .if (first_atk <> -1) .and last_atk = -1
                last_atk .set Env_Index
            .endif 

            .if first_dmc = -1
                first_dmc .set Env_Index
            .elseif last_dmc <> -1
                last_dmc .set -1
                .if .not Suppress_Env_Optimization_Warnings
                    .warning "This 4-Byte is after a 5 or 3 Byte. Not optimal."
                .endif
            .endif 

            Sub_Env Name, v1,0,0,v2,v3, \
                          v4,0,0,v5,v6, \
                          v7,v8, \
                          v9 ;No Attack

        .elseif .xmatch(Size, "3b")
            .ifblank v8
                .error "Not enough Variables for 3-Byte Env."
            .elseif .not .blank (v9)
                .error "Too Many Variables for 3-Byte Env."
            .endif

            .if (first_atk <> -1) .and last_atk = -1
                last_atk .set Env_Index
            .endif 

            .if (first_dmc <> -1) .and last_dmc = -1
                last_dmc .set Env_Index
            .endif

            Sub_Env Name, v1,0,0,v2,v3, \
                          v4,0,0,v5,v6, \
                          v7,v8, \
                          0 ;No DMC and No Attack

        .else
            .error "Invalid Env Size." ;input "6b", "5b", "4b", or "3b" with quotes.
        .endif

        _Name .set Env_Index

        Env_Index .set Env_Index + 1


    .endmacro

    .macro Sub_Env Name, atk_vol, atk_rate, dec_vol, dec_rate, sus_vol, atk_duty, atk_len, dec_duty, cutoff, sus_duty, vib_spd, vib_del, dmc_lowest_d25


        ;============================================================
        ; Envelope Bank / Index validation
        ;============================================================

            .if (Env_Index - Env_Bank_Index) >= $10
                .out "Env Warning: Envelope exceeds its Bank"
            .endif

            .if Env_Index > $FF
                .error "Env Error: Max Index exceeded (0..255)"
                .out "Env Error: Max Index exceeded (0..255)"
                .out ""
                .exitmacro
            .endif


        ;============================================================
        ;Data Validation
        ;============================================================

            ;Volume
            .if (atk_vol & $0F) <> 0
                .error "Env Error: Attack Volume must use whole values * $10"
            .endif

            .if (atk_vol < 0) .or (atk_vol > $F0)
                .error "Env Error: Attack Volume out of range (0..15) * $10"
            .endif


            .if (dec_vol & $03) <> 0
                .error "Env Error: Decay Volume must use 0.25 increments * $10"
            .endif

            .if (dec_vol < 0) .or (dec_vol > $FC)
                .error "Env Error: Decay Volume out of range (0..15.75) * $10"
            .endif


            .if (sus_vol & $0F) <> 0
                .error "Env Error: Sustain Volume must use whole values * $10"
            .endif

            .if (sus_vol < 0) .or (sus_vol > $F0)
                .error "Env Error: Sustain Volume out of range (0..15) * $10"
            .endif


            ;Rate
            .if (atk_rate & $03) <> 0
                .error "Env Error: Attack Rate must use 0.25 increments"
            .endif

            .if (atk_rate < -$20) .or (atk_rate > $1C)
                .error "Env Error: Attack Rate out of range (-2.00 .. +1.75)"
            .endif


            .if (dec_rate & $03) <> 0
                .error "Env Error: Decay Rate must use 0.25 increments * $10"
            .endif

            .if (dec_rate < -$80) .or (dec_rate > -$04)
                .error "Env Error: Decay Rate out of range (-8.00 .. -0.25) * $10"
            .endif


            ;Duty
            .if (atk_duty) > 3 .or (atk_duty < 0)
                .error "Env Error: Attack Duty must be 0..3"
            .endif

            .if (dec_duty) > 3 .or (dec_duty < 0)
                .error "Env Error: Decay Duty must be 0..3"
            .endif

            .if (sus_duty) > 3 .or (sus_duty < 0)
                .error "Env Error: Sustain Duty must be 0..3"
            .endif


            ;Timers
            .if (atk_len < 0) .or (atk_len > 15)
                .error "Env Error: Attack Length must be 1..15" 
            .endif  
            
            .if (cutoff < 0) .or (cutoff > 7)
                .error "Env Error: Cutoff must be 0..7"
            .endif


            ;Vib
            .if (vib_spd & $F3) <> 0
                .error "Env Error: Invalid Vib Speed"
            .endif
                ;Both are (0..3) << 2
            .if (vib_del & $F3) <> 0
                .error "Env Error: Invalid Vib Delay"
            .endif

            ;TODO tweak these values around so I can just type F2, and it does what I think.
            ;dmc
            .if dmc_lowest_d25 <> 0 ;Zero is placeholder
                .if dmc_lowest_d25 < As1 
                    .error "Env Error: DMC Lowest d25 pitch too low."
                .elseif dmc_lowest_d25 > Cs3 
                    .error "Env Error: DMC Lowest d25 pitch too high."
                .endif
            .endif 

        ;============================================================
        ; Store values
        ;============================================================

            .ident(.sprintf("Row%02x_AT_Init", Env_Index)) = atk_vol | vib_del | atk_duty

            .ident(.sprintf("Row%02x_AT_Rate", Env_Index)) = (atk_rate & $3c) << 2 | atk_len
            .ident(.sprintf("Row%02x_Decay_Init", Env_Index)) = dec_vol | dec_duty   

            .ident(.sprintf("Row%02x_Decay_Rate", Env_Index)) = (dec_rate & $7c) << 1 | cutoff
            .ident(.sprintf("Row%02x_Sustain", Env_Index)) = sus_vol | vib_spd | sus_duty

            .ident(.sprintf("Row%02x_DmcLow", Env_Index)) = dmc_lowest_d25 +1



    .endmacro


    .macro Env_Bank Bank_Name, Init_Env_Index

        .ifndef Env_Index

            .ifblank Init_Env_Index
                .fatal "The first Env_Bank needs the starting Env_Index. ie: Env_Bank 'Starting_Index', 0"
            .endif

            Env_Index .set Init_Env_Index

        .else

            .ifnblank Init_Env_Index
                .error "Only the first Env_Bank may specify Init_Env_Index."
            .endif

            .repeat ((16 - (Env_Index & $0F)) & $0F), I
                Env "Unused", Unused_Env
            .endrepeat

        .endif

        Env_Bank_Index .set (Env_Index & $F0)

    .endmacro


    .macro Output_Env

        .if first_env = -1
            .error "No Envelopes to emit."
            .exitmacro
        .endif

        .if first_atk = -1
            first_atk .set Env_Index
        .endif

        .if last_atk = -1
            last_atk .set Env_Index
        .endif

        .if first_dmc = -1
            first_dmc .set Env_Index
        .endif

        .if last_dmc = -1
            last_dmc .set Env_Index
        .endif



        ;----------------------------------------------------------
        ; AT Rate
        ;----------------------------------------------------------

        LUT_Env_AT_Rate = * - first_atk
        .assert (*-81 = DMC_Sample_6_81), warning, "Env Data not after DMC sample. Either disable $00 overloading, or move it closer."
        .assert (first_env + 10 >= first_atk), warning, "Too many Env's Overloading DMC $00s (Max 10)" ;This should be able to auto-emit 10 fewer at most.
                

        .repeat (Env_Index-first_atk), I ;Uses Env_Index as end, as must emit $00s after Overloading is complete.
            J .set  I+first_atk
            .byte .ident(.sprintf("Row%02x_AT_Rate",J))
        .endrepeat

        ;----------------------------------------------------------
        ; Decay Init
        ;----------------------------------------------------------

        LUT_Env_Decay_Init = * - first_atk

        .repeat (Env_Index-first_atk), I
            J .set I+first_atk
            .byte .ident(.sprintf("Row%02x_Decay_Init",J))
        .endrepeat


        ;Above for 5b versions.


        ;----------------------------------------------------------
        ; AT Init
        ;----------------------------------------------------------

        LUT_Env_AT_Init = * - first_env

        .repeat (Env_Index-first_env), I
            J .set  I+first_env
            .byte .ident(.sprintf("Row%02x_AT_Init",J))
        .endrepeat

        ;----------------------------------------------------------
        ; Decay Rate
        ;----------------------------------------------------------

        LUT_Env_Decay_Rate = * - first_env

        .repeat (Env_Index-first_env), I
            J .set I+first_env
            .byte .ident(.sprintf("Row%02x_Decay_Rate",J))
        .endrepeat


        ;----------------------------------------------------------
        ; Sustain
        ;----------------------------------------------------------

        LUT_Env_Sustain = * - first_env

        .repeat (Env_Index-first_env), I
            J .set I+first_env
            .byte .ident(.sprintf("Row%02x_Sustain",J))
        .endrepeat


        ;----------------------------------------------------------
        ; DMC
        ;----------------------------------------------------------

        LUT_env_dmc_lowest_25_pitch = * - first_dmc

        .repeat (last_dmc-first_dmc), I
            J .set I+first_dmc
            .byte .ident(.sprintf("Row%02x_DmcLow",J))
        .endrepeat

    .endmacro

;



;===========================================================
;Vibrato:
;===========================================================


    Vib_Delay_Index .set 0
    .macro Vibrato_Delay Frames_to_Delay, Alias
    
        .if Vib_Delay_Index >= 4
            .error "Vib_Delay Error: Exceeded Maximum of 4 delay types"
            .out .sprintf("Vib_Delay Error: Exceeded Maximum of 4 delay types. Given: %d. Maximum: 4", Vib_Delay_Index + 1)
            .out ""
            .exitmacro
        .endif
    
        .ident(.string(Alias)) .set (Vib_Delay_Index << 2)
    
        .ident(.sprintf("Vib_Delay_%02x", Vib_Delay_Index)) = Frames_to_Delay
    
        Vib_Delay_Index .set Vib_Delay_Index + 1
    
    .endmacro
    
    
    .macro Output_Vibrato_Delays

        LUT_Vibrato_Delays:
            .repeat Vib_Delay_Index, I
                .byte <~.ident(.sprintf("Vib_Delay_%02x", I))
            .endrepeat

    .endmacro
    
    
    
    
    
    
    
    Vib_Cycle_Data_Index .set 0
    Vib_Cycle_Index .set 0

    .macro Vibrato_Cycle Alias, v1,v2,v3,v4,v5,\
            v6,v7,v8,v9,v10, \
            v11,v12,v13,v14,v15, \
            v16,v17,v18,v19,v20

        ;validation
            .if Vib_Cycle_Index >= 4
                .error "Vib_Cycle Error: Exceeded Maximum of 4 cycle types."
                .out .sprintf("Vib_Cycle Error: Exceeded Maximum of 4 cycle types. Given: %d. Maximum: 4", Vib_Cycle_Index + 1)
                .out ""
                .exitmacro


            .elseif Vib_Cycle_Index = 0
                .ifnblank v1
                    .error "Vib_Cycle Error: Vib_None cannot have data."
                    .out "Vib_Cycle Error: The first cycle (Vib_None) must not include data."
                    .out ""
                    .exitmacro
                .endif

            .elseif Vib_Cycle_Index > 0
                .ifblank v1
                    .error "Vib_Cycle Error: Cycle data required."
                    .out "Vib_Cycle Error: All but the first cycle (Vib_None) must have data."
                    .out ""
                    .exitmacro
                .endif
            .endif

        ;

        .ident(.string(Alias)) .set (Vib_Cycle_Index << 2)

        .ident(.sprintf("Vib_Cycle_Start_%02x", Vib_Cycle_Index)) = Vib_Cycle_Data_Index

        Sub_Vibrato_Cycle v1,v2,v3,v4,v5,\
                v6,v7,v8,v9,v10, \
                v11,v12,v13,v14,v15, \
                v16,v17,v18,v19,v20


        Vib_Cycle_Index .set Vib_Cycle_Index + 1

    .endmacro


    .macro Sub_Vibrato_Cycle v1,v2,v3,v4,v5,\
                v6,v7,v8,v9,v10, \
                v11,v12,v13,v14,v15, \
                v16,v17,v18,v19,v20

        .ifblank v1
            .exitmacro
        .endif

        .if (v1 > $3f) .or (v1 < -$40)
            .error "Vib_Cycle Error: Invalid Period Delta"
            .out "Vib_Cycle Error: Invalid Period Delta. Valid Range: -$40..$3f"
            .out "    The input delta's are used by Vib_Deep."
            .out ""
            .exitmacro
        .endif

        .ident(.sprintf("Vib_Cycle_Data_%02x", Vib_Cycle_Data_Index)) = (v1 << 1) & $ff

        Vib_Cycle_Data_Index .set Vib_Cycle_Data_Index + 1

        Sub_Vibrato_Cycle v2,v3,v4,v5,\
                v6,v7,v8,v9,v10, \
                v11,v12,v13,v14,v15, \
                v16,v17,v18,v19,v20
    .endmacro





    .macro Output_Vibrato_Cycles

        LUT_Vibrato_Period_Deltas:
            .repeat Vib_Cycle_Data_Index, I
                .byte .ident(.sprintf("Vib_Cycle_Data_%02x", I))
            .endrepeat


        .byte $ff, $fe, $fd

        LUT_Start_Vib_Index = * -1 ;Index 0 is None, and Not used.
        LUT_End_Vib_Index = * ;End = Start of next.

            .repeat Vib_Cycle_Index - 1, I
                .byte .ident(.sprintf("Vib_Cycle_Start_%02x", I + 1))
            .endrepeat

            .byte Vib_Cycle_Data_Index ;End of last Cycle

    .endmacro


;


;===========================================================
;Custom Duration Sets
;===========================================================

    ;If this flag is set: Enable_Custom_Duration_Sets = 0
        ;These macros will do nothing. 

    Duration_Set_Index .set $50
    Duration_Set_Data_Index .set 0

    .macro Duration_Set Name, Size, v1,v2,v3,v4,\
            v5,v6,v7,v8, \
            v9,v10,v11,v12,\
            v13,v14,v15,v16

        .if !Enable_Custom_Duration_Sets
            .exitmacro
        .endif

        ;validation
            .if .defined(Name)
                .error "Dur_Set Error: Name is already defined."
                .out .sprintf("Duration_Set Error: Name is already defined. Value: '%s' ", .string(Name))
                .out ""
                .exitmacro
            .endif

            .if (Size < 1) .or (Size > 7)
                .error "Duration_Set Error: Invalid Size."
                .out .sprintf("Duration_Set Error: Size must be in the range 1..8. Given: %d", Size)
                .out "      Size is the number of bytes, not number of nibbles read."
                .out ""
                .exitmacro
            .endif

            .if Duration_Set_Index > $5f
                .error "Dur_Set Error: Exceeded maximum number of sets."
                .out .sprintf("Duration_Set Error: Invalid Set Index: $%02x. Maximum: $5f", Duration_Set_Index)
                .out ""
                .exitmacro
            .endif

            .if Duration_Set_Data_Index > $1f
                .error "Dur_Set Error: Data start index out of range."
                .out .sprintf("Duration_Set Error: Invalid Starting Data Index: $%02x. Maximum start index: $1f", Duration_Set_Data_Index)
                .out ""
                .exitmacro
            .endif

        ;

        ; Record the set's size and data start.
        .ident(.string(Name)) .set Duration_Set_Index

        .ident(.sprintf("Duration_Set_Info_%02x", Duration_Set_Index)) = (Size << 5) | Duration_Set_Data_Index

        ; Collect opcode nibbles.
        Sub_Duration_Set v1,v2,v3,v4,\
            v5,v6,v7,v8, \
            v9,v10,v11,v12,\
            v13,v14,v15,v16

        Duration_Set_Index .set Duration_Set_Index + 1

    .endmacro


    .macro Sub_Duration_Set v1,v2,v3,v4,\
            v5,v6,v7,v8, \
            v9,v10,v11,v12,\
            v13,v14,v15,v16

        .ifblank v1
            .exitmacro
        .endif

        .ifblank v2
            .error "Duration_Set Error: Incomplete opcode pair."
            .out "Duration_Set Error: Duration Opcodes must be supplied in pairs."
            .out ""
            .exitmacro
        .endif

        Dur_Opcode_Calc v1, v1_opcode
        Dur_Opcode_Calc v2, v2_opcode

        .ident(.sprintf("Duration_Set_Data_%02x", Duration_Set_Data_Index)) = (v2_opcode << 4) | v1_opcode

        Duration_Set_Data_Index .set Duration_Set_Data_Index + 1

        Sub_Duration_Set v3,v4,\
            v5,v6,v7,v8, \
            v9,v10,v11,v12,\
            v13,v14,v15,v16 ;Recurse Pairs


    .endmacro

    .macro Dur_Opcode_Calc Opcode, Return_Var
        .if .xmatch(Opcode, 16th)
            Return_Var .set $0
        .elseif .xmatch(Opcode, 8th)
            Return_Var .set $1
        .elseif .xmatch(Opcode, qtr)
            Return_Var .set $2
        .elseif .xmatch(Opcode, dqt)
            Return_Var .set $3
        .elseif .xmatch(Opcode, hlf)
            Return_Var .set $4
        .elseif .xmatch(Opcode, dhf)
            Return_Var .set $6
        .elseif .xmatch(Opcode, whl)
            Return_Var .set $8
        .else
            .if Opcode > $ff
                .error "Duration_Set Error: Invalid Opcode Value."
                .out "Duration_Set Error: Duration Opcodes is either Note mnemonics, `16th`, or raw byte like `$b0`."
                .out ""
                .exitmacro
            .endif
            Return_Var .set (Opcode >> 4)
        .endif
    .endmacro



    .macro Output_Duration_Sets
        .if !Enable_Custom_Duration_Sets
            .exitmacro
        .endif

        LUT_Read_Nibbles_Init:
            .repeat Duration_Set_Index - $50, I
                .byte .ident(.sprintf("Duration_Set_Info_%02x", I + $50))
            .endrepeat

        LUT_Length_Nibbles:
            .repeat Duration_Set_Data_Index, I
                .byte .ident(.sprintf("Duration_Set_Data_%02x", I))
            .endrepeat

    .endmacro


;