

;===============================================================
;Scaffolding
;===============================================================




   ;LOTS of errors?  Likely ended a scope w/o starting one or vice versa
  .macro Channel Label, Scope_Name
    Label:

    .scope Scope_Name  ;If Blank,  Un-Named
    _8th = ::_8th




    Define_Pitches ;a0 = 0, as0 = 1 ,etc
    Duration_List Set_Name ;redefine Durations in scope

  .endmacro



  .macro Define_Pitches
      Octave = $40 ;Old Data Format.

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

      C6 = $3f

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

  .endmacro

  Define_Pitches ;Define them Globally.






 

  .macro Header _BP, _Env, Vib_Depth, Cont_Tag

    .ifblank _Env
        .error "Header Error: Missing Env Param."
        .out "Header Error: Missing Env Param."
        .out ""
    .endif 

    .ifblank _BP
        .error "Header Error: Missing BP Param."
        .out "Header Error: Missing BP Param."
        .out ""
    .endif


    .if .xmatch(Cont_Tag, "Cont")
        ;pass
    .elseif .not .blank (Cont_Tag)
        .error "Header Error: Invalid Cont Tag."
        .out "Header Error: Invalid Cont Tag. Expects the string \"Cont\" "
        .out ""

    .elseif .xmatch(Vib_Depth, "Cont")
        .ifnblank Cont_Tag
            .error "Header Error: Inccorect inputs. Cont tag must be last param."
            .out "Header Error: Inccorect inputs. Cont tag must be last param."
            .out ""
        .endif
    .else
      Set_Pitch_Data _BP, Vib_Depth
      .byte _Env

    .endif 
 


    EB .set ::_Env & $f0
        ;Envelope Bank

    BP .set _BP
        ;Base Pitch

  .endmacro


  .macro Noise_Header Noise_Bank, Kick_Type, Cont_Tag

    .ifblank Noise_Bank
        .error "Header Error: Missing NB Param."
        .out "Header Error: Missing Noise Bank Param."
        .out ""
    .endif 


    .if .xmatch(Cont_Tag, "Cont")
        ;pass
    .elseif .not .blank (Cont_Tag)
        .error "Header Error: Invalid Cont Tag."
        .out "Header Error: Invalid Cont Tag. Expects the string \"Cont\" "
        .out ""
    .else
        Set_Pitch_Data Noise_Bank, Kick_Type

    .endif 

    BP .set Noise_Bank

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

;

;===============================================================
;Notes
;===============================================================

    .macro Notes L1,P1, L2,P2, L3,P3, L4,P4, L5,P5, L6,P6, L7,P7, L8,P8, L9,P9, L10,P10



        .ifblank L1
            .exitmacro
        .endif

        .if .xmatch(P1, Rest)
            .error "Notes Error: `rest` must be lowercase"
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


        .else
            Assert_Valid_Pitch ::Pitch, "Notes Pitch Error"

            .byte (Length << 4) | (Pitch - BP + 1)



        .endif

    .endmacro

;

