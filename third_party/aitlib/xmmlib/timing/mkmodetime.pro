PRO mkmodetime,data,sourcepos,quad,mode,time=time,frametime=frametime,$
               nocorr=nocorr,cycle=cycle,plotfile=plotfile,ps=ps,ghost=ghost,$
               fine=fine,factor=factor,swaps=swaps,comment=comment,chatty=chatty
;+
; NAME:            
;                  mkmodetime
;
;
;
; PURPOSE:
;                  Apply time correction to the photon arrival times
;                  for different readout Modes of the XMM pn-CCD for
;                  timing analysis.
;
;
; CATEGORY:
;                  XMM-Data-Analysis/Timing
;
;
; CALLING SEQUENCE:
;                  mkmodetime,data,190,0,'timing',/chatty
;                  
;                  
; 
; INPUTS:
;                  data     : Data structure of one quadrant containing
;                             line, column, energy, seconds, subseconds,
;                             time and ccd information
;                  sourcepos: Line number giving the position of the
;                             source on the ccd  
;                  quad     : The quadrant the data is taken from    
;                  mode     : String describing the readout mode of
;                             the ccd. Valid modes are:
;                                  'full'   for Full Frame Mode
;                                  'extend' for extended Full Frame
;                                           Mode
;                                  'small'  for Small Window Mode
;                                  'large'  for Large Window Mode
;                                  'timing' for Timing Mode
;                                  'burst'  for Burst Mode
;
; OPTIONAL INPUTS:
;                  plotfile : Name of the file for the results of the
;                             frametime determination.
;                  ps       : Print results of mkframtime to a
;                             ps-file.
;                  ghost    : Show plot in ghostview (automatically). 
;                  factor   : Do not use this parameter unless you
;                             know very well what you are doing !
;
;
;      
; KEYWORD PARAMETERS:
;                  /nocorr : No event-time correction is done; only
;                            usefull to determine frame time.
;                  /cycle  : Determine the frametime for one readout
;                            cycle from the given data and use this
;                            time to perform the
;                            timecorrection. Otherwise a default
;                            frametime is used. 
;                  /swaps  : Remove swaps in HK-Data produced bye
;                            PEP-Station or what ever. BE CAREFUL WITH
;                            THIS OPTION !!!!!
;                  /chatty : Give more information on what's going
;                            on
;                  /fine   : Apply a time correction with respect to
;                            the line in with the photon is
;                            detected. This keyword only affects
;                            'timing' and 'burst' mode.
;                  
; OUTPUTS:
;
;
; OPTIONAL OUTPUTS:
;                  time     : The mode dependant corrected time vektor
;                             in seconds.
;                  frametime: The frame time found in the data 
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  A the moment the time is hold in two vaiables, the
;                  input data and the variable 'time' -> needs a lot
;                  of memory -> needs improvement !
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
;                  mkmodetime,data,mode='burst',time=time,/chatty
;                             
;
;
; MODIFICATION HISTORY:
; V1.0   7.04.99 M. Kuster first initial version, no timecorrection for
;                          different readout modes so far
; V1.1   8.04.99 M. Kuster added time correction for all readout modes
;                          at the moment the frametime is fixed and not
;                          calculated from the dataset.
; V1.2  12.05.99 M. Kuster Fixed bug with double precision in time
;                          calculation
; V1.21 18.05.99 M. Kuster First idear for the frametime
;                          calculation. Formulas have to be changed for a
;                          variable frametime.
; V1.22 25.05.99 M. Kuster epoch folding for frame time determination
;                          added    
; V1.23 04.06.99 M. Kuster default start and stop times for epoch
;                          folding in the different modes added
; V1.23 05.06.99 M. Kuster added printout of lc, chi-square and pulse
; V1.24 26.10.99 M. Kuster changed data format from array to structure
; V1.25 23.02.00 M. Kuster added keyword swaps 
; V1.26 18.04.00 M. Kuster changed Timig-Mode to 739 Clks per TS
; V1.27 10.05.00 M. Kuster If frametime is not calculated from the
;                          data, take defaults depending on
;                          readout-mode
; V1.28 10.05.00 M. Kuster don't subtract time(0) any more   
; V2.00 18.05.00 M. Kuster Updated all constants for time conversion
;                          according to the ASIC reference design
;
;-   
   
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (keyword_set(cycle)) THEN cycle=1 ELSE cycle=0
   IF (keyword_set(ps)) THEN psplot=1 ELSE psplot=0
   IF (keyword_set(fine)) THEN fine=1 ELSE fine=0
   
   time=data.time               ; 
   numti=n_elements(time)       ; get number of elements in time
   time=reform(time,numti)      ; create vector out of array(1,*)

   ;; remove swaps !!!!!
   ;; This is only needed for data taken with the pep-station or for
   ;; orbit data with wrong time tages (commissioning phase)
   IF (keyword_set(swaps)) THEN BEGIN 
       noswps=where(time LT 5000)
       time=time(noswps)
       data=data(noswps)
   ENDIF 

   ;; calculate frame time from data by epoch folding 
   IF (cycle EQ 1) THEN BEGIN    
       mkframetime,time,mode,comment=comment,clock=clock,factor=factor,plotfile=plotfile,ps=ps,ghost=ghost,/chatty
       print,'% MKMODETIME:******* Got clock-period of '+string(format='(F20.15)',clock)+' sec ******'
   ENDIF ELSE BEGIN 
       CASE mode OF             ; mode dependant default values got from cal data
           'full': BEGIN
               clock=0.00000004000d0
           END 
           'extend': BEGIN      ; extended Full Frame Mode (checked)
               clock=0.00000004000d0
           END 
           'small': BEGIN       ; Small Window Mode only one ccd is active
               clock=0.000000040000246d0
           END 
           'large': BEGIN       ; Large Window Mode
               clock=0.00000004000d0
           END 
           'timing': BEGIN      ; Timing Mode only one ccd is active
               clock=0.000000039999980d0
           END            
           'burst': BEGIN       ; Burst Mode only one ccd is active
               clock=0.000000039999246d0
           END 
       ENDCASE            
       print,'% MKMODETIME:******* Got default clock-period of '+string(format='(F20.15)',clock)+' sec ******'
   ENDELSE 

   ;; Transformation according to the document 'Time resolution
   ;; capability of the XMM EPIC pn-CCD in different readout modes'
   ;; by M. Kuster et. al., SPIE 1999
   IF (NOT keyword_set(nocorr)) THEN BEGIN
       CASE mode OF 
           'full': BEGIN        ; Full Frame Mode (checked)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for Full Frame Mode ...'
               ENDIF
               FOR i=0, 2 DO BEGIN
                   ;; transformation to center of integration time of
                   ;; CCD number i 
                   ind=where(data.ccd EQ (i+(quad*3))) ; index of the ccds
                   CASE i OF 
                       0: BEGIN 
                           time(ind)=time(ind)-(1280847d0 * clock) ; timetransformation
                       END 
                       1: BEGIN 
                           time(ind)=time(ind)-(1128087d0 * clock) ; timetransformation
                       END 
                       2: BEGIN 
                           time(ind)=time(ind)-( 975332d0 * clock) ; timetransformation
                       END 
                   ENDCASE 
               ENDFOR
           END       
           
           'extend': BEGIN      ; extended Full Frame Mode (checked)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for ext. Full Frame Mode ...'
               ENDIF
               FOR i=0, 2 DO BEGIN
                   ;; transformation to center of integration time of
                   ;; CCD number i
                   ind=where(data.ccd EQ (i+(quad*3))) ; index of the ccds
                   CASE i OF 
                       0: BEGIN 
                           time(ind)=time(ind)-(3902287d0 * clock ) ; timetransformation
                       END 
                       1: BEGIN 
                           time(ind)=time(ind)-(3749527d0 * clock ) ; timetransformation
                       END 
                       2: BEGIN 
                           time(ind)=time(ind)-(3596772d0 * clock ) ; timetransformation
                       END 
                   ENDCASE
               ENDFOR            
           END
           
           'small': BEGIN       ; Small Window Mode only one ccd is active (checked)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for Small Window Mode ...'
               ENDIF
               ;; transformation to center of integration time of CCD number 1
               time=time-(92024d0 * clock ) ; timetransformation
           END
           
           'large': BEGIN       ; Large Window Mode (cheched)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for Large Window Mode ...'
               ENDIF
               FOR i=0, 2 DO BEGIN
                   ;; transformation to center of integration time of CCD number i
                   ind=where(data.ccd EQ (i+(quad*3))) ; index of the ccds
                   CASE i OF 
                       0: BEGIN 
                           time(ind)=time(ind)-(825748.5d0 * clock ) ; timetransformation
                       END 
                       1: BEGIN 
                           time(ind)=time(ind)-(726529.5d0 * clock ) ; timetransformation
                       END 
                       2: BEGIN 
                           time(ind)=time(ind)-(627315.5d0 * clock ) ; timetransformation
                       END 
                   ENDCASE  
               ENDFOR          
           END
           
           'timing': BEGIN      ; Timing Mode only one ccd is active (checked)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for Timing Mode ...'
               ENDIF
               IF (fine EQ 1) THEN BEGIN
                   ls=fix(sourcepos/10)
                   ;; transformation to fine time in timing mode
                   time=time+ ( ( (data.line-200)-ls )*739d0 ) * clock
               ENDIF ELSE BEGIN 
                   ;; transformation to coarse time in timing mode
                   time=time-( (9-fix(data.line/20))*14780d0-7390d0 ) * clock
               ENDELSE 
           END
           
           'burst': BEGIN       ; Burst Mode only one ccd is active (checked)
               IF (chatty EQ 1) THEN BEGIN
                   print,'% MKMODETIME: Doing time-correction for Burst Mode ...'
               ENDIF
               IF (fine EQ 1) THEN BEGIN 
                   ;; transformation to fine time in burst mode
                   time=time-(105014d0+(sourcepos-data.line)*18d0) * clock
               ENDIF ELSE BEGIN 
                   ;; transformation to coarse time in burst mode ()
                   time=time-(106994d0 * clock)
               ENDELSE 
           END
       ENDCASE
   ENDIF
END

;; conversion linenumber i in timing mode to macro line number m
FUNCTION line2ml,line
   return,(line - fix(line/20)*20)
END 

;; conversion CCD linenumber i to macro line
FUNCTION ccd2ml,line
   return,(fix(line/10))
END 
