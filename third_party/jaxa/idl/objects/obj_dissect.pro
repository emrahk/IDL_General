;+
; Project     : HESSI
;
; Name        : OBJ_DISSECT
;
; Purpose     : find methods & properties of an object or class
;
; Category    : utility objects
;
; Explanation : checks CLASS name and CLASS__DEFINE procedure 
;
; Syntax      : IDL>obj_dissect,class,methods=methods,props=props
;
; Inputs      : CLASS = class name or object variable name 
;
; Outputs     : See keywords
;
; Keywords    : QUIET = inhibit printing
;               METHODS = string array of method calls
;               PROPS = string array of property names
;
; History     : Written 20 May 1999, D. Zarro, SM&A/GSFC
;               Modified 5 Nov 2006, Zarro (ADNET/GSFC)
;                - removed EXECUTE
;               Modified 26 March 2009, Zarro (ADNET/GSFC)
;                - made searching super classes the default
;               31-Dec-2015, Zarro (ADNET) - improved error handling
;
; Contact     : dzarro@solar.stanford.edu
;-

pro obj_dissect,class,methods=methods,verbose=verbose,super=super,$
                err=err,props=props,_extra=extra

err=''
methods='' & props=''
 
if n_elements(class) ne 1 then begin
 err='Input argument must be scalar class name or object reference'
 mprint,err
 return
endif

if is_number(super) then super=(0b > byte(super) < 1b) else super=1b
verbose=keyword_set(verbose)
find_props=arg_present(props)
find_methods=arg_present(methods)

valid_obj=0b
if size(class,/tname) eq 'OBJREF' then begin
 valid_obj=obj_valid(class)
 if ~valid_obj then begin
  err='Input object is null'
  mprint,err
  return
 endif
 class_name=obj_class(class) 
endif else begin
 if is_blank(class) then begin
  if find_props then $
   pr_syntax,'props=obj_props(class_name)'
  if find_methods then $
   pr_syntax,'methods=obj_methods(class_name [,/super])'
  err='Invalid input'
  return
 endif
 class_name=class
endelse 

;-- error catch

class_err='"'+class_name+'" is probably not a valid class name'
error=0
catch,error
if error ne 0 then begin
 err=class_err
 mrpint,err
 catch,/cancel
 return
endif
                       
;-- extract properties 

if find_props then begin
 temp=obj_struct(class_name,err=err)
 if is_string(err) then mprint,err
 if is_struct(temp) then props=tag_names(temp) else props=''
 return
endif

if ~find_methods then return   
                                       
;-- extract methods calls
;-- look for __define constructor procedure. 
;   If found, avoid the overhead of creating a temporary object

class_def=strlowcase(trim(class_name))+'__define'
have_con=have_proc(class_def,out=fname)

if ~have_con || (super && ~valid_obj) then begin
 chk=valid_class(class_name)
 if ~chk then begin
  err='Invalid class name - '+class_name
  mprint,err
  return
 endif
endif

if fname eq '' then begin
 def_err='Could not locate "'+class_def+'" constructor'
 err=def_err
 mprint,err
 return
endif

temp=''
chkarg,fname,out=temp,/quiet,/reset

;-- search for method calls with '::'

out=''
calls=where(strpos(temp,'::') gt -1,count)
if count gt 0 then begin
 if count gt 0 then out=temp[calls]
 if count eq 1 then out=out[0]
 if verbose then for i=0,count-1 do print,out[i]
endif

;-- check for super classes

if super then begin
 sclass=obj_class(class_name,/super)
 if trim(sclass[0]) ne '' then begin
  for i=0,n_elements(sclass)-1 do begin
   obj_dissect,sclass[i],methods=sout,verbose=verbose
   if is_string(sout) then begin
    if is_blank(out) then out=sout else out=append_arr(out,sout,/no_copy)
   endif
  endfor
 endif
endif
methods=out

if is_blank(out) && verbose then mprint,'No methods found for "'+class_name+'"'

return & end
