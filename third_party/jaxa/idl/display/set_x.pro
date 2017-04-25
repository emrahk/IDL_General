;+
; Project     : SDAC  
;                   
; Name        : SET_X   
;               
; Purpose     : Set the device to 'X' with vector fonts.
;               
; Category    : graphics
;               
; Explanation : Uses "set_plot"
;               
; Use         : SET_X
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: !p.font set to -1
;               
; Prev. Hist  : 
;
; Mod.        :
;       version 1, richard.schwartz@gsfc.nasa.gov 2-Mar-1996
;	version 2, amy@aloha.nascom.nasa.gov 5-Mar-1998
;		changed setplot,'x' to set_plot,'x'
;-            
;======================================================================
pro set_x

on_error,2

if not have_windows() then case os_family() of
	'Windows': set_plot,'win'
	'MacOS':   set_plot,'mac'
	else: set_plot,'x'
endcase

!p.font=-1

end
