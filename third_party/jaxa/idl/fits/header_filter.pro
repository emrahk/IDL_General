;function HEADER_FILTER, header, keysToFilter
;+
; NAME:
;       HEADER_FILTER
; PURPOSE:
;       Removes the keys listed in keysToFilter array from the input string array
;
; CALLING SEQUENCE:
;       Result = HEADER_FILTER(header, keysToFilter)
;
; INPUTS:
;       Header        = String array containing keys to be filtered
;       KeysToFilter  = String array containing keys to filter out from the Header
;
; OUTPUTS:
;       Result of function = filtered string array
;
; EXAMPLE:
;       Remove the elements matching with words specified in keysToFilter from the header
;              of a FITS file extension
;       IDL>  print, HEADER_FILTER(header, keysToFilter)
;
; PROCEDURES CALLED
;
; MODIFICATION HISTORY:
; Sandhia Bansal   - Initial release - 11/05/2004
;-

function header_filter, header, keysToFilter


nRem = n_elements(keysToFilter) - 1
for i=0, nRem do begin
   indices = where(strmid(header, 0, strlen(keysToFilter[i])) NE keysToFilter[i], count)
   if (count GT 0) then $
      header = header[indices]
endfor

return, header

end
