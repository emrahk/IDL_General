;+
; Project     : RHESSI
;
; Name        : ALOG_SCALE
;
; Purpose     : LOG scale an image
;
; Category    : Graphics
;
; Syntax      : output=log_scale(input)
;
; Inputs      : INPUT = input image
;
; Outputs     : OUTPUT = log-scaled image
;
; Keywords    : NO_COPY = do not duplicate input
;
; History     : Written 30 August 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function alog_scale,input,no_copy=no_copy

if n_elements(input) eq 0 then return,input
if is_byte(input) then mprint,'Warning - input image is byte-scaled.'

chk=where(input gt 0.,count,complement=complement,ncomplement=ncount)
if count eq 0 then begin
 mprint,'Cannot log-scale all negative or zero data.'
 return,input
endif

if keyword_set(no_copy) then output=temporary(input) else output=input
if ncount gt 0 then begin
 tmin=min(output[chk],/nan)
 output[complement]=tmin
endif

return,alog10(temporary(output))

end
