;+
; Project     : SOLAR-B/EIS
;                   
; Name        : EXP_ZDBASE
;               
; Purpose     : Expand ZDBASE into component directories
;               
; Category    : Catalog
;               
; Syntax      : IDL> exp_zdbase
;    
; Keywords    : VERBOSE = obvious
;
; Side effects: Environment/logical ZDBASE set to expanded directories
;               
; History     : Written, 1-August-1997,  D M Zarro
;               Modified 10-Feb-2004, Zarro (L-3Com/GSFC) - optimized
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro exp_zdbase,verbose=verbose

zdbase=chklog('ZDBASE')
if is_blank(zdbase) then return
edbase=exp_dbase(zdbase)
edbase=arr2str(edbase,delim=plim)

mklog,'ZDBASE',edbase
if keyword_set(verbose) then message,'Expanded to - '+edbase,/cont

return  & end

