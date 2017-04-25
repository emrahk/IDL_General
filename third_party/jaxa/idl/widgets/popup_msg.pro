;---------------------------------------------------------------------------
; Document name: popup_msg.pro
; Created by:    Liyun Wang, GSFC/ARC, August 19, 1994
;
; Last Modified: Fri Jan 26 09:18:46 1996 (lwang@orpheus.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO popup_msg_event, event
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; pro popup_msg_event, event
;
; The event handler for PRO POP_MSG
;  calls to  :  none
;  common    :  none
;
;  The only purpose of the routine is to kill the message window,
;     created by PRO POP_MSG, AFTER the user reads the message.
;     The user clicks the "Dismiss" button to get here.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
   WIDGET_CONTROL, event.top, /destroy ; This widget is modaled so its the
                                ;  only widget the user is able to kill
   RETURN
END

;===========================================================================

PRO popup_msg, text, title=title, group=group, modal=modal, font=font, $
               multiple=multiple, left_justify=left_justify,$
               right=right, space=space, verbatim=verbatim
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       POPUP_MSG
;
; PURPOSE:
;       Display a message from a popup text widget.
;
; Explanation:
;     This routine creates a message window that informs the user with a
;     message and requires the user to read the message and to dismiss the
;     window before control will return to the calling procedure.
;
; Calling sequence:
;     popup_msg, message [, title=title, group=group, font=font,$
;                           multiple=multiple, verbatim=verbatim]
;
;  calls to  :  xregistered('pop_msg'), xmanager,'popup_msg'
;
;  common    :  none
;
; INPUT
;     message:  string or string vector containing a message
;		that will be displayed on the screen for the
;		user to read.
;		(multi-line messages are aesthetically better)
;
; Optional inputs:
;     title:    Optional title of the message window
;     group:    ID number of the widget which acts as a group leader
;     modal:    Make the calling widget inactive if set
;     space:    Number of lines to space text; default to 4
;
; Keywords:
;     left_justify - Left justify text (default is to centre it)
;     right        - Right justify text
;     verbatim     - Don't do any adjustment of text layout
;
; OUTPUT
;     none
;
; MODIFICATION HISTORY
;	JAN 1993        -- Elaine Einfalt (HSTX)
;       August 19, 1994 -- Liyun Wang (ARC)
;       August 31, 1994 -- Liyun Wang (ARC), added GROUP keyword
;       Feb 16 1995     -- C D Pike, RAL.  Added FONT and MULTIPLE keywords.
;       Feb 20 1995     -- Added crude left justify option.
;       April 27, 1995  -- Liyun Wang, GSFC/ARC, Added keywords SPACE, RIGHT
;       April 30, 1995  -- C D Pike, RAL, Added VERBATIM keyword.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-
;
;  Allow multiple copies if explicitly requested.
;
   IF NOT KEYWORD_SET(multiple) THEN BEGIN
      IF xregistered('popup_msg') THEN RETURN
   ENDIF

   IF N_ELEMENTS(font) EQ 0 THEN BEGIN
      ffont = get_dfont('-*-courier-*-r-normal-*-16-*-*-*-*-*-*-*')
      IF ffont(0) EQ '' THEN ffont='fixed'
      font = ffont(0)
   ENDIF

   bfont="-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1"
   bfont=(get_dfont(bfont))(0)

   IF (N_ELEMENTS(title) EQ 0) THEN title = 'Message'
   IF N_ELEMENTS(text) EQ 0 THEN BEGIN
      text = ['Usage:','    popup_msg, text [,title=title]']
      title = 'POPUP_MSG'
   ENDIF

   IF N_ELEMENTS(space) EQ 0 THEN space=4
   IF space GT 0 THEN BEGIN
      buff=REPLICATE('', space)
      text=[buff,text,buff]
   ENDIF

   num_line = N_ELEMENTS(text)

   base = WIDGET_BASE(title=title, /column, space=20, xpad=10, ypad = 10)

   tmp_bs = WIDGET_BASE(base, /column, xpad = 50)
   respond = WIDGET_BUTTON(tmp_bs, value= 'Dismiss', /frame, font = bfont)

   text_part = WIDGET_BASE(base, /column, /frame) ; write message

   if not keyword_set(verbatim) then text = justify(text, just='|')

   IF KEYWORD_SET(left_justify) THEN text = justify(text, just='<')
   IF KEYWORD_SET(right) THEN text = justify(text, just='>')
   xsize = (MAX(STRLEN(text)) < 80)
   ysize = (N_ELEMENTS(text) < 50)
   info = WIDGET_TEXT(text_part, value = text, font=font, $
                      xsize = xsize, ysize = ysize)

;---------------------------------------------------------------------------
;  Position the widget in the center of the caller widget if GROUP is set
;---------------------------------------------------------------------------
;    IF N_ELEMENTS(group) NE 0 THEN BEGIN
;       aa = WIDGET_INFO(LONG(group),/valid)
;       IF aa THEN BEGIN
;          WIDGET_CONTROL,base,/realize,tlb_get_size=wsize,map=0
;          WIDGET_CONTROL,group,tlb_get_offset=goff,tlb_get_size=gsize
;          xxsize=((gsize(0)-wsize(0))/2) > 0.
;          yysize=((gsize(1)-wsize(1))/2) > 0.
;          xoff=goff(0)+xxsize
;          yoff=goff(1)+yysize
;       ENDIF
;    ENDIF

   IF (N_ELEMENTS(xoff) EQ 0) AND (N_ELEMENTS(yoff) EQ 0) THEN $
      WIDGET_CONTROL, base, /realize, /map $
   ELSE $
      WIDGET_CONTROL,base, /realize, tlb_set_xoff=xoff, tlb_set_yoff=yoff, /map

   XMANAGER,'popup_msg', base, group = group, modal = KEYWORD_SET(modal)

   RETURN
END

;---------------------------------------------------------------------------
; End of 'popup_msg.pro'.
;---------------------------------------------------------------------------
