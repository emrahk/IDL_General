; readcaha.pro -reads calar alot data for RX J1940.1-1025
; $Log: readcaha.pro,v $
; Revision 1.1  2003/03/31 09:19:40  goehler
;  read rxj1940.1-1025 functions added to cvs
;

pro readcaha, time,rate, error=error,reftime=reftime,$
              helio=helio, bary=bary


; ------------------  global defs -----------------------------

base_path="../CAHA-Jul-2001/Logs"

; ------------------------------------------------------------

if n_elements(reftime) eq  0 then reftime=52106.D0

;; read x/y data:
read_xy,base_path+"/RXJ1940_all.err",data,n_cols=3 ;erzeugt mit write_final 


; time in MJD, in respect of zero point:
time=reform(data[0,*]  - 0.5)
rate=reform(data[1,*])

;; read error data:
read_xy,base_path+"/RXJ1940_all.err",data,n_cols=3,x_col=3,y_col=3 ;erzeugt mit write_final 
error=reform(data[0,*])


; shift to helio center if necessary:
if keyword_set(helio) then begin
    time=rxj_helio(time,/mjd)
    print, "Helio center correction!"
ENDIF



; shift to bary center if necessary:
if keyword_set(bary) then begin
    time=rxj_bary(time,/mjd)
    print, "Bary center correction!"
endif

; shift by reference time:
time=time - reftime


end

