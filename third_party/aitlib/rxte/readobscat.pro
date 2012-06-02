;;
;; Read an XTE human-readable obscat
;;SLEW doesn't work yet!
PRO readobscat,file,slew=slew,occult=occult,saa=saa,good=good,mjd=mjd, $
               verbose=verbose,cass=cass

   maxent=5000

   slew=dblarr(2,maxent)   & slewcnt=0
   occult=dblarr(2,maxent) & occcnt =0
   saa=dblarr(2,maxent)    & saacnt =0
   good=dblarr(2,maxent)   & goodcnt=0

   slew(*)=-1.
   occult(*)=-1.
   saa(*)=-1.
   good(*)=-1.
   
   nomode='         '
   modes=['  EVENTS:','GOODTIME:']
   skip=-1
   event=0
   goodm=1
   mode=skip
   FOR i=0,n_elements(file)-1 DO BEGIN 
       readfil=file(i)
       IF (NOT file_exist(readfil)) THEN BEGIN 
           IF NOT keyword_set(cass) THEN BEGIN
              readfil='/xtearray/timelines/obscat/'+file(i)
              IF (NOT file_exist(readfil)) THEN BEGIN 
                  readfil='/usr/local/xte/obscat/'+file(i)
              ENDIF 
            ENDIF ELSE BEGIN
              reads,strmid(file(i),5,4),day
              wk=(fix(day)-755)/7
              wk=strtrim(string(wk),2)
              readfil='/home/xte/logs/week'+wk+'/'+file(i)
	    ENDELSE
       ENDIF 
       IF (file_exist(readfil)) THEN BEGIN 
           IF (keyword_set(verbose)) THEN print, 'READING '+readfil
           openr,unit,readfil,/get_lun
       END ELSE BEGIN 
           print,'WARNING: Obscat '+file(i)+' does not exist'
           unit=-1
       END 
       IF (unit NE -1) THEN BEGIN 
           WHILE NOT eof(unit) DO BEGIN 
               a=''
               readf,unit,a
               modstr=strmid(a,0,9)
               IF (modstr NE nomode) THEN mode=where(modstr EQ modes)
               mode=mode(0)
           
               IF (mode EQ event) THEN BEGIN 
                   what=strtrim(strmid(a,9,14),2)
                   when=double(strmid(a,34,10))
                   IF (what EQ 'start_slew') THEN BEGIN 
                       slew(0,slewcnt)=when
                   END
                   IF (what EQ 'end_slew') THEN BEGIN 
                       slew(1,slewcnt)=when 
                       slewcnt=slewcnt+1
                   END 
                   IF (what EQ 'in_occult') THEN BEGIN 
                       occult(0,occcnt)=when
                   END 
                   IF (what EQ 'out_occult') THEN BEGIN 
                       occult(1,occcnt)=when
                       occcnt=occcnt+1
                   END 
                   IF (what EQ 'in_saa') THEN BEGIN 
                       saa(0,saacnt)=when
                   END 
                   IF (what EQ 'out_saa') THEN BEGIN 
                       saa(1,saacnt)=when
                       ;;... hack for missing 'in_saa'-tag in some obscats
                       IF (saa(0,saacnt) EQ -1.) THEN BEGIN 
                           saa(0,saacnt)=saa(1,saacnt)
                       ENDIF 
                       saacnt=saacnt+1
                   END 
               ENDIF 
               IF (mode EQ goodm) THEN BEGIN 
                   when1=double(strmid(a,20,10))
                   when2=double(strmid(a,45,10))
                   good(0,goodcnt)=when1
                   good(1,goodcnt)=when2
                   goodcnt=goodcnt+1
               ENDIF 
           END 
           free_lun,unit
       END 
   END 
   IF (slewcnt GT 0) THEN slew=slew(*,0:slewcnt-1)
   IF (occcnt GT 0) THEN occult=occult(*,0:occcnt-1)
   IF (saacnt GT 0) THEN saa=saa(*,0:saacnt-1)
   IF (goodcnt GT 0) THEN good=good(*,0:goodcnt-1)

   IF (keyword_set(mjd)) THEN BEGIN 
       IF (slewcnt GT 0) THEN slew=met2jd(slew,/mjd)
       IF (occcnt GT 0) THEN occult=met2jd(occult,/mjd)
       IF (saacnt GT 0) THEN saa=met2jd(saa,/mjd)
       IF (goodcnt GT 0) THEN good=met2jd(good,/mjd)
   ENDIF 
END 
