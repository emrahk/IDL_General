;+
; $Id: submjd.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;
; PURPOSE:
;  subtract two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to sub: a - b
;        a can be an array but not b
;
; OUTPUTS:
;  resu : a - b
;
; HISTORY:
;  coded by A.Thernisien on 13/08/2002
;
;-
function submjd,a,b

r=a

r.time=a.time-b.time

mlt0=where(r.time lt 0,nblt0)
mge0=where(r.time ge 0,nbge0)

if nblt0 gt 0 then begin
    r(mlt0).time=r(mlt0).time+86400000
    r(mlt0).mjd=a(mlt0).mjd-b.mjd-1
endif
if nbge0 gt 0 then r(mge0).mjd=a(mge0).mjd-b.mjd

return,r
end
