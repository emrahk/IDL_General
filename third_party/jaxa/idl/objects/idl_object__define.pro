;+
; Project     : RHESSI
;
; Name        : IDL_OBJECT__DEFINE
;
; Purpose     : Fake IDL_OBJECT class definition to maintain
;               backwards compatibility between IDL 8 and older
;               versions.
;
; Category    : Objects
;
; History     : Written 15 December 2010, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function idl_object::init

return, 1

end

;---------------------------------------------------------------------
pro idl_object::cleanup

return & end

;--------------------------------------------------------------------------

pro idl_object__define

temp =  {idl_object,idl_object_dummy:0B}

return & end
