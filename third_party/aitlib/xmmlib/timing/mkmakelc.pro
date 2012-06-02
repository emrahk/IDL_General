PRO mkmakelc,data,file,binsize,mode,srcpos,quad,maxen=maxen,minen=minen,time=time,rate=rate,error=error,$
             outpath=outpath,chatty=chatty,single=single,gain=gain,cte=cte,abrixas=abrixas,fs=fs,orsay=orsay,$
             date=date,filter=filter,plot=plot
;+
; NAME:            mkmakelc
;
;
;
; PURPOSE:
;                  Build a lightcurve from data and save the
;                  lightcurve in fits-format.
;
;
;
; CATEGORY:
;                  XMM-Timing Analysis / I/O
;
;
; CALLING SEQUENCE:
;                  mkwritelc,file,/chatty
;                  
;                  
; 
; INPUTS:
;                  data     : Name of the data-array
;                  binsize  : Binsize of the lightcurve in seconds    
;                  mode     : String describing the readout mode of
;                             the ccd. Valid modes are:
;                                  'full'   for Full Frame Mode
;                                  'extend' for extended Full Frame
;                                           Mode
;                                  'small'  for Small Window Mode
;                                  'large'  for Large Window Mode
;                                  'timing' for Timing Mode
;                                  'burst'  for Burst Mode
;                  srcpos   : Position of the Source-PSF on the
;                             detector; only important for the
;                             timecorrection in timing- and
;                             burst-mode. Otherwise a dummy value like
;                             0 can be given.
;                  quad     : Quadrant the data is taken from
;
;
; OPTIONAL INPUTS:
;                  outpath  : The path where the FITS-Files are
;                             written to. (default './')
;                  
;
;      
; KEYWORD PARAMETERS:
;                  /abrixas: Set FITS-keyword telescope to 'ABRIXAS',
;                            default is 'XMM'
;                  /fs     : Set FITS-keyword model to 'FS', default
;                            is 'FM'
;                  /orsay  : Set FITS-Keyword campaign to
;                            'Orsay-Calibration', default is
;                            'Panter-Calibration'.
;                  /chatty : Give more information on what's going
;                            on
;                  /plot   : The lightcurves arre plotted on the
;                            screen. 
;                  
;    
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;                  time   : A vector containing the mode-dependent
;                           corrected timinformations
;                  rate   : A vector containing the rate in counts/sec
;                           for each time.
;                  error  : A vector containing the error in
;                           counts/sec for each time.
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
;                  mkwritelc,file,0.001,'full',0,/plot,/chatty
;                             
;
;
; MODIFICATION HISTORY:
; V1.0  8.02.98 M. Kuster first initial version, no timecorrection for
;                         different readout modes so far
; V1.1 12.05.99 M. Kuster changed calculation of rate, added some
;                         keywords and added mode-name to the
;                         outfile-name 
;-   
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (keyword_set(fs)) THEN model='FS' ELSE model='FM'
   IF (keyword_set(abrixas)) THEN telescope='ABRIXAS' ELSE telescope='XMM'
   IF (keyword_set(orsay)) THEN campaign='Orsay-Calibration' ELSE $
     campaign='Commisioning Phase'
   IF (NOT keyword_set(filter)) THEN filter='medium'
   IF (NOT keyword_set(date)) THEN date='00.00.0000'
   IF (NOT keyword_set(outpath)) THEN outpath='./'
   IF (keyword_set(nocorr)) THEN corr=0 ELSE corr=1
   IF (keyword_set(cycle)) THEN cylce=1 ELSE cycle=0
   IF (keyword_set(plot)) THEN plot=1 ELSE plot=0
   time=0
   
   print,'% MKMAKELC: Working on Quadrant '+STRTRIM(quad,2)+' ...'
   outfile=file+'_Q'+STRTRIM(quad,2)+'_'+mode
   
   ;; Set Energywindow according to minen and maxen
   IF (keyword_set(maxen) OR keyword_set(minen)) THEN BEGIN
       indx=where((data.energy GE minen) AND (data.energy LE maxen))
       data=data(indx)
   ENDIF 

   ;; Apply split-event correction
   IF (keyword_set(single)) THEN BEGIN
       data=mksplit(data)
       singleid=where(data.split EQ 0)
       data=data(singleid)
   ENDIF 
   
   ;; Apply gain-correction
   IF (keyword_set(cte)) THEN BEGIN
       data=mkcte(data)
   ENDIF 
   
   ;; Apply cte-correction
   IF (keyword_set(gain)) THEN BEGIN
       data=mkgain(data)
   ENDIF 

   IF (data[0].time NE -1) THEN BEGIN ; science-data found -> begin to work
       lightcurve=histogram(data.time,binsize=binsize) ; build lightcurve with binsize in seconds
       
       ;; build new time vektor for histogram
       n=n_elements(lightcurve)
       time=dindgen(n)*binsize+data(0).time ;; absolute zeit eintragen !!!!
       
       ;; calculate rate and error
       rate=lightcurve/binsize  ; rate in counts/sec
       error=sqrt(rate)         ; no dead-time correction so far
       
       IF (plot EQ 1) THEN BEGIN 
           plot,time,rate,title='Lightcurve Quadrant '+STRTRIM(quad,2),psym=10,/xstyle,$
             xtitle='Time / seconds',ytitle='Rate / counts per second',/ynozero
       ENDIF 
       mkwritelc,outfile,time,rate,error,outpath=outpath,model=model,ccdmode=mode,$
         quadrant='Quadrant '+STRTRIM(quad,2),campaign=campaign,dateobs=date,dateend=date,$
         telescope=telescope,filter=filter,/chatty
   END ELSE BEGIN               ; no science-data found -> give warning, nothing to do
       print,'% MKMAKELC: WARNING ! No science-data found in quadrant '+STRTRIM(quad,2)
   ENDELSE
END
