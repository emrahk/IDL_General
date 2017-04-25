;+
; Project     : HESSI
;
; Name        : NEAR_TIME
;
; Purpose     : Find index of time array nearest input time
;
; Category    : time, utility
;
; Syntax      : IDL> chk=near_time(times,itime)
;
; Inputs      : TIMES = time array to search
;               ITIME = time value to search on
;
; Outputs     : INDEX = index of nearest time element
;               
; History     : Written,  1-Dec-2003, Zarro (L-3Com/GSFC)
;               Improved, 28-Dec-2005, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function near_time,times,itime

index=-1
if (not exist(times)) or (1-valid_time(itime)) then return,index

dtype=size(times,/type)
itype=size(itime,/type)

if itype le 5 then dtime=itime else dtime=anytim2tai(itime)
if dtype le 5 then begin
 diff=min(abs(times-dtime),index)
endif else begin
 diff=min(abs(anytim2tai(times,err=err)-dtime),index) 
 if is_string(err) then begin
  message,err,/cont
  index=-1
 endif
endelse

return,index

end
