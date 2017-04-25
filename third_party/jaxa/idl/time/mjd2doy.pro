;+
; $Id: mjd2doy.pro,v 1.1 2006/09/11 21:10:00 nathan Exp $
;
; PURPOSE:
;  Give the Day Of Year from a date in CDS_INT_TIME format
; 
; CATEGORY:
;  time
; 
; INPUTS:
;  mjd : CDS_INT_TIME date
; 
; OUTPUTS:
;  return : the day of year
;
;-

function mjd2doy,mjd

date=anytim(mjd,/utc_ext)

firstdoy=anytim(string(date.year,form='(I4.4)')+'/01/01 00:00:00.000',/mjd)

doy=fix(mjd2day(mjd)-mjd2day(firstdoy))+1


return,doy
end
