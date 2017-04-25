;+
; Project     : HESSI
;
; Name        : NEAREST_GEV
;
; Purpose     : determine nearest GOES event to a particular time
;
; Category    : synoptic
;;
; Syntax      : IDL> gev=nearest_gev(time,during=during)
;
; Inputs      : TIME = time to check
;
; Outputs     : GEV = GOES event structure
;
; Keywords    : DURING = 1/0 if time is during GOES event
;
; History     : 6-Dec-2001, D.M. Zarro (EIT/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function nearest_gev,time,during=during

during=0b
if not valid_time(time) then begin
 pr_syntax,'gev=nearest_gev,time [,during=during]'
 return,''
endif

gev=get_gev(time,time,count=count,/quiet)

if count eq 0 then return,''

tstart=anytim(gev,/tai)
tend=tstart+gev.duration

tref=anytim2tai(time)

tdiff=abs(tref-tstart)
gfind=where(tdiff eq min(tdiff))

gfound=gev[gfind]
gstart=tstart[gfind]
gend=tend[gfind]

during=(tref ge gstart) and (tref le gend)

during=during[0]

return,gfound

end
