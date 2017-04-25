;---------------------------------------------------------------------------
; Document name: xset_value.pro
; Created by:    Liyun Wang, GSFC/ARC, August 18, 1994
;
; Last Modified: Thu Dec  5 13:58:45 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       XSET_VALUE
;
; PURPOSE:
;       Set the value of a variable interactively with a slider.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       xset_value, value [, min = min] [, max = max]
;
; INPUTS:
;       VALUE - Current default value; may be changed upon exit
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       VALUE - Updated value
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       MIN   -- Minimum value of the range (Default: 0)
;       MAX   -- Maximum value of the range (Default: 100)
;       TITLE -- Title of the widget; default: "Number Picker"
;       INSTRUCT -- A brief instruction to the user for running the program
;       GROUP -- Group ID of an upper widget on which this one depends
;       FONT  -- Button FONT 
;       STATUS -- returned as 0 is user hit CANCEL, otherwise 1
;
; CALLS:
;       BELL, DATATYPE
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
;       Utilities, Widget
;
; PREVIOUS HISTORY:
;       Written August 18, 1994, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, August 18, 1994
;       Version 2, Liyun Wang, GSFC/ARC, May 2, 1995
;          Gewt rid of common block
;       Version 3, November 9, 1995, Liyun Wang, GSFC/ARC
;          Added check to guarentee the input value is a numerical one
;             and within the allowed range
;          Positioned the widget in the center of the screen
;          Added INSTRUCT keyword
;       Version 4, 12 August 1996, Zarro, GSFC
;          Converted to use HANDLES, added FONT and STATUS keywords, and
;          removed restriction to exit when value is not changed.
;       Version 5, December 5, 1996, Liyun Wang, NASA/GSFC
;          Fixed problem with floating point number
;
; VERSION:
;       Version 5
;-

;---------------------------------------------------------------------------
;  Event handler
;---------------------------------------------------------------------------
PRO XSET_VALUE_EVENT, event

   ON_ERROR, 2

   WIDGET_CONTROL, event.top, get_uvalue=unseen
   info = get_pointer(unseen, /no_copy)
   IF datatype(info) NE 'STC' THEN RETURN

   WIDGET_CONTROL, event.id, get_uvalue=uvalue, get_value=cur_value
   CASE (uvalue) OF
      'ACCEPT': BEGIN
         WIDGET_CONTROL, info.info_id, get_value=value
         value = trim(value(0))
         xset_check, info, value, status=status
         IF status THEN BEGIN
            info.value_sv = value
            xkill, event.top
         ENDIF
      END
      'RESET': BEGIN
         value = info.value_sv
         WIDGET_CONTROL, info.sld_id, set_value=value
         WIDGET_CONTROL, info.info_id, set_value=value
      END
      'CANCEL': BEGIN
         info.status = 0
         xkill, event.top
      END
      'SLIDER': BEGIN
;         WIDGET_CONTROL, info.text, set_value='',/appe
         WIDGET_CONTROL, info.sld_id, get_value=value
         WIDGET_CONTROL, info.info_id, set_value=value
      END
      'KEYBOARD': BEGIN
         value = trim(cur_value(0))
         xset_check, info, value, status=status
      END
      ELSE: do_nothing = 1
   ENDCASE
   set_pointer, unseen, info, /no_copy
END

;----------------------------------------------------------------------------

PRO xset_check, info, value, status=status
   status = 0

   IF NOT valid_num(value) THEN BEGIN
      WIDGET_CONTROL, info.text, set_value=STRTRIM(value, 2)+$
         ' is not a valid number!'
      WIDGET_CONTROL, info.text, set_value=info.instruct, /append
      RETURN
   ENDIF
   
   IF value LT info.min OR value GT info.max THEN BEGIN
      WIDGET_CONTROL, info.text, $
         set_value='Input value is out of allowed range!'
      WIDGET_CONTROL, info.text, set_value=info.instruct, /append
      RETURN
   ENDIF
   
   status = 1
;   WIDGET_CONTROL, info.text, set_value=''
   WIDGET_CONTROL, info.info_id, set_value=value
   WIDGET_CONTROL, info.sld_id, set_value=value
 RETURN
