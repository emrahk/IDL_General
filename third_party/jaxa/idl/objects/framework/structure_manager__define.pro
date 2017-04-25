;---------------------------------------------------------------------------
; Document name: structure_manager__define.pro
; Created by:    Andre Csillaghy, March 4, 1999
; Time-stamp: <Wed Nov 22 2006 14:30:46 csillag tournesol.local>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI
;
; NAME:
;       STRUCTURE MANAGER CLASS
;
; PURPOSE:
;       Manages the input and output of values for tag names of a specific
;       structure. In that sense, structure tags ar considered as
;       parameters, and structures as containers of parameters.
;       The class associates with the structure a Get() function and a Set
;       procedure.
;       To set a value to a parameter:
;       o->Set, TAG_NAME = tag_value
;       To get a value from a parameter:
;       tag_value = o->Get( /TAG_NAME )
;
;       Under the assumption of uniqueness, parameter names can be
;       shortened, e.g. tag_value = o->Get( /TAG_N ) is equivalent to
;       tag_value = o->Get( /TAG_NAME ) as long as there are no other
;       parameters biginning with TAG_N.
;
;       This is one of the main component of the Framework class. It
;       allows to uniformly manage control and information parameters.
;
;       The structure manager deals with pointers transparently. That
;       is, if you have a tag name defined as a pointer, you can use
;       that tag name to store virtually anything. The stucture
;       manager will deal with pointer dereferencing automatically.
;
; CATEGORY:
;       Objects
;;
; CONSTRUCTION:
;       obj = Obj_New( 'Structure_Manager', structure )
;
; INPUT:
;       struture: the arbitrary struture to manage
;
; METHODS:
;       Get(): to get a value from a specific tag name
;       Set: to set a value to a specific tag name
;
; KEYWORDS:
;       DONE: (Set) is "1" if the value of a parameter (i.e., tag) has been changed
;       FOUND: (Get, Set) is an array containing the parameter names that have
;              been found.
;       NO_DEREFERENCE: (Get) Under normal operations, the structure
;                       manager will dereference pointers when passing
;                       back values. This feature can be turned off
;                       with that keyword.
;       NOSINGLE: (Get) Under normal operations, the structure manager
;                 will return a structure when several parameters are
;                 requested, where each parameter is a tag name with
;                 its values assigned to that tag name. However, If only a
;                 single parameter is requested, the value of that
;                 parameter will be directly passed back. The NOSINGLE
;                 option allows to get a structure back even if there
;                 is only one parameter requested.
;       NOT_FOUND: (Set)  is an  array of positions of the parameters
;                  that have not been found.
;
; HISTORY:
;       21-Aug-2009, K Tolbert = In Set, use heap_free instead of ptr_free to 
;         free recursively. Pointers inside the pointers weren't being freed. Memory leak.
;       30-Apr-2009, K Tolbert - in Set, set item_to_assign = this_item if not valid pointer
;       27-July-2001, Paul Bilodeau - added call to Ptr_Free to fix memory leak
;       Based on hsi_super__define, but generalized.
;           June 28, 1999, A Csillaghy, csillag@ssl.berkeley.edu
;       hsi_super: March 4, 1999, for Release 2
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-

function structure_manager_test

o = obj_new( 'structure_manager', {hsi_image_strategy_control} )
t = systime( /sec ) & for i=0l, 100000l do o->set, im_time_bin = 1 & print, systime( /sec ) - t
t = systime( /sec )
for i=0l, 100000l do bb = o->get( /im_time_bin )
print, systime( /sec ) - t

end


;---------------------------------------------------------------------------

FUNCTION Structure_Manager::INIT, struct,  _EXTRA = _extra

IF N_Params() EQ 1 AND Size( struct, /TYPE ) EQ 8 THEN BEGIN
    self.struct = Ptr_New( struct )
    self.tag_name = Ptr_New( Tag_Names( struct ) )
    self.n_tags = N_Elements( *self.tag_name )
    self.before_idl_56 = !version.release LT '5.6'
    return, 1
ENDIF else begin
    message, 'you must construct the structure manager with a structure', /cont
    return, 0
endelse

END

;---------------------------------------------------------------------------

PRO Structure_Manager::CLEANUP

Free_Var, self.struct
Ptr_Free, self.tag_name

END

;---------------------------------------------------------------------------

FUNCTION Structure_Manager::NewGet, $
                          PARAM_NAME=param_name, $
                          PTR=ptr, $
                          FOUND=found, $
                          done = done

done = 0
found = ''

; this is if the whole structure must be returned
IF NOT Keyword_Set( PARAM_NAME ) THEN BEGIN
    found = *self.tag_name
    done = 1
    RETURN, *self.struct
ENDIF

