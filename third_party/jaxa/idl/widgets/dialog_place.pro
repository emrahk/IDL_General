; + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
;+
; NAME:
;	DIALOG_PLACE
;
; PURPOSE:
;	Place a widget at a specified location.
;
; CATEGORY:
;	WIDGETS
;
; CALLING SEQUENCE:
;	DIALOG_PLACE, base_id [, /CENTER, XPOS = , YPOS = ]
;
; INPUTS:
;       base_id: Id of the widget to place
;
; KEYWORDS:
;       CENTER     : Place the widget at the center of the current screen.
;       XPOS, YPOS : If specified, place the upper left corner of the 
;                    widget at XPOS, YPOS.  Overrides keyword CENTER.
;
; OUTPUTS:
;       NONE
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;       Maps the widget BASE_ID to the screen.
;
; RESTRICTIONS:
;	When the widget base is created, it should use the keyword MAP = 0
;       so that when DIALOG_PLACE is called, the widget does not flash on the
;       screen.  See example below.
;
; EXAMPLES:
;
;       base = WIDGET_BASE (MAP = 0)
;         .
;         .
;         .
;       WIDGET_CONTROL, base, /REALIZE 
;       DIALOG_PLACE, base, /CENTER
;
; MODIFICATION HISTORY:
;	Written, 1999 January, Robert.Mallozzi@msfc.nasa.gov
;                This routine supercedes PLACE_MENU.
;-
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PRO DIALOG_PLACE, base_id, $
    CENTER = center, $
    XPOS = xpos, YPOS = ypos

 
    IF (N_ELEMENTS (base_id) EQ 0) THEN BEGIN
       MESSAGE, /CONTINUE, 'Missing parameter: BASE_ID.'
       RETURN
    ENDIF

    IF (NOT WIDGET_INFO (base_id, /VALID)) THEN BEGIN
       MESSAGE, /CONTINUE, 'Invalid widget ID: ' + STRING (base_id)
       RETURN
    ENDIF
    
    ; User forgot to realize the widget
    ;
    IF (NOT WIDGET_INFO (base_id, /REALIZED)) THEN $
       WIDGET_CONTROL, base_id, /REALIZE

    ; Get screen resolution
    ;
    screen = GET_SCREEN_SIZE ()

    ; Get widget size
    ;
    WIDGET_CONTROL, base_id, TLB_GET_SIZE = dialogSize

    ; Compute center placement point
    ; 
    center = [(screen[0] / 2.0) - (dialogSize[0] / 2.0), $ 
              (screen[1] / 2.0) - (dialogSize[1] / 2.0)] 
       
    
    ; Override default center placement?
    ;
    IF (N_ELEMENTS (xpos) EQ 0) THEN $
       xpos = center[0]

    IF (N_ELEMENTS (ypos) EQ 0) THEN $
       ypos = center[1]
    
    ; Place the widget, and map to screen
    ;   
    WIDGET_CONTROL, base_id, TLB_SET_XOFFSET = xpos, TLB_SET_YOFFSET = ypos
    WIDGET_CONTROL, base_id, MAP = 1


END
