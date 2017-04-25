;---------------------------------------------------------------------------
; Document name: xmessage.pro
; Created by:    Liyun Wang, NASA/GSFC, August 19, 1996
;
; Last Modified: Tue Aug 20 10:15:43 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO
;
; NAME:
;       XMESSAGE
;
; PURPOSE:
;       Make a pop-up widget window to display a brief message
;
; CATEGORY:
;       Utility, widget
;
; EXPLANATION:
;
; SYNTAX:
;       xmessage, msg
;
; INPUTS:
;       MSG - A string array or scalar containing the message
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
;       WBASE       - A named variable containing base ID of the pop-up widget
;       TITLE       - A string scalar variable; title of the pop-up widget
;       REGISTER    - Set this keyword to get the pop-up widget
;                     registered with XMANAGER. If this keyword is not
;                     set, XMANAGER is NOT called, and it's caller's
;                     responsibility to remove the pop-up widget
;       GROUP       - group leader of text widget parent; meaningful
;                     only when REGISTER keyword is set
;       FONT        - font for text widget
;       XOFF,YOFF   - pixel offset relative to caller
;       WAIT        - secs to wait before killing widget
;       XSIZE,YSIZE - X-Y sizes for text widget
;       SPACE       - number of lines to space text
;       APPEND      - append to existing text
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       The widget window is left on the screen unless it is killed by
;       the caller or by killing the parent widget if REGISTER and
;       GROUP keywords are set.  
;
; HISTORY:
;       Version 1, August 19, 1996, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
PRO xmessage_event, event
END

PRO xmessage, array, wbase=wbase, title=title, register=register, $
              font=font, append=append, WAIT=WAIT, group=group, $
              xsize=xsize, ysize=ysize, xoff=xoff, yoff=yoff, $
              space=space

   ON_ERROR, 1

   IF (datatype(array) NE 'STR') THEN BEGIN
      MESSAGE, 'input must be a string', /cont
      RETURN
   ENDIF
   IF NOT HAVE_WIDGETS() THEN BEGIN
      MESSAGE, 'widgets unavailable', /cont
      RETURN
   ENDIF

   IF xalive(wbase) THEN update = 1 ELSE update = 0
   append = KEYWORD_SET(append)

   IF N_ELEMENTS(space) EQ 0 THEN space = 2

   IF N_ELEMENTS(title) NE 0 THEN wtitle = title ELSE BEGIN
;---------------------------------------------------------------------------
;     Figure out caller's name
;---------------------------------------------------------------------------
      HELP, calls=calls
      IF N_ELEMENTS(calls) GT 1 THEN BEGIN
         caller = calls(1)
         i = STRPOS(caller, ' ')
         caller = STRMID(caller, 0, i)
      ENDIF ELSE caller = 'XMESSAGE'
      wtitle = STRTRIM(caller,2)
   ENDELSE

   IF (NOT append) AND (space GT 0) THEN BEGIN
      buff = REPLICATE(' ', space) & text=[buff, detabify(array), buff]
   ENDIF ELSE text = detabify(array)

   lfont = '-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1'
   lfont = (get_dfont(lfont))(0)

   IF datatype(font) EQ 'STR' THEN tfont = (get_dfont(font))(0) ELSE BEGIN
      tfont = '8x13bold'
      tfont = (get_dfont(tfont))(0)
   ENDELSE

   IF NOT update THEN BEGIN
      scroll = (N_ELEMENTS(text) GT 50 OR MAX(STRLEN(text)) GT 80)
      IF N_ELEMENTS(ysize) EQ 0 THEN ysize = N_ELEMENTS(text) < 50
      IF N_ELEMENTS(xsize) EQ 0 THEN xsize = MAX(STRLEN(text)) < 80
      wbase = WIDGET_BASE(title=wtitle, /column)
      wtext = WIDGET_TEXT(wbase, /frame, value=text, uvalue='text', $
                          font=tfont, scroll=scroll, $
                          ysize=ysize, xsize=xsize)

;---------------------------------------------------------------------------
;     determine placement
;---------------------------------------------------------------------------
      IF (N_ELEMENTS(xoff) EQ 0) AND (N_ELEMENTS(yoff) EQ 0) THEN BEGIN
         offsets = get_cent_off(wbase, group, valid=valid)
         IF valid THEN BEGIN
            xoff = offsets(0) & yoff=offsets(1)
         ENDIF
      ENDIF

      realized = WIDGET_INFO(wbase, /realized)

      IF (N_ELEMENTS(xoff) EQ 0) AND (N_ELEMENTS(yoff) EQ 0) THEN $
         WIDGET_CONTROL, wbase, /realize ELSE $
         WIDGET_CONTROL, wbase, /realize, $
         tlb_set_xoff=xoff, tlb_set_yoff=yoff, /map, /show

   ENDIF ELSE BEGIN
      wtext = WIDGET_INFO(wbase, /child)
      temp = WIDGET_INFO(wbase, /sibling)
      WIDGET_CONTROL, wtext, set_value=text, append=append
      WIDGET_CONTROL, wbase, tlb_set_title=wtitle
      xshow, wbase
   ENDELSE

   IF KEYWORD_SET(register) THEN $
      xmanager, 'xmessage', wbase, group=group, /just_reg

   IF (N_ELEMENTS(wait) GT 0) THEN BEGIN
      WAIT, wait
      xkill, wbase
   ENDIF

   RETURN

END

;---------------------------------------------------------------------------
; End of 'xmessage.pro'.
;---------------------------------------------------------------------------
