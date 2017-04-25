;+
; Project     : HESSI
;
; Name        : YMD2DATE
;
; Purpose     : convert YMD to date
;
; Category    : time utility
;
; Inputs      : YMD - year, month, day string, e.g. '040311'
;
; Outputs     : DATE - 11-Mar-2004
;
; Keywords    : ERR - error string
;
; History     : 29-Aug-2004,  D.M. Zarro (L-3Com/GSFC).  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function ymd2date,ymd,err=err,_extra=extra,tai=tai

err=''
if is_blank(ymd) then return,''
chk=stregex(ymd,'([0-9]{2,4})([0-9]{2})([0-9]{2})',/extra,/sub)
chk=comdim2(chk[1,*]+'-'+chk[2,*]+'-'+chk[3,*])
if keyword_set(tai) then t=anytim2tai(chk,err=err) else begin
 if is_struct(extra) then t=anytim2utc(chk,err=err,_extra=extra) else $
  t=anytim2utc(chk,err=err,/vms)
endelse

if is_string(err) then message,err,/cont
return,t
end
