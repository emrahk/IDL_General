pro get_msclr_events,idf0_,times_,pha
;**************************************************
; Program retrieves the event times and pha 
; values from the common block. Variables 
; are:
;     times_.........event times
;      idf0_.........first idf used
;       pha..........pha array
; Define the common block:
;*************************************************
common events,idf0,times,phasave
;*************************************************
; Extract the variables:
;*************************************************
times_ = times
idf0_ = idf0
pha = phasave
;*************************************************
; That's it!
;*************************************************
return
end
