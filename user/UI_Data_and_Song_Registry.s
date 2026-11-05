;============================================================
; Compressed Text Dictionary
;============================================================
    ; Defines reusable text sequences for compression and ease of authoring.
    ;
    ; See the README for details and limitations


    UI_Word __dash__, " - ", $80

    UI_Word _CURRENT_TRACK__, "CURRENT "
    UI_Word _TRACK__, "TRACK ", $80
        TRACK_OFFSET = 6
            ;Affects the `TRACK 01 - <Song_Name>` Centering
                            
        CURRENT_PLAYING_OFFSET = TRACK_OFFSET + 5
            ;Affects the `<Song_Name>` Centering under `CURRENT TRACK`
                ;Track +5 Keeps simular H Center, but customize however.

    ; This message appears below "Tri-Pulse Studios"
    ; See the README for details.
    UI_Word _SUBTITLE_HI, "Custom Subtitle", $80
    UI_Word _SUBTITLE_LOW, "Goes Here", $80

        SUBTITLE_HI_OFFSET = 8
        SUBTITLE_LOW_OFFSET = 11
        

    UI_Word _Sq0, "Sq0", $80
    UI_Word _Sq1, "Sq1", $80
    UI_Word _Tri, "Tri", $80
    UI_Word _Noi, "Noise", $80
    UI_Word _DMC, "DMC", $80
    UI_Word _Hex, ": $", $80


    UI_Word _2026, "2026", $80

;============================================================
; Song Registry
;============================================================

    ; Usage:   Song <Internal_Name>, <Tempo>, <"UI Text">, 


    ;Internal name must match that used in Channels
    ;   ie: Song Fanfare, <Tempo>, <UI_text>
    ;       matches
    ;       Channel Fanfare_Sq0

    .include "user/Song_Data/Examples/Scale_Demo.s"
    Song Scale_Demo, 12, "Scale Demo"

        ;I type 6+7 to mean 16ths of length 6 and 7.
            ;Some songs compress better when "8th" length is functionally 16th, denoted as just Tempo = 6
;
 
