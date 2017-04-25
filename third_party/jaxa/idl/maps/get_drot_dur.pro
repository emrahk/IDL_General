;+
; Project     : SOHO-CDS
;
; Name        : GET_DROT_DUR
;
; Purpose     : compute durations (in seconds) to solar rotate a map
;
; Category    : imaging
;
; Explanation : cater for different types of inputs 
;
; Syntax      : dur=get_drot_dur(map,duration,time=time)
;
; Inputs      : MAP = time or map structure
;               DURATION = amount to rotate by [def=hours units]
;
; Outputs     : DUR = duration in seconds
;
; Keywords    : TIME = time (or map time) to rotate to
;               DAYS = input duration units in days
;               SECONDS = input duration units in seconds
;  
; History     : Written 5 June 1998, D. Zarro, SAC/GSFC
;               10 Jan 2005, Zarro (L-3Com/GSFC) 
;                - permitted zero duration
;               11 Dec 2014, Zarro (ADNET)
;                - TIME input can be a MAP
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_drot_dur,map,duration,time=time,days=days,seconds=seconds
err=''

;--check inputs

if ~valid_map(map) then begin
 pr_syntax,'dur=get_drot_dur(map,duration,[time=time])'
 return,0
endif

cur_time=get_map_time(map,/tai)
dtime=0.

case 1 of
 valid_time(time): dtime=(anytim2tai(time)-cur_time)
 valid_map(time): dtime=(get_map_time(time,/tai)-cur_time)
 else: begin
  if is_number(duration) then dtime=float(duration)
  case 1 of
   keyword_set(days): dtime=dtime*3600.*24.
   keyword_set(seconds) : do_nothing=1
  else: dtime=dtime*3600.
 endcase
 end
endcase

return,dtime
end
