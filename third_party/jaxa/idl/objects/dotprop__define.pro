;+
; Project     : RHESSI
;
; Name        : DOTPROP__DEFINE
;
; Purpose     : Convenient base class that inherits IDL_OBJECT
;               to enable new IDL '.' syntax for accessing and
;               setting properties.
;
; Category    : Objects
;
; History     : Written 15 December 2010, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

;----------------------------------------------------------------------

pro dotprop::getproperty,_ref_extra=extra

if ~is_string(extra) then return
if ~have_method(self,'get') then return

nkey=n_elements(extra)
for i=0,nkey-1 do begin
 struct=create_struct(extra[i],1)
 val=self->get(_extra=struct)
 (scope_varfetch(extra[i],/ref))=val
endfor

return & end

;--------------------------------------------------------------------------

pro dotprop::setproperty,_extra=extra

if have_method(self,'set') then self->set,_extra=extra

return & end


;----------------------------------------------------------------------------

pro dotprop__define

  temp =  {dotprop,dotprop_dummy:0B,inherits idl_object}

return & end
