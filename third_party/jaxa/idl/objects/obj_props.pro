;+
; Project     : HESSI
;
; Name        : OBJ_PROPS
;
; Purpose     : find property names in an object
;
; Category    : utility objects
;
; Syntax      : IDL>out=obj_props(class)
;
; Inputs      : CLASS = class name or object variable name 
;
; Outputs     : OUT = string array of property names
;
; Keywords    : ERR = error string
;
; History     : Written 20 May 1999, D. Zarro, SM&A/GSFC
;               31-Dec-2015, Zarro (ADNET) - added _REF_EXTRA
;
; Contact     : dzarro@solar.stanford.edu
;-

function obj_props,obj,_ref_extra=extra

obj_dissect,obj,props=props,_extra=extra
return,props

end
