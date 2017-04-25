;+
; NAME:
;     SEC2HMS
; PURPOSE:
;     Function that converts a time in seconds to HHMMSS format
; CATEGORY:
;     OVRO APC UTILITY
; CALLING SEQUENCE:
;     hhmmss = hms2sec(sec)
; INPUTS:
;     sec       the time in seconds
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
; ROUTINES CALLED:
; OUTPUTS:
;     hhmmss    the converted time, in HHMMSS format, as a REAL number
; COMMENTS:
; SIDE EFFECTS:
; RESTRICTIONS:
; MODIFICATION HISTORY:
;     Written 26-Sep-1997 by Dale Gary
;-
function sec2hms,t

  hh = fix(t/3600.)
  mm = fix((t mod 3600.)/60.)
  ss = (t mod 60.)

return, hh*10000.+mm*100.+ss
end
