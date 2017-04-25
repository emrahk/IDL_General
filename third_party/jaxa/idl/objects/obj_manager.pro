;+
; Project     : HESSI
;
; Name        : OBJ_MANAGER
;
; Purpose     : keep track of object references to avoid
;               memory leaks
;
; Category    : utility objects
;
; Explanation : Saves object heap names in global system variable
;               
; Syntax      : IDL> status=obj_manager(object)
;
; Inputs      : OBJECT = object reference
;
; Outputs     : STATUS = 1 if OBJECT has already been created, 0 otherwise
;
; Keywords    : None
;
; History     : Written 10 April 2002, D. Zarro, L3-Com/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function obj_manager,object

status=1b
if (size(object,/tname) ne 'OBJREF') then return,status

defsysv,'!obj_manager',exists=defined
if not defined then begin
 temp={reference:'',valid:0b}
 defsysv,'!obj_manager',ptr_new(temp)
endif

valid=obj_valid(object)
help,object,out=ref
ref=ref[0]
current=*!obj_manager
chk=where(ref eq current.reference,count)
if count eq 0 then begin
 if valid then begin
  new={reference:ref[0],valid:1b}
  new=merge_struct(current,new)
  *!obj_manager=new
 endif
endif else begin
 if valid then begin
  if current[chk].valid then begin
   message,'warning, '+ref+' already in memory',/cont
   status=0b
  endif
 endif else begin
  current[chk].valid=0b
  *!obj_manager=current
 endelse
endelse 

return,status & end

