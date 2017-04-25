;+
; $Id: sortmjd.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;
; NAME:
;  sortmjd
;
; PURPOSE:
;  sort an CDS_INT_TIME structure array
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  d0 : the array to sort
;  map : set to output a where-like map
;
; OUTPUTS:
;  resu : sort(d0)
;
; HISTORY:
;  coded by A.Thernisien on 20/08/2002
;
;-
function sortmjd,d0,map=map
d=d0
if n_elements(map) eq 0 then begin
    d=d0(sort(d.mjd))

    idx=0L
    nbd=n_elements(d)

    while idx lt nbd do begin
        m=where(d.mjd eq d(idx).mjd,cnt)
        d(m)=(d(m))(sort(d(m).time))
        idx=idx+cnt
    endwhile
endif else begin
    
    m1=sort(d.mjd)
    idx=0L
    nbd=n_elements(d)

    while idx lt nbd do begin
        m=where(d(m1).mjd eq d(m1(idx)).mjd,cnt)
        m1(m)=m1(m(sort(d(m1(m)).time)))
        idx=idx+cnt
    endwhile
    d=m1
endelse

return,d
end
