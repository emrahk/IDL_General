;+
; Project     : HESSI
;                  
; Name        : ALLOW_GIF
;               
; Purpose     : platform/OS independent check if current system
;               supports writing GIF files
;                             
; Category    : system utility
;               
; Syntax      : IDL> a=allow_gif()
;                                        
; Outputs     : 1/0 if yes/no
;                   
; History     : 7 Apr 2003, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function allow_gif,err=err

common allow_gif,gif_state,err_state

if exist(gif_state) then begin
 err=err_state
 return,gif_state
endif

dsave=!d.name
err=''
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err='GIF unsupported on current system' 
 if is_open(temp_file,unit=lun) then close_lun,lun
 file_delete,temp_file,/quiet
 set_plot,dsave
 gif_state=0b
 err_state=err
 return,gif_state
endif

set_plot,'Z'
temp_file=mk_temp_file('test.gif',/random,direc=get_temp_dir())
write_gif,temp_file,bindgen(2,2)
file_delete,temp_file,/quiet
set_plot,dsave
gif_state=1
err_state=''
return,gif_state

end
