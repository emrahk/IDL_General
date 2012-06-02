pro raw_plot,mi,ma,events,energie,zeile,spalte,time,sekbruch,sekunde,$
             count,rawcount,rawid,numti,numco,posfehl,timefehl,filename,z,quadrant,ccd,$
             ghost=ghost,ps=ps,chatty=chatty,comment=comment
   
   IF (keyword_set(ps)) THEN BEGIN 
       ps = 1
   END ELSE BEGIN 
       ps = 0
   END 
   
   IF (keyword_set(ps)) THEN BEGIN 
       chatty = 1
   END ELSE BEGIN 
       chatty = 0
   END
   
;   ma=700                       ; for test plot only first 700 events
;fr = 18432000d0  ;18 Mhz-Quarz
;fr = 20000000d0  ;20 Mhz-Quarz   
   fr = 25000000d0              ;25 Mhz-Quarz    zeiteinheit=fr/512
   zeiteinheit=fr/512
   ze = 1d/zeiteinheit
   loadct,13

   plotfile=filename+'_rQ'+STRTRIM(quadrant, 2)+'.ps'
 
   IF (chatty EQ 1) THEN BEGIN 
       print,'% PLOTRAW: Working on rawdata plot for Quadrant ',quadrant,' ...'
       IF (ps EQ 1) THEN BEGIN 
           print,'% PLOTRAW: Printing to file: ',plotfile
       END
   END 

   IF (ps EQ 1) THEN BEGIN      ; plot to ps-file
       set_plot,'ps'
       device,xsize=26.5,ysize=17,/landscape,/color,yoffset=29,xoffset=0, $
         file=plotfile,set_font='Times',/TT_FONT
   END ELSE BEGIN 
       set_plot,'x'
   END 
   
   zzw=where(time GE mi AND time LE ma,zw)
   IF zw GE 1 THEN !p.multi=[0,1,4] ELSE !p.multi=[0,1,3]
   za=min(zeile(mi:ma))
   zn=max(zeile(mi:ma))-za
   plot,zeile,title='Line Content (blue: Time Word; green: Counter)',$
     psym=10, xtitle='Data Word No.',ytitle='Line No.',$
     xrange=[mi,ma],charsize=3,/xstyle,/ystyle
   FOR i=long(0),numti-1 DO oplot,[time(i),time(i)],$
     [0,199],color=25,thick=2
   FOR i=long(0),numco-1 DO oplot,[count(i),count(i)],[0,199],$
     color=42,thick=2
   IF rawcount NE 1 AND ma-mi LE 100 THEN BEGIN
       rel=where(events GT mi AND events LT ma)
       xyouts,-.022*(ma-mi)+mi,za+.1*zn,'CCD-ID:',color=120,$
         charsize=1.5,/data,alignment=1
       xyouts,events(rel),za+.1*zn,strtrim(ccd(events(rel)),1),$
         color=120,charsize=1.5,/data,alignment=.5
   ENDIF
   plot,spalte,title='Column Content (blue: Time Word; green: Counter)'$
     ,/xstyle,xtitle='Data Word No.',ytitle='Column No.',xrange=[mi,ma],$
     /ystyle,charsize=3,psym=10
   FOR i=long(0),numti-1 DO oplot,[time(i),time(i)],[0,63],$
     color=25,thick=2
   FOR i=long(0),numco-1 DO oplot,[count(i),count(i)],[0,63],color=42,$
     thick=2
   erid=where(events GE mi AND events LE ma,erct)
   IF erct GT 0 THEN BEGIN
       emn=min(energie(events(erid)))
       emm=max(energie(events(erid)))
   ENDIF ELSE BEGIN
       emn=0 & emm=0
   ENDELSE
   plot,energie,title='Energy Content (blue: Time Word; green: Counter)'$
     ,xtitle='Data Word No.',charsize=3,ytitle='Energy',xrange=[mi,ma],$
     yrange=[emn,emm],/ystyle,/xstyle,psym=10
   FOR i=long(0),numti-1 DO oplot,[time(i),time(i)],[emn,emm],$
     color=25
   FOR i=long(0),numco-1 DO oplot,[count(i),count(i)],[emn,emm],color=42,$
     thick=2
   IF zw GE 1 THEN BEGIN
       plot,time,sekunde+sekbruch*ze,title='Time Content',$
         xtitle='Data Word No.',charsize=3,$
         ytitle='Time',xrange=[mi,ma],/ystyle,/xstyle,psym=1
       oplot,time,sekunde+sekbruch*ze,line=1
   ENDIF
   
   ;; print time and counter error diagonal on page
   IF posfehl GT 0 THEN xyouts,200,8000,orientation=23,color=120,/device,$
     'POSITION COUNTER ERROR !!',charthick=5,charsize=7
   IF timefehl GT 0 THEN xyouts,200,2000,orientation=23,color=120,/device,$
     'TIME WORD ERROR !!',charthick=5,charsize=7
      
   ;; print file, count and ccd information
   
   IF rawcount GT 6 THEN im = 5 ELSE im = rawcount-1
   
   FOR i=0, im DO BEGIN         ; print # events in CCDs 0-5
       xyouts,300,20000-i*500,'CCD ' + STRTRIM(rawid(i),2) + ': ' + STRTRIM(z(rawid(i)),2)$
         + ' Events',/device,charsize=1.1
   END
   
   IF rawcount GT 6 THEN BEGIN  ; print # events in CCD 6-11
       im=rawcount-1
       FOR i=6, im DO BEGIN 
           xyouts,5300,20000-(i-6)*500,'CCD ' + STRTRIM(rawid(i),2) + ': ' + STRTRIM(z(rawid(i)),2)$
             + ' Events',/device,charsize=1.1
       END
   ENDIF        

   xyouts,26000,20000,'Raw Data of File '+filename,/device,alignment=1,charsize=1.5
   xyouts,15000,19500,'Quadrant : '+STRTRIM(quadrant, 2),/device,charsize=1.1
   xyouts,15000,19000,'Number of timewords:       ' + STRTRIM(numti,2),/device,charsize=1.1
   xyouts,15000,18500,'Number of Count Info Data: ' + STRTRIM(numco,2),/device,charsize=1.1
   xyouts,15000,18000,'Dataword Range from ' + STRTRIM(mi,2) + ' to ' + STRTRIM(ma,2),/device,charsize=1.1
  
   IF (ps EQ 1) THEN BEGIN      ; close ps device if neccessary
       device,/close
       set_plot,'x'   
   END 
   
   IF (keyword_set(comment)) THEN BEGIN ; print optional comment
       xyouts,300,17500,'Comments : '+comment,/device,charsize=1.1
   END 
   
   IF (keyword_set(ghost) AND ps EQ 1) THEN BEGIN ; show ps-file with ghostview if seleted
       spawn, 'ghostview -swap -a4 '+plotfile,/sh
   ENDIF
   
   !p.multi=0
