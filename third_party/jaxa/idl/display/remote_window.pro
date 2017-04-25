;+
; Project     : HESSI
;                  
; Name        : REMOTE_WINDOW
;               
; Purpose     : Check if remote window can be opened
;                             
; Category    : system utility
;               
; Syntax      : IDL> a=remote_window()
;                                        
; Outputs     : 1/0 if yes/no
;                   
; History     : 18-Feb-2012, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-    

function remote_window,verbose=verbose,err=err

common remote_window,last
err=''
if os_family(/lower) eq 'windows' then return,1b

if n_elements(last) ne 0 then if last then return,last

spawn,['xinput','version'],result,err,/noshell
err=err[0]
result=err eq ''
if keyword_set(verbose) then if ~result then message,err,/info
if result then last=result

return,result

end
