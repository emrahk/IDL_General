; readdips.pro - reads (creates) dip times for RX J1940.1-1025
; $Log: readdips.pro,v $
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;
pro readdips, time,rate, reftime=reftime,$
             helio=helio,bary=bary


;; bary equals helio:
IF keyword_set(bary) THEN helio=1

; global setup:
;dipstart=17400.D0
dipstart=20891.D0
dipnum=4000

;dipwidth=800.D0/86400.D0
dipwidth=900.D0/86400.D0



time=dblarr(dipnum*4)
rate=dblarr(dipnum*4)


FOR i= 0, dipnum-1 DO BEGIN 

dips, i+dipstart, t, /mjd,helio=helio
time[i*4]   = t-dipwidth/2
time[i*4+1] = t-dipwidth/2
time[i*4+2] = t+dipwidth/2
time[i*4+3] = t+dipwidth/2

rate[i*4]   = 0
rate[i*4+1] = 1000
rate[i*4+2] = 1000
rate[i*4+3] = 0
ENDFOR 

if n_elements(reftime) ne 0 then time=time-reftime

end


