;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: dsp_strarr.pro
; Created by:    Liyun Wang, NASA/GSFC, September 2, 1994
;
; Last Modified: Wed Nov 23 15:44:21 1994 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;+
; PROJECT:
;      SOHO - CDS
;
; NAME:
;      DSP_STRARR
;
; PURPOSE:
;      To display a string array in a text widget.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;      DSP_STRARR, string_array [, font = font, title=title]
;
; INPUTS:
;      strings -- The string array to be displayed.
; OPTIONAL INPUTS:
;      None.
;
; OUTPUTS:
;      None.
;
; OPTIONAL OUTPUTS:
;      None.
;
; KEYWORD PARAMETERS:
;      FONT   -- Font to be used for the text widget. Default: fixed
;      TITLE  -- Title of the widget window. Default: 'Info Window'
;      ONE_COPY -- Set this keyword to let xmanager know that only one copy of
;                  this widget is allowed to run at one time.
;		XSIZE - x size of widget is max length of text < xsize.  Default is 60.
;		YSIZE - y size of widget.  Default is 20.
;		NO_BLOCK - 	If set, make widget non-blocking
; CALLS:
;      None.
;
; COMMON BLOCKS:
;      None.
;
; RESTRICTIONS:
;      None.
;
; SIDE EFFECTS:
;      None.
;
; CATEGORY:
;      Utilities, widgets
;
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;      Written September 2, 1994, by Liyun Wang, NASA/GSFC
;		Modified 1-Aug-2000, Kim Tolbert.  Added xsize and ysize keywords.
;		Modified 28-Jan-2001, Kim Tolbert.  Added no_block keyword
;
; VERSION:
;
;-
;
PRO DSP_STRARR_EVENT, event
   wtype = WIDGET_INFO(event.id,/type)
   IF wtype EQ 1 THEN BEGIN
      WIDGET_CONTROL, event.id, get_uvalue = value
      IF value EQ 'QUIT' THEN WIDGET_CONTROL, event.top, /destroy
   ENDIF
END

PRO DSP_STRARR, strings, font=font, title=title, one_copy=one_copy, $
                group=group,  xsize=xsize, ysize=ysize, no_block=no_block

   IF xregistered('dsp_strarr') AND KEYWORD_SET(one_copy) THEN RETURN
   n =  N_ELEMENTS(strings)
   IF n EQ 0 THEN BEGIN
      PRINT, 'DSP_STRARR -- Usage:'
      PRINT, '    DSP_STRARR, string_array [, font=font]
      PRINT, ' '
      RETURN
   ENDIF
   IF datatype(strings) NE 'STR' THEN BEGIN
      PRINT, 'DSP_STRARR -- Input parameter has to be string array'
      PRINT, ' '
      RETURN
   ENDIF

   IF N_ELEMENTS(font) EQ 0 THEN font = 'fixed'
   IF N_ELEMENTS(title)  EQ 0 THEN title = 'Info Window'
   base = WIDGET_BASE(title = title, /column, space = 15, xpad = 5, $
                      ypad = 5)
   row1 = WIDGET_BASE(base, /column, xpad = 80)

   quit = WIDGET_BUTTON(row1, value = 'Dismiss', uvalue = 'QUIT', /frame)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  We will put a limit on number of lines and number of characters in
;  each line that can be shown in the widget. We set line number be
;  be 20 and number of characters in each line be 60. Byound these
;  values, there has to be a scrolling bar to guide the user to see
;  other text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	if keyword_set(xsize) then xsize = (max(strlen(strings))+2) < xsize else xsize = 60

	if not keyword_set(ysize) then ysize = 20

   IF n LE ysize THEN BEGIN
      row2 = WIDGET_LIST(base, value = strings, xsize = xsize, $
                         font = font, ysize = ysize)
   ENDIF ELSE BEGIN
      row2 = WIDGET_LIST(base, value = strings, xsize = xsize, $
                         ysize = ysize, font = font)
   ENDELSE

   WIDGET_CONTROL, base, /realize

   XMANAGER, 'dsp_strarr', base, group_leader = group, no_block=no_block
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'dsp_strarr.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
