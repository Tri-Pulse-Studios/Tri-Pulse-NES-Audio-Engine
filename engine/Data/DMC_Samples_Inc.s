
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

