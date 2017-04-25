;+
; Project     : VSO                                                              
;                                                                                
; Name        : CURPROG                       
;                                                                                
; Purpose     : Return name of current program (procedure/function/method).
;                                                                                
; Category    : utility system                                                   
;                                                                                
; Syntax      : IDL> output=curprog()                      
;                                                                                
; Inputs      : None
;                                                                                
; Outputs     : OUTPUT = name of current program. 
;                       (returns $MAIN$ if called from main level)
;                                                                                
; Keywords    : PATH = return name with full path.
;               CALLER = return name of program that called current program.
;                                                                                
; History     : 25-Jan-2014, Zarro (ADNET) - written
;-

function curprog,path=path,caller=caller

r=scope_traceback(/struct,/system)
np=n_elements(r)

ncurr=keyword_set(caller) ? (np-3) > 0 : (np-2) > 0
output=keyword_set(path) ? (r[ncurr]).filename : (r[ncurr]).routine

if is_blank(output) then output='MAIN'
return,output
end
