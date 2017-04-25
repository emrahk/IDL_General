;+
; Name: get_objref
; 
; Purpose: Get object reference(s) for specified class. Returned in order of heap variable index, which will probably be
;   order in which they were created.
;   
; Calling sequence: objs = get_objref([class])
; 
; Calling arguments:
;  class - Class name of objects to return.  If omitted, all objects are found.
;  
; Output: Array of references to object instances of specified class in heap index order.  If none, returns 0.
; 
; Examples:
;   If your session has one plotman object instance:
;   z = get_objref('plotman')
;   help,z
;      <Expression>    OBJREF    = <ObjHeapVar372158(PLOTMAN)>
;   
;   If your session has two plotman object instances:
;   z = get_objref('plotman')
;   help,z
;      Z               OBJREF    = Array[2]
;   help,z[0],z[1]
;      <Expression>    OBJREF    = <ObjHeapVar371982(PLOTMAN)>
;      <Expression>    OBJREF    = <ObjHeapVar372158(PLOTMAN)>
;
;Written: Kim Tolbert, 27-Feb-2014
;Modifications:
;
;-

function get_objref, class

checkvar, class, ''

a=obj_valid()

if class ne '' then begin
  q = where (obj_isa(a, class), count)
  if count eq 0 then return, 0
  a = a[q]
endif

heapind = long(get_heap_index(a))

return, n_elements(a) eq 1 ? a[0] : a[sort(heapind)]

end