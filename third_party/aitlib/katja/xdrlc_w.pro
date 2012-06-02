PRO xdrlc_w,lcname,time,rate, $
            history=history, $
            gaps=gaps,dseg=dseg,chatty=chatty,gzip=gzip 
;+
; NAME:
;          xdrlc_w
;
;
; PURPOSE:
;          write a multidimensional lightcurve, i.e., the time array,
;          the multidimensional rate array, and the keywords
;          to a file in xdr format
;
;
; FEATURES: 
;          write a multidimensional lightcurve, i.e., the time array
;          ``time'', the multidimensional rate array ``rate'', the
;          keywords (``history'', ``gaps'', ``dseg''), and further
;          information to the file ``lcname'' in xdr format; the order
;          and IDL formats of the output components are documented in
;          the ASCII file ``xdrlc.format'';
;          gzipped files are written, if ``gzip'' is set
;             
;   
; CATEGORY:
;          timing tools  
;
;
; CALLING SEQUENCE:
;          xdrlc_w,lcname,time,rate, $
;            history=history, $
;            gaps=gaps,dseg=dseg, $
;            chatty=chatty,gzip=gzip 
;
;
; INPUTS:
;          lcname   : string containing the file name of
;                     the multidimensional lightcurve in xdr format
;                     that is to be written 
;          time     : time array of the lightcurve; ``time'' is converted
;                     to a double array before it is written to lcname
;          rate     : multidimensional rate array of the lightcurve;
;                     ``rate'' is converted to a floating point array
;                     before it is written to lcname  
;
;   
; OPTIONAL INPUTS:
;          history  : string array;
;                     default: 'History is not known.';
;                     [an example for a typical history string array
;                     produced by the analysis of RXTE/PCA lightcurves
;                     (using rxte_syncseg.pro and rxte_fourier.pro) is given
;                     by the  ASCII file history.bsp; this example has
;                     been written by xdrfu_w[1,2].pro, routines
;                     similar to xdrlc_w.pro but for Fourier quantities
;                     instead of for lightcurves]
;          gaps     : array containing the startbins of gaps
;                     in the time array; ``gaps'' is converted to
;                     a double array before it is written to lcname;  
;                     default: -2D0;
;                     from the input given through ``gaps'', the internal
;                     parameter ``nogap'' is determined and written:
;                     nogap: integer indicating whether there are gaps
;                            nogap=0: not known
;                            nogap=1: there are no gaps
;                            nogap=2: there are gaps, all gaps are
;                                     given in ``gaps''   
;          dseg     : parameter containing the segment length in bins
;                     if the lightcurve is segmented; dseg is converted to
;                     a long word before it is written to lcname;   
;                     default: -1L
;   
;   
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0   
;          gzip     : if set, a gzipped file is written (.gz is
;                     appended to the lcname);
;                     default: undefined   
;
;
; OUTPUTS:
;          none, but see side effects (and optional outputs)
;
;
; OPTIONAL OUTPUTS:
;          (default values of the keywords history, gaps, dseg, and
;          chatty can be returned if those keywords are undefined in the
;          calling of xdrlc_w)
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:    
;          a file named lcname is written containing the time array,
;          the multidimensional rate array, the keywords, and further
;          information in xdr format; the order and IDL formats of
;          these output components are documented in the ASCII file
;          ``xdrlc.format'';  
;          warning: the IDL format of most of the input parameters is
;          redefined by the xdrlc_w routine, thus this routine might
;          change formats in a code (time: double array, rate:
;          floating point array, gaps: double array, dseg: long word)  
;
;  
; RESTRICTIONS:
;          none
;
;
; PROCEDURES USED:
;          none  
;
; EXAMPLE:
;          time=[findgen(100),150.+findgen(50)] 
;          rate=fltarr(n_elements(time),2)   
;          rate[*,0]=randomn(seed0,n_elements(time))
;          rate[*,1]=randomn(seed1,n_elements(time))
;          xdrlc_w,'test.lc',time,rate, $
;                  history='Test', $
;                  gaps=99L,dseg=10L,/chatty   
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/25 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed    
;          Version 1.3, 2000/10/26 Katja Pottschmidt,   
;                                  IDL header: minor changes   
;          Version 1.4, 2001/02/20 Katja Pottschmidt,
;                                  a gzipped file can now also be written: 
;                                  the gzip keyword has to be set
;          Version 1.5, 2001/07/10 Katja Pottschmidt,
;                                  files written to the ``processed''
;                                  directory are automatically gzipped
;   
;
;-
   
   
;; set default values
;; default values for history, gaps, and dseg see below
IF (n_elements(chatty) EQ 0) THEN chatty=1


;; lightcurve array format
time=double(time)
rate=float(rate)
   
   
;; open output xdr file
IF (strmatch(lcname,'*processed*') EQ 1) THEN gzip=1
IF (keyword_set(gzip)) THEN BEGIN
     openw,unit,lcname+'.gz',/get_lun,/xdr,/compress
ENDIF ELSE BEGIN   
     openw,unit,lcname,/get_lun,/xdr
ENDELSE 
  
 
;; write version
version='xdrlc 1.0'
writeu,unit,version
   
   
;; write history
IF (n_elements(history) EQ 0) THEN BEGIN
    history='History is not known.'
ENDIF 
nhist=n_elements(history)     & writeu,unit,nhist
writeu,unit,history


;; write helpful parameters
nt=n_elements(time)           & writeu,unit,nt
nch=n_elements(rate(0,*))     & writeu,unit,nch
bt=time[1]-time[0]            & writeu,unit,bt
first=double(min(time))       & writeu,unit,first 
last=double(max(time))        & writeu,unit,last


;; write gaps: array giving the lightcurve indices where gaps start
ngaps=n_elements(gaps)
IF (ngaps EQ 0L) THEN BEGIN
    nogap=0L
    gaps=dblarr(1)
    gaps=-2D0
ENDIF
IF (ngaps NE 0L) THEN BEGIN
    nogap=2L
ENDIF
IF (ngaps NE 0L) AND (gaps(0) EQ -1D0) THEN BEGIN
    nogap=1L
ENDIF
ngaps=n_elements(gaps)
writeu,unit,ngaps
writeu,unit,double(gaps)


;; write nogap: integer indicating wether there are gaps
;; nogap=0: not known
;; nogap=1: there are no gaps
;; nogap=2: there are gaps, all gaps are given in "gaps"
writeu,unit,long(nogap)


;; write dseg: integer giving the segment length of continuous data
;; if data have been segmented
IF (n_elements(dseg) EQ 0) THEN BEGIN
    dseg=-1L
ENDIF
writeu,unit,long(dseg)

 
;; write time and rate array
writeu,unit,time
FOR i=0,nch-1 DO BEGIN
    writeu,unit,rate[*,i]
ENDFOR 


;; close output xdr file 
free_lun,unit
   
   
END 











