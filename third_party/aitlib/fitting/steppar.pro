PRO steppar,x,y,w,a,bounds=bounds,$
            par1ind=par1ind,par1min=par1min,par1max=par1max,nstep1=nstep1,$
            par1log=par1log, $
            par2ind=par2ind,par2min=par2min,par2max=par2max,nstep2=nstep2, $
            par2log=par2log, $
            par1val=par1val,chi2val=chi2val,$
            chi2red=chi2red,dof=dof,$
            plot=plot,psym=psym,sigmaa=sigmaa,dev=dev, $
            _extra=extra
;+
; NAME:
;       steppar
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
;         chi2red: reduced chi^2 at minimum (result from chi2 keyword
;                of curvefit)
;         dof: degrees of freedom (returned from curvefit)
;         plot: if set, a plot of chi^2 vs. the parameter(s) is
;            shown, with contours indicating the 1sigma, 90%, and 99%
;            confidence regions (the latter option requires the
;            chi2red and dof values as well!).
;         sigmaa: if also given (returnvalue from jwcurvefit) also
;            plot the error bars as determined from the Hessian
;            matrix (also need chi2red and dof).
;         dev: plot axes as deviation from best fit value 
;   
;       * All keyword-parameters given to the previous call to
;         curvefit.
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
;   (from a program doing a fit to an astrophysical absorption line)
;
;   bounds=[ $
;            [0.,10000.], $
;            [xstart,xend], $
;            [0.,20.], $
;            [0.,10.], $
;            [0.,0.] $
;          ]
;    
;   ;; do the fit
;   res=jwcurvefit(lam,dat,w,a,sigmaa,function_name='hbetaline',/noderivative, $
;                  chi2=chi2,itmax=200,tol=1D-5,iter=iter,bounds=bounds, $
;                 dof=doffit)
;   steppar,lam,dat,w,a,$
;     par1ind=1,par1min=a[1]-2.,par1max=a[1]+2.,nstep1=30, $
;     par2ind=2,par2min=a[2]-0.75,par2max=a[2]+0.75,nstep2=30, $
;     par1val=par1val,par2val=par2val,chi2val=chi2val,$
;     chi2red=chifit,dof=doffit,$
;     FUNCTION_name='hbetaline',/noderivative,bounds=bounds,/plot

;
;
; MODIFICATION HISTORY:
;     Version 1.0, 1999/03/03, Joern Wilms (wilms@astro.uni-tuebingen.de)
;     Version 1.1, 1999/11, 23, JW: 
;         added psym plotting option,
;         removed bug in computation of fit uncertainty (dof was
;            overwritten)
;         added option to also plot uncertainty from Hessian matrix
;
;-
   
   
   IF (n_elements(par1log) EQ 0) THEN par1log=0
   IF (n_elements(par2log) EQ 0) THEN par2log=0
   
   ;; no bounds given --> bounds go from +/- infinity
   IF (n_elements(bounds) EQ 0) THEN BEGIN 
       bounds=fltarr(2,n_elements(a))
       bounds(0,*)=-1E30
       bounds(1,*)=+1E30
   ENDIF 
   
   ;; ... check on min and max parameter
   IF (n_elements(par1min) EQ 0 OR n_elements(par1max) EQ 0) THEN BEGIN 
       message,'Need to give par1min and par1max keywords'
   END 
   IF (par1min GT a[par1ind] OR par1max LT a[par1ind]) THEN BEGIN 
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
       IF (par2min GT a[par2ind] OR par2max LT a[par2ind]) THEN BEGIN 
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
           fitstart=a
           fitstart[par1ind]=par1val[i]
           bnds=bounds
           bnds[0:1,par1ind]=par1val[i]
           IF (twopar) THEN BEGIN 
               fitstart[par2ind]=par2val[j]
               bnds[0:1,par2ind]=par2val[j]
           END 
           ;; ... fit with  parameter fixed
           tmp=jwcurvefit(x,y,w,fitstart,sigmaadummy,chi2=chi2,dof=dofsav,$
                          _extra=extra,bounds=bnds)
           chi2val[i,j]=dofsav*chi2
       END 
   END 
   
   IF (keyword_set(plot)) THEN BEGIN 
       IF (twopar) THEN BEGIN 
           off1=0.
           IF (keyword_set(dev)) THEN off1=a[par1ind]
           off2=0.
           IF (keyword_set(dev)) THEN off2=a[par2ind]
           IF (n_elements(chi2red) NE 0 AND n_elements(dof) NE 0) THEN BEGIN 
               cmin=chi2red*dof
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
             xstyle=1,ystyle=1,levels=levels
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
           plot,par1val-off,chi2val,xlog=par1log,xstyle=1,/ynozero
           oplot,[a[par1ind],a[par1ind]]-off,[min(chi2val),max(chi2val)], $
             linestyle=1
           IF (n_elements(psym) NE 0) THEN BEGIN 
               oplot,par1val-off,chi2val,psym=psym
           ENDIF 
           IF (n_elements(chi2red) NE 0 AND n_elements(dof) NE 0) THEN BEGIN 
               oplot,[par1min,par1max]-off,[chi2red,chi2red]*dof,linestyle=1
               deltay=(max(chi2val)-min(chi2val))*0.01
               deltax=(par1max-par1min)*0.01
               ;; 1 sigma confidence with and without hesse uncertainty
               IF (n_elements(sigmaa) NE 0) THEN BEGIN 
                   ;; uncertainty from Hessian matrix
                   oplot,a[par1ind]+[-sigmaa[par1ind],+sigmaa[par1ind]]-off, $
                     [chi2red,chi2red]*dof+1.,linestyle=2
                   oplot,[par1min,a[par1ind]-sigmaa[par1ind]]-off, $
                     [chi2red,chi2red]*dof+1.,linestyle=1
                   oplot,[a[par1ind]+sigmaa[par1ind],par1max]-off, $
                     [chi2red,chi2red]*dof+1.,linestyle=1
               END ELSE BEGIN 
                   oplot,[par1min,par1max]-off, $
                     [chi2red,chi2red]*dof+1.,linestyle=1
               END 
               xyouts,par1min+deltax-off,chi2red*dof+1.+deltay,'1 sigma'
               ;; 90% confidence
               oplot,[par1min,par1max]-off, $
                 [chi2red,chi2red]*dof+2.706,linestyle=1
               xyouts,par1min+deltax-off,chi2red*dof+2.706+deltay,'90%'
               ;; 99% confidence
               oplot,[par1min,par1max]-off, $
                 [chi2red,chi2red]*dof+6.635,linestyle=1
               xyouts,par1min+deltax-off,chi2red*dof+6.635+deltay,'99%'
           END 
       END 
   END 
END 




