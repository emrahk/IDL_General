PRO mkspectrum,data,spectrum=spectrum,xxx=xxx,fitres=fitres,ccdid=ccdid,$
               minimum=minimum,maximum=maximum,ymin=ymin,ymax=ymax,$
               bg=bg,line=line,fwhm=fwhm,peak=peak,ampl=ampl,integral=integral,$
               gain=gain,cte=cte,dofit=dofit,log=log,comment=comment,plotfile=plotfile,$
               ps=ps,ghost=ghost
;+
; NAME:            mkspectrum
;
;
;
; PURPOSE:
;                  Plot an energy-spectrum derived from xxm
;                  observation data
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  mkspectrum,d0,minimum=1150,maximum=1600,/fit,ccdid=0,line='Cu-K' 
;
; 
; INPUTS:
;                  data   : the data array to be plotted
;
;
; OPTIONAL INPUTS:
;                  ccdid  : the ccdid of the desired ccd
;                  minimum: the minimum energy value in ADU 
;                  maximum: the maximum energy value in ADU
;                  ymin   : the minimum y value in counts
;                  ymax   : the maximum y value in counts
;                  bg     : binsize
;                  line   : the name of the observed x-ray eneergy; is
;                           used to determine the amplification and to
;                           transform ADU in eV;
;                           Possible values are: 
;                           'C-K','Ti-L','O-K','Cr-L','Fe-L','Co-L',
;                           'Cu-L','Mg-K','Al-K','Si-K','P-K','Mo-L',
;                           'Ag-L','Ti-K','Cr-K','Mn-K','Fe-K','Cu-K',
;                           'Ge-K','Mo-K'
;                  comment : a optional comment that will be
;                            printed to the ps-file
;                  plotfile: name of the output ps-file, default is
;                            'plot.ps' 
;      
; KEYWORD PARAMETERS:
;                  /gain  : perform a gain-correction on the
;                           input-data
;                  /cte   : perform a cte-correction on the input-data  
;                  /dofit : apply a gauss fit to the dataset
;                  /log   : plot in logarithmic scale
;                  /ps    : plot to ps-file
;                  /ghost : show ps-file with 'gv'
;
;
; OUTPUTS:
;                  spetrum : The derived spectrum of the data
;
;
; OPTIONAL OUTPUTS:
;                  fwhm    : the full with half maximum from the
;                            gauss-fit
;                  ampl    : the amplification calculated from the fit 
;                  integral: the integral number of events under the
;                            gauss-fit
;                  resfit  :    
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
;                  mkspectrum,d0,minimum=1150,maximum=1600,/fit,ccdid=0,line='Cu-K'
;                  
;
; MODIFICATION HISTORY:
; V1.0 06.06.99 M. Kuster first initial version
; V2.0 09.06.99 M. Kuster added error calculation for gaussfit
; V2.1 30.06.99 M. Kuster fixed bug with enegyrange max and min   
; V2.2 12.08.99 M. Kuster Changed data structure 'data'
; V2.3 07.12.99 M. Kuster Changed keyword 'fit' to 'dofit'
; V2.4 14.12.99 M. Kuster Added keyword spectrum
;-
   peakname = ['C-K','Ti-L','O-K','Cr-L','Fe-L','Co-L',$
               'Cu-L','Mg-K','Al-K','Si-K','P-K','Mo-L',$
               'Ag-L','Ti-K','Cr-K','Mn-K','Fe-K','Cu-K',$
               'Ge-K','Mo-K']
   
   peakvalue = [277.,425.,525.,573.,705.,776.,$
                930.,1253.,1486.,1739.,2014.,2308.,$
                2980.,4508.,5410.,5897.,6398.,8040.,$
                9874.,17440.]
   fwhm=0.
   peak=0.
   ampl=0.
   integral=0.
   
   olddata=data

   IF (keyword_set(gain)) THEN gkorr=1 ELSE gkorr=0
   IF (keyword_set(cte)) THEN ckorr=1 ELSE ckorr=0
   IF (keyword_set(dofit)) THEN dofit=1 ELSE dofit=0
   IF (keyword_set(log)) THEN logplot=1 ELSE logplot=0
   IF (keyword_set(ps)) THEN psplot=1 ELSE psplot=0
   IF (NOT keyword_set(bg)) THEN bg=1.d
   IF (keyword_set(line)) THEN BEGIN 
       fitpeak=where(peakname EQ line)
   END ELSE BEGIN
       fitpeak=1.
   ENDELSE 
      
   IF (n_elements(ccdid) NE 0) THEN BEGIN ; do corretion for one specified ccd
       ccdind=where(data.ccd EQ ccdid)
       IF (ccdind(0) NE -1) THEN BEGIN 
           data=data(ccdind)
           IF (gkorr EQ 1) THEN BEGIN
                data=mkgain(data,ccdid,/chatty)
           ENDIF 
           
           IF (ckorr EQ 1) THEN BEGIN
                data=mkcte(data,ccdid,/chatty)
           ENDIF
       ENDIF ELSE BEGIN 
           print,'% MKSPECTRUM: ERROR no data of CCD: '+STRTRIM(ccdid)+' found !!'
       ENDELSE 
       
   ENDIF ELSE BEGIN             ; do corretion for all ccds
       FOR i=0, 11 DO BEGIN
           ccdind=where(data.ccd EQ i)
           IF (ccdind(0) NE -1) THEN BEGIN
               IF (gkorr EQ 1) THEN BEGIN
                    data(ccdind)=mkgain(data(ccdind),i,/chatty)
               ENDIF 
               IF (ckorr EQ 1) THEN BEGIN
                    data(ccdind)=mkcte(data(ccdind),i,/chatty)
               ENDIF
           ENDIF ELSE BEGIN 
               print,'% MKSPECTRUM: ERROR no data of CCD '+STRTRIM(i,2)+' found !!'
           ENDELSE 
       ENDFOR 
   ENDELSE 
   
   IF (NOT keyword_set(minimum)) THEN minimum = MIN(data.energy)
   IF (NOT keyword_set(maximum)) THEN maximum = MAX(data.energy)
   
   ;;select energy window 
   indx=where((data.energy GE minimum) AND (data.energy LE maximum))   
   energy=data(indx).energy
       
   spectrum = HISTOGRAM(energy, BINSIZE=bg)

   xindex = INDGEN(N_ELEMENTS(spectrum))*bg+min(energy)
   IF (NOT keyword_set(ymin)) THEN ymin=min(spectrum)
   IF (NOT keyword_set(ymax)) THEN ymax=max(spectrum)
   
   IF (logplot EQ 1) THEN BEGIN 
       IF (n_elements(ccdid) NE 0) THEN BEGIN
           tit='Energy-Spectrum of CCD '+STRTRIM(ccdid,2)+' (log-scale)' 
       ENDIF ELSE BEGIN 
           tit='Energy-Spectrum of all CCDs (log-scale)' 
       ENDELSE 
   ENDIF ELSE BEGIN 
       IF (n_elements(ccdid) NE 0) THEN BEGIN
           tit='Energy-Spectrum of CCD '+STRTRIM(ccdid,2) 
       ENDIF ELSE BEGIN 
           tit='Energy-Spectrum of all CCDs'
       ENDELSE 
   ENDELSE
   
   IF (gkorr EQ 1) THEN tit=tit+', Gain-corrected'
   IF (ckorr EQ 1) THEN tit=tit+', CTE-corrected'
   
   IF (dofit EQ 1) THEN BEGIN 
       pos=[0.10,0.40,0.96,0.80]
       xtit=''
       xtit2='Energy in ADU'
       xsty=1
   ENDIF ELSE BEGIN 
       pos=[0.10,0.10,0.96,0.80]
       xtit='Energy in ADU'
       xsty=1
   ENDELSE 
   
   IF (psplot EQ 1) THEN BEGIN 
       set_plot,'ps'
       loadct,13
       IF (NOT keyword_set(plotfile)) THEN plotfile='plot.ps'
       IF (NOT keyword_set(comment)) THEN comment=''
       plotfile=STRTRIM(plotfile,2)
       print,'% MKSPECTRUM: Printing to file: ',plotfile
       spawn,"date '+%d %b %Y  %H:%M:%S'",date ; get system date
       user=getenv('USER')      ; get username
       host=getenv('HOST')      ; get hostname
       ;;open postscript device 
       device,bits_per_pixel=8,xsize=20.0,ysize=29.0,/color,/portrait, $
         file=plotfile,set_font='Times',/TT_FONT,xoffset=0.5,yoffset=0
   ENDIF
   
   IF min(xindex) GE maximum OR max(xindex) LE minimum THEN BEGIN 
       plot, [minimum,maximum], [0,0], title=tit, XTITLE=xtit, yrange=[.1*logplot,ymax],$
         ytitle='Number of Counts',PSYM=10, XSTYLE=xsty, $
         /ystyle, YLOG=logplot, MIN_VALUE=.1*logplot,$
         xticks=xti,/normal,position=pos
   ENDIF ELSE BEGIN
       PLOT, xindex, spectrum, XRANGE=[minimum,maximum],title=tit,$
         position=pos,yrange=[.1*logplot,ymax],$
         ytitle='Number of Counts',XTITLE=xtit, $
         xticks=xti,PSYM=10, XSTYLE=xsty, /ystyle,$
         YLOG=logplot, MIN_VALUE=.1*logplot,xtickname='',/normal
   ENDELSE  
   numevents=total(spectrum)
   xyouts,0.10,0.92,'Total number of events= '+string(format='(F9.0)',numevents),$
     alignment=0.,/normal   
   
   IF (dofit EQ 1) THEN BEGIN
       gspek = HISTOGRAM(energy, MIN=minimum, MAX=maximum, BINSIZE=bg)
       IF (maximum-minimum+bg)/bg GT 8 THEN BEGIN
           xxx = INDGEN(N_ELEMENTS(gspek))*bg+minimum
           ;; do gaussfit on data
           weight=dblarr(n_elements(gspek))
           weight(*)=1.d
           ;; get starters for better fit 
           temp=gaussfit(xxx,gspek,f)
           ;; do better gauss fit 
           gauss=mkgaussfit(xxx,gspek,weight,f,error=error,result=result)           
           ;; oplot fit
           OPLOT, xxx, gauss, COLOR=42, THICK=2

           peak=result(1)
           ;; calculate errors plus and minus
           errorp=error(1,1)-peak
           errorm=peak-error(0,1)

           centerstr='Center= '+string(format='(F9.4)',result(1))+$
             ' ^{+'+STRTRIM(string(format='(F9.4)',errorp),2)+'}'+$
             '_{-'+STRTRIM(string(format='(F9.4)',errorm),2)+'}'+$
             ' ADU'
           fitres=result(1)
           ;; print peak value and errors
           xyouts,0.10,0.89,textoidl(centerstr),alignment=0.,/normal
           
           IF (fitpeak(0) NE 1.) THEN BEGIN
               ampl=result(1)/peakvalue(fitpeak)
               xyouts,0.70,0.92,'Ampl. = '+string(format='(F7.4)',ampl)+' ADU/eV', $
                 alignment=0.,/normal    
               fwhm=peakvalue(fitpeak)*2.*SQRT(2.*ALOG(2.))*f(2)/f(1)
               errorp=(error(1,2)-result(2))/ampl
               errorm=(result(2)-error(0,2))/ampl             
               sigmastr='\sigma ='+string(format='(F9.4)',result(2)/ampl)+$
                 ' ^{+'+STRTRIM(string(format='(F9.4)',errorp),2)+'}'+$
                 '_{-'+STRTRIM(string(format='(F9.4)',errorm),2)+'}'+$
                 ' eV'
               xyouts,0.70,0.89,textoidl(sigmastr),$
                 alignment=0.,/normal               
               xyouts,0.70,0.86,'FWHM= '+$
                 string(format='(F9.3)',fwhm)+' eV', $
                 alignment=0.,/normal
           ENDIF 
           integral=f(0)*f(2)*SQRT(2*!PI)/bg
           xyouts,0.10,0.86,'Integral= '+$
             string(format='(F9.3)',integral)+' Events', $
             alignment=0.,/normal
           ;; end of to be done
           resid=gauss/gspek
           plot, xxx, resid, XRANGE=[minimum,maximum],title='',$
             position=[0.10,0.25,0.96,0.35],$
             yrange=[0.,3.],$
             ytitle='Residual',XTITLE=xtit2, PSYM=1, /XSTYLE, $
             YLOG=logplot, MIN_VALUE=.1*logplot,/normal,/noerase           
       ENDIF ELSE BEGIN
           print,'% MKSPECTRUM: Gauss Fit not possible - Not enough data points !'
       ENDELSE
   ENDIF 
   
   IF (psplot EQ 1) THEN BEGIN  ; close ps device if neccessary
       xyouts,0.10,0.95,'Comment: '+comment,$
         alignment=0.,/normal
       xyouts,0.98,0.03,'IAAT by '+user+'@'+host+' '+date,charsize=0.9, $
         alignment=1.,/normal
       device,/close
       set_plot,'x'
   ENDIF
   
   IF (keyword_set(ghost) AND (psplot EQ 1)) THEN BEGIN 
       spawn, 'gv '+plotfile,/sh
   ENDIF  
   data=olddata
END 

