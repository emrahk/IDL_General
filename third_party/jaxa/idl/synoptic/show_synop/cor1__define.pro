;+
; Project     : STEREO
;
; Name        : COR1__DEFINE
;
; Purpose     : stub that inherits from SECCHI class
;
; Category    : Objects
;
; History     : Written 7 April 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function cor1::init,_ref_extra=extra

if self->secchi::init(_extra=extra) then return,1 else return,0

end

;--------------------------------------------------------------------
function cor1::search,tstart,tend,_ref_extra=extra

return,self->secchi::search(tstart,tend,/cor1,_extra=extra)
end

;------------------------------------------------------
pro cor1__define,void                 

void={cor1, inherits secchi}

return & end
