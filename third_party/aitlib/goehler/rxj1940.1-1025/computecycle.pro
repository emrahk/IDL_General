function computecycle, time, basetime=basetime, period=period, pdot=pdot
; look for cycle comes closest to time by explicite solving cycle/time
; equation. time must be in mjd
; 12-06-2002, eg



if n_elements(basetime) eq 0 then basetime =  2449638.8242296550D0

IF n_elements(period) EQ 0 THEN period = 0.1406261194D0

IF n_elements(pdot) EQ 0 THEN pdot=  -3.0223080D-09


; JD -> MJD
basetime=basetime-2400000.5D0


if pdot eq 0.D0 then return, round((time-basetime)/period)

; solved T= basetime + N*P + N^2*P*P_dot/2 
val = round((sqrt(1.D0 - 2.D0*(basetime-time)/period*pdot) - 1.D0)/pdot) 
return, val


end