; in newget, we only look for a single parameter

; here we know we look for a single parameter
; but the parameter could be associated with to structure tags

found_idx = WC_Where( *self.tag_name, param_name + '*', n_found, /CASE_IGNORE )
IF n_found GT 0 THEN BEGIN
    found = (*self.tag_name)[found_idx]
    if not keyword_set( ptr ) then begin
      ret = struct_subset( *self.struct, found )
    endif else begin
      ret = struct2ptr(*self.struct, found_idx)
    endelse
endif else ret = -1

return, ret

END

;---------------------------------------------------------------------------

FUNCTION Structure_Manager::Get, $
                  NOT_FOUND=NOT_found, $
                  PARAM_NAME=param_name, $
                  FOUND=found, $
                  NOSINGLE=nosingle, $
                  NO_DEREFERENCE=no_dereference, $
                  _EXTRA=_extra

IF NOT Keyword_Set( _EXTRA ) AND NOT Keyword_Set( PARAM_NAME ) THEN BEGIN
    NOT_found = ''
    found = *self.tag_name
    IF Keyword_Set( NO_DEREFERENCE ) THEN BEGIN
        RETURN, *self.struct
    ENDIF ELSE BEGIN
        RETURN, Tag_Dereference( *self.struct )
    ENDELSE
ENDIF

this_param_name=Keyword_Set( _EXTRA ) ? $
    Tag_Names( _extra ) : Strupcase(param_name)
n_param = N_Elements( this_param_name )

found =  ''

; pmessmer 2005-02-02
if n_param gt 0 then strlen_this_param_name = strlen(this_param_name)

FOR i=0, n_param-1 DO BEGIN
; acs 2003-05-17 this takes too much time
; 2005-feb-01 this is unnecessary
;    IF Float( !version.release )  LT 5.6 THEN BEGIN
    IF self.before_idl_56 THEN BEGIN
        found_idx = WC_Where( *self.tag_name, this_param_name[i] + '*', n_found )
    ENDIF ELSE BEGIN
;        found_idx = where( stregex( *self.tag_name, '^' + this_param_name[i], $
;                                    /FOLD_CASE, /BOOLEAN ), n_found )
         found_idx = where(strcmp(*self.tag_name, this_param_name[i], /fold_case, $
                         strlen_this_param_name[i]))
         n_found = found_idx[0] eq -1 ? 0 : n_elements(found_idx)
        ;print, '------------------------------------
        ;print, 'searched = ', this_param_name[i]
        ;print, 'tag = ', *self.tag_name
        ;print, 'found_idx, n_found = ', found_idx, n_found
        ;print, '-------------------------------------
    ENDELSE
    IF n_found GT 0 THEN BEGIN
        IF n_param EQ 1 AND n_found EQ 1 THEN BEGIN
; for performance acs 2005-02-01
            found_idx0 = found_idx[0]
            found = (*self.tag_name)[found_idx0]
            NOT_found =  ''
            IF Keyword_Set( NOSINGLE ) THEN BEGIN
; this crashes when the tag is a structure
; so we replaced str_subset with create_struct on 2002-02-10
;                ret = Str_Subset( *self.struct, found[0] )
                ret = Create_Struct( found[0], (*self.struct).(found_idx0) )
                IF Keyword_Set( NO_DEREFERENCE ) THEN BEGIN
                    RETURN, ret
                ENDIF ELSE BEGIN
                    RETURN, Tag_Dereference( ret )
                ENDELSE
            ENDIF ELSE BEGIN
                ret =  (*self.struct).(found_idx0)
                IF (Ptr_Valid( ret[0] ))[0] THEN BEGIN
                    IF Keyword_Set( NO_DEREFERENCE ) THEN BEGIN
                        RETURN, ret
                    ENDIF ELSE BEGIN
                        RETURN, *ret
                    ENDELSE
                ENDIF ELSE BEGIN
                    RETURN, ret
                ENDELSE
            ENDELSE
        ENDIF ELSE BEGIN
            full_found_idx=N_Elements( full_found_idx ) GT 0 ? $
                [full_found_idx, found_idx]: found_idx
        ENDELSE
    ENDIF
ENDFOR

IF N_Elements( full_found_idx ) NE 0 THEN BEGIN
    ; is that really needed?
    ;full_found_idx = full_found_idx[ Uniq( full_found_idx )]
    found = (*self.tag_name)[full_found_idx]
    IF Keyword_Set( NO_DEREFERENCE ) THEN BEGIN
        RETURN, Str_Subset(*self.struct, found )
    ENDIF ELSE BEGIN
        RETURN, Tag_Dereference( Str_Subset(*self.struct, found) )
    ENDELSE
