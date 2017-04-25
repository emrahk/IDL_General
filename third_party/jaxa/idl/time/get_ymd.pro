;+
; Project     : HESSI
;
; Name        : get_ymd
;
; Purpose     : return YYMMDD part from filename
;
; Category    : utility 
;
; Syntax      : IDL> get_ymd,file,ymd,hms
;
; Inputs      : FILE = string array of filenames 
;                      (e.g. kpno_fd_20010601_0111.fits)
;
; Outputs     : YMD = yymmdd string (e.g. 200110601)
;
; Opt. Outputs: HMS = hhmmss (e.g. 121204)
;
; Keywords    : FULL = include full year [def is 01 instead of 2001]
;
; History     : Written 1 Aug 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro get_ymd,file,ymd,hms,full=full

ymd='' & hms=''

if is_blank(file) then return

d=stregex(file,'_([0-9]{6,8})_?',/extract,/sub)

ymd=strtrim(reform(d[1,*]),2) 

if (1-keyword_set(full)) then begin
 len=strlen(ymd)
 chk=where(len eq 8,count)
 if count gt 0 then ymd[chk]=strmid( ymd[chk],2,1000 )
endif

if n_elements(ymd) eq 1 then ymd=ymd[0]

if n_params() eq 3 then begin
 d=stregex(file,'_([0-9]{4,6})\.',/extract,/sub)
 hms=strtrim(reform(d[1,*]),2)
 if n_elements(hms) eq 1 then hms=hms[0]
endif

return

end
