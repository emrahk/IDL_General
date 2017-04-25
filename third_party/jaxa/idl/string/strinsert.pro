;+
; Project     : RHESSI
;
; Name        : STRINSERT
;
; Purpose     : Insert the supplied string in the input string at the specified location. 
;
; Explanation : 
;
;               eg. IDL> print,strinsert ('abcdefgcd', 'xxx', 3) --> 'abcxxxdefgcd
;
; Use         : Result = strinsert(input,new,offset)
;
; Inputs      :
;               input=any string
;               new=new characters to insert
;               offset = location in input to insert new (starting at 0) If not specified, =0.
;
; Outputs     : Result = new string.
;
; Keywords    : None
;
; Category    : String processing
;
; Written     : Kim Tolbert, 1-Feb-2010. (preferred name, str_insert, already taken for structures)
;
; Modified    : 
;-
;

function strinsert, input, new, offset

if new eq '' then return, input

checkvar, offset, 0
offset = offset > 0
b = byte(input)
blen = n_elements(b)
b_new = byte(new)
b_out = offset eq 0 ? b_new : [ b[0:(offset-1) < (blen-1)], b_new ]
b_out = offset lt blen ? [b_out, b[offset:blen-1]] : b_out
return, string(b_out)
end
