; readxte.pro -reads xte data for RX J1940.1-1025
; $Log: readxte.pro,v $
; Revision 1.2  2003/04/24 13:04:43  goehler
; fix: look for all observations, even with non-numerical directory name
;
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;

pro readxte, time,rate,error=error, reftime=reftime,$
             propid=propid,helio=helio,bary=bary,binning=binning




; READ PARTS OF OBSERVATION:
;------------------------------------------------------------



; ============================= GENERAL INFO =================================:

; binning to be used:
if n_elements(binning) eq 0 then binning=1

; path of rxte observations:
base_path="/xtescratch/goehler/"

;; default proposal id:
IF n_elements(propid) EQ 0 THEN propid = "P60007"


; ============== CREATE FILE LIST ======================: 


spawn,"ls -1d "+base_path+propid+"/[0-9][0-9]-[0-9][0-9]-*",dirs

FOR i = 0,n_elements(dirs)-1 DO BEGIN 
    ;; remove leading path:
    dirs[i] = (stregex(dirs[i],'.*/([^/]*)',/subexpr,/extract))[1]
ENDFOR 


; ============================= OBS INFO =================================:


print, "Processing at:", base_path+propid
print,dirs
readxtedata,time,rate,path=base_path+propid, $
          dirs=dirs, /exclusive,/faint,/top,/nopcu0,err=error,bary=bary,binning=binning


if keyword_set(helio) then begin
    time=rxj_helio(time,/mjd)
    print, "Helio center correction!"
ENDIF

if keyword_set(bary) then begin
    print, "Bary center corrected!"
endif

if n_elements(reftime) ne 0 then time=time-reftime

end 

