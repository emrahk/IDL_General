;+
; Project     : HESSI
;
; Name        : GET_HEAP_INDEX
;
; Purpose     : Function to return the heap index of a pointer or object as a string.  If variable is not a
;	pointer or object, returns an empty string.
;
; Category    : utility objects
;
; Explanation : Parses output of help,var,output=output to find heap index.  Will not work if RSI changes
;   format of help output.
;
; Syntax      : IDL> index = get_heap_index(var)
;
; Examples    : if  get_heap_index(a) eq get_heap_index(b) then print,'a and b are the same object'
;
; Inputs      :		var - object or pointer to get heap index of (scalar or array)
;
; Opt. Inputs : None
;
; Outputs     : string containing heap index, or empty string if not a heap variable. (or array of 
;   strings, one for each element in var)
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Restrictions: Uses output of help,var so if RSI changes the format of the help output,
;		this won't work.
;
; Side effects: None
;
; History     : Written 17 Aug 2000, Kim Tolbert
;
; Contact     : kim.tolbert@nasa.gov
; Modifications:
; 27-Feb-2013, Kim. Make it work on an array of input variables
;-
function get_heap_index, var

nvar = n_elements(var)
ind = strarr(nvar)

for i = 0,nvar-1 do begin
  help, var[i], output=output

  pos = strpos (output, 'HeapVar')
  if pos[0] eq -1 then ind[i] = '' else begin
    output = strmid(output, pos[0] + 7)
    pos = strpos (output, '(')
    if pos[0] eq -1 then pos = strpos (output, '>')
    if pos[0] eq -1 then ind[i] = '' else  ind[i] = strmid(output, 0, pos[0])
  endelse
endfor

return, nvar eq 1 ? ind[0] : ind

end

