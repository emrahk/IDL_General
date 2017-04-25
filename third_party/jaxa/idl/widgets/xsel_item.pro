;---------------------------------------------------------------------------
; Document name: xsel_item.pro
; Created by:    Liyun Wang, GSFC/ARC, February 27, 1995
;
; Last Modified: Wed May 24 16:20:26 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XSEL_ITEM()
;
; PURPOSE:
;       Select an item from a given string list (similar to XSEL_LIST)
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = xsel_item(str_array)
;
; INPUTS:
;       STR_ARRAY -- A string vector that contains the given list
;
; OPTIONAL INPUTS:
;       TITLE -- A title above the displayed item, default to: "Selected Item"
;       FONT  -- name of font to be used. Default: 9x15bold
;
; OUTPUTS:
;       Result -- Index of the chosen list. If the operation is canceled, 
;                 a -1 is returned.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       DATATYPE, CW_DROPLIST
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
;       Written February 27, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, February 27, 1995
;       Version 2, Liyun Wang, GSFC/ARC, May 24, 1995
;          Got rid of common block;
;          Used CW_DROPLIST compound widget program
;       Version 3, Zarro, GSFC, 12 August 1996
;          Converted to using HANDLES
; VERSION:
;       Version 3, May 24, 1995
;-
;

;---------------------------------------------------------------------------
;  Event handler
;---------------------------------------------------------------------------
PRO xsel_item_event, event
   WIDGET_CONTROL, event.top, get_uvalue = unseen
   aa=get_pointer(unseen,/no_copy)
   if datatype(aa) ne 'STC' then return
   WIDGET_CONTROL, event.id, get_uvalue = uvalue
   i = (WHERE(uvalue EQ aa.uvalue))(0)
   IF i GE 0 THEN aa.index = i
   CASE (uvalue) OF
      'CANCEL': BEGIN
         aa.index = -1
         xkill, event.top
      END
      'ACCEPT': xkill, event.top
      ELSE:
   ENDCASE

;---------------------------------------------------------------------------
;  Stuff information back
;---------------------------------------------------------------------------

   set_pointer,unseen,aa,/no_copy
END

;---------------------------------------------------------------------------
;  Main program
;---------------------------------------------------------------------------
FUNCTION xsel_item, str_array, title=title, font=font, group=group
   ON_ERROR, 2
   IF datatype(str_array) NE 'STR' THEN BEGIN
      PRINT, 'Usage: result = xsel_item(str_array)'
      RETURN, -1
   ENDIF
   IF N_ELEMENTS(title) EQ 0 THEN title = 'Selected Item'
   IF N_ELEMENTS(font) EQ 0 THEN font = '9x15bold'

   index = 0
   num = N_ELEMENTS(str_array)
   str_man = MAX(STRLEN(str_array))

   base = WIDGET_BASE(title = 'XSEL_ITEM', /column)

   button_bs = WIDGET_BASE(base, /column, /frame, xpad = 20)
   accept = WIDGET_BUTTON(button_bs, value = 'Accept', uvalue = 'ACCEPT')
   cancel = WIDGET_BUTTON(button_bs, value = 'Cancel', uvalue = 'CANCEL')

   disp_bs = WIDGET_BASE(base, /column, /frame, ypad = 10)
   
   FOR i = 0, N_ELEMENTS(title)-1 DO BEGIN
      temp = WIDGET_LABEL(disp_bs, value = title(i),font=font)
   ENDFOR
   uvalue = STRTRIM(INDGEN(N_ELEMENTS(str_array)),2)
   temp = cw_droplist(disp_bs, value = str_array, uvalue = uvalue, $
                      font=font, buttons = buttons)

   WIDGET_CONTROL, base, /realize

   aa = {value:str_array, uvalue:uvalue, buttons:buttons, index:index}
   make_pointer,unseen
   set_pointer,unseen,aa,/no_copy
   WIDGET_CONTROL, base, set_uvalue = unseen
   
   XMANAGER, 'xsel_item', base, group = group,/modal
   if xalive(base) then xmanager
   aa=get_pointer(unseen,/no_copy)
   free_pointer,unseen
   if datatype(aa) eq 'STC' then index=aa.index
   return,index
END

;---------------------------------------------------------------------------
; End of 'xsel_item.pro'.
;---------------------------------------------------------------------------
