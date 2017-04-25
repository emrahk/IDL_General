;+
; Project     : HESSI
;
; Name        : CHAN_DEFINE
;
; Purpose     : Define a channel selection object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('chan')
;
; History     : Written 10 March 2002, D. Zarro, L-3Com/GSFC
;               Modified 15 Nov 2006, Zarro (ADNET/GSFC)
;                - removed device-dependent font assignments which
;                  caused some systems to crash
;               Modified, 4-Mar-2007, Zarro (ADNET)
;                - removed ADD_METHOD
;               Modified 4-Aug-2009, Kim.
;                - added _extra to cleanup args
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init

function chan::init

return,1

end

;-----------------------------------------------------------------------------

pro chan::cleanup, _extra=extra

return & end

;----------------------------------------------------------------------------

pro chan::set,dim1_sel=dim1_sel

if is_number(dim1_sel) then self.dim1_sel=   0b > dim1_sel < 1b

return & end

;-----------------------------------------------------------------------------

pro chan::all,event

widget_control,event.top,get_uvalue=self

wchan=self->getprop(/wchan)

all=event.select
self->set,all=all
if all then begin
 nchans=n_elements(self->getprop(/dim1_ids))
 widget_control,wchan,set_list_select=indgen(nchans)
endif else widget_control,wchan,set_list_select=-1

return
end

;----------------------------------------------------------------------
pro chan::cancel,event

widget_control,event.top,get_uvalue=self
self.cancel=1b
xkill,event.top

return & end
;-----------------------------------------------------------------------

pro chan::accept,event

widget_control,event.top,get_uvalue=self
wchan=self->getprop(/wchan)
wtext=self->getprop(/wtext)

s=widget_info(wchan,/list_select)
if s[0] eq -1 then begin
 widget_control,wtext,set_value='Select at least one channel.',/append
 return
endif else self->set,dim1_use=s

self.cancel=0b
xkill,event.top 

return
end

;----------------------------------------------------------------------------

pro chan::options,group=group,title=title,cancel=cancel

cancel=0b
if self->getprop(/plot_type) eq 'specplot' then return
if not self->getprop(/dim1_sel) then return
chan=self->getprop(/dim1_ids)
if not is_string(chan) then return
if not allow_windows() then return

lfont=self->getprop(/lfont)
bfont=self->getprop(/bfont)

wbase = widget_mbase (group=group,/column,title=' ',/modal)

row1=widget_base(wbase,/column,/frame)

if is_string(title) then begin
 label=widget_label(row1,value=' ')
 label=widget_label(row1,value=title,font=lfont)
 label=widget_label(row1,value=' ')
endif

self->wchan,row1

;-- message box

cbase=widget_base(row1,/row,/align_center)
self.wtext=widget_text(cbase,ysize=4,xsize=50,font=lfont)

row2=widget_base(wbase,/row,/align_center)
waccept = widget_button(row2, value='Accept',uvalue='accept',font=bfont)
wcancel = widget_button(row2, value='Cancel',uvalue='cancel',font=bfont)

xrealize,wbase,group=group,/center,/screen

widget_control,wbase,set_uvalue=self

xmanager,'self->options',wbase,event='obj_event'

cancel=self->getprop(/cancel)
return
end

;-----------------------------------------------------------------------------
;-- make channel selection widget

pro chan::wchan,base

if not xalive(base) then return
if not self->getprop(/dim1_sel) then return
lfont=self->getprop(/lfont)
bfont=self->getprop(/bfont)

chan=self->getprop(/dim1_ids)
if not is_string(chan) then return

chan_choice=self->getprop(/dim1_use)
units=self->getprop(/dim1_unit)
pad=' '
temp=widget_base(base,column=3)
left=widget_base(temp,/column)
label=widget_label(left,value='Select Channels '+units+':',font=lfont)
label=widget_label(left,value='(Ctrl key for multiple)',font=lfont)

middle=widget_base(temp,/column)
self.wchan=widget_list(middle,value=pad+trim2(chan)+pad,ysize=10,xsize=10,$
                    font='fixed',/multiple)
widget_control,self.wchan,set_list_select=chan_choice
right=widget_base(temp,/nonexclusive)
wall=widget_button(right,value='All',uvalue='all',font=lfont)

nchan=n_elements(chan)
all=nchan eq n_elements(chan_choice)
self->set,all=all
widget_control,wall,set_button=self->getprop(/all)

return & end

;------------------------------------------------------------------------------
;-- chan site structure

pro chan__define

self={chan,dim1_sel:0b,wchan:0l,wtext:0l,cancel:0b,lfont:'',bfont:'', inherits gen}

return & end

