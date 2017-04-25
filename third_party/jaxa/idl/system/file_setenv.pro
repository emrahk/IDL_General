;+
; Project     : RHESSI
;
; Name        : FILE_SETENV
;
; Purpose     : Read file containing SETENV commands and set 
;               environment within IDL
;
; Category    : system utility 
;
; Inputs      : FILE = ascii file with entries like: setenv AAA BBB
;
; Outputs     : Environment variables: $AAA=BBB
;
; Keywords    : None
;
; History     : 21-Feb-2010, Zarro (ADNET) - Written
;               6-Feb-2016, Zarro (ADNET) - added check for commented commands
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro file_setenv,file,verbose=verbose,_extra=extra

verbose=keyword_set(verbose)
if is_blank(file) then return
dfile=local_name(file)
chk=file_test(dfile,/read)
if ~chk then begin
 mprint,'Input environment definition file not found.'
 return
endif

a=strcompress(rd_ascii(dfile))
d=stregex(a,'(.*)(setenv) +([^ ]+) +([^ ]+)',/extract,/sub,/fold)
ok=where( (strlowcase(d[2,*]) eq 'setenv') and (strtrim(d[1,*],2) eq ''),count)
if count eq 0 then begin
 mprint,'No SETENV commands found.'
 return
endif


d=d[*,ok]
for i=0,count-1 do begin
 if verbose then message,'Setting '+d[3,i]+' to '+d[4,i],/cont
 mklog,d[3,i],d[4,i],/local
endfor
return & end