;===============================================================
;Compression Instructions
;===============================================================


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
            .out "           Repeat \"xb\",  <Count>  (valid: 5b..1b in Qutoes)"
        .endif

    .endmacro



    .macro Sub_Repeat Size, Count

        .ifblank Count
            .error "Repeat Error: Missing Repeat Count."
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
            .exitmacro
        ;

        .elseif .xmatch(Count, "Inf")
            .if Size > 4
                .error .sprintf("Repeat Error: Long repeat count >= 8 only valid for Size 1..4 (Input Size: %d)", Size)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
                .exitmacro
            .endif

        .byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), $00
            ;Infinite Repeats read as negetive values.

        .elseif Size = 1
            .if Count < 3
                .warning .sprintf("Repeat Warning: Count %d is too small for \"1b\" Repeat (use Count >= 3 or unroll).", Count)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
            .endif

            .if Count > 128
                .error .sprintf("Repeat Error: Repeat count must be <= 128 or \"Inf\" (Input Count: %d)", Count)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
                
            .endif

            ;.byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), Count ;Effective Size is +1
            .byte $91, Count  ;$91 is "1b", <custom>

        .elseif Count >= 8

            .if Count > 128
                .error .sprintf("Repeat Error: Repeat count must be <= 128 or \"Inf\" (Input Count: %d)", Count)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
                
            .endif

            .if Size > 4
                .error .sprintf("Repeat Error: Long repeat count >= 8 only valid for Size 1..4 (Input Size: %d)", Size)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
                .out"               Repeat <Size 2..5>, <Count 1..7>"
                .exitmacro
            .endif


            .byte $80 + (((Size+1) & 6) << 3) + (((Size+1) ^ 1) & 1), Count 

        ;


        .else ; Count < 8 

            .if Size > 5
                .error .sprintf("Repeat Error: Short repeat count < 8 only valid for Size 2..5 (Input Size: %d)", Size)
                .out"        Usage: Repeat <Size 1>,    <Count 3..128 or \"Inf\">"  
                .out"               Repeat <Size 2..4>, <Count 8..128 or \"Inf\">"
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
            .out "    Usage: Riff <Start_Label>, <End_Label> [, \"3b\"]"
            .out "           Legacy: Riff <Length>, <End_Label>  ;raw byte count"
            .out ""
            .exitmacro
        .endif

        .assert (>* = >(id)), warning, "Riff Warning: Page Crossed"

        .if .const (Length) ;Raw Number Version
            .if Length < 32
                .byte $c0|Length, <(id) ;Can make it length -1 and replace the add Length  w/ sec, adc.

                .if Length <= 2
                    .error "Riff Error: Re-read length must be 3..255 bytes."
                    .out  "  Usage: Riff <Start_label>, <End_label>"
                    .out  "  Usage: Riff <Start_label>, <Length (3..255)>"
                    .out ""
                .endif

            .else
                .byte $c2, Length, <(id)
            .endif

        .else ;Two Labels Version
            .ifblank Explicit_Type
                .byte $c0|((Length)-(id)), <(id)
                .assert ((Length)-(id) < 32), error, "Riff Error: Explicit 3-Byte marker Required"

                .assert ((Length)-(id) >= 3), error, "Riff Error: Re-read length must be 3..255 bytes."

            .else
                .byte $c2, (Length)-(id), <(id)
                .assert ((Length)-(id) >= 32), warning, "Riff Warning: Explicit 3-Byte marker is not needed here"

                .assert ((Length)-(id) >= 3), error, "Riff Error: Re-read length must be 3..255 bytes."
            .endif
        .endif
    .endmacro



    ;===========================================================
    ;If_Alt
    ;===========================================================
    .macro If_Alt _Old, _New, Supress_Warning

        .if .xmatch(_Old, "Toggle")
            .byte $70
            .exitmacro
        .endif

        .ifblank _New
            .byte $70 | (_Old & $f) ;Raw, Unchecked Delta


            ; .error "If_Alt Error: Invalid syntax"
            ; .out   "    Usage: If_Alt <Unmodified>, <Modified>"
            ; .out   "           If_Alt \"Toggle\""
            
            .exitmacro



        .elseif .xmatch(_Old,rest)
            .byte $70 | ((_New - BP + 1) & $f)
            Assert_Valid_Pitch ::_New, "If_Alt _New Pitch Error"
            .exitmacro

                

        .elseif .xmatch(_New,rest)
            .byte $70 | ((-1 * (_Old - BP + 1) )& $f) ;The Negetive may be backward
            Assert_Valid_Pitch ::_Old, "If_Alt _Old Pitch Error"

            .exitmacro


        .elseif .const(_Old) && .const(_New)
            .if _Old = _New
                .error "If_Alt Error: Delta is zero (conflicts with Toggle command)"
                .out   "    Usage: If_Alt <Unmodified>, <Modified>"
                .out   "           If_Alt \"Toggle\""
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

    .macro Assert_Valid_Pitch Pitch, Error_Message

        .if (Pitch < A0) || (Pitch > B5)
                .error "Pitch Error: Invalid Pitch"
                .out Error_Message
                .out .sprintf("    Pitch out of valid range: A0 (0.8) to B5 (5.11). Given Pitch: %d.%d.", (Pitch+9) / 12, (Pitch+9) .mod 12)
                .out ""
        
        .elseif ((Pitch - BP + 1) < 1) || ((Pitch - BP + 1) > $0F)
            .error "Pitch Error: Pitch out of BP's Range."
            .out Error_Message
            .out .sprintf("    Pitch out of BP's range. Given Pitch: %d.%d. BP Range: %d.%d to %d.%d", (Pitch+9) / 12, (Pitch+9) .mod 12,   (BP+9) / 12, (BP+9) .mod 12,   ((BP+9) + 14) / 12, ((BP+9) + 14) .mod 12)   
            .out ""

        .endif

    .endmacro

 
    ;===========================================================
    ;Duration
    ;===========================================================

    .macro Duration Length_Pattern, P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12
        .if .xmatch(Length_Pattern, "Cont")
            Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12  ;Riffs can start a Duration, then return partway through Duration

        .elseif ((Length_Pattern >= $50) .and (Length_Pattern <= $5f))
            .byte Length_Pattern
            Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

        .else
            .error "Duration Error: Invalid Length_Pattern (Use \"Cont\" to Omit)"
            .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
            .out " "
            .exitmacro
        .endif

    .endmacro



    .macro Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12
        .ifblank P1
            .exitmacro
        .endif
        
        .ifblank P2
            .error "Duration Error: Even number of pitches required"
            .out "       Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
            .out " "
            .exitmacro
        .endif
        
        .if .xmatch(P1, Rest) .or .xmatch(P2, Rest)
            .error "Duration Error: `rest` must be lowercase"
            .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
            .out " "
            .exitmacro

            ;.xmatch case sensitive may be fixable w/ .case -  to remove case senstiivity. (Then restore after .macros w/ .case +)
        .endif

        ;The `.if .not .const(P1)` guards against needing to check ::P1 vs Local P1


        .if .xmatch (P1, rest) .and .xmatch (P2, rest)              
            .byte $00


        .elseif .xmatch (P1, rest)

            .if .not .const(P2) 
                Sub_Duration P1,::P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

            .elseif P2 < B5
                Assert_Valid_Pitch P2, "Duration P2 Error:"
                .byte (P2-BP+1) << 4 ;Note

            .else
                .byte (P2 & $0F) << 4  ;Non-Note

            .endif

    

        .elseif .xmatch (P2, rest)

            .if .not .const(P1) ;If Raw Hex.
                Sub_Duration ::P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

            .elseif P1 < B5
                Assert_Valid_Pitch P1, "Duration P1 Error:"
                .byte (P1-BP+1) << 4 ;Note

            .else
                .byte (P1 & $0F) << 4  ;Non-Note

            .endif
            
        .else ;Neither are Rests.

            .if (.not .const(P2)) .and (.not .const(P1)) 
                Sub_Duration ::P1,::P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

            .elseif .not .const(P2) 
                Sub_Duration P1,::P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

            .elseif .not .const(P1)
                Sub_Duration ::P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

            .else
                .if (P1 < B5) .and (P2 < B5) ;Both Notes
                    Assert_Valid_Pitch P1, "Duration P1 Error:"
                    Assert_Valid_Pitch P2, "Duration P2 Error:"

                    .byte ((P2-BP+1) << 4)  | (P1-BP+1)

                .elseif P1 < B5
                    Assert_Valid_Pitch P1, "Duration P1 Error:"

                    .byte ((P2 & $0F) << 4) | (P1-BP+1)

                .elseif P2 < B5
                    Assert_Valid_Pitch P2, "Duration P2 Error:"

                    .byte ((P2-BP+1) << 4)  | (P1 & $0F)

                .else ;Both Non-Notes
                    .byte ((P2 & $0F) << 4) | (P1 & $0F)

                .endif

            .endif
        .endif


        Sub_Duration P3,P4,P5,P6,P7,P8,P9,P10,P11,P12 ;Recurse
    .endmacro




    ;.macro Sub_Duration P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12
        ; .ifblank P1
        ;     .exitmacro
        ; .endif
        
        ; .ifblank P2
        ;     .error "Duration Error: Even number of pitches required"
        ;     .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
        ;     .out " "
        ;     .exitmacro
        ; .endif
        
        ; .if .xmatch(P1, Rest) .or .xmatch(P2, Rest)
        ;     .error "Duration Error: `rest` must be lowercase"
        ;     .out"        Usage: Duration <Length_Pattern>, <Pitch>, <Pitch>, ..."
        ;     .out " "
        ;     .exitmacro

        ;     ;.xmatch case sensitive may be fixable w/ .case -  to remove case senstiivity. (Then restore after .macros w/ .case +)
        ; .endif



        ; .if .const(P1) .and .const(P2)
        ;     .out "2"

        ; .elseif .const(P1)
        ;     Sub_Duration P1,(::P2),P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

        ; .elseif .const(P2)
        ;     Sub_Duration (::P1),P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

        ; .else
        ;     .out "1"
        ;     Sub_Duration (::P1),(::P2),P3,P4,P5,P6,P7,P8,P9,P10,P11,P12

        ; .endif

        ; .if (P1 = -1) .and (P2 = -1);(.xmatch (P1, rest)) .and (.xmatch (P2, rest))              
        ;     .byte $00

        ;     .out ":)"


        ; .elseif .xmatch (P1, rest)
        ;     .out ":("
        ;         .if P2 < B5
        ;             Assert_Valid_Pitch P2, "Duration P2 Error:"
        ;             .byte (P2-BP+1) << 4 ;Note

        ;         .else
        ;             .byte (P2 & $0F) << 4  ;Non-Note

        ;         .endif


        ; .elseif .xmatch (P2, rest)

        ;         .if P1 < B5
        ;             Assert_Valid_Pitch P1, "Duration P1 Error:"
        ;             .byte (P1-BP+1) << 4 ;Note

        ;         .else
        ;             .byte (P1 & $0F) << 4  ;Non-Note

        ;         .endif




        ; .else ;Neither are Rests.

        ;         .if (P1 < B5) .and (P2 < B5) ;Both Notes
        ;             Assert_Valid_Pitch P1, "Duration P1 Error:"
        ;             Assert_Valid_Pitch P2, "Duration P2 Error:"

        ;             .byte ((P2-BP+1) << 4)  | (P1-BP+1)

        ;         .elseif P1 < B5
        ;             Assert_Valid_Pitch P1, "Duration P1 Error:"

        ;             .byte ((P2 & $0F) << 4) | (P1-BP+1)

        ;         .elseif P2 < B5
        ;             Assert_Valid_Pitch P2, "Duration P2 Error:"

        ;             .byte ((P2-BP+1) << 4)  | (P1 & $0F)

        ;         .else ;Both Non-Notes
        ;             .byte ((P2 & $0F) << 4) | (P1 & $0F)

        ;         .endif

        ; .endif


        ; Sub_Duration P3,P4,P5,P6,P7,P8,P9,P10,P11,P12 ;Recurse
    ;.endmacro



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



