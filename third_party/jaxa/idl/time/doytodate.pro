;+
; PURPOSE:
;  give the date from the day of year
; 
; CATEGORY:
;  time
;-

function doytodate,year,doy,_extra=e

; - subtract 1 because the DOY start at 1
date=anytim(addmjd(anytim(strtrim(year,2)+'/01/01',/mjd),{CDS_INT_TIME,mjd:long(doy-1),time:0L}),_extra=e)


return,date
end
