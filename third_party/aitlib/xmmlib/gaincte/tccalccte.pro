PRO tccalccte,data,ccdid,emin=emin,emax=emax,erange=erange,$
		minline=minline,maxline=maxline,bline=bline,$
		mincol=mincol,maxcol=maxcol,badcols=badcols,$
		bg=bg,cte=cte,errf=errf,peakf=peakf,plotfit=plotfit,file=file,chatty=chatty
	   
;+
; NAME:            tccalccte
;
;
;
; PURPOSE:
;		   Calculate CTE of given area
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tccte,data,9,emin=900,emax=1500,minline=141,bline=14,cte=cte,/plot 
;
; 
; INPUTS:
;                  data   : the data struct array to be fitted
;                  ccdid  : the ccdid of the desired ccd (0..11)   
;
;
; OPTIONAL INPUTS:
;                  emin, emax : fixed minimum/maximum energy value in ADU 
;                  erange : half energy interval around peak used for fit   
;		   minline, maxline, mincol, maxcol: area on ccd from which data is 
;		                              		to be taken
;                  bline : number of lines for one fit
;                  badcols : intarr with numbers of bad columns 
;                  bg    : binsize for gaussfit
;                  file  : filename of HK file, if set, save cte
;                          values to file CTE_??_HK??????_???.dat
;   
;
; KEYWORD PARAMETERS: 
;                  errf :  save calculated errors to file CTE_??_err_HK??????_???.dat
;                  peakf : save peak positions to file
;                  CTE_??_peakpos_HK??????_???.dat
;                  plotfit: plot each fit
;
;
; OUTPUTS:
;                  cte: fltarr with cte values
;
;
; OPTIONAL OUTPUTS:
;		   none   
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
;                  see code
;
;
; EXAMPLE:
;
;                  
;
; MODIFICATION HISTORY:
; V1.0 04.01.00 T. Clauss Initial version
; V1.1 24.01.00 T. Clauss Removed column binning, added badcols
; V1.2 25.01.00 T. Clauss Added saving to file
; V2.0 03.04.00 T. Clauss Changed fitting procedure, corrected calculation of CTE,  
;                         added calc. of errors, changed plotting
;                         procs  
; V2.1 03.04.00 T. Clauss Added preselection of data  
; V2.2 30.08.00 T. Clauss Changed plotting procedures, changed keyword
;                         plot to plotfit
;-
   
   
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (keyword_set(plotfit)) THEN plotfit=1 ELSE plotfit=0
   
   IF (NOT keyword_set(bg)) THEN bg=1.d
   
   IF (NOT keyword_set(emin)) THEN emin = MIN(data.energy)
   IF (NOT keyword_set(emax)) THEN emax = MAX(data.energy)

   IF (NOT keyword_set(minline)) THEN minline=0
   IF (NOT keyword_set(maxline)) THEN maxline=199
   IF (NOT keyword_set(mincol)) THEN mincol=0
   IF (NOT keyword_set(maxcol)) THEN maxcol=63

   IF (NOT keyword_set(bline)) THEN BEGIN bline=1
     ENDIF ELSE BEGIN
       IF ((minline+bline) GT maxline) THEN bline=maxline-minline+1
     ENDELSE	
     
   IF (NOT keyword_set(badcols)) THEN badcols=-1
   
   ind=where((data.energy GE emin) AND (data.energy LE emax) AND $
             (data.line GE minline) AND (data.line LE maxline) AND $
             (data.column GE mincol) AND (data.column LE maxcol))   
   
   dat=data(ind)
   
   numline=fix((maxline-minline+1)/bline)  ;; number of line bins
   cte=fltarr(64)
   cte(*)=0
   err=fltarr(64)
   err(*)=0
   a_cte=fltarr(64)
   a_cte(*)=0
   peaks=fltarr(64,numline)
   sigmap=fltarr(64,numline)
   sigmap(*)=0
   chisqp=fltarr(64,numline)
   chisqp(*)=0
   xpeaks=INDGEN(numline)*bline+minline
   
   ywsize=100*fix((numline+3)/4)
   IF (plotfit EQ 1) THEN BEGIN
       loadct,13
       window, 12, xsize=400, ysize=300, xpos=400, ypos=150 
       window, 11, xsize=400, ysize=ywsize, xpos=620, ypos=740-ywsize 
       window, 10, xsize=400, ysize=ywsize, xpos=500, ypos=700-ywsize       
       awin=10
       wset, awin
   ENDIF
   
   FOR col=mincol,maxcol DO BEGIN
     IF((where(badcols EQ col))(0) EQ -1) THEN BEGIN  
         nl=0                   ;
         pcnt=0
         IF (chatty EQ 1) THEN print,'Column ',col
         FOR line=minline,maxline-bline+1,bline DO BEGIN
             indx=where((dat.line GE line) AND (dat.line LE line+bline-1) AND $
                        (dat.column EQ col))
             IF (n_elements(indx) GT 1) THEN BEGIN
                 pdata=dat(indx)
                 plotpos=[(100*(pcnt MOD 4)+5)/400.0, 1-float(100*fix(pcnt/4)+90)/ywsize,$
                          (100*(pcnt MOD 4)+95)/400.0, 1-float(100*fix(pcnt/4)+15)/ywsize]
                 tcpeak,pdata,erange=erange,bg=bg,sigma=sigma1,chisq=chisq1,peak=peak,$
                   plotfit=plotfit,plotpos=plotpos
                 peaks(col,nl)=peak
                 sigmap(col,nl)=sigma1
                 chisqp(col,nl)=chisq1
             ENDIF ELSE BEGIN
                 peaks(col,nl)=0
                 IF (plotfit EQ 1) THEN BEGIN
                     noticks=[' ',' ',' ',' ',' ',' ',' ',' '] 
                     plotpos=[(100*(pcnt MOD 4)+5)/400.0, 1-float(100*fix(pcnt/4)+90)/ywsize,$
                              (100*(pcnt MOD 4)+95)/400.0, 1-float(100*fix(pcnt/4)+15)/ywsize]
                     plot,[0,1],position=plotpos,/nodata,/noerase,xtickname=noticks,ytickname=noticks
                 ENDIF
             ENDELSE
             IF (chatty EQ 1) THEN $
               print,'   Peak position at lines ',strtrim(line,2),' to ',strtrim((line+bline-1),2),$
               ' : ',strtrim(peaks(col,nl),2),' , sigma: ',strtrim(sigma1,2),' , chisq: ',strtrim(chisq1,2)
             nl=nl+1
             pcnt=pcnt+1
         ENDFOR
                  
         fit=linfit(xpeaks,alog(peaks(col,*)),sigma=sigmac)
         a_cte(col)=exp(fit[0])
         cte(col)=exp(fit[1])
         err(col)=cte(col)*sigmac(1)
         IF (NOT (cte(col) GE 0)) THEN BEGIN 
             cte(col)=0 
             err(col)=0
             a_cte(col)=0
         ENDIF
         IF (chatty EQ 1) THEN print,'      CTE: ',cte(col),'    Sigma ',err(col)
         IF (plotfit EQ 1) THEN BEGIN
             IF (cte(col) GT 0) THEN BEGIN 
                 wset, 12
                 wshow, 12
                 erase
                 plot,xpeaks,alog(peaks(col,*)),psym=2,/ystyle
                 oplot,[0,200],[fit[0],fit[0]+fit[1]*200],color=42
             ENDIF
             IF (awin EQ 10) THEN BEGIN 
                 awin=11
             ENDIF ELSE BEGIN
                 IF (awin EQ 11) THEN awin=10
             ENDELSE
             wset, awin
             wshow, awin
             erase
         ENDIF         
     END ELSE BEGIN 
         IF (chatty EQ 1) THEN print,'Column ',col,' bad!'
         cte(col)=0
         err(col)=0
     ENDELSE     
   ENDFOR
   
   
   IF (plotfit EQ 1) THEN wset,12
   
   IF (keyword_set(file)) THEN BEGIN
          
       ccdnr=['00','01','02','10','11','12','20','21','22','30','31','32']
   
       openw,unit,'CTE_'+ccdnr(ccdid)+'_'+strmid(file,0,strlen(file)-4)+'_'+$
                                           strmid(file,strlen(file)-3,3)+'.dat',/get_lun
       FOR i=0,63 DO printf,unit,cte(i)
       
       printf,unit,' '
       printf,unit,'Parameters for calculation: '
       printf,unit,' CCD Nr. '+strtrim(ccdid,2)
       printf,unit,' Energy: Range of +- '+strtrim(erange,2)+' ADC within '+$
         strtrim(emin,2)+'..'+strtrim(emax,2)+' ADC'
       printf,unit,' Lines '+strtrim(minline,2)+'..'+strtrim(maxline,2)+$
                   ' with line binsize '+strtrim(bline,2)
       printf,unit,' Columns '+strtrim(mincol,2)+'..'+strtrim(maxcol,2)
       printf,unit,'  Bad Columns: ',badcols
       printf,unit,' Binsize for fit: '+strtrim(bg,2)
       
       free_lun,unit   
           
       IF (keyword_set(errf)) THEN BEGIN
             
           openw,unit,'CTE_'+ccdnr(ccdid)+'_err_'+strmid(file,0,strlen(file)-4)+'_'+$
                                           strmid(file,strlen(file)-3,3)+'.dat',/get_lun
           FOR i=0,63 DO printf,unit,err(i)
           free_lun,unit   
       ENDIF
       
       IF keyword_set(peakf) THEN BEGIN
           
           openw,unit,'CTE_'+ccdnr(ccdid)+'_peakpos_'+strmid(file,0,strlen(file)-4)+'_'+$
             strmid(file,strlen(file)-3,3)+'.dat',/get_lun
           
           printf,unit,numline
           printf,unit,xpeaks         
           FOR i=0,63 DO BEGIN
               printf,unit,i
               FOR j=0,numline-1 DO printf,unit,peaks(i,j),sigmap(i,j),chisqp(i,j)
               printf,unit,cte(i),err(i),a_cte(i)     
           ENDFOR
           
           printf,unit,' '
           printf,unit,'Data contained in this file: '
           printf,unit,' - number of line bins (i.e. number of peaks)'
           printf,unit,' - line positions of peaks'
           printf,unit,' - for each of the 64 columns:'
           printf,unit,'    * column number'
           printf,unit,'    * for each peak: position, sigma, chisq'
           printf,unit,'    * cte, sigma of linear fit and peakpos(0)'
                      
           printf,unit,' '
           printf,unit,'Parameters for calculation: '
           printf,unit,' CCD Nr. '+strtrim(ccdid,2)
           printf,unit,' Energy: Range of +- '+strtrim(erange,2)+' ADC within '+$
             strtrim(emin,2)+'..'+strtrim(emax,2)+' ADC'
           printf,unit,' Lines '+strtrim(minline,2)+'..'+strtrim(maxline,2)+$
             ' with line binsize '+strtrim(bline,2)
           printf,unit,' Columns '+strtrim(mincol,2)+'..'+strtrim(maxcol,2)
           printf,unit,'  Bad Columns: ',badcols
           printf,unit,' Binsize for fit: '+strtrim(bg,2)
           
           free_lun,unit
       ENDIF
   ENDIF
END 































































































