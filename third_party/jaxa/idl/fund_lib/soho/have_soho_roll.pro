;+
; Project     : SOHO
;
; Name        : HAVE_SOHO_ROLL
;
; Purpose     : Check INDEX structure for SOHO 180 degree roll
;
; Category    : imaging
;
; Syntax      : IDL> chk=have_soho_roll(index)
;
; Inputs      : INDEX = index 
;
; Outputs     : 1/0 if rolled 180 or not
;
; Keywords    : None
;
; History     : Written 20 July 2009, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function have_soho_roll,index

if ~is_struct(index) and ~is_string(index) then return,0b
if is_string(index) then tindex=fitshead2struct(index) else tindex=index

choices=['sc_roll','p_angle','crot','crota1','crota2','solar_p']
for i=0,n_elements(choices)-1 do begin
 if have_tag(tindex,choices[i],k,/exact) then $
  if nint((abs(index.(k)) mod 360)) eq 180 then return,1b
endfor

return,0b

end
