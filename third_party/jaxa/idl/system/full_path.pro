;+
; Project     : VSO
;
; Name        : full_path
;
; Purpose     : Ensure file name has full path name
;
; Category    : utility string
;
; Syntax      : IDL> dfile=full_path(file)
;
; Inputs      : FILE = file name
;
; Outputs     : DFILE  = file name with full path 
;
; Keywords    : None
;
; History     : 4-Dec-2009, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                                                                                                        
function full_path,file
                                                                            
if is_blank(file) then return,''                                            
dpath=file_break(file,/path)
if is_string(dpath) then return,file else return,concat_dir(curdir(),file)

end
