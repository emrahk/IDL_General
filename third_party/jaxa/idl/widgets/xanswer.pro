;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XANSWER()
;
; PURPOSE:
;       Popup widget to get a Yes/No answer for a given question
;
; CALLING SEQUENCE:
;       Result = xanswer(question [,/str])
;
; INPUTS:
;       QUESTION - A string scalar or vector for the question presented to the
;                  user
;
; OPTIONAL INPUTS:
;       FLASH - Make the question flash for number of FLASH times
;       RATE  - Flashing rate in seconds; default: 0.25 sec.
;
; OUTPUTS:
;       RESULT - A numerical value of 1 or 0, or a string scalar with a value
;                'Y' or 'N' if the keyword STR is set
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       STR        - Set this keyword to make string type return
;       BEEP       - Make a beep if set
;       JUSTIFY    - justify string (| for center, < for left, > for right)
;       RIGHT      - Right justify the question
;       SPACE      - Number of line to space text; default to 3
;       FONT       - Font for text widget
;       SUPPRESS   - set to show suppress future message button
;       BACK       - set to unsuppress turned-off message
;       INSTRUCT   - additional instructions
;       CHECK_INSTRUCT - set to check INSTRUCT instead of QUESTION
;       DEFAULT    - default answer
;       MESSAGE_SUPP - message to suppress
;       SKIPPER - returns 1 if user previously suppressed message 
;
; CATEGORY:
;       Utility, widget
;
; PREVIOUS HISTORY:
;       Written March 8, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, March 8, 1995
;       Version 2, Liyun Wang, GSFC/ARC, May 2, 1995
;          Added INSTRUCT keyword
;       Version 3, Liyun Wang, GSFC/ARC, May 2, 1995
;          Got rid of common block
;       Version 4, November 15, 1995, Liyun Wang, GSFC/ARC
;          Changed exclusive button to regular button
;          Added Xresource option
;       Version 5, February 15, 1996, Liyun Wang, GSFC/ARC
;          Xresource option disabled for IDL version 3.5 and earlier
;       Version 6, June 19, 1996, Liyun Wang, GSFC/ARC
;          Added a timer event to prevent the widget from hiding behind
;             other windows
;       Version 7, August 12, 1996, Zarro, GSFC
;          Added check for valid handle value
;       Version 8, September 12, 1996, Zarro, GSFC
;          Added suppression message
;	July 5, 2000, Kim Tolbert, Set input focus in widget to default answer
;       Oct 22, 2002, Zarro (EER/GSFC) - added SKIPPED keyword
;       Modified, 28 Feb 2007, Zarro (ADNET)
;        - moved group & modal keywords from xmanager to widget_base
;       Modified, 15-March-07, Zarro (ADNET)
;        - moved /modal back to xmanager
;-

 pro xanswer_event, event
 widget_control, event.top, get_uvalue=unseen
 info=get_pointer(unseen,/no_copy)
 if datatype(info) ne 'STC' then return
 widget_control, event.id, get_uvalue=opt
 case (opt) of

  'suppress': s=suppress_message(info.smess,/add)

   'yes': begin
    info.answer = 1
    xkill,event.top
   end

   'no': begin
    info.answer = 0
    xkill,event.top
   end

   else: do_nothing=1
 endcase

 set_pointer,unseen,info,/no_copy
 return & end

;-----------------------------------------------------------------------

  function xanswer, question, str=str, flash=flash, beep=beep, rate=rate, $
                  space=space, font=font,message_supp=message_supp, $
                  title=title, group=group,default=default,skipped=skipped,$
                  instruct=instruct,suppress=suppress,back=back,$
                  check_instruct=check_instruct,justify_it=justify_it,_extra=extra

   if datatype(question) ne 'STR' then question = 'Do you wish to continue?'
   if datatype(instruct) ne 'STR' then instruct='Choice ? '

