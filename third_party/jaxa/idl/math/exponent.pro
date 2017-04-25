;+
; Project     : HINODE/EIS
;
; Name        : EXPONENT
;
; Purpose     : return exponent of number
;
; Inputs      : VALUE = number to check [e.g. 1024]
;               BASE  = base power [e.g. 2]
;
; Outputs     : EXPONENT such that VALUE= BASE ^ EXPONENT
;
; Keywords    : None
;
; Version     : Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function exponent,value,base

if ~is_number(value) then return,0
if is_number(base) then base=fix(base) else base=2

if value lt base then return,0
i=0
num=value
repeat begin
 i=i+1
 rem= num mod base
 if rem eq 0 then num=num/base else return,0
endrep until (num eq 1)

return,i
end
