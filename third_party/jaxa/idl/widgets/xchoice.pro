;+
; Project     : SOHO - CDS
;
; Name        : XCHOICE
;
; Purpose     : present a choice 
;
; Syntax      : IDL> value=xchoice(text,options)
;
; Inputs      : TEXT    = info text
;               OPTIONS = array of options, e.g. ['QUIT','CONTINUE']
;
; Outputs     : VALUE = index of chosen option (-1 if no selection)
;
; Keywords    :
;              GROUP = group leader of caller
;              XOFF,YOFF = device (x,y) offsets of XINPUT base relative to caller
;              TFONT = text widget font 
;              BFONT = button widget font
;              ROW   = layout option buttons into rows
;              BUFF_SIZE = buffer space size around text [def = 3]
;
; History     : Version 1,  1-April-1996,  D.M. Zarro.  Written
;               Modified, 28 Feb 2007, Zarro (ADNET) 
;                - moved group & modal keywords from xmanager to widget_base
;               Modified, 15-March-07, Zarro (ADNET)
;                - moved /modal back to xmanager
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro xchoice_event,event 

widget_control,event.top,get_uvalue = unseen
info=get_pointer(unseen,/no_copy)
if datatype(info) ne 'STC' then return
widget_control,event.id,get_uvalue = uvalue
if not exist(uvalue) then uvalue=''

info.sel=intarr(n_elements(info.wb))
clook=where(event.id eq info.wb,cnt)
if cnt eq 1 then info.sel(clook)=1
xkill,event.top

set_pointer,unseen,info,/no_copy

return & end

;--------------------------------------------------------------------------- 

function xchoice,text,options,group=group,tfont=tfont,bfont=bfont,$
         row=row,buff_size=buff_size,flash=flash,_extra=extra

;-- input check

if datatype(text) ne 'STR' then begin
 message,'enter input warning text',/cont
 return,-1
endif

if datatype(options) ne 'STR' then begin
 message,'enter user options array',/cont
 return,-1
endif

if not have_widgets() then begin
 message,'widgets unavailable',/cont
 return,-1
endif

;-- fonts

mk_dfont,bfont=bfont,tfont=tfont

;-- make widgets

wbase=widget_base(title='XCHOICE',/column,group=group)
if not exist(buff_size) then buff_size=1
buff=strarr(buff_size)
value=[buff,text,buff]
wtext=widget_text(wbase,value=value,font=tfont,ysize=n_elements(value))

;-- options

nb=n_elements(options)
if keyword_set(row) then row1=widget_base(wbase,/row) else row1=wbase

wb=lonarr(nb)
sel=intarr(nb)

for i=0,nb-1 do wb(i)=widget_button(row1,value=options(i),font=bfont,/no_rel)

;-- realize bases

xrealize,wbase,group=group,_extra=extra,/screen

if exist(flash) then begin
 for i=0,flash-1 do begin
  widget_control,wtext,set_value=''
  wait,1
  widget_control,wtext,set_value=value
 endfor
endif

;-- save info needed in event handler 

info={wb:wb,sel:sel}
make_pointer,unseen
set_pointer,unseen,info,/no_copy
widget_control,wbase,set_uvalue = unseen

xmanager,'xchoice',wbase,/modal

;-- retrieve user choice

info=get_pointer(unseen,/no_copy)
free_pointer,unseen

value=-1
if datatype(info) eq 'STC' then begin
 sel=info.sel
 slook=where(sel eq 1,cnt)
 if cnt gt 0 then value=slook(0)
endif

xshow,group

return,value & end

