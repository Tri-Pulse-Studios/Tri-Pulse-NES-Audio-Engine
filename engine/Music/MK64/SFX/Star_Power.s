_8th .set -1 ;$0b ;6-5

    ;68 Bytes
        ;Loses a lot trying to make it 6+5
        ;Maybe can re-use the YV adjustment Idea. (Which itself is based on lap 3 speed up.)

.align 256
py_Segment Star_Power_Sq0, PageFit

    Channel Star_Power_Sq0, SP_Sq0
        Header C4, Lead_d12_12_0
        End_Intro:

        _1:
        Notes qtr,C4, qtr,C4, 8th,C4, qtr,C4
        Repeat _1, 1

        Notes qtr,C4
        _2:

        Shift_Pitch C4, B3
        Riff _1, _2
    Loop Star_Power_Sq0
    Loop_SP_Sq0:


    Channel Star_Power_Sq1
        Header F3, Pad_d25_8_3_v12

        Riff SP_Sq0::_1, Loop_SP_Sq0

    Loop Star_Power_Sq1, "Riffed"

py_Segment_End Star_Power_Sq0



py_Segment Star_Power_Tri, PageFit

    Channel Star_Power_Tri 
        Header {C5,+Octave}, SFX_Hoot_M8 

        _1:
            Riff _2, _3

            _2:
            Notes qtr,rest, qtr,Fs5, hlf,C5

            Notes qtr,Fs5, 8th,Fs5, 

            _2_7:
            Notes qtr,C5, dqt,C5  

        ;

        _3:
        Riff _1, _2_7
        Notes qtr,Fs5, 8th,C5, qtr,C5

    Loop Star_Power_Tri

py_Segment_End Star_Power_Tri



py_Segment Star_Power_dmc, PageFit

    Channel Star_Power_dmc
        Header D2, T_0f__d25

        _1:
            Notes dqt,D2, dqt,A2, hlf,D3

            ; Shift_Pitch +Octave
            ; Notes 8th,D4
            ; Shift_Pitch -Octave

            Notes qtr,A2, qtr,D2, qtr,A2, 

        _2:
        Shift_Pitch D2, C2
        Riff _1, _2

    Loop Star_Power_dmc
py_Segment_End Star_Power_dmc


py_Segment Star_Power_Noise, PageFit

    Channel Star_Power_Noise
        Noise_Header ::Star_Power_NB, As3_Tom    ;2f D50 Kick works fine

        ;1
        Notes qtr,Crash_3, 8th,Rasp_c, 8th,Hat_Kick, 

        ;1.3
        Riff _2_7, _3
        Repeat "2b", 4

        _2_5:
            Notes qtr,Shaker_Kick, 8th,Rasp_2_Kick, 8th,Hat_2  ;Offset Kick


            _2_7:
            Notes qtr,Shaker_Kick, 8th,Rasp_2,      8th,Hat_Kick

        _3:
        Repeat _2_7, 6

        Riff _2_5, _3

    Loop Star_Power_Noise

py_Segment_End Star_Power_Noise

