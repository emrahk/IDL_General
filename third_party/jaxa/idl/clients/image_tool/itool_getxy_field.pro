;---------------------------------------------------------------------------
; Document name: ITOOL_GETXY_FIELD.PRO
; Created by:    Liyun Wang, NASA/GSFC, May 5, 1997
;
; Last Modified: Mon May  5 16:45:05 1997 (LWANG@sumop1.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_getxy_field, event
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_GETXY_FIELD()
;
; PURPOSE: 
;       
;
; CATEGORY:
;       
; 
; EXPLANATION:
;       
; SYNTAX: 
;       Result = itool_getxy_field(event)
;
; EXAMPLES:
;       
; INPUTS:
;       EVENT - Event structure
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, May 5, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
;---------------------------------------------------------------------------
;  Get values from INS_X and INS_Y fields
;---------------------------------------------------------------------------
@image_tool_com
   COMMON for_pointing

   WIDGET_CONTROL, point_wid.point_x, get_value=xtemp
   WIDGET_CONTROL, point_wid.point_y, get_value=ytemp
   IF NOT valid_num(xtemp(0)) OR NOT valid_num(ytemp(0)) THEN BEGIN
      xack,'Invalid character(s) in INS_X and/or INS_Y field!', $
         group=event.top, ins='OK'
      RETURN, 0
   ENDIF
   central_pos = [xtemp(0), ytemp(0)]
   saved_x = pointing_stc.pointings(index).ins_x
   saved_y = pointing_stc.pointings(index).ins_y
   saved_pt = pointing_done(index)
   pt_fov_update
   RETURN, 1
   
END


;---------------------------------------------------------------------------
; End of 'ITOOL_GETXY_FIELD.PRO'.
;---------------------------------------------------------------------------
