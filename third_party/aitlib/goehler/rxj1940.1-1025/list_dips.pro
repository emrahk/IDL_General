
; list dips

;FOR i= 18000, 18211 DO BEGIN 
;FOR i= 17400, 17500 DO BEGIN 
;FOR i= 18350, 18500 DO BEGIN 
FOR i= 20891, 22491 DO BEGIN 
;FOR i= 861, 991 DO BEGIN 

dips, i,time, date=date ,/mjd,/helio
print, "Cycle: ", i, " Time: ", string(time,format='(F16.6)'), " Date: ", date
ENDFOR 

end
