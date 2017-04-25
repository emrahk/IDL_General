;+
; Project     : SOHO-CDS
;
; Name        : GET_SSWDB
;
; Purpose     : figure out path to SSWDB from 
;               $SSW/site/setup/setup.ssw_paths
;
; Category    : Utility
;
; Syntax      : sswdb=get_sswdb()
;
; Inputs      : None
;
; Outputs     : SSWDB = directory corresponding to SSWDB (e.g. /sdb)
;
; History     : Written 1 Dec 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_sswdb

sswdb=''
chk=loc_file('$SSW/site/setup/setup.ssw_paths',count=count)
if count eq 0 then return,''
text=strcompress(rd_ascii(chk(0)))
def='setenv SSWDB'
chk=where(strpos(text,def) gt -1,count)
if count eq 0 then return,''
text=text(chk(0))
rest=str_replace(text,def,'')
dirs=trim(str2arr(rest,delim=','))
for i=0,n_elements(dirs)-1 do if is_dir(dirs(i)) then return,dirs(i)
return,''
end
