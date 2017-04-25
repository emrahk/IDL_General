;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  addmjd
;
; PURPOSE:
;  addition of two mjd formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to add
;
; OUTPUTS:
;  resu : a + b
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:;
;
; HISTORY:
;  coded by A.Thernisien on 13/08/2002
;
; CVSLOG:
;  $Id: addmjd.pro,v 1.1 2006/09/11 21:10:00 nathan Exp $
;
;
;-
function addmjd,a,b

r=a

r.time=a.time+b.time

mge=where(r.time ge 86400000,nbge)
mlt=where(r.time lt 86400000,nblt)

if nbge gt 0 then begin
    r(mge).time=r(mge).time-86400000
    r(mge).mjd=a(mge).mjd+b.mjd+1
endif
if nblt gt 0 then r(mlt).mjd=a(mlt).mjd+b.mjd

return,r
end
