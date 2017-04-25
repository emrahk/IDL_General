;+
; Project     : HESSI
;
; Name        : OBJ_METHODS
;
; Purpose     : find methods in an object
;
; Category    : utility objects
;
; Explanation : checks CLASS__DEFINE procedure 
;
; Syntax      : IDL> out=obj_methods(class)
;
; Inputs      : CLASS = class name or object variable name 
;
; Outputs     : OUT = string array of method calls
;
; Keywords    : ERR = error string
;
; History     : Written 20 May 1999, D. Zarro, SM&A/GSFC
;               31-Dec-2015, Zarro (ADNET) - added _REF_EXTRA
;
; Contact     : dzarro@solar.stanford.edu
;-

function obj_methods,obj,_ref_extra=extra

obj_dissect,obj,err=err,methods=methods,_extra=extra
return,methods

end
