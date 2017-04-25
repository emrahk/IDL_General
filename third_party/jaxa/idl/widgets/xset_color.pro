;---------------------------------------------------------------------------
; Document name: xset_color.pro
; Created by:    Liyun Wang, GSFC/ARC, August 18, 1994
;
; Last Modified: Thu Feb 15 15:05:24 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XSET_COLOR
;
; PURPOSE:
;       Change color index interactively
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       xset_color, color_var [, min = min, max = max]
;
; INPUTS:
;       COLOR_VAR - Integer, original color index
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       COLOR_VAR - New color index value
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       MIN   -- Minimum value of the range, default: 0
;       MAX   -- Maximum value of the range, default: !d.n_colors-1
;       TITLE -- Title of the widget; default: "Set Color"
;       INSTRUCT -- A brief instruction to the user for running the program
;       GROUP -- Group ID of an upper widget which would be desensitized if
;                GROUP is set upon calling this routine
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
;       Utility, widget
;
; PREVIOUS HISTORY:
;       Written August 18, 1994, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, August 18, 1994
;       Version 2, Liyun Wang, GSFC/ARC, May 2, 1995
;          Get rid of common block
;       Version 3, November 9, 1995, Liyun Wang, GSFC/ARC
;          Added check to guarentee the input value is a numerical one
;             and within the allowed range
;          Positioned the widget in the center of the screen
;          Added INSTRUCT keyword
;       Version 4, February 15, 1996, Liyun Wang, GSFC/ARC
;          Xresource option disabled for IDL version 3.5 and earlier
;       Version 5, 12 August 1996, Zarro, GSFC
;          Converted to use HANDLES
;	Version 6, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 6, 8 April 1998
;-

;---------------------------------------------------------------------------
;  Event handler
;---------------------------------------------------------------------------
PRO XSET_COLOR_EVENT, event

   ON_ERROR, 2

   WIDGET_CONTROL, event.top, get_uvalue = unseen
   info=get_pointer(unseen,/no_copy)
   if datatype(info) ne 'STC' then return
   WIDGET_CONTROL, event.id, get_uvalue = uvalue, get_value = cur_value

   CASE (uvalue) OF
      'ACCEPT': BEGIN
         WIDGET_CONTROL, info.sld_id, get_value = value
         IF (value NE info.value_sv) THEN BEGIN
            info.value_sv = FIX(value)
         ENDIF
         xkill, event.top
      END
      'RESET': BEGIN
         value = info.value_sv
         WIDGET_CONTROL, info.sld_id, set_value = value
         WIDGET_CONTROL, info.info_id, set_value = value
         POLYFILL, info.dispw_x, info.dispw_y, /dev, color = value
      END
      'CANCEL': BEGIN
         value = info.value_sv
         xkill, event.top
      END
      'SLIDER': BEGIN
         WIDGET_CONTROL, info.sld_id, get_value = value
         WIDGET_CONTROL, info.info_id, set_value = value
         POLYFILL, info.dispw_x, info.dispw_y, /dev, color = value
      END
      'KEYBOARD': BEGIN         ; Value entered from the keyboard
         value = cur_value(0)
         IF valid_num(value) EQ 1 THEN BEGIN
            IF value LT info.min OR value GT info.max THEN BEGIN
               WIDGET_CONTROL, info.text, $
                  set_value='Input value is out of allowed range!'
               WAIT, 2
               WIDGET_CONTROL, info.text, set_value=info.instruct
            ENDIF ELSE BEGIN
               WIDGET_CONTROL, info.info_id, set_value=value
               WIDGET_CONTROL, info.sld_id, set_value=value
               POLYFILL, info.dispw_x, info.dispw_y, /dev, color=value
            ENDELSE
         ENDIF ELSE BEGIN
            WIDGET_CONTROL, info.text, $
               set_value=STRTRIM(value, 2)+' is not a valid number!'
            WAIT, 2
            WIDGET_CONTROL, info.text, set_value=info.instruct
         ENDELSE
      END
      ELSE:
   ENDCASE

   set_pointer,unseen,info,/no_copy
END

