;===============================================================
;Math
;===============================================================

    .macro asr ;Arthimatic Shift Right. (Sign Preserving)
        cmp #$80
        ror
    .endmacro



    .macro add arg, mode

        .ifblank mode
            clc
            adc arg

        .elseif .xmatch(mode, clc)

            .if Debugging_Enabled

                bcc *+6 ;skip if valid

                .assert * <> Debugging_Crash_Address, error, "Debugging_Crash_Address Here: "
                cmp *
                .byte $02

            .endif

            adc arg
        .elseif .xmatch(mode, sec)

            .if Debugging_Enabled

                bcs *+6 ;skip if valid

                .assert * <> Debugging_Crash_Address, error, "Debugging_Crash_Address Here: "
                cmp *
                .byte $02

            .endif

            adc arg
        .else
            .error .sprintf("Invalid add mode '%s'.", mode)
            .out "Usage:  add <arg> [, clc|sec]"
            .out "        clc|sec: carry state guaranteed by prior logic"
        .endif

    .endmacro


    .macro sub arg, mode

        .ifblank mode
            sec
            sbc arg

        .elseif .xmatch(mode, clc)

            .if Debugging_Enabled

                bcc *+6 ;skip if valid

                .assert * <> Debugging_Crash_Address, error, "Debugging_Crash_Address Here: "
                cmp *
                .byte $02

            .endif

            sbc arg
        .elseif .xmatch(mode, sec)

            .if Debugging_Enabled

                bcs *+6 ;skip if valid

                .assert * <> Debugging_Crash_Address, error, "Debugging_Crash_Address Here: "
                cmp *
                .byte $02

            .endif

            sbc arg
        .else
            .error .sprintf("Invalid sub mode '%s'.", mode)
            .out "Usage:  sub <arg> [, clc|sec]"
            .out "        clc|sec: carry state guaranteed by prior logic"
        .endif

    .endmacro

    ;Advanced, Optimization techniques:
        ;adc <var>
            ;Deliberately using carry for math, ie, 16 bit adder.

        ;add <var>
            ;Stardard clc,adc <var> macro.

        ;add <var>, clc
            ; emits just adc <var> (Saving a byte of ROM by not executing "clc")

            ; Use when state is guarenteed to be Carry = 0
            ; with Debugging_Enabled = 1, this asserts during runtime Carry = 0. 

;


;===============================================================
;Repeated Instructions.
;===============================================================

  ;Repeated Shifts
  .macro lsrn Repeat
    .repeat Repeat
    lsr
    .endrepeat
  .endmacro

  .macro rorn Repeat
    .repeat Repeat
    ror
    .endrepeat
  .endmacro

  .macro asln Repeat
    .repeat Repeat
    asl
    .endrepeat
  .endmacro

  .macro roln Repeat
    .repeat Repeat
    rol
    .endrepeat
  .endmacro


  ;Repeated Register Decriments.
  .macro deyn Repeat
    .repeat Repeat
      dey
    .endrepeat
  .endmacro

  .macro inyn Repeat
    .repeat Repeat
      iny
    .endrepeat
  .endmacro


  .macro dexn Repeat
    .repeat Repeat
      dex
    .endrepeat
  .endmacro

  .macro inxn Repeat
    .repeat Repeat
      inx
    .endrepeat
  .endmacro

;


;===============================================================
;Stack
;===============================================================
    .macro phaxy
        pha
        txa
        pha
        tya
        pha
    .endmacro

    .macro plaxy ;Reverse order.
        pla
        tay
        pla
        tax
        pla
    .endmacro


    .macro phx
        txa
        pha
    .endmacro

    .macro plx
        pla
        tax
    .endmacro


    .macro phy
        tya
        pha
    .endmacro

    .macro ply
        pla
        tay
    .endmacro


    .macro phm Memory
        lda Memory
        pha
    .endmacro

    .macro plm Memory
        pla
        sta Memory
    .endmacro

;


