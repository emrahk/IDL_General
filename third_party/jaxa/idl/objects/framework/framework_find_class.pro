;---------------------------------------------------------------------------
; Document name: framework_find_class.pro
; Created by:    Andre, July 03, 2000
; Time-stamp: <Fri Sep 24 2004 16:39:12 csillag saturn.ethz.ch>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       framework_find_class( object, class_name )
;
; PURPOSE:
;       Traverses the whole tree of classe to find a class, and returns the object reference.
;
;       *note:* this does not apply to this version any more:
;       For Frameworks, it searches into all
;       the sources that contain a valid object, but it traverses
;       further only on the source with index 0. For Strategy_Holders,
;       in uses the function Strategy_Holder::GetStrategy() to find
;       out if the strategy is available (hence creating it if it is
;       not already created) before traversiong on source[0] as for
;       frameworks.
;       *end note*
;
; CATEGORY:
;       Objects
;
; CALLING SEQUENCE:
;       class_found = framework_find_class( start_object, class_name )
;
; INPUTS:
;       start_object: the object reference where the traversing should
;                     start. Must be a subclass of Framework or
;                     Strategy_Holder
;       class_name: the name of the class to search
;
; OUTPUTS:
;       class_found: the object reference of the class, or -1 if not found
;
; KEYWORDS:
;       VERBOSE: if set prints one of these ennoying messages.
;       FC_GET_ID: an ID assigned by framework, no use for users.
;
; SEE ALSO:
;       framework__define
;
; HISTORY:
;       11-apr-2011, Kim. Start looping backward at index 29, not 9 (there's
;                    space for 30 objects, but previously assumed would never
;                    use for more than 10)
;       07-aug-2007, Kim renamed to framework_find_class (from find_class)
;       1-sep-2004 - added the keyword fc_get_id  which allows to
;                    control the classes framework_find_class already visited
;                    such that it does not visit a class twice. The
;                    mechanism is internal and shoudl not be used at
;                    the user level. The framework assigns an id that
;                    is used to track down the recursion.
;
;       29-oct-2003: rewritten with recursion. need to decide about
;       the way to deal with strategies and/or multiple traversals of
;       the object tree.
;
;       12-aug-2003: acs, change to fix a bug that showed up in idl 6
;       (returns an array instead of a scalar)
;
;       Release 6: includes strategy_holder handling, September 2001, ACs
;
;       Version 1, July 03, 2000,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-


FUNCTION framework_find_class, this_object, class_name, VERBOSE = verbose, fc_get_id = fc_get_id

this_class_name = Obj_Class( this_object )

if strupcase(  class_name ) eq this_class_name then begin
    if keyword_set( verbose ) then begin
        message, 'class name found: ' + this_class_name, /info, /cont
    endif
    return, this_object
endif

;print, 'not the right class: ', this_class_name, 'checking further...'

; here we could not find the class. search for it recursively
; recursion is much nicer that the earlier crap!
; again a lesson from 2nd month of undergrad course

for i=29, 0, -1 do begin
    already_traversed = 0
    source_obj = this_object->Get( /source, src_index = i )
    if obj_valid( source_obj ) then begin
        if keyword_set( fc_get_id ) then begin
            if obj_isa( source_obj, 'framework' ) then begin
                ;print, source_obj->get_fc_id(), fc_get_id
                if source_obj->get_fc_id() eq fc_get_id then begin
                    already_traversed = 1
                ;    print, source_obj, ' is already traveresd'
                endif else begin
                    source_obj->set_fc_id, fc_get_id
                ;    print, source_obj, ' is not traversed yet'
                endelse
            endif
        endif
        if not already_traversed then begin
            obj_candidate = framework_find_class(  source_obj, class_name, fc_get_id = fc_get_id )
        endif
        if obj_valid( obj_candidate ) then return, obj_candidate
    endif
endfor

; if we are here we did not find the class

RETURN, -1

END

;---------------------------------------------------------------------------
; End of 'framework_find_class.pro'.
;---------------------------------------------------------------------------
