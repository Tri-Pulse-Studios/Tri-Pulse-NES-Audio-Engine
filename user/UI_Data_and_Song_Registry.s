;============================================================
; Compressed Text Dictionary
;============================================================
    ; Defines reusable text sequences for compression and ease of authoring.
    ;
    ; See the README for details and limitations


    UI_Word __dash__, " - ", $80

    UI_Word _CURRENT_TRACK__, "CURRENT "
    UI_Word _TRACK__, "TRACK ", $80


    ; This messages appears below "Tri-Pulse Studios"
    ; See the README for details.
    UI_Word _SUBTITLE_HI, "Heritage: A Dragon's Tale", $80
    UI_Word _SUBTITLE_LOW, "By: EliteFerrex", $80

    SUBTITLE_HI_OFFSET = $03
    SUBTITLE_LOW_OFFSET = $08
        ; $00 - $1f to adjust text-centering.
        

    UI_Word _Sq0, "Sq0", $80
    UI_Word _Sq1, "Sq1", $80
    UI_Word _Tri, "Tri", $80
    UI_Word _Noi, "Noise", $80
    UI_Word _DMC, "DMC", $80
    UI_Word _Hex, ": $", $80


;============================================================
; Song Registry
;============================================================

    ; Usage:   Song <Internal_Name>, <Tempo>, <"UI Text">, 

    ;Internal name must match that used in Channels
    ;   ie: Song Fanfare, <Tempo>, <UI_text>
    ;       matches
    ;       Channel Fanfare_Sq0

    .include "user/Song_Data/Overworld.s"
    Song Overworld, 9, "Overworld"

    .include "user/Song_Data/Khevari_Dunes.s"
    Song Khevari, 6+6, "Khevari Dunes"

        ;I type 6+7 to mean 16ths of length 6 and 7.
            ;Some songs compress better when "8th" length is functionally 16th, denoted as just Tempo = 6
;
 
