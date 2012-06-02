function loadasm1d, fl

;;
;; Load in the ASM data
;;
;; The "One-Day Averages" ASCII data files contain five columns: 
;;   0.MJD of the observation (JD - 2,400,000.5) 
;;   1.Averaged ASM unit count rate for the day (counts/second; Crab is ~75) 
;;   2.RMS estimated error (counts/second) 
;;   3.RMS deviation of the points from the one-day mean (counts/second) 
;;   4.Number of dwells averaged 

temp=dblarr(5)
data=[0]

openr,unit,fl,/get_lun
while not eof(unit) do begin
   readf,unit,temp,format='(5f0)'
   if (data(0) eq 0) then begin
      data=[temp]
   endif else begin
      data=[[data],[temp]]
   endelse 
endwhile
free_lun,unit


;;
;; That's All FFolks!
;;

return,data
end
