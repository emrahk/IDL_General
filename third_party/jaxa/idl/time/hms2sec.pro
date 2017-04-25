;+
; NAME:
;     HMS2SEC
; PURPOSE:
;     Function that converts a time in HHMMSS format to time in seconds
; CATEGORY:
;     OVRO APC UTILITY
; CALLING SEQUENCE:
;     sec = hms2sec(hhmmss)
; INPUTS:
;     hhmmss    the time in HHMMSS format (a LONG integer or REAL)
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
; ROUTINES CALLED:
; OUTPUTS:
;     sec       the converted time, in seconds, as a REAL number
; COMMENTS:
; SIDE EFFECTS:
; RESTRICTIONS:
; MODIFICATION HISTORY:
;     Written 26-Sep-1997 by Dale Gary
;-

function hms2sec,t

  hh = fix(t/10000.)
  mm = fix((t mod 10000.)/100.)
  ss = t mod 100.

return, hh*3600.+mm*60.+ss
end
