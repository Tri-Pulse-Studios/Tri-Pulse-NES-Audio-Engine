;============================================================
; Engine Settings
;============================================================



ZP_RAM_Start = $00
    ;Reserves $15 (23) Bytes of contiguous ZP RAM.
    ;Valid range is $00-$E9

RAM_Start = $500
    ;Reserves $A0 (160) Bytes of contiguous standard RAM.
    ;Valid range is $00-$75f

Riff_Buffer_Start = $5a0
    ;Reserves 40 or 80 Bytes (See Below) of contiguous standard RAM.
    ;Valid range is $00-$780

Expand_Max_Riff_Depth 1
    ;0 = Max depth 4. Uses 40 Bytes of RAM  ;VERIFY
    ;1 = Max depth 7. Uses 80 Bytes of RAM
    ;
    ; Disable only if you can't spare the RAM

;ADVANCED
Debugging_Enabled 0
    ;Enables various NES runtime checks in the code.
    ;If an exception is detected, the console crashes.
    ;
    ;See the README for details



;============================================================
; Vibrato
;============================================================

; Vibrato cycle values are 2x the maximum vibrato depth.
; The engine halves the delta's between 1 and 4 times, as defined in the Song's Data.
;
; This is to maintain a constant percieved vibrato depth across octaves.
;
; Halving rounds toward negative infinity:
;    3 / 2  = 1
;             1 / 2 = 0
;   -3 / 2  = -2
;             -1 / 2 = -1
;
; Negative values never reach 0 when halved. The minimum values
; are therefore 0 and -1.

py_Segment LUT_Vibrato_NonRel_Data, Free
    LUT_Vibrato_NonRel_Data:
            .byte      8,12,8,       <-8,<-12,<-8          ;6v Fast
            .byte   8,12,12,8,       <-8,<-12,<-12,<-8     ;8v Medium
            .byte 4,8,12,12,8,4, <-4,<-8,<-12,<-12,<-8,<-4 ;12v Slow

        LUT_Start_Vib_Index:
            .byte 0,  6,  6+8

        LUT_End_Vib_Index:
        ;   .byte 0,  6,  6+8
            .byte 6+8+12

        LUT_Vibrato_Delays:
        .byte <~0, <~8, <~16, <~28

    py_Segment_End LUT_Vibrato_NonRel_Data
;

;============================================================
; Duration Instruction Data
;============================================================

; ADVANCED: Defines the Duration sets available to the music DSL
; for song compression.
;
; This "Starter" set is sufficient for most songs.
;
; WARNING: Defining additional Duration sets is possible, but not practical.
; An update will provide a more reasonable method in the future.
;
; See the README for details on defining custom duration sets.

    py_Segment LUT_Length_Nibbles, Free
        LUT_Length_Nibbles:

            adr_00:
            adr_0000:
            adr_6x0:
            adr_8x0:
            .byte $00,$00,$00,$00

            adr_1111:
            adr_6x1:
            adr_8x1:
            .byte $11,$11,$11
            adr_111_R:
            .byte $11, $91  ;$9- is repeat "3b" or "2b"


            adr_2222:
            adr_6x2:
            adr_8x2:
            .byte $22,$22,$22,$22

            adr_6x8:
            adr_8x8:
            .byte $88,$88,$88,$88


        .assert (*-LUT_Length_Nibbles)<$20, error, "Duration Lengths don't fit."
            ;This can be before the last one.

        LUT_Read_Nibbles_Init:
            Duration_List Emit_LUT ;Macro Emitted Data


        py_Segment_End LUT_Length_Nibbles


;============================================================
; Envelopes
;============================================================

; Defines the instrument Envelopes used by the music DSL.
; The Envelope name in the definition is used to reference it in Channels.
;   ie:
;       Env Pad_d12_6_0, \
;           <Env_Data>
;
;       Channel <Song_Name>
;           Header <BP>, Pad_d12_6_0
;
; Envelopes can be used by any channel, though not all channels support all features.
;       Tri/Tri-Pulse alias Pulse Envelopes to better express how they function.
;
; See the README for the naming convention 
;
;
;
; Envelopes are organized into banks of 16.
;       Switching between Envelopes within a bank is simple.
;       Switching between banks mid-song is possible, but not recommended for beginners.
;       There cannot be empty slots in a bank. (Except for the last one)
;           -Unused space can be filled with Noise Channel's Env freely. (Noise ignores banks.)
;
; Since the Envelope data format is fairly obtuse, a Starter set is provided.
;       Their names match the inlcuded FamiStudio file: Tri_Pulse_Demo.fms
;
; See the README for the complete Envelope format.
;
;
;
; WARNING: Unused Envelope data can be optimized, but this should be a final step.
; It is complex, easy to mess up, hard to debug, and only worthwhile when 
; saving ~20 bytes of ROM matters.
;
; See the README for Envelope Optimization.



