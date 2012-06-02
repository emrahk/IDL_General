PRO mkstatistics,data,ccd,ccdstat,chatty=chatty
;+
; NAME:
;              mkstatistics
;
;
; PURPOSE:
;              Print Information on the number of events, count rate
;              and some small statistics.
;
;
; CATEGORY:
;              XMM-Data analysis
; 
;
; CALLING SEQUENCE:
;               mkstatistics,data,ccd,ccdstat=ccdstat,/chatty
;               
; 
; INPUTS:
;               data   : 
;
;
; OPTIONAL INPUTS:
;               none
;
;      
; KEYWORD PARAMETERS:
;               chatty : Give more information on what's going
;                        on;
;
;
; OUTPUTS:
;               ccdstat : A structure containing the statistical
;                        information on the data analyzed. 'stat' has
;                        the following structure:
;                        stat={stat,events:long(0), singles:long(0),
;                        splits:long(0), rate:double(0),
;                        fract:double(0), duration:double(0),
;                        tstart:double(0), tstop:double(0)}
;                        For a more detailed explanation see code !
;
;
; OPTIONAL OUTPUTS:
;               none
;
; COMMON BLOCKS:
;               none
;
;
; SIDE EFFECTS:
;               none
;
;
; RESTRICTIONS:
;               none
;
;
; PROCEDURE:
;               see code
;
;
; EXAMPLE:
;               mkstatistics,'/cdrom/hk/hk980224.053',2,/chatty
;
;
; MODIFICATION HISTORY:
; V 1.0 26.10.99 M. Kuster first initial version
; V 1.1 13.12.99 M. Kuster user has to read in data first with, e.g. mkreadquad
;-

   ccdstat={stat,events:long(0),singles:long(0),splits:long(0),rate:double(0),$
         fract:double(0),duration:double(0),tstart:double(0),tstop:double(0)}
   
   quadrant=[0,0,0,1,1,1,2,2,2,3,3,3]
   
   IF (data NE -1) THEN BEGIN 
       ind=where(data.ccd EQ ccd)
       IF (ind[0] NE -1 ) THEN BEGIN
           ccdstat.events  =n_elements(ind)
           ccdstat.tstart  =data(ind(0)).time
           ccdstat.tstop   =data(ind(n_elements(ind)-1)).time
           ccdstat.duration=ccdstat.tstop-ccdstat.tstart
           ccdstat.rate    =ccdstat.events/ccdstat.duration
           ccdstat.fract   =double(n_elements(ind))/double(n_elements(data.ccd))*100d0
           data            = mksplit(data(ind),singles=singles,splits=splits)
           ccdstat.singles = n_elements(singles)
           ccdstat.splits  = n_elements(splits)
           IF (keyword_set(chatty)) THEN BEGIN 
               print,'% MKSTATISTICS: *********************************'
               print,'% MKSTATISTICS: Number of events in CCD   '+string(format='($,F2.0)',ccd)+$
                 '      '+$
                 string(format='($,F12.0)',ccdstat.events)
               print,'% MKSTATISTICS: Number of singles in this CCD    '+$
                 string(format='($,F12.4)',ccdstat.singles)+' events'
               print,'% MKSTATISTICS: Number of splits in this CCD     '+$
                 string(format='($,F12.4)',ccdstat.splits)+' events'       
               print,'% MKSTATISTICS: Mean-Rate in this CCD                   '+$
                 string(format='($,F10.4)',ccdstat.rate)+' counts/sec'
               print,'% MKSTATISTICS: Fraction of total counts in Quadrant    '+$
                 string(format='($,F5.2)',ccdstat.fract)+' %'       
               print,'% MKSTATISTICS: Start time of observation       '+' '+$
                 string(format='($,F12.5)',data(0).time)+' sec'
               print,'% MKSTATISTICS: Start time of observation in CCD'+' '+$
                 string(format='($,F12.5)',ccdstat.tstart)+' sec'
               print,'% MKSTATISTICS: Stop time of observation  in CCD'+' '+$
                 string(format='($,F12.5)',ccdstat.tstop)+' sec'       
               print,'% MKSTATISTICS: Length of observation           '+' '+$
                 string(format='($,F12.4)',ccdstat.duration)+' sec'
               print,'% MKSTATISTICS: *********************************'
           ENDIF   
       ENDIF ELSE BEGIN 
           print,'% MKSTATISTICS: *********************************'
           print,'% MKSTATISTICS: No science data found !'
           print,'% MKSTATISTICS: *********************************'
           ccdstat=-1
       ENDELSE
   ENDIF ELSE BEGIN 
       print,'% MKSTATISTICS: *********************************'
       print,'% MKSTATISTICS: No science data in file !'
       print,'% MKSTATISTICS: *********************************'
       ccdstat=-1
   ENDELSE 
END

