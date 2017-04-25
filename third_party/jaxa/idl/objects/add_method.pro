;+
; Project     : HESSI
;
; Name        : ADD_METHOD
;
; Purpose     : Dynamically add a method to a class (and it's objects)
;
; Category    : utility objects
;
; Explanation : Based on method name (e.g. CLONE), looks for a class
;               definition file (e.g. CLONE__DEFINE.PRO). It then makes a 
;               temporary copy of this file, and replaces all instances
;               of CLASS::METHOD with OBJ::METHOD where OBJ is the
;               class name that you want to add METHOD to. It then
;               compiles this temporary file.
;
; Syntax      : IDL> add_method,method,object
;
; Examples    : IDL> add_method,'clone',map_object
;                             or
;               IDL> add_method,'gen::getprop',map_object
;
; Inputs      : METHOD = string method name
;             : OBJECT = object reference (or class name) 
;
; Outputs     : None
;
; Keywords    : ERR = error string
;               VERBOSE = set for output messages
;               CLEANUP = set to cleanup temporary files
;               OVERRIDE = override existing method if duplicate
;
; Restrictions: METHOD must have a METHOD__DEFINE.PRO in !path 
;               If user enters method such as, for example, GEN::GETPROP
;               the method name is the part after the ::
;               If :: is not present, then the input is assumed to be a 
;               class and all it's methods are added.
;               Added method(s) will only apply during current IDL session
;
; Side Effects: New method will override existing method of target object
;
; History     : Written: 9 July 2000, D. Zarro (EIT/GSFC)
;               Modified: 24 August 2000, Zarro (EIT/GSFC) - vectorized
;               Modified: 3 Sept 2001, Zarro (EITI/GSFC) - added option
;               to add specific method via: class::method_name
;               Modified: 4 May 2002, Zarro (EER/GSFC) - switched to
;               using CD instead of adding temporary path when using
;               RESOLVE_ROUTINE. IDL 6.0 has a problem with this.
;               Modified, 27 Feb 2007, Zarro (ADNET)
;                - added /NO_CLEANUP
;
; Contact     : dzarro@solar.stanford.edu
;-

pro add_method,method,object,err=err,verbose=verbose,override=override,$
               no_cleanup=no_cleanup


err=''
verbose=keyword_set(verbose)

;-- input checks

syntax='add_method,method,object'

if size(method,/tname) ne 'STRING' then begin
 err='First input argument must be a string method name'
 message,err,/info
 pr_syntax,syntax
 return
endif

;--check method input

method=trim(method)
cc_pos=strpos(method,'::')
all_methods=cc_pos eq -1
if all_methods then begin
 method_name=trim(method)
 method_class=trim(method)
endif else begin
 method_name=strmid(method,cc_pos+2,strlen(method))
 method_class=strmid(method,0,cc_pos)
endelse

;-- check for METHOD__DEFINE

method_define=method_class+'__define.pro'

if ~have_proc(method_define,out=method_file) then begin
 err='Could not locate - '+method_define
 message,err,/info
 return
endif

np=n_elements(object)
otype=size(object,/tname)
if (otype ne 'STRING') and (otype ne 'OBJREF') then begin
 err='Second input argument must be an object reference or class name'
 message,err,/info
 return
endif

;-- loop thru each object to determine valid class names

class_names=strarr(np)
if otype eq 'OBJREF' then begin
 for i=0,np-1 do begin
  if obj_valid(object[i]) then class_names[i]=strlowcase(obj_class(object[i]))
 endfor
endif else class_names=strlowcase(trim(object))

chk=valid_class(class_names,index,count=count)
if count eq 0 then return
valid_class_names=get_uniq(class_names[index])

;-- check if method has been added to these class names

np=n_elements(valid_class_names)
if ~keyword_set(override) then begin
 for i=0,np-1 do begin
  added=is_method_added(method_name,valid_class_names[i])
  if ~added then not_added=append_arr(not_added,valid_class_names[i])
 endfor
 if exist(not_added) then valid_class_names=not_added else begin
  if verbose then message,'Method "'+method_name+'" already added to "'+arr2str(valid_class_names)+'" class',/info
  return
 endelse
 np=n_elements(valid_class_names)
endif


;-- read the method file into memory and replace all function/pro calls
;   as follows:
;
;   METHOD::METHOD_NAME -> METHOD_CLASS::METHOD_NAME.
;
;   However, we don't replace any INIT or CLEANUP methods so as not to 
;   interfere with these methods in the original target object.
;     

marray=rd_ascii(method_file)
if all_methods then begin
 smethod=strlowcase(method_name)
 method_calls=smethod+'::'
endif else begin
 smethod=strlowcase(method_class)
 method_calls=strlowcase(method)
endelse

method_class=strlowcase(method_class)

init_call=method_class+'::init'
;init_call_arg=method_class+'::init '
cleanup_call=method_class+'::cleanup'

tarray=strlowcase(marray)

chk=(strpos(tarray,method_calls) gt -1) and $
    (strpos(tarray,init_call) eq -1) and $
;    (strpos(tarray,init_call_arg) eq -1) and $
    (strpos(tarray,cleanup_call) eq -1)
ok=where(chk,count)

if count eq 0 then begin
 err='Could not locate any '+method_name+' method calls in '+method_file
 message,err,/info
 return
endif

temp=tarray[ok]

;-- now do the replace 
                   
np=n_elements(valid_class_names)
for i=0,np-1 do begin
 class_name=valid_class_names[i]
 array=marray                  
                                                
 if verbose then message,'Adding "'+method_name+'" method(s) to '+class_name,/info

 init_call=class_name+'::init'
 cleanup_call=class_name+'::cleanup'

 if all_methods then mtemp='' else mtemp=method_name
 temp=str_replace(temp,method_calls,class_name+'::'+mtemp)

 array[ok]=temp

;--  write to a temporary file 

 temp_dir=get_temp_dir()
 temp_name=method_name+'.pro'
 temp_file=mk_temp_file(temp_name,direct=temp_dir,/random)
 break_file,temp_file,dsk,dir,pro_name

 new_array=append_arr(array,['pro '+pro_name,'end'],/no_copy)

 file_append,temp_file,new_array,/new

;-- compile new added method 

 cd,temp_dir,current=current
 qsave=!quiet
 !quiet=1
 resolve_routine,pro_name,/either
 !quiet=qsave
 cd,current

 error=0
 catch,error
 if error ne 0 then begin
  catch,/cancel
  cd,current
 endif

;-- cleanup

if ~keyword_set(no_cleanup) then file_delete,temp_file,/quiet

endfor

;-- compile original method file to get it's methods

obj_compile,method_class,/quiet


return & end
