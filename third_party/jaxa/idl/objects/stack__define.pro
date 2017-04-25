;+
; Project     : Virtual Solar Observatory
;
; Name        : STACK__DEFINE
;
; Purpose     : To define a 'stack' object (mutable array)
;
; Category    : Utility, VSO
;
; Explanation : The 'stack' object is a mutable array, which
;               can have 0 elements, or can have items 'push'ed
;               on to the end of it.  It's just a wrapper around
;               a pointer so I don't have to do garbage collection
;
; Syntax      : IDL> temp = obj_new('stack')
;
; Examples    : IDL> temp = obj_new('stack')
;               IDL> temp->push,'one'
;               IDL> temp->push, ['two', 'three']
;               IDL> results = temp->contents()
;
; History     : Version 1, 08-Nov-2005, J A Hourcle. Released
;               Modified 1-Jan-2006, Zarro (L-3Com/GSFC)
;                - improved memory management
;               V 1.2, 13-Aug-2010, Hourcle : removed 'foreach' due to conflict in IDL8;
;                                             can 'push' nothing without problem
;
; Contact     : oneiros@grace.nascom.nasa.gov
;-

; This is an attempt to create an 'array' that supports
; push (add to the end of the array) ... I might add
; pop/shift/unshift in the Perl sense sometime later.

; I was working on something more specific, but came across
; the 'Reading Data Into An Array' example in the IDL
; docs, and decided to make it a generic object
;
; NOTE : this may no longer be needed in IDL 8, but the code
;        that uses this should be backwards compatable

function stack::init
    self.contents = ptr_new(/allocate_heap)
    return, 1
end


;=======


pro stack::cleanup
    if (ptr_valid(self.contents)) then ptr_free, self.contents
return & end


;=======


; Input :
;   OBJECT : object to be added to the stack
; Note :
;   this will flatten arrays (add each element of the array to the stack)

pro stack::push, object
    if ~n_elements(object) then $
        return
    if not ptr_valid(self.contents) then $
        self.contents = ptr_new(/allocate_heap)

    if (n_elements(*self.contents) eq 0) then $
        *self.contents = object $
    else *self.contents = [temporary(*self.contents),object]
return & end

; convenience function --
; Input:
;   see PROCEDURE 'push'
; Output:
;   the number of elements in the stack

function stack::push, object
    self->push, object
    return, self->n_elements()
end


;=======

; Input :
;   none
; Output :
;   the underlying array (or a null pointer, if there are no elements)

function stack::contents
    return, *self.contents
end

;=======

; warning -- convenience functions, but they probably aren't useful
; to most people.  They're here mostly as stubs for later expansion

; this won't handle very complex calls
; so it'll only pass each element as the first argument,
; and the other arguments are in _extra

;pro stack::foreach, proc, _extra=extra
;    self->call_procedure, proc, _extra=extra
;return & end

;==

pro stack::call_procedure, proc, _extra=extra
    if self->n_elements() eq 0 then return
    for i = 0, self->n_elements()-1 do $
        call_procedure, proc, self->item(i), _extra=extra
return & end

;==

;function stack::foreach, func, _extra=extra
;    return, self->call_function( proc, _extra=extra )
;end

;==

function stack::call_procedure, func, _extra=extra
    results = obj_new('stack')
    if self->n_elements() eq 0 then return, results
    for i = 0, self->n_elements()-1 do $
        results->push, call_function( func, self->item(i), _extra=extra )
    return, results
end

;==

; I thought about a 'call_method', also, but it'd require using 'execute',
; which the docs say should be avoided if possible.


;=======

; Input :
;   none
; Output :
;   the number of elements currently in the stack

function stack::n_elements
    if ( not ptr_valid(self.contents) ) then return, 0
    if ( self.contents eq ptr_new()   ) then return, 0
    return, n_elements(*self.contents)
end

;=======

; Input :
;   INDEX : number ; the index number to retrieve
; Output :
;   the value stored in that indexed location

function stack::item, index
    if ( not is_number(index)        ) then return, ptr_new()
    if ( index GE self->n_elements() ) then return, ptr_new()

    contents = *self.contents
    return, contents[index]
end

;=======


pro stack__define
    struct = { stack, INHERITS gen, contents:ptr_new() }
return & end
