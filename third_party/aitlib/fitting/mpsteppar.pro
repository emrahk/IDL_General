PRO mpsteppar,fcn,x,y,err,start_params,parinfo=parinfo,$
              par1ind=par1ind,par1min=par1min,par1max=par1max,nstep1=nstep1,$
              par1log=par1log, $
              par2ind=par2ind,par2min=par2min,par2max=par2max,nstep2=nstep2, $
              par2log=par2log, $
              par1val=par1val,par2val=par2val,chi2val=chi2val,$
              bestnorm=bestnorm,perror=perror, $
              plot=plot,psym=psym,dev=dev, $
              xtitle=xtitle,ytitle=ytitle, $
              _extra=extra
;+
; NAME:
;       mpsteppar
;
;
; PURPOSE:
;       plot 1D or 2D chi^2 contours for chi^2 fitting error determination
;
;
; CATEGORY:
;       fitting
;
;
; CALLING SEQUENCE:
;       steppar,x,y,w,a plus lot's of keywords
;
; 
; INPUTS:
;       x,y,w: (x,y) values and weight of data, identical to 
;              curvefit 
;       a: best fit parameters of the fit function
;
;
; OPTIONAL INPUTS:
;
;      
; KEYWORD PARAMETERS:
;     * required:   
;         par1ind: index of 1st parameter to be stepped
;         par1min,par1max: min. and max. value of 1st parameter
;         nstep1: number of steps for par1
;     * optional: 
;         par1log: if set, use logarithmic steps 
;         par2ind,par2min,par2max,nstep2,par2log: same as 
;            the ..1.. pars for the 2nd parameter to be stepped.
;         bestnorm: chi^2 at minimum (result from bestnorm keyword
;                of mpfitfun)
;         plot: if set, a plot of chi^2 vs. the parameter(s) is
;            shown, with contours indicating the 1sigma, 90%, and 99%
;            confidence regions (the latter option requires the
;            bestnorm value as well!).
;         dev: plot axes as deviation from best fit value 
;         xtitle: lable for the x-axis (default, if there is a parname
;            tag available, name of the fit parameter)
;         ytitle: same as xtitle, only for (guess what) the y-axis; in
;            the case of 2d contours only

