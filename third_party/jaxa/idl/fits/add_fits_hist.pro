;+
; Project     : HESSI
;
; Name        : ADD_FITS_HIST
;
; Purpose     : Add string to FITS HISTORY
;
; Category    : FITS, Utility
;
; Syntax      : IDL> nheader=add_fits_hist(header,value)
;
; Inputs      : HEADER = FITS header (string or index structure
;                         format)
;               VALUE = string to add
;
; Outputs     : NHEADER = updated header
;
; History     : Written, 23-April-2009 (Zarro/ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-


function add_fits_hist,header,value

if (~is_string(header,/blank) and ~is_struct(header)) or is_blank(value) then begin
 pr_syntax,'head=update_header(header,value)'
 if exist(header) then return,header else return,''
endif

output=header & value=strtrim(value,2)
if have_fits_hist(output,value) then return,output

;-- handle structure case

if is_struct(output) then begin
 if ~have_tag(output,'history') then return,add_tag(output,value,'history')
 history=output.history
 history=[history,value]
 return,rep_tag_value(output,history,'history')
endif

;-- handle string case

if is_string(output,/blank) then begin
 tval='HISTORY '+value
 chk=where(stregex(output,'History .+',/bool,/fold),count)
 if count eq 0 then return,[output,tval]
 nout=n_elements(output)
 clast=chk[count-1]
 if clast eq (nout-1) or (clast eq 0) then noutput=[output,tval] else $
  noutput=[output[0:clast],tval,output[clast+1:nout-1]]
 return,noutput
endif

end
