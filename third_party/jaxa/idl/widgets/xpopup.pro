;+
; Project     : HESSI
;
; Name        : XPOPUP
;
; Purpose     : widget popup window
;
; Category    : utility widgets
;
; Syntax      : IDL> xpopup,instruct
;
; Inputs      : INSTRUCT = string to popup
;
; Keywords    : WBASE = widget ID of main base. If passed in, text
;                       window is updated.
;               XSIZE,YSIZE = text box dimensions (def = 3 x 10 characters)
;               TFONT,BFONT = text and button fonts
;               GROUP = widget ID of group leader
;               TITLE = title for main base
;
; History     : Written 14 Aug 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


pro xpopup_event,event

widget_control, event.id, get_uvalue = uservalue
if ~exist(uservalue) then uservalue=''
uservalue=trim(uservalue)

if uservalue eq 'close' then xkill,event.top

return & end

;--------------------------------------------------------------------------- 

pro xpopup,instruct,wbase=wbase,title=title,group=group,ysize=ysize,$
           tfont=tfont,bfont=bfont,xsize=xsize
                                                              

if is_string(instruct) then mess=instruct else $
 mess='Add your text here'

val=[' ',mess,' ']

;-- update text if a live base

if xalive(wbase) then begin
 wtext=widget_info(wbase,/child)
 if widget_info(wtext,/name) eq 'TEXT' then begin
  widget_control,wtext,set_value=val
  xshow,wbase
  return
 endif
end

;-- create main base 

atitle=''
if is_string(title) then atitle=title

ndim=data_chk(mess,/ndim)
if ndim eq 1 then ny=n_elements(mess) else ny=data_chk(mess,/ny)
nx=max(strlen(mess))
if ~is_number(ysize) then ysize=5 > ny < 20
if ~is_number(xsize) then xsize=10 > nx < 50
scroll= (ny gt ysize) or (nx gt xsize)

wbase=widget_mbase(title=atitle,/column,group=group)

wtext=widget_text(wbase,value=val,ysize=ysize,font=tfont,xsize=xsize,$
                  scroll=scroll)

row=widget_base(wbase,/row,/align_center) 
closeb=widget_button(row,uvalue='close',/frame,value='Close',font=bfont)

;-- realize & manage

xrealize,wbase,group=group,/center

xmanager,'xpopup',wbase,/no_block

return & end

