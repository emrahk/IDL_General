;+
; Project     : HESSI
;
; Name        : VSO_JAVA_CHECK
;
; Purpose     : Check VSO Java libraries
;
; Category    : synoptic sockets VSO
;
; Inputs      : TINTERVAL = seconds between pinging server [def=300]
;
; Outputs     : 1/0 if up or down
;
; Keywords    : RESET = don't check common for last saved status
;
; History     : Written 22-Dec-2009, Zarro (ADNET)
;               15-March-2010, Zarro (ADNET) 
;               - added more error checks
;               24-March-2010, Zarro (ADNET)
;               - removed check for Prepserver status 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function vso_java_check,tinterval,err=err,quiet=quiet,reset=reset

common vso_java_check,last_status,last_time,interval,last_err,last_java_check


err=''
reset=keyword_set(reset)
verbose=~keyword_set(quiet)

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 goto,bail
endif

;-- limit checking to specified intervals

if is_blank(last_err) then last_err=''
if ~exist(interval) then interval=300.
if exist(tinterval) then interval=tinterval
if exist(last_time) and exist(last_status) and ~reset then begin
 now=systime(/seconds)
 if (now-last_time) lt interval then begin
  err=last_err
  if is_string(err) and verbose then message,err,/cont
  return,last_status
 endif
endif
last_time=systime(/seconds)

;-- load Java libraries

vso_startup,err=err,status=status
if ~status then goto,bail

;-- only do the following Java compatibility check once

if ~exist(last_java_check) then last_java_check=0b
if reset or ~last_java_check then begin
 last_java_check = check_java_vso_compatibility()
 if ~last_java_check then begin
  err='Failed to load local Java libraries.'
  goto,bail
 endif
endif 

last_status=1b & last_err='' 
return,1b

bail: last_err=err & last_status=0b
if verbose then message,err,/cont

return,0b

end
