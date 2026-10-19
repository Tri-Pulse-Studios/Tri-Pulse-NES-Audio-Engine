.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2            ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $00, $00        ; mapper 0, Horizontal mirroring

.segment "VECTORS"
  .addr nmi
  .addr reset 
  .addr irq ;Unused
 
.segment "STARTUP" ; "nes" linker config requires a STARTUP section, even if it's empty

.segment "CHARS"

  .incbin "engine\Data\Tri_Pulse_UI_Tiles.bin"

;

.segment "CODE"; Main code segment for the program



  ;Start at $c000 instead of $8000
    ;DMC samples must start past $c000, and 16K of ROM is plenty.
  .res $4000, $00 


  .include "Defined\Print_PC_as_Warning.s"  
  .define Print_PC_Enabled 0 ;This is very slow

  ;Above here ignored/hardcoded for tmp

py_Segment __Defines, Defines

  __Defines:
    Emit__Unused = 0 ;TODO. Make Vestigial

    .feature line_continuations + ; Ending w/ a "\" lets single lines spill over multiple.
    .feature underline_in_numbers + ;ie, lda #%1010_0101 is now valid.
  

    .include "user\Config.s" ;User settings.

    .include "engine\Defined\Defined_RAM.s"
    .include "engine\Defined\Defined_Macros.s"


  .include "user\Engine_Data.s"
  .include "user\SFX_Data.s"
  .include "user\UI_Data_and_Song_Registry.s"

    ;Data emitted elsewhere. Defines names here.

py_Segment_End __Defines


 


py_Segment NB_Data, Free
  NB_Data:
  Output_All_NoiseFX  ;Macro Output Column-Major LUTs

  Output_All_Songs ;Macro Output Song Pointers
py_Segment_End NB_Data 


;===============================================================
;Primary Music Code Block
;===============================================================

.include "engine\Code\Music_Init.s"
.include "engine\Code\Music_Update.s"
.include "engine\Code\Music_New_Note.s"

.include "engine\Data\Music_Period_LUTs.s"



py_Segment __Reset_w_UI, Free
    __Reset_w_UI:

  .include "engine\Code\Music_UI_Reset.s"
  .include "engine\Code\Music_UI.s"

py_Segment_End __Reset_w_UI 




 
py_Segment irq, Free
  
  irq: 
  .if Debugging_Enabled
    .byte $02
    cmp $8070
    rti ;Crash on Interupt.
  .endif
py_Segment_End irq



DMC_Samples:

    .align 64, $DC
  py_Segment DMC_Sample_1_17, Indicies, 0, $40, $80, $c0
    Zero_Sample_Addr:
    DMC_Sample_1_17:
    DMC_Sample_4_65: ;Data Overlaps
    .incbin "engine\Data\DMC Samples\DMC_Sample_Merged_12.5%_Tri_Pulse.bin" ;All Three  12.5% Tri-Pulse
    DMC_Sample_6_81 = DMC_Sample_1_17+64 ;Shares the 65th $00 Byte.
  
    Output_All_Env  ;Overloading $00s w/ DMC
  py_Segment_End DMC_Sample_1_17

    .align 64, $DC
  py_Segment DMC_Sample_8_65, Indicies, 0, $40, $80, $c0
    DMC_Sample_8_65: 
    DMC_Sample_9_81 = DMC_Sample_8_65+64 ;Shares the 65th $FF Byte.
    .incbin "engine\Data\DMC Samples\DMC_Sample_Merged_25%_Tri_Pulse.bin" ;Two 25% Tri-Pulse
  py_Segment_End DMC_Sample_8_65


    .align 64, $DC
  py_Segment DMC_Sample_2_17, Indicies, 0, $40, $80, $c0
    FF_Sample:
    DMC_Sample_2_17:
    .incbin "engine\Data\DMC Samples\DMC_Sample_2_17.bin" ;One 25% Tri-Pulse
  py_Segment_End DMC_Sample_2_17


    .align 64, $DC
  py_Segment DMC_Sample_Tri_Kick, Indicies, 0, $40, $80, $c0
    DMC_Sample_Tri_Kick: ;2-17, 50% Duty, Double Volume.
    .incbin "engine\Data\DMC Samples\DMC_Sample_Tri_Kick.bin" 
  py_Segment_End DMC_Sample_Tri_Kick

;



Output_UI_Words
Output_UI_Text

; TODO Song "Silence"
;Song "Silence" ;Press B-button to silence engine by playing a song of "Nothing"




.byte "Tri-Pulse Studios 2026"

py_Ignore

  .macro FillPage

    .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
    .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
    .byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
    .byte $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
    .byte $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
    .byte $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
    .byte $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
    .byte $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F
    .byte $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF
    .byte $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
    .byte $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
    .byte $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
    .byte $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
    .byte $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF


  .endmacro

  .macro FillLastPage ;$FF at $FF40, $00 at $FF00 for DMC
    
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
    .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
    
    .byte $FF, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
    .byte $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
    .byte $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
    .byte $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
    .byte $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
    .byte $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F
    .byte $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF
    .byte $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
    .byte $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
    .byte $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
    .byte $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
    .byte $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9 ;Vectors go here.


  .endmacro

  .macro KiloByte
    FillPage
    FillPage
    FillPage
    FillPage
  .endmacro



  .align 1024, $fe

  ;$e000
    ;KiloByte
    ;KiloByte
    ;KiloByte
    ;KiloByte


  ;$f000
    ;KiloByte
    ;KiloByte
    KiloByte

      FillPage
      FillPage
      FillPage
      FillLastPage
;
py_Ignore_End


.if In_pySegment
  .error "Unclosed py_Segment"
.endif

.if In_pyIgnore
  .error "Unclosed py_Ignore"
.endif




