;+
; Project     : VSO
;
; Name        : IDL_BRIDGE__DEFINE
;
; Purpose     : Wrapper around IDL_IDLBRIDGE class to override SETVAR
;               and GETVAR methods in order to allow passing structures,
;               pointers, and objects.
;
; Category    : Objects
;
; Syntax      : IDL> o=obj_new('idl_bridge')
;
; Outputs     : O = IDL bridge object
;
; Keywords    : See IDL_IDLBRIDGE class definition
;
; History     : 21-November-2015, Zarro (ADNET) - Written
;               19-March-2016, Zarro (ADNET) 
;               - passed !QUIET to bridge
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function idl_bridge::init,_ref_extra=extra

quiet=strtrim(!quiet,2)
error=0
catch, error
if (error ne 0) then begin
 if ~stregex(err_state(),'OPENR: Error opening file. Unit: 100, File: ext_ucon',/bool) then begin
  mprint,err_state()
  if obj_valid(self) then obj_destroy,self
  catch,/cancel
  return,0
 endif
 catch,/cancel
 message,/reset
 self->execute,'!quiet='+quiet
 return,1
endif

s=self->idl_idlbridge::init(_extra=extra)
if s eq 1 then begin
 self->execute,'!quiet=1'
 self->execute, '@' + pref_get('IDL_STARTUP')
 self->execute,'!quiet='+quiet
endif

return,1

end
;-----------------------------------------------

pro idl_bridge::setvar,name,value,no_copy=no_copy,err=err

err=''
no_copy=keyword_set(no_copy)
if is_blank(name) ||  n_elements(value) eq 0 then return
type=size(value,/type)

;-- look for special cases (structure, pointer, object)

chk=where(type eq [8,10,11],count)
if count eq 0 then begin
 self->idl_idlbridge::setvar,name,value
endif else begin
 dimensions=size(value,/dimensions)
 buffer=data_stream(value)
 self->idl_idlbridge::setvar,name,buffer
 self->idl_idlbridge::setvar,'type',type
 self->idl_idlbridge::setvar,'dimensions',dimensions
 self->execute,name+'=data_unstream('+name+',type=type,dimensions=dimensions,/no_copy,err=err)'
 err=self->idl_idlbridge::getvar('err')
endelse

if string(err) then mprint,err else if no_copy then destroy,value

return
end

;------------------------------------------------

function idl_bridge::getvar,name,no_copy=no_copy,err=err

err=''
no_copy=keyword_set(no_copy)
if is_blank(name) then return,null()
self->execute,'type=size('+name+',/type)'
type=self->idl_idlbridge::getvar('type')
if type eq 0 then begin
 err='Non-existent variable - '+name
 mprint,err
 return,null()
endif

;-- look for special cases (structure, pointer, object)

chk=where(type eq [8,10,11],count)
if count eq 0 then begin
 value=self->idl_idlbridge::getvar(name)
endif else begin
 buffer_name='r'+session_id()
 self->execute,buffer_name+'=data_stream('+name+',dimensions=dimensions,err=err)'
 err=self->idl_idlbridge::getvar('err')
 if is_blank(err) then begin
  buffer=self->idl_idlbridge::getvar(buffer_name)
  dimensions=self->idl_idlbridge::getvar('dimensions')
  value=data_unstream(buffer,type=type,dimensions=dimensions,err=err,/no_copy)
  err=self->idl_idlbridge::getvar('err')
  self->execute,'destroy,'+buffer_name
 endif
endelse

if is_string(err) then begin
 mprint,err
 value=null()
endif else begin
 if no_copy then self->execute,'destroy,'+name
endelse

return,value 

end


;-----------------------------------------------
pro idl_bridge__define

temp={idl_bridge, inherits idl_idlbridge}

return & end