;===============================================================
;Naming
;===============================================================

    .macro Inline Func_Name

        Func_Name

        ;Usage: 
        ;Create a .macro <Func_Name>
            ;<code>
        ;.endmacro

        ;invoke it w/ Inline <Func_Name> instead of jsr <Func_Name>
    .endmacro


    ;===========================================================
    ;Temporary Cache Naming
    ;===========================================================

    ;Usage, alias up to 16 variables of scratch RAM. (Ideally ZP)
        ; Mark where RAM is filled/freed
        ; Error checks collisions

        ;
    .macro Name_Cache Cache_Index, new_name 
        .if Cache_Index > 15
        .error "INVALID CACHE ADDRESS PROVIDED. Valid Range 0-15 (Not 0-f)"
        .else

        .if .ident(.concat("cache_", .string(Cache_Index))) = -1  ;If Scratch clear

            .ident(.concat("cache_", .string(Cache_Index))) .set $10 + Cache_Index  ;mark scratch index reserved
            new_name .set .ident(.concat("cache_", .string(Cache_Index))) ;Set name = scratch index
            
        .else
            .error "CACHE ALREADY ALLOCATED!"
        .endif
        .endif
    .endmacro


    .macro name_tmp Cache_Index, new_name

        clear_cache Cache_Index, .ident(.concat("tmp_", .string(Cache_Index)))
        Name_Cache Cache_Index, new_name

    .endmacro

    .macro clear_tmp Cache_Index, old_name

        clear_cache Cache_Index, old_name
        Name_Cache Cache_Index, .ident(.concat("tmp_", .string(Cache_Index)))

    .endmacro


    .macro clear_cache Cache_Index, old_name

        .if .not .const(cache_0)
        .if .const(::cache_0)
            .fatal "tmp naming error: Inside an Unexpected Scope. (Check Music Channels all Loop or .endscope)"
        .else
            .warning "tmp naming warning: Inside a defined scope. Not Expected"
        .endif
        .endif



        .if Cache_Index > 15
        .error "INVALID CACHE ADDRESS PROVIDED. Valid Range 0-15 (Not 0-f)"
        .else
        .if .ident(.concat("cache_", .string(Cache_Index))) = -1  ;If Scratch = -1  
            .error "CACHE ALLREADY CLEAR! Maybe you deleted the Name?"

        .elseif .blank(old_name)
            .error "NO CACHE NAME PROVIDED."

        .elseif old_name = -1 
            .error "WRONG CACHE NAME PROVIDE. Maybe you mispelled it?"

        .else
            .ident(.concat("cache_", .string(Cache_Index))) .set -1
            old_name .set -1

        .endif
        .endif
    .endmacro



    ;Cache_Init
        .repeat 16, I
        .ident(.concat("cache_", .string(I))) .set -1
        .endrepeat
        ; cache_0 .set -1
        ; cache_1 .set -1
        ;...
        ; cache_14 .set -1
        ; cache_15 .set -1


    ;Init tmp names
        .repeat 16, I
        Name_Cache I, .ident(.concat("tmp_", .string(I)))
        .endrepeat

        ; Name_Cache 0, tmp_0
        ; Name_Cache 1, tmp_1
        ;...
        ; Name_Cache 14, tmp_14
        ; Name_Cache 15, tmp_15
;

;===============================================================
;Branching
;===============================================================

    .macro  jeq     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        beq     Target
        .else
        bne     *+5
        jmp     Target
        .endif
    .endmacro

    .macro  jne     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bne     Target
        .else
        beq     *+5
        jmp     Target
        .endif
    .endmacro


    .macro  jmi     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bmi     Target
        .else
        bpl     *+5
        jmp     Target
        .endif
    .endmacro

    .macro  jpl     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bpl     Target
        .else
        bmi     *+5
        jmp     Target
        .endif
    .endmacro


    .macro  jcs     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bcs     Target
        .else
        bcc     *+5
        jmp     Target
        .endif
    .endmacro

    .macro  jcc     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bcc     Target
        .else
        bcs     *+5
        jmp     Target
        .endif
    .endmacro


    .macro  jvs     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bvs     Target
        .else
        bvc     *+5
        jmp     Target
        .endif
    .endmacro

    .macro  jvc     Target
        .if     .def(Target) .and ((*+2)-(Target) <= 127)
        bvc     Target
        .else
        bvs     *+5
        jmp     Target
        .endif
    .endmacro


    ;Branch "Always"
        ;jmp optimization with debugging at runtime.
    .macro bal Target, Condition

        .if .xmatch(Condition,bcc)
            bcc Target

        .elseif .xmatch(Condition,bcs)
            bcs Target

        .elseif .xmatch(Condition,beq)
            beq Target

        .elseif .xmatch(Condition,bne)
            bne Target

        .elseif .xmatch(Condition,bmi)
            bmi Target

        .elseif .xmatch(Condition,bpl)
            bpl Target

        .elseif .xmatch(Condition,bvs)
            bvs Target

        .elseif .xmatch(Condition,bvc)
            bvc Target

        .else
            .error "Invalid BAL condition. Expected: bcc, beq, etc"
        .endif

        .if Debugging_Enabled

            .assert * <> Debugging_Crash_Address, error, "Debugging_Crash_Address Here: "
            .byte $02

        .endif
    .endmacro


    ;Decimal Flag Utilization
        ;sed / cld otherwise have no effect in the NES.
    .macro bds Target
        php
        pla
        and #$08
        bne Target
    .endmacro

    .macro bdc Target
        php
        pla
        and #$08
        beq Target
    .endmacro

    .macro jds Target
        php
        pla
        and #$08
        jne Target
    .endmacro

    .macro jdc Target
        php
        pla
        and #$08
        jeq Target
    .endmacro

;


;===============================================================
;Music Engine
;===============================================================
   
    ;===========================================================
    ;Organizing Misc Effects
    ;===========================================================

    .macro SFX_Type _Name, _Data

        .ifndef SFX_Type_Index

        Pre_Data = 0
        Data_Block = 1
        Post_Data = 2

        SFX_Type_Index .set $f8 ;$f0-$f7 is Custom Volume
        SFX_Data_Phase .set Pre_Data

        .endif


        .if SFX_Type_Index >= $100 
            .error "SFX_Type Error: Index overflow (f0..ff)"
            .exitmacro
        .endif


        .ifblank _Data 

            .if SFX_Data_Phase = Data_Block
            SFX_Data_Phase .set Post_Data
            .endif

        .else  

            .if SFX_Data_Phase = Post_Data   
            .error "SFX_Type Error:  Missing SFX Data (All w/o data must be at Start or End)"

            .elseif SFX_Data_Phase = Pre_Data
            SFX_Data_Phase .set Data_Block
            
            .endif 

            .byte _Data

        .endif

        _Name = SFX_Type_Index                ; symbol
        SFX_Type_Index .set SFX_Type_Index + 1        ; next

    .endmacro

;
