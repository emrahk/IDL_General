;+
; Project     : HESSI
;                  
; Name        : ALLOW_SOCKETS
;               
; Purpose     : check if sockets are supported
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> a=allow_sockets()
;                                        
; Outputs     : 1/0 if yes/no
;                   
; History     : 28 Mar 2002, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function allow_sockets,verbose=verbose,err=err

err=''
os=os_family(/lower)
version=float(strmid(!version.release,0,3))
verbose=keyword_set(verbose)

if ((os ne 'windows') and (os ne 'unix')) or (version lt 5.4) then begin
 err='Need at least IDL version 5.4 on Unix/Windows for Socket support'
 if verbose then begin
  message,err,/info
  xack,err,/suppress
 endif
 return,0b
endif

return,1b

end
