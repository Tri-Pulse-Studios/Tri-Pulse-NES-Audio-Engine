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

  .incbin "engine//Data//Tri_Pulse_UI_Tiles.bin"

;



.segment "CODE"; Main code segment for the program


test .set 0

.if !test
  .out ":)"
.endif

test .set 1
.if !test
  .out ":("
.endif


;.out .sprintf("Var = $%02x", Var)

  ;Start at $c000 instead of $8000
    ;DMC samples must start past $c000, and 16K of ROM is plenty.
  .res $4000, $00 




  .include "Defined//Print_PC_as_Warning.s"  
  .define Print_PC_Enabled 0 ;This is very slow

  ;Above here ignored//hardcoded for tmp

py_Segment __Defines, Defines

  __Defines:
    Emit__Unused = 0 ;TODO. Make Vestigial

    .feature line_continuations + ; Ending with a "//" lets single lines spill over multiple.
    .feature underline_in_numbers + ;ie, lda #%1010_0101 is now valid.
    .feature string_escapes +

    .include "user//Config.s" ;User settings.

    .include "engine//Defined//Defined_RAM.s"

    .include "engine//Defined//Macros_Code.s"
    .include "engine//Defined//Macros_Engine_Data.s"
    .include "engine//Defined//Macros_Song_Data.s"
    .include "engine//Defined//Macros_UI.s"


  .include "user//Engine_Data.s"
  .include "user//SFX_Data.s"
  .include "user//UI_Data_and_Song_Registry.s"

    ;Data emitted elsewhere. Defines names here.

py_Segment_End __Defines


 
; FF FE FD FF F7 F0 E3 FF FE FD 08 0C 08 F8 F4 F8
; 08 0C 0C 08 F8 F4 F4 F8 04 08 0C 0C 08 04 FC F8
; F4 F4 F8 FC FF FE FD 00 06 0E FF FE FD 26 27 30
; 30 0D 0D 0D 02 02 02 06 07 3A 3A 35 FF FF 00 FF
; 00 FF 16 00 FF 16 00 00 00 FF 00 21 1B 15



py_Segment User_Data, Free
  User_Data:
  Output_SFX

  Output_Vibrato_Delays
  Output_Vibrato_Cycles

  Output_Duration_Sets

  ;Env defined below with DMC Samples.

  Output_NoiseFX  ;Macro Output Column-Major LUTs
  Output_Kick_Type ;Macro Output small Kick Type LUT

  Output_Song ;Macro Output Song Pointers

  Output_UI_Words
  Output_UI_Text

  
py_Segment_End NB_Data 


;===============================================================
;Primary Music Code Block
;===============================================================

.include "engine//Code//Music_Init.s"
.include "engine//Code//Music_Update.s"
.include "engine//Code//Music_New_Note.s"

.include "engine//Data//Music_Period_LUTs.s"



py_Segment __Reset_w_UI, Free
    __Reset_w_UI:

  .include "engine//Code//Music_UI_Reset.s"
  .include "engine//Code//Music_UI_Update.s"

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
    .incbin "engine//Data//DMC Samples//DMC_Sample_Merged_12.5%_Tri_Pulse.bin" ;All Three  12.5% Tri-Pulse
    DMC_Sample_6_81 = DMC_Sample_1_17+64 ;Shares the 65th $00 Byte.
  
    Output_Env  ;Overloading $00s w// DMC
  py_Segment_End DMC_Sample_1_17

    .align 64, $DC
  py_Segment DMC_Sample_8_65, Indicies, 0, $40, $80, $c0
    DMC_Sample_8_65: 
    DMC_Sample_9_81 = DMC_Sample_8_65+64 ;Shares the 65th $FF Byte.
    .incbin "engine//Data//DMC Samples//DMC_Sample_Merged_25%_Tri_Pulse.bin" ;Two 25% Tri-Pulse
  py_Segment_End DMC_Sample_8_65


    .align 64, $DC
  py_Segment DMC_Sample_2_17, Indicies, 0, $40, $80, $c0
    FF_Sample:
    DMC_Sample_2_17:
    .incbin "engine//Data//DMC Samples//DMC_Sample_2_17.bin" ;One 25% Tri-Pulse
  py_Segment_End DMC_Sample_2_17


    .align 64, $DC
  py_Segment DMC_Sample_Tri_Kick, Indicies, 0, $40, $80, $c0
    DMC_Sample_Tri_Kick: ;2-17, 50% Duty, Double Volume.
    .incbin "engine//Data//DMC Samples//DMC_Sample_Tri_Kick.bin" 
  py_Segment_End DMC_Sample_Tri_Kick

;




.byte "Tri-Pulse Studios 2026"



.if In_pySegment
  .error "Unclosed py_Segment"
.endif

.if In_pyIgnore
  .error "Unclosed py_Ignore"
.endif




