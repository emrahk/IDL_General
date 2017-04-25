;+
; Project     :	SOHO/CDS
;
; Name        : XLIST
;
; Purpose     : lists structure tags in a list widget.
;
; Use         : XLIST,STRUCT.
;
; Inputs      : STRUCT
;
; Outputs     : INDEX = selected index of structure array
;
; Keywords    : 
;               wbase  = widget id of parent widget (input/output)
;               wlist  = widget id of list widget into which to write (input/output)
;               lfont   = list widget font 
;               bfont   = button widget font 
;               title  = title of parent base
;               tags   = tags to list
;               select = set to permit list selection
;               remove = set to permit list deletion
;               ysize  = ysize of list widget
;               xsize  = xsize of list widget
;
; Category    : Widgets
;
; Written     :	Zarro (ARC/GSFC) 12 October 1994
;               Modified, 28 Feb 2007, Zarro (ADNET)
;               - moved group & modal keywords from xmanager to widget_base
;-

pro xlist_event,  event                         ;event driver routine

widget_control,event.top,get_uvalue=unseen
info=get_pointer(unseen,/no_copy)
if datatype(info) ne 'STC' then return

child=child_pointer(unseen)
struct=get_pointer(child,/no_copy)
if datatype(struct) ne 'STC' then return

widget_control, event.id, get_uvalue = uservalue
selected=info.selected
fields=info.fields
nfields=info.nfields

if (n_elements(uservalue) eq 0) then uservalue=''
wtype=widget_info(event.id,/type)

;-- button widget

bname=strtrim(uservalue,2)
if bname eq 'exit' then begin
 info.selected=-1
 xkill,event.top
endif

if bname eq 'select' then xkill,event.top

if bname eq 'view' then begin
 info.view_on=event.select
 if info.view_on then xlist_view,struct,info,group=event.top else xhide,info.sbase
endif

;-- remove elements

if (bname eq 'remove') or (bname eq 'clear') then begin
 delete_all=0

 if bname eq 'remove' then begin
  if (selected gt -1) and (nfields gt 0) then begin
   keep=where(selected ne indgen(nfields),cnt)
   if cnt gt 0 then begin
    fields=fields(keep) & nfields=cnt
    struct=struct(keep)
   endif else delete_all=1
  endif
 endif else delete_all=1

 if delete_all then begin
  value=xanswer('Are you sure?',group=event.top,/modal)
  if value then begin 
   fields='' & nfields=0
  endif else goto,bail_out
 endif

 selected=-1
 info=rep_tag_value(info,fields,'fields')
 info.nfields=nfields
 info.selected=selected
 widget_control,info.wlist,set_value=fields
 widget_control,info.wlist,sensitive=(nfields gt 0)
endif

;-- list widget

if wtype eq 6 then begin
 info.selected=event.index 
 if info.view_on then xlist_view,struct,info,group=event.top
endif

xlist_buttons,info
bail_out:
set_pointer,unseen,info,/no_copy
set_pointer,child,struct,/no_copy

return & end

;--------------------------------------------------------------------------- 

pro xlist_view,struct,info,group=group

sbase=info.sbase
stags=info.stags
if info.selected lt 0 then return
xstruct,struct(info.selected),/just_reg,$
 wbase=sbase,wtags=stags,group=group,title=' '
info.sbase=sbase
info=rep_tag_value(info,stags,'STAGS')

return & end

;--------------------------------------------------------------------------- 

pro xlist_buttons,info

ok=(info.selected gt -1)
if xalive(info.selb) then widget_control,info.selb,sensitive=ok
if xalive(info.remb) then widget_control,info.remb,sensitive=ok
if xalive(info.clearb) then widget_control,info.clearb,$
 sensitive=(info.nfields gt 0)

return & end

;--------------------------------------------------------------------------- 

pro xlist,struct,index,wlist=wlist,lfont=lfont,select=select,modal=modal,$
      wbase=wbase,title=title,group=group,just_reg=just_reg,bfont=bfont,$
      wlabel=wlabel,tags=tags,_extra=extra,font=font,$
      remove=remove,pad=pad,clear=clear,ysize=ysize,xsize=xsize,view=view

index=-1

if  (datatype(struct) ne 'STC') then begin
 message,'input must be a structure',/cont
 return
endif

if not have_widgets() then begin
 message,'widgets unavailable',/cont
 return
endif

just_reg=keyword_set(just_reg)
update=xalive(wbase)
modal=keyword_set(modal) or keyword_set(select) 

if datatype(title) ne 'STR' then title = 'XLIST'

;-- get tag definitions

stc_name=tag_names(struct,/structure_name)
if stc_name eq '' then stc_name='ANONYMOUS'
nstruct=n_elements(struct)

;-- make string array for list widget

cur_tags=tag_names(struct)
ntags=n_elements(tags)
if ntags eq 0 then begin
 do_tags=cur_tags
endif else begin
 if datatype(tags) eq 'STR' then do_tags=tags else do_tags=cur_tags(tags)
endelse

ntags=n_elements(do_tags)

