;+
; PURPOSE:
;  give the day of year for a given date
; 
; CATEGORY:
;  time
;-

function doy,date
return,mjd2doy(anytim(date,/mjd))
end
