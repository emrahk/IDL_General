;+
; Name:   reform_struct
;
; Purpose:  Convert a structure with tag arrays to a structure array of tags.
;
; Category: structure
;
; Explanation: The output structure array will have a dimension equal
;               to the dimension of the tag arrays. If tags have different
;               dimensions, then the output structure will have a dimension 
;               equal to the first tag (or the tag name passed in calling
;               arguments). Any tags that don't match that dimension are 
;               not included in the output structure.
;
; Syntax:  new_struct = reform_struct(var, tag, error=error)
;
; Inputs:  var - input structure to reform
; 
; Optional Inputs:  tag - string name of tag to use for dimension of output struct
;
; Keywords:  error - Returns error flag. 0 / 1 means no error / error.
;
; Example     : IDL> stc={a:findgen(100),b:findgen(100)}
;               IDL> out=reform_struct(stc)
;               IDL> help,out
;               OUT    STRUCT    = -> <Anonymous> Array[100]
;
; Restrictions: Al tags in input structure that will be included in output structure
;   must be singly dimensioned.
;
; History: Written by R.Schwartz as a method in hsi_spectrogram. Extracted
;   to a standalone function and documented by K. Tolbert, 13-Nov-2008
;
;-

function reform_struct, var, tag, error=error

    if n_elements( var ) gt 1 then return, var
    error = 1

    tags = tag_names( var )
    ; dimension of 'tag' tag will determine dimension of output struct
    default, tag, tags[0]
    test = have_tag( var, tag, i)
    if not test then begin
       message,/continue,tag + ' not found'

       return, var
       endif

    nel = n_elements( var.(i) )
    ntag = n_elements(tags)
    nels = lonarr( ntag)
    for i = 0, ntag-1 do nels[i] = n_elements( var.(i))
    ; only include tags that match dimension of selected tag
    sel = where( nels eq nel, nsel)
    var1 = str_subset( var, tags[sel])
    base = str_tagarray2scalar( var1, 0)
    var2 = replicate( base, nel)
    for i=0, nsel-1 do var2.(i) = var1.(i)
    error = 0
    return, var2
    end