;MOVE BELOW TO README

    ;
    ; My Envelope naming shorthand:
    ;   I include the minimum data needed for an envelope to be recognizable
    ;
    ;   Pulse Channels:
        ;   Lead / Pad       = General instrument type
        ;   sqr / d12 / d25 / d75 = Duty cycle
        ;   _X_Y         = Volume markers, Attack, Sustain
        ;   _X_Y_Z       = Volume markers, Attack, Decay, Sustain (Typically )
        ;   _sX         = X is Sustain Volume (0 - 15)
        ;   _vX     = Vibrato speed, in frames per cycle
        ;   _Xf_Ym         = X is Note Cutoff, in frames.
        ;                       -Channel is silenced for X frames at the end.
        ;                       -Channel will not be silnced for first Y frames.
        ;
        ; Example:
        ;   Pad_d12_6_0
        ;       A "quiet" instrument, with 12.5% Duty (thin), and volume decaying from 6 to 0.
        ;       The note ends on its own, so there is no Cutoff marker.
        ;       The lack of a v6/v8/v12 marker means no vibrato.

    ;   Triangle / Tri-Pulse
    ;
    ;   T  = Identifier for Tri/ Tri-Pulse
    ;   d12 / d25  = Tri-Pulse's prefered Duty Cycle (Triangle ignores.)
    ;   _Xf_Ym         = X is Note Cutoff, in frames. (Same as Pulse.)
    ;   _vX     = Vibrato speed, in frames per cycle  (Same as Pulse. Tri-Pulse ignores.)
    ;
    ;
    ;   T_1f_2m_12v__d25
    ;       A Triangle / Tri-Pulse instrument. Tri-Pulse duty is 25% (Medium)
    ;       1f_2m = The channel silences for one frame at the end of a note.
    ;               - The channel will not attempt to silence until frame 3 or later of a note.
    ;       12v = slow vibrato. (Tri-Pulse ignores)
    ;




    ;
    ; WARNING: Optimization of unused Envelope data is possible,
    ; but is easy to mess up, and saves only a little ROM.
;


