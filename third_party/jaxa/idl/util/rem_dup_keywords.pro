;+
; Project     : VSO
;
; Name        : REM_DUP_KEYWORDS
;
; Purpose     : remove duplicate keywords from EXTRA
;
; Category    : utility 
;
; Syntax      : IDL> output=rem_dup_keywords(extra)
;
; Inputs      : EXTRA = keyword extra in structure or string format
;
; Outputs     : NEXTRA = duplicate keywords removed - one with largest
;                       string length is favored.
;
; Keywords    : None
;
; History     : 25-Feb-2013 Zarro (ADNET) - written.
;-

function rem_dup_keywords,extra

if ~is_string(extra) and ~is_struct(extra) then return,extra

if is_struct(extra) then textra=tag_names(extra) else textra=extra
np=n_elements(textra)
if np eq 1 then return,extra

;-- cycle thru each keyword. If it matches the start of another
;   keyword in the list, then remove the shortest one.

for i=0,np-1 do begin
 chk=where(stregex(textra,'^'+textra[i],/bool,/fold),count)
 if (count gt 1) then begin
  matches=textra[chk]
  lens=strlen(matches)
  chk=where(lens eq min(lens))
  rem=matches[chk[0]]
  dup=where(rem eq textra)
  textra[dup[0]]=''
 endif
endfor

ok=where(textra ne '',count)
if count gt 0 then textra=textra[ok]
if count eq 1 then textra=textra[0]
if count eq 0 then textra=''

;-- return structure if it was input

rem=-1
if is_struct(extra) then begin
 tags=tag_names(extra) & ntags=n_elements(tags)
 for i=0,ntags-1 do begin
  chk1=where(tags[i] eq textra,count)
  if count eq 0 then rem=[rem,i]
 endfor
 chk2=where(rem gt -1,rcount)
 if rcount gt 0 then textra=rem_tag(extra,rem[chk2]) else textra=extra
endif
 
return,textra

end
