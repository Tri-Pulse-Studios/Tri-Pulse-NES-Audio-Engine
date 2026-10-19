.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2            ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $00, $00        ; mapper 0, Horizontal mirroring

.segment "VECTORS"
  .addr nmi
  .addr reset 
  .addr $2026 ;irq
 
.segment "STARTUP" ; "nes" linker config requires a STARTUP section, even if it's empty

.segment "CHARS"

  .incbin "MK64_Tiles_Truncated.bin"

;

.segment "CODE"; Main code segment for the program


  .res $4000, $00 ;Unoptimized starts at $8000, fills to $c000. Binned starts at $e000

  .include "Defined/Print_PC_as_Warning.s"  
  .define Print_PC_Enabled 0 ;This is very slow

  ;Above here ignored/hardcoded for tmp

py_Segment __Defines, Defines

  __Defines:
    ;Toggleable Debugging/Settings
    ;All are T/F 1/0 statements.

    .define Debugging_Enabled 0 ;Remove certain debugging checks for benchmark/final builds.
    .define Emit_MK64_Unused 0 ;Remove Code blocks unused by this specific project, (Such as Sq/Tri SFX support.)


    .feature line_continuations + ; Ending w/ a "\" lets single lines spill over multiple.
    .feature underline_in_numbers + ;ie, lda #%1010_0101 is now valid.
  

    .include "Defined\Defined_RAM.s"
    .include "Defined/Defined_Macros.s"

py_Segment_End __Defines
;



py_Segment NB, Defines ;Free
DKs_Jungle_Parkway_dmc = (Inf_Wait -2) ;Only plays NoiseFX
  NB:
  .include "Music\MK64\Noise_Bank.s"

py_Segment_End NB

py_Segment NB_Data, Free
  NB_Data:
  ;Macro Output Column-Major LUTs
  Output_All_NoiseFX 
py_Segment_End NB_Data

.include "Music\Music_Init.s"
.include "Music\New_Note.s"
.include "Music\Music_Update.s"



.include "Music\Music_LUTs.s"

.include "Music\SFX_Engine.s"
py_Segment __SFX_Data, Free
  __SFX_Data:
  .include "Music\SFX_LUTs.s"
py_Segment_End __SFX_Data




.include "Music\MK64\MK64_Title.s" ;Could Organize these based on shared data.
.include "Music\MK64\MK64_Menu.s"


.include "Music\MK64\Raceway.s" 
.include "Music\MK64\Yoshi_Valley.s" ;Tri End not Releasing
  .include "Music\MK64\Choco_Mountain.s"
.include "Music\MK64\Koopa_Beach.s"  
.include "Music\MK64\Kalamari_Desert.s" 

.include "Music\MK64\Toads_TurnPike.s"
.include "Music\MK64\Frappe_Snowland.s"

.include "Music\MK64\Bowsers_Castle.s"

.include "Music\MK64\DKs_Jungle_Parkway.s"
.include "Music\MK64\Banshee_Boardwalk.s"
.include "Music\MK64\Rainbow_Road.s"


.include "Music\MK64\Staff_Roll.s"

.include "Music\MK64\Race_Results.s"
.include "Music\MK64\SFX\Lose_Race.s"



.align 256
py_Segment Start_Fanfares, PageFit
  Start_Fanfares:
  .include "Music\MK64\SFX\Race_Start.s"
  .include "Music\MK64\SFX\Battle_Start.s"
py_Segment_End Start_Fanfares

.align 256
py_Segment Finish_Fanfares, PageFit
  Finish_Fanfares:
  .include "Music\MK64\SFX\Award_Lose.s"
  .include "Music\MK64\SFX\Finish_1st.s"
  .include "Music\MK64\SFX\Finish_2nd_to_4th.s"
py_Segment_End Finish_Fanfares


.include "Music\MK64\SFX\Star_Power.s"
.include "Music\MK64\Battle.s"

.include "Music\MK64\SFX\Battle_Results.s"

.include "Music\MK64\Award_Win.s"



.include "Code_MK64\Lap_3.s" ;Defines

py_Segment __Reset_w_UI, Free
    __Reset_w_UI:



  .include "Code_MK64\Music_Only_Reset.s"

  .include "Code_MK64\Background_Simplified.s"


py_Segment_End __Reset_w_UI ;Can split into a few smaller Free Segments, but whatever.


  ;Should be blank (Unless I impliment dmc ATK)
py_Segment irq, Free
  
  irq: ;using for brk has issues.
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
    .incbin "Music\FamiConverter\Output_Files\DMC_Sample_Merged_12.5%_Tri_Pulse.bin" ;All Three  12.5% Tri-Pulse
    DMC_Sample_6_81 = DMC_Sample_1_17+64 ;Shares the 65th $00 Byte.
  
    Output_All_Env  ;Overloading $00s w/ DMC
  py_Segment_End DMC_Sample_1_17

    .align 64, $DC
  py_Segment DMC_Sample_8_65, Indicies, 0, $40, $80, $c0
    DMC_Sample_8_65: 
    DMC_Sample_9_81 = DMC_Sample_8_65+64 ;Shares the 65th $FF Byte.
    .incbin "Music\FamiConverter\Output_Files\DMC_Sample_Merged_25%_Tri_Pulse.bin" ;Two 25% Tri-Pulse
  py_Segment_End DMC_Sample_8_65


    .align 64, $DC
  py_Segment DMC_Sample_2_17, Indicies, 0, $40, $80, $c0
    FF_Sample:
    DMC_Sample_2_17:
    .incbin "Music\FamiConverter\Output_Files\DMC_Sample_2_17.bin" ;One 25% Tri-Pulse
  py_Segment_End DMC_Sample_2_17


    .align 64, $DC
  py_Segment DMC_Sample_Tri_Kick, Indicies, 0, $40, $80, $c0
    DMC_Sample_Tri_Kick: ;2-17, 50% Duty, Double Volume.
    .incbin "Music\FamiConverter\Output_Files\DMC_Sample_Tri_Kick.bin" 
  py_Segment_End DMC_Sample_Tri_Kick

;

.byte "Fritz"

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




