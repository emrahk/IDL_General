PRO create_times,time0,duration,delta,name
;+
; NAME:
;       create_times
;
;
; PURPOSE:
;       create a file containing a list of times. A proper gti file
;       can be created from this file.
;
;
; CATEGORY:
;       
;
;
; CALLING SEQUENCE:
;       create_times,zerotime,length,delta_t,filename
;
; 
; INPUTS:
;       zerotime : the first entry in the times list
;       length   : the total length of the times list (in timeunits)
;       delta_t  : the step between to succeeding times
;       filename : name of the output file
;
;
; PROCEDURE:
;       a simple appropriate array is created and written to the
;       specified file
;
;
; EXAMPLE:
;       create_times,6.7574000E7,10000.,0.1,'test.txt'
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm, AIT
;-



;;time0 : starttime OF the observation
;;duration : length OF the observation (in sec)
;;delta : timestep in sec 
;;name : name OF the outputfile

IF (n_elements(time0) EQ 0) THEN time0 = 6.7574000E7
IF (n_elements(duration) EQ 0) THEN duration = 1.0E4
IF (n_elements(delta) EQ 0) THEN delta = 0.25
IF (n_elements(name) EQ 0) THEN name = 'times.asc'

t = dindgen(duration/delta)
t = t * delta + time0 

openw,1,name
printf,1,t,format='(D15.4)'
close,1

END


