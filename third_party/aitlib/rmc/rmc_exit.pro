PRO RMC_EXIT,event
;+
; NAME:  rmc_exit
;
;
;
; PURPOSE: closes all windows, which were opened by the main program
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: rmc_exit  (It is called in a menu)
;
;
;
; INPUTS: 
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:  clear all pointers (calling rmc_cleanup) and close the program
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:  
; $Log: rmc_exit.pro,v $
; Revision 1.3  2002/05/17 09:24:30  slawo
; *** empty log message ***
;
; Revision 1.2  2002/05/17 09:23:14  slawo
; Added documentation
;
;
;-
   
   ;; Exits the widgets and closing all windows
   rmc_cleanup,event.top
   widget_control,event.top, /destroy
END 