END

;+
; NAME:
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
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; V1.0 M. Kuster first initial version
; V1.1 M. Kuster sepearted file I/O from plot routine
; V1.2 M. Kuster solved problem with nct !!
;-
PRO plotraw,rawdata,outfile,quadrant,chatty=chatty,ps=ps,ghost=ghost,fileout=fileout,$
            energie=energie,zeile=zeile,spalte=spalte,time=time,$
            sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
            numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
            enbit=enbit
   
   IF (keyword_set(chatty)) THEN BEGIN 
       chatty = 1
   END ELSE BEGIN 
       chatty = 0 
   END 
   
   IF (keyword_set(fileout)) THEN BEGIN
       fileout=1
   END ELSE BEGIN
       fileout=0
   END
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'% PLOTRAW: Working on rawdata plot for Quadrant ',quadrant,' ...'
   END 

   IF (rawdata[0] EQ -1) THEN BEGIN 
       print,'% PLOTRAW: WARNING no Science-Data in Quadrant '+STRTRIM(quadrant,2)+' !!!'
       return
   ENDIF 
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'% PLOTRAW: Removing Count-Info Data ...'
   ENDIF 
   
   ;; Set Default values
   rawcid=0
   mi = 0
   spekstack = 0l
   ma = 1000000l
;fr = 18432000d0  ;18 Mhz-Quarz
;fr = 20000000d0  ;20 Mhz-Quarz   
   fr = 25000000d0              ;25 Mhz-Quarz 
   zeiteinheit=fr/512
   ze = 1d/zeiteinheit
   dw = 'Data Word No. '
   ys=750
   cmoffset=256
   anz=7000
   
   anf=0
   evanf=anf
   anzahl=long(anz/30.)
   
   ;; prepare output for Errors
   at = ' at No. '
   fr = 's from No. '
   sn = STRARR(6)
   sn(0) = ' two Time Words '
   sn(1) = ' missing Time Word'
   sn(2) = ' Line Counter back jump'
   sn(3) = ' Column Counter back jump'
   sn(4) = ' Seconds Counter back jump'
   sn(5) = ' Fr. Sec. Counter back jump'   
      
   ;;definition for fileio streams
