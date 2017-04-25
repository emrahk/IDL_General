;+
; Project     : VSO
;
; Name        : THREAD
;
; Purpose     : Wrapper around IDL-IDLBridge object to run any procedure
;               in a background thread
;
; Category    : utility objects
;
; Example     : 
;              IDL> thread,'proc',arg1,arg2,...arg10,key1=key1,key2=key2...
;              IDL> thread,'func',arg1,arg2,..,function_out=out,key1=key1,...

; Inputs      : PROC = procedure or function
;               ARGi = arguments accepted by proc/func (up to 10)
;
; Keywords    : KEYi = keywords accepted by proc/func
;               FUNCTION_OUT = special keyword to capture output of
;               function
;               NEW_THREAD = set to create a new thread object each
;               time [def = reuse last thread object]
;               ID_THREAD = unique ID string for thread object
;               RESET_THREAD = kill all running threads
;
; Restrictions: Only scalar or array variables of numeric or string
;               type can be transferred. Structures, pointers, and 
;               object references cannot be transferred between
;               processes using the IDL_IDLBridge object.
;
; History     : 22-Feb-2012, Zarro - Written
;               27-Jan-2015, Zarro 
;               - added support for returning modified
;                 arguments/keywords 
;               13-Feb-2015, Zarro
;               - added /NEW_THREAD
;-

;--- call back routine to notify when thread is complete

pro thread_callback, status, error, oBridge, userdata

common thread,obridge_sav,ocontainer

;-- check for modified input/output variables and return to scope of caller

 ndata=n_elements(userdata)
 if ndata gt 0 then begin
  new_obj=userdata[0].var_input eq 'new'
  id_obj=userdata[0].var_name
  for i=1,ndata-1 do begin
   var_name=userdata[i].var_name
   var_input=userdata[i].var_input
   if (var_name ne '') && (var_input ne '') then begin
    var_val=obridge->getvar(var_name)
    if n_elements(var_val) eq 0 then var_val=null()
    (scope_varfetch(var_input,level=-2,/enter))=var_val
   endif
  endfor
 endif

;-- signal completion

 case status of
  4: mess='Aborted.'
  3: mess='Completed, but with following warnings:'
  else: mess='Completed.'
 endcase
 
 if new_obj then begin
  if obj_valid(obridge) then obj_destroy,obridge
  print,'% THREAD_CALLBACK: '+id_obj+' '+mess
  if obj_valid(ocontainer) then ocontainer->remove,obridge
 endif else print,'% THREAD_CALLBACK: '+mess

 if error ne '' then mprint,error
 
 return & end

;---------------------------------------------------------------------------------

pro thread,proc,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,_ref_extra=extra,$
                reset_thread=reset_thread,function_output=function_output,$
                new_thread=new_thread,id_thread=id_thread

if n_params() eq 0 then begin
 print,"Syntax: thread,'procedure',arg0,arg1,...arg9,keywords=keywords"
 print,"Syntax: thread,'function',arg0,arg1,...arg9,function_out=output,keywords=keywords"
 return
endif

common thread,obridge_sav,ocontainer

if keyword_set(reset_thread) then begin
 if obj_valid(obridge_sav) then obj_destroy,obridge_sav
 if obj_valid(ocontainer) then obj_destroy,ocontainer
 return
endif

;-- restore last used thread from common (if not new thread)

new_thread=keyword_set(new_thread)
if ~obj_valid(ocontainer) then  ocontainer=obj_new('idl_container') 
if ~new_thread && obj_valid(obridge_sav) then obridge=obridge_sav

;-- set a catch in case of errors

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 if obj_valid(obridge) then obj_destroy,obridge
 if obj_valid(ocontainer) then ocontainer->remove,obridge
 catch,/cancel
 return
endif

;-- check we can open an X-window

;a=widget_base(map=0)
;widget_control,a,/destroy

;-- ensure thread object has same IDL environment/path as parent

if ~obj_valid(obridge) then begin
 obridge = Obj_New('IDL_Bridge',callback='thread_callback')
endif

;-- save new thread

if new_thread then begin
 ocontainer->add,obridge
endif

;-- check status

if ~new_thread then begin
 status=obridge->status(error=error)
 if is_string(error) then mprint,error
 if (status eq 3) || (status eq 4) then obridge->execute,'retall'
 if status eq 1 then begin
  print,'% THREAD: Current thread busy. Come back again later or use /NEW_THREAD to start new thread.'
  return
 endif
endif

;-- use scope functions to determine: 
;   var_name = local name of argument/keyword
;   var_input = caller name of argument/keyword
;   var_val = input/output value of argument/keyword

;-- if a new thread is being requested, tag it so that it can be
;   cleaned up when completed

if keyword_set(id_thread) then name=id_thread else name='Thread submitted at '+!stime
if new_thread then input='new' else input=''
userdata={var_name:name,var_input:input}

;-- if proc is a function, return output in special "function_output" keyword

cmd=proc
is_function=arg_present(function_output) || keyword_set(function_output)
if is_function then begin
 cmd='function_output='+proc+'('
 var_val=''
 var_name='function_output'
 obridge->setvar,var_name,var_val
 var_input=scope_varname(scope_varfetch(var_name,/enter),level=1)
 temp={var_name:var_name,var_input:var_input[0]}
 userdata=[userdata,temp]
endif

for i=1,n_params()-1 do begin
 var_val=''
 var_name='p'+strtrim(string(i),2)
 if arg_present(scope_varfetch(var_name)) || $
   n_elements(scope_varfetch(var_name)) ne 0 then begin
  if n_elements(scope_varfetch(var_name)) ne 0 then var_val=scope_varfetch(var_name)
  delim=','
  if strpos(cmd,'(') eq (strlen(cmd)-1) then delim='' 
  cmd=cmd+delim+var_name
 endif
 var_input=scope_varname(scope_varfetch(var_name,/enter),level=1)
 if n_elements(var_val) gt 0 then obridge->setvar,var_name,var_val
 temp={var_name:var_name, var_input:var_input[0]}
 userdata=[userdata,temp]
endfor

;-- use scope_varfetch to determine name "var_name" and value "var_value" of keywords at caller level

ntags=n_elements(extra)
if ntags gt 0 then begin
 for i=0,ntags-1 do begin
  var_name=extra[i]
  if n_elements(scope_varfetch(var_name,/ref)) ne 0 then var_val=scope_varfetch(var_name,/ref)
  delim=','
  if strpos(cmd,'(') eq (strlen(cmd)-1) then delim='' 
  cmd=cmd+delim+var_name+'='+var_name
  var_input=scope_varname(scope_varfetch(var_name,/ref),level=1)
  if n_elements(var_val) gt 0 then obridge->setvar,var_name,var_val
  temp={var_name:var_name, var_input:var_input[0]}
  userdata=[userdata,temp]
 endfor
endif

;-- pass caller variable names to bridge object for use by callback

if n_elements(userdata) gt 0 then obridge->setproperty,userdata=userdata

;-- set thread object to use same working directory as parent 

if is_function then cmd=cmd+')'
cd,current=current
obridge->execute,'cd,"'+current+'"'
obridge->execute,cmd,/nowait

;-- if not new thread, save in common for recycling

if ~new_thread && obj_valid(obridge) then obridge_sav=obridge

;-- check status

case obridge->status(error=error) of
 1: mprint,'Submitted.'
 2: mprint,'Completed.'
 3: mprint,'Failed - '+error
 4: mprint,'Aborted - '+error
 else: print,'Idle.'
endcase

if error ne '' then mprint,error

return & end