;

;===============================================================
;Engine State Instructions
;===============================================================

    ;===========================================================
    ;Enveleope
    ;===========================================================

    .macro Set_Env _Env


        .if (::_Env & $F0) <> EB
            .error "Set_Env Error: Env in different bank."
            .out .sprintf("Set_Env Error: Env in different bank. Use Set_Env_Bank Instead. Given Env: $%02X. Current Bank: $%02X", ::_Env, EB)
            .out "    A Riff/Repeat re-reading a previous Set_Env_Bank may require a manual `EB .set <_Env> & $f0` line."
            .out ""
        .endif


        .byte $e0 | (_Env & $f)
    .endmacro 

    .macro Set_Env_Bank _Env 

        .byte Set_Env_Bank_Byte, _Env  ;$f9, <id>

        EB .set (_Env & $f0)

    .endmacro


        ;Legacy macro Name support. Depreciate.
    .macro Env_Change _Env, Supress_Warning

        .warning "Set_Env Warning: Legacy Syntax Used."
        .out "Set_Env Warning: Legacy Syntax Used. Use Set_Env <_Env> instead."
        .out ""

        Set_Env _Env, Supress_Warning

    .endmacro 


    ;===========================================================
    ;Base Pitch
    ;===========================================================
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

        .byte $b8
        Set_Pitch_Data pitch, vibrato_depth

    .endmacro


    .macro Set_Pitch_Data pitch, vibrato_depth
        .ifblank pitch
            .error "Header Error: Missing BP param"
            .out "Header Error: Missing BP param"
            .out ""
            .exitmacro

        .elseif pitch > $3f
            .error "Header Error: BP out of Range."
            .out "Header Error: Base Pitch out of Range A0..B5"
            .out ""
            .exitmacro
        .endif

        .ifblank vibrato_depth
            .byte ( (pitch<<2) |1) ;Default depth is 1 or "Medium"

        .elseif ::vibrato_depth < 4
            .byte ( (pitch<<2) |vibrato_depth)

        .else
            .error "Header Error: Vibrato Depth out of Range"
            .out .sprintf("Header Error: Vibrato Depth out of Range. Given: %d. Valid Range: 0..3", vibrato_depth)
            .out ""

        .endif

        BP .set (pitch)
    .endmacro




    ;===========================================================
    ;Special Volume
    ;===========================================================

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

    .endmacro

    .macro Set_Volume Volume

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


    ;===========================================================
    ;Misc Effects
    ;===========================================================


    .macro Inc_Page Label, Scoped
        .assert (>* +1) = >Label, error, "Inc_Page Error: Destination Label not in the next page."

        .byte Inc_Page_Byte, <Label

        ; ::Label .set BP
        .ifnblank Scoped
            .ident(.sprintf("%s_BP", .string(Label))) .set BP
            .endscope
        .endif

    .endmacro