;-- was this question suppressed?

   skipped=0b
   if not exist(default) then default=1
   if keyword_set(check_instruct) then smess=instruct else smess=question
   if suppress_message(smess,remove=back) then begin
    skipped=1b & answer=default & goto,done
   endif

   IF N_ELEMENTS(rate) EQ 0 THEN rate = 0.25
   IF N_ELEMENTS(space) EQ 0 THEN space = 3
   IF N_ELEMENTS(title) EQ 0 THEN title = ' '
   IF space GT 0 THEN buff = REPLICATE('',space)

   if datatype(font) eq 'STR' then tfont=font
   mk_dfont,bfont=bfont,tfont=tfont

   base = WIDGET_BASE(title=title, /column,group=group)
   base1 = WIDGET_BASE(base, /column, uvalue='push')

   IF space GT 0 THEN text = [buff,question,buff] ELSE text = question
   xsize = (MAX(STRLEN(text)) < 80)
   ysize = (N_ELEMENTS(text) < 50)

   IF datatype(justify_it) eq 'STR' THEN text = justify(text, just=justify_it)
   IF KEYWORD_SET(right) THEN text = justify(text, just='>')

   wtext = WIDGET_TEXT(base1, value=text, /frame, font=tfont, $
                       xsize=xsize, ysize=ysize)

   IF N_ELEMENTS(instruct) EQ 0 THEN BEGIN
      tmp = WIDGET_BASE(base1, /row, xpad=30, space=15)
      IF !version.release LT '3.6' THEN BEGIN
         answer1 = WIDGET_BUTTON(tmp, value='Yes', uvalue='yes', font=bfont, $
                              /no_release)
         answer0 = WIDGET_BUTTON(tmp, value='No', uvalue='no', font=bfont, $
                              /no_release)
      ENDIF ELSE BEGIN
         answer1 = WIDGET_BUTTON(tmp, value='Yes', uvalue='yes', font=bfont, $
                              resource='YesButton', /no_release)
         answer0 = WIDGET_BUTTON(tmp, value='No', uvalue='no', font=bfont, $
                              resource='NoButton', /no_release)
      ENDELSE
   ENDIF ELSE BEGIN
      temp = WIDGET_BASE(base1, /row)
      inst = WIDGET_LABEL(temp, value=instruct, font=tfont)
      tmp = WIDGET_BASE(temp, /row, space=10)

      IF !version.release LT '3.6' THEN BEGIN
         answer1 = WIDGET_BUTTON(tmp, value='Yes', uvalue='yes', font=bfont)
         answer0 = WIDGET_BUTTON(tmp, value='No', uvalue='no', font=bfont)
      ENDIF ELSE BEGIN
         answer1 = WIDGET_BUTTON(tmp, value='Yes', uvalue='yes', font=bfont, $
                              resource='YesButton')
         answer0 = WIDGET_BUTTON(tmp, value='No', uvalue='no', font=bfont, $
                              resource='NoButton')
      ENDELSE
   ENDELSE

;-- suppress question?

   if keyword_set(suppress) then begin
    row=widget_base(base1,/column)
    c1=widget_base(row,/row)
    if datatype(message_supp) ne 'STR' then $
     supp_mess='Do not ask this question again' else $
      supp_mess=message_supp
    xmenu,supp_mess,c1,/column,/nonexclusive,uvalue='suppress',font=tfont
   endif

;-- realize

   xrealize,base,group=group,_extra=extra,/screen

   IF KEYWORD_SET(beep) THEN bell
   IF N_ELEMENTS(flash) NE 0 AND datatype(flash) EQ 'INT' THEN BEGIN
      FOR i=0, flash-1 DO BEGIN
         WIDGET_CONTROL, wtext, set_value=''
         WAIT, rate
         WIDGET_CONTROL, wtext, set_value=text
         WAIT, rate
      ENDFOR
   ENDIF

    if not exist(default) then default=1
	if default eq 1 then begin
		if xalive(answer1) then widget_control, answer1, /input_focus
	endif else begin
		if xalive(answer0) then  widget_control, answer0, /input_focus
	endelse

;-- save event handler variables in pointer

   make_pointer,unseen
   answer=-1
   info={answer:answer,smess:smess}
   set_pointer,unseen,info,/no_copy
   widget_control, base, set_uvalue=unseen
   child=widget_info(base,/child)
   xmanager, 'xanswer', base,/modal
   info=get_pointer(unseen,/no_copy)
   free_pointer,unseen
   if datatype(info) eq 'STC' then answer=info.answer else answer=0

done:
   if keyword_set(str) then begin
    if answer then return, 'y' else return, 'n'
   endif else begin
    if answer then return, 1b else return, 0b
   endelse

   end

