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

  .include "Defined//Print_PC_as_Warning.s"  
  .define Print_PC_Enabled 0 ;For the py_Segment stuff, a tool TBA.

py_Segment __Defines, Defines

  __Defines:

    Emit__Unused = 0 ;TODO. Make Vestigial

    .feature line_continuations +   ; Ending with a "/" lets long macro invocations split over multiple lines.
    .feature underline_in_numbers + ; da #%1010_0101 is now valid.
    .feature string_escapes + ;     ;`\"String\"` inside litteral Quotes.

    .include "user//Config.s" ;User settings.

    .include "engine//Defined//Defined_RAM.s"

    .include "engine//Defined//Macros_Code.s"
    .include "engine//Defined//Macros_Engine_Data.s"
    .include "engine//Defined//Macros_Song_Data.s"
    .include "engine//Defined//Macros_UI.s"


  .include "user//Engine_Data.s"
  .include "user//SFX_Data.s"
    ;Data emitted elsewhere. Defines names here.

py_Segment_End __Defines

.assert * = $8000, warning, "Primary Defined Segment Shouldn't emit data."


; Song Data ocupies $8000-$9fff
py_Segment _Song_Registry, Defines
  _Song_Registry:

  .include "user//UI_Data_and_Song_Registry.s"
    ;Internal Song_Data .includes 
    
py_Segment_End _Song_Registry


.align $2000

; UI Engine ocupies $a000-$bfff
py_Segment __Reset_w_UI, Free
    __Reset_w_UI:

  .include "engine//Code//Music_UI_Reset.s"
  .include "engine//Code//Music_UI_Update.s"

  Output_UI_Words
  Output_UI_Text

py_Segment_End __Reset_w_UI 


  


; Music Engine ocupies $c000... 
  .align $2000



py_Segment User_Data, Free
  User_Data:
  Output_SFX

  Output_Vibrato_Delays
  Output_Vibrato_Cycles

  Output_Duration_Sets

  Output_MiscFX_Data
  ;Env defined below with DMC Samples.

  Output_NoiseFX  ;Macro Output Column-Major LUTs
  Output_Kick_Type ;Macro Output small Kick Type LUT

  Output_Song_Pointers ;Macro Output Song Pointers


  
py_Segment_End User_Data 


;===============================================================
;Primary Music Code Block
;===============================================================

.include "engine//Code//Music_Init.s"
.include "engine//Code//Music_Update.s"
.include "engine//Code//Music_New_Note.s"

.include "engine//Data//Music_Period_LUTs.s"
.include "engine//Data//DMC_Samples_Inc.s"





 






py_Segment irq, Free
  
  irq: 
  .if Debugging_Enabled

    Runtime_Exception "Runtime Exception: Unexpected IRQ. Debug the source of the interrupt."
    rti 

  .endif
py_Segment_End irq




.byte "Tri-Pulse Studios 2026"



.if In_pySegment
  .error "Unclosed py_Segment"
.endif

.if In_pyIgnore
  .error "Unclosed py_Ignore"
.endif


.if Debugging_Address <> -1
    .out .sprintf("Attempting to fetch Runtime Exception error message associated with Address: $%04x ...", Debugging_Address)
    .out "      - Build will fail if a matching error message is found."

    .if (Debugging_Address < $8000) .or (Debugging_Address > $ffff)
        .out .sprintf("    Address: $%04x is not a ROM address.", Debugging_Address)
    .endif

    .out ""

.endif















