;+
; Project     : EIT2
;
; Name        : EIT2__DEFINE
;
; Purpose     : Wrapper object to read prepped EIT images
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('eit2')
;
; History     : Written 1-Jan-09 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function eit2::init,_ref_extra=extra

return,self->synop::init(ftype='eit_',_extra=extra)

end

;------------------------------------------------------------------------------

pro eit2__define,void                 

void={eit2,inherits synop}

return & end
