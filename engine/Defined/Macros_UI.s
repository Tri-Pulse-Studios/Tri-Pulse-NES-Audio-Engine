
;===============================================================
;Song Names
;===============================================================

    .macro Collect_UI_Text v1, v2, v3, v4, v5, \
                           v6, v7, v8, v9, v10, \
                           v11, v12, v13, v14, v15, \
                           v16, v17, v18, v19, v20

        .ifblank v1
            .exitmacro
        .endif

        ; Strings: log each character separately.
        .if .match(.left(1, {v1}), "")

            .repeat .strlen(v1), I

                .if UI_Text_Index > 255
                    .error "Song UI Text Error: Maximum UI text size is 256 bytes"
                    .exitmacro
                .endif

                .ident(.sprintf("UI_Text_%02x", UI_Text_Index)) = \
                    .strat(v1, I)

                UI_Text_Index .set UI_Text_Index + 1

            .endrepeat

        ; Aliases: log the encoded byte directly.
        .else

            .if UI_Text_Index > 255
                .error "Song UI Text Error: Maximum UI text size is 256 bytes"
                .exitmacro
            .endif

            .ident(.sprintf("UI_Text_%02x", UI_Text_Index)) = v1

            UI_Text_Index .set UI_Text_Index + 1

        .endif

        Collect_UI_Text v2, v3, v4, v5, v6, \
                        v7, v8, v9, v10, v11, \
                        v12, v13, v14, v15, v16, \
                        v17, v18, v19, v20
        ;Recurse remaining args.

    .endmacro



    .macro Output_UI_Text

    ;----------------------------------------
    ; UI text bytes
    ;----------------------------------------
    LUT_Song_Names_Text:

        .repeat UI_Text_Index, I
        .byte .ident(.sprintf("UI_Text_%02x", I))
        .endrepeat


    ;----------------------------------------
    ; UI text start indexes
    ;----------------------------------------
    LUT_Name_Start_Indexes:

        .repeat Song_Index, I
        .byte .ident(.sprintf("Song%02x_UI_Start", I))
        .endrepeat

        ; ; End of final song / start of next song
        .byte UI_Text_Index
        ;Having Song_Silence should do it.

    .endmacro

;

;===============================================================
;Compressed Aliases
;===============================================================

    .macro UI_Word Name, Text, EOL_Flag

        .ident(.string(Name)) = UI_Word_Text_Index | $80

        .repeat .strlen(Text), I

            .if I <> .strlen(Text) - 1
                .ident(.sprintf("UI_Word_%02x", UI_Word_Text_Index)) = \
                    .strat(Text, I)

            .else
                .if .blank(EOL_Flag)
                    .ident(.sprintf("UI_Word_%02x", UI_Word_Text_Index)) = \
                        .strat(Text, I)

                .elseif EOL_Flag = $80
                    .ident(.sprintf("UI_Word_%02x", UI_Word_Text_Index)) = \
                        .strat(Text, I) | $80

                .else
                    .error "Invalid Input for EOL Flag"
                .endif

            .endif

            UI_Word_Text_Index .set UI_Word_Text_Index + 1

        .endrepeat

    .endmacro


    

    .macro Output_UI_Words
        UI_Word _LOGO, "Tri-Pulse Studios", $80
        ;UI_Word _LOGO, "TRI-PULSE STUDIOS", $80


        LUT_Words_Text:

            .repeat UI_Word_Text_Index, I
                .byte .ident(.sprintf("UI_Word_%02x", I))
            .endrepeat

    .endmacro


;
