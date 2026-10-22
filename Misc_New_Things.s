
;Group Boundary Init.

first_atk  .set -1
last_atk   .set -1

first_dmc  .set -1
last_dmc   .set -1

first_env .set -1 ;If first is not the start of a bank.

.macro Env Size, Name, v1,v2,v3,v4,v5, v6,v7,v8,v9,v10, v11,v12, v13,  v14
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
    .if .xmatch(Name, "Unused")
        Sub_Env Name, 0,0,0,0,0, 0,0,0,0,0, 0,0,0
    .elseif .xmatch(Size, "6b")
        .ifblank v13
            .error "Not enough Variables for 6-Byte Env."
        .elseif .not .blank v14
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

        Sub_Env Name, v1,v2,v3,v4,v5, v6,v7,v8,v9,v10, v11,v12, v13

    .elseif .xmatch(Size, "5b")
        .ifblank v12
            .error "Not enough Variables for 5-Byte Env."
        .elseif .not .blank v13
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


        Sub_Env Name, v1,v2,v3,v4,v5, v6,v7,v8,v9,v10, v11,v12,  0 ;No DMC


    .elseif .xmatch(Size, "4b")
        .ifblank v9
            .error "Not enough Variables for 4-Byte Env."
        .elseif .not .blank v10
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

        Sub_Env Name, v1,0,0,v2,v3, v4,0,0,v5,v6, v7,v8, v9 ;No Attack

    .elseif .xmatch(Size, "3b")
        .ifblank v8
            .error "Not enough Variables for 3-Byte Env."
        .elseif .not .blank v9
            .error "Too Many Variables for 3-Byte Env."
        .endif

        .if (first_atk <> -1) .and last_atk = -1
            last_atk .set Env_Index
        .endif 

        .if (first_dmc <> -1) .and last_dmc = -1
            last_dmc .set Env_Index
        .endif

        Sub_Env Name, v1,0,0,v2,v3, v4,0,0,v5,v6, v7,v8, 0 
            ;No Attack and No DMC

    .else
        .error "Invalid Env Size." ;input "6b", "5b", "4b", or "3b" with quotes.
    .endif

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
        .out "        Usage: Env <Size>, <Name>, <Data ...>"
        .exitmacro
    .endif

    _Name .set Env_Index

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


    ;Vibrato
    .if (vib_spd & $F3) <> 0
        .error "Env Error: Invalid Vibrato Speed"
    .endif
        ;Both are (0..3) << 2
    .if (vib_del & $F3) <> 0
        .error "Env Error: Invalid Vibrato Delay"
    .endif

    ;TODO tweak these values around so I can just type F2, and it does what I think.
    ;dmc
    .if dmc_low_25 <> 0 ;
        .if dmc_lowest_d25 < dmc_low_25 ;As1 
            .error "Env Error: DMC Lowest d25 pitch too low."
        .elseif dmc_lowest_d25 > dmc_high_12_5 ;C3 
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

    .ident(.sprintf("Row%02x_DmcLow", Env_Index)) = dmc_lowest_d25



.endmacro


.macro Env_Bank

    .ifndef Env_Index
        Env_Index .set 0
    .else
        ; Otherwise, move to next multiple of 16
        Env_Index .set ((Env_Index + 15) & $FFF0)
    .endif

    ; Remember start of current bank
    Env_Bank_Index .set Env_Index

.endmacro


.macro Output_All_Env

    .if first_env = -1
        .fatal "No Envelopes to emit."
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





Env_Bank

        Env "6b", Lead_sqr_13_0, \
            $d0, -$20, $6c, -$0c, $00, \
            _d50, atk_4, _d50, _0f, _d50,\
            Vib_None, No_Delay, \
            dmc_low_25

        T_M11__d25 .set Lead_sqr_13_0

        Env "5b", Lead_d25_3_8_6_v12, \  
            $30, +$08, $8c, -$04, $60, \
            _d25, atk_11, _d25, _0f, _d25, \
            Vib_Slow, Med_Delay

        Env "4b", Whistle_25to12_v6, \  
            $b0, -$20, $70, \
            _d25, _0f, _d12, \
            Vib_Fast, Short_Delay, \
            dmc_low_25

        T_v6_0f .set Whistle_25to12_v6

        Env "3b", Pad_sqr_s4, \
            $60, -$10, $40, \
            _d50, _0f, _d50, \
            Vib_Med, Long_Delay