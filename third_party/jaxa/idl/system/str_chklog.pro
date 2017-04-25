;+
; Project     : VSO                                                              
;                                                                                
; Name        : STR_CHKLOG                                                         
;                                                                                
; Purpose     : Translate environment substrings separated by delimiters
;                                                                                
; Category    : utility string                                                   
;                                                                                
; Syntax      : IDL> output=str_chklog(input)                      
;                                                                                
; Inputs      : INPUT = input string (e.g. $SSW/gen/idl)                                            
;                                                                                
; Outputs     : OUTPUT = translated output (e.g. /solarsoft/gen/idl)
;                                                                                
; Keywords    : See CHKLOG
;                                                                                
; History     : 30-Oct-2013, Zarro (ADNET) - written
;-

function str_chklog,input,_extra=extra

if is_blank(input) then return,''
output=input
pieces=strsplit(input,'(\\|/)',/regex,/extract)
for i=0,n_elements(pieces)-1 do begin
 opiece=chklog(pieces[i],/preserve,/norecurse,_extra=extra)
 output=strep2(output,pieces[i],opiece,_extra=extra,/nopad)
endfor

return,output
end

