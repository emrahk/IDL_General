;+
; NAME:
;  FITS_GET 
;
; PURPOSE:
;  function to return value(s) from specified column
;  GET analog of FITS_READ, i.e., checks whether file is ASCII or
;  BINARY table & uses correct routine to return value(s)
;
; CALLING SEQUENCE
;  values=fits_get(hdr,tab,field,rows,nulls)
;
; INPUTS:
;  hdr - FITS ASCII or BINARY header returned by FITS_READ
;  tab - FITS ASCII or BINARY table array returned by FITS_READ
;  field - field name or number
;
; OPTIONAL INPUTS:
;  rows -  scalar or vector giving row number(s)
;          Row numbers start at 0.  If not supplied or set to
;         -1 then values for all rows are returned
;
; OUTPUTS:
;  the values for the row are returned as the function value.
;  Null values are set to 0 or blanks for strings.
;
; OPTIONAL OUTPUT:
;  nulls - null value flag of same length as the returned data.
;          It is set to 1 at null value positions and 0 elsewhere.
;          If supplied then the optional input, rows, must also
;          be supplied.
;
; HISTORY:
;  written 04 Feb 1992 (GAR)
;  Always check for null values to prevent conversion errors
;  (W. Landsman          August 1990)
;-
;------------------------------------------------------------------
function fits_get,hdr,tab,field,rows,nulls
;
try=sxpar(hdr,'XTENSION')        ;determine if this is an image or a table
stry = size(try)
ns = n_elements(stry)
trytyp = stry(ns-2)             ;type code for try
;
if (trytyp eq 7) then begin      ;try is a string variable, OK
  try = strtrim(try,2)
  if (n_elements(rows) eq 0) then rows = -1      ;default is to return all
;
  case try of  
  'TABLE': values = ftget(hdr,tab,field,rows,nulls)
  'BINTABLE': values = tbget(hdr,tab,field,rows,nulls)
  'A3DTABLE': values = tbget(hdr,tab,field,rows,nulls)
  else: begin
     print,'Sorry, table is not FITS ASCII or BINARY'
     values = -1
     end
  endcase
endif else begin
  print,'Sorry, this is not a FITS table'
  values = -1
endelse
;
return,values
end
