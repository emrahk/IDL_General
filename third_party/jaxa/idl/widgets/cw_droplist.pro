;---------------------------------------------------------------------------
; Document name: cw_droplist.pro
; Created by:    Liyun Wang, GSFC/ARC, May 23, 1995
;
; Last Modified: Wed May 24 15:48:52 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       CW_DROPLIST()
;
; PURPOSE:
;       Create a compound widget to simulate a droplist widget
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = cw_droplist(parent, value=value, uvalue=uvalue)
;
; INPUTS:
;       PARENT - The ID of the parent widget
;       VALUE  - String array, Value of list
;       UVALUE - User value of the list
;
; OPTIONAL INPUTS: 
;       INITIAL - Index of item in the list to be shown initially
;       XOFFSET - The X offset of the widget relative to its parent
;       YOFFSET - The Y offset of the widget relative to its parent
;       FONT    - The name of the font to be used for the button titles
;
; OUTPUTS:
;       RESULT - Widget ID of this compound widget
;
; OPTIONAL OUTPUTS:
;       BUTTONS - ID of droplist buttons, starting from the "face" (or base)
;                 button (#0)
;
; KEYWORD PARAMETERS: 
;       FRAME - Frame the list button
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written May 23, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 23, 1995
;
; VERSION:
;       Version 1, May 23, 1995
;-
;
;---------------------------------------------------------------------------
;  Sample program
;---------------------------------------------------------------------------
; PRO testing_event, event
;    WIDGET_CONTROL, event.id, get_uvalue = uvalue
;    IF uvalue EQ 'QUIT' THEN WIDGET_CONTROL, event.top, /destroy
;    RETURN
; END

; PRO testing
;    base = WIDGET_BASE(title = 'Testing', /column)
;    temp = WIDGET_BASE(base, /row)
;    lable = WIDGET_LABEL(temp, value = 'Value', font = '10x20')
;    bt = cw_droplist(temp, value= ['This is 1st Button',$
;                                   'This is 2nd Button',$
;                                   'This is 3rd Button'], $
;                     uvalue = ['1st','2nd','3dr'], $
;                     initial = 2, font = '9x15bold')
;    quit = WIDGET_BUTTON(base, value = 'Quit', uvalue = 'QUIT')
;    
;    WIDGET_CONTROL, base, /realize
;    XMANAGER, 'testing', base
;    xmanager
; END

FUNCTION CW_DROPLIST_EVENT, ev
   WIDGET_CONTROL, ev.id, get_uvalue = uvalue
   WIDGET_CONTROL, ev.id, get_value = value
   child = WIDGET_INFO(ev.handler, /child)
   WIDGET_CONTROL, child, set_value = value
   WIDGET_CONTROL, ev.handler, set_uvalue = uvalue
   return, { ID:ev.handler, TOP:ev.top, HANDLER:0L, value:uvalue }
END

FUNCTION cw_droplist, parent, value=menu_list, uvalue=uvalue, font=font, $
                      initial=initial, xoffset=xoffset, yoffset=yoffset,$
                      frame=frame, buttons=buttons
   ON_ERROR, 2
   IF N_ELEMENTS(parent) EQ 0 OR N_ELEMENTS(uvalue) EQ 0 OR $
      N_ELEMENTS(menu_list) EQ 0 THEN $
      MESSAGE, 'Syntax: id = cw_droplist(parent, value=value, uvalue=uvalue)'
   
   IF N_ELEMENTS(uvalue) NE N_ELEMENTS(menu_list) THEN $
      MESSAGE, 'Number of UVALUE incompatible with that of VALUE'

   IF (N_ELEMENTS(xoffset) EQ 0) THEN xoffset=0
   IF (N_ELEMENTS(yoffset) EQ 0) THEN yoffset=0
   IF N_ELEMENTS(initial) EQ 0 THEN initial = 0
   IF N_ELEMENTS(frame) EQ 0 THEN frame = 0
   IF N_ELEMENTS(font) EQ 0 THEN font = ''
   len = MAX(STRLEN(menu_list))
   menu_list = strpad(menu_list, len, /after)
   base = WIDGET_BASE(parent, /column, event_fun='cw_droplist_event', $
                      xoffset=xoffset, yoffset=yoffset, frame = frame)
   ivalue = menu_list(initial)
   bt = WIDGET_BUTTON(base, value = ivalue, /menu, font=font)

   empty = WIDGET_BUTTON(bt, value = '')
   WIDGET_CONTROL, empty, sensitive = 0
   
   n = N_ELEMENTS(menu_list)
   lbt = LONARR(n)
   FOR i = 0, n-1 DO BEGIN
      lbt(i) = WIDGET_BUTTON(bt, value = menu_list(i), $
                             uvalue = uvalue(i), font=font)
   ENDFOR
   buttons = [bt,lbt]
   RETURN, base
END

;---------------------------------------------------------------------------
; End of 'cw_droplist.pro'.
;---------------------------------------------------------------------------
