;+
; Project     : HESSI
;
; Name        : CLONE__DEFINE
;
; Purpose     : Define a CLONE class
;
; Category    : objects
;
; Explanation : CLONE class contains a single method for
;               cloning an arbitrary object. Pointers and objects
;               are cloned recursively. 
;
; Usage:      : inherit class in your class__define procedure
;  
;               
; e.g:
;
; pro your_class__define
; temp={your_class, property tags...,inherits parents,inherits clone}
; return
; end
;
; (note use of multiple inheritance)
;                    
; then, 
; IDL> your_obj=obj_new(your_class)
;
; then use it as a procedure: 
;
; IDL>your_obj->clone,cloned_obj
;
; or as a function:
; 
; IDL> cloned_obj=your_obj->clone()
;
; Alternatively, CLONE method can be added dynamically to an existing
; object, via:
; 
; IDL> add_method,'clone',object
;
; Just make sure that there are no CLONE methods in current class or
; adjacent inherited parent classes -- or there will be a conflict
;
;
; Outputs     : class with clone method
;
; History     : Written 8 July 2000, D. Zarro, EIT/GSFC
;               Modified 30 October 2006, Zarro (ADNET/GSFC) 
;                - removed EXECUTE
;
; Contact     : dzarro@solar.stanford.edu
;-

function clone::init

return, 1

end

;-------------------------------------------------------------------------
;-- cleanup (placeholder, does nothing)

pro clone::cleanup

return & end


;--------------------------------------------------------------------------
;-- clone object (procedure)
;-- e.g. obj->clone,cloned_object

pro clone::clone,out,_extra=extra,destroy_input=destroy_input
                    
;-- identify source class

selfclass = obj_class(self)

;-- avoid memory leaks by first freeing output cloned_object

if keyword_set(destroy_input) then begin
 if size(out,/tname) eq 'OBJREF' then if obj_valid(out) then obj_destroy,out
endif

out=obj_new(selfclass)

if not obj_valid(out) then return          

;-- recurse over nested pointers and objects

struct=obj_struct(selfclass)

for i=0,n_tags(struct)-1 do begin

 dtype=size(struct.(i),/tname)
 free_var,out.(i)

 case dtype of

  'POINTER': out.(i)=ptr_clone(self.(i),_extra=extra) 

  'OBJREF': out.(i)=obj_clone(self.(i),_extra=extra)

  'STRUCT': out.(i)=stc_clone(self.(i),_extra=extra)

  else: out.(i)=self.(i)
 endcase
endfor

return
end


;--------------------------------------------------------------------------
;-- clone object (wrapper function around above procedure call)
;-- e.g. cloned_obj=obj->clone()

function clone::clone,_extra=extra

self->clone,out,_extra=extra

if obj_valid(out) then return,out else return,obj_new()

end

;-------------------------------------------------------------------------

pro clone__define

;-- dummy is just a dummy tag since CLONE class has no properties
 
self =  {clone,clone_define_placeholder:0}
   
end
                                                                           
