PRO geteventdata,rawdata,cmoffset,load,reddata=reddata,energie=energie,zeile=zeile,$
                 spalte=spalte,time=time,$
                 sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
                 numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
                 enbit=enbit,chatty=chatty,noise=noise
;+
; NAME: geteventdata
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;               Do not use getcountinfo just before this function
;               Do not use for offset, noise or dslin maps
;               Not split event correction
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
; V1.0 M. Kuster first initial version
; V1.2 M. Kuster fixed bug: program crashed when rawdata contains no
;                science data e.g. rawdata=-1
; V1.3 M. Kuster splitevent corrrection added   
; V1.4 M. Kuster Added keyword noise for Noise-Maps   
;-   
   IF (keyword_set(chatty)) THEN BEGIN
       chatty=1
   END ELSE BEGIN
       chatty=0
   END
   
;fr = 18432000d0  ;18 Mhz-Quarz
;fr = 20000000d0  ;20 Mhz-Quarz
   
   fr = 25000000d0              ;25 Mhz-Quarz   
   zeiteinheit=fr/512
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'% GETEVENTDATA: Removing Count-Info Data ...'
   ENDIF 
   
   IF (rawdata[0] EQ -1) THEN BEGIN 
       print,'% GETEVENTDATA: WARNING No Science Data found !!!'
       reddata=-1
       return
   ENDIF
   
   cz=n_elements(rawdata)-1
   enbit=byte(ishft(rawdata,-30))
   count=where(enbit eq 1,numco)
 
   IF numco GT 0 AND load EQ 1 THEN BEGIN 
       WHILE count(numco-1) EQ cz DO BEGIN
           count=count(0:numco-2)
           rawdata=rawdata(0:cz-1)
           enbit=enbit(0:cz-1)
           numco=numco-1
           cz=cz-1
       ENDWHILE
       WHILE count(0) EQ 0 AND numco GT 1 DO BEGIN 
           count=count(1:*)-1
           rawdata=rawdata(1:*)
           enbit=enbit(1:*)
           numco=numco-1
       ENDWHILE 
       
       id=bytarr(n_elements(rawdata))+1
       id(count)=0
       evid=where(id)
       rawdata=rawdata(evid)    ; nur noch Zeit- und Energieworte !!! (keine Counter)
                                
       enbit=enbit(evid)
   ENDIF 
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'% GETEVENTDATA: Extracting data ...'
   ENDIF 
   
   evid=0
   events=where(enbit eq 0,numev)
   time=where(enbit ge 2,numti)
   
   IF numti NE 0 THEN BEGIN
       ;; Erstes Event darf kein Zeitwort sein!!!      
       WHILE time(0) EQ 0  AND load EQ 1 DO BEGIN 
           enbit=enbit(1:*)           
           rawdata=rawdata(1:*)
           time=time(1:*)-1
           numti=numti-1
           events=events-1
       ENDWHILE
       timewords=rawdata(time)
       sekunde=fix(ishft(timewords,-16) and '00007fff'xl)
       sekbruch=long(timewords and '0000ffff'xl)
       if load eq 1 then begin
           evsek=lonarr(numev)
           evsbruch=lonarr(numev)
           evsek(0:time(0)-1)=replicate(sekunde(0),time(0))
           evsbruch(0:time(0)-1)=replicate(sekbruch(0),time(0))
           t4=time(0)
           FOR tt=long(1),numti-1l DO BEGIN
               t1=time(tt)
               t2=time(tt-1)+1
               t3=t1-t2
               IF t3 GT 0 THEN BEGIN
                   evsek(t4:t4+t3-1)=replicate(sekunde(tt),t3)
                   evsbruch(t4:t4+t3-1)=replicate(sekbruch(tt),t3)
               ENDIF
               t4=t4+t3   
           ENDFOR
           IF n_elements(enbit) GT time(numti-1)+1 THEN BEGIN
               evsek(t4:*)=replicate(sekunde(numti-1),n_elements(enbit)-1-time(numti-1))
               evsbruch(t4:*)=replicate(sekbruch(numti-1),n_elements(enbit)-1-time(numti-1))
           ENDIF
       ENDIF 
  ENDIF
  
  IF load EQ 1 THEN BEGIN 
      enbit=0
      rawdata=rawdata(events)
      eventpos=events
      events=0
  ENDIF 
  
  IF (keyword_set(noise)) THEN BEGIN
      ccd=-1
      energie=sqrt(float((rawdata) and '0000ffff'xl)/100.)
      spalte=byte(ishft(rawdata,-16) AND '0000003f'xl)
      zeile=byte(ishft(rawdata,-22))
  ENDIF ELSE BEGIN 
      ccd=fix(ishft(rawdata,-14) AND '00000003'xl)*3+fix(ishft(rawdata,-12) AND '00000003'xl)
      energie=fix(rawdata AND '00000fff'xl)-cmoffset
      spalte=byte(ishft(rawdata,-16) AND '0000003f'xl)
      zeile=byte(ishft(rawdata,-22))
  ENDELSE 
  IF max(zeile) GE 200b THEN zeile(where(zeile GT 199b))=199b
  rawdata=0
;; Calculate rate
  if load eq 1 then begin 
 
      IF numti NE 0 THEN BEGIN
          zdiff=sekunde(numti-1)-sekunde(0)+sekbruch(numti-1)/zeiteinheit-sekbruch(0)/zeiteinheit
          IF zdiff GT 1 THEN rate=float(numev)/zdiff ELSE rate=0
          rate=long(rate*100+.5)/100.
      ENDIF
      
      IF (chatty EQ 1) THEN BEGIN 
          print,'% GETEVENTDATA: Generating data array ...'
      ENDIF
  
      
      reddata={data,line:long(0),column:long(0),energy:double(0),sec:long(0),$
              secbruch:long(0),ccd:byte(0),split:long(0),time:double(0)}
   
      ;; Make data-array according to results
      ;; has to be changed to a structure to be consistant 
      ;; with cte and gain correction and to save memory !!

      reddata=replicate(reddata,numev)
      reddata(*).line=zeile
      reddata(*).column=spalte
      reddata(*).energy=energie
      IF numti NE 0 THEN BEGIN
          fr = 25000000d0       ;25 Mhz-Quarz    
          zeiteinheit=fr/512d0
          
          reddata(*).sec=evsek          
          reddata(*).secbruch=evsbruch
          reddata.time=reddata.sec+reddata.secbruch/zeiteinheit
      ENDIF 
      
;      reddata(5,*)=ccd
      reddata(*).ccd=ccd
      
;      reddata(6,*)=-1 ;; no split-event correction so far
      reddata(*).split=-1
  ENDIF 
END



