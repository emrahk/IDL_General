;+
; Project     : SOHO - CDS
;
; Name        : FLASH_MSG
;
; Purpose     : Flashes an information message in a text widget.
;
; Explanation : Write a text message to the specified widget, and alternates
;               it with setting it blank in order to simulate a flashing
;               message.
;
; Use         : IDL> flash_msg, widget_id, text [, other_keywords]
;
; Inputs      : widget_id  - the id of the text widget
;               text       - the message to be flashed
;
; Opt. Inputs : None.
;
; Outputs     : None.
;
; Opt. Outputs: None.
;
; Keywords    : NUM    -- Number of flashing times; default is 4 times.
;               NOBEEP -- Set this keyword to suppress the beep
;               RATE   -- Flashing rate in seconds; default: 0.25 sec.
;               APPEND -- Appends to widget text rather than overwriting
;
; Calls       : BELL
;
; Restrictions: Widget must be already set up.
;
; Side effects: Can be annoying if called frequently with beeping!
;
; Category    : Utilities, Help
;
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 2-Jul-1993
;
; Modified    : Liyun Wang, GSFC/ARC, August 25, 1994
;                  Added optional keyword NUM to control number of flashing
;                  times and NOBEEP to suppress the beep.
;
;               Add append keyword,  CDP, 14-Oct-94
;               Fix working of /append mode, CDP, 19-Oct-94
;               Limit rewrite of old text in /append mode to 20 lines.
;                                            CDP, 9-Jan-95
;
; Version     : Version 5, 9-Jan-95
;-

PRO flash_msg, widget_id, text, num=num, nobeep=nobeep, rate=rate, $
               append=append

;
;  insist on correct number of parameters
;
   IF N_PARAMS() LT 2 THEN BEGIN
      bell
      PRINT, 'FLASH_MSG --  Not enough parameters. '
      PRINT, '              Syntax: FLASH_MSG, widget_id, text, [ keywords]'
      PRINT, ' '
      RETURN
   ENDIF

   IF N_ELEMENTS(num) EQ 0 THEN num = 4
   IF N_ELEMENTS(rate) EQ 0 THEN rate = 0.25

;
;  if want to append, save whats already there
;
   if keyword_set(append) then widget_control, widget_id, get_val=old_text

;
;  audio/visual message
;
   IF N_ELEMENTS(nobeep) EQ 0 THEN bell

   FOR i= 0, num-1 DO BEGIN
      WIDGET_CONTROL, widget_id, set_value=text
      wait, rate
      WIDGET_CONTROL, widget_id, set_value=' '
      wait, rate
   ENDFOR
   if keyword_set(append) then begin
      n = n_elements(old_text) 
      if n gt 0 then begin
         for i=(0 > (n-20)),n-1  do begin
            if i eq 0 then begin
               widget_control, widget_id, set_value=old_text(i)
            endif else begin
               widget_control, widget_id, set_value=old_text(i), /append
            endelse
         endfor
         widget_control, widget_id, set_value=text, /append
      endif
   endif else begin
      widget_control, widget_id, set_value=text
   endelse
END
