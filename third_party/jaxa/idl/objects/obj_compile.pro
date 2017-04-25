;+
; Project     : HESSI
;
; Name        : OBJ_COMPILE
;
; Purpose     : compiles class/object methods
;               (including inherited methods)
;
; Category    : utility objects
;
; Syntax      : IDL> obj_compile,class
;
; Inputs      : CLASS = class name (or object)
;
; History     : Written 8 Sept 2001, Zarro, EITI/GSFC
;               Modified, 28 Mar 2003, Zarro (EER/GSFC)
;               -- added /either
;
; Contact     : dzarro@solar.stanford.edu
;-

pro obj_compile,class,_extra=extra

parents=obj_parents(class,count=count,err=err)

if err ne '' then return

if size(class,/tname) eq 'OBJREF' then name=obj_class(class) else $
 name=trim(class)

classes=name
if count gt 0 then classes=strlowcase([name,parents])
count=n_elements(classes)

qsave=!quiet
!quiet=1

for i=0,count-1 do resolve_routine,classes[i]+'__define',_extra=extra,$
                    /either
!quiet=qsave

return
end