;       * All keyword-parameters given to the previous call to
;         mpfitfun.
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;       par1val: values of 1st parameter
;       par2val: values of 2nd parameter
;       chi2val: array containing the chi^2 values
;       
;
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       if /plot is set, a (contour) plot is drawn in the current window
;
;
; RESTRICTIONS:
;       stepping regions need to contain the best fit value.
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;     based on steppar.pro, written 1999.03.03 by Joern Wilms
;
;     CVS Version 1.0, 2001.12.06, Joern Wilms
;         (mainly written while at SSO in October 2001)
;
; DO NOT MODIFY ANYTHING BELOW THIS LINE: RCS LOG
; $Log: mpsteppar.pro,v $
; Revision 1.5  2003/02/24 14:44:52  goehler
; support extra function arguments in the 1-dim special case
; where no free parameters are are used. The parameters are
; passed via _extra keyword.
;
; Revision 1.4  2002/08/15 13:16:34  goehler
; exported parameter 2 to support external plot routines
;
; Revision 1.3  2002/06/03 21:15:16  wilms
; changed header (removed old keywords from jwsteppar).
; added code such that parinfo is not a required keyword anymore
;
; Revision 1.2  2002/05/10 09:59:24  wilms
; * added xtitle and ytitle keywords
; * took care of special case that there are no free parameters. In this
;   case, chi^2 is computed directly.
;
;
;-
  IF (n_elements(parinfo) NE 0) THEN BEGIN 
      pbest=parinfo
      IF (n_elements(start_params) NE 0) THEN pbest.value=start_params
  ENDIF ELSE BEGIN 
      IF (n_elements(start_params) EQ 0) THEN BEGIN 
          message,'parinfo keyword is not given',/info
          message,'therefore, start_params are required'
      ENDIF 
      pbest=replicate({value:0d0,fixed:0,limited:[0,0], $
                         limits:[-1E30,+1E30]},n_elements(start_params))
      pbest.value=start_params
  ENDELSE 
   
  IF (n_elements(par1log) EQ 0) THEN par1log=0
  IF (n_elements(par2log) EQ 0) THEN par2log=0

  ;; intelligence to get the x- and y-axis titles right
  IF (n_elements(xtitle) EQ 0) THEN BEGIN 
      xtitle=''
      tags=tag_names(pbest[par1ind])
      ndx=(where(tags EQ 'PARNAME'))[0]
      IF (ndx NE -1) THEN xtitle=pbest[par1ind].(ndx)
  ENDIF 

  IF (n_elements(par2ind) NE 0 AND n_elements(ytitle) EQ 0) THEN BEGIN 
      ytitle=''
      tags=tag_names(pbest[par2ind])
      ndx=(where(tags EQ 'PARNAME'))[0]
      IF (ndx NE -1) THEN ytitle=pbest[par2ind].(ndx)
  ENDIF 
   
  ;; ...set bounds for all parameters to simplify our life
  ndx=where(NOT pbest.limited[0]) ;; lower bound
  pbest[ndx].limits[0]=-1E30

  ndx=where(NOT pbest.limited[1]) ;; upper bound
  pbest[ndx].limits[1]=+1E30

  pbest[*].limited[*]=1 
   
  ;; ... check on min and max parameter
  IF (n_elements(par1min) EQ 0 OR n_elements(par1max) EQ 0) THEN BEGIN 
      message,'Need to give par1min and par1max keywords'
  END 
  IF (par1min GT pbest[par1ind].value OR $
      par1max LT pbest[par1ind].value) THEN BEGIN 
      message,'par1min and par1max need to bracket best fit parameter'
  END 
   
  ;; ... default number of steps for 1st parameter
  IF (n_elements(nstep1) EQ 0) THEN nstep1=10
   
  twopar=(n_elements(par1ind) NE 0 AND n_elements(par2ind) NE 0)
   
  IF (keyword_set(par1log)) THEN BEGIN 
      par1val=floggen(par1min,par1max,nstep1)
  END ELSE BEGIN 
      par1val=par1min+findgen(nstep1)/(nstep1-1)*(par1max-par1min)
  END 
   
  IF (twopar) THEN BEGIN 
      IF (par2min GT pbest[par2ind].value OR $
          par2max LT pbest[par2ind].value) THEN BEGIN 
          message,'par2min and par2max need to bracket best fit parameter'
      END 
      IF (n_elements(nstep2) EQ 0) THEN nstep2=10
      IF (keyword_set(par2log)) THEN BEGIN 
          par2val=floggen(par2min,par2max,nstep2)
      END ELSE BEGIN 
          par2val=par2min+findgen(nstep2)/(nstep2-1)*(par2max-par2min)
      END 
  END ELSE BEGIN 
      nstep2=1
  END 
   
  chi2val=fltarr(nstep1,nstep2)
   
  FOR j=0,nstep2-1 DO BEGIN 
      FOR i=0,nstep1-1 DO BEGIN 
          ;; ... freeze parameter
          fitstart=pbest
          fitstart[par1ind].value=par1val[i]
          fitstart[par1ind].fixed=1
          IF (twopar) THEN BEGIN 
              fitstart[par2ind].value=par2val[j]
              fitstart[par2ind].fixed=1
          END 
          ;; ... fit with  parameter fixed
          dummy=where(fitstart.fixed NE 1,numfree)
          ;; perform a fit if there are free parameters
          IF (numfree GT 0) THEN BEGIN 
              tmp=mpfitfun(fcn,x,y,err,parinfo=fitstart, $
                           bestnorm=cc,_extra=extra)
          ENDIF ELSE BEGIN 
              ;; no free parametes --> compute a chi^2 by hand
              ;; not the best way, really...
              IF n_elements(extra.functargs) GT 0 THEN BEGIN                           ;; add. function argument
                  funval=call_function(fcn,x,fitstart[*].value, $
                                       _extra=extra.functargs) ;; to pass? -> do via extra
              ENDIF ELSE BEGIN 
                  funval=call_function(fcn,x,fitstart[*].value)                ;; no function argument
              ENDELSE                                                          ;; (default)
              cc=total( (y-funval)^2. / err^2)
          ENDELSE 
          chi2val[i,j]=cc
      END 
  END 
   
  IF (keyword_set(plot)) THEN BEGIN 
      a=pbest.value
      IF (n_elements(perror) NE 0) THEN sigmaa=perror


      IF (twopar) THEN BEGIN 
          off1=0.
          IF (keyword_set(dev)) THEN off1=a[par1ind]
          off2=0.
          IF (keyword_set(dev)) THEN off2=a[par2ind]
          IF (n_elements(bestnorm)) THEN BEGIN 
              cmin=bestnorm
          END ELSE BEGIN 
              message,'Warning: contour levels are approximate',/informative
              cmin=min(chi2val)
              message,'   assuming'+strtrim(cmin,2)+'as local minimum',$
                /informative
          END 
          ;; 1sigma, 90%, and 99% contours
          levels=cmin+[2.2789,4.6052,9.2104]
          contour,chi2val,par1val-off1,par2val-off2, $
            xlog=par1log,ylog=par2log, $
            xstyle=1,ystyle=1,levels=levels, $
            xtitle=xtitle,ytitle=ytitle
          ;; uncertainty from the Hessian matrix
          IF (n_elements(sigmaa) NE 0) THEN BEGIN 
              ;; hesse matrix
              oplot,a[par1ind]+[-sigmaa[par1ind],+sigmaa[par1ind]]-off1, $
                [a[par2ind],a[par2ind]]-off2,linestyle=2
              oplot,[a[par1ind],a[par1ind]]-off1, $
                a[par2ind]+[-sigmaa[par2ind],+sigmaa[par2ind]]-off2, $
                linestyle=2
              ;; dashed lines outside, x direction
              oplot,[par1min,a[par1ind]-sigmaa[par1ind]]-off1, $
                [a[par2ind],a[par2ind]]-off2,linestyle=1
              oplot,[a[par1ind]+sigmaa[par1ind],par1max]-off1, $
                [a[par2ind],a[par2ind]]-off2,linestyle=1
              ;; dashed lines outside, y direction
              oplot,[a[par1ind],a[par1ind]]-off1, $
                [par2min,a[par2ind]-sigmaa[par2ind]]-off2, $
                linestyle=1
              oplot,[a[par1ind],a[par1ind]]-off1, $
                [a[par2ind]+sigmaa[par2ind],par2max]-off2, $
                linestyle=1
          END ELSE BEGIN 
              oplot,[par1min,par1max]-off1,[a[par2ind],a[par2ind]]-off2, $
                linestyle=1
              oplot,[a[par1ind],a[par1ind]]-off1,[par2min,par2max]-off2, $
                linestyle=1
          END
          
      END ELSE BEGIN 
          off=0.
          IF (keyword_set(dev)) THEN off=a[par1ind]
          plot,par1val-off,chi2val,xlog=par1log,xstyle=1,/ynozero, $
            xtitle=xtitle,ytitle='Chi-Squared'
          oplot,[a[par1ind],a[par1ind]]-off,[min(chi2val),max(chi2val)], $
            linestyle=1
          IF (n_elements(psym) NE 0) THEN BEGIN 
              oplot,par1val-off,chi2val,psym=psym
          ENDIF 
          IF (n_elements(bestnorm)) THEN BEGIN 
              oplot,[par1min,par1max]-off,[bestnorm,bestnorm],linestyle=1
              deltay=(max(chi2val)-min(chi2val))*0.01
              deltax=(par1max-par1min)*0.01
              ;; 1 sigma confidence with and without hesse uncertainty
              IF (n_elements(sigmaa) NE 0) THEN BEGIN 
                  ;; uncertainty from Hessian matrix
                  oplot,a[par1ind]+[-sigmaa[par1ind],+sigmaa[par1ind]]-off, $
                    [bestnorm,bestnorm]+1.,linestyle=2
                  oplot,[par1min,a[par1ind]-sigmaa[par1ind]]-off, $
                    [bestnorm,bestnorm]+1.,linestyle=1
                  oplot,[a[par1ind]+sigmaa[par1ind],par1max]-off, $
                    [bestnorm,bestnorm]+1.,linestyle=1
              END ELSE BEGIN 
                  oplot,[par1min,par1max]-off, $
                    [bestnorm,bestnorm]+1.,linestyle=1
              END 
              xyouts,par1min+deltax-off,bestnorm+1.+deltay,'1 sigma'
              ;; 90% confidence
              oplot,[par1min,par1max]-off, $
                [bestnorm,bestnorm]+2.706,linestyle=1
              xyouts,par1min+deltax-off,bestnorm+2.706+deltay,'90%'
              ;; 99% confidence
              oplot,[par1min,par1max]-off, $
                [bestnorm,bestnorm]+6.635,linestyle=1
              xyouts,par1min+deltax-off,bestnorm+6.635+deltay,'99%'
          END 
      END 
  END 
END 




