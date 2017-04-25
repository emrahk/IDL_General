function seq_summary, roadmap, seq_params, table, entry, seq_num, qprint=qprint, fheader=fheader, $
		out2=out2, out3=out3, noheader=noheader, extra_out=extra_out
;
;NAME:
;	seq_summary
;PURPOSE:
;	To return a summary of the different images available
;	in the images grabbed
;CALLING SEQUENCE:
;	seq_sum = seq_summary(roadmap)
;	seq_sum = seq_summary(roadmap, seq_param, /qprint)
;	seq_sum = seq_summary(roadmap, seq_param, table, entry, seq_num, /qprint)
;INPUT:
;	roadmap	- the SXT roadmap structure
;OUTPUT:
;	returns a string array of the different images/tables available
;	seq_param- A structure with .table, .entry and .seq which are the
;		   values for the corresponding string printed out
;	table	- the field roadmap.seq_tab_serno
;	entry	- the field roadmap.obsregion extracted (different for
;		  pfi and ffi)
;	seq_num	- the field roadmap.seq_num extracted
;	out2	- A string array the same length as the function return which
;		  has information on the range of times for each sequence.
;	out3	- Similar to "out2", but has the location and deviation from
;		  that location.
;	noheader- If set, do not have a header line.
;	extra_out- If set, then derive OUT2 and OUT3 outputs (done this way
;		  because the call to FOV2NAR is time consuming and should not
;		  be called unless necessary)
;HISTORY:
;	Written Fall '91 by M.Morrison
;	25-Apr-92 (MDM) Added headers
;			Added the parameters "table", "entry" and "seq_num"
;	27-Jan-93 (MDM) Added OUT2 and OUT3 option
;	24-Mar-93 (MDM) Added /EXTRA_OUT option so that OUT2 and OUT3 are
;			not derived unless that switch is set
;	19-Aug-93 (MDM) Replaced GT_FOV_CENTER call with GT_CENTER call
;	 1-Oct-93 (MDM) Modified so that the history of pointing is checked
;			and the pointing used for the most images are used
;		 	when calculating the heliocentric coordinate.
;-
;
table = roadmap.seq_tab_serno
seq_num = roadmap.seq_num
if (btest0(roadmap(0).pfi_ffi, 0)) then entry = mask(roadmap.obsregion, 6, 2) $	;ffi
				else entry = mask(roadmap.obsregion, 4, 2)	;pfi
dpmode = roadmap.dp_mode mod 32
dprate = roadmap.dp_rate / 32
;
seq_params0 = make_str('{dummy, seq: 0, table: 0, entry: 0}')
;
str = '     Seq#  #Img Mode/Rate Tab/Entry             Description       '
out = str
seq_params = seq_params0
out2 = '    Times                '
out3 = '    Location'
if (keyword_set(qprint)) then print,str
for iseq=1,13 do begin
    ss = where(seq_num eq iseq)
    n = 0
    if (ss(0) ne -1) then n = n_elements(ss)
    str = string("Seq#", iseq, n, format='(a4,i3,3x,i5)')
    str = str + '  --------------------------------------------------------------'
    seq_params = [seq_params, seq_params0]
    out = [out, str]
    out2 = [out2, ' ']				;blank line
    out3 = [out3, ' ']				;blank line
    if (keyword_set(qprint)) then print,str
    for itab=min(table),max(table) do begin
	for ientry=0,3 do begin
	    ss = where((seq_num eq iseq) and (table eq itab) and (entry eq ientry))
	    if (ss(0) ne -1) then begin
		seq_params0.seq = iseq
		seq_params0.table = itab
		seq_params0.entry = ientry
		;
		if (dpmode(ss(0)) eq 9) then dpmode_str = 'FL' else dpmode_str = 'QT'
		if (min(dpmode(ss)) ne max(dpmode(ss))) then dpmode_str = 'FQ'
		if (dprate(ss(0)) eq 4) then dprate_str = 'Hi ' else dprate_str = 'Med'
		if (min(dprate(ss)) ne max(dprate(ss))) then dprate_str = 'HMd'
		str = string(n_elements(ss), format='(4x,3x,3x,i5)')
		str = str + '  ' + dpmode_str + '/' + dprate_str
		str = str + string(itab, ientry, format = '(2x, i4,"/",i1)')
        	temp = get_info2(roadmap(ss(0)), /noninteractive)
        	str = str + '  = ' + strmid(temp(0), 32, 100)
		;
		if (keyword_set(extra_out)) then begin
		    nn = n_elements(ss)
		    str2 = fmt_tim(roadmap(ss(0))) + ' - ' + gt_time(roadmap(ss(nn-1)),/str)
		    fov = gt_center(roadmap(ss), /cmd, /angle)/60.	;2xN
		    rrr = sqrt(  (fov(0,*)-fov(0,0))^2 + (fov(1,*)-fov(1,0))^2 )
		    dev = string(max(rrr), format='(f5.1)')

		    vals = (fov(0,*)+20) + (fov(1,*)+20)*40		;added 1-Oct-93
		    ii = get_most_comm(vals, uvals, h)

 		    loc = gt_center( roadmap(ss(ii)), /cmd, /helio, /str)
		    noaa = fov2nar(roadmap(ss(ii)))
		    str3 = loc + '  (' + dev + ')'
		    if (noaa(0) ne '') then str3 = str3 + ' ['+noaa+']'
		    out2 = [out2, str2]
		    out3 = [out3, str3]
		end
		;
		seq_params = [seq_params, seq_params0]
		out = [out, str]
		if (keyword_set(qprint)) then print,str
	    end
	    seq_params0.table = 0	;zero out for testing data presence cases
	end
    end
end
;
if (keyword_set(noheader)) then begin
    out = out(1:*)
    out2 = out2(1:*)
    out3 = out3(1:*)
end
;
return, out
end