;



;===============================================================
;Song Registration
;===============================================================



    ;Init
    Song_Index .set 0

    UI_Text_Index .set 0 
    UI_Word_Index .set 0
    UI_Word_Text_Index .set 0


    .macro Song Name, Len, v1, v2, v3, v4, v5, \
                        v6, v7, v8, v9, v10, \
                        v11, v12, v13, v14, v15, \
                        v16, v17, v18, v19, v20

            .local Sq0, Sq1, Tri, Noise, Dmc

            .if Song_Index > 61
            .error "Song Error: Max Index exceeded (0..61)" ;61*5 = 255
            .exitmacro

            .elseif .xmatch(Name, "Silence")
                Song_Silence  ;Macro to emit minimal data.
                .exitmacro

            ; Guard
            .elseif .defined(.ident(.concat(.string(Name), "_SongDefined")))
                .error "Song Error"
                .out .sprintf("Error: Song Name: `%s` is already defined.", .string(Name))
                .out ""
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

            Collect_UI_Text v1, v2, v3, v4, v5, \
                            v6, v7, v8, v9, v10, \
                            v11, v12, v13, v14, v15, \
                            v16, v17, v18, v19, v20

            Song_Index .set Song_Index + 1

            ; mark defined
            .ident(.concat(.string(Name), "_SongDefined")) = 1

    .endmacro


    .macro Output_Song

        Max_Track_Index .set (Song_Index -1)

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

;