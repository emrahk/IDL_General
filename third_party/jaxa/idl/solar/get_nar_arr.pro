; Project     : SOHO - CDS
;
; Name        : GET_NAR_ARR
;
; Purpose     : Wrapper around GET_NAR
;
; Category    : planning
;
; Explanation : Get NOAA AR pointing info
;
; Syntax      : IDL>nar=get_nar_arr(tstart)
;
; Inputs      : TSTART = start time
;
; Opt. Inputs : TEND = end time
;
; Outputs     : NAR = array with NOAA info
;
; History     : 16-Feb-2006, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_nar_arr,tstart,tend,count=count,_extra=extra
 nar=get_nar(tstart,tend,count=count,_extra=extra)
 if count eq 0 then return,''
 return,[[nar.time],[nar.day],[nar.noaa],[nar.x],[nar.y]] 
 end


