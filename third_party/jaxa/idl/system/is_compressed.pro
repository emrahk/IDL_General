;+
; Project     : HESSI
;
; Name        : IS_COMPRESSED
;
; Purpose     : returns true if file has .Z or .gz ext
;
; Category    : utility I/O
;
; Syntax      : IDL> chk=is_compressed(file)
;
; Inputs      : FILE = input filename(s)
;
; Outputs     : 1/0 if compressed or not
; 
; Optional Outputs: TYPE = 'gz' or 'Z' or '.zip'
;
; History     : Written 2 July 2000, D. Zarro, EIT/GSFC
;               26-Aug-2010, Zarro (ADNET) - added .zip support
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_compressed,file,type

type=''
if is_blank(file) then return,0b

nfiles=n_elements(file)
compressed=bytarr(nfiles)
type=strarr(nfiles)
type=stregex(file,'\.(zip|gz|Z)$',/ext,/sub)
type=type[1,*]
chk=where(type ne '',count)
if count gt 0 then compressed[chk]=1b

if nfiles eq 1 then begin
 compressed=compressed[0]
 type=type[0]
endif

return,compressed

end
