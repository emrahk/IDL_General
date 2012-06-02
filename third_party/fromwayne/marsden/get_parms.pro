pro get_parms,mdl,num_lines,num_parms,a,a_string,mdln,fitme
;*******************************************************************
; Program gets the model parameters for a model
; Input variables are:
;          mdl................model to fit
;            a................array of parameter values
;     a_string................parameter names
;    num_lines................number of gaussian lines in fit
;    num_parms................number of parameters in model
;          mdl................mdl + num_lines
; The possible models are:
;       MODEL                  ROUTINE
;  N gaussian lines           nline.pro
;  N lines + const.           nline_const.pro
;  N lines + linear           nline_lnr.pro
;  N lines + pwrlw            nline_pwrlw.pro
;  N lines + pwrlw + const.   nline_pwrlw_const.pro
; 8/26/94 Annoying print statements removed
;******************************************************************
nz = where(a ne 0.)
if (fitme ne 0 and nz(0) ne -1)then return
if (mdl eq 'N GAUSSIAN LINES')then begin
   num_parms = 3*num_lines
   a = fltarr(num_parms) & a_string = strarr(num_parms)
   for i = 0,num_lines - 1 do begin
    b = 'LINE ' + string(i+1) + ' , ' + ' NORMALIZATION' 
    a_string(3*i) = strcompress(b)
    b = 'LINE ' + string(i+1) + ' , ' + ' CENTROID'
    a_string(3*i + 1) = strcompress(b)
    b = 'LINE ' + string(i+1) + ' , ' + ' SIGMA'
    a_string(3*i + 2) = strcompress(b)
   endfor
endif 
if (mdl eq 'N LINES + CONST.')then begin
   num_parms = 3*num_lines + 1
   a = fltarr(num_parms) & a_string = strarr(num_parms)
   a_string(0) = 'CONSTANT'
   for i = 0,num_lines - 1 do begin   
    b = 'LINE ' + string(i+1) + ' , ' + ' NORMALIZATION' 
    a_string(3*i + 1) = strcompress(b)
    b = ' CENTROID'
    a_string(3*i + 2) = strcompress(b)
    b = ' SIGMA'
    a_string(3*i + 3) = strcompress(b)
   endfor
endif
if (mdl eq 'N LINES + LINEAR')then begin
   num_parms = 3*num_lines + 2
   a = fltarr(num_parms) & a_string = strarr(num_parms)
   a_string(0) = 'SLOPE' & a_string(1) = 'CONSTANT'
   for i = 0,num_lines - 1 do begin   
    b = 'LINE ' + string(i+1) + ' , ' + ' NORMALIZATION' 
    a_string(3*i + 2) = strcompress(b)
    b = 'CENTROID'
    a_string(3*i + 3) = strcompress(b)
    b = 'SIGMA'
    a_string(3*i + 4) = strcompress(b)
   endfor
endif
if (mdl eq 'N LINES + PWRLAW')then begin
   num_parms = 3*num_lines + 2
   a = fltarr(num_parms) & a_string = strarr(num_parms)
   a_string(0) = 'PWRLAW NORMALIZATION'
   a_string(1) = 'PWRLAW SPECTRAL INDEX'
   for i = 0,num_lines - 1 do begin   
    b = 'LINE ' + string(i+1) + ' , ' + ' NORMALIZATION' 
    a_string(3*i + 2) = strcompress(b)
    b = ' CENTROID'
    a_string(3*i + 3) = strcompress(b)
    b = ' SIGMA'
    a_string(3*i + 4) = strcompress(b)
   endfor
endif
if (mdl eq 'N LINES + PWRLAW + CONST.')then begin
   num_parms = 3*num_lines + 3   
   a = fltarr(num_parms) & a_string = strarr(num_parms)
   a_string(0) = 'PWRLW NORMALIZATION'
   a_string(1) = 'PWRLW SPECTRAL INDEX'
   a_string(num_parms-1) = 'CONSTANT'
   for i = 0,num_lines - 1 do begin   
    b = 'LINE ' + string(i+1) + ' , ' + ' NORMALIZATION' 
    a_string(3*i + 2) = strcompress(b)
    b = ' CENTROID'
    a_string(3*i + 3) = strcompress(b)
    b = ' SIGMA'
    a_string(3*i + 4) = strcompress(b)
   endfor
endif
;********************************************************************
; Incorporate 'num_lines' into model string mdl
;********************************************************************
place = strpos(mdl,'N')
frnt = strmid(mdl,0,place-1) & bck = strmid(mdl,place+1,strlen(mdl))
mdln = strcompress(frnt + ' ' + string(num_lines) + ' ' + bck)
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end

