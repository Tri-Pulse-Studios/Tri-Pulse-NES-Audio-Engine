;===============================================================
;Debugging
;===============================================================
    .macro Runtime_Exception Error_Msg
        .assert Debugging_Crash_Address <> *, error, Error_Msg
        .byte $02
    .endmacro

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
                bcc :+
                    Runtime_Exception "Runtime Exception: ADD w/ Omitted clc Error. The syntax `add <Var>, clc` assumes Carry is guarenteed to be clear, but Carry was set. Debug the previous instructions."

                :
            .endif

            adc arg
        .elseif .xmatch(mode, sec)

            .if Debugging_Enabled

                bcs :+
                    Runtime_Exception "Runtime Exception: ADD w/ Omitted sec Error. The syntax `add <Var>, sec` assumes Carry is guarenteed to be set, but Carry was clear. Debug the previous instructions."

                :

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

                bcc :+
                    Runtime_Exception "Runtime Exception: SUB w/ Omitted clc Error. The syntax `sub <Var>, clc` assumes Carry is guarenteed to be clear, but Carry was set. Debug the previous instructions."

                :

            .endif

            sbc arg
        .elseif .xmatch(mode, sec)

            .if Debugging_Enabled

                bcs :+
                    Runtime_Exception "Runtime Exception: SUB w/ Omitted sec Error. The syntax `sub <Var>, sec` assumes Carry is guarenteed to be set, but Carry was clear. Debug the previous instructions."

                :

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
  .macro lsrn num_repeats
    .repeat num_repeats
    lsr
    .endrepeat
  .endmacro

  .macro rorn num_repeats
    .repeat num_repeats
    ror
    .endrepeat
  .endmacro

  .macro asln num_repeats
    .repeat num_repeats
    asl
    .endrepeat
  .endmacro

  .macro roln num_repeats
    .repeat num_repeats
    rol
    .endrepeat
  .endmacro


  ;Repeated Register Decriments.
  .macro deyn num_repeats
    .repeat num_repeats
      dey
    .endrepeat
  .endmacro

  .macro inyn num_repeats
    .repeat num_repeats
      iny
    .endrepeat
  .endmacro


  .macro dexn num_repeats
    .repeat num_repeats
      dex
    .endrepeat
  .endmacro

  .macro inxn num_repeats
    .repeat num_repeats
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
    .macro name_cache Cache_Index, new_name 
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
        name_cache Cache_Index, new_name

    .endmacro

    .macro clear_tmp Cache_Index, old_name

        clear_cache Cache_Index, old_name
        name_cache Cache_Index, .ident(.concat("tmp_", .string(Cache_Index)))

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
        name_cache I, .ident(.concat("tmp_", .string(I)))
        .endrepeat

        ; name_cache 0, tmp_0
        ; name_cache 1, tmp_1
        ;...
        ; name_cache 14, tmp_14
        ; name_cache 15, tmp_15
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
            Runtime_Exception "Runtime Exception: BAL Error. `bal` is intended to always branch, but execution failed to branch. Debug the branch condition and preceding instructions."

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


