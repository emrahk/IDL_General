function trough_cycles, time, period=period, basetime=basetime,pdot=pdot
; trough_cycles - return cycle number for given trough time.
; default trough ephemerides use time in JD
; 10-06-2002, eg

;period=(12150.D0-13.5D0)/86400.D0
if n_elements(period) eq 0 then period=(12150.D0)/86400.D0 

IF n_elements(pdot) EQ 0 THEN pdot=-3.3D-9
      

;basetime=(2452000.5D0-0.02156D0)
; basetime according diss. geckeler, p.40, first entry, in JD
if n_elements(basetime) eq 0 then basetime=2449638.82219D0


;; compute cycle number according algorithm used in cafe_model_dip
cycles = round((- 1.D0  + sqrt(1.D0 - $
                                2.D0*pdot/period* $
                                (basetime-time)))              $
                /pdot)

return, cycles


end
