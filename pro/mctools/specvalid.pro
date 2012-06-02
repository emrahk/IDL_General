;
; Find whether spectrum contains valid data (i.e. data that is not
; either 0 or saturated), return 1 if spectrum contains valid data.
;
function specvalid, spec
  on_error, 1
  specinfo, spec, fmin, fmax, empty
  return, not empty
end

