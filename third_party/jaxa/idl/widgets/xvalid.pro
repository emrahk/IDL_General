;---------------------------------------------------------------------------
; Document name: xvalid.pro
; Created by:    Liyun Wang, GSFC/ARC, January 4, 1996
;
; Last Modified: Fri Jan  5 10:04:20 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION xvalid, name, noshow=noshow, id=id
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XVALID()
;
; PURPOSE:
;       Determine if a named widget is registered with XMANAGER
;
; CATEGORY:
;       Utility
;
; EXPLANATION:
;       This is a widget utility program similar to xregistered (it is
;       actually modified from xregistered). It does one more thing
;       than xregistered: it returns the ID of the named widget as an
;       optional output keyword parameter. XREGISTERED should have had
;       this ID keyword (suggestion has been sent to RSI by LYW).
;
; SYNTAX:
;       Result = xvalid(name)
;
; EXAMPLES:
;       IF xvalid('image_tool', id=parent) THEN ...
;
; INPUTS:
;       NAME - String, name of the widget program
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - Integer with a value of 1 or 0, indicating if the
;                named widget is registered with XMANAGER
;
; OPTIONAL OUTPUTS:
;       ID     - ID of the top level widget which is registered with
;                XMANAGER. If the named widget is not registered with
;                XMANAGER, a -1 will be returned.
;
; KEYWORDS:
;	NOSHOW - If the widget in question is registered, it is brought
;		 to the front of all the other windows by default.  Set this
;		 keyword to keep the widget from being brought to the front.
;
; COMMON:
;       MANAGED (defined in XMANAGER and XREGISTERED)
;
; RESTRICTIONS:
;       XMANAGER and/or XREGISTERED must be called prior to calling
;       this routine to establish the MANAGED common block.
;
; SIDE EFFECTS:
;       The named widget is brought to foreground id NOSHOW keyword is
;       not set.
;
; HISTORY:
;       Version 1, January 4, 1996, Liyun Wang, GSFC/ARC. Modified
;          from XREGISTERED
;       Version 2, August 14, 1996, Zarro, GSFC -- added XMANAGER call
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-

   if datatype(name) ne 'STR' then return,0

;-- check XMANAGER common 

   xmanager_com,ids,names,nummanaged

   answer = 0
   id = -1L

   IF KEYWORD_SET(nummanaged) THEN BEGIN
      validids = WHERE(ids NE 0, answer)
      IF (answer EQ 0) THEN RETURN, answer
      registered = WHERE(names(validids) EQ name, answer)
      IF (answer EQ 0) THEN RETURN, answer
      registered = validids(registered)
   ENDIF ELSE RETURN, answer

   id = ids(registered(0))
   validids = WIDGET_INFO(ids(registered), /valid)
   IF ((validids(0) EQ 1) AND (NOT KEYWORD_SET(noshow))) THEN $
      WIDGET_CONTROL, id, /show

   RETURN, answer

END

;---------------------------------------------------------------------------
; End of 'xvalid.pro'.
;---------------------------------------------------------------------------
