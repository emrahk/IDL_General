;+
; Project     : SOHO
;
; Name        : FIX_SOHO_ROLL,INDEX
;
; Purpose     : Fix 180 roll in INDEX structure
;
; Category    : imaging
;
; Syntax      : IDL> out=fix_soho_roll(index)
;
; Inputs      : INDEX = index from FITS file
;
; Outputs     : OUT = INDEX modified with potential roll keywords set to 0.
;
; Keywords    : None
;
; History     : Written 20 July 2009, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function fix_soho_roll,index

if ~is_struct(index) then return,0b

out=index
if have_tag(index,'sc_roll',k,/exact) then out.(k)=0.
if have_tag(index,'p_angle',k,/exact) then out.(k)=0.
if have_tag(index,'crot',k,/exact) then out.(k)=0.
if have_tag(index,'crota1',k,/exact) then out.(k)=0.
if have_tag(index,'crota2',k,/exact) then out.(k)=0.
if have_tag(index,'solar_p',k,/exact) then out.(k)=0.

return,out

end
