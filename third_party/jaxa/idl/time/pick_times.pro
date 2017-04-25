;+
; Project     : SOHO - CDS
;
; Name        : PICK_TIMES
;
; Purpose     : pick times from a selection
;
; Category    : planning
;
; Explanation : User enters TSTART/TEND. If either is not defined then
;               defaults are used. If /LAST is set, then the last used
;               times are used
;
; Syntax      : IDL> times=pick_times(tstart,tend)
;
; Inputs      : TSTART, TEND = input times to start selection
;
; Opt. Inputs : None
;
; Outputs     : TIMES= selected times
;
; Opt. Outputs: None
;
; Keywords    : CTIMES = last times to use if /LAST set
;               DTIMES = default times to use if TSTART/TEND not given
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-OCT-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function pick_times,tstart,tend,last=last,$
         dtimes=dtimes,ctimes=ctimes


if not exist(ctimes) then ctimes=[0.d,0.d]

;-- start with defaults

times_in=exist(tstart) or exist(tend)
times=[0.d,0.d]
if exist(dtimes) then begin
 if (dtimes(0) gt 0.) then times(0)=anytim2tai(dtimes(0))
 if (dtimes(1) gt 0.) then times(1)=anytim2tai(dtimes(1))
endif

;-- substitute user inputs

if exist(tstart) then times(0)=anytim2tai(tstart)
if exist(tend) then times(1)=anytim2tai(tend)

;-- substitute common block variables if user requests last times 
;   or no times are input

if keyword_set(last) or (not times_in) then begin
 if exist(ctimes) then begin
  if (ctimes(0) gt 0.) then times(0)=anytim2tai(ctimes(0))
  if (ctimes(1) gt 0.) then times(1)=anytim2tai(ctimes(1))
 endif
endif

;-- if still no times, substitute defaults

if exist(dtimes) then begin
 if (times(0) eq 0.d) and (dtimes(0) gt 0.) then times(0)=anytim2tai(dtimes(0))
 if (times(1) eq 0.d) and (dtimes(1) gt 0.) then times(1)=anytim2tai(dtimes(1))
endif

return,times & end
