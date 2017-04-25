;+
; Project     : HESSI
;
; Name        : FREE_VAR
;
; Purpose     : free variable memory (pointer, objects, structures)
;
; Category    : utility objects
;
; Syntax      : IDL> free_var,var
;
; Inputs      : VAR = any type of IDL variable (scalar or array)
;
; Keywords    : DELETE = set to delvarx variable
;               EXCLUDE = string array of tag names to not free
;               NO_DEALLOCATE = clear pointer variables, but don't deallocate
;                            memory
;
; History     : Written 28 May 2000, D. Zarro, EIT/GSFC
;               Mod 20-Aug-2000, Kim Tolbert, added exclude keyword
;               Mod 28-Jun-2001, Andre Csillaghy, remodeled for
;               efficiency and worked on a problem with the structure option
;               Mod 12-Dec-2002, Zarro (EER/GSFC) - added check for
;               blank exclude & changed 'is_member' call to 'where'
;               22-Apr-2004, Zarro (L-3Com/GSFC) - added /NO_DEALLOCATE
;               22-Feb-2006, Zarro (L-3Com/GSFC) - replaced PTR_FREE by
;                                                  HEAP_FREE 
;
; Contact     : dzarro@solar.stanford.edu
;-

pro free_var,var,delete=delete, exclude=exclude,no_deallocate=no_deallocate

deallocate=1-keyword_set(no_deallocate)

np = n_elements(var)
if np eq 0 then return

; acs changed /tname to /type for efficiency
; 11: object
; 8: structure
; 10: pointer

dtype = size(var, /type)
proceed=where(dtype eq [8,10,11],count)
if count eq 0 then return

; for efficiency we don't use case so that we have
; only one test.
; here we can test only for the type, obj_destroy dont care if the
; object is not valid, also we can destroy all of them at once (i hope)

if (dtype eq 11) then begin
 if deallocate then obj_destroy, var
endif

if (dtype eq 8) then begin  
    
; check the tags on the first var only
; also let's do two loops separately for exclude set or not set.

 tags = tag_names(var[0])
 nt = n_elements(tags)
 if is_string(exclude) then begin 
  temp=strtrim(strupcase(exclude),2)
  for j=0l, nt-1 do begin 
   chk=where(tags[j] eq temp,count)
   if count eq 0 then free_var, var.(j),delete=delete,exclude=exclude,no_deallocate=no_deallocate
  endfor 
 endif else for j=0l, nt-1 do free_var,var.(j),delete=delete,exclude=exclude,no_deallocate=no_deallocate
endif

if (dtype eq 10) then begin 

;-- recurse on pointer values

; here we need the loop because we cannot dereference more than one ptr
; at once

 for i=0l, np-1 do if ptr_valid( var[i] ) then $
  free_var,*var[i],delete=delete,exclude=exclude,no_deallocate=no_deallocate

; the empty arr of ptrs can be deleted at once

  if deallocate then heap_free,var else ptr_empty,var

endif 

;-- finally remove variable

if keyword_set(delete) then delvarx,var

return & end

