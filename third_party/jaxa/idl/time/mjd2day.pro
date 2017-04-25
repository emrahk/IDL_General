;+
; $Id: mjd2day.pro,v 1.1 2006/09/11 21:10:00 nathan Exp $
;
; PURPOSE:
;  Convert a CDS_INT_TIME to a double precision mjd date
; 
; CATEGORY:
;  time
;
; INPUTS:
;  a : a CDS_INT_TIME date structure
; 
; OUTPUTS:
;  return : the mjd date in double precision
;
;-
function mjd2day,a
return,double(a.mjd)+(double(a.time)/86400000D)
end
