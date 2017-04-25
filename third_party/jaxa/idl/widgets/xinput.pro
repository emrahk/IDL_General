;+
; Project     :	SOHO - CDS
;
; Name        : XINPUT
;
; Purpose     : Allow user to input text
;
; Use         : xinput,text
;
; Opt. Inputs : INSTRUCT = instructions for user
;
; Outputs     : TEXT = string response text entered by user
;
; Keywords    :
;              GROUP = group leader of caller
;              MODAL = modal (make caller insensitive)
;              XOFF,YOFF = device (x,y) offsets of XINPUT base relative to caller
;              TFONT = text widget font
;              BFONT = button widget font
;              YSIZE = ysize of input text widget
;              TITLE = title for main base
;              STATUS = 0/1 if CANCELLED/ACCEPTED
;              ACCEPT_ENTER = Set to make ENTER key act as ACCEPT
;              NOBLANK = if set, the user cannot exit without typing something
;
; Category    : Widgets
;
; Written     :	Version 1, Zarro (ARC/GSFC) 23 October 1994
;
; Modified:   : Version 2, Liyun Wang, GSFC/ARC, March 24, 1995
;                  added MAX_LEN keyword
;               Version 3, Liyun Wang, GSFC/ARC, March 29, 1995
;                  Made the widget's width be at least MAX_LEN if
;                  MAX_LEN is passed
;               Version 4, Zarro, GSFC, August 15 1996
;                  Added second XMANAGER call to catch a problem
;                     occuring on SUMER's VMS system.
;                  Limited instruction window to maximum of 25 rows
;                     instead of 45 rows --- LYW
;               Version 5, SVHH, UiO, 22 October 1996
;                  Added /ACCEPT_ENTER keyword.
;               Version 6, DMZ, GSFC, 24 October 1996
;                  Initialize cursor position in text widget prior to
;                  exiting. This helps avoid IDL FONT error.
;               Version 7, DMZ, GSFC, 4 October 1996
;                  Added /NOBLANK
;               Kim, 28 March 2000.  Took /modal off xmanager call, and added group
;		and modal to call to widget_base if using > Version 5.0.
;		Kim, 6 April 2000.  Redid change of 28 March.
;               Modified, 8 April 2000 (Zarro, SM&A/GSFC) - wrapped first
;               call to widget base with call_function in case pre-5 compilers
;               complain about having modal keyword embedded.
;               Modified, 1-March-07, Zarro (ADNET) - force /modal
;               Modified, 15-March-07, Zarro (ADNET) 
;                - moved /modal back to xmanager
;            
;-

pro xinput_event,  event                         ;event driver routine

widget_control,event.top, get_uvalue = unseen
info=get_pointer(unseen)

if (1-is_struct(info)) then return

widget_control, event.id, get_uvalue = uservalue

if not exist(uservalue) then uservalue=''

wtype=widget_info(event.id,/type)

;-- button widgets

if wtype eq  1 then begin
 bname=strtrim(uservalue,2)
 widget_control,info.wtext,get_value=text
 text=trim(text(0))
 widget_control,info.wtext,set_value=text
 if bname eq 'CANCEL' then begin
  info.status=0 & quit=1
 endif else quit=(text ne '') or (info.blank)
 if quit then begin
  xtext_reset,info
  xkill,event.top
 endif
endif

;-- text widgets

if wtype eq 3 then begin
 widget_control,event.id,get_value=text
 text=trim(text(0))
 if (text ne '') or (info.blank) then begin
  info=rep_tag_value(info,text,'text')
  if event.type eq 0 and info.accept then begin
   if event.ch eq 10b then begin
    xtext_reset,info
    xkill,event.top
   endif
  endif
 endif
endif

exit: set_pointer,unseen,info
return & end

;---------------------------------------------------------------------------

pro xinput,text,instruct,group=group,tfont=tfont,bfont=bfont,_extra=extra,$
           max_len=max_len,ysize=ysize,status=status,title=title,$
           accept_enter=accept_enter,noblank=noblank

;-- fonts

mk_dfont,bfont=bfont,tfont=tfont

;-- make widgets

if is_blank(mtitle) then mtitle='XINPUT' else mtitle=title

wbase=widget_base(title=mtitle,/column,group=group)

;-- input text is default value

if n_elements(ysize) eq 0 then ysize=1
if is_string(text) then def_value=text else def_value=''
def_value=strtrim(def_value,2)
text=def_value
if n_elements(max_len) eq 0 then max_len=0
sz=size(def_value)
if sz(0) eq 1 then ysize=(sz(1) < 10)
xsize=max(strlen(text))
if max_len gt 0 then xsize=xsize > max_len

;-- instruction box

if is_string(instruct) AND keyword_set(instruct) then begin
 comment=instruct
 comment=[' ',comment,' ']
 csize = N_ELEMENTS(comment) < 25
 row1=widget_base(wbase,/column)
 wtext = WIDGET_TEXT(row1, xsize=MAX(STRLEN(instruct)) > xsize, $
                     ysize=csize, value=comment, font=tfont, $
                     scroll=csize GT 24)
endif

wtext=widget_text(wbase,xsize=xsize,ysize=ysize,/editable,/all,font=tfont,value=def_value)
row2=widget_base(wbase,/row)
temp1=widget_base(row2,/row)
quit=widget_button(temp1,value='CANCEL',uvalue='CANCEL',font=bfont,/no_rel)
temp2=widget_base(row2,/row)
ok=widget_button(temp2,value='ACCEPT',uvalue='ACCEPT',font=bfont,/no_rel)

;-- realize and position

xrealize,wbase,group=group,/screen,_extra=extra

;-- set text insertion point

if n_elements(def_value) eq 1 then text_sel= strlen(def_value)+1  else $
 text_sel=1

;-- invisible base in which to hold variables common to event handler

make_pointer,unseen
info={text:def_value,status:1,wtext:wtext,accept:keyword_set(accept_enter),$
      blank:1-keyword_set(noblank)}

set_pointer,unseen,info
widget_control,wbase,set_uvalue = unseen

xmanager,'xinput',wbase,/modal

;-- retrieve user text

info=get_pointer(unseen)
free_pointer,unseen

;-- shorten string

if is_struct(info) then status=info.status else status=0

if not status then text=def_value else begin
 text=info.text
 if (max_len gt 0) then begin
  for i=0,n_elements(text)-1 do begin
   if max(strlen(text(i))) gt max_len then text(i)=strmid(text(i),0,max_len)
  endfor
 endif
endelse

if n_elements(text) eq 1 then text=text(0)
xshow,group

return & end

