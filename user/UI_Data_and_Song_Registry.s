;============================================================
; Character Dictionary
;============================================================

    ;The tile data is located at `engine/Tri_Pulse_UI_Tiles.bin`
    ;   Modify it as needed, but ensure this Character Dictionary is updated to match.
    
    
    _A = $0A
    _B = $0B
    _C = $0C
    _D = $0D
    _E = $0E
    _F = $0F
    _G = $10
    _H = $11
    _I = $12
    _J = $13
    _K = $14
    _L = $15
    _M = $16
    _N = $17
    _O = $18
    _P = $19
    _Q = $1A
    _R = $1B
    _S = $1C
    _T = $1D
    _U = $1E
    _V = $1F
    _W = $20
    _X = $21
    _Y = $22
    _Z = $23

    _apo_S = $2B      ; 'S  

    _Q_mark = $30     ; ?
    _X_mark = $31     ; !
    _at     = $32     ; @
    _Hash   = $33     ; #
    _Dollar = $34     ; $
    _Percent = $35    ; %
    _Caret  = $36     ; ^
    _Ampersand = $37  ; &
    _Asterisk = $38   ; *
    _LeftParen = $39  ; (
    _RightParen = $3A ; )

    _dash = $3B       ; -
    _colon = $3C      ; :
    _tick = $3D       ; '
    _quote = $3E      ; "

    _spc = $3f        ; 
    ; WARNING: Tile IDs $80-$ff are not supported by the text engine. 
    ;   Using a tile ID greater than $7f results in undefined behavior.

    ; WARNING: Tile IDs `$3f` and `$ff` must remain empty.
;============================================================
; Compressed Text Dictionary
;============================================================
    ; Defines reusable text sequences for compression and ease of authoring.
    ;
    ; See the README for details and limitations


            UI_Word __dash__, _spc, _dash, _spc|$80

            UI_Word _CURRENT_TRACK__, _C, _U, _R, _R, _E, _N, _T, _spc ;No |$80 terminator.
                UI_Word _TRACK__, _T, _R, _A, _C, _K, _spc|$80

 

            ;This message appears below "Tri-Pulse Studios"
            ;See the README for details.
            UI_Word _SUBTITLE, _spc|$80
     
            SUBTITLE_OFFSET = $00 
                ;$00 - $1f to adjust text-centering.
                ;$0a worked for " in 8KB"

            UI_Word _2026, 2, 0, 2, 6|$80


;============================================================
; Song Registry
;============================================================

    ; Usage:   Song <Internal_Name>, <Tempo>, <{_U, _I, _spc, _T, _E, _X, _T}>, 
        ;Curly braces around UI_Text are needed.

    ;Internal name must match that used in Channels
    ;   ie: Song Fanfare, <Tempo>, <UI_text>
    ;       matches
    ;       Channel Fanfare_Sq0


    .include "user/Song_Data/Examples/Scale_Demo.s"

    Song Scale_Demo, 12, {_S, _C, _A, _L, _E, _spc, _D, _E, _M, _O}  
          
        ;I type 6+7 to mean 16ths of length 6 and 7.
            ;Some songs compress better when "8th" length is functionally 16th, denoted as just Tempo = 6
;

