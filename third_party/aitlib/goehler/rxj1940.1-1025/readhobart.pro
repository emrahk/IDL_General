; readhobart.pro -reads hobat data for RX J1940.1-1025
; $Log: readhobart.pro,v $
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;
;
; rate in arbitrary units (mag to flux converted)

pro readhobart, time,rate,reftime=reftime,$
              helio=helio,bary=bary


; ------------------  global defs -----------------------------

base_path="/xmmarray/xmmscratch/goehler/RXJ1940-1025/HOBART"

; ------------------------------------------------------------

if n_elements(reftime) eq  0 then reftime=52000.D0

read_xy,base_path+"/tt.14.corrected",data,x_col=9,y_col=2, n_head=1,n_cols=14


; time in MJD, in respect of zero point:
time=reform(data[0,*])
rate=exp(-reform(data[1,*])/2.5)


; shift to helio center if necessary:
if keyword_set(helio) then begin
    time=rxj_helio(time,/mjd)
    print, "Helio center correction!"
endif

; shift to bary center if necessary:
if keyword_set(bary) then begin
    time=rxj_bary(time,/mjd)
    print, "Bary center correction!"
endif


; shift by reference time:
time=time - reftime


end

