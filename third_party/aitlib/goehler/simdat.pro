pro simdat, time, rate, signal=signal,noise=noise,$
    period=period, gap_period=gap_period, gap_index=gap_index, num=num, gap_level=gap_level
; simdat - simulates different data


; number of points:
if n_elements(num) eq 0 then  num=4000

; test period:
if n_elements(period) eq 0 then period=50.0

; signal height:
if n_elements(signal) eq 0 then signal=1.0

; noise height:
if n_elements(noise) eq 0 then noise=1.0



; create time field:
time=dindgen(num)


; create periodic gaps:
; with a given period:
if n_elements(gap_period) eq 0 then gap_period =20.0

; sinus level above which gap is rejected
IF n_elements(gap_level) EQ 0 THEN gap_level=0.99

gaps=sin(time*2.D0*!DPI/gap_period)^2.D0
gap_index = where(gaps lt gap_level)




rate=signal*(sin(time*2.D0*!DPI/period)+1.D0) + noise*randomu(seed,num,/double) 

time=time[gap_index]
rate=rate[gap_index]

end


