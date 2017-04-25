;+
; Project     : HESSI
;
; Name        : MDI_C__DEFINE
;
; Purpose     : Define an MDI Continuum data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('mdi_c')
;
; History     : Written 17 Jul 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

;-- MDI search method

function mdi_c::search,tstart,tend,_ref_extra=extra

return,self->mdi::search(tstart,tend,/continuum,_extra=extra)

end

;-------------------------------------------------------------------

;-- MDI Continuum data structure

pro mdi_c__define                 

self={mdi_c,inherits mdi}

return & end



