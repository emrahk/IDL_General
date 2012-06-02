PRO RMC_MOTION, event
;+
; NAME: rmc_motion
;
;
;
; PURPOSE:       Handles draw widget motion events. Display the cursor
; location and value of image at that location. 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_MOTION, event (automatic call over Window)
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:  
;  $Log: rmc_motion.pro,v $
;  Revision 1.3  2002/05/21 12:30:09  slawo
;  Removed comment which was not as a comment written
;
;  Revision 1.2  2002/05/21 12:29:00  slawo
;  Add comments
;
;-
   
    Widget_Control, event.top, Get_UValue=info, /No_Copy
    
    xloc = StrTrim(Fix(event.x / info.scale), 2)
    yloc = StrTrim(info.dim-1-Fix(event.y / info.scale), 2)
    Widget_Control, info.xLocationID, Set_Value=xloc
    Widget_Control, info.yLocationID, Set_Value=yloc
    
    ;; Make sure value is not byte type.
    
    IF (event.x LT (info.dim*info.scale)) AND $
      (event.y LT (info.dim*info.scale)) AND (event.x GE 0) AND $
      (event.y GE 0)THEN BEGIN   

        value = (*info.image)[event.x, event.y]
        str=string(format='(F10.4)',value)

        ;; Display image value.        
        Widget_Control, info.valueID, Set_Value=StrTrim(str, 2)
        IF event.clicks EQ  1 THEN BEGIN
            
            Widget_Control, info.xMaxLocationID, Set_Value=xloc
            Widget_Control, info.yMaxLocationID, Set_Value=yloc
            
            info.xmax=xloc
            info.ymax=yloc
            
            Widget_Control, info.maxValueID, Set_Value=StrTrim(str, 2)
        ENDIF 
    ENDIF
    
    Widget_Control, event.top, Set_UValue=info, /No_Copy
END
