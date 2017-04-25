;+
; Project     : HESSI     
;                   
; Name        : DB_CHECK
;               
; Purpose     : check input search string for syntax errors
;               
; Category    : Database
;               
; Syntax      : IDL> db_check,field,in_search,out_search
;
; Example     : db_check,['tstart,tend,xcen,ycen'],'xcen<1,ycen>2'
;    
; Inputs      : FIELD = valid searchable fields in database
;               IN_SEARCH = search string
;               
; Opt. Inputs : None
;               
; Outputs     : OUT_SEARCH = corrected search string
;
; Opt. Outputs: None
;               
; Keywords    : STATUS = 1 if corrected string is ok, 0 otherwise
;               SYNTAX = 1 if syntax error found
;               (STATUS can be 0 even if SYNTAX=0. This can occur
;               if input string does not contain at least one valid
;               searchable field name).
;
; Restrictions: None
;               
; Side effects: None.
;               
; History     : Version 1,  13-May-1999,  D M Zarro (SM&A/GSFC)  Written
;     
; Contact     : dzarro@solar.stanford.edu
;-


pro db_check,fields,in_search,out_search,status=status,syntax=syntax

out_search=''
status=0 & syntax=0

if (datatype(fields) ne 'STR') or (datatype(in_search) ne 'STR') then begin
 pr_syntax,'db_check,fields,search'
 return
endif

if trim(in_search) eq '' then begin
 status=1 & syntax=1 & return
endif
temp=trim(str2arr(strupcase(strcompress(in_search))))

nitems=n_elements(temp)
nfields=n_elements(fields)

;-- now do validation

delim=['=','<','>']

ndelim=n_elements(delim)
valid_tag=bytarr(nitems)
bad_input=bytarr(nitems)
for i=0,nitems-1 do begin
 tsplit=str2arr(temp(i),'=')
 if n_elements(tsplit) eq 1 then tsplit=str2arr(temp(i),'<')
 if n_elements(tsplit) eq 1 then tsplit=str2arr(temp(i),'>')
 tsplit=trim(tsplit)
 ok=where_vector(tsplit,fields,tcount)

;-- check for sensible fields

 if tcount eq 1 then begin
  if n_elements(tsplit) eq 1 then bad_input(i)=1
  if n_elements(tsplit) eq 2 then begin
   if (tsplit(0) ne fields(ok(0))) or (tsplit(1) eq '') then bad_input(i)=1
  endif
  if n_elements(tsplit) eq 3 then begin
   if (tsplit(1) ne fields(ok(0))) or (tsplit(0) eq '') or $
      (tsplit(2) eq '') or (strpos(temp(i),'>') gt -1) then bad_input(i)=1
  endif
 endif
 if (tcount eq 1) and (not bad_input(i)) then begin
  valid_tag(i)=1
  if exist(done) then chk=where(ok(0) eq done,dcount) else dcount=0
  if dcount eq 0 then begin
   if exist(valid) then valid=[valid,temp(i)] else valid=temp(i)
   if exist(done) then done=[done,ok(0)] else done=ok(0)
  endif
 endif else begin
  if keyword_set(exper) then afields=main_fields else afields=exper_fields
  acheck=where_vector(tsplit,afields,acount)
  if (acount gt 0) then valid_tag(i)=1
 endelse
endfor

if exist(valid) then out_search=arr2str(valid)

if max(valid_tag) eq 1 then status=1
if max(bad_input) eq 1 then syntax=1

dprint,'out_search: ',out_search

return & end

