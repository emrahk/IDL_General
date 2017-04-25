;+
; Project     : SDAC
;                   
; Name        : EVENTS_BY_TIME
;               
; Purpose     : This procedure finds events for different instruments over input time
;		intervals.
;               
; Category    : GEN, HXRBS, BATSE, GRS, SPEX
;                                     
; Explanation : This procedure assembles the various software written for the
;		different instruments and returns sufficient information to
;		find the event numbers or filenames spanning the time interval
;               
; Use         : 
;    
; Inputs      : Instrument
;		Time
;               
; Opt. Inputs : None
;               
; Outputs     : Events
;		Select_list
;		Type
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls       :
;
; Common      : None
;               
; Restrictions: To date, only HXRBS, BATSE, and SMM GRS are covered
;               
; Side effects: None.
;               
; Prev. Hist  :
;
; Modified    : Version 1, RAS, 28-mar-1997
;
;-            
;==============================================================================
pro events_by_time, instrument, time, events, select_list

ut = anytim(time, /sec)
if n_elements(ut) eq 1 then ut = [ut, ut+86400.]

case 1 of
	strpos(strupcase(instrument), 'HXRBS') ne -1: begin
	header = string('Flare#  ', 'Start time  ', 'End time  ', $
		'Peak Rate  ','Total Counts')
	ut(0) = ut(0) > utime('14-feb-1980') < utime('19-nov-1989')
	ut(1) = ut(1) > ut(0) < utime('19-nov-1989')
	search = string(ut(0))+'<start_sec<'+string(ut(1))
	search_hxrbs_db, search, list, fldata
        if list(0) gt 0 then begin
	events = fldata.flare_num
        numfl = n_elements(events)
  	select_list = strarr(numfl)
	for i=0,numfl-1 do begin
	tc = fldata.tot_counts
	if tc(i) eq -7777 or tc(i) eq 1e13 then tc_string = 'unknown' else begin
        if tc(i) le 99999 then $
            tc_string = string(tc(i), format='(i5)') else $
            tc_string = string(tc(i), format='(e8.2)')
	endelse
	fl_st=fldata.start_secs & fl_pe=fldata.peak_rate
	fl_fl=fldata.flare_num & fl_du=fldata.duration
	select_list(i) = string (fl_fl(i), $
                    strmid(atime(/yohkoh, fl_st(i)),0,18), ' - ', $
                    strmid(atime(/yohkoh, fl_st(i) + fl_du(i)),10,8), $
                    fl_pe(i), tc_string, $
                    format = '(i5, 3x, a18, a3, a8, 3x, i7, 7x, a)') 
   	endfor
	endif else begin
		select_list = [header, '******************  No events selected ****************']
	endelse
	select_list = 'HXRBS '+[header, select_list]

	endelse
	end



	strpos(strupcase(instrument), 'BATSE') ne -1: then 
	header = string('Burst#  Flare#  ', 'Start time  ', 'End time  ', $
		'Peak Rate  ','Total Counts')
	ut(0) = ut(0) > utime('15-apr-1981') < utime(!stime)
	ut(1) = ut(1) > ut(0) < utime(!stime)
	flist, incomm=['start,'+atime(ut(0)),'end,'+atime(ut(1))','exit']
	flare_select, good, inp_good=indgen(2e4)
	if good(0) ne -1 then begin
	read_flare, good(0), fldata
	
	fldata = replicate( good, n_elements(good) )
	for i=0,n_elements(good)-1 do begin
		read_flare, good(i), temp
		fldata(i) = temp
	endfor
	events = good
        numfl = n_elements(events)
  	select_list = strarr(numfl)
	for i=0,numfl-1 do begin
	tc = fldata.total_counts
	if tc(i) eq -7777 or tc(i) eq 1e13 then tc_string = 'unknown' else begin
        if tc(i) le 99999 then $
            tc_string = string(tc(i), format='(i5)') else $
            tc_string = string(tc(i), format='(e8.2)')
	endelse
	fl_st=fldata.start_secs & fl_pe=fldata.peak_rate
	fl_fl=fldata.flare_num & fl_du=fldata.duration
	select_list(i) = string (fl_fl(i), $
                    strmid(atime(/yohkoh, fl_st(i)),0,18), ' - ', $
                    strmid(atime(/yohkoh, fl_st(i) + fl_du(i)),10,8), $
                    fl_pe(i), tc_string, $
                    format = '(i5, 3x, a18, a3, a8, 3x, i7, 7x, a)') 
   	endfor
	select_list = string(form='(i5)',fldata.burst_num)+'   '+select_list				
	endif else begin
		select_list = [header, '******************  No events selected ****************']
	endelse
	select_list = 'BATSE '+[header, select_list]
	end



	strpos(strupcase(instrument), 'SMM') ne -1 and 	$
	strpos(strupcase(instrument), 'GRS') ne -1: then 
	header = 'File Name     File Start           File End                Peak Rate(300-350 keV)'
	p=break_path(!path)
	w=where(strpos(strupcase(p),'GRS') ne -1, nw)
	if nw ge 1 then p=p(w)
	genfile=loc_file('grs_file_times.genx',path=path,count=count)
	restgen, file=genfile, p,/quiet
	w=where( (p.stime ge ut(0) and p.stime le ut(1) ) $
		or (p.etime ge ut(0) and p.etime le ut(1)), nw)	
	if nw ge 1 then begin
		events = w
		ev = p(w)
		select_list = strarr(nw)
		for i=0,nw-1 do select_list(i) = string( string(ev(i).fnam), $
		anytim(/trunc,ev(i).stime,/yoh), anytim(/trunc, ev(i).etime,/yoh), ev(i).prat,$
		format='(a,2x,a,3x,a,f9.1)')	
		header = 'File Name     File Start           File End                Peak Rate(300-350 keV)'
	endif else begin
		select_list = [header, '******************  No events selected ****************']
	endelse
	select_list = 'GRS  '+ [header,select_list]
	end


	strpos(strupcase(instrument), 'YOHKOH') ne -1 and 	$
	strpos(strupcase(instrument), 'HXT') ne -1: then 
	header = 'Flare Trigger Start   Flare Trigger End
	get_utevent, ut(0), ut(1), yo_fstart, yo_fstop, /flare
	if keyword_set(yo_fstart) then begin
		date = anytim(/date,[yo_fstart,yo_fstop])
		date = date( uniqo(date) )
		ydays = parse_atime,date,year=year,month=month, day=day, /string
		hda1 = loc_file('hda'+ydays(0)+'*.*', path=data_paths(), count=count1)
		if n_elements(date) eq 2 then $
		hda2 = loc_file('hda'+ydays(1)+'*.*', path=data_paths(), count=count2)
		case 1 of
			count1 gt 0 and count2 gt 0: hda=[hda1,hda2]
			count1 gt 0 and count2 eq 0: hda=hda1
			count1 eq 0 and count2 gt 0: hda=hda2
			else: hda=''
		endcase
		
		if keyword_set(hda) then begin
			filetimes, hda, startt, stopt
	

;	utlim = anytim(/sec, [yo_fstart(0),yo_fstop(n_elements(yo_fstop)-1)])
;	hda = loc_file('hda*.*',path=data_paths(), count=count)
;	if count ge 1 then begin
;		break_file, hda, disk, dir, fnam, ext
;		fdate = anytim( fid2ex( strmid(fnam, 3, 6)),/sec)
;		wut = where( fdate ge (utlim(0)-11e3) and fdate le (utlim(1)+11e3), nut)
;	endif		 
	nevents = 
	select_list = strarr( n
		select_list = anytim(/trunc, /yohk,yo_fstart)			
	end

endcase

end


