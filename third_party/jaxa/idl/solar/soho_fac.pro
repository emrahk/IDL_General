;+
; Project     : SOHO
;
; Name        : soho_fac
;
; Purpose     : return ratio of solar radius viewed from SOHO to that viewed
;               from Earth
;
; Category    : utility 
;;
; Syntax      : IDL> ratio=soho_fac(date)
;
; Inputs      : DATE = date to compute ratio (def=current)
;
; Outputs     : above ratio
;
; Keywords    : None
;
; History     : Written 20 Sept 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function soho_fac,date

err=''
tdate=anytim2utc(date,err=err)
if err ne '' then get_utc,tdate

svec=pb0r(tdate,/soho)
evec=pb0r(tdate)

return,svec(2)/evec(2)

end