;   ZFEHLER = 5
;   EFEHLER = 6
;   KURZINFO= 7
   
   ;;---------------------------------------- geteventdata ------------------------------------
;   geteventdata,rawdata,256,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
;     sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
;     numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
;     enbit=enbit,/chatty
   ;;---------------------------------------- END ------------------------------------

   mm=n_elements(energie)
   
   IF ma GE mm THEN ma=mm-1
   
   loadct, 13

   za=min(zeile(events))        ;min zeile
   zn=max(zeile(events))-za     ;norm of zeile
   
   ;; Set error counters to zero 
   ztfehl=0
   zwfehl=0
   skfehl=0
   brfehl=0
   
   sekfehl=-1
   zwortfehl=-1
   bruchfehl=-1
   
   ;; check for time errors
   IF numti GE 2 THEN BEGIN 
       zeit=transpose(reform([sekunde,sekbruch*ze],numti,2)) ; generate zeit(2:*) out of sekunde and sekbruch
       zeit=shift(zeit,0,-1)-zeit ; calculate delta t of two timewords
       zeit=zeit(*,0:numti-2)   ; forget last 2 times 
       bruchfehl=where(zeit(0,*) EQ 0 AND zeit(1,*) LE 0,brfehl) ; wenn sekunde=0 und bruchfehler<0 -> Fehler 
       sekfehl=where(zeit(0,*) LT 0,skfehl) ; wenn sekunde<0 -> Fehler
       zwortfehl=where((shift(time,-1)-time) EQ 1,zwfehl) ; wenn delta position der Zeitworte = 1 -> Fehler zwei nacheinander
   ENDIF
   
   zid=bytarr(mm)+1             ; erzeuge array mit indexen von 1 bis mm-1
   IF numco GT 1 THEN zid(count)=0 ; setze alle indizes mit countern auf 0
   nct=where(zid)               ; array nct mit positionen ohne counter
   
   ;;erzeuge zz(4,nct) aus zeile spalte ccd und energiebit
   ;; alle counter sind jetzt drausen -> delta zz bestimmen
   zz=fix(transpose(reform([zeile,spalte,ccd,enbit],mm,4)))
   zz=zz(*,nct)                 ; warum ???
   zz=shift(zz,0,-1)-zz         ; delta zz berechnen
   zz=zz(*,0:mm-numco-2)        ; warum mm-numco-2 ?
   
   spaltfehl=where(zz(0,*) EQ 0 AND zz(2,*) EQ 0 AND zz(3,*) EQ 0 $ 
   ;; wenn delta spalte=0, ccd identisch, daten=events ->fehler
                   AND enbit(nct(0:mm-numco-2)) EQ 0 AND zz(1,*) LE 0,spfehl)
   zeilfehl=where(zz(2,*) EQ 0 AND zz(3,*) EQ 0 AND enbit(nct(0:mm-numco-2)) $
                  EQ 0 AND zz(0,*) lt 0,zfehl) ; wenn ccd identisch, daten=events, ??, delta zeile<0 ->fehler
   zeitfehl=where(zz(2,*) LT 0 AND zz(3,*) EQ 0 AND enbit(nct(0:mm-numco-2)) $
                  EQ 0,ztfehl)  ; wenn delta ccd <0, delta enbit=0, ?? ->fehler
   zzw=where(time GE mi AND time LE ma,zw)
   
   IF zw GE 1 THEN !p.multi=[0,1,4] ELSE !p.multi=[0,1,3]
   
   fehl = lonarr(6,2) 
   fehl(0,0) = zwfehl & IF zwfehl GT 0 THEN fehl(0,1) = time(zwortfehl(0))
   fehl(1,0) = ztfehl & IF ztfehl GT 0 THEN fehl(1,1) = nct(zeitfehl(0)) ; warum ???
   fehl(2,0) = zfehl  & IF zfehl  GT 0 THEN fehl(2,1) = nct(zeilfehl(0)) ; warum ??? nct(zeil...)=zeilfehl
   fehl(3,0) = spfehl & IF spfehl GT 0 THEN fehl(3,1) = nct(spaltfehl(0))
   fehl(4,0) = skfehl & IF skfehl GT 0 THEN fehl(4,1) = time(sekfehl(0)+1)
   fehl(5,0) = brfehl & IF brfehl GT 0 THEN fehl(5,1) = time(bruchfehl(0)+1)
   fehl = STRTRIM(STRING(fehl), 2)
   
   IF cmoffset EQ 0 THEN BEGIN
       
       sp = [BINDGEN(64),BINDGEN(32)+32b]
       zei = [REPLICATE(100, 32), REPLICATE(199, 64)]
       cc = REBIN(BINDGEN(3), 96)
       zeit = zeit(0,*) + zeit(1,*)
       zeit = REFORM(zeit, numti-1)
       tcd = ccd(events)
       tsp = spalte(events)
       tze = zeile(events)
       sh = tsp(0)
       tcd = tcd(64-sh:*)
       tsp = tsp(64-sh:*)
       tze = tze(64-sh:*)
       ner = N_ELEMENTS(tcd)
       sp = REFORM(REBIN(sp, 96l, LONG(ner/96.)+1), 96l*(LONG(ner/96.)+1))
       sp = BYTE(sp(0:ner-1))
       tra = WHERE(tsp-sp, trasp)
       zei = REFORM(REBIN(zei, 96l, LONG(ner/96.)+1), 96l*(LONG(ner/96.)+1))
       zei = BYTE(zei(0:ner-1))
       tra = WHERE(tze-zei, traze)
       cc = REFORM(REBIN(cc, 96l, LONG(ner/96.)+1), 96l*(LONG(ner/96.)+1))
       cc = BYTE(cc(0:ner-1)) + MIN(tcd)
       tra = WHERE(tcd-cc, tracd)
       tra = WHERE(zeit LT .1414d0 OR zeit GT .1416d0, trazt)
       print, 'Spaltenfehler: ', trasp
       print, 'Zeilenfehler: ', traze
       print, 'CCD-ID-Fehler: ', tracd
       print, 'Zeit-Fehler: ', trazt
   ENDIF 
   
   ;; Get number of events in CCDs ------------------------------------------
   his = WHERE(ccd(events) NE ccd(events(0)), wccd)
   IF wccd GT 0 THEN his = HISTOGRAM(ccd(events), OMIN=ccdmin, OMAX=ccdmax) $
   ELSE BEGIN
       ccdmin = ccd(events(0))
       ccdmax = ccdmin
       his = N_ELEMENTS(ccd(events))
   ENDELSE       
   
   IF ccdmax GT 11 THEN BEGIN
       his = his(0:11-ccdmin)
       ccdmax = 11
   ENDIF
   ;;------------------------------------------------------------------------
   
   z = lonarr(12)
   z(ccdmin:ccdmax) = his
   rawid = WHERE(z, rawcount)   
   IF rawcount GT 6 THEN im = 5 ELSE im = rawcount-1

   ;; start output to file and screen
   IF (fileout EQ 1) THEN BEGIN ; open outputfiles
       openw,ZFEHLER ,outfile+'_timerrors'+STRTRIM(quadrant,2),/get_lun
       openw,EFEHLER ,outfile+'_eventerrors'+STRTRIM(quadrant,2),/get_lun
