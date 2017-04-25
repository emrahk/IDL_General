;+
; Project     : HESSI
;                  
; Name        : SSW_LAST_UPDATE
;               
; Purpose     : spit out time of last SSW mirror update by checking date
;               of $SSW/gen/setup/ssw_info_map.dat
;                             
; Category    : utility
;               
; Syntax      : IDL> last_ssw_update
;
; Inputs      : None
; 
; Outputs     : time of last update printed to screen
;
; Keywords    : VERSION - set to show IDL version
;                                   
; History     : Written, 19-April-2004, Zarro (L-3Com/GSFC)
;               Modified, 16-Sept-2014, Zarro (ADNET)
;               - add check for personal IDL Startup
;               Modified, 6-Mar-2015, Zarro (ADNET)
;               - convert UTC to local time
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro ssw_last_update,version=version

if keyword_set(version) then help,/st,!version

;-- find latest SSW map file

map_file=local_name('$SSW/gen/setup/ssw_info_map.dat')
chk=loc_file(map_file,count=count)
if count eq 0 then begin
 message,'Non-standard SSW installation',/info
 return
endif

openr,lun,chk[0],/get_lun
head=strarr(10)
readf,lun,head
close_lun,lun

;-- time of last update

str='.*UT +Time +\:(.+)\|'
chk=strtrim(stregex(head,str,/ext,/sub,/fold),2)

find=where(chk[1,*] ne '',count)
if count eq 0 then begin
 message,'Non-standard SSW installation',/info
 return
endif

utime=chk[1,find[0]]
ltime=anytim(anytim(utime)+ut_diff(/sec),/vms,/trunc)


;print,''
;message,'Personal IDL_STARTUP file - '+getenv('ssw_pers_startup'),/info
;print,''

mprint,ltime+' '+'local time.'
return
end


