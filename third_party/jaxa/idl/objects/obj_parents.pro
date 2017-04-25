;+
; Project     : HESSI
;
; Name        : OBJ_PARENTS
;
; Purpose     : find parents of object or class
;
; Category    : utility objects
;
; Explanation : uses recursion on OBJ_CLASS
;               
; Syntax      : IDL> parent=obj_parents(class)
;
; Inputs      : CLASS = class name or object variable name 
;
; Outputs     : PARENT = class name of parent, grandparents, great grand...
;
; Keywords    : COUNT = # of parents found
;               CHILD_NAME = class name of input child object
;
; History     : Written 10 Oct 1999, D. Zarro, SM&A/GSFC
;               Vectorized 17 April 2001, Zarro, EITI/GSFC
;               Modified 16 March 2004, Zarro (L-3Com/GSFC) 
;                - return children when no parents
;      
; Contact     : dzarro@solar.stanford.edu
;-

function obj_parents,class,count=count,child_name=child_name,err=err

err=''
count=0
child_name=''

chk=(size(class,/tname) eq 'OBJREF') or (size(class,/tname) eq 'STRING')
if (not chk) then begin
 err='Input argument must be class name or object reference'
 message,err,/cont
 return,''
endif


;-- check parents of class name.

sclass=(size(class,/tname) eq 'STRING')
np=n_elements(class)
for i=0,np-1 do begin
 status=1
 if sclass then obj_init,class[i],status=status
 if status then begin
  child_name=obj_class(class[i])
  output=obj_class(class[i],count=count,/super)
  if count gt 0 then parents=append_arr(parents,output) else $
   children=append_arr(children,child_name)
 endif
endfor
count=n_elements(parents)
if count eq 0 then return,children

;-- recurse here

grand_parents=obj_parents(parents,count=count2)
if count2 gt 0 then parents=[parents,grand_parents]

count=n_elements(parents)
if count eq 1 then parents=parents[0]
return,parents
 
end
