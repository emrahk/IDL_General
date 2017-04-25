;+
; NAME:
;         funct_val
; PURPOSE:
;         evaluate any function and its partial derivatives
;         with respect to each parameter
; CATEGORY:
;         utility
; CALLING SEQUENCE:
;         f=funct_val(x,a,pder,funct=funct,extra=extra)
; INPUTS:
;         x=dependent variable array
;         a=function parameter array
;         funct=generic function name passed as string
; OUTPUTS:
;         f=computed function
; OPTIONAL OUTPUT PARAMETERS:
;         pder=derivative of function at ith point with respect to jth parameter
;             (should not be calculated if parameter is not supplied in call)
;         if stepfac le 0 then pder is computed analytically from function
; KEYWORDS:
;         
;         stepfac (in) = fractional stepsize for numerical differencing
;         fixp (in) = logical vector identifying which parameters to keep 
;                  fixed (e.g. fixp=[1,2] means keep parameters 1 and 2 fixed)
;         corr (in) = correlation matrix specifying actual links between parameters
;                 (e.g. corr(3,2)=alpha implies a(3)=alpha*a(2) and a(3) will
;                  be fixed during solution)
;         extra (out) = extra optional variable in which user can return
;                     miscellaneous information.
; RESTRICTIONS:
;         funct must be passed as string for this proc to work
; PROCEDURE:
;         uses call_function
; MODIFICATION HISTORY:
;         written March '87 by DMZ, Applied Research Corp.
;         modified Aug '87 by DMZ, to allow fixed parameters
;         modified Oct '87 by DMZ, to allow linking parameters
;         modified Jun '88 by DMZ, to allow analytic PDER
;         converted to version 2 -- DMZ (ARC) April 1992
;         optimized and cleaned up keyword inputs -- DMZ (ARC) Sept 1993
;-

 function funct_val,x,a,pder,funct=funct,fixp=fixp,corr=corr,stepfac=stepfac,$
                 extra=extra

 common funct_val,pder_nozero

 on_error,1
 s=size(funct)
 if datatype(funct) ne 'STR' then message,'enter a function name'


 if n_params() eq 2 then begin
  return,double(call_function(funct,x,a,extra=extra))
 endif

;-- compute partial derivatives?

 nx=n_elements(x) 
 na=n_elements(a)
 if n_elements(fixp) eq 0 then fixp=-1
 f=double(call_function(funct,x,a,pder))
 
 sp=size(pder)

 if sp(0) ne 2 then begin    ;-- compute PDE numerically

  if n_elements(stepfac) eq 0 then stepfac=.001

  pder=dblarr(nx,na) & b=a
  for k=0,na-1 do begin        ;perturb each variable
   chk=where(k eq fixp,count)
   if (count eq 0) then begin
    step=stepfac*a(k)
    if step eq 0. then step=.001
    b(k)=a(k)+step
    fp=double(call_function(funct,x,b))
    b(k)=a(k)-step
    fm=double(call_function(funct,x,b))
    pder(nx*k)=(fp-fm)/2.d0/step
    b(k)=a(k)
   endif
  endfor
 endif

;-- link parameters?

 if n_elements(corr) ne 0 then begin
  sp=size(corr)
  if (sp(1) eq na) and (sp(2) eq na) then pder=pder#corr else $
    message,'invalid correlation matrix'
 endif

;-- fix parameters?
 
 if min(fixp) ne -1 then begin
  par=replicate(1.,na)
  par(fixp)=0
  vary=where(par ne 0,count)
  if (count lt na) then pder=pder(*,vary)
 endif

 return,f
 end
