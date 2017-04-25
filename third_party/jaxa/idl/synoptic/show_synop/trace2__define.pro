;+
; Project     : TRACE2
;
; Name        : TRACE2__DEFINE
;
; Purpose     : Wrapper object to read prepped TRACE images
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('trace2')
;
; History     : Written 1-Jan-09 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function trace2::init,_ref_extra=extra

return,self->synop::init(ftype='trac_',_extra=extra)

end

;------------------------------------------------------------------------------

pro trace2__define,void                 

void={trace2,inherits synop}

return & end
