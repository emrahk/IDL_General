; readsso.pro -reads Siding Springs Observatory data for RX J1940.1-1025
; $Log: readsso.pro,v $
; Revision 1.2  2003/04/03 07:57:43  goehler
; update for header reading
;
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;

pro readsso, time,rate, reftime=reftime,$
              helio=helio,bary=bary,refstar=refstar,uband=uband


; ------------------  global defs -----------------------------

base_path="/xmmscratch/rexer/Logs/lc"

if n_elements(refstar) eq 0 then refstar= 1
filename1=base_path+"/RXJ1940_R_Night_A_vsREf"+$
         STRTRIM(STRING(refstar),2)+"_engl.dat"

filename2=base_path+"/RXJ1940_U_Night_all nights_vsREf"+$
         STRTRIM(STRING(refstar),2)+"_engl.dat"

; ------------------------------------------------------------


if n_elements(reftime) eq  0 then reftime=52106.D0

if not keyword_set(uband) then $
  read_xy,filename1,data, x_col=1,y_col=3,n_cols=3, n_head=6$ ;erzeugt mit write_final 
else $  ; time 2 of U-filter data:
  read_xy,filename2,data, x_col=1,y_col=3,n_cols=3, n_head=6 ;erzeugt mit write_final 



; time in MJD, in respect of zero point:
time=reform(data[0,*])
rate=reform(data[1,*])

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

