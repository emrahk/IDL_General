; readtroughs.pro - reads (creates) trough times for RX J1940.1-1025
; $Log: readtroughs.pro,v $
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;

pro readtroughs, time,rate, reftime=reftime,$
                 helio=helio, bary=bary


;; bary equals helio:
IF keyword_set(bary) THEN helio=1

; global setup:
troughstart=16000.D0
troughnum=5000L

troughwidth1=1129.3D0/86400.D0
troughwidth2=1074.2D0/86400.D0

time=dblarr(troughnum*4L)
rate=dblarr(troughnum*4L)
;period=12141.302361D0/86400.D0
basetime=2449638.824D0
period  =12150.096713D0/86400.D0
pdot    = -3.0223D-9


FOR i= 0L, troughnum-1 DO BEGIN 

troughs, i+troughstart, t, /mjd,helio=helio,period=period,basetime=basetime,pdot=pdot
time[i*4]   = t-troughwidth1
time[i*4+1] = t-troughwidth1
time[i*4+2] = t+troughwidth2
time[i*4+3] = t+troughwidth2

rate[i*4]   = 0
rate[i*4+1] = 1000
rate[i*4+2] = 1000
rate[i*4+3] = 0
ENDFOR 

if n_elements(reftime) ne 0 then time=time-reftime

end


