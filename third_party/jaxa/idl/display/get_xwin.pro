;+
; Project     : SOHO-CDS
;
; Name        : GET_XWIN
;
; Purpose     : get a free X-window
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : get_xwin,index
;
; Inputs      : INDEX - window index to get
;               If input window INDEX is available then corresponding window
;               will become active, otherwise a new window is opened
;
; Keywords    : XSIZE,YSIZE = window size [def = 512,512]
;               RETAIN = retain backing store [def = 2]
;               XPOS,YPOS = window position [def = 0,0]
;               TITLE = window title [def = '']
;               FREE  = get next free window
;               NOSHOW = don't call WSHOW
;               NEW = get new window with specified INDEX
;               NORESIZE = if set, resized windows are treated as new windows
;
; History     : Written 22 October 1996, D. Zarro, ARC/GSFC
;               Modified, 20 May 2000, Zarro (EIT/GSFC) 
;               Modified, 13 Dec 2001, Zarro (EITI/GSFC) - added ALLOW_WINDOWS call
;
; Contact     : dzarro@solar.stanford.edu
;-
;+

pro get_xwin,index,xsize=xsize,ysize=ysize,free=free,err=err,$
             ypos=ypos,xpos=xpos,retain=retain,title=title,draw=draw,$
             noshow=noshow,new=new,_extra=extra,noresize=noresize

err=''
do_windows=(!d.name ne 'Z') and (!d.name ne 'PS')
if not do_windows then begin
 if not exist(index) then index=-1 & return
endif

if not allow_windows() then begin
 err='Unable to open window'
 if not exist(index) then index=-1
 return
endif

if n_elements(retain) eq 0 then retain=2
if n_elements(xpos) eq 0 then xpos=0
if n_elements(ypos) eq 0 then ypos=0
if datatype(title) ne 'STR' then title=' '

case 1 of
 exist(xsize) and (not exist(ysize)): begin
  dxsize=xsize(0) & dysize=xsize(0)
 end
 (not exist(xsize)) and exist(ysize): begin
  dxsize=ysize(0) & dysize=ysize(0)
 end
 exist(ysize) and exist(xsize) : begin
  dxsize=xsize(0) & dysize=ysize(0)
 end
 else: begin
  dxsize=512 & dysize=512
 end
endcase

if keyword_set(free) then begin
 dwin=-1 & goto,done
endif

;-- valid index entered?

if is_number(index) then dwin=index else begin
 if !d.window gt -1 then dwin=!d.window else begin
  dwin=-1 & goto,done
 endelse
endelse

new=keyword_set(new)
if keyword_set(new) then begin
; if dwin gt 31 then dwin=-1
 dwin=-1
 goto,done
endif

;-- check if input window index is open

resize=1-keyword_set(noresize)

device,window=ow
owx=where(ow eq 1)
find=where(float(dwin) eq float(owx),count)
if count gt 0 then begin
 if ((!d.x_size eq dxsize) and (!d.y_size eq dysize)) or resize then begin
  wset,dwin & goto,exit
 endif else dwin=-1
endif else begin
 if dwin gt 31 then dwin=-1
endelse

done:

if (dwin gt -1) then begin
 window,dwin,xsize=dxsize,ysize=dysize,xpos=xpos,retain=retain,title=title,$
  ypos=ypos,_extra=extra
endif else begin
 window,/free,xsize=dxsize,ysize=dysize,xpos=xpos,retain=retain,$
 title=title,ypos=ypos,_extra=extra
endelse

exit:

index=!d.window
wset,index
dprint,'% GET_XWIN: current window set to: '+string(index)

;if trim(title) eq '' then wtitle,index,'IDL '+trim(string(index))

if (1-keyword_set(draw)) and (1-keyword_set(noshow)) then wshow2,index


return & end