;       printf,ZFEHLER,outfile ; for dietmar compatibility
;       printf,ZFEHLER,''
;       printf,EFEHLER,outfile ; for dietmar compatibility
;       printf,EFEHLER,''
   END
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'% PLOTRAW: Rawdata of File: '+outfile ; Print filename of raw plot
       FOR i=0, im DO BEGIN 
           print,'% PLOTRAW: CCD ' + STRTRIM(rawid(i),2) + ': ' + STRTRIM(z(rawid(i)),2) + ' Events'
       END
       
       IF rawcount GT 6 THEN BEGIN 
           im=rawcount-1
           FOR i=6, im DO BEGIN 
               print,'% PLOTRAW: CCD ' + STRTRIM(rawid(i),2) + ': ' +STRTRIM(z(rawid(i)),2) + ' Events'
           END
       ENDIF        
       print,'% PLOTRAW: Number of timewords:           ' + STRTRIM(numti,2)
       print,'% PLOTRAW: Number of Count Info Data:     ' + STRTRIM(numco,2)
       print,'% PLOTRAW: Dataword Range from            ' + STRTRIM(mi,2) + ' to ' + STRTRIM(ma,2)
   ENDIF 
   
   IF zwfehl GT 1 THEN st = 's' ELSE st = ''
   IF zwfehl GT 1 THEN st1 = 'from No. ' ELSE st1 = ' at No. '
   
   posfehl = zfehl + spfehl     ; Position ERRORS
   timefehl = ztfehl + zwfehl + skfehl + brfehl ; Time ERRORS
   
   ;; Output ERRORS
   Head='% PLOTRAW: ERROR in '+ outfile

   IF (chatty EQ 1) THEN BEGIN 
       j=n_elements(zwortfehl)
       IF ((j) GE 1) AND (zwortfehl(0) GE 0) THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Timeword ERROR at Position: ' + STRTRIM(time(zwortfehl(i-1)),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,ZFEHLER,'time: xxxxx.xxxxx '+quadrant+'Timeword ERROR at Position: ' + STRTRIM(time(zwortfehl(i-1)),2)
                   printf,ZFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' TWO TIME WORDS Frame-Number: ' $
                     + STRTRIM(time(zwortfehl(i-1)),2)
               END 
           END 
       ENDIF 
       
       j=n_elements(zeitfehl)
       IF ((j) GE 1) AND (zeitfehl(0) GE 0) THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Time ERROR at Position: ' + STRTRIM(nct(zeitfehl(i-1)),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,ZFEHLER,'time: xxxxx.xxxxx '+'Time ERROR at Position: ' + STRTRIM(nct(zeitfehl(i-1)),2)
                   printf,ZFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' TWO TIME WORDS Frame-Number: ' $
                     + STRTRIM(nct(zeitfehl(i-1)),2)
              END               
           END 
       ENDIF 
       
       j=n_elements(zeilfehl)
       IF ((j) GE 1) AND  (zeilfehl(0) GE 0)THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Line ERROR at Position: ' + STRTRIM(nct(zeilfehl(i-1)),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,EFEHLER,'time: xxxxx.xxxxx '+'Zeilen ERROR at Position: ' + STRTRIM(nct(zeilfehl(i-1)),2)
                   printf,EFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' LINE COlUMN COUNTER BACKJUMP Frame-Number: ' $
                     + STRTRIM(nct(zeilfehl(i-1)),2)                  
               END   
           END 
       ENDIF
       
       j=n_elements(spaltfehl)
       IF ((j) GE 1) AND (spaltfehl(0) GE 0) THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Column ERROR at Position: ' + STRTRIM(nct(spaltfehl(i-1)),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,EFEHLER,'time: xxxxx.xxxxx '+'Spalten ERROR at Position: ' + STRTRIM(nct(spaltfehl(i-1)),2)
                   printf,EFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' LINE COlUMN COUNTER BACKJUMP Frame-Number: ' $
                     + STRTRIM(nct(spaltfehl(i-1)),2)
               END  
           END 
       ENDIF       
       
       j=n_elements(sekfehl)
       IF ((j) GE 1) AND (sekfehl(0) GE 0) THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Seconds ERROR at Position: ' + STRTRIM(time(sekfehl(i-1)+1),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,ZFEHLER,'ZEIT !! '+'Sekunden ERROR at Position: ' + STRTRIM(time(sekfehl(i-1)+1),2)
                   printf,ZFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' SECONDS ERROR Frame-Number: ' $
                     + STRTRIM(time(sekfehl(i-1)+1),2)
               END 
           END 
       ENDIF       
       
       j=n_elements(bruchfehl)
       IF ((j) GE 1) AND (bruchfehl(0) GE 0) THEN BEGIN 
           FOR i=1,j DO BEGIN 
               print,Head+' Fraction ERROR at Position: ' + STRTRIM(time(bruchfehl(i-1)+1),2)
               IF (fileout EQ 1) THEN BEGIN
