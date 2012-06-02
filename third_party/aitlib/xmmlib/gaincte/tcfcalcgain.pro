PRO tcfcalcgain,file,quad,ccdid,emin=emin,emax=emax,erange=erange,$
               bg=bg,notsingles=notsingles,ccorr=ccorr,$
               minline=minline,maxline=maxline,mincol=mincol,maxcol=maxcol,$
               gain=gain,bin=bin,errf=errf,plot=plot,ps=ps,chatty=chatty
;+
; NAME:            tcfcalcgain
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
;                  tcfcalcgain,"HK000125.000",0,9,emin=1000,emax=1500,erange=100,/plot
;
; 
; INPUTS:
;                  file :  name of the HK file
;                  quad :  quadrant of ccd containing the data (0..3)
;                  ccdid :  number of ccd containing the data (0..11)
;   
;
; OPTIONAL INPUTS:
;                  emin: the minimum energy value in ADU 
;                  emax: the maximum energy value in ADU
;		   minline, maxline, mincol, maxcol: area on ccd from which data is 
;							to be taken
;                  bg     : binsize
;                  erange : half energy interval
;
; KEYWORD PARAMETERS:
;                  notsingles :  don't apply single correction
;                  plot :  plot gain curve
;                  ps :  save plot as ps-file
;                  chatty :  print more information   
;                  gcorr: do gain correction with existing gain file
;                  ccorr: do cte correction with existing cte file
;
;
; OUTPUTS:
;                  gain :  FLTARR(64) containing the gain values
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
;                  read data from file, apply single correction,
;                  call program tccalcgain,
;                  details see code
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 25.01.00 T. Clauss first version
;-
   
   
   print,'% TCFCALCGAIN: Reading data in quadrant ',strtrim(quad,2)
   mkreadquad,file,quad,data=data
   
   IF (NOT keyword_set(notsingles)) THEN BEGIN
       print,'% TCFCALCGAIN: Selecting singles only'  
       result=mksplit(data,singles=sdata)
       data=sdata
   ENDIF
      
   IF keyword_set(ccorr) THEN BEGIN 
       print,'% TCFCALCGAIN: CTE correction'  
       data=tccte(data,ccdid,minline=minline,maxline=maxline,hkfile=file)
   ENDIF
      
   print,'% TCFCALCGAIN: Calculating gain'
   
   tccalcgain,data,ccdid,emin=emin,emax=emax,erange=erange,$
     minline=minline,maxline=maxline,mincol=mincol,maxcol=maxcol,$
     gain=gain,bg=bg,bin=bin,errf=errf,plotfit=plot,file=file,chatty=chatty
       
   IF (keyword_set(plot) OR keyword_set(ps)) THEN BEGIN 
       open_print,'gain.ps',/postscript
       plot,gain
       close_print
   ENDIF 
END







