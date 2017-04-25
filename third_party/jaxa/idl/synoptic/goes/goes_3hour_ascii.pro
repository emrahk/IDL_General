;+
;
; NAME:
;	GOES_3HOUR_ASCII
;
; PURPOSE:
;	Read the GOES 3-hour ASCII files copied from SEL and return the
;	header record, and the data records.
;
; CATEGORY:
;	GOES
;
; CALLING SEQUENCE:
;       GOES_3HOUR_ASCII, File, Header, Data
;
; CALLS:
;       IEEE_TO_HOST
;
; INPUTS:
;       File:	GOES 3-hour file.
;
; OUTPUTS:
;       Header:	Array containing year, day of the year and satellite number.
;	Data:   Array containing time in sec from start of observation day
;		in 2-3 sec interval, ?, ?, flux (watts/m^2) for range 
;		1. - 8. angstroms, and flux (watts/m^2) for range 
;		.5 - 4. angstroms. Flux value of -99999.0 means no data.
;
; PROCEDURE:
;       Read data from goes_3hour file, perform a longword swap using
;	'byteorder', convert data array from IEEE to host representation,
;	and return header and remaining data arrays.
;
; MODIFICATION HISTORY:
;	Kim Tolbert 7/93
;       Mod. 08/07/96 by RCJ. Use IEEE_TO_HOST instead of CONV_UNIX_VAX.
;	Mod. 02/02/05 by AES. SEL changed format to ASCII.  Completely
;		change how we read it.
;	Kim Tolbert, 4-Dec-2009. GOES14 has 2-sec resolution, not 3, so increase max
;	 array size.  Also, there are only 4 columns, not 6 - the second and third 
;	 (starting from 1) are missing because there's no status day, so insert two
;	 zeroes in those columns.
;-
pro goes_3hour_ascii, file, header, data

;openr, lun, file, /get_lun

;fstat = fstat(lun)
;nrec = fstat.size / 20

;data = fltarr(5, nrec)
indata = rd_ascii(file,lines=[1,6000])  ; increased from 3700 for GOES14
;help,indata
; Theoretically there should only be 3600 lines.  Read higher just in case.
; rd_ascii will only return what's there.
; convert to our format below.

asciidates=strmid(indata,0,10)
asciitimes=strmid(indata,11,8)
daystart='00:00:00 '+asciidates[0]
daystart=anytim(daystart,out_sty='sec')
sod=anytim(asciitimes[*]+' '+asciidates[*],out_sty='sec') -daystart 
;sod = seconds of day from 00:00 the day of observation

; get header info from filename
;print,file
;print,strmid(file,1,2)

parts=strsplit(file,'/',/extract)
file=parts(n_elements(parts)-1)
satellite=float(strmid(file,1,2))
year=strmid(file,8,4)
year2=strmid(year,2,2)
month=strmid(file,13,2)
day=strmid(file,16,2)

date=year2+month+day
date2doy,date,doy
doy=float(doy)
year=float(year)
header=[year,doy,satellite,-99999.0,-99999.0]

;help,indata
;data = data(*,1:*)
indata=strcompress(indata)
help,indata
extracted=strarr(6,n_elements(indata))
help,extracted
extracted[4:5,*]="-99999.0"
for i=0,(n_elements(indata)-1) do begin
;	print,i
;	help,indata[i]
	;extracted[*,i]=float(strsplit(indata[i],' ',/extract,/count))
	result=float(strsplit(indata[i],' ',/extract,count=count))
	; GOES14 is missing the status columns, so fill in with two zeros.
	if count eq 4 then begin
	  count=6
	  result = [result[0:1], 0., 0., result[2:3]]
	endif
	extracted[0:count-1,i]=result
endfor
;
;format for data:  sod, stat_wd1,stat_wd2,x_short,x_long
; 
;stat_wd1=extracted[2,*]
;stat_wd2=extracted[3,*]
;x_long=extracted[4,*]	
;x_short=extracted[5,*]
data=fltarr(5,n_elements(indata))
data[0,*]=sod
data[1,*]=extracted[2,*]
data[2,*]=extracted[3,*]
data[3,*]=extracted[5,*]
data[4,*]=extracted[4,*]
return & end
