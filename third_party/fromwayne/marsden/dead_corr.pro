pro dead_corr,idf,idf_hdr,livetime,idfarr,xulds,ulds,$
              arms,trigs,vetos,livetime_out,num=num
;***********************************************************
; Program applies the ULD corrections to the 
; deadtime rate. Variables are:
;           idf..........current idf
;       idf_hdr..........science header for idf
;      livetime..........uncorrected time
;        idfarr..........array of idfs for ULDs
;         xulds..........array of XULDs vs IDF
;          ulds..........array of ULDs vs IDF
;          arms..........array of arm rate vs IDF
;         trigs..........array of triggger rate vs IDF
;         vetos..........array of veto rate vs IDF
;  livetime_out..........corrected livetime
;           num..........array of good event #s/det
; First do usage:
;***********************************************************
common oldulds,xulds_old,ulds_old,idfarr_old,$
               arms_old,trigs_old,vetos_old,alpha,beta
if (n_elements(idf) eq 0)then begin
   print,'USAGE: dead_corr,idf,idf_hdr,' + $
          'livetime,idfarr,xulds,ulds,arm,' + $
           'trigger,veto,livetime_out,num=num'
   return
endif
;**********************************************************
; Make the temporary XULD, ULD, arm, trigger, and 
; veto arrays
;**********************************************************
xuld = lonarr(4) & uld = xuld & arm = xuld
trig = xuld & veto = xuld
if (n_elements(num) eq 0)then num = [0.,0.,0.,0.]
xulds_save = xulds
ulds_save = ulds
idfarr_save = idfarr
arms_save = arms
trigs_save = trigs
vetos_save = vetos
newcor = n_elements(arms) gt 4
;**********************************************************
; Spline fit for the parameter values for 
; the given IDF, if that IDF is not contained 
; in IDFARR. If IDF is closer to the old 
; parameter arrays, substitute the old arrays and 
; THEN update the old arrays with the new 
; ones. Got that?
;**********************************************************
in = where(idfarr eq idf)
if (in(0) ne -1)then begin
   xuld = float(reform(xulds(*,in(0))))
   uld = float(reform(ulds(*,in(0))))
   if (newcor eq 1)then begin
      arm = float(reform(arms(*,in(0))))
      trig = float(reform(trigs(*,in(0))))
      veto = float(reform(vetos(*,in(0))))
   endif else begin
      arm = arms
      trig = trig
      veto = veto
   endelse
endif else begin
   if (idf lt min(idfarr))then begin
      old = idf - max(idfarr_old)
      new = min(idfarr) - idf
      if (old lt new)then begin
         idfarr = idfarr_old
         xulds = xulds_old
         ulds = ulds_old
         arms = arms_old
         trigs = trigs_old
         vetos = vetos_old
         idfarr_old = idfarr
         xulds_old = xulds
         ulds_old = ulds
      endif
   endif   
   a1 = min(idfarr) - idf
   a2 = idf - max(idfarr)
   a3 = (idf gt min(idfarr)) and (idf lt max(idfarr)) 
   if (abs(a1) le 5 or abs(a2) le 5 or a3)then begin
      for i = 0,3 do begin
       xuld(i) = spline(idfarr,reform(xulds(i,*)),idf)
       uld(i) = spline(idfarr,reform(ulds(i,*)),idf)
       if (newcor)then begin
          arm(i) = spline(idfarr,reform(arms(i,*)),idf)
          trig(i) = spline(idfarr,reform(trigs(i,*)),idf)
          veto(i) = spline(idfarr,reform(vetos(i,*)),idf)
       endif else begin
          arm = arms
          trig = trigs
          vetos = veto
       endelse
      endfor
   endif
endelse
;************************************************************
; Define some variables:
;************************************************************
sz = size(livetime)
if (n_elements(alpha) eq 0)then alpha = 0.
if (n_elements(beta) eq 0)then beta = 0.
pos = idf_hdr.clstr_postn
dwell = idf_hdr.dwell_time
time = fltarr(4)
if (sz(1) eq 4)then begin
   for i = 0,3 do time(i) = total(livetime(i,*))
   nint = float(n_elements(livetime(*,0)))
   nbns = float(n_elements(livetime(0,*)))
endif else begin
   for i = 0,3 do time(i) = total(livetime(*,i))
   nint = float(n_elements(livetime(0,*)))
   nbns = float(n_elements(livetime(*,0)))
endelse
livetime_out = livetime*0.
;**********************************************************
; Get the fractional exposure f:
;**********************************************************
f = 1.
a = pos eq '0 (FOR +/- 3.0 DEG)'
b = pos eq '0 (FOR +/- 1.5 DEG)'
if (a eq 0 and b eq 0)then begin
   if (dwell eq '16 SECONDS')then f = .75
   if (dwell eq '32 SECONDS')then f = .875
endif
;**********************************************************
; Get the corrected deadtime. Follows W.A.H. program
; fixlvt.pro (please see for explanation):
;**********************************************************
gdcor = -3.75e-7
fxcor = -4.*2.125e-6
totxcor = 4.*alpha + fxcor
xacor = -4.*2.5e-7
vcor = -4.*3.e-6
ucor = 4.*beta
xarm = arm - trig
indx = where(xarm le 0.)
if (indx(0) ne -1)then xarm(indx) = 0.
xvto = veto - xarm - xuld
indx = where(xvto le 0.)
if (indx(0) ne -1)then xvto(indx) = 0.
;**********************************************************
; Form the new livetime:
;**********************************************************
dt0 = 16. - time
dt = dt0 + num*gdcor + f*(totxcor*xuld + xacor*xarm + $
     vcor*xvto + ucor*uld)
if (sz(1) eq 4)then begin
   for i = 0,3 do livetime_out(i,*) = (16. - dt(i))/nbns
endif else begin
   for i = 0,3 do livetime_out(*,i) = (16. - dt(i))/nbns
endelse
if (total(uld) eq 0.)then livetime_out = livetime
;**********************************************************
; Replace the ULD values:
;**********************************************************
ulds = ulds_save
xulds = xulds_save
idfarr = idfarr_save
arms = arms_save
trigs = trigs_save
vetos = vetos_save
;**********************************************************
; Thats all ffolks.
;**********************************************************
return
end