;============================================================
;Bank 0 Primary Instruments
;============================================================
Env_Bank 

    ;========================================================
    ;Lead Envs
    ;========================================================
        ;50% Lead
        Env Lead_sqr_s5_v12_1f, \
            $90 |Vib_qtr | Duty_50, \
            $00, $00, \
            (-$6 & $1f) << 3 | $01, \
            $50 | Vib_Slow | Duty_50, \
            dmc_low_25
        T_1f_v12__d25 .set Lead_sqr_s5_v12_1f

        ;25% Lead
        Env Lead_12to25_s6_v12, \  
            $c0 | Vib_16th | Duty_12, \
            (-$8 & $f) << 4 | $02, \
            $80 | Duty_25, \
            (-$1 & $1f) << 3 | $00, \
            $60 | Vib_Slow | Duty_25, \
            $ff  ;Tri-Pulse Duty undefined
        ;

        ;12.5% Lead
        Env Lead_d12_s7_v8_1f, \
            $b0 | Vib_qtr | Duty_12, \
            $00, $00, \
            (-$4 & $1f) << 3 | $01, \
            $70 | Vib_Med | Duty_12, \
            dmc_high_12_5

        T_1f_v8__d12 .set Lead_d12_s7_v8_1f


    ;========================================================
    ;Percussive Envs
    ;========================================================
        ;50% Lead
        Env Lead_sqr_13_0, \
            $f0 | Duty_50, \
            (-$8 & $f) << 4 | $04, \
            $78 | Duty_50, \
            (-$3 & $1f) << 3 | $00, \
            $00 | Duty_50, \
            $ff

        ;

        ;25% Pad
        Env Pad_d75_8_0,\
            $c0 | No_vib | Duty_75, \
            (-6 & $f) << 4 | $04, \
            $60 | Duty_75 , \
            (-2 & $1f) << 3 | $00, \
            $00 | Duty_75 ,\
            $ff
        ;

        ;12.5% Pad
        Env Pad_d12_6_0, \
            $b0 | Duty_12, \
            (-$8 & $f) << 4 | $03, \
            $48 | Duty_12, \
            (-$1 & $1f) << 3 | $01, \
            $00 | Duty_12, \
            $ff 
        ;

    ;========================================================
    ;Pad Envs
    ;========================================================


        ;50% Pad
        Env Pad_sqr_s4_v8, \
            $70 | Vib_qtr | Duty_50, \
            $00, $00, \
            (-$4 & $1f) << 3 | $00, \
            $40 | Vib_Med | Duty_50, \
            dmc_low_25

        T_0f_v8__d25 .set Pad_sqr_s4


        ;25% Pad
        Env Pad_d25_8_3_v12, \  
            $90 | Vib_Inst | Duty_25, \
            $00, $00, \
            ( -4 & $1f) << 3 | $0, \
            $30 | Vib_Slow | Duty_25, \
            dmc_low_25
        T_0f_v12__d25 .set Pad_d25_8_3_v12

        ;12.5% Pad
        Env Pad_d12_s3_v8, \
            $60 | Vib_8th | Duty_12, \
            $00, $00, \
            (-$4 & $1f) << 3 | $00, \
            $30 | Vib_Med | Duty_12, \
            dmc_high_12_5
        T_0f_v8__d12 .set Pad_d12_s3_v8

    ;========================================================
    ;Misc Envs
    ;========================================================

        ;v6 vibrato is very fast. More SFX than musical.
        Env Whistle_25to12_v6, \
            $e0 | Vib_16th | Duty_25, \
            $00, $00, \
            (-$c & $1f) << 3 | $00, \
            $70 | Vib_Fast | Duty_12, \
            dmc_low_25

        T_0f_v6__d25 .set Lead_25to12_v6

        ;Example of an increasing volume Envelope
        Env Lead_d25_3_8_6_v12, \  
            $30 | Vib_8th | Duty_25, \
            (+$2 & $f) << 4 | 11, \
            $8c | Duty_25, \
            (-$1 & $1f) << 3 | $00, \
            $60 | Vib_Slow | Duty_25, \
            $ff
        ;




    ;========================================================
    ;Triangle / Tri-Pulse Envs
    ;========================================================

    ; Aliased Pulse Envelopes are listed here again for organization.

            ;Triangle, No Cutoff. Pick a Vibrato Speed
        ; Slow:   T_0f_v12__d25 from Pad_d25_8_3_v12
        ; Medium: T_0f_v8__d25  from Pad_sqr_s4_v8
        ; Fast:   T_0f_v6__d25  from Whistle_25to12_v6
            
            ;Triangle, 1f Cutoff. Pick a Vibrato Speed
        ; Slow:   T_1f_v12__d25 from Lead_sqr_s5_v12
        ; Medium: T_1f_v8__d12  from Lead_d12_s7_v8_1f
        ; Fast:
        Env T_1f_v6, \
            $10|Duty_12, $00, $00, \
            (-1 & $1f) << 3 | $01, \
            $10 | Vib_Fast, \
            $ff ;DMC Undefined
        ;

            ;Tri-Pulse 25% Duty. Pick Cutoff Time. (Ignores Vibrato)
        ;0f, 1f, or 2f
        ; T_0f_v12__d25 from Pad_d25_8_3_v12
        ; T_1f_v12__d25 from Lead_sqr_s5_v12
        Env T_2f__d25, \
            $10|Duty_12, $00, $00, \
            (-1 & $1f) << 3 | $02, \
            $10, \
            dmc_low_25   
        ;

            ;Tri-Pulse 12% Duty. Pick Cutoff Time. (Ignores Vibrato)
        ;0f, 1f, or 2f
        ; T_0f_v8__d12  from Pad_d12_s3_v8
        ; T_1f_v12__d25 from Lead_sqr_s5_v12
        Env T_2f__d12, \
            $10|Duty_12, $00, $00, \
            (-1 & $1f) << 3 | $02, \
            $10, \
            dmc_high_12_5
            
        ;

    ; 14 / 16 Envelopes of Bank 0 are used.
        ; The three Triangle-only Envelopes can be moved to another bank more easily to make space.
        ; A pulse Env could also use a 2f Cutoff and have Triangle alias it.

        Env Unused_1, \
            $10|Duty_12, $00, $00, \
            (-1 & $1f) << 3 | $02, \
            $10, \
            dmc_high_12_5
            
        ;

        Env Unused_2, \
            $10|Duty_12, $00, $00, \
            (-1 & $1f) << 3 | $02, \
            $10, \
            dmc_high_12_5
            
        ;

        ;These Unused ones can be replaced by Noise Channel Envs freely.
            ;For simplicity, I kept Noise organized.

;============================================================
; Bank 1 Noise Channel
; (Envelopes are automatically handled per-Note by the Noise Channel, and ignore the bank.)
;============================================================
    Env Crash_env, \
        $b0, \
        (-8 & $f) << 4 | $3, \
        $6c, \
        (-$01 & $1f) << 3 | $0, \
        $00, \
        $ff
    ;

    Env Snare_env, \
        $a0, \
        (-$8 & $f) << 4 | $3, \
        $60, \
        (-$04 & $1f) << 3, \
        $00, \
        $ff
    ;

    Env Pre_Cymbal_env, \
        $20, \
        (+$1 & $f) << 4 | $e, \
        $00, \
        $00, $00, \
        $ff
    ;

    Env Shaker_env, \
        $a0, \
        $00, $00, \
        (-12 & $1f) << 3, \
        $00, \
        $ff
    ;

    Env Hat_env, \
        $40, \
        $00, $00, \
        (-8 & $1f) << 3, \
        $00, \
        $ff
    ;