END

;---------------------------------------------------------------------------
;  Main program
;---------------------------------------------------------------------------
PRO XSET_VALUE, value, min=min, max=max, title=title, group=group, $
                instruct=instruct, font=font, status=status

   ON_ERROR, 2

   dtype = datatype(value, 2)
   IF ((dtype GE 6) OR (dtype LT 1)) THEN BEGIN
;---------------------------------------------------------------------------
;     data not integer or (double precision) floating number
;---------------------------------------------------------------------------
      MESSAGE,'Wrong data type.',/cont
      RETURN
   ENDIF

   caller=get_caller(stat)
   if stat and (not xalive(group)) then xkill,/all
   value_sv = value
  
   IF N_ELEMENTS(title) EQ 0 THEN title = 'Number Picker'
   IF N_ELEMENTS(instruct) EQ 0 THEN instruct = ''
   if datatype(font) ne 'STR' then font=''

   base = WIDGET_BASE (title = title, /column, space=20)

   row1   = WIDGET_BASE(base, /row, xpad = 30, space = 20, /frame)
   done   = WIDGET_BUTTON(row1, value = 'Accept', uvalue = 'ACCEPT',font=font)
   reset  = WIDGET_BUTTON(row1, value = 'Reset', uvalue = 'RESET',font=font)
   cancel = WIDGET_BUTTON(row1, value = 'Cancel', uvalue = 'CANCEL',font=font)

   base1 = WIDGET_BASE(base, /column, /frame)

   text = WIDGET_TEXT(base1, value=instruct, ysize=2)

   row2 = WIDGET_BASE(base1, /column, /frame, xpad=30)
   info_id = cw_field(row2, title='Current Value:', value=value, field=font, $
                      xsize=10, /RETURN, uvalue='KEYBOARD', font=font)

   slider_y = 30

   IF (dtype LE 2) THEN BEGIN
;---------------------------------------------------------------------------
;     value is a short integer
;---------------------------------------------------------------------------
      IF (N_ELEMENTS(min) EQ 0) THEN min = 0
      IF (N_ELEMENTS(max) EQ 0) THEN max = 100
      sld_id =  WIDGET_SLIDER(base1, minimum = min, maximum = max, $
                              value = value, /frame, uvalue = 'SLIDER', $
                              ysize = slider_y, /drag,/suppress)
   ENDIF ELSE IF (dtype EQ 3) THEN BEGIN
;---------------------------------------------------------------------------
;     value is a long integer
;---------------------------------------------------------------------------
      IF (N_ELEMENTS(min) EQ 0) THEN min = 0l
      IF (N_ELEMENTS(max) EQ 0) THEN max = 100l
      sld_id =  WIDGET_SLIDER(base1, minimum = min, maximum = max, $
                              value = value, /frame, uvalue = 'SLIDER',$
                              ysize = slider_y, /drag, /suppress)
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     value is a floating point number (either single or double precsion)
;---------------------------------------------------------------------------
      IF (N_ELEMENTS(min) EQ 0) THEN min = 0.0
      IF (N_ELEMENTS(max) EQ 0) THEN max = 100.0
      cur_value = FLOAT(value)
      sld_id = cw_fslider(base1, minimum=min, maximum=max, $
                         value=cur_value, uvalue='SLIDER', $
                         /frame, /drag, /suppress, ysize=slider_y)
   ENDELSE

;-- realize and center main base

   xrealize, base, group=group, /center

   status=1
   info = {sld_id:sld_id, info_id:info_id, value_sv:value_sv, text:text, $
           min:min, max:max, instruct:instruct, status:status}

   make_pointer, unseen
   set_pointer, unseen, info, /no_copy
   WIDGET_CONTROL, base, set_uvalue=unseen
   XMANAGER, 'xset_value', base, group_leader=group, /modal
   IF xalive(base) THEN xmanager
   info = get_pointer(unseen, /no_copy)
   free_pointer, unseen
   IF datatype(info) EQ 'STC' THEN BEGIN
      value = info.value_sv
      status = info.status
   ENDIF
END

;---------------------------------------------------------------------------
; End of 'xset_value.pro'.
;---------------------------------------------------------------------------
