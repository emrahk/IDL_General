;+
; Project     : HESSI
;
; Name        : FREE_VAR__DEFINE
;
; Purpose     : Define a FREE_VAR class
;
; Category    : objects
;
; Explanation : FREE_VAR class contains a single method for
;               recursively freeing memory from an object
;
; Usage:      : IDL> add_method,'free_var',object
;               IDL> object->free_var
;
; or from within a method:
;
;               add_method,'free_var',self
;               self->free_var
;
; Keywords:  EXCLUDE - string array of properties or tag names to
;     not destroy
;
; History     : Written 10 August 2000, Tolbert (GSFC), Zarro (EIT/GSFC)
;
; Modifications:
;   20-Aug-2000, Kim Tolbert, added exclude keyword
;   04-Feb-2003, Kim, somehow check in for loop for exclude disappeared. Put it back
;   05-Feb-2003, Zarro (EER/GSFC) - checked for blank exclude
;   22-Apr-2004, Zarro (L-3Com/GSFC) - added _EXTRA
;
; Contact     : dzarro@solar.stanford.edu
;-

;--------------------------------------------------------------------------

pro free_var::free_var, exclude=exclude,_extra=extra

props = obj_props (self,/super)
nprops=n_elements(props)

; if exclude is blank, then don't checking for it within property loop. 
; Andre says it's faster this way.

if is_blank(exclude) then for i=0,nprops-1 do free_var,self.(i),_extra=extra else begin
 for i=0,nprops-1 do begin
  q = where (props[i] eq strupcase(exclude), count)
  if count eq 0 then free_var, self.(i), exclude=exclude,_extra=extra
 endfor
endelse

return & end

;----------------------------------------------------------------------------

pro free_var__define

temp =  {free_var,free_var__define_placeholder:1}

end
