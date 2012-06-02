function findcycle, time, cstart, cstop, period=period, basetime=basetime,pdot=pdot
; look for cycle comes closest to time by a recursive binary search
; between cycle cstart and cstop
; 11-06-2002, eg


;period=(12150.D0-13.5D0)/86400.D0
if n_elements(period) eq 0 then period=(12150.D0)/86400.D0

IF n_elements(pdot) EQ 0 THEN pdot=-3.3D-9

;basetime=(2452000.5D0-0.02156D0)
; basetime according diss. geckeler, p.40, first entry, in JD
if n_elements(basetime) eq 0 then basetime=(2449638.82219D0)

troughs, cstart,t1, period=period,/mjd,/helio,basetime=basetime,pdot=pdot
troughs, cstop, t2, period=period,/mjd,/helio,basetime=basetime,pdot=pdot

cmid = (cstart+cstop)/2
troughs, cmid, t3, period=period,/mjd,/helio,basetime=basetime, pdot=pdot

if cstop-cstart gt 1 then begin
    if time lt t3 then return, findcycle(time, cstart, cmid, $
                                         period=period, basetime=basetime,pdot=pdot) $
    else               return, findcycle( time, cmid, cstop, $
                                          period=period, basetime=basetime,pdot=pdot)
endif else begin
    if time lt (t1+t2)/2 then return, cstart $
    else return, cstop
endelse

end
