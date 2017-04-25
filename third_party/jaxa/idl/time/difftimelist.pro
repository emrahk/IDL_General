pro difftimelist, timein1, cutoff,SECONDS=seconds,MINUTES=minutes,HOURS=hours,DAYS=days, _EXTRA=extra
;$Id: difftimelist.pro,v 1.1 2006/08/23 18:44:53 nathan Exp $
;
; Compute intervals between consecutive times in input and generate report.
;
; Inputs: 
;   timein1 STRARR  times in string format, or STCARR CDS format, or DBLARR Tai format
;   cutoff  INT     Time between input times for which a line in the report will be generated
;   	    	    Default unit is seconds.
;
; Keywords:
;   /SECONDS	cutoff is in seconds (default)
;   /MINUTES	cutoff is in minutes
;   /HOURS  	cutoff is in hours
;   /DAYS   	cutoff is in days
;   any keywords for anytim2utc.pro are allowed
;
; Constraint: if input is DOY, then character after day number MUST be "t"
;
; Category    : utility, time, string, packets, report
;               
; $Log: difftimelist.pro,v $
; Revision 1.1  2006/08/23 18:44:53  nathan
; moved from ../util
;
; Revision 1.1  2006/05/01 18:30:54  nathan
; For 1 column of times
;

IF datatype(timein1) EQ 'DOU' THEN tai=timein1 ELSE BEGIN
    print,'Converting input to TAI...'
    tai=utc2tai(anytim2utc(timein1,_EXTRA=extra))
ENDELSE
diffsec=tai-shift(tai,1)

case 1 of 
    keyword_set(MINUTES): BEGIN  
    	cutsec=cutoff*60.
	label=' Gap(Min.)'
	conv=60.
	end
    keyword_set(HOURS): BEGIN  
    	cutsec=cutoff*3600.
	label='Gap(hours)'
	conv=3600.
	end
    keyword_set(DAYS): BEGIN  
    	cutsec=cutoff*86400.
	label=' Gap(Days)'
	conv=86400.
	end
    else: BEGIN
    	cutsec=cutoff
	label=' Gap(Sec.)'
	conv=1.
	end
endcase

found=where(diffsec GE cutsec,nf)

openw,lun,'difftimereport.txt',/get_lun

printf,lun,'Time                '+label
;   	    02/18/06 00:08:05
for i=0,nf-1 do begin
    printf,lun,timein1[found[i]]+string(diffsec[found[i]]/conv,format='(f13.2)') 
endfor
close,lun
free_lun,lun

stop
end
