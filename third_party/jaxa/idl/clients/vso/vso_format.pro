;+
; Project     : VSO
;
; Name        : vso_format
;
; Purpose     : return time in VSO format [yyyymmddhhmmss]
;
; Category    : VSO, utility, time
;
; Syntax      : IDL> vso_time=vso_format(time,err=err)
;
; Inputs      : TIME = any time
;
; Outputs     : VSO_TIME = VSO time
;
; Keywords    : ERR = error string
;
; History     : 12-Nov-2005, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function vso_format,time,err=err

err=''
utc=anytim2utc(time,err=err,/ext)
if is_string(err) then return,0

temp=[utc.year,utc.month,utc.day,utc.hour,utc.minute,utc.second]
temp=strtrim(str_format(temp,'(i4.2)'),2)
return,arr2str(temp,delim='')

end

