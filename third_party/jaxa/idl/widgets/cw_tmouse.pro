;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_TMOUSE()
;               
; Purpose     : Convert a draw-event into an action string.
;               
; Explanation : See CW_MOUSE. This routine takes the ID of a CW_MOUSE
;               compound widget and translates the supplied widget-draw
;               event into an "action string" according to the current
;               status of the CW_MOUSE.
;               
; Use         : action = CW_TMOUSE(CW_ID,EVENT)
;    
; Inputs      : CW_ID : The compound widget id returned by CW_MOUSE.
;
;               EVENT : A widget_draw event.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns an "action string".
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utility, Display
;               
; Prev. Hist. : Based on cmouse_action
;
; Written     : Stein Vidar H. Haugan, UiO, 13 June 1996
;               
; Modified    : Not yet.
;
; Version     : 1, 13 June 1996
;-            

FUNCTION cw_tmouse,id,ev
  ON_ERROR,0
  WIDGET_CONTROL,id,get_uvalue=status,/no_copy
  
  ;; Default
  uvalue = ''
  
  ;; What happened?
  CASE ev.type OF
     0: press = ev.press        ; Button press
     1: press = -1*ev.release   ; Button release
     2: press = status.disp.press ; Motion, status.press is 0 if not applicable
     3: press = 0               ; Viewport motion -- ignore
  END
  
  ;; Return corresponding uvalues
  CASE press OF
     -1: uvalue = status.disp.release(0)
     -2: uvalue = status.disp.release(1)
     -4: uvalue = status.disp.release(2)
     0: uvalue = status.disp.motion
     1: BEGIN 
        WIDGET_CONTROL,status.select1,get_uvalue=uvalue
        IF NOT status.repeat1(status.current(0)) THEN press = 0
     END
     2: BEGIN
        WIDGET_CONTROL,status.select2,get_uvalue=uvalue
        IF NOT status.repeat2(status.current(1)) THEN press = 0
     END
     4: BEGIN
        WIDGET_CONTROL,status.select3,get_uvalue=uvalue
        IF NOT status.repeat3(status.current(2)) THEN press = 0
     END
  END
  
  press = press > 0 ;; Negative values shouldn't repeat
  
  ;; Put back for later.
  
  status.disp.press = press
  
  WIDGET_CONTROL,id,set_uvalue=status,/no_copy
  
  RETURN,uvalue
END
