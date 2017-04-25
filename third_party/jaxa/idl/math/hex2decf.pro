function hex2decf, hexstr
;+
; $Id: hex2decf.pro,v 1.1 2005/04/21 19:26:16 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : hex2decf
;               
; Purpose   : return decimal integer from hex string
;               
; Explanation: 
;               
; Use       : IDL> 
;    
; Inputs    :   

; Optional Inputs: 
;               
; Outputs   : 

; Optional Outputs: 
;
; Keywords  :   

; Calls from LASCO : 
;
; Common    : 
;               
; Restrictions: 
;               
; Side effects: 
;               
; Category    : 
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/I2, Apr 05
;               
; $Log: hex2decf.pro,v $
; Revision 1.1  2005/04/21 19:26:16  nathan
; no comment
;
;-            

hex2dec, hexstr,number,/quiet
return, number

end