ENDIF ELSE BEGIN
    NOT_found = *self.tag_name
    RETURN, -1
ENDELSE

END

;---------------------------------------------------------------------------

PRO Structure_Manager::NewSet, param_name, param_value, $
                     DONE=done, need_update = need_update

done = 0
need_update = 0
IF N_Params() ne 2 THEN BEGIN
    Message, 'One parameter and one value must be passed to be set', /CONTINUE
    RETURN
ENDIF

; acs get rid of wc_where 2003-05-17
;IF float( !version.release ) LT 5.6 THEN BEGIN
if self.before_idl_56 then begin
    idx = WC_Where( *self.tag_name, param_name + '*', n_found, /CASE_IGNORE )
ENDIF ELSE begin
;    idx = where( stregex( *self.tag_name, '^' + param_name, $
;                          /FOLD_CASE, /BOOLEAN ), n_found )
     idx = where(strcmp(*self.tag_name, param_name, /fold_case, strlen(param_name)))
     n_found = idx[0] eq -1 ? 0 : n_elements(idx)
ENDELSE

IF n_found EQ 0 THEN return

param_stored = (*self.struct).(idx)
if same_data( param_stored, param_value, /NOTYPE_CHECK ) then begin
    done = 1
    return
endif

size_stored = Size( param_stored, /TYPE )
size_passed = Size( param_value, /TYPE )

; 1st case: both param and struct are vars
if size_stored ne 10 then begin
    if  size_passed ne 10 then begin
        (*self.struct).(idx) = param_value
        done = 1 & need_update = 1
    endif else begin
        done =1
        if not same_data( param_stored, *param_value, /NOTYPE_CHECK ) then begin
            (*self.struct).(idx) = *param_value
            need_update = 1
        ENDIF
    endelse
endif else begin
; here the param stored is a pointer
    if  size_passed ne 10 then begin
; if the parameter passed is not a pointer, check the value first and
; if different assings it
        IF Ptr_Valid( param_stored ) then begin
            if NOT same_data( *param_stored, param_value, /NOTYPE_CHECK ) THEN BEGIN
                ptr_free, (*self.struct).(idx)
            endif else begin
                done = 1
                return
            endelse
        endif
        (*self.struct).(idx) = Ptr_New( param_value )
        done = 1 & need_update = 1
    endif else begin
; here both params are pointers. we know they are not shallow equal,
; so let's check if they are deep equal
        if ptr_valid( param_stored ) then begin
            if not same_data( *param_stored, *param_value ) then begin
                ptr_free, (*self.struct).(idx)
            endif else begin
                done = 1
                return
            endelse
        endif
        (*self.struct).(idx) = param_value
        done = 1 & need_update = 1
    endelse
endelse

END

;---------------------------------------------------------------------------

PRO Structure_Manager::SET, _EXTRA = _extra, $
                     found = found, $
                     NOT_FOUND=NOT_found, $
                     fw_set_id = fw_set_id, $ ; just to make sure that it does
                                ; not get in the way of the variables to really be set
                     DONE=done

IF NOT Keyword_Set( _EXTRA ) THEN BEGIN
    Message, 'At least one parameter must be passed to be set', /CONTINUE
    done =  -1
    NOT_found =  -1
    RETURN
ENDIF

tag_name = Tag_Names( _extra )
n_tag = N_Tags( _extra )
done = Bytarr( n_tag )

;; pmessmer 2005-02-02 ---
if n_tag gt 0 then strlen_tag_name  = strlen(tag_name)
; ---

FOR i=0, n_tag-1 DO BEGIN

;    IF Float( !version.release ) LT 5.6 THEN BEGIN
    if self.before_idl_56 then begin
        this_tag_idx = WC_Where( *self.tag_name, tag_name[i] + '*', n_found, /CASE_IGNORE )
    ENDIF ELSE begin
;;--- pmessmer 2005-02-02
;;        this_tag_idx = where( stregex( *self.tag_name, '^' + tag_name[i], $
;;                                       /FOLD_CASE, /BOOLEAN ), n_found )
       this_tag_idx = where(strcmp(*self.tag_name, tag_name[i], /fold_case, strlen_tag_name[i]))
       n_found = this_tag_idx[0] eq -1 ? 0 : n_elements(this_tag_idx)
;;---
    ENDELSE

;print, n_found
    IF n_found GT 0 THEN BEGIN

;         IF tag_name[I] EQ 'NATURAL' THEN STOP

        this_item = _extra.(i)

        IF Size(  this_item, /TYPE ) EQ 10 THEN BEGIN
            is_ptr_to_assign = 1
        ENDIF ELSE is_ptr_to_assign = 0
