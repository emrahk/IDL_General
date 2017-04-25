;+
; Project     : SOLAR-B/EIS
;                   
; Name        : EXP_DBASE
;               
; Purpose     : Expand DBASE into component directories
;               
; Category    : Catalog
;               
; Syntax      : IDL> out=exp_dbase(input)
;
; Input       : Delimited database directories
;
; History     : Written 7-May-2004, Zarro (L-3Com/GSFC)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function exp_dbase,input

if is_blank(input) then return,''
chk=strpos(input,'+')
plim=get_path_delim()
comp=str2arr(input,delim=plim)
for i=0,n_elements(comp)-1 do begin
 p=comp[i]
 pos=strpos(p,'+')
 if pos gt -1 then begin
  p=strmid(p,pos+1,strlen(p))
  p='+'+local_name(p)
  pdir=expand_path(p,/all,/arr)
 endif else pdir=local_name(p)
 if is_string(pdir) then begin
  if not exist(edir) then edir=pdir else begin
   for k=0,n_elements(pdir)-1 do begin
    chk=where(pdir[k] eq edir,count)
    if count eq 0 then edir=[edir,pdir[k]]
   endfor
  endelse
 endif
endfor
return,arr2str(edir,delim=plim)
end

