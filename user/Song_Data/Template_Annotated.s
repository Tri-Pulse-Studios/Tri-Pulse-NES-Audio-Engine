;============================================================
; Song Template
;============================================================
;
; The scaffolding: Channel, Header, Notes, and Loop must remain as is.
; Each channel requires at least one Note.
;
; Replace "Song_Name" throughout this file with your song's name 
; as defined in User/UI_Data_and_Song_Registry.s 
;   ie: Song Fanfare, <Tempo>, <UI_text>
;       matches
;       Channel Fanfare_Sq0
;          Header <_BP>, <_Env>,  [<Vib_Depth>]
;
; Channel syntax:
;   Channel <Name>_channel_type, [<Global_Designator>]
;
; Each channel is its own sandbox. For a Riff to access data 
; from another channel, it must use that channel's Global Designator.
;
; See the README for the complete music DSL documentation.
;============================================================


;============================================================
; Custom note lengths
;============================================================
    ; This optional variable is used for note lengths that are inconvenient to write manually.
    ;    Example: `Notes 16*_8th,rest` is a two-measure rest.
    ;
    ; Typical usage: Set it to the song's Tempo as defined in user/UI_Data_and_Song_Registry.s 
    ;   ie: Song Fanfare, 11, <UI_text>
    ;       matches
    ;       _8th .set 11
    ;
    ; WARNING: The engine does not enforce or validate these values.
    ;
    ; This variable is automatically redefined inside each Channel's sandbox
    ; No other variables are automatically passed into Channels.
    ;
    ; See the README for details on custom note lengths.
_8th .set -1

;============================================================
; Page Confinement
;============================================================
    ; Each channel's data must remain within a single 256-byte page.
    ;
    ; If a song exceeds 256 bytes, 
    ; insert additional ".align 256" lines between channels as needed.
    ;
    ; If a channel exceeds 256 bytes, 
    ; explicit page increments are required.
    ;
    ; The Python binner ignores these alignments 
    ; in favor of its own page binning.
    ;
    ; See the README for details on page confinement.
.align 256


;============================================================
; Square 0
;============================================================

Channel Song_Name_Sq0
    Header <Init_Base_Pitch>, <Init_Envelope_Name>, [<Optional_Vibrato_Depth>]
        ;ie Header A3, Lead_sqr_v12, Vib_Shallow

    Notes whl,rest

Loop Song_Name_Sq0


;============================================================
; Square 1
;============================================================

Channel Song_Name_Sq1
    Header <_BP>, <_Env>,  [<Vib_Depth>]

    Notes whl,rest

Loop Song_Name_Sq1


;============================================================
; Triangle
;============================================================

Channel Song_Name_Tri
    Header <_BP>, <_Env>,  [<Vib_Depth>]

    Notes whl,rest

Loop Song_Name_Tri


;============================================================
; DMC
;============================================================

Channel Song_Name_dmc
    Header <_BP>, <_Env>

    Notes whl,rest

Loop Song_Name_dmc


;============================================================
; Noise
;============================================================

Channel Song_Name_Noise
    Noise_Header <Song_Name_Noise_Bank>, <Kick_Type>
        ;ie Noise_Header Fanfare_NB, d50_Kick

    Notes whl,rest

Loop Song_Name_Noise

