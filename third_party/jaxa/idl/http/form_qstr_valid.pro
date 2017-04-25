pro form_qstr_valid, qstr, vfields, values, count, confarr=confarr, $
		     gtarr=gtarr, $
		     merge_list=merge_list, range_list=range_list
;
;   Name:  form_qstr_valid
;  
;   Purpose: return array of "valid" search fields (filter out NOPS, etc)
;
;   History:
;      Circa Nov 1997 - S.L.Freeland - clean up a post query structure
;      17-May-1998 - S.L.Freeland - add MERGE_LIST and RANGE_LIST keywords
;  
fields=tag_names(qstr)
; ------ remove standard times from consideration ----------
ssok=where(strpos(fields,'STOP_') eq -1 and strpos(fields,'START_') eq -1)
fields=fields(ssok)
;
;  ---------- ignore fields used within WWW -----------
ignore=strupcase(str2arr('SEARCH,TEST_MODE'))
fields=fields(rem_elem(fields,ignore))

; ---------- handle MERGE_LIST (radio buttons...) -------------
for i=0,n_elements(merge_list)-1 do begin
  umerge=strupcase(merge_list(i))+'_'
  ss=where(strpos(fields,umerge) eq 0,umcnt)
  if umcnt gt 0 then begin
    qstr=add_tag(qstr,arr2str(str_replace(fields(ss),umerge,'')),$
		 merge_list(i))     
    qstr=rem_tag(qstr,fields(ss))
    fields=[fields(rem_elem(fields,fields(ss))),merge_list(i)]
  endif 
endfor  
; ------------------------------------------------------

; ------------ handle RANGE_LIST  VAL=VAL+/-DELTAT ---------------
; assume each member in form "value,delta", for example 
drange=''
for i=0, n_elements(range_list)-1 do begin
   ll=strupcase(strtrim(str2arr(range_list(i)),2))
   if n_elements(ll) eq 2 then begin
      drange=[drange,ll(1)]               ; tags to remove
      gtval=gt_tagval(qstr,ll(0),missing='????')
      gtdelt=gt_tagval(qstr,ll(1),missing='????')
      if is_number(gtval) and is_number(gtdelt) then begin
         box_message,'generating range for: ' + ll(0)
         vind=tag_index(qstr,ll(0))
         range=[float(gtval)-float(gtdelt),float(gtval)+float(gtdelt)]
	 newval=arr2str(strtrim(range,2),' ~ ')
         qstr.(vind)=newval
     endif
   endif
endfor  

if n_elements(drange) gt 1 then begin
   cleanf=drange(1:*)
   cleanf=cleanf(uniq(cleanf,sort(cleanf)))
   qstr=rem_tag(qstr,cleanf)
   fields=fields(rem_elem(fields,cleanf))
endif

nf=n_elements(fields)
tind=tag_index(qstr,fields)

vfields=''                                           ; initiale output
values=''
for i=0,nf-1 do begin
   val=strtrim(qstr.(tind(i)),2)                     ; blanks->nulls
   if strupcase(val) eq 'ALL' then val=''           ; force NOP for 'ALL'
   if strupcase(val) eq 'ON' then val='1'           ; boolean flags

   if val ne '' then begin
       vfields=[vfields,fields(i)]
       values=[values,val]
   endif
endfor

notnull=where(vfields ne '',count)

if count gt 0 then  begin
  vfields=vfields(notnull)
  values=values(notnull)
  for i=0,count-1 do begin
     first=strmid(values(i),0,1)
       if not is_member(first,str2arr('=,<,>') ) then $
		     values(i) = '='+values(i)
  endfor 
  confarr=vfields+values
  gtarr=strarr(n_elements(confarr))
  for i=0,count-1 do gtarr(i)=gt2exe(confarr(i),/noss)
endif

box_message,'form_qstr_valid'

return
end
