function ssw_contrib_ok2online, jobinfo, quiet=quiet
;
;+
;  
;   Name: ssw_contrib_ok2online
;
;   Purpose: boolean - true if JOBINFO passes sanity/security tests
;
;  Input Parameters:
;      JOBINFO - structure represtenting ssw_contrib job log
;                (output from ssw_contrib_info.pro)
;  
;   History:
;      21-Sep-1999 - S.L.Freeland
;-  
loud=1-keyword_set(quiet)

retval=0                                       ; Default=NO

fromid=str2arr(strtrim(gt_tagval(jobinfo, /from, missing=''),2),'@')

if n_elements(fromid) eq 2 then begin
   strtab2vect,fromid, fromuser, fromip
   retval=is_member(fromuser,'freeland,morrison') 
   box_message,'ssw_contrib_ok2online: Inline security checks only...'
endif else box_mesage,'Unexpected or missing "FROM" field in job...(???)'

if loud then box_message,'ssw_contrib_ok2line? ' + (['NO','YES'])(retval)

return,retval
end
