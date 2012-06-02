PRO lcmerge,lclist,namefin, $
            channelrange=channelrange,bintime=bintime,factor=factor, $
            gaps=gaps,gapdura=gapdura,chatty=chatty
;+
; NAME: 
;          lcmerge
;
;
; PURPOSE: 
;          merge and write RXTE lightcurves of a given energy band, rebin,
;          find gaps
;
;
; FEATURES: 
;          a string array ``lclist'' containing the names of the FITS
;          lightcurves that are to be merged has to be given; the
;          lightcurves are read and chronologically sorted by
;          comparing the first time bin of all lightcurves - thus a
;          merged lightcurve is created; the ``bintime'' as a power of
;          2 in sec can be given to be used for a consistency check; the
;          lighcurve can be rebinned by an integer factor given by
;          ``factor''; a string array called ``history'' is created
;          containing the value of several keywords (``channelrange'',
;          ``bintime'', ``factor'') as well as the lightcurve indices
;          where gaps start and the gap lengths in the original
;          lightcurve (which are also optional array outputs named
;          ``gaps'' and ``gapdura''); the history, the gap array, and
;          the merged lightcurve are written to the xdr file
;          ``namefin''
;
;   
; CATEGORY:
;          timing tools for FITS lightcurves 
;
;
; CALLING SEQUENCE:
;          lcmerge,lclist,namefin, $
;                  channelrange=channelrange,bintime=bintime,factor=factor, $
;                  gaps=gaps,gapdura=gapdura,chatty=chatty
;
;
; INPUTS:
;          lclist       : string array containing the file names of
;                         the lightcurves in FITS format that are to be read 
;          namefin      : string giving the file name of the merged
;                         xdr output lightcurve (with the file also
;                         containing the history array and the gap array) 
;      
;   
; OPTIONAL INPUTS:
;          channelrange : string, containing the channel range (pha
;                         channels) of the energy band that is to be
;                         considered; this string is written into the
;                         history string (no other relevance in this
;                         procedure);  
;                         default entry in history string: 
;                         'Keyword channelrange has not been set (lcmerge)'   
;          bintime      : parameter containing the bintime exponent for
;                         the given energy band with the bintime being
;                         expressed as power of the basis 2 in sec;
;                         if given, bintime is used for a consistency
;                         check; default entry in history string:   
;                         'Keyword bintime has not been set (lcmerge)'
;          factor       : integer containing the rebin factor for
;                         the given energy band;    
;                         default: 1, i.e., no rebinning      
;
;
; KEYWORD PARAMETERS:
;          chatty       : controls screen output; 
;                         default: screen output;  
;                         to turn off screen output, set chatty=0   
;
;
; OUTPUTS:
;          none, but see side effects and optional outputs
;
;   
; OPTIONAL OUTPUTS:
;          gaps         : long array containing the startbins of gaps
;                         in the merged time array (before rebinning); 
;                         also listed in the history string and
;                         separately written to the xdr output file      
;          gapdura      : array containing the lengths of the gaps in the
;                         original time array, given in the same units as
;                         the time array; also listed in the history
;                         string   
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          the resulting merged lightcurve, the history string
;          array, and the gap array are written to the file namefin in
;          xdr format  
;
;
; RESTRICTIONS:
;          the input lightcurves have to be in FITS format; outside of
;          the gaps the lightcurves have to be evenly spaced
;
;
; PROCEDURES USED: 
;          timerebin.pro, xdrlc_w.pro
;
;
;
; EXAMPLE:
;          lcmerge,['FS3b_978fa90-9790884__excl_8_0-10.lc', $
;                   'FS3b_9791110-9791f08__excl_8_0-10.lc', $
;                   'FS3b_9792790-9792bec__excl_8_0-10.lc' ], $
;                  'merge001.xdrlc',channelrange=['0-10'], $
;                  bintime=-8D0,factor=1L, $
;                  gaps=gaps,gapdura=gapdura,/chatty
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/23 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed    
;          Version 1.3, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header: description of
;                                  ``gaps'' and ``gapdura'' corrected    
;          Version 1.4, 2000/11/02 Katja Pottschmidt,   
;                                  IDL header: minor changes, 
;                                  default for chatty keyword changed   
;          Version 1.5, 2000/12/22 KP: editorial change in header   
;
;
;-   
   
   
;; set default values,
IF (n_elements(channelrange) EQ 0) THEN BEGIN 
    schannelrange='Keyword channelrange has not been set (lcmerge)'
