;+
; Project     : HESSI
;
; Name        : VALID_OMAP
;
; Purpose     : check if input objects is a valid object map
;
; Category    : utility objects
;
; Syntax      : IDL> valid=valid_omap(object)
;
; Inputs      : OBJECT = object variable
;
; Outputs     : 1/0 if valid or invalid
;
; History     : Written 1 May 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function valid_omap,var

if size(var,/tname) ne 'OBJREF' then return,0b

parents=obj_parents(var)
chk= (parents eq 'MAP') or (parents eq 'FITS')
ok=where(chk eq 1,count)
return,count gt 0

end
