pro save_fit
;*************************************************************************
; Program saves the result of a fit to an ascII file.
; Varables are:
;	  idfs,idfe.............start,stop IDF#
;                rt.............rate to fit
;             ltime.............livetime string for rate
;                lt.............livetime
;                dt.............array of dates,times (start,stop)
;                cp.............cluster position
;               mdl.............model to fit
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
;          fit_bins.............Start,stop bins of fit
; Common Blocks:
;          fitblock.............contains fit variables
; 8/26/94 Print statements
;*********************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,nfree,$
                rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,stpbin,$
                fttd,asave,mdlnsave,det_str
;*********************************************************************
; Construct and open file for fits
;*********************************************************************
typ = string(typ) & idfss = string(idfs) & idfes = string(idfe)
fname = strcompress(typ + 'F' + idfss + '.dat',/remove_all)
get_lun,unit
openw,unit,fname
;*********************************************************************
; Write data to file
;*********************************************************************
num_parms = n_elements(a)
nfrees = string(nfree)
a = float(a) & sigmaa = float(sigmaa)
astr = string(a) & sigstr = string(sigmaa)
printf,unit,'*********************FIT RESULTS***********************'
printf,unit,'DATA TYPE : ',typ, ' IDFS : ',idfs,' TO ',idfes
printf,unit,'FITTED MODEL : ',mdln
printf,unit,'FITTED CHANNELS: ',string(strtbin),string(stpbin)
printf,unit,'CHISQUARED/DOF = ',string(chisqr),' D.O.F. = ',nfrees
printf,unit,'****************BEST FIT PARAMETERS*******************'
for i = 0,num_parms-1 do begin
 printf,unit,astring(i),' = ',astr(i),' +/- ',sigstr(i)
endfor
;*********************************************************************
; Close shop + thats all ffolks
;*********************************************************************
close,unit
free_lun,unit
return
end
