; Modifications:
;  17-Oct-2002, Kim.  Added nbreak_log option
;  19-Mar-2003, Kim.  Added option in popup options to divide an interval into sub-intervals
;    by grouping data bins.
;    Also added code at the end (in sortandsave block) to clean up intervals; remove duplicate
;    intervals and any intervals whose start=end, and if data_bound is set, force intervals
;    to xaxis boundaries
;  23-Apr-2008, Kim. Added n_elements(se) eq 1 check for appending new_se to se
pro plotman_modify_int, what, int_info, int_index=int_index, nbreak=nbreak, lbreak=lbreak, $
	ndata=ndata, ntotalbreak=ntotalbreak, startint=startint, nosort=nosort, data_bound=data_bound, $
	error=error

error = 0

nint = int_info.nint
se = *int_info.se

sortandsave = 1

case what of

	'add': begin
		if int_info.new_se[0] ge int_info.new_se[1] then begin
			error = 1
			return
		endif
		if nint+1 gt int_info.max_intervals then begin
			msg = 'Maximum intervals allowed ( ' + strtrim(int_info.max_intervals,2) + ') already defined.'
			message, msg, /cont
			a = dialog_message (msg, /error)
			error =1
			return
		endif
		if nint eq 0 or n_elements(se) eq 1 then se = int_info.new_se else $
		    se = [ [se], [int_info.new_se] ]
		nint = nint + 1
		end

	'delete': begin

		; if didn't pass in interval number to delete, delete all intervals

		if not exist (int_index) then begin
			nint = 0
			se = [0.,0.]
		endif else begin
			new_nint = (nint - 1) > 0
			if new_nint eq 0 then se = [0.,0.] else begin
				if int_index eq (nint-1) then begin
					se = se[*,0:new_nint-1]
				endif else begin
					for i = int_index, nint-2 do se[*,i] = se[*,i+1]
					se = se[*,0:new_nint-1]
				endelse
			endelse
			nint = new_nint
		endelse
		end

	; break total interval length into n sub-intervals of equal length
	'nbreak': begin
		if not exist (int_index) then return
		if not keyword_set (nbreak) then return
		orig_se = se[*,int_index]
		plotman_modify_int, 'delete', int_info, int_index=int_index
		len = (orig_se[1] - orig_se[0]) / nbreak
		for i = 0,nbreak-1 do begin
			int_info.new_se = [ orig_se[0] + i*len, orig_se[0] + (i+1)*len ]
			plotman_modify_int, 'add', int_info, error=error, data_bound=data_bound
			if error then goto, endloop
		endfor
		endloop:
		sortandsave = 0
		end

	; break total interval length into n sub-intervals of equal length in log space
	'nbreak_log': begin
		if not exist (int_index) then return
		if not keyword_set (nbreak) then return
		orig_se = se[*,int_index]
		plotman_modify_int, 'delete', int_info, int_index=int_index
		len = (alog10(orig_se[1]) - alog10(orig_se[0])) / nbreak
		for i = 0,nbreak-1 do begin
			int_info.new_se = 10. ^ ([ alog10(orig_se[0]) + (i*len), alog10(orig_se[0]) + ((i+1)*len) ])
			plotman_modify_int, 'add', int_info, error=error, data_bound=data_bound
			if error then goto, endloop
		endfor
		endloop2:
		sortandsave = 0
		end

	; break total interval length into as many intervals of length lbreak as will fit
	'lbreak': begin
		if not exist (int_index) then return
		if not keyword_set (lbreak) then return
		orig_se = se[*,int_index]
		plotman_modify_int, 'delete', int_info, int_index=int_index
		nbreak = fix ((orig_se[1] - orig_se[0]) / lbreak)
		;print,orig_se, nbreak, lbreak
		for i = 0,nbreak-1 do begin
			int_info.new_se = [ orig_se[0] + i*lbreak, orig_se[0] + (i+1)*lbreak ]
			plotman_modify_int, 'add', int_info, error=error, data_bound=data_bound
			if error then goto, endloopb
		endfor
		endloopb:
		sortandsave = 0
		end

	'ndata': begin
		if not exist (int_index) then return
		if not keyword_set (ndata) then return
		if int_info.xaxis[0] eq -1 then begin
			a=dialog_message("Can't get x axis information for this type of data.")
			return
		endif
		orig_se = se[*,int_index]
		plotman_modify_int, 'delete', int_info, int_index=int_index
		q = min (abs(int_info.xaxis[0,*] - orig_se[0]), ind)
		;ind = find_ix (int_info.xaxis[0,*], orig_se[0])
		if ind eq -1 then return
		repeat begin
			int_info.new_se = [int_info.xaxis[0,ind], int_info.xaxis[1,ind+ndata-1]]
			plotman_modify_int, 'add', int_info, error=error, data_bound=data_bound
			if error then goto, endloopd
			ind = ind + ndata
			if ind+ndata-1 gt n_elements(int_info.xaxis[0,*])-1 then goto, endloopd
		endrep until int_info.xaxis[1,ind+ndata-1] gt orig_se[1]
		endloopd:
		sortandsave = 0
		end

	; starting at startint, make ntotalbreak intervals of length lbreak
	'ntotalbreak': begin
		if not exist(startint) then return
		if not exist(lbreak) then return
		if not exist(ntotalbreak) then return
		for i = 0, ntotalbreak-1 do begin
			int_info.new_se = startint + [i,i+1]*lbreak
			plotman_modify_int, 'add', int_info, error=error, data_bound=data_bound
			if error then goto, endloopt
		endfor
		endloopt:
		sortandsave = 0
		end

	else:

endcase

if sortandsave then begin

	; If data_bound is set, then force to closest data boundary.
	if keyword_set(data_bound) then begin
		for i =0, nint*2-1 do begin
			q = min (abs(se[i] - int_info.xaxis), index)
			se[i] = int_info.xaxis[index]
		endfor
	endif

	; Weed out duplicate intervals
	if n_elements(se[0,*]) gt 1 then begin
		sum = se[0,*] + se[1,*]
		diff = se[1,*] - se[0,*]
		q = find_dup(sum+diff)
		if q[0] ne -1 then se[*,q] = 0.
	endif

	; Weed out intervals whose start is same as end
	q = where (se[0,*] ne se[1,*], count)

	if count gt 0 then begin
		se = se [*,q]
		nint = count
	endif else begin
		se = [0.,0.]
		nint = 0
	endelse

	; Sort intervals by start of interval
	if not keyword_set(nosort) then begin
		if n_elements(se) gt 2 then begin
			q = sort(se[0,*])
			se = se[*,q]
		endif
	endif

	int_info.nint = nint
	*int_info.se = se

endif

end