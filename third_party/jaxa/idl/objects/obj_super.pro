;+
; Project     : HESSI
;
; Name        : OBJ_SUPER
;
; Purpose     : Execute a method of a super class
;
; Category    : utility objects
;
; Syntax      : IDL>obj_super,obj,method
;
; Inputs      : OBJ = object reference
;               METHOD = string method name [def=procedure]
;
; Keywords    : FUNCTION = method is a function
;               EXTRA = keywords to pass to method
;               RESULT = returned result if function
;
; History     : Written 10 April 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro obj_super,obj,method,_extra=extra,function_type=function_type,$
                 result=result

if size(method,/tname) ne 'STRING' then return
if size(obj,/tname) ne 'OBJREF' then return
if not obj_valid(obj) then return
super=obj_class(obj,/super,count=count)
if count eq 0 then return

;-- catch errors in case method doesn't exist

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return
endif

super=super[0]+'::'+method
if keyword_set(function_type) then $
 result=call_method(super,obj,_extra=extra) else $
  call_method,super,obj,_extra=extra

catch,/cancel
return & end

