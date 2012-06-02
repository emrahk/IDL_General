PRO TRIPP_SMOOTH, x ,y, sm, xsm, ysm
;+
; NAME:                
;                    TRIPP_SMOOTH
;
;
;
; PURPOSE:           
;                     box smoothing 
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:      
;                  Version 1.0 1999   Stefan Dreizler
;
;-


on_error,2                      ;Return to caller if an error occurs

step = fix(sm/2)


x = reform(x)   ; reduce one-dimensional arrays to vectors
y = reform(y)

dimx = size(x)
dimy = size(y)

IF dimx[1] NE dimy[1] THEN BEGIN
   PRINT,'% TRIPP_SMOOTH: Size of Arrays unequal, stopping ...'
   STOP
ENDIF

dim=dimx[1]

xsm = dblarr(dim)
ysm = dblarr(dim)


;; -------------------------------------------------------------------------

CASE 1 OF

     (sm EQ 1)           : BEGIN
                               xsm = x
                               ysm = y
                           END

     (sm EQ 2 OR sm EQ 4): BEGIN
                           ;; --- kepp the beginning as it is
                           FOR i = 0,step-1 DO BEGIN
                               xsm[i] = x[i]
                               ysm[i] = y[i]
                           ENDFOR
                           ;; --- box - smoothing
                           FOR i = step,dim-step DO BEGIN
                     ;PRINT,i,step,x[i-step:i],total(x[i-step:i]),float(sm)
                              xsm[i] = total(x[i-step:i])/float(sm)
                              ysm[i] = total(y[i-step:i])/float(sm)
                           ENDFOR
                           ;; ---- kepp the end as it is
                           IF STEP GT 1 THEN BEGIN
                               FOR i = dim-step+1,dim-1 DO BEGIN
                                   xsm[i] = x[i]
                                   ysm[i] = y[i]
                               ENDFOR
                           ENDIF
                         END

     (sm EQ 3 OR sm EQ 5): BEGIN
                           ;; --- keep the beginning as it is
                           FOR i = 0,step-1 DO BEGIN
                               xsm[i] = x[i]
                               ysm[i] = y[i]
                           ENDFOR
                           ;; --- box - smoothing
                           FOR i = step,dim-step-1 DO BEGIN
                              xsm[i] = total(x[i-step:i+step])/float(sm)
                              ysm[i] = total(y[i-step:i+step])/float(sm)
                           ENDFOR
                           ;; ---- keep the end as it is
                            FOR i = dim-step,dim-1 DO BEGIN
                                xsm[i] = x[i]
                                ysm[i] = y[i]
                            ENDFOR
                         END
     ELSE: PRINT,'% TRIPP_SMOOTH: smotthing parameter too large: '+strtrim(string(sm),2) 

ENDCASE

;; -------------------------------------------------------------------------

END