if not exist(pad) then pad=' ' else pad=strpad(' ',pad,/after)
lpad=fltarr(n_elements(cur_tags))

for k=0,1 do begin
 for j=0,nstruct-1 do begin
  tstruct=struct(j) & delvarx,tlabel
  for i=0,n_elements(cur_tags)-1 do begin
   ctag=strupcase(strtrim(cur_tags(i),2))
   clook=where(ctag eq strtrim(strupcase(do_tags),2),count)
   if count gt 0 then begin
    temp=tstruct.(i)
    if datatype(temp) eq 'STC' then outsub='STRUCTURE' else outsub=arr2str(temp,delim=' ',/trim)
    outsub=outsub+pad
    ctag=ctag+pad
    if k eq 0 then begin
     lpad(i)= lpad(i) > strlen(outsub)
     lpad(i)=lpad(i) > strlen(ctag)
    endif else begin
     outsub=strpad(outsub,lpad(i),/after)
     if not exist(tlabel) then tlabel=outsub else tlabel=tlabel+outsub
    endelse
   endif
  endfor
  if k eq 1 then begin
   if j eq 0 then fields=tlabel else fields=[fields,tlabel]
  endif
 endfor
endfor

ok=where_vector(do_tags,cur_tags,count)
lpad=lpad(ok)
slabel=strpad(do_tags(0),lpad(0),/after)
if count gt 1 then for i=1,count-1 do slabel=slabel+strpad(do_tags(i),lpad(i),/after)

;-- make widgets

if (not update) then begin

;-- fonts

 mk_dfont,bfont=bfont,lfont=lfont
 wbase=widget_base(title=title,/column,group=group)

;-- buttons

 selb=0 & remb=0 & clearb=0 & viewb=0
 row1=widget_base(wbase,/row,map=0)
 if (not just_reg) then begin
  if keyword_set(select) then bname='Cancel' else bname='Done'
  exitb=widget_button(row1,value=bname,uvalue='exit',/no_release,/frame,$
                      font=bfont)

  if keyword_set(select) then $
   selb=widget_button(row1,value='Select and Exit',uvalue='select',/no_release,$
                    /frame,font=bfont)

  if keyword_set(remove) then $
   remb=widget_button(row1,value='Remove',uvalue='remove',/no_release,$
                    /frame,font=bfont)

  if keyword_set(view) then $
   xmenu,'View',row1,/row,/nonexclusive,/frame,buttons=viewb,uvalue='view',$
     font=bfont

  if keyword_set(clear) then $
   clearb=widget_button(row1,value='Clear All',uvalue='clear',/no_release,$
                    /frame,font=bfont)
  widget_control,row1,/map
 endif

;-- lists

 if not exist(ysize) then ysize=20
 if not exist(xsize) then xsize=strlen(slabel)
 wlabel=widget_list(wbase,font=lfont,ysize=1,xsize=xsize,value='')
 wlist=widget_list(wbase,/frame,ysize=ysize,font=lfont,xsize=xsize,value='')
 xrealize,wbase,group=group,_extra=extra
 widget_control,wlabel,set_value=slabel
 widget_control,wlist,set_value=fields

;-- use pointer to communicate with event handler

 if not just_reg then begin
  make_pointer,unseen,child,/wid
  sbase=0l & stags=0l
  nfields=n_elements(fields)
  info={fields:fields,selected:-1,selb:selb,remb:remb,wlist:wlist,$
        clearb:clearb,viewb:viewb,nfields:nfields,sbase:sbase,$
        view_on:0,stags:stags}
  xlist_buttons,info
  set_pointer,unseen,info,/no_copy
  set_pointer,child,struct,/no_copy
  widget_control,wbase,set_uvalue=unseen
 endif
endif else begin                  ;-- updating registered XLIST
 if not xalive(wlist) then begin
  row=widget_info(wbase,/child)
  wlabel=widget_info(row,/sib)
  wlist=widget_info(wlabel,/sib)
 endif
 if datatype(title) eq 'STR' then widget_control,wbase,tlb_set_title=trim(title)
 widget_control,wlist,set_value=fields
 widget_control,wlabel,set_value=slabel
 widget_control,wbase,get_uvalue=unseen
 child=child_pointer(unseen)
 info=get_pointer(unseen,/no_copy)
 if datatype(info) eq 'STC' then begin
  info=rep_tag_value(info,fields,'fields')
  info.nfields=n_elements(fields) 
  set_pointer,unseen,info,/no_copy
  set_pointer,child,struct,/no_copy
  widget_control,wbase,set_uvalue=unseen
 endif
 xshow,wbase
 return
endelse

if not just_reg then xmanager,'xlist',wbase,just_reg=just_reg,modal=modal

;-- cleanup

if (not xalive(wbase)) and (not just_reg) then begin
 struct=get_pointer(child,/no_copy)
 info=get_pointer(unseen,/no_copy)
 if datatype(info) eq 'STC' then begin
  index=info.selected
  if info.nfields eq 0 then delvarx,struct
 endif
endif
 
if just_reg or modal or (get_caller() eq '') then begin
 free_pointer,unseen
 free_pointer,child
endif

return & end


