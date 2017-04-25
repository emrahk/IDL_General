;+
; PROJECT:
;	SSW
; NAME:
;	PTR_CONCAT
;
; PURPOSE:
;	This function concatenates the contents of dereferenced pointers that
;	contain identical structures or identical fields(tags).
;
; CATEGORY:
; 	Structures, Pointers
;
; CALLING SEQUENCE:
;	Result =  Ptr_Concat(ptrarr, index, valid, nvalid)
;
; INPUTS:
;       Ptrarr: array of pointers to be dereferenced
;
; OPTIONAL INPUTS:
;	IN_STRUCT- structure with tags to load into the same as those in the dereferenced
;		pointer's structure.  The return is 1
;
; OUTPUTS:
;      Index - Lonarr of Nvalid elements.  Gives position in Result for each valid pointer
;	   Valid  - Selected valid pointers
;	   Nvalid - total number of valid pointers
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	CHECK_TYPE - only concatenate identical numerical datatypes.
;	THESE_TAGS - only concatenate these specific tags
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	functions only at the top level, nothing recursive
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	10-feb-2009, Version 1, richard.schwartz@nasa.gov
;
;-

function ptr_concat, ptr, index, valid, nvalid, $
	check_type =check_type, these_tags=these_tags, in_struct=in_struct


index = 0
valid =where( size(/tname,ptr[0])  eq 'POINTER', nvalid)
if nvalid then valid = where(ptr_valid(ptr), nvalid)
if nvalid eq 0 then begin
	message,/cont, 'No valid pointers'
	return, 0
	endif
index = lonarr( nvalid )
first =(*ptr[valid[0]])[0]
ttags = get_uniq(these_tags)
if keyword_set( these_tags) then begin
	err_code = n_elements(get_tag_index(first,(ttags))) ne n_elements(ttags)
	if err_code then $
		err_msg='Not valid tags for structure found in pointer: '+arr2str(these_tags,' ')+'  not in ' +arr2str(tag_names(first))
	if not err_code then first = struct_subset( first, these_tags, /quiet, err_code=err_code, err_msg=err_msg)
	if err_code then begin
		 message,/continue,err_msg
		return,0
		endif
		endif
first_str = size(first, /str)
pass = min(abs( [0,10,11] - first_str.type) < 1) ; all one's can be concatenated, 0's can't
if not pass then begin
	message,/cont,'Data type cannot be concatenated, type = '+strtrim(first_str.type,2)
	return, 0
	endif
default, check_type, 0
check_type = first_str.type eq 8 ? 1 :check_type ;if we're concatenating structures the types must agree

type = first_str.type
for i=0L,nvalid-1 do begin
	nx_str =size(*ptr[valid[i]],/st)
	ntype= nx_str.type
	pass= (type eq 8) and (ntype eq 8) or $
	( ((type ne 8) and (ntype ne 8)) and ( check_type? type eq ntype : 1) )
	if not pass then begin
		valid[i] = 0
		endif else begin
		index[i] = nx_str.n_elements
		endelse
	endfor



sel = where(index<1, nvalid)
valid = valid[sel]
index = [0, index[sel]]

index = long(total(index,/cum))

if size(in_struct,/tname) ne 'STRUCT' then begin
;In this branch we're pulling the structure fields out of the pointer and concatenating
out = replicate( first[0], last_item(index))
for i=0L, nvalid-1 do begin
	nx = *ptr[valid[i]]
	nx_str = size(/str, nx)
	temp = replicate( first[0], nx_str.n_elements)
	if 	((first_str.type eq 8 and nx_str.type eq 8) and $
	(first_str.structure_name eq '' or nx_str.structure_name eq '') ) $
	then begin
		struct_assign, nx, temp
		nx = temp
		endif
		out[index[i]] =nx
	endfor
endif else begin
;In this branch we're loading the in_struct back in to each structure

ix = 0L ;placeholder in in_struct
nin = n_elements( in_struct)
for i=0L, nvalid-1 do begin
	nx = *ptr[valid[i]]
	nx_str = size(/str, nx)

	temp = ix + lindgen(nx_str.n_elements)
	nxtemp = ix + nx_str.n_elements
	if 	((first_str.type eq 8 and nx_str.type eq 8) and $
	(first_str.structure_name eq '' or nx_str.structure_name eq '') ) $
	then begin
		if nxtemp gt nin  or ((i eq (nvalid-1)) and (nxtemp ne nin)) then begin
			message, 'Mismatch between number of input structure elements and elements in ptr array'
			endif

		temp = in_struct[temp]
		ix = ix + nx_str.n_elements
		struct_assign, temp, nx,/nozero
		*ptr[valid[i]] = nx
		endif

	endfor
	out=1
	endelse
	return, out
end