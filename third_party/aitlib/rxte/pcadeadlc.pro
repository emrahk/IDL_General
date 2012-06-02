PRO pcadeadlc,time,rate,obs,mjd=mjd
;+
; NAME: pcadeadlc
;
;
;
; PURPOSE: perform deadtime correction on a PCA lightcurve
;
;
;
; CATEGORY: RXTE
;
;
;
; CALLING SEQUENCE: pcadeadlc,time,rate,obs
;
;
;
; INPUTS: 
;         time: time at which the given countrate in rate was measured
;         rate: measured countrate, on return: deadtime corrected
;         obs : path to an observation that was extracted with the
;               standard Tuebingen RXTE scripts and includes a
;               subdirectory pcadead containing the necessary
;               deadtime information
;
; KEYWORD PARAMETERS:
;         mjd: if set, the times are given in MJD (default: MET)
;
;
; OUTPUTS:
;         rate: the deadtime-corrected countrate
;
; PROCEDURE:
;         follows RXTE GOF description for spectra, using Jernigan et
;         al. deadtime values
;         Warning: The correction still is not 100% o.k., i.e. the
;         Crab does not get absolutely flat, but the corrected lcs
;         look MUCH better than without this correction
;
; EXAMPLE:
;   obs='/home/wilms/xtescratch/crab/P40805/04'
;   readlc,time,rate,err,obs+$
;      '/standard2f_134off_excl_top/standard2f_134off_excl_top.lc'
;   readlc,bati,bara,baerr,obs+$
;      '/pcabackest/standard2f_back_SkyVLE_top_good_134off_excl.lc'
;   subra=rate-bara
;   pcadeadlc,time,rate,obs
;   corra=rate-bara
;   plot,time,subra
;   oplot,time,corra,color=150
;
;
; MODIFICATION HISTORY:
;    Version 1.1: Initial Version, 2001.03.22 JW
;    Version 1.2: 2001.03.23 KP, JW removed bug in definition of kstop
;    CVS Version 1.3: 2003.05.02 TG 
;                    Determination of extrapolated/interpolated values
;                    of dtf still did not work for some special
;                    cases. The whole section was rewritten and should
;                    work for all imaginable cases.
;    CVS Version 1.4: 2003.05.02 TG 
;                    Forgot to remove stupid test printout.
;-

  onedead={time:0d0,RemainingCnt:0.,VLECnt:0.,VpCnt:0., $
           XeCntPcu0:0.,XeCntPcu1:0.,XeCntPcu2:0.,XeCntPcu3:0., $
           XeCntPcu4:0., XeCntPcu5:0.,dsvle:0., $
           numpcu:0,dtf:0.}

  oo=obs+'/./pcadead/'

  ;; Read the individual deadtime-related lightcurves
  readlc,titi,rara,err,oo+'RemainingCnt.lc',mjd=mjd
  dead=replicate(onedead,n_elements(titi))
  dead.time=titi
  dead.remainingcnt=rara

  readlc,titi,rara,err,oo+'VLECnt.lc',mjd=mjd
  dead.vlecnt=rara

  readlc,titi,rara,err,oo+'VpCnt.lc',mjd=mjd
  dead.vpcnt=rara

  readlc,titi,rara,err,oo+'XeCntPcu0.lc',mjd=mjd
  dead.XeCntPcu0=rara

  readlc,titi,rara,err,oo+'XeCntPcu1.lc',mjd=mjd
  dead.XeCntPcu1=rara

  readlc,titi,rara,err,oo+'XeCntPcu2.lc',mjd=mjd
  dead.XeCntPcu2=rara

  readlc,titi,rara,err,oo+'XeCntPcu3.lc',mjd=mjd
  dead.XeCntPcu3=rara

  readlc,titi,rara,err,oo+'XeCntPcu4.lc',mjd=mjd
  dead.XeCntPcu4=rara

  ;; get VLE discriminator settings
  v1=mrdfits(oo+'/vle1.fits',1)
  v2=mrdfits(oo+'/vle2.fits',1)
  v3=mrdfits(oo+'/vle3.fits',1)
  v4=mrdfits(oo+'/vle4.fits',1)
  v5=mrdfits(oo+'/vle5.fits',1)
  titi=v1.time
  IF (keyword_set(mjd)) THEN titi=met2jd(titi,/mjd)

  dsvle=(v1.dsvle+v2.dsvle+v3.dsvle+v4.dsvle+v5.dsvle)/5.

  ;; interpolate onto resolution of other housekeeping data
  dead.dsvle=fix(interpol(dsvle,titi,dead.time))

  ;; number of PCU that are on
  dead.numpcu=(dead.xecntpcu0 NE 0.)+(dead.xecntpcu1 NE 0.)+ $
    (dead.xecntpcu2 NE 0.)+(dead.xecntpcu3 NE 0.)+ $
    (dead.xecntpcu4 NE 0.)+(dead.xecntpcu5 NE 0.)

  ;; discriminator setting dependent deadtimes as per
  ;; Jernigan, Klein, and Arons, 2000, Ap.J. 530, 875.
  vledead=(dead.dsvle EQ 0.)* 12E-6+$
          (dead.dsvle EQ 1.)* 61E-6+$
          (dead.dsvle EQ 2.)*142E-6+$
          (dead.dsvle EQ 3.)*500E-6

  ;; deadtime-fraction
  dead.dtf=10E-6*(dead.xecntpcu0+dead.xecntpcu1+dead.xecntpcu2+$
                 dead.xecntpcu3+dead.xecntpcu4+dead.xecntpcu5+$
                 dead.vpcnt+dead.remainingcnt)/dead.numpcu+$
          vledead*(dead.vlecnt)/dead.numpcu

  dt_dtf=dead[1].time-dead[0].time
  dt_lc=time[1]-time[0]
  
  ;; rare case flag: see below
  flag_rarecase=0

  IF (dt_lc GT dt_dtf) THEN BEGIN 
    
    ;; compute average dtf for each timebin, in the case that the
    ;; temporal resolution of the deadtime information is better than
    ;; the  temporal resolution of the lightcurve
    
    ;; ... compute last timebin
    tt=[time,2.*time[n_elements(time)-1]-time[n_elements(time)-2]]
    n_tt=n_elements(tt)
    intersection=where(dead.time GE tt[0] AND dead.time LE tt[n_tt-1],n_intersection)

    IF n_intersection EQ 0 THEN begin
      ;; care for the (rare but still existing) case when there are no
      ;; dtf values in the tt interval: then after rebinning, all dtf
      ;; would be 0.000. Instead take the left and right bordering
      ;; values of dtf to the tt interval and interpolate for the tt
      ;; interval. 
      flag_rarecase=1 ;; set flag so the interpolation below is skipped
      dtf=fltarr(n_tt-1)
      lowerpart=where(dead.time lt tt[0])
      lowerborder=max(lowerpart)
      upperpart=where(dead.time gt tt[n_tt-1])
      upperborder=min(upperpart)
      l_time=dead[lowerborder].time
      l_dtf=dead[lowerborder].dtf
      r_time=dead[upperborder].time
      r_dtf=dead[upperborder].dtf
      ;; the extrapolation/interpolation formula
      dtf[0:n_tt-2]=l_dtf+(r_dtf-l_dtf)/(r_time-l_time)*(time[0:n_tt-2]-l_time)

    ENDIF ELSE begin
      ;; ... rebin onto the resolution of the current lightcurve
      ;; ... (requires the resolution of dead.time to be larger than
      ;; ... that of tt!)
      ;; ... the gaps keyword is necessary to ensure that no empty bins
      ;; ... are removed by rebinlc 
      rebinlc,dead.time,dead.dtf,dtim,dtf,usetime=tt,/gaps
      
    endelse
    
  ENDIF ELSE BEGIN 

    ;; temporal resolution of the deadtime information is worse than the
    ;; resolution of the lightcurve --> interpolate deadtime information
    dtf=interpol(dead.dtf,dead.time,time,/quadratic)

  ENDELSE 
  
  ;;
  ;; interpolate over gaps in the dtf due to missing housekeeping data
  ;; only if not rarecase has been flagged
  ;;
  ndx=where(dtf EQ 0.) ;; look for zero values
  
  IF (ndx[0] NE -1) AND (flag_rarecase EQ 0) THEN BEGIN 
    ;; kstart gives the position of the lower limit of a set of zero values of dtf
    ;; kstop gived the position of the upper limit of a set of zero values of dtf
    ;; kstartarr and kstoparr are all values of kstart and kstop
    ;; e.g.: dtf=[0,0,1,1,1,1,0,1,1,0,0]
    ;; then  kstartarr=[0,6,9] and kstoparr =[1,6,10]
    kstartarr=0
    kstoparr=0
    tail=0
    kstart=0
    kstop=0
    
    WHILE kstart lt n_elements(ndx)-1 DO BEGIN
      set=0
      kk=kstart-1
      
      REPEAT begin
        kk=kk+1
        IF ndx[kk+1] EQ ndx[kk]+1 THEN begin
          kstop=kk+1
          IF kk+1 EQ n_elements(ndx)-1 THEN BEGIN
            tail=1
          endif
        ENDIF ELSE BEGIN
          kstop=kk
          set=1
        ENDELSE
      enDREP UNTIL (set EQ 1) OR (tail EQ 1)
      
      kstartarr=[kstartarr,kstart]
      kstoparr=[kstoparr,kstop]
      kstart=kstop+1
    ENDWHILE
    
    IF tail NE 1 THEN begin
      kstart=kstop+1
      kstop=kstart
      
      kstartarr=[kstartarr,kstart]
      kstoparr=[kstoparr,kstop]
    ENDIF
    
    kstartarr=kstartarr[1:n_elements(kstartarr)-1]
    kstoparr=kstoparr[1:n_elements(kstoparr)-1]
    IF n_elements(kstartarr) EQ 1 THEN BEGIN
      IF kstartarr EQ kstoparr THEN BEGIN
        kstartarr=0
        kstoparr=0
      endif
    endif
    
    IF n_elements(kstartarr) NE n_elements(kstoparr) THEN BEGIN
      message,'Determination of zero values in dtf failed'
    endif
    
    ;; Now that we know the position of the zero values we can
    ;; extrapolate or interpolate for all sets of zero dtf values.
    ;; We have to decide on the cases that exist:
    
    FOR kk=0,n_elements(kstartarr)-1 DO begin
      
      kstart=ndx[kstartarr[kk]]
      kstop=ndx[kstoparr[kk]]
      
      ;; kstart:kstop is range where dtf=0
      IF (kstart EQ 0) THEN BEGIN 
        ;; special case of a gap at the beginning
        ;; extrapolate
        t1=time[kstop+2] & dt1=dtf[kstop+2]
        t2=time[kstop+1] & dt2=dtf[kstop+1]
      ENDIF ELSE BEGIN 
        IF (kstop EQ n_elements(dtf)-1) THEN BEGIN 
          ;; special case of a gap at the end
          ;; extrapolate
          t1=time[kstart-2] & dt1=dtf[kstart-2]
          t2=time[kstart-1] & dt2=dtf[kstart-1]
        ENDIF ELSE BEGIN 
          ;; gap is somewhere in the middle
          ;; linear interpolation using values measured at
          ;; times kstart-1 and kstart+1
          t1=time[kstart-1] & dt1=dtf[kstart-1]
          t2=time[kstop+1] & dt2=dtf[kstop+1]
        ENDELSE 
      endelse
      ;; the extrapolation/interpolation formula
      dtf[kstart:kstop]=dt1+(dt2-dt1)/(t2-t1)*(time[kstart:kstop]-t1)
    endfor
  endif
  
  rate=rate/(1.-dtf)
  
END 

