pro fitit
;*********************************************************************
; Program controls the fitting widgets. All the fitting is done here.
; Variables are:
;	  idfs,idfe.............start,stop IDF#
;                rt.............rate to fit
;             ltime.............livetime string for rate
;                lt.............livetime
;                dt.............array of dates,times (start,stop)
;                cp.............cluster position
;               mdl.............model to fit
;              mdln.............mdl + num_lines
;               opt.............data option
;               det.............detector choice
;                 a.............array of parameters
;           astring.............array of parameter names
;              afit.............exclude any parameters from fit
;         num_lines.............number of lines to fit
;              yfit.............fitted values
;                 x.............channel centers
;            chisqr.............chisqared statistic
;              iter.............number of iterations for fit
;             nfree.............   "    " degrees of freedom
;          num_chns.............   "    " channels
;               typ.............Data typ of fit
;    strtbin,stpbin.............start,stop bins of fit
;              fttd.............fit indicator (0-new fit,1-old fit)
;             asave.............saved parameter values from last fit
;              mdln.............saved model from last fit
;           det_str.............detector  plot label string for phapsa 
; Common Blocks:
;          fitblock.............contains fit variables
; The models are (mod '.pro'):
;             nline.............n gaussian lines
;       nline_const............."     "      "    + constant offset
;         nline_lnr............."     "      "    + linear piece
;       nline_pwrlw............."     "      "    + power law
; nline_pwrlw_const............."     "      "    "   "    "   + const
; The fitting is done via an adaptation of Bevington's CURFIT.
; Weighting is initially done via data weights but then model
; weighting is used for the final search.
; Get the parameters of the model and array of initial values
; 8/26/94 Annoying print statements eliminated
;************************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
                nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,$
                stpbin,fttd,asave,mdlnsave,det_str
;************************************************************************
; Get the parameters of the model
;************************************************************************
get_parms,mdl,num_lines,num_parms,a,astring,mdln,fttd
;************************************************************************
; Fit the model to the data using crft
;************************************************************************
fitbins = [strtbin,stpbin]
fit_mdl,mdl,rt,float(ltime),a,sigmaa,chisqr,x,yfit,iter,nfree,fitbins,$
        rtplot,fttd
;************************************************************************
; Activate the fit display widget
;************************************************************************
nz = where(a ne 0.)
if (nz(0) ne -1)then begin
   asave = a & mdlnsave = mdln
endif else begin
   if (mdln eq mdlnsave)then a = asave
endelse
wfit,idfs,idfe,dt,cp,rtplot,ltime,opt,det,a,sigmaa,mdln,chisqr,nfree,x,$
 yfit,astring,typ,strtbin,stpbin,det_str
;************************************************************************
; Thats all ffolks 
;************************************************************************
return
end
