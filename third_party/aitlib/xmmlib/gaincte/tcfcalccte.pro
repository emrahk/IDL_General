PRO tcfcalccte,file,quad,ccdid,emin=emin,emax=emax,erange=erange,bg=bg,$
		minline=minline,maxline=maxline,bline=bline,$
		mincol=mincol,maxcol=maxcol,badcols=badcols,$
		cte=cte,errf=errf,peakf=peakf,plot=plot,ps=ps,stop=stop,chatty=chatty
	   
;+
; NAME:            tcfcalccte
;
;
;
; PURPOSE:
;		   Calculate CTE 
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tcfcalccte,"HK000125.000",0,9,emin=1000,emax=1500,bline=10,/plot
;
; 
; INPUTS:
;                  file :  name of the HK file
;                  quad :  quadrant of ccd containing the data (0..3)
;                  ccdid :  number of ccd containing the data (0..11)
;   
;
; OPTIONAL INPUTS:
;                  emin :  the minimum energy value in ADU 
;                  emax :  the maximum energy value in ADU
;                  erange : half energy interval for fit   
;                  bg   :  binsize   
;		   minline, maxline, mincol, maxcol :  area on ccd from which data is 
;							to be taken
;                  bline :  line binsize   
;                  badcols :  bad columns
;
;
; KEYWORD PARAMETERS:
;                  plot :  plot cte curve
;                  ps :  save plot as ps-file
;                  chatty :  print more information   
;                  stop :  stop before finishing the program
;                  errf: save sigmas from linfit to file
;                            CTE_??_err_HK...
;                  peakf: save peakpositions, errors, cte to file CTE_??_peakpos_HK...    
;
;
; OUTPUTS:
;                  cte :  FLTARR(64) containing the cte values
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
;                  For gain correction, there has to be an ascii gain
;                  file with a filename of the form CTE_??_HK??????_???.dat
;
;
; PROCEDURE:
;                  read data from file, apply single correction,
;                  apply gain correction, call program tccalccte,
;                  details see code
;
;
; EXAMPLE:
;                  tcfcalccte,"HK991222.042",0,9,/mode2,emin=900,emax=1500,erange=100,$
;                              minline=141,bline=5,bg=3.0,/errf,/peakf,/plot,/chatty      
;                  
;
; MODIFICATION HISTORY:
; V1.0 25.01.00 T. Clauss, first version
; V1.1 19.04.00 T. Clauss, added keywords ERRF, PEAKF   
;-


   print,'% TCFCALCCTE: Reading data'  
   mkreadquad,file,quad,data=dat
   
   print,'% TCFCALCCTE: Selecting singles only'  
   result=mksplit(dat,singles=sdat)
   
   dat=0
   
   print,'% TCFCALCCTE: Gain correction'  
   data=tcgain(sdat,ccdid,hkfile=file)
   
   print,'% TCFCALCCTE: Calculating CTE'  
   
   tccalccte,data,ccdid,emin=emin,emax=emax,erange=erange,$
     minline=minline,maxline=maxline,bline=bline,$
     mincol=mincol,maxcol=maxcol,badcols=badcols,$
     bg=bg,cte=cte,errf=errf,peakf=peakf,plotfit=plot,file=file,chatty=chatty
   
   IF (keyword_set(plot) OR keyword_set(ps)) THEN BEGIN 
       open_print,'cte.ps',/postscript
       plot,cte
       close_print
   ENDIF 
   IF (keyword_set(stop)) THEN stop
END 































































































