;+
; Project     : HINODE/EIS
;
; Name        : OBJ_STRUCT
;
; Purpose     : extract structure definition associated with an object class
;
; Category    : utility objects
;
; Syntax      : IDL> struct=obj_struct(obj)
;
; Inputs      : OBJ = class name or object variable name 
;
; Outputs     : STRUCT = structure definition associated with class/object
;
; Keywords    : ERR = error message
;
; History     : Written 1 Nov 2006, D. Zarro (ADNET/GSFC)
;               31-Dec-2015, Zarro (ADNET) - improved error handling
;      
; Contact     : dzarro@solar.stanford.edu
;-

function obj_struct,class,err=err

err=''
struct=''

;-- error check

obj_in=(obj_valid(class))[0]
class_in=is_string(class)

if ~obj_in && ~class_in then begin
 err='Input argument must be a valid class name or object reference'
 return,''
endif

error=0
catch,error
if error ne 0 then begin
 err=err_state()
; message,err,/cont
 err='Invalid class name - '+cname
 catch,/cancel
 return,''
endif

;-- avoid execute if IDL > 6.0

if obj_in then cname=obj_class(class) else cname=strtrim(class,2)

if since_version('6.1') then begin
 if obj_in then $
  struct=call_function('create_struct',name=cname) else $
   struct=call_function('create_struct',name=cname)
endif else begin
 expr='struct={'+cname+'}'
 s=execute(expr)
 if s eq 0 then err=err_state()
endelse

return,struct & end 
 
