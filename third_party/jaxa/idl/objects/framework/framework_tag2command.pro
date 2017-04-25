;---------------------------------------------------------------------------
; Document name: framework_tag2command.pro
; Created by:    Andre_Csillaghy, October 30, 2002
;
; Last Modified: Wed Oct 30 13:00:21 2002 (csillag@hercules)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       FRAMEWORK_TAG2COMMAND()
;
; PURPOSE: 
;       
;
; CATEGORY:
;       
; 
; CALLING SEQUENCE: 
;       result = framework_tag2command()
;
; INPUTS:
;       
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURE:
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLES:
;       
;
; SEE ALSO:
;
; HISTORY:
;       Version 1, October 30, 2002, 
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;

FUNCTION framework_tag2command, struct

ntags = N_Tags( struct ) 
tn = Tag_Names( struct )
new_command = Strarr( ntags )
FOR i=0, ntags-1 DO BEGIN
    tval = Val2string( struct.(i) )
    new_command[i] = 'o->set, ' + tn[i] + '=' + tval 
ENDFOR 

return, new_command

END


;---------------------------------------------------------------------------
; End of 'framework_tag2command.pro'.
;---------------------------------------------------------------------------
