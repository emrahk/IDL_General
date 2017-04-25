;+
; Project     :  YOHKOH-BCS
;
; Name	      :  GUESS_FIT_PAR
;
; Purpose     :  Guess line parameters for fitting single and/or double component
;
; Explanation: Smoothes spectrum to find mean minimum flux for background
;              then find maximum flux location for line.
;
; Category    : fitting
;
; Syntax      : guess_fit_par,wave,flux,fit_par
;
; Inputs      : wave - wavelength array
;               flux - flux array
;
; Outputs     : fit_par =[fback,0,0,intens,wcent,doppw, intens2,wcent2,doppw2]
;               wcent - wavelength center of strongest line in spectrum
;               intens- peak line intensity
;               doppw - doppler width of line (1/e half-width)
;               fback - linear continuum background
;
; Opt. Outputs: sigmaa = sigma errors
;
; Keywords    : lrange - wavelength range to limit line search
;               crange - wavelength range to limit continuum calculation
;               sbin   - bin smoothing value 
;               double - fit a second component
;               plot   - plot results
;               blue   - find a blueshifted second cmpt
;               lineonly - fit line only
; Restrictions: 
;               The peak or minimum of the Gaussian must be the largest
;	        or smallest point in the Y vector.
;
; Side effects: None
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

 pro guess_fit_par,wave,flux,fit_par,lrange=lrange,crange=crange,$
               sbin=sbin,double=double,plot=plot,lineonly=lineonly,blue=blue


 if n_elements(sbin) eq 0 then sbin=5    ;-- smooth over 5 bins

;-- continuum part first
  
 if not keyword_set(lineonly) then begin
  def_range=[min(wave),max(wave)]
  if n_elements(crange) eq 0 then ccrange=def_range else ccrange=crange
  s1=where( (wave ge min(ccrange)) and (wave le max(ccrange)) and $
            (flux ge 0.) ,count)
  if (count gt 0) then begin
   cflux=flux(s1)
   cwave=wave(s1)
   sflux=amedian(cflux,20)
   oflux=interpol(sflux,cwave,wave)
   fback=min(sflux,imin) > 0.
  endif else begin
   message,'could not determine continuum for spectrum',/contin
   fback=0.
  endelse 
 endif else begin
  fback=0 & oflux=0.
 endelse

;-- line part next

 if n_elements(lrange) eq 0 then llrange=def_range else llrange=lrange
 s2=where( (wave ge min(llrange)) and (wave le max(llrange)) and $
           (flux ge 0.) ,count)

 if (count gt 0) and (fback ge 0.) then begin
  lflux=flux(s2)
  lwave=wave(s2)
  mflux=oflux(s2)
;  dflux=amedian((lflux-fback) > 0.,5)
  dflux=(lflux-fback) > 0.

  fpeak=max(dflux,imax)
  lpeak=lflux(imax)
  intens=lpeak-fback
  wcent=lwave(imax)
  stren=fback+intens/exp(1.)       ;-- intensity at 1/e of maximum
  wval=findval(lflux,lwave,stren)

  diff2=abs(wval-wcent)
  find2=where(diff2 eq min(diff2))
  wval=wval(find2(0))
  doppw=abs(wcent-wval(0))    ;-- observed 1/e width

  fit_par=[fback,0,0,intens,wcent,doppw]
 endif else message,'could not determine line position for spectrum',/contin

;-- now look for second line by subtracting  first

 wshift=(abs(lwave-wcent)/doppw) < 10.d
 first=fback+intens*exp(-double(wshift)^2)
 if keyword_set(plot) then oplot,lwave,first,psym=10
 
 if keyword_set(double) or keyword_set(blue) then begin
  resid=(lflux-first) > 0.
  if keyword_set(blue) then brange=[min(llrange),wcent] else brange=llrange
  if keyword_set(plot) then oplot,lwave,resid,psym=10,linestyle=1
  guess_fit_par,lwave,resid,fit_par2,lrange=brange,plot=plot,/lineonly
  fit_par=[fit_par,fit_par2(3:5)]
 endif 

 return & end

