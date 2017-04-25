function safe_unlog10, log10data, nosub1=nosub1
;
;+
;   Name: safe_unlog10
;
;   Purpose: ~undo the 'safe_log10' function algorithm
;
;   Input Parameters:
;       log10data - assumed output from safe_log10(data)
;  
;   Calling Sequence:
;       original=safe_unlog10(log10data)
;  
;   History:
;      25-March-1999 - S.L.Freeland
;-

retval=10.^log10data
if not keyword_set(nosub1) then $
     retval=temporary(retval)-1.         ; subtract the 1. added by safe_log10

return,retval
end
