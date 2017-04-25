;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  negmjd
;
; PURPOSE:
;  neg of an CDS_INT_TIME struct array
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a : input array to neg
;
; OUTPUTS:
;  resu : - a
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:;
;
; HISTORY:
;  coded by A.Thernisien on 13/08/2002
;
; CVSLOG:
;  Revision 1.1  2002/08/20 15:46:05  arnaud
;  *** empty log message ***
;
; $Id: negmjd.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function negmjd,a

r=a
r.time=0L-a.time

mlt0=where(r.time lt 0,nblt0)
mge0=where(r.time ge 0,nbge0)

if nblt0 gt 0 then begin
    r(mlt0).time=r(mlt0).time+86400000
    r(mlt0).mjd=0L-a(mlt0).mjd-1
endif
if nbge0 gt 0 then r(mge0).mjd=0L-a(mge0).mjd

return,r
end
