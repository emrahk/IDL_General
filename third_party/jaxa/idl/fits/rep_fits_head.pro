;+
; Project     : HESSI
;
; Name        : REP_FITS_HEAD
;
; Purpose     : Replace FITS header information. 
;               Equivalent programs that do this often get the
;               character spacings wrong, which upsets
;               some less tolerant FITS readers.
;
; Category    : FITS, Utility
;
; Syntax      : IDL> rep_fits_head,head,key,value
;
; Inputs      : HEAD = FITS header 
;               KEY    = key name to replace
;               VALUE  = value to replace with
;
; Outputs     : HEAD= modified header
;
; History     : Written, 3-Jan-2005, Zarro (L-3Com/GSFC)
;               
; Contact     : dzarro@solar.stanford.edu
;-

pro rep_fits_head,head,key,value

if is_blank(head) or is_blank(key) or ~exist(value) then begin
 pr_syntax,'rhead = rep_fits_head(head,key,value)'
 return
endif

chk=where(strpos(head,key) gt -1)
if chk[0] gt -1 then begin
 line=head[chk[0]]
 p1=strpos(line,'=')
 p2=strpos(line,'/')
 rem=''
 if p1 gt -1 then begin
  new_value=trim(value)
  nspace=p2-p1-strlen(new_value)-2
  if nspace gt 0 then space=string(replicate(32b,nspace)) else space=''
  new_line=strmid(line,0,p1+1)+space+new_value
  if p2 gt 0 then new_line=new_line+strmid(line,p2-1,strlen(line)) else $
   new_line=new_line+'/'
  head[chk[0]]=new_line
 endif
endif

return & end

