pro fit_mdl,mdl,rt,tl,a,sigmaa,chisqr,x,yfit,iter,nfree,fitbins,$
            rtplot,fttd
;********************************************************************
; Program fits the model to the data 
; Input variables are:
;           mdl.............model to fit
;            rt.............rate to fit
;            tl.............livetime for weights
;      num_chns.............number of channels
;          afit.............elements of a to fit (1 = fit)
;      num_chns.............number of pha channels
;       fitbins.............start,stop bins of fit
;          fttd.............fit indicator (1 = fitted)
; Output variables:
;             a.............array of parameter values
;        sigmaa.............errors on parameter values
;        chisqr.............chisquared for fit
;             x.............channels for fit
;          yfit.............fitted values
;          iter.............# iterations in fit
;         nfree.............# degrees of freedom
;            dw.............data weights
;      fun_name.............function name
;        rtplot.............rate to plot in fitting widget
;***********************************************************************
num_chns = n_elements(rt)
x = findgen(num_chns)
rt_save = rt & x_save = x
rt = reform(rt,num_chns)
if (fitbins(1) gt num_chns - 1)then fitbins(1) = num_chns - 1
rt = rt(fitbins(0):fitbins(1)) & x = x(fitbins(0):fitbins(1))
num_chns = fitbins(1) - fitbins(0) + 1
afit = a & afit(*) = 1
chisqr = 0
nfree = num_chns - n_elements(a)
iter = 0
sigmaa = a & sigmaa(*) = 0.
if (keyword_set(sigmaa) eq 0)then sigmaa = a
print,'FIT_MDL:FTTD=',fttd
nz = where(a ne 0.)
if (nz(0) eq -1)then begin
   rtplot = rt
   rt = rt_save
   print,'RETURNING FROM FITIT'
   return
endif
;**********************************************************************
; Get the function name of the model
;**********************************************************************
mod_str = ['N GAUSSIAN LINES','N LINES + CONST.',$
 'N LINES + LINEAR','N LINES + PWRLAW','N LINES + PWRLAW + CONST.']
mr_names = ['nline','nline_const','nline_lnr','nline_pwrlw',$
 'nline_pwrlw_c']
mdl_ndx = where(mod_str eq mdl)
fnction = mr_names(mdl_ndx(0))
print,'FNCTION=',fnction
print,'SIZE(FNCTION)=',size(fnction)
;******************************************************************
; Get data weights
; Important philosophical point : If there are no counts, what is
; the data weight? LAF & DB convention : use one count
;******************************************************************
print,'tl=',tl
dw = replicate(1.,num_chns)/tl
nz = where(rt ne 0.)
drt = sqrt(rt/tl)
dw(nz) = 1./(drt(nz))^2
;******************************************************************
; Fit the model
;******************************************************************
yfit = crft(x,rt,dw,a,afit,sigmaa,tl,fnction,iter,chisqr,nfree)
print,'FIT_MDL: MDL=',mdl
print,'SIZE(RT)=',size(rt)
print,'TL=',tl
print,'A=',a
print,'SIGMAA=',sigmaa
print,'CHISQR=',chisqr
print,'SIZE(X)=',size(x)
print,'SIZE(YFIT)=',size(yfit)
print,'ITER=',iter,', NFREE=',nfree
;****************************************************************
; Thats it 
;****************************************************************
rtplot = rt
rt = rt_save
return
end
            
