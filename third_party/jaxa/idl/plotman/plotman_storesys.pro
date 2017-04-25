; 30-Mar-2003, Kim.  added no_p keyword to not save !p structure
pro plotman_storesys, input, no_p=no_p

; input must be either the plotman object, or the state structure containing the object


if datatype (input) eq 'OBJ' then begin

	if keyword_set(no_p) then input -> set, xx=!x, yy=!y else $
		input -> set, xx=!x, yy=!y, pp=!p

endif else begin

	if tag_exist (input,'obj') then begin

		if keyword_set(no_p) then input.obj -> set, xx=!x, yy=!y else $
			input.obj -> set, xx=!x, yy=!y, pp=!p

	endif else print,'PLOTMAN_STORESYS: Can not find where to store system variables.'

endelse

end