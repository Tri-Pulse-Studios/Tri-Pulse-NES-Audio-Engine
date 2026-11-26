;============================================================
; Compressed Text Dictionary
;============================================================
    ; Defines reusable text sequences for compressed Song Names.
    ; Also Defines fixed UI Text.
    ;
    ; See the README for details and limitations


    
    UI_Word _CURRENT_TRACK__, "CURRENT "
    UI_Word _TRACK__, "TRACK ", $80

        TRACK_OFFSET = 4
            ; Affects the horizontal centering of:
            ;   `TRACK <Index> - <Song_Name>`
                            
        CURRENT_PLAYING_OFFSET = TRACK_OFFSET + 5
            ; Affects the horizontal centering of:
            ;   `<Song_Name>` beneath `CURRENT TRACK`

            ; TRACK_OFFSET + 5 defaults to a similar centering of `TRACK <Index> - <Song_Name>`.

            

    UI_Word _SUBTITLE_HI, "The Legend of Zelda: ALttP", $80
    UI_Word _SUBTITLE_LOW, "OST by Koji Kondo", $80

        SUBTITLE_HI_OFFSET = 3
        SUBTITLE_LOW_OFFSET = 7
        ; Affects the horizontal centering of:
        ;   `Tri-Pulse Studios`
        ;
        ;     `High Subtitle`
        ;       `Low Title`



    UI_Word __dash__, " - ", $80

    UI_Word _Sq0, "Sq0", $80
    UI_Word _Sq1, "Sq1", $80
    UI_Word _Tri, "Tri", $80
    UI_Word _Noi, "Noise", $80
    UI_Word _DMC, "DMC", $80
    UI_Word _Hex, ": $", $80

    

    UI_Word _2026, "2026", $80

;

;============================================================
; Song Registry
;============================================================
    ; Asigns Song Indexes, registers UI Data for Songs, and emits Song Data
    ;   Usage:   Song <Internal_Name>, <Tempo>, <"UI Text"> 
    

    ; Internal Name must match Channel definitions.
    ;   ie: Song Fanfare, ...
    ;
    ;       Channel Fanfare_Sq0
    ;           Header ...

    .define SONG_DATA_DIR "user/Song_Data/"
    ; Internal Name must also match the Song Data filename.
    ;   ie: Song Fanfare, ...
    ;
    ;   "SONG_DATA_DIR/Fanfare.s"
    

    Song Hyrule_Castle,  9, "Hyrule Castle" ;Intro phrase is 9. Set to 6+7 later.
    Song Death_Mountain, 6+7, "Death Mountain"
    




    ; .undef SONG_DATA_DIR
    ; .define SONG_DATA_DIR "user/Song_Data/Subfolder"




;
 
