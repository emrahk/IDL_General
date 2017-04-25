;+
; Project     : HESSI
;                  
; Name        : GOES_TEMP_DIR
;               
; Purpose     : return name of temporary directory for caching of local GOES data
;                             
; Category    : synoptic utility
;               
; Syntax      : IDL> dir=goes_temp_dir()
;                                        
; Outputs     : dir= directory name
;                   
; History     : 15 Apr 2002, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function goes_temp_dir

if test_dir('$GOES_DATA_USER',out=out,/quiet) then return,out
return,concat_dir(get_temp_dir(),'goes')

end

