;+
; Project     : SOHO - CDS     
;                   
; Name        : SMART_WINDOW
;               
; Purpose     : a smarter way to set/restore plot window parameters
;               
; Category    : utility
;               
; Syntax      : IDL> smart_window,window
;    
; Inputs      : WINDOW = window ID number to set to
;               
;               
; Keywords    : SET = set current system variables to saved values
;               REMOVE = remove input window from common
;               DRAW = informs that window is a DRAW widget
;               STATUS = 1/0 if success/fail
;               NOSHOW = set to not call WSHOW
;               
; Side effects: If WINDOW is valid, subsequent plots are directed to it
;               
; History     : Version 1,  24-Jan-1998, Zarro (SAC/GSFC)
;               24-Jun-2000, Zarro (EIT/GSFC) - changed IS_WIN call to SUPP_WIN
;               18-Jun-2001, Zarro (EITI/GSFC) - added Z-buffer support
;               13 Dec 2001, Zarro (EITI/GSFC) - added ALLOW_WINDOWS call
;
; Contact     : dzarro@solar.stanford.edu
;-            

pro smart_window,window,set=set,remove=remove,draw=draw,status=status,$
                 noshow=noshow

common smart_window,window_pars

status=0b
ps=!d.name eq 'PS'

if (not exist(window)) then return
status=1b
if ps then return

;-- check if window is closed

zbuff=!d.name eq 'Z'
if (not zbuff) then begin
 if not allow_windows() then begin
  status=0b
  return
 endif
endif

closed=1b
if not zbuff then begin
 device,wind=ow 
 where_open=where(ow eq 1,count)
 if count gt 0 then begin
  ok=where(window eq where_open,ocount)
  closed=(ocount eq 0) 
 endif
endif else closed=0b

;-- check if window parameters are saved

saved=0b
if datatype(window_pars) eq 'STC' then begin
 ok=where(window eq window_pars.window,count)
 saved=(count eq 1)
endif

if saved and (closed or keyword_set(remove)) then begin
 keep=where(window ne window_pars.window,count)
 if count eq 0 then delvarx,window_pars else window_pars=window_pars(keep)
 saved=0b 
endif
if closed then return

multi_pos=!p.multi(0)
if saved then begin
 if keyword_set(set) then begin
  window_pars(ok).x=!x
  window_pars(ok).y=!y
  window_pars(ok).p=!p
 endif else begin
  !x=window_pars(ok).x
  !y=window_pars(ok).y
  !p=window_pars(ok).p
 endelse
endif else begin
 new_par={window:long(window),x:!x,y:!y,p:!p}
 window_pars=merge_struct(window_pars,new_par)
endelse

if not zbuff then begin
 wset,window
 if (1-keyword_set(draw)) and (1-keyword_set(noshow)) then wshow2,window
endif

status=1b

;-- preserve plot location for multiple plots

!p.multi(0)=multi_pos

return & end
