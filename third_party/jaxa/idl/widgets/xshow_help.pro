;---------------------------------------------------------------------------
; Document name: xshow_help.pro
; Created by:    Liyun Wang, GSFC/ARC, May 12, 1995
;
; Last Modified: Fri May 12 15:05:42 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO xshow_help, help_stc, topic, tbase=tbase, font=font, group=group
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       XSHOW_HELP
;
; PURPOSE: 
;       Show help text in a text widget based on its topic
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       xshow_help, help_stc, topic [, tbase]
;
; INPUTS:
;       HELP_STC - Help structure created by MK_HELP_STC
;       TOPIC    - A string scalar, the tag name in HELP_STC whose
;                  value is the corresponding help text
;     
; OPTIONAL INPUTS: 
;       tbase    - ID of the text widget on which the help text appears
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       XTEXT
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
;       Written May 12, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 12, 1995
;
; VERSION:
;       Version 1, May 12, 1995
;-
;
   ON_ERROR, 2
   IF datatype(help_stc) NE 'STC' OR datatype(topic) NE 'STR' THEN BEGIN
      MESSAGE, 'Invalid input parameter type.',/cont
      RETURN
   ENDIF
   topics = TAG_NAMES(help_stc)
   IF grep(topic, topics, /exact) EQ '' THEN BEGIN
      text = 'Sorry, but no help information on topic '+topic+$
         ' is available.'
   ENDIF ELSE BEGIN
      IF execute('text = help_stc.'+topic) NE 1 THEN $
         text = 'Sorry, but no help information on topic '+topic+$
         ' is available.'
   ENDELSE
   xtext, text, title = 'Help Topic: '+topic, wbase = tbase, /just_reg, $
      group = group, space = 1, font=font

END

;---------------------------------------------------------------------------
; End of 'xshow_help.pro'.
;---------------------------------------------------------------------------
