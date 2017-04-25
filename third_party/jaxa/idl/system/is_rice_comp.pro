;+
; Project     : STEREO
;
; Name        : IS_RICE_COMP
;
; Purpose     : Check if a RICE-compressed file
;
; Category    : system utility 
;
; Syntax      : IDL> chk=is_rice_comp(file)
;
; Inputs      : FILE = input file to check
;
; Outputs     : CHK = 1 or 0
;
; Keywords    : ERR= error string
;
; History     : 9-Apr-2012, Zarro (ADNET) - written
;               23-Dec-2014, Zarro (ADNET)
;                -added more error checking
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                                         
function is_rice_comp,file,_ref_extra=extra,err=err,verbose=verbose

case 1 of
 is_blank(file): err='Missing or invalid input file.'
 n_elements(file) gt 1: err='Input file must be scalar.'
 ~file_test(file,/read): err='Cannot locate input file.'
 else: err=''
endcase

if is_string(err) then begin
 message,err,/info
 return,0b
endif

;-- search extension header for RICE compression keyword 

i=0
repeat begin
 terr=''
 mrd_head,file,header,ext=i,err=terr,_extra=extra,/no_check
 if is_blank(terr) then begin
  chk=where(stregex(header,'cmp.+rice.+compression',/bool,/fold),count)
  if count ne 0 then return,1b
  i=i+1
 endif
endrep until is_string(terr)

;if keyword_set(verbose) then message,'Input file is not RICE-compressed.',/info
return,0b
end
