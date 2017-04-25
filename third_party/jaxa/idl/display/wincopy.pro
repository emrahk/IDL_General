;+
; Project     : HESSI
;                  
; Name        : WINCOPY
;               
; Purpose     : copy contents of one window into another
;               
; Category    : display graphics utility
;               
; Explanation : uses DEVICE,/COPY
;               
; Syntax      : IDL> wincopy,w1,w2
;    
; Examples    : 
;
; Inputs      : W1 = source window ID
;               W2 = target window ID
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : FREE = if target doesn't exist, create it
;               PIXMAP = if creating via /FREE, make it a PIXMAP
;               VERBOSE = informational messages
;               ERR = error string
;             
; Restrictions: Probably works in Windows
;               
; Side effects: Nome
;               
; History     : Version 1,  26-May-1999, Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro wincopy,window1,window2,free=free,err=err,verbose=verbose,pixmap=pixmap

err=''
verbose=keyword_set(verbose)
free=keyword_set(free)
reverse=keyword_set(reverse)
pixmap=keyword_set(pixmap)

if not exist(window1) then src_wid=!d.window else src_wid=window1
device,window=owindow

;-- check if source window is available

avail=where(owindow eq 1,count)
if count eq 0 then begin
 err='no windows open'
 message,err,/cont
 return
endif

chk=where(src_wid eq avail,count)
if count eq 0 then begin
 err='source window '+num2str(src_wid)+' is closed'
 message,err,/cont
 return
endif

;-- check if target window is available (if /free not set)

if not exist(window2) then free=1b else targ_wid=window2
if not free then begin
 chk=where(targ_wid eq avail,count)
 if count eq 0 then begin
  err='target window '+num2str(targ_wid)+' is closed'
  message,err,/cont
  return
 endif
endif else begin
 window,/free,pixmap=pixmap
 targ_wid=!d.window
endelse

;-- now do copy

wset,targ_wid
device,copy=[0,0,!d.x_vsize,!d.y_vsize,0,0,src_wid]
wset,src_wid

if verbose then message,'window '+num2str(src_wid)+' copied '+num2str(targ_wid),/cont
if pixmap then wset,src_wid else wset,targ_wid
window2=targ_wid

return & end

