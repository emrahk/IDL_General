PRO jdtick,jd,level,parm,lgyrtk=lgyrtk,_extra=extra
  IF (jd GE parm.jdmin AND jd LE parm.jdmax) THEN BEGIN 
    pos=convert_coord(jd-parm.jd0,0.,/data,/to_normal)
    IF keyword_set(lgyrtk) THEN begin
      plots,[pos(0),pos(0)],[2*parm.dash(0)-parm.dash(level),parm.dash(level)], $
        /normal,_extra=extra    ;,/clip,noclip=0
    enDIF ELSE BEGIN
      plots,[pos(0),pos(0)],[parm.dash(0),parm.dash(level)], $
        /normal,_extra=extra    ;,/clip,noclip=0
    endelse
   ENDIF 
END 

PRO jdlabel,jd1,jd2,text,level,parm,_extra=extra
   IF (level LE 1) THEN return
   IF (parm.nolabel EQ 1) THEN return

   ;; ... don't label if interval outside visible range
   IF (jd2 LE parm.jdmin) THEN return 
   IF (jd1 GE parm.jdmax) THEN return

   ;; ... put labels only within visible range
   jjd1=jd1
   jjd2=jd2
   IF (jjd1 LT parm.jdmin) THEN jjd1=parm.jdmin
   IF (jjd2 GT parm.jdmax) THEN jjd2=parm.jdmax

   tex=strtrim(text,2)


   ;; Display string only if string fits into range
   IF (jjd1 NE jjd2) THEN BEGIN 
       po=convert_coord([0.,parm.size(level)*strlen(tex)*!d.x_ch_size], $
                        [0.,0.],/device,/to_data)
;;doesn't work right yet
       IF ( (po(0,1)-po(0,0))/(jjd2-jjd1) GT 1.2) THEN return
   ENDIF 

   pos=convert_coord((jjd1+jjd2)/2.-parm.jd0,0.,/data,/to_normal)
   xyouts,pos(0),parm.po(level),tex,/normal,/noclip, $
     alignment=0.5,size=parm.size(level),_extra=extra
END 



PRO jwdateaxis,upper=upper,nolabel=nolabel,mjd=mjd,noyear=noyear, $
               zeropoint=zeropoint,stretch=stretch,charsize=charsize, $
               fontscale=fontscale,longyr=longyr, $
               _extra=extra
