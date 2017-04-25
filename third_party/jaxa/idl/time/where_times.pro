;+
; Project     : HESSI
;
; Name        : WHERE_TIMES
;
; Purpose     : check where times fall within input time limits
;
; Category    : HESSI, GBO, utility, time
;
; Syntax      : IDL> check=where_times(times,tstart=tstart,tend=tend,count)
;
; Inputs      : TIMES = time array to check (TAI format)
;
; Outputs     : CHECK = index of matching times
;
; Keywords    : TSTART = lower time limit (TIMES >= TSTART)
;               TEND   = upper time limit (TIMES <= TEND)
;               COUNT  = number of matches
;               INTERVALS = [2,*] array of start/end sub-intervals
;
; History     : Written, 9-Apr-1999,  D.M. Zarro (SM&A/GSFC)
;               Modified, 14-Feb-2008, Zarro (ADNET) - added INTERVALS

;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function where_times,times,tstart=tstart,tend=tend,count=count,$
               intervals=intervals

count=0
sz=size(times)
if (sz[1] gt 5) and (sz[1] lt 3) then begin
 pr_syntax,'check=where_times(times,tstart=tstart,tend=tend,count=count)'
 return,-1
endif

vstart=valid_time(tstart)
vend=valid_time(tend) 
if ~vstart and ~vend then begin
 count=n_elements(times)
 return,lonarr(count)
endif

t1=anytim2tai(tstart) & t2=anytim2tai(tend)

case 1 of
 (vstart and vend) : ss=where( (times ge t1) and (times le t2),count)
 vstart: ss=where(times ge t1,count)
 vend: ss=where(times le t2,count)
 else: ss=-1
endcase
 
;-- check for sub-intervals

nintervals=0l
sz=size(intervals)
if (sz[0] eq 2) and (sz[1] eq 2) then nintervals=sz[2]
if (sz[0] eq 1) and (sz[1] eq 2) then nintervals=1
if nintervals eq 0 then return,ss

found_one=0b
for i=0,nintervals-1 do begin
 dstart=anytim2tai(intervals[0,i])
 dend=anytim2tai(intervals[1,i])
 in_window=(dstart ge t1) and (dstart le t2) and $
           (dend ge t1)  and (dend le t2)
 if in_window then begin
  dprint,anytim2utc(dstart,/vms)+' - '+anytim2utc(dend,/vms) 
  found_one=1b
  chk=where( (times ge dstart) and (times le dend),icount)
  if icount gt 0 then begin
   if exist(nss) then nss=[temporary(nss),temporary(chk)] else nss=temporary(chk)
  endif
 endif
endfor

if ~found_one then begin
 message,'All intervals outside search window',/cont
 return,ss
endif
count=n_elements(nss)
if count gt 0 then ss=get_uniq(nss,count=count) else ss=-1

return,ss & end
