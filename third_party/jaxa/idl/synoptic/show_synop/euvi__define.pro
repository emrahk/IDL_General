;+
; Project     : STEREO
;
; Name        : EUVI__DEFINE
;
; Purpose     : stub that inherits from SECCHI class
;
; Category    : Objects
;
; History     : Written 7 April 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function euvi::init,_ref_extra=extra

if self->secchi::init(_extra=extra) then return,1 else return,0

end

;-----------------------------------------------------

pro euvi::read,file,_ref_extra=extra

self->secchi::read,file,_extra=extra,/euvi

return & end

;-----------------------------------------------------------

function euvi::search,tstart,tend,_ref_extra=extra

return,self->secchi::search(tstart,tend,/euvi,_extra=extra)

end

;----------------------------------------------------
pro euvi__define,void                 

void={euvi, inherits secchi}

return & end