;                   printf,ZFEHLER,'ZEIT !! '+'Bruchteil ERROR at Position: ' + STRTRIM(time(bruchfehl(i-1)+1),2)
                   printf,ZFEHLER,'time: xxxxx.xxxxx Q:'+STRTRIM(quadrant,2)+' FRACTIONS ERROR Frame-Number: ' $
                     + STRTRIM(time(bruchfehl(i-1)+1),2)
               END 
           END 
       ENDIF       
       
       
       IF fehl(0,0) GT 0 THEN BEGIN 
           print,'% PLOTRAW: ERROR '+fehl(0,0)+' time'+st+sn(0)+st1+fehl(0,1)
       ENDIF 
       
       FOR s = 1,5 DO BEGIN
           IF fehl(s,0) GT 1 THEN st = fr ELSE st = at
           IF fehl(s,0) GT 0 THEN BEGIN 
               print,'% PLOTRAW: ERROR '+fehl(s,0)+sn(s)+st+fehl(s,1)
           ENDIF 
       ENDFOR
       IF ztfehl+zwfehl+zfehl+spfehl+skfehl+brfehl EQ 0 THEN BEGIN 
           print,'% PLOTRAW: No Abbreviations detected !'
           IF (fileout EQ 1) THEN BEGIN
               printf,ZFEHLER,'No Abbreviations detected !'
               printf,EFEHLER,'No Abbreviations detected !'
           END            
       ENDIF 
   ENDIF 
   
   IF (fileout EQ 1) THEN BEGIN ; close all outputfiles
       free_lun,ZFEHLER
       free_lun,EFEHLER
   END
   
   ;; plot data to file or screen 
   IF (keyword_set(ps)) THEN BEGIN 
       IF (keyword_set(ghost)) THEN BEGIN 
           raw_plot,mi,ma,events,energie,zeile,spalte,time,sekbruch,sekunde,count,rawcount,rawid,numti,numco,$
             posfehl,timefehl,outfile,z,quadrant,ccd,/ps,/ghost
       END ELSE BEGIN
           raw_plot,mi,ma,events,energie,zeile,spalte,time,sekbruch,sekunde,count,rawcount,rawid,numti,numco,$
             posfehl,timefehl,outfile,z,quadrant,ccd,/ps
       END 
   END ELSE BEGIN
       raw_plot,mi,ma,events,energie,zeile,spalte,time,sekbruch,sekunde,count,rawcount,rawid,numti,numco,$
         posfehl,timefehl,outfile,z,quadrant,ccd
   END 
END 


























