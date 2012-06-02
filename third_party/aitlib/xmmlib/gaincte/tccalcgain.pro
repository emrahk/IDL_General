PRO tccalcgain,data,ccdid,emin=emin,emax=emax,erange=erange,$
               minline=minline,maxline=maxline,mincol=mincol,maxcol=maxcol,$
               gain=gain,bg=bg,bin=bin,errf=errf,file=file,plotfit=plotfit,chatty=chatty
;+
; NAME:            tccalcgain
;
;
;
; PURPOSE:
;		   Calculate gain
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  
;
; 
; INPUTS:
;                  data   : the data struct array to be fitted
;                  ccdid  : the ccdid of the desired ccd (0..11)   
;
;
; OPTIONAL INPUTS:
;                  emin: the minimum energy value in ADU 
;                  emax: the maximum energy value in ADU
;                  erange: energy range for fit
;		   minline, maxline, mincol, maxcol: area on ccd from which data is 
;							to be taken
;                  bg     : binsize
;                  file  : filename of HK file, if set, save gain
;                          values to file Gain_??_HK??????_???.dat
;   
;
; KEYWORD PARAMETERS:
;                  plotfit : plot each fit
;                  bin : save gain values in binary format to file Gain_??_HK??????_???.bin
;                  errf : save error values to file Gain_??_err_HK??????_???.dat
;                  chatty :  print gain values   
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;		   gain :  fltarr(64) with gain values
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  for each column in chosen are, make spectrum out of
;                  all events, fit gaussian, divide peak position by
;                  the mean position of all peaks, save to file if desired
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 25.01.00 T. Clauss first version
; V1.1 11.05.00 T. Clauss added keyword errf
; V1.2 30.08.00 T. Clauss changed plotting procedure, changed keyword
;                         plot to plotfit
;-
   
   
   IF (NOT keyword_set(bg)) THEN bg=1.d
   IF (keyword_set(plotfit)) THEN plotfit=1 ELSE plotfit=0
   
   IF (NOT keyword_set(emin)) THEN emin=0
   IF (NOT keyword_set(emax)) THEN emax=4095
   
   IF (NOT keyword_set(minline)) THEN minline=0
   IF (NOT keyword_set(maxline)) THEN maxline=199
   IF (NOT keyword_set(mincol)) THEN mincol=0
   IF (NOT keyword_set(maxcol)) THEN maxcol=63
      
   gain=fltarr(64)
   gain(*)=0
   peaks=fltarr(64)
   peaks(*)=0
   peaksum=0
   peak=0
   
   IF (plotfit EQ 1) THEN BEGIN
       WINDOW, 10, XSIZE=800, YSIZE=800
       wset,10
   ENDIF
       
   FOR j=mincol,maxcol DO BEGIN
       indx=where((data.energy GE emin) AND (data.energy LE emax) AND $
                  (data.line GE minline) AND (data.line LE maxline) AND $
                  (data.column eq j))
       IF (n_elements(indx) GT 1) THEN BEGIN
           pdata=data(indx)
           plotpos=[(100*(j MOD 8)+5)/800.0,1-(100*fix(j/8)+90)/800.0,$
                    (100*(j MOD 8)+95)/800.0,1-(100*fix(j/8)+15)/800.0]
           tcpeak,pdata,erange=erange,bg=bg,peak=peak,sigma=sigma,chisq=chisq,$
             plotfit=plotfit,plotpos=plotpos
           IF(peak GT 0) THEN BEGIN
               peaksum=peaksum+peak
               peaks(j)=peak
           ENDIF           
           IF (keyword_set(chatty)) THEN $
             print,'% TCCALCGAIN: Col ',strtrim(j,2),' : Peak : ',strtrim(peaks(j),2),$
             ' , sigma: ',strtrim(sigma,2),' , chisq: ',strtrim(chisq,2)               
       ENDIF ELSE BEGIN
           peaks(j)=0
           IF (plotfit EQ 1) THEN BEGIN
               noticks=[' ',' ',' ',' ',' ',' ',' ',' '] 
               plotpos=[(100*(j MOD 8)+5)/800.0,1-(100*fix(j/8)+90)/800.0,$
                        (100*(j MOD 8)+95)/800.0,1-(100*fix(j/8)+15)/800.0]
               plot,[0,1],position=plotpos,/nodata,/noerase,xtickname=noticks,ytickname=noticks
           ENDIF
       ENDELSE
   ENDFOR     
   pind=where((peaks GT 0),pcnt)
   IF(pcnt GT 0) THEN BEGIN 
       mpeak=peaksum/pcnt
       gain(pind)=mpeak/peaks(pind)
       IF keyword_set(errf) THEN BEGIN
           perr=0.5
           gerr=fltarr(64)
           gerr(*)=0
           gerr(pind)=1/peaks(pind)*perr*sqrt(1+gain(pind)^2)
       ENDIF 
   ENDIF
      
   IF (keyword_set(file)) THEN BEGIN
    
       ccdnr=['00','01','02','10','11','12','20','21','22','30','31','32']
   
       openw,unit,'Gain_'+ccdnr(ccdid)+'_'+strmid(file,0,strlen(file)-4)+'_'+$
                                           strmid(file,strlen(file)-3,3)+'.dat',/get_lun
       FOR i=0,63 DO printf,unit,gain(i)
       
       printf,unit,' '
       printf,unit,'Parameters for calculation: '
       printf,unit,' CCD Nr. '+strtrim(ccdid,2)       
       printf,unit,' Energy: Range of +- '+strtrim(erange,2)+' ADC within '+$
         strtrim(emin,2)+'..'+strtrim(emax,2)+' ADC'
       printf,unit,' Lines '+strtrim(minline,2)+'..'+strtrim(maxline,2)
       printf,unit,' Columns '+strtrim(mincol,2)+'..'+strtrim(maxcol,2)
       printf,unit,' Binsize for fit: '+strtrim(bg,2)
       
       free_lun,unit   
       
       IF keyword_set(bin) THEN begin
           openw,unit,'Gain_'+ccdnr(ccdid)+'_'+strmid(file,0,strlen(file)-4)+'_'+$
             strmid(file,strlen(file)-3,3)+'.bin',/XDR,/get_lun
           writeu,unit,gain
           free_lun,unit 
       ENDIF
              
       IF keyword_set(errf) THEN BEGIN
           openw,unit,'Gain_'+ccdnr(ccdid)+'_err_'+strmid(file,0,strlen(file)-4)+'_'+$
                                           strmid(file,strlen(file)-3,3)+'.dat',/get_lun  
           
           FOR i=0,63 DO printf,unit,gerr(i)
           
           printf,unit,' '
           printf,unit,'Parameters for calculation: '
           printf,unit,' CCD Nr. '+strtrim(ccdid,2)       
           printf,unit,' Energy: Range of +- '+strtrim(erange,2)+' ADC within '+$
             strtrim(emin,2)+'..'+strtrim(emax,2)+' ADC'
           printf,unit,' Lines '+strtrim(minline,2)+'..'+strtrim(maxline,2)
           printf,unit,' Columns '+strtrim(mincol,2)+'..'+strtrim(maxcol,2)
           printf,unit,' Binsize for fit: '+strtrim(bg,2)
       
           free_lun,unit   
       ENDIF
   ENDIF
END







