function store_intervals::init, new, ut=ut, ident=ident

self.n_stored = 0b
if keyword_set(new) then self->add, new, ut=ut, ident=ident
return,1
end

;-----

pro store_intervals::cleanup
add_method,'free_var',self
self->free_var
end

;-----

pro store_intervals::add, new, ut=ut, ident=ident, err_msg=err_msg

err_msg = ''
for i = 0,self.n_stored-1 do begin
	if same_data (new, *((*self.int_str)[i]).int) then return
endfor

sz = size(new, /str)
if not (sz.n_elements eq 2 or (sz.n_dimensions eq 2 and sz.dimensions[0] eq 2)) then begin
	err_msg = 'Error - interval array must be [2] or [2,n]'
	message, err_msg, /cont
	return
endif

checkvar, ident, ''

a = {intervals_struct}
a.n_int = n_elements(new[0,*])
type = keyword_set(ut) ? 'Time' : 'Energy'
mm = minmax(new)
if keyword_set(ut) then mm = anytim(mm, /vms) else mm = strtrim (string(mm,format='(g12.4)'),2)
prefix = ident ne '' ? ident +', ' : ''
a.desc = prefix + strtrim(a.n_int,2) + ' ' + type + ' Intervals. Range: ' + mm[0] + ' to ' + mm[1]
a.ut = keyword_set(ut)
a.int = keyword_set(ut) ? ptr_new (anytim(new)) : ptr_new(new)

if self.n_stored eq 0 then self.int_str = ptr_new(a) else self.int_str = ptr_new(append_arr(*self.int_str, a))
self.n_stored = self.n_stored + 1

end

;-----

pro store_intervals::delete, all=all, index=index, desc=desc, err_msg=err_msg

err_msg = ''

if self.n_stored eq 0 then return

if keyword_set(all) then begin
	self.n_stored = 0
	free_var, self.int_str
endif

if n_elements(index) gt 0 then begin
	if index ge 0 and index lt self.n_stored then ind = index else $
		err_msg = 'Interval ' + strtrim(index,2) + ' is not stored.'
endif

if keyword_set(desc) then begin
	desc_arr = (*self.int_str).desc
	q = where (desc_arr eq desc, count)
	if count gt 0 then ind = q[0] else $
		err_msg = 'Interval to delete is not stored. (Description = ' + desc + ')'
endif

if n_elements(ind) gt 0 then begin
	ptr_free, (*self.int_str)[ind].int
	keep = indgen(n_elements(*self.int_str))
	if self.n_stored gt 1 then begin
		remove, ind, keep
		*self.int_str =(*self.int_str)[keep]
	endif
	self.n_stored = self.n_stored - 1
endif

if err_msg ne '' then a = dialog_message(err_msg)

end

;-----

function store_intervals::getdata, index=index, str=str, desc=desc, num_stored=num_stored

if keyword_set(num_stored) then return, self.n_stored

ns = self.n_stored

if keyword_set(desc) then begin
	if ns eq 0 then return, 'No intervals stored.' else return, (*self.int_str).desc
endif

if keyword_set(str) then begin
	if ns eq 0 then return, -1 else return, *self.int_str
endif

if n_elements(index) gt 0 then begin
	if ns eq 0 then return, -1 else begin
		if keyword_set(str) then return, (*self.int_str)[index] $
			else return, *((*self.int_str)[index]).int
	endelse
endif

return, *self.int_str  ; if nothing explicitly asked for, return array of structures
end

;-----

pro store_intervals::list, full=full

if self.n_stored eq 0 then print,'No intervals stored.' else begin
	list = [strtrim(fix(self.n_stored), 2) + ' interval sets stored in object.', '']
	if keyword_set(full) then begin

		for i = 0,self.n_stored-1 do begin
			list = append_arr (list, $
				[(*self.int_str)[i].desc, $
				'  ' + format_intervals(*((*self.int_str)[i]).int, ut=(*self.int_str)[i].ut eq 1), ''] )
		endfor

	endif else list = [list, (*self.int_str).desc]

	prstr, list, /nomore
endelse

end

;-----

pro store_intervals__define

dummy = {store_intervals, $
	n_stored: 0b, $			; number of sets of intervals stored
	int_str: ptr_new() }	; pointer to array of intervals_struct structure for each set

dummy = {intervals_struct, $	; structure containing each set of intervals
	n_int: 0, $				; number of intervals in this set
	desc: '', $				; ascii description of this set of intervals
	ut: 0b, $				; 0/1 means intervals are numbers or times
	int: ptr_new() }		; pointer to array of intervals edges (2,n)

end
