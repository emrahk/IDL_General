;+
; Project     : HESSI
;                  
; Name        : CLOSE_LUN
;               
; Purpose     : Same as FREE_LUN but with error checks
;                             
; Category    : system utility i/o
;               
; Syntax      : IDL> close_lun,lun
;
; Inputs      : LUN = logical unit number to free and close
;
; History     : 6 May 2002, Zarro (L-3Com/GSFC)
;               25 November 2015, Zarro (ADNET) - vectorized and added _extra
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro close_lun,lun,_ref_extra=extra,all=all

if keyword_set(all) then begin
 close,/all,/force
 return
endif

nlun=n_elements(lun)
if nlun eq 0 then return
for i=0,nlun-1 do begin

 error=0
 catch,error
 if error ne 0 then begin
  mprint,err_state()
  catch,/cancel
  continue
 endif

 slun=lun[i]
 if ~is_number(slun) then continue
 if slun le 0 then continue
 close,slun,/force,_extra=extra
 free_lun,slun,/force,_extra=extra

endfor

return & end