;        is_ptr_to_assign = Size(  this_item, /TYPE ) EQ 10

        ;;; revisited for performance 2005-02-01 acs
        this_tag_idx0 =  this_tag_idx[0]
        is_ptr_stored = Size( (*self.struct).( this_tag_idx0 ), /TYPE ) EQ 10
        IF is_ptr_stored THEN BEGIN
            IF Ptr_Valid((*self.struct).( this_tag_idx0 )) THEN BEGIN
                item_stored = (*(*self.struct).( this_tag_idx0 ) )
            ENDIF ELSE BEGIN
                item_stored = Ptr_New()
            ENDELSE
        ENDIF ELSE BEGIN
            item_stored = (*self.struct).( this_tag_idx0 )
        ENDELSE

;        item_stored = (*self.struct).( this_tag_idx[0] )
;        is_ptr_stored = Size( item_stored, /TYPE ) EQ 10
;        IF is_ptr_stored THEN BEGIN
;            IF Ptr_Valid(item_stored) THEN BEGIN
;                item_stored = (*item_stored)
;            ENDIF ELSE BEGIN
;                item_stored = Ptr_New()
;            ENDELSE
;        endif

        IF is_ptr_to_assign THEN BEGIN
            n_ptr = N_Elements( this_item )
            IF n_ptr GT 1 THEN BEGIN
                item_to_assign = this_item ; temporary! we need to check even for this.
            ENDIF  ELSE BEGIN
                item_to_assign = this_item
                IF Ptr_Valid( this_item ) THEN $
                    IF N_Elements( *this_item) NE 0 THEN BEGIN
                    item_to_assign = *this_item
                ENDIF 
            ENDELSE
        ENDIF ELSE BEGIN
            item_to_assign = this_item
        ENDELSE

        IF Size(  this_item, /TYPE ) EQ 10 THEN IF n_ptr GT 1 THEN samedata = 0
        IF Size( item_to_assign, /N_DIM ) NE Size( item_stored, /N_DIM ) THEN samedata = 0 $
            ELSE samedata = Same_Data( item_to_assign, item_stored, /NOTYPE_CHECK )

        IF NOT samedata THEN BEGIN
            done[i] = 1
            IF is_ptr_stored AND NOT is_ptr_to_assign THEN BEGIN
            	HEAP_FREE, (*self.struct).( this_tag_idx[0] ) ; Kim changed from ptr_free to heap_free, 20-aug-2009
                (*self.struct).( this_tag_idx[0] ) = Ptr_New( item_to_assign )
            ENDIF ELSE IF is_ptr_to_assign AND NOT is_ptr_stored THEN BEGIN
;                 (*self.struct).( this_tag_idx[0] ) = item_to_assign
                  (self.struct).( this_tag_idx[0] ) = this_item
            ENDIF ELSE BEGIN
                IF is_ptr_stored THEN BEGIN
                    HEAP_FREE, (*self.struct).( this_tag_idx[0] ) ; Kim changed from ptr_free to heap_free, 20-aug-2009
                    IF N_Elements( this_item ) GT 1 THEN BEGIN
                        (*self.struct).( this_tag_idx[0] ) = Ptr_new( item_to_assign )
                    ENDIF ELSE BEGIN
                        (*self.struct).( this_tag_idx[0] ) = this_item
                    ENDELSE
                ENDIF ELSE BEGIN
                    ;;; this special case is nneded as some params are nested
                    ;;; structures, for instance as_quality from aspect
                    ;;; solution. when reading from files. some parameters
                    ;;; might have been stripped off, such as null
                    ;;; pointers. acs 2005-08-04
                    if size( (*self.struct).( this_tag_idx[0] ), /type ) eq 8 then begin
                        temp_struct = (*self.struct).( this_tag_idx[0] )
                        struct_assign, item_to_assign, temp_struct
                        (*self.struct).( this_tag_idx[0] ) = temp_struct
                    endif else begin
                        (*self.struct).( this_tag_idx[0] ) = item_to_assign
                    endelse
                ENDELSE
            ENDELSE
        ENDIF

    ENDIF ELSE BEGIN

; revisit 2005-02-01 acs
        NOT_found = N_Elements( NOT_found ) GT 0 ? $
            [NOT_found, i]: i

;        not_found_arr[i] = 1

    ENDELSE

ENDFOR

IF N_Elements( NOT_found ) EQ 0 THEN NOT_found =  -1 ;else not_found = where( not_found_arr )

END

;---------------------------------------------------------------------------


PRO Structure_Manager__define

self = {Structure_Manager, $
        struct: Ptr_New(), $
        tag_name: Ptr_New(), $
        n_tags: 0, $
        before_idl_56:0B}

END


;---------------------------------------------------------------------------
; End of 'hsi_super__define.pro'.
;---------------------------------------------------------------------------
