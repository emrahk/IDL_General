;+
; Project     : HESSI
;
; Name        : GEN__DEFINE
;
; Purpose     : Define a GENeric object
;
; Category    : objects
;
; Explanation : This CLASS definition really only contains general methods
;               that can be inherited by other objects
;
; Inputs      : None
;
; Outputs     : Generic object with COPY and EXTRACT methods
;
; History     : Written 14 Oct 1999, D. Zarro (SM&A/GSFC)
;               Modified 27 Feb 2007, Zarro (ADNET)
;               - removed nasty EXECUTES
;               Modified 26-Apr-2009, Zarro (ADNET)
;               - modified GET to return "undefined" value instead of ''
; Contact     : dzarro@solar.stanford.edu
;-

function gen::init

self.debug = get_debug()
self.verbose =  fix( getenv('SSW_FRAMEWORK_VERBOSE') )
return, 1

end

;---------------------------------------------------------------------------

function gen::check_and_set, value_stored, new_value, $
                        yes_update = yes_update, $
                        execute = execute

yes_update = ~same_data( value_stored, new_value )
IF yes_update THEN BEGIN
    if keyword_set( execute ) then call_method, execute, self
    return, new_value
endif else begin 
    return, value_stored
endelse

end

;------------------------------------------------------------------------
pro gen::cleanup

return & end

;--------------------------------------------------------------------------

pro gen::methods,_extra=extra
iprint,obj_methods(self,_extra=extra)
return & end

;--------------------------------------------------------------------------
;-- extract properties (function)

function gen::getprop,_extra=extra,count=count,err=err,status=status
 
;-- following trick allows method to distinguish between
;   when keyword is set as an actual keyword or as an output
;   variable

status=1b
if keyword_set(count) and ~arg_present(count) then extra=add_tag(extra,1,'count')
if keyword_set(err) and ~arg_present(err) then extra=add_tag(extra,1,'err')

all=have_tag(extra,'all_props',/exact)
get_value=have_tag(extra,'get_value',/exact)

if all then extra=rem_tag(extra,'all_props')
if get_value then extra=rem_tag(extra,'get_value')

use_def=have_tag(extra,'default_val',/exact)

count=0
err=''
if use_def then begin
 rdef=extra.default_val 
 extra=rem_tag(extra,'default_val')
endif else rdef=''

if rdef eq '' then status=0b else status=1b
if ~all then begin 
 if ~is_struct(extra) then return,rdef
 props=tag_names(extra)
 if n_elements(props) ne 1 then begin
  err='Only one property can be accessed at a time'
  message,err,/info
  print,props
  return,rdef
 endif
 prop=trim(strlowcase(props[0]))
endif

class=obj_class(self)
struct=obj_struct(class,err=err)
if is_string(err) then return,rdef

;-- check if all properties are requested

props=strlowcase(tag_names(struct))
if all then begin
 struct_assign,self,struct
 for i=0,n_elements(props)-1 do begin
  np=n_elements(self.(i))
  for j=0,np-1 do begin
   if ptr_valid( self.(i)[j] ) then begin
    if exist( *(self.(i)[j]) ) and get_value then begin
     struct=rep_tag_value(struct,*(self.(i))[j],props[i])
    endif
   endif
  endfor
 endfor
 count=n_elements(struct)
 status=1b
 return,struct
endif

if ~have_tag(struct,prop,index,exact=exact,/start) then begin
 err='Property does not exist'
 return,rdef
endif

;-- find first one in which first 3 letters match

nfound=n_elements(index)
if nfound gt 1 then begin
 i=-1
 repeat begin
  i=i+1
  chk=strmid(props(index[i]),0,3) eq strmid(prop,0,3)
 endrep until chk or (i eq (nfound-1))

 if chk then value=self.(index[i]) else begin
  err='Property does not exist'
  return,rdef
 endelse
endif else value=self.(index[0])

count=n_elements(value)
if size(value,/tname) ne 'POINTER' then begin
 if size(value,/tname) eq 'STRING' then value=trim2(value)
 status=1b
 return,value
endif
if ~ptr_valid(value) then return,rdef

;-- if a valid pointer, then return it's value

count=n_elements(*value)
if count gt 0 then begin
 status=1b
 return,*value
endif

return,rdef
end

;---------------------------------------------------------------------------
;-- privatize properties

pro gen::private,properties,caller,_extra=extra

if (datatype(extra) eq 'STC') and (datatype(properties) eq 'STR') and $
 (datatype(caller) eq 'STR') then begin

 if (strpos(strupcase(caller),'::INIT') eq -1) then begin
  extra=rem_tag(extra,properties)
  if datatype(extra) ne 'STC' then delvarx,extra
 endif
endif

return & end

;---------------------------------------------------------------------------
;-- extract name and dir parts for filename (using REGEXP)

pro gen::fbreak,file,dir,name

if since_version('5.3') then name=file_break(file,path=dir) else begin
 break_file,file,dsk,path,fname,ext
 dir=trim2(dsk+path)
 name=trim2(fname+ext)
endelse

return & end

;----------------------------------------------------------------------------

pro gen__define
  
  temp =  {gen, $
           debug:0B,  $
           verbose: 0B}

   
end
                                                                           
