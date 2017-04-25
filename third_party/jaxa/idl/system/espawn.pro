;+
; Project     : SOHO - CDS
;
; Name        : ESPAWN
;
; Purpose     : spawn a shell command and return STDIO and STDERR
;
; Category    : System
;
; Explanation : regular IDL spawn command doesn't return an error message
;
; Syntax      : IDL> espawn,cmd,out
;
; Inputs      : CMD = command(s) to spawn
;
; Keywords    : See SPAWN command
;
; Outputs     : OUT = output of CMD
;
; History     : Version 1,  24-Jan-1996, Zarro (ARC/GSFC) - written
;               Modified, 12-Nov-1999, Zarro (SM&A/GSFC) - made 
;                Windows compliant
;               Modified, 12-March-2000, Zarro (SM&A/GSFC) - sped
;                up with /NOSHELL (Unix only)
;               Modified, 22-May-2000, Zarro (EIT/GSFC) - added
;                /UNIQUE
;               Modified, 26-Mar-2002, Zarro (EER/GSFC) 
;                - sped up with caching 
;               29-Dec-2014, Zarro (ADNET) 
;                - cleaned up; removed caching
;               
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro espawn,cmd,out,_ref_extra=extra

windows=os_family(/lower) eq 'windows'

if arg_present(out) then begin
 if windows then win_spawn,cmd,out,_extra=extra else unix_spawn,cmd,out,_extra=extra
endif else begin
 if windows then win_spawn,cmd,_extra=extra else unix_spawn,cmd,_extra=extra
endelse

return

end
