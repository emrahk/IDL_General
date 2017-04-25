;+
; Project     :	SOHO/CDS
;
; Name        : XACK
;
; Purpose     : Make user acknowledge an action
;
; Use         : xack
;
; Inputs :    : ARRAY = message to user
;
; Outputs     : RESULT = result of DIALOG_MESSAGE
;
; Keywords    : 
;               GROUP = widget ID of calling widget.
;               SPACE = lines of border space surrounding message text.
;               INSTRUCT = optional instruction to supersede "Acknowlege" 
;               TITLE = Title of the pop-up widget
;               WARN  = set to call IDL warning function WIDGET_MESSAGE
;               TURN_OFF = set to show suppress future message button
;               BACK = set to unsuppress turned-off message
;               SINSTRUCT = suppression instructions
;;
; Written     :	Version 1, Zarro (ARC/GSFC) 12 October 1994
;
; Modification: Version 2, April 19, 1996, Liyun Wang, GSFC/ARC
;                  Added TITLE keyword
;               Version 3, Sept 19, 2000, Zarro (EIT/GSFC)
;                  Updated for IDL 5
;               Version 4, May 8, 2002, Zarro (L-3Com/GSFC)
;                  Added call to DIALOG_MESSAGE
;               Modified, 30 May 2006, Zarro (L-3Com/GSFC)
;                  Added version 6 check
;               Modified, 28 Feb 2007, Zarro (ADNET)
;                - moved group & modal keywords from xmanager to widget_base
;               Modified, 15-March-07, Zarro (ADNET)
;                - moved /modal back to xmanager
;               Modified, 3-Aug-07, Zarro (ADNET)
;                - fixed /suppress bug
;
;-

pro xack_event,  event                         ;event driver routine

widget_control, event.id, get_uvalue = uservalue

if not exist(uservalue) then uservalue=''
uservalue=trim(uservalue)

;-- force dialog box to foreground

if (uservalue eq 'suppress') then begin
 widget_control,event.top,get_uvalue=smess
 s=suppress_message(smess,/add)
endif

if uservalue eq 'close' then xkill,event.top

return & end

;--------------------------------------------------------------------------- 

pro xack,array,result,group=group,space=space,$
         instruct=instruct,$
         title=title,warn=warn,sinstruct=sinstruct,$
         turn_off=turn_off,back=back,suppress=suppress,_extra=extra


if is_blank(array) then return

if ~allow_windows() then begin
 message,arr2str(array,delim=' '),/cont
 return
endif

remove=keyword_set(back)

;-- check if this message is being suppressed

suppress=keyword_set(turn_off) or keyword_set(suppress)
if suppress_message(array,remove=remove) then begin
 dprint,'% XACK: message suppressed'
 return
endif

;-- make widgets

mk_dfont,bfont=bfont,tfont=tfont

if is_blank(title) then title = ' '
wbase=widget_base(title=title,/column,group=group)

if is_string(instruct) then mess=instruct else mess='OK'

if n_elements(space) eq 0 then begin
 sy=(n_elements(array) < 5)
 blank=replicate('',(sy/2 > 3))
endif else begin
 if space gt 0 then blank=replicate('',space)
endelse
if n_elements(blank) gt 0 then sarr=[blank,array,blank] else sarr=array
narr=n_elements(sarr)
tysize=narr < 20
wtext=widget_text(wbase,xsize=max(strlen(array)) > strlen(mess),$
                   ysize=tysize,value=sarr,font=tfont,scroll=narr gt 20)
 
row2=widget_base(wbase,/column,/align_center)
c1=widget_base(row2,/row)
ackb=widget_button(c1,uvalue='close',/no_release,font=bfont,$
                   /frame,value=mess)

if suppress then begin
 row3=widget_base(wbase,/column)
 c2=widget_base(row3,/row)
 if is_string(sinstruct) then supp_mess=sinstruct else $
  supp_mess='Do not show this message again'
 xmenu,supp_mess,c2,/column,/nonexclusive,uvalue='suppress',font=tfont
endif

;-- realize 

widget_control,wbase,set_uvalue=array

xrealize,wbase,group=group,_extra=extra,/screen

xmanager,'xack',wbase,/modal

return & end