;+
; NAME:
;            jwdateaxis
;
;
; PURPOSE:
;            To plot an x-axis labeled with the date(s) instead of the
;            Julian Date or MJD.
;
;
; CATEGORY:
;            General astronomy tools
;
;
; CALLING SEQUENCE:
;            jdateaxis
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;            fontscale: array of 4 reals defining the scale for the
;                       4 levels of label sizes. default:[0.,1.,1.2,1.4]
;
;	
; KEYWORD PARAMETERS:
;            upper    : if set, plot upper x-axis instead of lower x-axis
;            nolabel  : if set, don't label the plot
;            noyear   : if set, suppress year tag in label
;            mjd      : if set, the units in which the x-axis was
;                       plotted, are the modified JD (i.e. JD-2400000.5)
;            zeropoint: the units of the x-axis have been plotted in
;                       JD (or MJD), but an additional time given by
;                       zeropoint has been subtracted before plotting
;                       (i.e. JD = x-axis value PLUS zeropoint)
;            stretch  : multiply all labels with stretch before plotting
;            charsize : Size of the characters    
;            longyr   : if there are only year labels (1996, 1997,
;                       1998, ...), extended yearly tickmarks are
;                       plotted, that reach out to in between the year
;                       labels. The advantage is that any doubt about
;                       which monthly tickmarks belong to which year
;                       is removed. Especially useful in the plots of
;                       long monitorings like Cyg X-1 which span
;                       several years. 
;            _extra   : in addition, all graphics keywords are passed via the
;                       _extra mechanism.
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
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;             readlc,time,count,'test.lc',/mjd
;             jwplotlc,time-min(time),count,/noxaxis,/mjd
;             jwdateaxis,zeropoint=min(time),/mjd,/upper
;
; MODIFICATION HISTORY:
;              Version 1.0: 1997/10/22, Joern Wilms    
;                                       (wilms@astro.uni-tuebingen.de)
;              Version 1.1: 2000/02/21, JW, added charsize
;              Version 1.2: 2000/07/12, JW: added _extra keyword
;              Version 1.3: 2001/08/27, Katja Pottschmidt 
;                                       (katja@astro.uni-tuebingen.de):
;                                       added noyear keyword 
;              Version 1.4: 2002/01/28, Joern Wilms
;                                       added fontscale keyword
;          CVS Version 1.6: 2003/03/27, Thomas Gleissner
;                                       added longyr keyword
;-

   ;; stretch-factor if plot has non-standard y-size
   IF (n_elements(stretch) EQ 0) THEN stretch=1.

   ;; default: label the plot
   IF (n_elements(nolabel) EQ 0) THEN nolabel=0

   ;;
   ;; Get allowed x- and y-coordinates
   ;;
   clip=!p.clip
   ranges=convert_coord([clip(0),clip(2)],[clip(1),clip(3)],/device,/to_data)
   rannor=convert_coord([clip(0),clip(2)],[clip(1),clip(3)],/device,/to_normal)

   ;; jd0: offset to be added to x-value to get JD (which we'll use
   ;; throughout this subroutine
   jd0=0.D0
   IF (keyword_set(mjd)) THEN jd0=2400000.5D0
   IF (n_elements(zeropoint) NE 0) THEN jd0=jd0+zeropoint

   ;; jdmin and jdmax: JD of min. and max. x-value
   jdmin=ranges(0,0)+jd0
   jdmax=ranges(0,1)+jd0

   ;; year... of first and last day
   daycnv,jdmin,firstyear,firstmonth,firstday,hr
   daycnv,jdmax,lastyear,lastmonth,lastday,hr

   ;; min. and max. y-value (in data coordinates)
   ypos=ranges(1,0)
   IF (keyword_set(upper)) THEN ypos=ranges(1,1)

   ;;
   ;; Decide about what tickmarks to use
   ;;
   ;; constants for the intervals
   min1=0                       ; min tickmarks
   min10=0                      ; 10min tickmarks
   min15=0                      ; 15min tickmarks
   min30=0                      ; 30min tickmarks
   hourly=0                     ; hourly tickmarks
   hourly6=0                    ; 6hourly tickmarks
   hourly12=0                   ; 12hourly tickmarks
   daily=0                      ; daily tickmarks
   daily7=0                     ; 7daily tickmarks
   daily15=0                    ; 15daily tickmarks
   monthly=0                    ; monthly tickmarks
   monthly6=0                   ; 6monthly tickmarks
   yearly=0                     ; yearly tickmarks
   yearly5=0                    ; 5yearly tickmarks
   yearly10=0                   ; 10yearly tickmarks
   century=0                    ; century tickmarks
   millenium=0                  ; millenium tickmarks

   ;; time-interval for the labeling
   dt=(jdmax-jdmin)*0.9/(rannor(0,1)-rannor(0,0))
   
   IF (dt LT 10./(60.*24.)) THEN BEGIN 
       min1=2
       hourly=3
   ENDIF 
   

   IF (dt GT 10./(60.*24.) AND dt LT 0.5/24.) THEN BEGIN 
       min1=1
       min10=2
       hourly=3
   ENDIF 
   
   IF (dt GT 0.5/24. AND dt LE 0.2) THEN BEGIN 
       min10=1
       hourly=2
       daily=3
   ENDIF 
   IF (dt GT 0.2 and dt LE 0.5) THEN BEGIN 
       min15=1
       hourly=2
       daily=3
   ENDIF 
   IF (dt GT 0.5 AND dt LE 1.) THEN BEGIN 
       min30=1
       hourly=2
       daily=3
   ENDIF 
   IF ((dt GE 1.) AND (dt LE 3.)) THEN BEGIN 
       hourly=1
       hourly6=2
       daily=3
   ENDIF
   IF ((dt GT 3.) AND (dt LE 5)) THEN BEGIN 
       hourly6=1
       daily=2
       monthly=3
   ENDIF 
   IF ((dt GT 5.) AND (dt LE 17)) THEN BEGIN 
       hourly12=1
       daily=2
       monthly=3
   ENDIF 
   IF ((dt GT 17) AND (dt LE 2*30)) THEN BEGIN 
       daily=1
       daily7=2
       monthly=3
   ENDIF 
   IF ((dt GT 2*30) AND (dt LE 3.5*30)) THEN BEGIN 
       daily=1
       daily15=2
       monthly=3
   ENDIF 
   IF ((dt GT 3.5*30) AND (dt LE 15*30)) THEN BEGIN 
       daily7=1
       monthly=2
       yearly=3
   ENDIF
   IF ((dt GT 15*30) AND (dt LE 3.*350.)) THEN BEGIN 
       daily15=1
       monthly=2
       yearly=3
   ENDIF 
   IF ((dt GT 3.*350.) AND (dt LE 10.*350.)) THEN BEGIN 
       monthly=1
       monthly6=2
       yearly=3
   ENDIF 
   IF ((dt GT 10.*350.) AND (dt LE 15.*350.)) THEN BEGIN 
       monthly6=1
       yearly=2
   ENDIF 
   IF ((dt GT 15.*350.) AND (dt LE 55.*350.)) THEN BEGIN 
       yearly=1
       yearly5=2
   ENDIF 
   IF ((dt GT 55.*350.) AND (dt LE 110.*350.)) THEN BEGIN 
       yearly5=1
       yearly10=2
   ENDIF 
   IF ((dt GT 110.*350.) AND (dt LE 1200.*350.)) THEN BEGIN 
       yearly10=1
       century=2
   ENDIF 
   IF (dt GT 1200.*350.) THEN BEGIN 
       century=1
       millenium=2
   ENDIF 
   IF (keyword_set(noyear)) THEN yearly=0

   lgyrtk=0
   IF monthly EQ 1 AND monthly6 EQ 2 AND yearly EQ 3 AND keyword_set(longyr) THEN BEGIN
     lgyrtk=1
   endif

   ;; Determine which month-names to use
   month=['','January','February','March','April','May','June','July', $
          'August','September','October','November','December']
   IF (dt GT 300.) THEN BEGIN 
       month=['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep', $
              'Oct','Nov','Dec']
   ENDIF 
   IF (dt GT 500) THEN BEGIN 
       month=['','J','F','M','A','M','J','J','A','S','O','N','D']
   ENDIF 


   ;; po(1..3)  : position of label
   ;; dash(0..3): dash from dash(0) to dash(level)
   ;; jdmin     : min. allowed date
   ;; jdmax     : max. allowed date
   parm={parm,po:[0.,0.,0.,0.],dash:[0.,0.,0.,0.],size:[0.,0.,0.,0.], $
         jdmin:jdmin,jdmax:jdmax,jd0:jd0,nolabel:nolabel}

   ;;
   ;; Draw lines for axis, determine text-positions
   ;; parm.dash HAS TO AGREE WITH speclen IN jwmjdaxis
   IF (keyword_set(upper)) THEN BEGIN 
       plots,[clip(0),clip(2)],[clip(3),clip(3)],/device,_extra=extra
       po=convert_coord(jdmin-jd0,ypos,/data,/to_normal)
       IF (!D.name EQ 'PS') THEN BEGIN 
           parm.po=po(1)+[0.,0.0,0.015,0.07]*stretch
           parm.dash=po(1)-[0.,0.01,0.02,0.035]*stretch
       END ELSE BEGIN 
           parm.po=po(1)+[0.,0.0,0.01,0.045]*stretch
           parm.dash=po(1)-[0.,0.01,0.02,0.035]*stretch
       END
   END ELSE BEGIN 
       plots,[clip(0),clip(2)],[clip(1),clip(1)],/device,_extra=extra
       po=convert_coord(jdmin-jd0,ypos,/data,/to_normal)
       IF (!d.name EQ 'PS') THEN BEGIN 
           parm.po=po(1)-[0.,0.0,0.05,0.1]*stretch
           parm.dash=po(1)+[0.,0.01,0.02,0.035]*stretch
       END ELSE BEGIN 
           parm.po=po(1)-[0.,0.0,0.03,0.06]*stretch
           parm.dash=po(1)+[0.,0.01,0.02,0.035]*stretch
       END 
   END

   IF (n_elements(fontscale) NE 4) THEN BEGIN 
       IF (!D.NAME EQ 'PS') THEN BEGIN 
           parm.size=[0.,1.,1.2,1.4]
       END ELSE BEGIN 
           parm.size=[0.,1.,1.2,1.4]
       ENDELSE 
   ENDIF ELSE BEGIN 
       parm.size=fontscale
   ENDELSE 
   
   IF (n_elements(charsize) EQ 0) THEN BEGIN 
       charsize=1
       IF (!p.charsize NE 0.) THEN charsize=!p.charsize
   ENDIF 
   parm.size=parm.size*charsize

   ;;
   ;; First and last day to work with (longer than interval covered...)
   ;;
   jdcnv,firstyear,firstmonth,firstday,0.,jdstart
   jdcnv,lastyear,lastmonth,lastday+1,0.,jdend

   ;;
   ;; Output the tickmarks
   ;;
   ;; Caveat: in the loops, yr, mon, and day have to be LONG
   ;; variables, if not, the loops won't terminate (bug in jdcnv)
   
   ;;
   ;; Tickmarks in 1min distance
   ;;
   IF (min1 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hr=0,23 DO BEGIN 
               FOR frac=0,59 DO BEGIN 
                   jd=jjd+hr/24.+frac/60./24.
                   jdtick,jd,min1,parm,_extra=extra
                   IF (frac NE 0.) THEN BEGIN 
                       jdlabel,jd,jd,string(frac),min1,parm,_extra=extra
                   ENDIF 
               ENDFOR 
           ENDFOR 
       ENDFOR 
   ENDIF 
   
   ;;
   ;; Tickmarks in 10min distance
   ;;
   IF (min10 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hr=0,23 DO BEGIN 
               FOR frac=0,5 DO BEGIN 
                   jd=jjd+hr/24.+frac*10./60./24.
                   jdtick,jd,min10,parm,_extra=extra
                   IF (frac NE 0.) THEN BEGIN 
                       jdlabel,jd,jd,string(frac*10),min10,parm,_extra=extra
                   ENDIF 
               ENDFOR 
           ENDFOR 
       ENDFOR 
   ENDIF 


   ;;
   ;; Tickmarks in 15min distance
   ;;
   IF (min15 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hr=0,23 DO BEGIN 
               FOR frac=0,3 DO BEGIN 
                   jd=jjd+hr/24.+frac*0.25/24.
                   jdtick,jd,min15,parm,_extra=extra
                   IF (frac NE 0.) THEN BEGIN 
                       jdlabel,jd,jd,string(frac*15),min15,parm,_extra=extra
                   ENDIF 
               ENDFOR 
           ENDFOR 
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks in 30min distance
   ;;
   IF (min30 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hr=0,23 DO BEGIN 
               FOR frac=0,1 DO BEGIN 
                   jd=jjd+hr/24.+frac*0.5/24.
                   jdtick,jd,min30,parm,_extra=extra
                   IF (frac NE 0.) THEN BEGIN 
                       jdlabel,jd,jd,string(frac*30),min30,parm,_extra=extra
                   ENDIF 
               ENDFOR 
           ENDFOR 
       ENDFOR 
   ENDIF 

   ;;
   ;; Hourly Tickmarks
   ;;
   IF (hourly NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hr=0,23 DO BEGIN 
               jd=jjd+hr/24.
               jdtick,jd,hourly,parm,_extra=extra
               daycnv,jd,yyy,mmm,ddd
               IF (hourly EQ 2) THEN BEGIN 
                   jdlabel,jd,jd,string(hr),hourly,parm
               END ELSE BEGIN 
                   jdlabel,jd,jd+1./24., $
                     strtrim(string(yyy),2)+' '+month(mmm)+$
                     ' '+strtrim(string(ddd),2)+', '+ $
                     strtrim(string(hr),2)+'h',hourly,parm,_extra=extra
               END 
           ENDFOR 
       END
       
   ENDIF 

   ;;
   ;; 6hourly Tickmarks
   ;;
   IF (hourly6 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           FOR hh=0,3 DO BEGIN 
               jjj=jjd+hh/4.
               jdtick,jjj,hourly6,parm,_extra=extra
               IF (hourly6 EQ 2) THEN BEGIN 
                   jdlabel,jjj,jjj,string(hh*6),hourly6,parm,_extra=extra
               ENDIF 
           ENDFOR 
       ENDFOR 
   ENDIF 


   ;;
   ;; 12hourly Tickmarks
   ;;
   IF (hourly12 NE 0) THEN BEGIN 
       FOR jjd=jdstart,jdend DO BEGIN 
           jdtick,jjd,hourly12,parm,_extra=extra
           jdtick,jjd+0.5,hourly12,parm,_extra=extra
           IF (hourly12 EQ 2) THEN BEGIN 
               jdlabel,jjd,jjd,'0',hourly12,parm
               jdlabel,jjd+0.5,jjd+0.5,'12',hourly12,parm,_extra=extra
           ENDIF 
       ENDFOR 
   ENDIF 

   ;;
   ;; Daily Tickmarks
   ;;
   IF (daily NE 0) THEN BEGIN 
       FOR jjd=jdstart-1,jdend+1 DO BEGIN 
           jdtick,jjd,daily,parm,_extra=extra
           daycnv,jjd,yyy,mmm,ddd
           IF (daily EQ 2) THEN BEGIN 
               jdlabel,jjd,jjd,string(ddd),daily,parm
           END ELSE BEGIN 
               jdlabel,jjd,jjd+1, $
                 strtrim(string(yyy),2)+' '+month(mmm)+$
                 ' '+strtrim(string(ddd),2),daily,parm,_extra=extra
           END 
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks for days 1,8,15,22,29
   ;;
   IF (daily7 NE 0) THEN BEGIN 
       FOR yr=firstyear,lastyear DO BEGIN 
           FOR mon=1L,12L DO BEGIN 
               FOR day=0L,4L DO BEGIN 
                   dd=1+day*7
                   jdcnv,yr,mon,dd,0.,jjd
                   IF (NOT (mon EQ 2 AND day EQ 4)) THEN BEGIN 
                       jdtick,jjd,daily7,parm,_extra=extra
                       jdlabel,jjd,jjd,string(dd),daily7,parm,_extra=extra
                   END 
               ENDFOR 
           ENDFOR 
       ENDFOR 
   ENDIF

   ;;
   ;; Tickmarks at days 1 and 15
   ;;
   IF (daily15 NE 0) THEN BEGIN 
       FOR yr=firstyear,lastyear DO BEGIN 
           FOR mon=1L,12L DO BEGIN 
               jdcnv,yr,mon,1,0.,jjd
               jdtick,jjd,daily15,parm,_extra=extra
               jdlabel,jjd,jjd,'1',daily15,parm
               jdtick,jjd+15.,daily15,parm,_extra=extra
               jdlabel,jjd+15.,jjd+15.,'15',daily15,parm,_extra=extra
           ENDFOR 
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks for every month
   ;;
   IF (monthly NE 0) THEN BEGIN 
       FOR yr=firstyear,lastyear DO BEGIN 
           FOR mon=1L,12L DO BEGIN 
               jdcnv,yr,mon,1,0.,jjd
               jdtick,jjd,monthly,parm,_extra=extra
               jdcnv,yr,mon+1,1.,0.,jjj
               str=month(mon)
               IF (monthly EQ 3) THEN BEGIN 
                   str=strtrim(string(yr),2)+' '+month(mon)
               END               
               jdlabel,jjd,jjj,str,monthly,parm,_extra=extra
           ENDFOR 
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks for every 6 months
   ;;
   IF (monthly6 NE 0) THEN BEGIN
       FOR yr=firstyear,lastyear DO BEGIN 
           jdcnv,yr,1.,1.,0.,jjd
           jdtick,jjd,monthly6,parm,_extra=extra
           jdcnv,yr,7.,1.,0.,jjd
           jdtick,jjd,monthly6,parm,_extra=extra
       ENDFOR 
   ENDIF            

   ;;
   ;; Tickmarks for every year
   ;;
   IF (yearly NE 0) THEN BEGIN 
       FOR yr=firstyear,lastyear DO BEGIN 
           jdcnv,yr,1,1,0.,jjd
           jdtick,jjd,yearly,parm,lgyrtk=lgyrtk,_extra=extra
           ti=yearly
           ;; ...ugly hack
           IF (ti EQ 3 AND monthly6 NE 0) THEN ti=2
           jdcnv,yr+1,1,1,0.,jjd1
           jdlabel,jjd,jjd1,string(yr),ti,parm,_extra=extra
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks every 5 years
   ;;
   IF (yearly5 NE 0) THEN BEGIN 
       yr0=fix(firstyear/10)*10L
       yr1=fix(lastyear/10 + 1)*10L
       FOR yr=yr0,yr1,5 DO BEGIN 
           jdcnv,yr,1,1,0.,jjd
           jdtick,jjd,yearly5,parm,_extra=extra
           jdlabel,jjd,jjd,string(yr),yearly5,parm
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks every 10 years
   ;;
   IF (yearly10 NE 0) THEN BEGIN 
       yr0=fix(firstyear/10)*10L
       yr1=fix(lastyear/10 + 1)*10L
       FOR yr=yr0,yr1,10 DO BEGIN 
           jdcnv,yr,1,1,0.,jjd
           jdtick,jjd,yearly10,parm,_extra=extra
           jdlabel,jjd,jjd,string(yr),yearly10,parm
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks for every century
   ;;
   IF (century NE 0) THEN BEGIN 
       yr0=fix(firstyear/100)*100L
       yr1=fix(lastyear/100+1)*100L
       FOR yr=yr0,yr1,100 DO BEGIN 
           jdcnv,yr,1,1,0.,jjd
           jdtick,jjd,century,parm,_extra=extra
           jdlabel,jjd,jjd,string(yr),century,parm,_extra=extra
       ENDFOR 
   ENDIF 

   ;;
   ;; Tickmarks every 1000 years
   ;;
   IF (millenium NE 0) THEN BEGIN 
       yr0=fix(firstyear/1000)*1000L
       yr1=fix(lastyear/1000+1)*1000L
       FOR yr=yr0,yr1,1000 DO BEGIN 
           jdcnv,yr,1,1,0.,jjd
           jdtick,jjd,millenium,parm,_extra=extra
           jdlabel,jjd,jjd,string(yr),millenium,parm,_extra=extra
       ENDFOR 
   ENDIF 

   ;;
   ;; ... more than 10000 yrs are not allowed (are we being
   ;; creationist here???)
   ;;
END 
