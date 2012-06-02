PRO delcount,time,count,time0=time0,startt,stopt
;+
; NAME:
;       delcount
;
;
; PURPOSE:
;       delete the specified counts in the lightcurve
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       delcount,time,count,time0=zerotime,startt=starttime,stopt=stoptime
;
; 
; INPUTS:
;       time      : the time column
;       count     : the count column
;       starttime : begin of the timeblock to be erased
;       stoptime  : end of the timeblock to be erased
;
;
; OPTIONAL INPUTS:
;       zerotime  : use starttime and stoptime relative to zerotime
;                   not to the first entry in the time column
;
;	
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       count : the modified count column
;
;
; SIDE EFFECTS:
;       ATTENTION : del_count does not remove the specified times from
;       the lightcurve but simply sets the counts to zero.
;
;
; RESTRICTIONS:
;       See side effects
;
;
; PROCEDURE:
;       
;
;
; EXAMPLE:
;       delcount,time,counts,time0=6.7574e7,startt=1000.,stopt=2000.
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm, AIT
;-




IF (n_elements(time0) EQ -1) THEN BEGIN
    stt = startt
    spt = stopt
END ELSE BEGIN
    stt = time0+startt
    spt = time0+stopt
END
idx = where((time GE stt) AND (time LT spt))
IF (n_elements(idx) GT 1) THEN count(idx) = 0
END
