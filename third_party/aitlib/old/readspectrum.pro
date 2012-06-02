PRO readspectrum,path,name,counts,counterr,subback=subback, $
                 backfile=backfile,respfile=respfile
;+
; NAME:
;       readspectrum
;
;
; PURPOSE:
;       read a pha file and return the counts and error column
;       and the name of the background and response file. The
;       background can be subtracted
;
;
; CATEGORY:
;       spectra
;
;
; CALLING SEQUENCE:
;       readspectrum,path,filename,counts,error,backfile=backfile,
;       respfile=respfile,/subback 
;
; 
; INPUTS:
;       path : path to the spectrum
;       filename : name of the spectrum
;       
;
;
; OPTIONAL INPUTS:
;
;
;	
; KEYWORD PARAMETERS:
;       /subback : if thereis a backgroundfile entry in the .pha file,
;       this backgroundfile should be read and subtracted from the
;       .pha file
;
;
; OUTPUTS:
;       counts : array containing the counts per channel
;       error  : array containing the errors per channel
;
;
; OPTIONAL OUTPUTS:
;       backfile : name of the background file
;       respfile : name of the response file
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;       readspectrum,'/usr/users/kreyken/velax1/obs2/stdb.pha',
;       counts,error,backfile=back,respfile=resp,/subback
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm
;-

;; initialize some variables
rf = 'Test'
bf=rf
exposure = 0.
bexp = 0.

;; now read the spectrum from an OGIP PHA file.
;; c contains the counts, ce the error, rate is 1 if counts contains
;; really counts or 0 if counts contains contRATES, back is 1 if a
;; background is given, path+name : path and name to the pha file,
;; exposure is the exposure time, poisson is one if poisson error
;; statistic applies, repsonse and backfile contain the appropriate
;; files.

readpha,c,ce,rate,back,path+name,exposure=exposure, $
  poisson=pa,response=rf,backfile=bf

IF (rate EQ 0) THEN exposure = 1. 
;; Do not make an exposure time correction, if we already have count rates 
respfile = rf
backfile = bf
;; if background shall be subtracted, then read in the packground pha
;; file given in the data pha file, else create an empty background array

IF (keyword_set(subback)) THEN BEGIN
    readpha,cb,ceb,r,b,path+bf,exposure=bexp
END ELSE BEGIN
    cb = 0
    bexp = 1
END 

;; If poisson statistic applies, calculate the error and do exposure
;; time correction in all cases for the errors
IF (pa EQ 1) THEN BEGIN
    counterr = sqrt(c)/exposure 
END ELSE BEGIN 
    counterr = ce/exposure 
END 

;; do the background subtraction and the exposure time correction
counts = c/exposure - cb/bexp
END 

