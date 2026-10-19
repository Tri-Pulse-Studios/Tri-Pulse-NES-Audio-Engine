Macros_Defined .set 1

;To highlight, add pnemonic to 
;C:\Users\Cody\.vscode\extensions\tlgkccampbell.code-ca65-1.2.6\syntaxes


  ;Current backup: 
    ; "comment": "6502 Macros",
    ; 			"name": "keyword.other.macro.ca65.6502",
    ; 			"match": "\\b(?i)(\\.macro\\s+)?(clear_tmp|name_tmp|lsrn|asln|rorn|roln|add|sub|jeq|jne|jmi|jpl|jcc|jcs|jvs|jvc|balt|balte|bage|bagne|bae|bane|bxl|bxle|bxge|bxgne|bxe|bxne|byl|byle|byge|bygne|bye|byne|phx|phy|ply|plx|plaxy|phaxy|asr|)\\b"
    ; 		}, {




;Math

.macro inh arg, indexed ;Inc High

  .ifblank indexed

    .if arg > $ff

    bcc *+5 ;abs
    inc arg
    
    .else 
    bcc *+6 ;zp
    inc arg 
    .endif

  .else 
    .warning "Illegal Addressing mode if not ,x"
    .if arg > $ff

    bcc *+5 ;abs
    inc arg,x
    
    .else 
    bcc *+6 ;zp
    inc arg,x 
    .endif

  .endif
  .endmacro

  ;WARNING These do not catch Illegal Addressing Modes at present.
      ;If it becomes an issue, I can figure out how to do it properly.

  .macro deh arg, indexed ;DEc High

  .ifblank indexed

    .if arg > $ff

    bcs *+5 ;abs
    dec arg
    
    .else 
    bcs *+6 ;zp
    dec arg 
    .endif

  .else 
      .warning "Illegal Addressing mode if not indexed with x"
      .if arg > $ff

      bcs *+5 ;abs
      dec arg,x
      
      .else 
      bcs *+6 ;zp
      dec arg,x
      .endif

  .endif
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



;

;Shift repeated N times:

  .macro asr ;Arithmatic Shift Right. (The Arithmatic means it handles 2's comp correctly? )
  cmp #$80
  ror
  .endmacro

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


    ;If A> arg, A == arg

        ;If arg is Negetive (Only works for # mode):
          ;If (A-$100)> arg, A == (arg+$100)

  .macro max arg ;A is at max: the value at arg
  cmp arg
  bcc *+6
  lda arg
  .endmacro

  .macro min arg ;A is, at minimum, the value at arg
  cmp arg
  bcs *+6
  lda arg
  .endmacro

;Push
  .macro phaxy
  pha
  txa
  pha
  tya
  pha
  .endmacro


  .macro plaxy ;Specifically in reverse order of phaxy
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
;Pulls


;Naming
  Inline_Count .set 0
  .macro Inline Func_Name

    Func_Name

      ;Usage: 
        ;Create a .macro <Func_Name>
          ;<code>
        ;.endmacro

      ;invoke it w/ Inline
  .endmacro


  .macro particle Name, Hitbox   ;, Hitbox ;Hitbox format: $xxyy
    .local ID_Number

    .if .defined(.ident(.concat(.string(Name), "_ID")))
      .error "Name Already Defined as an Entity"
      .exitmacro

    .else
    .ident(.concat("Pointer_of_", .string(Name), "_Update")):

    ID_Number = (.ident(.concat("Pointer_of_", .string(Name), "_Update"))-LUT_Particle_IDs_Hitboxes)/4
    .ident(.concat(.string(Name), "_ID")) = ID_Number

    .word .ident(.concat(.string(Name), "_Update")) ;Pointer to Update logic
    .word Hitbox

    .endif
  .endmacro




  .macro entity Name, Hitbox   ;, Hitbox ;Hitbox format: $xxyy
    .local ID_Number

    .if .defined(.ident(.concat(.string(Name), "_ID")))
      .error "Name Already Defined as a Particle"
      .exitmacro

    .else
    .ident(.concat("Pointer_of_", .string(Name), "_Update")):

    ID_Number = (.ident(.concat("Pointer_of_", .string(Name), "_Update"))-LUT_Particle_IDs_Hitboxes)/4
    .ident(.concat(.string(Name), "_ID")) = ID_Number

    .word .ident(.concat(.string(Name), "_Update")) ;Pointer to Update logic

    .word Hitbox


    .endif
  .endmacro




  .macro Palette Name

  .ident(.concat("Pointer_of_", .string(Name), "_Palette")):
  .ident(.concat(.string(Name), "_Palette_ID")) = (.ident(.concat("Pointer_of_", .string(Name), "_Palette"))-LUT_All_Palettes)/3

  .endmacro
;Convention


;Less optimal than Branch version.
;jeq -> beq only if in backwards range.
;Else, bne skip_jmp, jmp

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

        cmp *
        .byte $02

    .endif
.endmacro

;
;Decimal Flag Utilization
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


;Music Engine Stuff


  .macro If_Alt _Old, _New, Supress_Warning

      .if .xmatch(_Old, "Toggle")
          .byte $70
          .exitmacro
      .endif

      .ifblank _New
          .byte $70 | (_Old & $f) ;Raw, Unchecked Delta


          ; .error "If_Alt Error: Invalid syntax"
          ; .out   "    Usage: If_Alt <Unmodified>, <Modified>"
          ; .out   "           If_Alt 'Toggle'"
          
          .exitmacro



      .elseif .xmatch(_Old,rest)
          .byte $70 | ((_New - BP + 1) & $f)
          Assert_Valid_Pitch _New
          .exitmacro

            

      .elseif .xmatch(_New,rest)
          .byte $70 | ((-1 * (_Old - BP + 1) )& $f) ;The Negetive may be backward
          Assert_Valid_Pitch _Old

          .exitmacro


      .elseif .const(_Old) && .const(_New)
        .if _Old = _New
            .error "If_Alt Error: Delta is zero (conflicts with Toggle command)"
            .out   "    Usage: If_Alt <Unmodified>, <Modified>"
            .out   "           If_Alt 'Toggle'"
            .exitmacro
        .endif

        .if _New = (BP + 1) && .blank(Suppress_Warning)
            .warning .sprintf("If_Alt Warning: Target note resolves to REST (BP:%d AltNote:%d)", BP, _New)
            .out   "    Fix: Adjust the Base Pitch."
            .exitmacro
        .endif
      .endif

      .byte $70 | (_New-_Old)&$f

  .endmacro



  .macro Assert_Valid_Pitch Pitch

    ; .assert ((Pitch - BP) >= 0) && ((Pitch - BP) <= $0F), error, .sprintf("If_Alt Error: Note out of BP Range. Note:%d  BP:%d", Pitch, BP
    ; .assert (Pitch >= A0) && (Pitch <= B5), error, .sprintf("If_Alt Error: Invalid pitch. Note:$%02X  (Valid range: A0–B5)", _New)

      .assert ((Pitch - BP) >= 0) && ((Pitch - BP) <= $0F), error, "If_Alt Error: Note out of BP range. Add 'F' to Force a non-note If_Alt"
      .assert (Pitch >= A0) && (Pitch <= B5), error, "If_Alt Error: Invalid pitch (valid range: A0–B5). Add 'F' to Force a non-note If_Alt"

  .endmacro



   ;LOTS of errors?  Likely ended a scope w/o starting one or vice versa
  .macro Channel Label, Scope_Name
    Label:

    .scope Scope_Name  ;If Blank,  Un-Named
    _8th = ::_8th




    Define_Pitches ;a0 = 0, as0 = 1 ,etc
    Duration_List Set_Name ;redefine Durations in scope

  .endmacro



 


  .macro Define_Pitches
      Octave = $40 ;???   Its needed.

      A0  = $00
      As0 = $01  ; Bb0
      Bb0 = $01
      B0  = $02

      C1  = $03
      Cs1 = $04  ; Db1
      Db1 = $04
      D1  = $05
      Ds1 = $06  ; Eb1
      Eb1 = $06
      E1  = $07
      F1  = $08
      Fs1 = $09  ; Gb1
      Gb1 = $09
      G1  = $0A
      Gs1 = $0B  ; Ab1
      Ab1 = $0B
      A1  = $0C
      As1 = $0D  ; Bb1
      Bb1 = $0D
      B1  = $0E

      C2  = $0F
      Cs2 = $10  ; Db2
      Db2 = $10
      D2  = $11
      Ds2 = $12  ; Eb2
      Eb2 = $12
      E2  = $13
      F2  = $14
      Fs2 = $15  ; Gb2
      Gb2 = $15
      G2  = $16
      Gs2 = $17  ; Ab2
      Ab2 = $17
      A2  = $18
      As2 = $19  ; Bb2
      Bb2 = $19
      B2  = $1A

      C3  = $1B
      Cs3 = $1C  ; Db3
      Db3 = $1C
      D3  = $1D
      Ds3 = $1E  ; Eb3
      Eb3 = $1E
      E3  = $1F
      F3  = $20
      Fs3 = $21  ; Gb3
      Gb3 = $21
      G3  = $22
      Gs3 = $23  ; Ab3
      Ab3 = $23
      A3  = $24
      As3 = $25  ; Bb3
      Bb3 = $25
      B3  = $26

      C4  = $27
      Cs4 = $28  ; Db4
      Db4 = $28
      D4  = $29
      Ds4 = $2A  ; Eb4
      Eb4 = $2A
      E4  = $2B
      F4  = $2C
      Fs4 = $2D  ; Gb4
      Gb4 = $2D
      G4  = $2E
      Gs4 = $2F  ; Ab4
      Ab4 = $2F
      A4  = $30
      As4 = $31  ; Bb4
      Bb4 = $31
      B4  = $32

      C5  = $33
      Cs5 = $34  ; Db5
      Db5 = $34
      D5  = $35
      Ds5 = $36  ; Eb5
      Eb5 = $36
      E5  = $37
      F5  = $38
      Fs5 = $39  ; Gb5
      Gb5 = $39
      G5  = $3A
      Gs5 = $3B  ; Ab5
      Ab5 = $3B
      A5  = $3C
      As5 = $3D  ; Bb5
      Bb5 = $3D
      B5  = $3E

      ;Enharmonics
      Bs0 = C1

      Cb1 = B0
      Fb1 = E1
      Es1 = F1
      Bs1 = C2

      Cb2 = B1
      Fb2 = E2
      Es2 = F2
      Bs2 = C3

      Cb3 = B2
      Fb3 = E3
      Es3 = F3
      Bs3 = C4

      Cb4 = B3
      Fb4 = E4
      Es4 = F4
      Bs4 = C5

      Cb5 = B4
      Fb5 = E5
      Es5 = F5

    Repeat_xN = ($90 + (0<<1))
    Repeat_x1 = ($91 + (1<<1))
    Repeat_x2 = ($91 + (2<<1))
    Repeat_x3 = ($91 + (3<<1))
    Repeat_x4 = ($91 + (4<<1))
    Repeat_x5 = ($91 + (5<<1))
    Repeat_x6 = ($91 + (6<<1))
    Repeat_x7 = ($91 + (7<<1))


    d50_Kick .set 0
    d25_Kick .set 1
    As3_Tom .set 2
    d12_Tom .set 3

  .endmacro

  Define_Pitches ;Define them Globally.



  .macro Duration Length_Pattern, P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12
      .if .xmatch(Length_Pattern, "Cont")
        Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12  ;Riffs can start a Duration, then return partway through Duration

      .elseif ((Length_Pattern >= $50) .and (Length_Pattern <= $5f))
        .byte Length_Pattern
        Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

      .else
        .error "Duration Error: invalid Length_Pattern (Use ''Cont'' to Omit)"
        .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
        .exitmacro
      .endif

    .endmacro



    .macro Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12
    .ifblank P1
      .exitmacro
    .endif
    
    .ifblank P2
      .error "Duration Error: Even number of pitches required"
      .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
      .exitmacro
    .endif
    
    .if .xmatch(P1, Rest) .or .xmatch(P2, Rest)
        .error "Duration Error: 'rest' must be lowercase"
        .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
        .exitmacro
    .endif

    .if .xmatch (P1, rest) .and .xmatch (P2, rest)  ;.xmatch case sensitive may be fixable w/ .case -  to remove case senstiivity. (Then restore after .macros w/ .case +)
      .byte $00



    .elseif .xmatch (P1, rest)
      .if .const(P2);P2 < C6

        .if P2 < B5
          .byte (P2-BP+1) << 4 ;Noise
        .else
          .byte (P2 & $0F) << 4
        .endif
      
      .else

        .byte (P2-BP+1) << 4 ;[RANGE ERROR] Means BP was wrong
      .endif

    .elseif .xmatch (P2, rest)
      .if .const(P1)
        .if P1 < B5
          .assert ((P1 - BP + 1) >= 1) && ((P1 - BP + 1) <= $0F) || (P1 >= C6), error, "Duration P1 has Invalid BP"
          .byte (P1-BP+1)
        .else
          .byte (P2 & $0F) << 4
        .endif

      .else
        
        .assert ((P1 - BP + 1) >= 1) && ((P1 - BP + 1) <= $0F) || (P1 >= C6), error, "Duration P1 has Invalid BP"
        .byte (P1-BP+1)
      .endif


    
    ;Noise Handling
      .elseif .not .const(P1)
        .assert ((P1 - BP + 1) >= 1) && ((P1 - BP + 1) <= $0F) || (P1 >= C6), error, "Duration Exception: P1 has Invalid BP"

        .if .not .const(P2)
          .byte (P1-BP+1) | ((P2-BP+1) << 4) ;Both Notes

        .else
          .byte (P1-BP+1)| ((P2 & $0F) << 4) ;P1 Note
        .endif

      .elseif .not .const(P2)
        .byte ((P1 & $0F)) | ((P2-BP+1) << 4) ;P2 Note
    ;

    ;Neither are Rests
    .elseif P1 > B5
        .if P2 > B5 
          .byte (P1 & $0F) | ((P2 & $0F) << 4) ;Both Non-Note

        .else
          .byte ((P1 & $0F)) | ((P2-BP+1) << 4) ;P2 Note

        .endif
    .else

        .assert ((P1 - BP + 1) >= 1) && ((P1 - BP + 1) <= $0F) || (P1 >= C6), error, "Duration Exception: P1 has Invalid BP"


        .if P2 > B5  
          .byte (P1-BP+1)| ((P2 & $0F) << 4) ;P1 Note

        .else


          .byte (P1-BP+1) | ((P2-BP+1) << 4) ;Both Notes
            ;
        .endif
    .endif


      Sub_Duration P3,P4,P5,P6,P7,P8,P9,P10,P11,P12 ;Recurse
  .endmacro

  .macro Duration_List DoMacro
        Dur_Index .set 0
        Dur_Opcode .set $50

        DoMacro _00, 1 ;$50
        DoMacro _0000, 2
        DoMacro _6x0, 3
        DoMacro _8x0, 4

        DoMacro _1111, 2 ;$54
        DoMacro _6x1, 3
        DoMacro _8x1, 4 

        DoMacro _2222, 2 ;$57
        DoMacro _6x2, 3
        DoMacro _8x2, 4


        DoMacro _6x8, 3 ;%5a
        DoMacro _8x8, 4

        DoMacro _111_R, 2 ;\ For YV.
        ;DoMacro _4444, 2  ;/

        ; DoMacro _0_00_0_Es, 4   ;\ For KTB
        ; DoMacro _00_0_0_4_Es, 5 ;/


          ;Khevari
        ;DoMacro _332_x2, 3
        ;DoMacro _111_221, 3
        ;DoMacro _111_2_111_b, 4
        
        ;DoMacro _11_100_x2, 5
        ;DoMacro _f_0000_f_1001, 5
        

      .if Dur_Index > $10
        .error "Duration_List Error: Limit of 16 Length Patterns Exceeded"
        .out"        Usage: Duration_List DoMacro, <Length_Pattern Name>, <Length>"
        .exitmacro
      .endif
    .endmacro




    .macro Emit_LUT Name, Size
      .if Size < 0 || Size > 7
        .error "Duration_List Error: Pattern Length Out of Range (0..7)"
        .out"        Usage: Duration_List <Macro_To_Invoke>, <Pattern_Length>, <Length>"
        .exitmacro  ;0 Can mean stop playing Nibble mode. (Useful for the idea to have shift pitch and start another Duration start for 1 Byte total instead of 1 byte each.) (Or for odd ones, entirely save a byte starting another duration if np BP needed.)
      .endif
      .byte ((Size << 5) | (.ident(.concat("adr", .string(Name))) - LUT_Length_Nibbles))
      Set_Name Name
    .endmacro

    .macro Set_Name Name, _ 
      .ident(.string(Name)) .set (Dur_Index + Dur_Opcode)
      Dur_Index .set Dur_Index + 1

  .endmacro




  ; .macro Duration_Emit_LUT Name, Size
  .macro Duration_Lengths Name, Size
      .ifndef Dur_Index
          Dur_Index .set $50
      .endif

      .byte ((Size << 5) | (.ident(.concat("adr", .string(Name))) - LUT_Length_Nibbles))
      .ident(.string(Name)) .set Dur_Index

      ;.ident(.sprintf("DurLen%02x", EnvCDur_Indexount)) = _Name

      Dur_Index .set Dur_Index + 1

      .if Dur_Index > $5f
        .error "Duration_List Error: Limit of 16 Length Patterns Exceeded"
        .out"        Usage: Duration_List DoMacro, <Length_Pattern Name>, <Length>"
        .exitmacro
      .endif

  .endmacro





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

        Sub_Env Name, v1,v2,v3,v4,v5, v6,v7,v8,v9,v10, v11,v12, v13

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


        Sub_Env Name, v1,v2,v3,v4,v5, v6,v7,v8,v9,v10, v11,v12,  0 ;No DMC


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

        Sub_Env Name, v1,0,0,v2,v3, v4,0,0,v5,v6, v7,v8, v9 ;No Attack

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

        Sub_Env Name, v1,0,0,v2,v3, v4,0,0,v5,v6, v7,v8, 0 
            ;No Attack and No DMC

    .else
        .error "Invalid Env Size." ;input "6b", "5b", "4b", or "3b" with quotes.
    .endif

    Name .set Env_Index

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
    .if (atk_len = 1) .or (atk_len > $0F) .or (atk_len < 0)
        .error "Env Error: Attack Length must be 0 or 2..15 (Use the vars atk_1 .. atk_14)" ;Interally represented as 2..15
    .endif                                              ;A one technically functions, but it still skips Atk_Rate

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

    .ident(.sprintf("Row%02x_DmcLow", Env_Index)) = dmc_lowest_d25 +1 ;Likely is off by one.



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





  ;3b blind V1
  ; .macro Output_All_Env ;Output Column Major of all the data.
  ;     LUT_Env_AT_Init:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_AT_Init", I))
  ;                 .byte .ident(.sprintf("Row%02x_AT_Init", I))
  ;             .else
  ;                 .byte $00

  ;             .endif
  ;         .endrepeat

  ;     ; .align 16, $11
  ;     ; .res 16, $11

  ;     LUT_Env_AT_Rate:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_AT_Rate", I))
  ;                 .byte .ident(.sprintf("Row%02x_AT_Rate", I))
  ;                 .else
  ;                 .byte $00

  ;             .endif
  ;         .endrepeat


  ;     ; .align 16, $11
  ;     ; .res 16, $11

      
  ;     LUT_Env_Decay_Init:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_Decay_Init", I))
  ;                 .byte .ident(.sprintf("Row%02x_Decay_Init", I))
  ;                 .else
  ;                 .byte $00
  ;             .endif
  ;         .endrepeat

  ;     ; .align 16, $11
  ;     ; .res 16, $11

      
  ;     LUT_Env_Decay_Rate:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_Decay_Rate", I))
  ;                 .byte .ident(.sprintf("Row%02x_Decay_Rate", I))
  ;                 .else
  ;                 .byte $00
  ;             .endif
  ;         .endrepeat


  ;     ; .align 16, $11
  ;     ; .res 16, $11

      
  ;     LUT_Env_Sustain:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_Sustain", I))
  ;                 .byte .ident(.sprintf("Row%02x_Sustain", I))
  ;                 .else
  ;                 .byte $00
  ;             .endif
  ;         .endrepeat


  ;     ; .align 16, $11
  ;     ; .res 16, $11

      
  ;     LUT_env_dmc_lowest_25_pitch:
  ;         .repeat Env_Index, I
  ;             .ifdef .ident(.sprintf("Row%02x_DmcLow", I))
  ;                 .byte .ident(.sprintf("Row%02x_DmcLow", I))
  ;                 .else
  ;                 .byte $00
  ;             .endif
  ;         .endrepeat

  ; .endmacro

  .macro Env_Change new_pointer, Supress_Warning

    .ifblank Supress_Warning
      
      .assert new_pointer^current_env_bank <= 15, warning, "Env in different bank. Requires Env_Change_Bank.  Env_Change <env>, 'F'  to supress warning."
    
    .endif
    
    .byte $e0 | (new_pointer & $f)
  .endmacro 

  .macro Env_Change_Bank new_pointer ;ERROR  current_env_bank  is not updated.  .set  makes it non-.const -> errors.

    ;current_env_bank = new_pointer

    .byte Set_Env_Bank_Byte, new_pointer  ;$f9, <id>

  .endmacro


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

 

  .macro Header Base_Pitch, Enveleope, Cont_Tag


    .if .xmatch(Cont_Tag, "Cont")
    .else
      Set_Pitch_Header Base_Pitch
      .byte Enveleope
    .endif 

    current_env_bank = Enveleope
    Set_BP Base_Pitch

  .endmacro




  .macro Noise_Header Noise_Bank, Kick_Type, Cont_Tag
    .if .xmatch(Cont_Tag, "Cont")
    .else
      Set_Pitch_Header Noise_Bank, Kick_Type
      ;.byte Enveleope
    .endif 

    Set_BP Noise_Bank, Kick_Type

  .endmacro


  .macro Inc_Page Label, Scoped
    .assert (>* +1) = >Label, error, "Inc_Page Error: Destination Label not in the next page."

    .byte Inc_Page_Byte, <Label

    ; ::Label .set BP
    .ifnblank Scoped
      .ident(.sprintf("%s_BP", .string(Label))) .set BP
      .endscope
    .endif

  .endmacro


  .macro Loop Pointer, Intro_Ptr

    .assert ( (>Pointer = >*) .or (<* = $00) ), error, "Channel Overflowing Page"
        
    .ifblank Intro_Ptr
      .byte $c0

    .elseif .xmatch (Intro_Ptr, "Riffed")
      ;pass

    .else
      .byte $c1, <Intro_Ptr
      
    .endif

    .endscope

  .endmacro
 

  SFX_PTR_ADJUST .set 2   ; hardcoded offset
  NoiseFX_Index .set 0 ;INIT

  .macro NoiseFX _Name, _Noise, _Dmc 
          ;_Tri,   disabled.

      .ifndef NoiseFX_Index
          NoiseFX_Index .set 0
      .endif

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


  .macro lda_GameFX _Name
      lda #_Name-LUT_SFX_Data + SFX_PTR_ADJUST

  .endmacro

  .macro SFX_Byte _Name

    .byte _Name-LUT_SFX_Data + SFX_PTR_ADJUST

  .endmacro


  .macro Output_All_NoiseFX

    ; .ifndef NoiseFX_Index
    ;   NoiseFX @Empty_PlaceHolder, $00, $00 ;, $00
    ; .endif

    ;   .res 16, $AA
    ; .align 16,$AA
    ; LUT_Tri_SFX_Ptr:
    ;     .repeat NoiseFX_Index, I
    ;         .ifconst .ident(.sprintf("NoiseRow%02x_Tri", I))
    ;             .byte .ident(.sprintf("NoiseRow%02x_Tri", I))
    ;         .else
    ;             .byte (.ident(.sprintf("NoiseRow%02x_Tri", I)) - LUT_SFX_Data + SFX_PTR_ADJUST)
    ;         .endif
    ;     .endrepeat


    LUT_Noise_SFX_Ptr:
        .repeat NoiseFX_Index, I
            .ifconst .ident(.sprintf("NoiseRow%02x_Noise", I))
                .byte .ident(.sprintf("NoiseRow%02x_Noise", I))
            .else
                .byte (.ident(.sprintf("NoiseRow%02x_Noise", I)) - LUT_SFX_Data + SFX_PTR_ADJUST)
            .endif
        .endrepeat

    
    LUT_DMC_SFX_Ptr:
      .repeat NoiseFX_Index, I
          .ifconst .ident(.sprintf("NoiseRow%02x_Dmc", I))
              .byte .ident(.sprintf("NoiseRow%02x_Dmc", I))
          .else
              .byte (.ident(.sprintf("NoiseRow%02x_Dmc", I)) - LUT_SFX_Data + SFX_PTR_ADJUST)
          .endif
      .endrepeat

  .endmacro



  .macro Notes L1,P1, L2,P2, L3,P3, L4,P4, L5,P5, L6,P6, L7,P7, L8,P8, L9,P9, L10,P10

  
      .ifblank L1
          .exitmacro
      .endif

      .if .xmatch(P1, Rest)
          .error "Notes Error: 'rest' must be lowercase"
          .out"        Usage: Notes <Length>,<Pitch>, <Length>,<Pitch>, ..."
          .exitmacro
      .endif


      .if .xmatch(L1, 8th)
        Sub_Note 1,P1
      .elseif .xmatch(L1, qtr)
        Sub_Note 2,P1
      .elseif .xmatch(L1, dqt)
          Sub_Note 3,P1
      .elseif .xmatch(L1, hlf)
          Sub_Note 4,P1
      .elseif .xmatch(L1, dhf)
          Sub_Note 6,P1
      .elseif .xmatch(L1, whl)
          Sub_Note 8,P1

      .elseif ((L1 >= 1) .and (L1 <= 255))
             Sub_Note 0,P1
             .byte L1

      .else
          .error "Notes Error: Invalid Note length. Must be 8th,qtr,dqt,hlf,dhf,whl or 1–255 (raw frames)."
          .out"        Usage: Notes <Length>,<Pitch>, <Length>,<Pitch>, ..."
          .exitmacro
      .endif

          Notes L2,P2, L3,P3, L4,P4, L5,P5  ;Recursion

    .endmacro




    .macro Sub_Note Length, Pitch
      .ifblank Pitch
          .error "Notes Error: Missing Pitch parameter for given Length."
          .out"        Usage: Notes <Length>, <Pitch>, <Length>, <Pitch>, ..."
          .exitmacro
      .endif


      .if .xmatch (Pitch, rest)
        .byte Length << 4 ;Rest

      .else ;Valid
        .byte (Length << 4) | (Pitch - BP + 1)
        
        .assert (Pitch >= A0) && (Pitch <= B5), error, "Notes Error: Pitch out of valid range (A0 to B5)"
        .assert ((Pitch - BP + 1) >= 1) && ((Pitch - BP + 1) <= $0F), error, "Notes Error: Pitch out of BP's current range (1...15)" ;Can Output the Pitch value, cuz it isn't constant. For petes...

      .endif

  .endmacro




  ; Format:  ;Repeat "4b", 3 to repeat 4 bytes, 3 times.
  ; Alt:     Repeat _Label, 3  to jump back to _Label 3 times
  .macro Repeat Size, Count

    .if .xmatch(Size, "5b") ;Hard-coded versions.
        Sub_Repeat 5, Count

    .elseif .xmatch(Size, "4b")
        Sub_Repeat 4, Count

    .elseif .xmatch(Size, "3b")
        Sub_Repeat 3, Count

    .elseif .xmatch(Size, "2b")
        Sub_Repeat 2, Count

    .elseif .xmatch(Size, "1b")
        Sub_Repeat 1, Count

    
    ;.elseif .not .const(Size)
    .elseif .defined(Size)
      Sub_Repeat *-Size, Count


    .else   ;[ERROR] This won't trigger under most cases. 
        .error "Repeat Error: Unrecognized Label or Malformed Tag."
        .out "Repeat Error: Unrecognized Label or Malformed Tag."
        .out "    Usage: Repeat <Label>, <Count>  (Size = * - Label)"  
        .out "           Repeat ''xb'',  <Count>  (valid: 5b..1b in Qutoes)"
    .endif

    .endmacro



    .macro Sub_Repeat Size, Count

    .ifblank Count
        .error "Repeat Error: Missing Repeat Count."
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
        .exitmacro
    ;

    .elseif .xmatch(Count, "Inf")
        .if Size > 4
            .error .sprintf("Repeat Error: Long repeat count >= 8 only valid for Size 1..4 (Input Size: %d)", Size)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
            .exitmacro
        .endif

      .byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), $ff 
        ;Infinite Repeats read as negetive values.

    .elseif Size = 1
        .if Count < 3
            .warning .sprintf("Repeat Warning: Count %d is too small for '1b' Repeat (use Count >= 3 or unroll).", Count)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
        .endif

        .if Count > 128
            .error .sprintf("Repeat Error: Repeat count must be <= 128 or 'Inf' (Input Count: %d)", Count)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
            
        .endif

        ;.byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), Count ;Effective Size is +1
        .byte $91, Count  ;$91 is "1b", <custom>

    .elseif Count >= 8

        .if Count > 128
            .error .sprintf("Repeat Error: Repeat count must be <= 128 or 'Inf' (Input Count: %d)", Count)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
            
        .endif

        .if Size > 4
            .error .sprintf("Repeat Error: Long repeat count >= 8 only valid for Size 1..4 (Input Size: %d)", Size)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
            .exitmacro
        .endif


        .byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), Count 

    ;


    .else ; Count < 8 

        .if Size > 5
            .error .sprintf("Repeat Error: Short repeat count < 8 only valid for Size 2..5 (Input Size: %d)", Size)
            .out"        Usage: Repeat <Size 1>,    <Count 3..128 or 'Inf'>"  
            .out"               Repeat <Size 2..4>, <Count 8..128 or 'Inf'>"
            .out"               Repeat <Size 2..5>, <Count 1..7>"
            .exitmacro
        .endif

        .byte $80 + (((Size) & 6) << 3) + (((Size) ^ 1) & 1) + (Count << 1)
    ;

    .endif
  .endmacro





  .macro Riff id, Length, Explicit_Type
    .ifblank Length
        .error "Riff Error: Missing Length/End label"
        .out "    Usage: Riff <Start_Label>, <End_Label> [, ''3b'']"
        .out "           Legacy: Riff <Length>, <End_Label>  ;raw byte count"
        .exitmacro
    .endif

    .assert (>* = >(id)), warning, "Riff Warning: Page Crossed"

    .if .const (Length) ;Number Version
      .if Length < 32
        .byte $c0|Length, <(id) ;Can make it length -1 and replace the add Length  w/ sec, adc.

        .if Length <= 2
          .error "Riff Error: Re-read length must be 3..255 bytes."
          .out  "  Usage: Riff <Start_label>, <End_label>"
          .out  "  Usage: Riff <Start_label>, <Length (3..255)>"
        .endif

      .else
        .byte $c2, Length, <(id)
      .endif

    .else ;Label Version
      .ifblank Explicit_Type
        .byte $c0|((Length)-(id)), <(id)
          .assert ((Length)-(id) < 32), error, "Riff Error: Explicit 3-Byte marker is required here"
          .assert ((Length)-(id) < 32), error, "     Usage: Riff <Start_label>, <End_label>, <''3b''>"

          .assert ((Length)-(id) >= 3), error, "Riff Error: Re-read length must be 3..255 bytes."
          .assert ((Length)-(id) >= 3), error, "     Usage: Riff <Start_label>, <End_label>"

      .else
        .byte $c2, (Length)-(id), <(id)
          .assert ((Length)-(id) >= 32), warning, "Riff Warning: Explicit 3-Byte marker is not needed here"
          .assert ((Length)-(id) >= 32), warning, "     Usage: Riff <Start_label>, <End_label>"

      .endif
    .endif
  .endmacro



  .macro Shift_Pitch before, after, update_bp
    .ifblank after

      Sub_Shift_Pitch before, update_bp ;update_bp doubling as Supress_Warnings?

    .else

      .if before = BP
      .elseif .blank (update_bp)  ;Lazy Way to skip warnings w/ mixed signals

      .if before <> BP .and .blank (update_bp)
          ;.error .sprintf("Shift_Pitch Error: Internal BP (%d) does not match Source_Pitch (%d)", BP, before)
          ; .out "    Usage: Shift_Pitch <Start_Pitch>, <Target_Pitch> [, Suppress_Warning]"
          ; .out "    [NOTE]: Internal BP desyncs after Repeats/Riffs that use Shift_Pitch."
          ; .out "        Correct manually after sequences:"
          ; .out "             BP .set BP + <delta>"
          ; .out "             BP .set <correct_pitch>"
          ; .exitmacro
      .endif

      .endif
      Sub_Shift_Pitch after-before, update_bp

    .endif
    .endmacro



    .macro Sub_Shift_Pitch shift, update_bp
      .if .xmatch(shift, -Octave) || shift = -12
          .byte Minus_Octave ;Defined in New_Note

          .ifblank update_bp
            BP .set BP-12
          .endif

      .elseif .xmatch(shift, +Octave) || shift = 12
          .byte Plus_Octave

          .ifblank update_bp
           BP .set BP+12
          .endif

      .elseif ((shift) < -7) || ((shift) > 7)
          .error .sprintf("Shift_Pitch Error: Shift value out of range (Input: %d, valid: -7..7 or +/-Octave)", shift)
          .out   "    Usage: Shift_Pitch <Start_Pitch>, <Target_Pitch> ; e.g., A3 to G3"
          .out   "    Usage: Shift_Pitch <Shift> ; e.g., -2"
          .out   "        Note: Usage Set_Pitch <Note> if Shift not in range"
          .exitmacro

      .else ;Normal
        .byte $b0 | ((shift) & $0F)

        .ifblank update_bp
         BP .set BP+shift
        .endif

      .endif
    .endmacro

    .macro Set_Pitch pitch, vibrato_depth

      .ifblank pitch
        .error "Set_Pitch Error: Missing pitch param"
        .exitmacro
      .elseif pitch > $3f
        .error "Set_Pitch Error: Pitch out of Range A0..B5"
        .exitmacro
      .endif

      .ifblank vibrato_depth

        .byte $b8, ( (pitch<<2) |1) ;Default depth is 1

      .elseif .xmatch(vibrato_depth, +Octave)
        .byte $b8, ( (pitch<<2) |2) ;2 is 0.5x Normal

      .elseif .xmatch(vibrato_depth, -Octave)
        .byte $b8, ( (pitch<<2) |0) ;0 is 2x Normal

      .elseif vibrato_depth <= 3 ;3 just alternates 0 and -1

        .byte $b8, ( (pitch<<2) |vibrato_depth)

      .else
          .error "Set_Pitch Error: Vibrato Depth out of Range 0..3"
          .exitmacro
        .endif

      Set_BP (pitch)

    .endmacro


    .macro Set_Pitch_Header pitch, vibrato_depth
      .ifblank pitch
        .error "Header Error: Missing pitch param"
        .exitmacro
      .elseif pitch > $3f
        .error "Header Error: Pitch out of Range A0..B5"
        .exitmacro
      .endif

      .ifblank vibrato_depth

        .byte ( (pitch<<2) |1) ;Default depth is 1  / d25 Kick

      .elseif .xmatch(vibrato_depth, +Octave)
        .byte ( (pitch<<2) |2) ;2 is 0.5x Normal

      .elseif .xmatch(vibrato_depth, -Octave)
        .byte ( (pitch<<2) |0) ;0 is 2x Normal

      .elseif vibrato_depth <= 3 ;3 just alternates 0 and -1

        .byte ( (pitch<<2) |vibrato_depth)

      .else
          .error "Header Error: Vibrato Depth out of Range 0..3"
          .exitmacro
        .endif

      Set_BP (pitch)
    .endmacro


    .macro Set_BP pitch, ignored_octave_flags
    BP .set pitch

  .endmacro



    .ifndef Song_Index
      Song_Index .set 0

      UI_Text_Index .set 0 ;Init

      UI_Word_Index .set 0
      UI_Word_Text_Index .set 0

    
    .endif



.macro Song Name, Len, Song_UI_Text
    .local Sq0, Sq1, Tri, Noise, Dmc

    .if Song_Index > 61
      .error "Song Error: Max Index exceeded (0..61)" ;61*5 = 255
      .exitmacro

    .elseif .xmatch(Name, "Silence")
      Song_Silence  ;Macro to emit minimal data.
      .exitmacro

    ; guard
    .elseif .defined(.ident(.concat(.string(Name), "_SongDefined")))
      .error "Song already defined: " .string(Name)
      .exitmacro
    .endif

      ; assign index
      .ident(.concat(.string(Name), "_Index")) .set Song_Index

      ; resolve symbols
      Sq0   = .ident(.concat(.string(Name), "_Sq0"))
      Sq1   = .ident(.concat(.string(Name), "_Sq1"))
      Tri   = .ident(.concat(.string(Name), "_Tri"))
      Noise = .ident(.concat(.string(Name), "_Noise"))
      Dmc   = .ident(.concat(.string(Name), "_dmc"))

      ; store row
      .ident(.sprintf("Song%02x_Sq0", Song_Index)) = Sq0
      .ident(.sprintf("Song%02x_Sq1", Song_Index)) = Sq1
      .ident(.sprintf("Song%02x_Tri", Song_Index)) = Tri
      .ident(.sprintf("Song%02x_Noise", Song_Index)) = Noise
      .ident(.sprintf("Song%02x_Dmc", Song_Index)) = Dmc

      .ident(.sprintf("Song%02x_Len", Song_Index)) = Len

      .if Len = 0 .or Len > 32
        .warning .sprintf("Song Warning: Tempo > 32 causes 8-bit overflow; note lengths become non-monotonic. Given Tempo = %u", Len)
      .endif 

    ;----------------------------------------
    ; UI text start index
    ;----------------------------------------

  .ident(.sprintf("Song%02x_UI_Start", Song_Index)) = UI_Text_Index

  Collect_UI_Text Song_UI_Text

  Song_Index .set Song_Index + 1

  ; mark defined
  .ident(.concat(.string(Name), "_SongDefined")) = 1

  .endmacro


  .macro Song_Silence
 
      
      ; write fixed pointers
      .ident(.sprintf("Song%02x_Sq0",   Song_Index)) = Inf_Wait-2
      .ident(.sprintf("Song%02x_Sq1",   Song_Index)) = Inf_Wait-2
      .ident(.sprintf("Song%02x_Tri",   Song_Index)) = Inf_Wait-2
      .ident(.sprintf("Song%02x_Noise", Song_Index)) = Inf_Wait-1
      .ident(.sprintf("Song%02x_Dmc",   Song_Index)) = Inf_Wait-2

      ; length = 0
      .ident(.sprintf("Song%02x_Len", Song_Index)) = 0

      ;Store nothing, but let the index exist.
      .ident(.sprintf("Song%02x_UI_Start", Song_Index)) = UI_Text_Index
      Collect_UI_Text

      ; advance index
      Song_Index .set Song_Index + 1

  .endmacro


  .macro Output_All_Songs


    Max_Track_Index .set Song_Index

    ; -------------------------
    ; Length table
    ; -------------------------
    LUT_Song_8th_Length:
      .repeat Song_Index, I
        .byte .ident(.sprintf("Song%02x_Len", I))
      .endrepeat


    ; -------------------------
    ; Pointer LOW (row-major, 5 per song)
    ; -------------------------
    LUT_Song_Ptr_Low:
      .repeat Song_Index, I
        .byte <.ident(.sprintf("Song%02x_Sq0", I))
        .byte <.ident(.sprintf("Song%02x_Sq1", I))
        .byte <.ident(.sprintf("Song%02x_Tri", I))
        .byte <.ident(.sprintf("Song%02x_Noise", I))
        .byte <.ident(.sprintf("Song%02x_Dmc", I))
      .endrepeat


    ; -------------------------
    ; Pointer HIGH
    ; -------------------------
    LUT_Song_Ptr_High:
      .repeat Song_Index, I
        .byte >.ident(.sprintf("Song%02x_Sq0", I))
        .byte >.ident(.sprintf("Song%02x_Sq1", I))
        .byte >.ident(.sprintf("Song%02x_Tri", I))
        .byte >.ident(.sprintf("Song%02x_Noise", I))
        .byte >.ident(.sprintf("Song%02x_Dmc", I))
      .endrepeat

.endmacro





;----------------------------------------
;UI Macros
;----------------------------------------
  .macro Collect_UI_Text v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20



    .ifblank v1
      .exitmacro
    .endif

    ; 256 bytes cannot be represented by an 8-bit start index.
    .if UI_Text_Index > 255
      .error "Song UI Text Error: Maximum UI text size is 256 bytes"
      .exitmacro
    .endif

    ; Store byte
    .ident(.sprintf("UI_Text_%02x", UI_Text_Index)) = v1

    ; Advance global text index
    UI_Text_Index .set UI_Text_Index + 1

    ; Continue with remaining variables
    Collect_UI_Text v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20

  .endmacro

  .macro Output_UI_Text

    ;----------------------------------------
    ; UI text bytes
    ;----------------------------------------
    LUT_Song_Names_Text:

      .repeat UI_Text_Index, I
        .byte .ident(.sprintf("UI_Text_%02x", I))
      .endrepeat


    ;----------------------------------------
    ; UI text start indexes
    ;----------------------------------------
    LUT_Name_Start_Indexes:

      .repeat Song_Index, I
        .byte .ident(.sprintf("Song%02x_UI_Start", I))
      .endrepeat

      ; ; End of final song / start of next song
      .byte UI_Text_Index
        ;Having Song_Silence should do it.

  .endmacro


  .macro UI_Word Name, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20

    .ident(.string(Name)) = UI_Word_Text_Index|$80
    Collect_UI_Word_Text v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20

  .endmacro



  .macro Collect_UI_Word_Text v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20

    .ifblank v1
      .exitmacro
    .endif


    .if UI_Word_Text_Index > $7e
      .error "UI Word Error: LUT_Words_Text exceeds max LUT size of 127 bytes"
      .exitmacro
    .endif

    ; .if (v1 > $7f) .and .not .blank (v2)
    ;   .error "UI_Words cannot nest."
    ; .endif


    .ident(.sprintf("UI_Word_%02x", UI_Word_Text_Index)) = v1

    UI_Word_Text_Index .set UI_Word_Text_Index + 1

    ;----------------------------------------
    ; Recurse
    ;----------------------------------------
    Collect_UI_Word_Text v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20

  .endmacro

  ;
    UI_Word _LOGO, _T, _R, _I, _dash, \
    _P, _U, _L, _S, _E, _spc, \
    _S, _T, _U, _D, _I, _O, _S|$80
  

.macro Output_UI_Words

  LUT_Words_Text:

    .repeat UI_Word_Text_Index, I
      .byte .ident(.sprintf("UI_Word_%02x", I))
    .endrepeat

.endmacro





 
  .macro Simple_SFX Name, BP, Sweep, Len, Envelope

    .ident(.string(Name)):

    .byte ((BP)*2-Sweep)|$80

    .ifnblank Len
      
      .byte Len+1, Envelope, (Sweep & $ff)

    .endif
    .endmacro



    .macro Complex_SFX Name, BP, Len, Envelope ;Ironicly simpler macro. Complexity is in Music Data

    Name:
    ; .ident(.string(Name)):

    .if BP > $f 
      .byte BP|$80 ;Sq/Tri must be stored pre-dec'ed already.
    .else
      .byte ((BP-1) & $ff)|$80 ;-1 for Rate index
    .endif

    
    .ifnblank Len
    .byte Len+1, Envelope
    .endif

  .endmacro

  .macro NB_Validate _Name
      .assert NoiseFX_Index - _Name < 16, error, "Exceeded 15 Noise_FX window"
  .endmacro




  ;Define Vol Names
    .define Vol_100 0  ;Number of 1/8ths to subtract from volume.
    .define Vol_87  1
    .define Vol_75  2
    .define Vol_62  3
    .define Vol_50  4
    .define Vol_37  5
    .define Vol_25  6
    .define Vol_12  7

    ;.define is the only way to make these vars constant for .if's
  ;

  .macro Vol_Fade_In Start, Target, f_Delay

    .byte $f0|Start,  f_Delay << 3 | Target

      ; Range checks
        .if Start > 7
            .error .sprintf("Fade_In Error: Start Volume out of range (0..7) (got: %d)", Start)
            .out   "    Usage: Vol_Fade_In <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_In  Vol_12,  Vol_100,  15"
            .exitmacro

        .elseif Target > 7
            .error .sprintf("Fade_In Error: Target Volume out of range (0..7) (got: %d)", Target)
            .out   "    Usage: Vol_Fade_In <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_In  Vol_12,  Vol_100,  15"
            .exitmacro

        .elseif f_Delay > 31 .or f_Delay=0
            .error .sprintf("Fade_In Error: Frame_Delay out of range (1..31) (got: %d)", f_Delay)
            .out   "    Usage: Vol_Fade_In <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_In  Vol_12,  Vol_100,  15"
            .exitmacro

        .elseif Start < Target
            .error .sprintf("Fade_In Error: Recieved Fade_Out Data (got: %d to %d)", Start, Target)
            .out   "    Usage: Vol_Fade_In <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_In  Vol_12,  Vol_100,  15"
            .exitmacro
        .endif
      ;

    .endmacro

    .macro Vol_Fade_Out Start, Target, f_Delay

      .byte $f0|Start,  f_Delay << 3 | Target

      ; Range checks
        .if (Start < 0) .or (Start > 7)
            .error .sprintf("Fade_Out Error: Start Volume out of range (0..7) (got: %d)", Start)
            .out   "    Usage: Vol_Fade_Out <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_Out  Vol_100,  Vol_12,  15"
            .exitmacro

        .elseif (Target < 0) .or (Target > 7)
            .error .sprintf("Fade_Out Error: Target Volume out of range (0..7) (got: %d)", Target)
            .out   "    Usage: Vol_Fade_Out <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_Out  Vol_100,  Vol_12,  15"
            .exitmacro

        .elseif f_Delay > 31 .or f_Delay=0
            .error .sprintf("Fade_Out Error: Frame_Delay out of range (1..31) (got: %d)", f_Delay)
            .out   "    Usage: Vol_Fade_Out <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_Out  Vol_100,  Vol_12,  15"
            .exitmacro

        ; Direction check (quieter)
        .elseif Start > Target
            .error .sprintf("Fade_Out Error: Recieved Fade_In Data (got: %d to %d)", Start, Target)
            .out   "    Usage: Vol_Fade_Out <Start>, <Target>, <Frame_Delay>"
            .out   "       ie: Vol_Fade_Out  Vol_100,  Vol_12,  15"
            .exitmacro
        .endif
      ;

  .endmacro

  .macro Volume_Set Volume

    .byte $f0|Volume,  0 << 3 | Volume
      ;Set Volumes are still Two Bytes, and they must specify the Volume Twice.
        ;It also disables f-effect reseting.

        .if Volume > 7
            .error .sprintf("Volume_Set Error: Start Volume out of range (0..7) (got: %d)", Volume)
            .out   "    Usage: Volume_Set  <Volume>"
            .out   "       ie: Volume_Set   Vol_12"
            .exitmacro
        .endif

  .endmacro

;





;if/else/elif/endif idea
;elif is VERY tricky though...
;even just having to track different labels for each is a stretch.

  ;rough draft from chatgpt

  ;idea:
  ;expand

    ; if minus
    ;     lda #$00

    ; else
    ;     lda #$01

    ; end_if
  ;to

    ; bpl @else_000  ;Note the opposite branch
    ;     lda #$00

    ; jmp @skip_else_000
    ; @else_000:
    ;     lda (section_data),y

    ; @skip_else_000:


  ; Initialize a macro counter
  ; .define IF_COUNTER 0

  ; .macro if condition
  ;     .define _IF_ID "IF_" + .string(IF_COUNTER)
  ;     .define _ELSE_LABEL "@else_" + .string(IF_COUNTER)
  ;     .define _END_LABEL "@skip_else_" + .string(IF_COUNTER)

  ;     ; Update IF_COUNTER
  ;     .undef IF_COUNTER
  ;     .define IF_COUNTER {IF_COUNTER + 1}

  ;     ; Branch based on the condition (inverted)
  ;     .if .strcmp(\condition, "minus")
  ;         bpl {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "plus")
  ;         bmi {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "sec")
  ;         bcc {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "clc")
  ;         bcs {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "zero")
  ;         bne {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "nonzero")
  ;         beq {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "sev")
  ;         bvc {_ELSE_LABEL}
  ;     .elseif .strcmp(\condition, "clv")
  ;         bvs {_ELSE_LABEL}
  ;     .else
  ;         .error "Unknown condition passed to .if"
  ;     .endif
  ; .endmacro

  ; .macro else
  ;     jmp {_END_LABEL}
  ; {_ELSE_LABEL}:
  ; .endmacro

  ; .macro end_if
  ; {_END_LABEL}:
  ; .undef _IF_ID
  ; .undef _ELSE_LABEL
  ; .undef _END_LABEL
  ; .endmacro


;








;Tmp Renaming:
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

















