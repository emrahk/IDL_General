PRO xdrlc_r,lcname,time,rate, $
            select=select,history=history, $
            gaps=gaps,nogap=nogap,dseg=dseg, $
            nt=nt,nch=nch,bt=bt,first=first,last=last,$         
            chatty=chatty
;+
; NAME: 
;          xdrlc_r
;
;
; PURPOSE:
;          read a multidimensional lightcurve and some extra information 
;          (e.g., about gaps) in xdr format that have been written by xdrlc_w
;
;
; FEATURES: 
;          read a multidimensional lightcurve, i.e., the time array
;          ``time'', the multidimensional rate array ``rate'', the
;          keywords (``history'', ``gaps'', ``dseg'', ``nt'', ``nch'',
;          ``bt'', ``first'', ``last'') from the xdr file ``lcname'';
;          the optional input ``select'' allows to select a certain
;          lightcurve set; the order and IDL formats of the output
;          components are documented in the ASCII file
;          ``xdrlc.format'' (see also OUTPUTS and OPTIONAL OUTPUTS);
;          gzipped files can also be read (automatically)
;   
;
; CATEGORY: 
;          timing tools
;
;
; CALLING SEQUENCE:   
;          xdrlc_r,lcname,time,rate, $
;                  select=select,history=history, $
;                  gaps=gaps,nogap=nogap,dseg=dseg, $
;                  nt=nt,nch=nch,bt=bt,first=first,last=last,$
;                  chatty=chatty
;
; 
; INPUTS:             
;          lcname : string containing the file name of
;                   the multidimensional lightcurve in xdr format
;                   that is to be read     
;
;
; OPTIONAL INPUTS:    
;          select : integer giving the column number of the
;                   multidimensional rate array that is
;                   to be read (starting with number 1);
;                   default: all columns of the rate array are read   
;   
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0      
;
;
; OUTPUTS:            
;          time    (dblarr(nt))     : time array of the xdr lightcurve
;          rate    (fltarr(nt,nch)) : multidimensional rate array of
;                                     the xdr lightcurve, e.g., for a
;                                     number (nch) of different energy
;                                     channels  
;
; OPTIONAL OUTPUTS:   
;          history (strarr(nhist))  : string array describing the different
;                                     processing steps of the
;                                     lightcurve;   
;                                     [an example for a typical history string 
;                                     array produced by the analysis of 
;                                     RXTE/PCA lightcurves (using 
;                                     rxte_syncseg.pro and rxte_fourier.pro)
;                                     is given by the ASCII file history.bsp;
;                                     this example has been written by 
;                                     xdrfu_w[1,2].pro, routines similar to 
;                                     xdrlc_w.pro but for Fourier quantities 
;                                     instead of for lightcurves]             
;          gaps    (dblarr(ngaps))  : double array giving the lightcurve
;                                     indices where gaps start
;          nogap   (long)           : integer indicating whether there are gaps
;                                     nogap=0: not known
;                                     nogap=1: there are no gaps
;                                     nogap=2: there are gaps, 
;                                              all gaps are given in ``gaps''
;          dseg    (long)           : parameter containing the segment length
;                                     in bins if the lightcurve is
;                                     segmented; if the lightcurve is
;                                     not segmented or dseg is unknown
;                                     then dseg=-1L    
;          nt      (long)           : dimension of the time array 
;          nch     (long)           : number of columns of the rate
;                                     array, e.g., number of energy channels  
;          bt      (double)         : bintime in units of the time
;                                     array; given by the first time bin
;          first   (double)         : smallest time value in units of
;                                     the time array  
;          last    (double)         : biggest time value in units of
;                                     the time array 
;                     
;
; COMMON BLOCKS:      
;          none
;
;
; SIDE EFFECTS:       
;          none
;
;
; RESTRICTIONS:       
;          the multidimensional xdr lightcurve has to be written
;          by the xdrlc_w.pro routine 
;
;
; PROCEDURES USED:
;          none
;
;
; EXAMPLE:            
;          xdrlc_r,'0016384_seg.xdrlc',time,rate, $
;                  select=2,history=history, $
;                  gaps=gaps,nogap=nogap,dseg=dseg, $
;                  nt=nt,nch=nch,bt=bt,first=first,last=last,$  
;                  chatty=chatty 
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled  
;          Version 1.2, 2000/10/26 Katja Pottschmidt,   
;                                  IDL header: minor changes,
;                                  keyword default values defined/changed    
;          Version 1.3, 2000/10/30 Katja Pottschmidt,   
;                                  IDL header: minor changes      
;          Version 1.4, 2001/02/20 Katja Pottschmidt,
;                                  gzipped files can now also be read 
;                                  (works automatically)           
;          Version 1.5, 2001/07/10 Katja Pottschmidt,
;                                  if the non-gzipped file does not
;                                  exist, the gzipped file is read 
; 
;   
;-
   
   
;; set default values
IF (n_elements(chatty) EQ 0) THEN chatty=1


;; open input xdr file   
IF (NOT file_exist(lcname)) THEN lcname=lcname+'.gz'
openr,unit,lcname,/get_lun,/xdr,/compress
   
   
;; read and check version
version=''
readu,unit,version   
IF ( version NE 'xdrlc 1.0') THEN BEGIN
    message,'Problem in xdrlc: versionstring wrong'
ENDIF 
   
   
;; read history
nhist=0L
readu,unit,nhist
history=strarr(nhist)
readu,unit,history
   
   
;; read helpful parameters
nt=0L     & readu,unit,nt
nch=0L    & readu,unit,nch
bt=0D0    & readu,unit,bt
first=0D0 & readu,unit,first
last=0D0  & readu,unit,last
   
   
;; read gaps
ngaps=0L
readu,unit,ngaps
gaps=dblarr(ngaps)
readu,unit,gaps
   
   
;; read helpful parameters
nogap=0L  & readu,unit,nogap
dseg=0L   & readu,unit,dseg
   
   
;; read time array
time=dblarr(nt)
readu,unit,time


;; read rate array
IF (n_elements(select) NE 0) THEN BEGIN
    select=fix(select)
    rate=fltarr(nt)
    FOR i=0,select-1 DO BEGIN 
        readu,unit,rate
    ENDFOR 
ENDIF ELSE BEGIN 
    rate=fltarr(nt,nch)
    rattmp=fltarr(nt)
    FOR i=0,nch-1 DO BEGIN 
        readu,unit,rattmp
        rate[*,i]=rattmp
    ENDFOR 
ENDELSE    


;; close input xdr file 
free_lun,unit   
   
   
END 









