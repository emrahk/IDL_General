;+
;
; NAME: 
;	WIDG_TYPE
;
; PURPOSE:
;	Returns the type (TEXT, BUTTON, etc.) of the widget ID.
;
; CATEGORY:
;	Widgets
;
; CALLING SEQUENCE:
;	result = widg_type(widget_id)
;
; CALLED BY:
;
;
; CALLS TO:
;	none
;
; INPUTS:
;       WIDGET_ID : the ID number of the widget to be identified.
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Returns the type of widget (BASE, BUTTON, SLIDER, TEXT, DRAW, LABEL
;	LIST, DROPLIST, ERROR)  
;
; OPTIONAL OUTPUTS:
;	none
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	Widgets must be available
;
; PROCEDURE:
;	Input a widget ID to return the type of widget it is.
;
; MODIFICATION HISTORY:
;	Nov 93 - Elaine Einfalt (HSTX)
;       Oct 95 - Add DROPLIST type. RCJ
;-

function widg_type, widget_id

goodid = widget_info(widget_id, /valid_id)	; is widget id valid

if goodid then begin

   typenum = widget_info(widget_id, /type)	; get the type code
   
   case typenum of                            	; convert type code to text
     0    : type = 'BASE'
     1    : type = 'BUTTON'
     2    : type = 'SLIDER'
     3    : type = 'TEXT'
     4    : type = 'DRAW'
     5    : type = 'LABEL'
     6    : type = 'LIST'
     8    : type = 'DROPLIST'
     else : type = 'ERROR'
   endcase

endif else begin

   print,'Invalid widget ID passed to WIDG_TYPE.'
   type = 'ERROR'

endelse

return, type
end