;---------------------------------------------------------------------------
;  Main program
;---------------------------------------------------------------------------
PRO XSET_COLOR, color_var, MIN = MIN, MAX = MAX, title=title, group=group,$
                instruct=instruct

   ON_ERROR, 2

   IF datatype(color_var) NE 'INT' AND datatype(color_var) NE 'LON' THEN BEGIN
      MESSAGE, 'Sytax: XSET_COLOR, color_index', /cont
      RETURN
   ENDIF

   value_sv = color_var < (!d.table_size-1)

   IF N_ELEMENTS(title) EQ 0 THEN title = 'XSET_COLOR'
   IF N_ELEMENTS(instruct) EQ 0 THEN instruct = ''

   base =  WIDGET_BASE (title = title, /column, space = 20)

   row1 = WIDGET_BASE(base, /row)
   temp1 = WIDGET_LABEL(row1,value = ' ')
   button_base = WIDGET_BASE (row1,space = 20, xpad = 30, /row, /frame)
   
   IF !version.release LT '3.6' THEN BEGIN
      done = WIDGET_BUTTON (button_base, value='Accept', uvalue='ACCEPT')
      resetting = WIDGET_BUTTON (button_base, value='Reset', uvalue='RESET')
      cancel = WIDGET_BUTTON (button_base, value='Cancel', uvalue='CANCEL')
   ENDIF ELSE BEGIN
      done = WIDGET_BUTTON (button_base, value='Accept', $
                            uvalue='ACCEPT', resource='AcceptButton')
      resetting = WIDGET_BUTTON (button_base, value='Reset', $
                                 uvalue='RESET')
      cancel = WIDGET_BUTTON (button_base, value='Cancel', $
                              uvalue='CANCEL', resource='QuitButton')
   ENDELSE
   temp1 = WIDGET_LABEL(row1,value = ' ')

   base1 = WIDGET_BASE(base, /column, /frame)

   text = WIDGET_TEXT(base1, value=instruct)

   row2 = WIDGET_BASE (base1, /row, space = 30, xpad = 30)
   temp1 = WIDGET_BASE(row2, /frame)
   info_id = cw_field(temp1, title = 'Color Index', value = value, $
                      /row, xsize = 3, /RETURN, uvalue = 'KEYBOARD')

   temp2 = WIDGET_BASE(row2, /row, /frame)
   win_width = 20               ; Width of the display area in pixels
   temp = WIDGET_LABEL(temp2, value = 'Color')
   draw_id = WIDGET_DRAW(temp2, xsize = win_width, ysize = win_width, /frame)

   slider_x = 250 & slider_y = 30
   IF (N_ELEMENTS(min) EQ 0) THEN min = 0
   IF (N_ELEMENTS(max) EQ 0) THEN max = !d.table_size-1
   sld_id =  WIDGET_SLIDER (base1, minimum = min, maximum = max, $
                            value = value, /frame, uvalue = 'SLIDER', $
                            ysize = slider_y, /drag, /suppress)

   offsets = get_cent_off(base, valid = valid)

   IF valid THEN $
      WIDGET_CONTROL, base, /realize, /map, tlb_set_xoff=offsets(0),$
      tlb_set_yoff=offsets(1), /show $
   ELSE $
      WIDGET_CONTROL, base, /realize, /map, /show

   dispw_x = [-10, win_width+20, win_width+20, -10, -10]
   dispw_y = [-10, -10, win_width+20, win_width+20, -10]

   WIDGET_CONTROL, draw_id, get_value = win_id
   WSET, win_id
   POLYFILL, dispw_x, dispw_y, /dev, color = value_sv

   WIDGET_CONTROL, info_id, set_value = value_sv
   WIDGET_CONTROL, sld_id, set_value = value_sv

;---------------------------------------------------------------------------
;  Make a structure to pass some infos to the event handler, including the ID
;  of the unseen widget
;---------------------------------------------------------------------------
   info = {sld_id:sld_id, info_id:info_id, win_id:win_id, $
           dispw_x:dispw_x, dispw_y:dispw_y, value_sv:value_sv, $
           text:text, min:min, max:max, instruct:instruct}

;---------------------------------------------------------------------------
;  Make a pointer for passing the info back
;---------------------------------------------------------------------------
   
   make_pointer,unseen
   set_pointer,unseen,info,/no_copy

   WIDGET_CONTROL, base, set_uvalue = unseen

   XMANAGER, 'xset_color', base, group_leader = group,/modal
   if xalive(base) then xmanager
   info=get_pointer(unseen,/no_copy)
   free_pointer,unseen
   if datatype(info) eq 'STC' then color_var = info.value_sv
END

;---------------------------------------------------------------------------
; End of 'xset_color.pro'.
;---------------------------------------------------------------------------
