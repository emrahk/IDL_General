pro html_temp2out, infil, outfil
;+
; NAME:
;	html_temp2out
; PURPOSE: 
;	Given a template html file, replace the file and gif names
;	denoted by <<FILE:filename>> and <<GIF:filename>> with the 
;	contents of the file or the appropriate HTML tags.
; OPTIONS:
;	<<FILE:filename>>	;text file <pre> insert
;	<<HFILE:filename>>	;html (or text) file insert
;	<<GIF:filename>>	;GIF file
;	<<UT_time>>		;Write UT time string
; SAMPLE CALLING SEQUENCE:
;	html_temp2out, infil, outfil
;	html_temp2out, '$MDI_CAL_INFO/log_health.thtml', 'log_health.html'
; OPTIONAL INPUT:
;	infil	- The path and file name of template file
;	outfil	- The path and file name of output file
; HISTORY:
;	Written 25-Mar-97 by S.Qwan
;	21-May-97 (MDM) - Renamed from "form" to "html_temp2out"
;			- Added the <pre> and such for the FILE option
;			- Added <p> for the GIF option
;			- Added HFILE option
;	28-May-97 (MDM) - Removed html_temp2out_s1 and replaced it with
;			  calls to strextract
;_

if n_elements(infil) eq 0 then infil = '$MDI_CAL_INFO/log_health.thtml'
if n_elements(outfil) eq 0 then outfil = '/mde0/public_html/health_mon/log_health.html'

temp = rd_tfile (infil)

ss=wc_where(temp, '<<FILE:*>>', mcount)
for a=mcount-1,0,-1 do begin
    ii = ss(a)
    tmp_nm = strtrim( strextract( temp(ii), ':', '>'), 2)
    out = ['<p><b><pre>', rd_tfile(tmp_nm), '</b></pre><p>']
    temp = [temp(0:ii-1), out, temp(ii+1:*)] 
end

ss=wc_where(temp, '<<HFILE:*>>', mcount)
for a=mcount-1,0,-1 do begin
    ii = ss(a)
    tmp_nm = strtrim( strextract( temp(ii), ':', '>'), 2)
    out = ['<p>', rd_tfile(tmp_nm), '<p>']
    temp = [temp(0:ii-1), out, temp(ii+1:*)] 
end

ss=wc_where(temp, '<<GIF:*>>', mcount)
for a=mcount-1,0,-1 do begin
    ii = ss(a)
    tmp_nm = strtrim( strextract( temp(ii), ':', '>'), 2)
    tmp_nm = '<IMG SRC="'+tmp_nm+'"><br>'
    temp = [temp(0:ii-1), '<p>', tmp_nm, '<p>', temp(ii+1:*)] 
end

ss_t=wc_where(temp, '*<<UT_time>>*', mcount)
if mcount ne 0 then begin
    ii=ss_t(0)
    test=str_sep(temp(ii), '<<UT_time>>')
    temp_t= test(0) + UT_time() + test(1)
    temp = [temp(0:ii-1), temp_t, temp(ii+1:*)]
end

file_delete, outfil
prstr, temp, file=outfil
end