ENDIF ELSE BEGIN 
    schannelrange=string(channelrange)
ENDELSE 
IF (n_elements(bintime) EQ 0) THEN BEGIN 
    sbintime='Keyword bintime has not been set (lcmerge)'   
ENDIF ELSE BEGIN 
    sbintime=string(bintime)
ENDELSE 
IF (n_elements(factor) EQ 0) THEN factor=1L
IF (n_elements(chatty) EQ 0) THEN chatty=1

;; read lightcurves from lclist
nlc=n_elements(lclist)
;lclist=lclist(sort(lclist))
tzero=dblarr(nlc)
FOR i=0,nlc-1 DO BEGIN 
    readlc,t,r,lclist(i)
    tzero(i)=t(0)
    dim=n_elements(t)
    ; add counter and dimension to sort into chronologically 
    ; correct order after all lightcurves have been read
    p=i-nlc
    t=temporary([t,p,dim])
    r=temporary([r,p,dim])
    IF (i EQ 0) THEN BEGIN
        ti=t
        ra=r
    ENDIF ELSE BEGIN 
        ti=temporary([ti,t])
        ra=temporary([ra,r])
    ENDELSE 
ENDFOR 
   
   
;; sort by comparing the first time-element of all lightcurves
chron=sort(tzero)
cr=long(where(ti EQ (chron(0)-nlc)))
crndx=long(cr(0)) 
sx=crndx-long(ti(crndx+1L)) & ex=crndx-1L
time=temporary(ti(sx:ex))
rate=temporary(ra(sx:ex))
FOR k=0,nlc-2 DO BEGIN
    cr=long(where(ti EQ (chron(k+1)-nlc)))
    crndx=long(cr(0))
    sx=crndx-long(ti(crndx+1L))
    ex=crndx-1L
    time=temporary([time,ti(sx:ex)])
    rate=temporary([rate,ra(sx:ex)])
ENDFOR 
ti=0. & ra=0.
time=double(time)
rate=float(rate)


;; check original bintime
IF (n_elements(bintime) NE 0) THEN BEGIN 
    dt=time(1)-time(0)
    dt2=time(5)-time(4)
    check=dt-2D0^(double(bintime))
    check2=dt2-2D0^(double(bintime))
    IF (check NE 0D0) AND (check2 NE 0D0) THEN BEGIN 
        message,'lcmerge: The wrong original bintime has been given'
    ENDIF 
ENDIF 
   
   
;; rebin time and rate by the given factor
timerebin,time,rate,factor=factor,gaps=gaps,gapdura=gapdura,chatty=chatty
   
   
;; define history
nlc=n_elements(lclist)
ngaps=n_elements(gaps)
ndura=n_elements(gapdura)
history=strarr(nlc+8+ngaps+ndura)
nhist=n_elements(history)
history(0)='Dimension of history (lcmerge)='+string(nhist)
history(1)='Keyword channelrange (lcmerge)='+schannelrange
history(2)='Keyword bintime (lcmerge)='+sbintime
history(3)='Keyword factor (lcmerge)='+string(factor)
history(4)='Number of gaps (lcmerge)='+string(ngaps)
history(5)='Startbins of gaps (lcmerge)='
IF (n_elements(gaps) NE 0) THEN BEGIN
    history(6:5+ngaps)=string(gaps)
ENDIF
history(6+ngaps)='Duration of gaps (lcmerge)='
IF (n_elements(gapdura) NE 0) THEN BEGIN
    history(7+ngaps:6+ngaps+ndura)=string(gapdura)
ENDIF
history(7+ngaps+ndura)='Names of original lightcurves (lcmerge)='
history((8+ngaps+ndura):(7+ngaps+ndura+nlc))=string(lclist)
   
   
;; write the merged, rebinned lightcurve in xdr-format
xdrlc_w,namefin,time,rate,history=history,gaps=gaps,dseg=-1,chatty=chatty 
   

END     








