PRO mkmakevent,data,file,mode,srcpos,quad,maxen=maxen,minen=minen,$
               outpath=outpath,nocorr=nocorr,cycle=cycle,chatty=chatty,$
               single=single,gain=gain,cte=cte,factor=factor,$
               fs=fs,filter=filter
;+
; NAME:            mkmakevent
;
;
;
; PURPOSE:
;                  Apply mode dependent time correction to the data
;                  and save the data as a Fits event file.
;
;
;
; CATEGORY:
;                  XMM-Data-Analysis/Timing
;
;
; CALLING SEQUENCE:
;                  mkmakeevent,data,file,'timing',190,1,minien=400,maxen=2500,/chatty
;                  
;                  
; 
; INPUTS:
;                  data     : Name of the data-structure
;                  file     : Name of the output event file; an
;                             extension showing the quadrant and read
;                             out mode is added.
;                  mode     : String describing the readout mode of
;                             the ccd. Valid modes are:
;                                  'full'   for Full Frame Mode
;                                  'extend' for extended Full Frame
;                                           Mode
;                                  'small'  for Small Window Mode
;                                  'large'  for Large Window Mode
;                                  'timing' for Timing Mode
;                                  'burst'  for Burst Mode
;                  sourcepos: Line number giving the position of the
;                             source on the ccd  
;                  quad     : Quadrant the data is taken from
;
;
; OPTIONAL INPUTS:
;                  outpath  : The path where the FITS-Files are
;                             written to. (default './')
;                  minen    : Minimum energy level. All events above
;                             this level are used for the event file
;                             generation. 
;                  maxen    : Maximum energy level. All events below
;                             this level are used for the event file
;                             generation.
;                  factor   : Do not use this parameter unless you
;                             know very well what you are doing !!!
;                  filter   : Name the filter used during the
;                             observation. This information is written
;                             to the fits header.
;                  
;
;      
; KEYWORD PARAMETERS:
;                  /single : Use only singles events
;                  /cte    : Apply a cte correction
;                  /gain   : Apply a gain correction 
;                  /nocorr : No mode-dependant time correction is
;                            done. Only a uncorrected lightcurve is
;                            generated. Especially to determine the
;                            cyclus time of each mode.
;                  /cycle  : Determine the frametime for one readout
;                            cycle from given data and use this
;                            time to perform the
;                            timecorrection. Otherwise the default
;                            frametime derived from the hardware
;                            oszillator of the EPEA is used.
;                  /fs     : Set FITS-keyword model to 'FS', default
;                            is 'FM'
;                  /chatty : Give more information on what's going
;                            on
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
;                  mkmakevent,data,file,'full',190,0,/chatty
;                             
;
;
; MODIFICATION HISTORY:
; V1.0  15.05.00 M. Kuster first initial version
; V1.1  18.05.00 M. Kuster Energy window should be applied after all
;                          corrections; added docu header
;
;-   
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (keyword_set(fs)) THEN model='FS' ELSE model='FM'
   IF (NOT keyword_set(filter)) THEN filter='unknown'
   IF (NOT keyword_set(outpath)) THEN outpath='./'
   IF (NOT keyword_set(factor)) THEN factor=1.d0
   IF (keyword_set(nocorr)) THEN corr=0 ELSE corr=1
   IF (keyword_set(cycle)) THEN cylce=1 ELSE cycle=0
   
   print,'% MKMAKEVENT: Working on Quadrant '+STRTRIM(quad,2)+' ...'
   outfile=file+'_Q'+STRTRIM(quad,2)+'_'+mode
   
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
   
   ;; Set Energywindow according to minen and maxen
   IF (keyword_set(maxen) OR keyword_set(minen)) THEN BEGIN
       indx=where((data.energy GE minen) AND (data.energy LE maxen))
       data=data(indx)
   ENDIF 

   IF (data[0].time NE -1) THEN BEGIN ; science-data found -> begin to work
       IF (corr EQ 1) THEN BEGIN
           mkmodetime,data,srcpos,quad,mode,time=time,/fine,$
             comment='Results of File '+file,plotfile=outfile+'.ps',$
             /ps,/chatty,factor=factor,cycle=cycle
       END ELSE BEGIN
           mkmodetime,data,srcpos,quad,mode,time=time,/fine,$
             comment='Results of File '+file,plotfile=outfile+'.ps',$
             /ps,/nocorr,factor=factor,/chatty,cycle=cycle
       END
       data.time=time
       mkwritevent,outfile,data,quad,outpath=outpath,model=model,$
         filter=filter,/chatty
   END ELSE BEGIN               ; no science-data found -> give warning, nothing to do
       print,'% MKMAKEVENT: WARNING ! No science-data found in quadrant '+STRTRIM(quad,2)
   ENDELSE
END

