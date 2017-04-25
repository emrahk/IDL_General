pro difftimes, timein1, timein2, filename=filename, local=local
;$Id: difftimes.pro,v 1.1 2006/08/23 18:44:54 nathan Exp $
;
; Print time difference between 2 time strings and format output
;
; Inputs: 2 time strings or set FILENAME=file with comma-delimited time strings
;
; Keywords:
;   LOCAL   If set, assume ground time (2nd column) is local time not UTC
;
; Constraint: if DOY, then character after day number MUST be "t"
;
; Category    : utility, time, string
;               
; $Log: difftimes.pro,v $
; Revision 1.1  2006/08/23 18:44:54  nathan
; moved from ../util
;
; Revision 1.2  2006/04/14 20:28:47  nathan
; handle local ground times
;
; Revision 1.1  2006/04/05 19:42:02  nathan
; for generating reports for preflight data time correlation
;

if keyword_set(filename) THEN BEGIN
    inp=readlist(filename)
    nin=n_elements(inp)
    if strmid(inp[0],0,1) NE '0' then BEGIN
    	parts=str_sep(inp[0],',')
    	inp=inp[1:nin-1]
    endif
    openw,1,filename+'.0'
    ;         2006-10-30T07:49:47.176
    printf,1,string(parts[0],format='(a23)')+'   '+string(parts[1],format='(a23)')+'  seconds diff'
endif ELSE BEGIN
    inp=timein1+','+timein2
endelse
nin=n_elements(inp)

for i=0,nin-1 do begin
    parts=str_sep(inp[i],',')
    time1=strtrim(parts[0],2)
    time2=strtrim(parts[1],2)
    strput,time1,'T',6
    strput,time2,'T',6
    tai1=anytim2tai(time1)
    tai2=anytim2tai(time2)
    IF keyword_set(LOCAL) THEN $
    	IF tai2 LT anytim2tai('2005-10-29t22:00:00') THEN tai2=tai2+4*3600 $
	ELSE IF tai2 LT anytim2tai('2006-04-01t22:00:00') THEN tai2=tai2+5*3600 $
	ELSE tai2=tai2+4*3600
    tdiff=tai2-tai1
    yy =fix (tdiff/(86400*365.25))
    dd =fix ( (tdiff )/86400. )
    hh =fix ( (tdiff - dd*86400. )/3600. )
    mm =fix ( (tdiff - dd*86400. -hh*3600. )/60. )
    ss =       tdiff - dd*86400. -hh *3600. -mm*60. 

    print,	utc2str(tai2utc(tai1),/date)+'   '+ $
      	    	utc2str(tai2utc(tai2),/date)+ $
        	'  +',string(hh,format="(i2.2)")+':'+ $
		      string(mm,format="(i2.2)")+':'+ $
		      string(ss,format="(i2.2)"),tdiff
    help,yy,dd,hh,mm,ss
    IF keyword_set(filename) THEN $
    printf,1,	utc2str(tai2utc(tai1))+'   '+ $
      	    	utc2str(tai2utc(tai2))+string(tdiff)
endfor    
    
    
close,1  
end
