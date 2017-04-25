;---------------------------------------------------------------------------
; Document name: framework__define.pro
; Created by:    Andre Csillaghy, November 1999
; Time-stamp: <Thu Oct 23 2008 17:47:56 csillag tournesol2.local>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI
;
; NAME:
;       FRAMEWORK ABSTRACT CLASS DEFINITION
;
; PURPOSE:
;       Provides a generic framework to manage scientific data processing.
;       The framework contains four main elements:
;       - The primary data which needs to be managed
;       - The control parameters
;       - The informational parameters
;       - The administration parameters.
;       The framework is inherited by application-specific concrete
;       classes. It is based on the template method design pattern.
;       The abstract class cannot be used without a concrete class.
;
; CATEGORY:
;       Object
;
; CONSTRUCTION:
;
;       Only through the concrete class
;
;       Look at
;       http://hessi.ssl.berkeley.edu/software/hessi_oo_concept.html
;       for information on how to use a framework.
;
; METHODS DEFINED IN THIS CLASS:
;
;      All these methods have a bunch of keywords associated. Look
;      down below.
;
;      Get(): retrieves ancillary parameters, from control, information,
;             administration and/or source objects.  If only one parameter is
;             requested, Get returns the value of this parameter
;             unless /NOSINGLE is set. If more than one parameter are
;             requested, Get returns an anonymous structure that have
;             for tags the parameters requested.
;             For pointer-type variables, Get does an automatic
;             dereferencing, i.e. it
;             returns the variables to which the pointers are
;             pointing rather than the pointers
;             (but see also /NO_DEREFERENCE).
;
;      GetData(): Retrieves primary data. When this function is
;                 called, the object checks whether the
;                 control parameters have changed, using the function
;                 Need_Update (see below). If parameters have changed,
;                 it assumes that data need to be recomputed and Process
;                 is called. Otherwise the object retrieves the contents of
;                 its memory, and makes the appropriate selection
;                 depending on the keyword parameters. Note that most
;                 of the time this procedure is only the generic part
;                 of a redefined procedure GetData in the concrete class.
;
;      Set: Sets values to control parameters. Set does not just store
;           the parameter values into a data structure. It first
;           checks if the parameters are the same as those already
;           stored. If they are, it just returns. If they are not, it
;           will set the need_update flag in the administration
;           structure to 1.
;
;      SetData: Input primary data into the framework. This is
;               usually called by the procedure Process
;
;      Plot: plots the data. This generally first calls GetData, and
;            generates a "view" of the data. Often, tough, the data
;            may be strongly summarized. The generic plotting routine
;            is empty.
;
;      Process: This procedure is called whenever an object needs to
;               be updated. It reads in the control parameters
;               associated with the class, reads in the data form a
;               source object (or from any other sources), process the
;               source data and stpres the results into the object's memory.
;
;      Print: prints control, info, and admin parameters

;      Need_Update(): Returns "1" if the object must call the procedure
;                     "Process" to update its state; otherwise "0."
;
; INPUT (CONTROL) PARAMETERS DEFINED IN THIS CLASS:
;
;      Through the concrete class
;
;      Primary data: through the accessor method "SetData":
;          obj->SetData, data
;          data must match the object data type definition!
;
;      Control parameters: through the accessor method "Set":
;          obj->Set, KEYWORD=value, KEYWORD=value, ...
;          where KEYWORD corresponds to the name of a control parameter
;
; OUTPUT (INFO) PARAMETERS DEFINED IN THIS CLASS:
;
;      Through the concrete class
;
;      Primary data: through the accessor method "GetData"
;          data = obj->GetData()
;
;      Control, info and admin parameters: through the accessor method
;                                          "Get":
;      value = obj->Get( /KEYWORD )
;      where KEYWORD corresponds to the name of a admin, info, contro,
;      or source parameter
;
; KEYWORDS:
;      /ADMIN_ONLY: (Get) Set this to retrieve only the
;                   administration  parameters
;      ADMIN_STRUCT:(Set) Initializes the admininstration structure,
;                    type {admin}
;      CLASS_NAME: (Get, GetData) If set to a valid class name
;                  (string), retrieves parameters for the class
;                  specified and all its sources recursively.
;                  Default: current class
;      /CONTROL_ONLY: (Get) Set this to retrieve only control parameters
;      CONTROL_STRUCT (Set): Sets the controil structure
;      FOUND (Get): Set this to a named variable to get the names of
;                   the parameters found in a string array
;      /INFO_ONLY: (Get) Set this to retrieve only information parameters
;      POINTER (GetData): If set, retrievs a reference to the
;                         (orginal) data insteade of a copy.
;      SOURCE_ONLY: (Get) Set this to retrieve the source object
;                   reference. See also SRC_INDEX.
;      SRC_INDEX: (Get) Set this to the index or array of indices
;                 of the source object(s) you want
;                 to get with SOURCE_ONLY. Default: 0
;      THIS_CLASS_ONLY: (Get) Set this to retrieve data only for the
;                             current class or for the class specified
;                             by CLASS_NAME
;      OBJECT_REFERENCE: (Get) Set this to retrieves the object
;                              reference of the class specified by
;                              CLASS_NAME
;      NO_DEREFERENCE: (Get) Set this to prefent automatic
;                      dereferencing of pointer-type tags.
;      NOSINGLE: (Get) Set this to retrieve an anonymous structure even
;                      for a single parameter request
;      NOT_FOUND (Set): Returns an array of strings containing
;                       the name of the keywords that have NOT
;                       been found
;
; EXAMPLE:
;
; HISTORY:
;       2010-Aug-12, Kim. In GET, changed AND to && for IDL 8.0 (n_tags(null obj) fails in 8.0)
;       2010-Apr-30, Kim. Added class_name to error message in GetData
;       2009-Oct-2,  Kim. Undo change of aug21.  For classes that store an array
;                    of pointers by iteratively calling getdata, filling in indices and 
;                    calling setdata, that change broke things because heap_free wipes 
;                    out the ones that were saved earlier. heap_free only works for classes
;                    that replace their entire data array in setdata. 
;                    So this is still a memory leak.  Need a better solution.
;       2009-aug-21, Kim. In SETDATA, use heap_free for data instead of ptr_free
;       2009-aug-10, Kim. In SET, call free_var for control, info, and admin before
;                    setting new ones. qlook sets these structs directly - memory leak.
;       2007-aug-07, Kim changed calls to hsi_get_debug, find_class to framework...
;       2006-08-02 - Kim.  Added set_last_update method and call it from setdata.
;       2005-05-10 - acs changes in the get procedure to correct a bug in the
;                    way it deals with subnames. The change is a small fix
;                    that shoudl hold until the ne get procedure comes along.
;       2004-10-16 - acs changed free_var to heap_free for idl > 5.3,
;                    to hope to try to reduce the memory leakages
;       2004-09-01 - acs added a new counter, fc_get_id, that (in
;                    addition to fw_get_id) flags the classes visited
;                    by find_class when a specific class in the object
;                    chain is searched. The classes flagged are not
;                    visited again when they got the same fc_get_id as
;                    the object that want to visit them.
;       2004-05-21 - Now framework defines a counter to manage the
;                    last_update stuff. The counter increases every
;                    time setdata is called. This is needed because as
;                    of 2004 may, the fastest machines get similar
;                    values for last_update when using the system
;                    time. the system time is only precise to the
;                    milisecond, which is not enough.
;                    In addition need_update was completely rewritten
;                    and is twice as fast now.
;       Release 5.1: January 2001 Documentation update
;                    December 2000 Change ptr_free to free_var from
;                     Paul Billodeau
;       Release 5, July 2000
;       Release 4, March 2000
;       Based on hsi_super__define, but generalized.
;           June 28, 1999, A Csillaghy, csillag@ssl.berkeley.edu
;       hsi_super: March 4, 1999, for Release 2
;           A Csillaghy, csillag@ssl.berkeley.edu
;-

FUNCTION Framework::INIT, _REF_EXTRA = extra, DO_ALL_CLASSES=do_all_classes

self->Framework::Set, /ADMIN_STRUCT

checkvar, do_all_classes, 0
self.do_all_classes = do_all_classes

self.debug = framework_get_debug()
self.verbose = Fix( Getenv( 'SSW_FRAMEWORK_VERBOSE' ) ) or Fix( Getenv( 'DEBUG' ) )
self.progress_bar = self.verbose or  Fix( Getenv( 'SSW_USE_PROGRESS_BAR' ) )

!except =  self.debug EQ 0 ? 1 : 2

; acs 2004-05-20 the last update mechanism using the system time does not work.
; so let's use a globally defined counter.
; the counter is incremented in setdata every time some data is set
defsysv, '!hsi_last_update_counter', exist = exists
if not exists then defsysv, '!hsi_last_update_counter', 0L

defsysv, '!fw_get_id', exist = exists
if not exists then defsysv, '!fw_get_id', 0L

defsysv, '!fw_set_id', exist = exists
if not exists then defsysv, '!fw_set_id', 0L

; needs one also for find class
defsysv, '!fc_get_id', exist = exists
if not exists then defsysv, '!fc_get_id', 0L

self.isa_strat_holder = Obj_Isa( self, 'STRATEGY_HOLDER_TOOLS' )

IF Keyword_Set( EXTRA ) THEN self->Framework::Set, _EXTRA = extra

;if obj_class( self ) eq 'HSI_PACKET' then stop

RETURN, 1

END

;---------------------------------------------------------------------------

PRO Framework::CLEANUP, THIS_CLASS_ONLY = this_class_only

if since_version( 5.3 ) then begin
    IF Obj_Valid( self.control ) THEN heap_free, self.control
    IF Obj_Valid( self.info ) THEN heap_free, self.info
    IF Obj_Valid( self.admin ) THEN heap_free, self.admin
    IF NOT Keyword_Set( THIS_CLASS_ONLY ) THEN BEGIN
        IF Total( Obj_Valid( self.source ) ) GT 0 THEN heap_free, self.source
    ENDIF
    heap_free,  self.data
endif else begin
    if obj_class( self.source[0] ) eq 'HSI_PACKET' then stop
    IF Obj_Valid( self.control ) THEN Obj_Destroy, self.control
    IF Obj_Valid( self.info ) THEN Obj_Destroy, self.info
    IF Obj_Valid( self.admin ) THEN Obj_Destroy, self.admin
    Ptr_Free, self.data
endelse

END

;---------------------------------------------------------------------------

FUNCTION Framework::NewGet, $
                  ADMIN_ONLY=admin_ONLY, $
                  CLASS_NAME=class_name, $
                  CONTROL_ONLY=control_only, $
                  INFO_ONLY=info_only, $
                  NO_ADMIN=no_admin, $
                  PARAM_NAME=param_name, $
                  POINTER=pointer, $
                  SRC_INDEX=src_index, $
                  SOURCE_ONLY=source_only, $
                  THIS_CLASS_ONLY=this_class_only, $
                  OBJECT_REFERENCE=object_reference, $
                  NOSINGLE=nosingle, $
                  NO_DEREFERENCE=no_dereference, $
                  NOT_FOUND=NOT_found, $
                  FOUND=found, $
                  _EXTRA=_extra

normal_run = Keyword_Set( _EXTRA ) OR $
    NOT( Keyword_Set( CLASS_NAME ) OR Keyword_Set( SOURCE_ONLY ) OR $
         Keyword_Set( OBJECT_REFERENCE ) OR Keyword_Set( ADMIN_ONLY ) )

IF normal_run THEN BEGIN

    NOT_found = ''
    IF Keyword_Set( _EXTRA ) THEN BEGIN
        this_param_name = Tag_Names( _EXTRA )
        n_param = N_Elements( this_param_name )
    ENDIF ELSE IF Keyword_Set( PARAM_NAME ) THEN BEGIN
        this_param_name = param_name
        n_param = N_Elements( this_param_name )
    ENDIF ELSE BEGIN
        this_param_name = ''
        n_param = 0
    ENDELSE

    IF n_param GT 1 THEN BEGIN
        FOR i=0, n_param -1 DO BEGIN
            this_val=self->Framework::NewGet( PARAM_NAME = this_param_name[i] )
        ENDFOR
        stop
; put structures together
        return, struct
    ENDIF

; here we know we have only 1 param to look for

; first create the chain where to llok for the param
    IF Keyword_Set( CONTROL_ONLY ) THEN BEGIN
        object = self.control
    ENDIF ELSE IF Keyword_Set( INFO_ONLY ) THEN BEGIN
        object = self.info
    ENDIF ELSE BEGIN
        IF Keyword_set( NO_ADMIN ) THEN BEGIN
             object = [self.control, self.info ]
       ENDIF ELSE BEGIN
            object = [self.control, self.info, self.admin ]
        ENDELSE
    ENDELSE
    IF NOT Keyword_Set( THIS_CLASS_ONLY ) THEN BEGIN
        IF Keyword_Set( SRC_INDEX ) THEN BEGIN
            object = [ object, self.source[src_index] ]
        ENDIF ELSE BEGIN
            object = [ object, self.source ]
        ENDELSE
   ENDIF
   n_obj = N_Elements( object )

   CheckVar, nosingle, 0
   this_nosingle = nosingle OR n_param GT 1

   FOR i=0, n_obj-1 DO BEGIN

       this_obj = object[i]
       IF Obj_Valid( this_obj ) THEN BEGIN
           IF Obj_ISA( this_obj, 'FRAMEWORK' ) THEN BEGIN
               this_struct = this_obj->Get( _EXTRA=_extra, $
                                            FOUND=this_found, $
                                            CONTROL_ONLY=control_only, $
                                            INFO_ONLY=info_only, $
                                            NO_DEREFERENCE=no_dereference, $
                                            /NOSINGLE)
            ENDIF ELSE BEGIN
                this_struct = this_obj->Get( PARAM_NAME=this_param_name, $
                                             FOUND=this_found, $
                                             NOSINGLE=nosingle, $
                                             NO_DEREFERENCE=no_dereference )
            ENDELSE
            IF this_found[0] NE '' AND $
                N_Elements( this_found ) EQ n_param THEN BEGIN
                found = this_found
                IF NOT Keyword_Set( NOSINGLE ) AND $
                    N_Elements( found ) EQ 1 AND $
                    Size( this_struct, /TYPE ) EQ 8 AND $
                    N_Tags( this_struct ) EQ 1 THEN BEGIN
                    IF this_found[0] EQ (Tag_Names(this_struct))[0] THEN BEGIN
                        RETURN, this_struct.(0)
                    ENDIF ELSE BEGIN
                        RETURN, this_struct
                    ENDELSE
                ENDIF ELSE BEGIN
                    RETURN, this_struct
                ENDELSE
            ENDIF ELSE BEGIN
                                ; now put them together if some found
                IF this_found[0] NE '' THEN BEGIN
                    full_struct = create_Struct( full_struct, this_struct )
                    full_found=N_Elements( full_found ) GT 0 ? $
                        [full_found, this_found] : this_found
                ENDIF

            ENDELSE
        ENDIF
    ENDFOR
    found=N_Elements( full_found ) GT 0 ?  $
        full_found[ Uniq( full_found ) ] : ''

    IF found[0] EQ '' THEN BEGIN
        RETURN, -1
    ENDIF ELSE BEGIN
        RETURN, full_struct
    ENDELSE

ENDIF

IF Keyword_Set( CLASS_NAME ) THEN BEGIN
    this_object = framework_find_class( self, class_name )
    IF Obj_Valid( this_object ) THEN BEGIN
        IF self.verbose GT 9 THEN BEGIN
            Message, class_name + ' found', /INFO, /CONTINUE
        ENDIF
        ; IF class_name EQ 'HSI_PACKET' THEN STOP
        IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
            RETURN, this_object
        ENDIF ELSE BEGIN
            RETURN, this_object->Get(  ADMIN_ONLY=admin_only, $
                                       CONTROL_ONLY=control_only, $
                                       POINTER=pointer, $
                                       SOURCE_ONLY=source_only, $
                                       THIS_CLASS_ONLY=this_class_only, $
                                       NOSINGLE=nosingle, $
                                       NOT_FOUND=NOT_found, $
                                       FOUND=found, $
                                       _EXTRA=_extra  )
        ENDELSE
    ENDIF ELSE IF self.debug GT 5 THEN BEGIN
        Message, class_name + 'not found', /INFO, /CONTINUE
    ENDIF
ENDIF ELSE IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
    RETURN, self
ENDIF

IF Keyword_Set( SOURCE_ONLY ) THEN BEGIN
    CheckVar, src_index, 0
    RETURN, self.source[src_index]
ENDIF
IF Keyword_Set( ADMIN_ONLY ) THEN RETURN, self.admin

END

;---------------------------------------------------------------------------

function framework::getid

return, self.fw_get_id

end

;---------------------------------------------------------------------------

function framework::get_this_class_pars

if obj_valid( self.info ) then ret_struct = self.info->get()
if obj_valid( self.control ) then begin
    ret_struct = create_struct( ret_struct, self.control->get() )
endif
return, ret_struct

end

;---------------------------------------------------------------------------


FUNCTION Framework::Get, $
                  ADMIN_ONLY=admin_ONLY, $
                  CLASS_NAME=class_name, $
                  CONTROL_ONLY=control_only, $
;                  DEBUG=debug, $
                  fc_get_id = fc_get_id, $
                  fw_get_id = fw_get_id, $
                  FOUND=found, $
                  INFO_ONLY=info_only, $
                  NO_ADMIN=no_admin, $
                  NO_DEREFERENCE=no_dereference, $
                  NOSINGLE=nosingle, $
                  NOT_FOUND=NOT_found, $
                  OBJECT_REFERENCE=object_reference, $
                  PARAM_NAME=param_name, $
                  POINTER=pointer, $
                  SRC_INDEX=src_index, $
                  SOURCE_ONLY=source_only, $
                  THIS_CLASS_ONLY=this_class_only, $
;                  verbose = verbose, $
                  _EXTRA=_extra

;if keyword_set( debug ) then return, self.debug
;if keyword_set( verbose ) then return, self.verbose

IF Keyword_Set( CLASS_NAME ) THEN BEGIN

; acs 2004-09-09
    if not keyword_set( fc_get_id ) then begin
        fc_get_id = !fc_get_id
        !fc_get_id = !fc_get_id + 1
;        print, 'increasing fc-get_id to: ', !fc_get_id
    endif
    self.fc_get_id = fc_get_id

    this_object = framework_find_class( self, class_name, fc_get_id = fc_get_id )
    IF Obj_Valid( this_object ) THEN BEGIN
;        IF self.verbose GT 9 THEN BEGIN
;            Message, class_name + ' found', /INFO, /CONTINUE
;        ENDIF
        ; IF class_name EQ 'HSI_PACKET' THEN STOP
        IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
            RETURN, this_object
        ENDIF ELSE BEGIN
            RETURN, this_object->Get(  ADMIN_ONLY=admin_only, $
                                       CONTROL_ONLY=control_only, $
                                       POINTER=pointer, $
                                       SOURCE_ONLY=source_only, $
                                       THIS_CLASS_ONLY=this_class_only, $
                                       NOSINGLE=nosingle, $
                                       NOT_FOUND=NOT_found, $
                                       FOUND=found, $
                                       _EXTRA=_extra  )
        ENDELSE
    ENDIF ELSE IF self.debug GT 5 THEN BEGIN
        Message, class_name + ' not found', /INFO, /CONTINUE
    ENDIF
ENDIF ELSE IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
    RETURN, self
ENDIF

normal_run = Keyword_Set( _EXTRA ) OR $
    NOT( Keyword_Set( CLASS_NAME ) OR Keyword_Set( SOURCE_ONLY ) OR $
         Keyword_Set( OBJECT_REFERENCE ) OR Keyword_Set( ADMIN_ONLY ) )

IF normal_run THEN BEGIN

    if not keyword_set( this_class_only ) then begin
        if not keyword_set( fw_get_id )  then begin
;	print, '-----------------------------------changing fw_get_id'
;	print, 'new value: ', !fw_get_id + 1, self
            fw_get_id = !fw_get_id+1
            !fw_get_id = fw_get_id
            ;stop
        endif
        self.fw_get_id = fw_get_id
    endif

    NOT_found = ''
    IF Keyword_Set( _EXTRA ) THEN BEGIN
        this_param_name = Tag_Names( _EXTRA )
        n_param = N_Elements( this_param_name )
    ENDIF ELSE IF Keyword_Set( PARAM_NAME ) THEN BEGIN
        this_param_name = param_name
        n_param = N_Elements( this_param_name )
    ENDIF ELSE BEGIN
        this_param_name = ''
        n_param = 0
    ENDELSE

    IF Keyword_Set( CONTROL_ONLY ) THEN BEGIN
        object = self.control
    ENDIF ELSE IF Keyword_Set( INFO_ONLY ) THEN BEGIN
        object = self.info
    ENDIF ELSE BEGIN
        IF Keyword_set( NO_ADMIN ) THEN BEGIN
             object = [self.control, self.info ]
       ENDIF ELSE BEGIN
            object = [self.control, self.info, self.admin ]
        ENDELSE
    ENDELSE
    IF NOT Keyword_Set( THIS_CLASS_ONLY ) THEN BEGIN
        IF Keyword_Set( SRC_INDEX ) THEN BEGIN
            object = [ object, self.source[src_index] ]
        ENDIF ELSE BEGIN
            object = [ object, self.source ]
        ENDELSE
   ENDIF
    n_obj = N_Elements( object )

    CheckVar, nosingle, 0
    this_nosingle = nosingle OR n_param GT 1

;     stop
;    FOR i=0, n_obj-1 DO BEGIN
    FOR i= 0, n_obj-1 do begin

        this_obj = object[i]
        ; stop
        IF Obj_Valid( this_obj ) THEN BEGIN
            IF Obj_ISA( this_obj, 'FRAMEWORK' ) THEN BEGIN
                ;help, self, this_obj, self.fw_get_id, this_obj->getid(), this_class_only
                ;print,' '
                if this_obj->getid() ne self.fw_get_id and not keyword_set( this_class_only ) then begin
                    this_struct = this_obj->Get( _EXTRA=_extra, $
                                                 FOUND=this_found, $
                                                 CONTROL_ONLY=control_only, $
                                                 INFO_ONLY=info_only, $
                                                 NO_DEREFERENCE=no_dereference, $
                                                 /NOSINGLE, fw_get_id = fw_get_id)
                endif else begin
                    ;print, '------- already traveresed'
                    this_struct = -1
                    this_found = ''
                endelse
            ENDIF ELSE BEGIN
                this_struct = this_obj->Get( PARAM_NAME=this_param_name, $
                                             FOUND=this_found, $
                                             NOSINGLE=nosingle, $
                                             NO_DEREFERENCE=no_dereference )
            ENDELSE

            IF this_found[0] NE '' AND $
                N_Elements( this_found ) EQ n_param AND $
; this we should go here only if the params
                this_found[0] eq this_param_name[0] and $
                NOT exist(full_struct) THEN BEGIN ;kim added this test 9/23/03
                found = this_found


;print, '------'
;help, self
;print, found, keyword_set( nosingle )
;print, n_elements( found ), this_struct
;if obj_isa( self, 'HSI_IMAGE_RAW' ) then stop

                ; Changed AND to && Aug 12,2010 for Version 8.0
                IF NOT Keyword_Set( NOSINGLE ) && $
                    N_Elements( found ) EQ 1 && $
                    Size( this_struct, /TYPE ) EQ 8 && $
                    N_Tags( this_struct ) EQ 1 THEN BEGIN
                    IF this_found[0] EQ (Tag_Names(this_struct))[0] THEN BEGIN
                        RETURN, this_struct.(0)
                    ENDIF ELSE BEGIN
                        RETURN, this_struct
                    ENDELSE
                ENDIF ELSE BEGIN
                    RETURN, this_struct
                ENDELSE
            ENDIF ELSE BEGIN
                                ; now put them together if some found
                IF this_found[0] NE '' THEN BEGIN
; acs here we shoudl replace this with a creat_struct call
; we cannot do this now because we have to check for duplicate tags.
                    if exist( full_struct ) then begin
                        full_struct =join_struct( full_struct, this_struct )
                    endif else full_struct = this_struct
                    full_found=N_Elements( full_found ) GT 0 ? $
                        [full_found, this_found] : this_found
                ENDIF

            ENDELSE
        ENDIF
    ENDFOR

;print, '-------------'
;help, self, full_found, full_struct, /str

    found=N_Elements( full_found ) GT 0 ?  $
        full_found[ Uniq( full_found ) ] : ''

    IF found[0] EQ '' THEN BEGIN
        RETURN, -1
    ENDIF ELSE BEGIN
;       This change would return the single tag if there is only one and nosingle is not set,
;       instead of the structure.
;       Seemed like a good idea, but screws up get(/binning) so comment out for now. kim

; acs 2004-08-20 this is a problem for t_idx and e_idx which are interpreted
; as parameters although they are not

; acs 2005-05-10 this is again uncommented as it seems it works now for t_idx
; and e_idx, at least for what I have been testing
    	if not keyword_set(nosingle) and size(full_struct,/type) eq 8 then begin
    		if n_tags(full_struct) eq 1 then return, full_struct.(0)
    	endif
        RETURN, full_struct
    ENDELSE

ENDIF

;IF Keyword_Set( CLASS_NAME ) THEN BEGIN
;
;; acs 2004-09-09
;    if not keyword_set( fc_get_id ) then begin
;        fc_get_id = !fc_get_id
;        !fc_get_id = !fc_get_id + 1
;;        print, 'increasing fc-get_id to: ', !fc_get_id
;    endif
;    self.fc_get_id = fc_get_id
;
;    this_object = framework_find_class( self, class_name, fc_get_id = fc_get_id )
;    IF Obj_Valid( this_object ) THEN BEGIN
;;        IF self.verbose GT 9 THEN BEGIN
;;            Message, class_name + ' found', /INFO, /CONTINUE
;;        ENDIF
;        ; IF class_name EQ 'HSI_PACKET' THEN STOP
;        IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
;            RETURN, this_object
;        ENDIF ELSE BEGIN
;            RETURN, this_object->Get(  ADMIN_ONLY=admin_only, $
;                                       CONTROL_ONLY=control_only, $
;                                       POINTER=pointer, $
;                                       SOURCE_ONLY=source_only, $
;                                       THIS_CLASS_ONLY=this_class_only, $
;                                       NOSINGLE=nosingle, $
;                                       NOT_FOUND=NOT_found, $
;                                       FOUND=found, $
;                                       _EXTRA=_extra  )
;        ENDELSE
;    ENDIF ELSE IF self.debug GT 5 THEN BEGIN
;        Message, class_name + ' not found', /INFO, /CONTINUE
;    ENDIF
;ENDIF ELSE IF Keyword_Set( OBJECT_REFERENCE ) THEN BEGIN
;    RETURN, self
;ENDIF

IF Keyword_Set( SOURCE_ONLY ) THEN BEGIN
    CheckVar, src_index, 0
; acs correction for an idl 6 different implementation on how to deal
; with 1-element arrays
    if n_elements( src_index ) eq 1 then begin
        RETURN, (self.source[src_index])[0]
    endif else begin
        RETURN, self.source[src_index]
    endelse
ENDIF
IF Keyword_Set( ADMIN_ONLY ) THEN RETURN, self.admin

END

;---------------------------------------------------------------------------

function framework::get_fc_id

return, self.fc_get_id

end
;---------------------------------------------------------------------------

function framework::setid

return, self.fw_set_id

end

;---------------------------------------------------------------------------

pro framework::set_fc_id, fc_id

self.fc_get_id = fc_id

end

;---------------------------------------------------------------------------

FUNCTION Framework::Need_Update, $
                  CHECK_MAIN_SOURCE_ONLY = check_main_source_only, $
                  NO_LAST_UPDATE = no_last_update

; acs 2005-03-24 cut time by 30% by introducing framework::get instead of get
; acs 2005-04-11 back to the old version (without framework::) because it
;                broke a situation in spex.

; acs 2004-05-21 this could get the price for the most badly written procedure on earth.
; rewritten to make it get out as soon as it gets 1

IF self->Get( /NEED_UPDATE ) NE 0 then return, 1
;if NOT Ptr_Valid( self.data ) THEN begin
;    print, 'no valid data in ', self
;    return, 1
;endif

; acs 2004-08-01 new kwd to check the main source only. needed in
; spectrogram to avoid the srm to trigger reprocessing of the whole
; chain. the srm recomputes itself only wehn it is explicitely called.

if keyword_set( check_main_source_only ) then begin
    count = 1
    obj_valid_list = 0
endif else begin
    obj_valid_list = where( obj_valid( self.source ), count )
endelse

; acs 2005-04-11 need to take into acct that some are spex_gen_strategy_holder
no_strategy_holder = stregex( obj_class( self ), 'STRATEGY_HOLDER' ) EQ -1
;no_strategy_holder_old = NOT Obj_ISA( self, 'STRATEGY_HOLDER' )
checkvar, no_last_update, 0
;self_last_update = self->framework::Get( /LAST_UPDATE )
self_last_update = self->Get( /LAST_UPDATE )

for i=0, count-1 do begin

    this_obj = self.source[obj_valid_list[i]]

;    print, no_last_update, self, self_last_update, this_obj,  $
;           this_obj->get( /last_update ), this_obj->framework::get( /last_update ), $
;           this_obj->get( /need )
    if this_obj->need_update() then return, 1

    if no_strategy_holder and NOT no_last_update then begin
         ; andre added /this_class_only 9/12/05.  Kim took away 9/15/05
;        if self_last_update lt this_obj->get( /last_update, /this_class_only ) then begin
        if self_last_update lt this_obj->get( /last_update) then begin
            ;print, self, this_obj, self_last_update, this_obj->get( /last_update ),
            return, 1
        endif
    endif
endfor

; if we get here we dont need reprocessing
return, 0

END

;---------------------------------------------------------------------------

FUNCTION Framework::GetData, $
                  CLASS_NAME=class_name, $
                  DIMENSION=dimension, $
                  DONE=done, $
                  NOPROCESS=noprocess, $
                  PLOT=plot, $
                  POINTER=pointer, $
                  TAG_NAME=tag_name, $
                  _ref_EXTRA=_extra



IF Keyword_Set( CLASS_NAME ) THEN BEGIN
    this_object = framework_find_class( self, class_name )
    IF Obj_Valid( this_object ) THEN BEGIN
        RETURN, this_object->GetData( DIMENSION=dimension, $
                                      DONE=done, $
                                      POINTER=pointer, $
                                      TAG_NAME=tag_name, $
                                      _EXTRA=_extra )
    ENDIF ELSE BEGIN
        Message, 'This class ' + class_name + ' has not yet been instantiated.';, /CONTINUE
        RETURN, -1
    ENDELSE
ENDIF

force =  0
IF Keyword_Set( _EXTRA ) THEN BEGIN
    self->Set, _EXTRA = _extra
    dummy =  where( _extra eq 'FORCE', c )
    IF c ge 1 THEN force = 1
ENDIF

; this is the place where framework decides whether to call process or
; not. Process is part of the concrete class, and implements the
; algorithm-specific operations that need to be run.
; acs 2007-11-08 do not run need_update if noprocess is set.
IF NOT Keyword_Set( NOPROCESS ) or force then begin
	IF self->Need_Update() OR force THEN BEGIN
    		self->Process, _EXTRA = _extra, DONE=done
    		self.admin->Set, NEED_UPDATE = 0
	endif
ENDIF

IF Keyword_Set( PLOT ) THEN self->Plot, _EXTRA = _extra

IF Keyword_Set( DIMENSION ) THEN BEGIN
    RETURN, Size( *self.data, /DIMENSION )
ENDIF

IF NOT Ptr_Valid( self.data ) THEN BEGIN
    Message, 'No primary data available in the object ' + $
             Obj_Class( self ), /CONTINUE
    RETURN, -1
ENDIF



IF Keyword_Set( POINTER ) THEN BEGIN
    RETURN, self.data
ENDIF ELSE BEGIN
    IF NOT Keyword_Set( TAG_NAME ) THEN BEGIN
        RETURN, *self.data
    ENDIF ELSE BEGIN
        IF N_Elements( tag_name ) EQ 1 THEN BEGIN
            RETURN, (Str_Subset( *self.data, Strupcase( tag_name ))).(0)
        ENDIF ELSE BEGIN
            RETURN, Str_Subset( *self.data, Strupcase( tag_name ))
        ENDELSE
    ENDELSE
ENDELSE

END

;---------------------------------------------------------------------------

PRO Framework::SetData, data, $
             NO_LAST_UPDATE=no_last_update, $
             RESET=reset, $
             _EXTRA=_extra


IF Keyword_Set( _EXTRA ) THEN self->Set, _EXTRA = _extra

size_info = Size( data, /struct )
IF size_info.type EQ 10 AND size_info.n_dimensions EQ 0 THEN BEGIN
    IF NOT Ptr_Valid( data )  THEN BEGIN
; ptr_free leaves a bunch of things in data. So we have to try with
; free_var. This is dangerous though. we'll see what happens.
;        Ptr_Free, self.data
        Free_Var, self.data
        self.data = Ptr_New( data )
    ENDIF ELSE BEGIN
        self.data = data
    ENDELSE
ENDIF ELSE BEGIN
    Ptr_Free, self.data    ; this is a memory leak for some classes
    ;heap_free, self.data  ;undid this change 2-oct-09,kim
;if obj_class( self ) eq 'HSI_VISIBILITY' then stop
; free_var doesnt work on macs. got a case where the pointer assigned
; just after got invalidated. let's hope that ptr_free works
; after so many years.  
; acs 2008-07-18
;    Free_Var, self.data
    IF NOT Keyword_Set( RESET ) THEN BEGIN
        self.data = Ptr_New( data )
;        if not ptr_valid( self.data ) then stop
    ENDIF;
;if obj_class( self ) eq 'HSI_VISIBILITY' then stop
ENDELSE

if not keyword_set( no_last_update ) then begin
; acs 2004-05-20 replace this
;self.admin->Set, LAST_UPDATE = systime(0, /SECONDS)
; with the specially defined counter to make sure it works on fast machines
; too
    self->set_last_update

endif

END

;---------------------------------------------------------------------------

pro framework::set_last_update
    self.admin->set, last_update = !hsi_last_update_counter
    !hsi_last_update_counter = !hsi_last_update_counter + 1
end

;---------------------------------------------------------------------------

PRO Framework::Print, _EXTRA = _extra, XSTRUCT=xstruct

IF NOT Keyword_Set( XSTRUCT ) THEN BEGIN
    IF Float( !version.release ) LE 5.2 THEN BEGIN
        Help, self->Get( _EXTRA=_EXTRA, /NOSINGLE ), /STRUCT
    ENDIF ELSE BEGIN
        Help, self->Get( _EXTRA=_EXTRA, /NOSINGLE ), /STRUCT, /BRIEF
    ENDELSE
ENDIF ELSE BEGIN
    XStruct, self->Get( _EXTRA=_EXTRA, /NOSINGLE )
ENDELSE

END

;---------------------------------------------------------------------------

PRO Framework::NewSet,  $
             ADMIN_STRUCT=admin_struct, $
             CONTROL_STRUCT=control_struct, $
             INFO_STRUCT=info_struct, $
             SRC_INDEX=src_index, $
             SOURCE_OBJ=source_obj, $
             THIS_CLASS_ONLY=this_class_only, $
             DONE=done, $
             NOT_found=NOT_found, $
             _EXTRA=_extra

;------
; Check for the framework administration commands:
;------

IF Keyword_Set( CONTROL_STRUCT ) THEN BEGIN
    self.control = Obj_New( 'Structure_Manager', control_struct )
    IF Obj_Valid( self.admin ) THEN self.admin->Set, /NEED_UPDATE
ENDIF

IF Keyword_Set( INFO_STRUCT ) THEN BEGIN
    self.info = Obj_New( 'Structure_Manager', info_struct  )
ENDIF

IF Keyword_Set( ADMIN_STRUCT ) THEN BEGIN
    IF DataType( admin_struct ) NE 'STC' THEN BEGIN
        admin_struct =  {admin_control}
    ENDIF
    self.admin = Obj_New( 'Structure_Manager', admin_struct )
    self.admin->Set, /NEED_UPDATE
ENDIF

IF Keyword_Set( SOURCE_OBJ ) THEN BEGIN
    CheckVar, src_index, 0
    self.source[src_index] = source_obj
    IF NOT Obj_Valid( self.admin ) THEN BEGIN
        admin = source_obj->Get( /ADMIN_ONLY )
        IF Obj_Valid( admin ) THEN self.admin = admin
    ENDIF
ENDIF

IF Keyword_Set( _EXTRA ) THEN BEGIN

    IF Keyword_Set( THIS_CLASS_ONLY ) THEN BEGIN
        object = [self.control, self.info, self.admin]
    ENDIF ELSE BEGIN
        object = [self.control, self.info, self.admin, self.source ]
    ENDELSE

    n_tag = N_Tags( _extra )
    n_obj = N_Elements( object )
    i = 0

    REPEAT BEGIN
        this_object = object[i]
        IF Obj_Valid( this_object ) THEN BEGIN
            this_object->Set, _EXTRA = _extra, DONE=this_done, $
                NOT_found=this_NOT_found
            IF i EQ 0 THEN IF Total( this_done ) NE 0 THEN BEGIN
                self.admin->Set, /NEED_UPDATE
            ENDIF
            n_tag = Total( NOT_found )
            IF n_tag NE 0 AND n_tag NE N_Tags( _EXTRA ) THEN BEGIN
                _EXTRA = Str_Subset( _extra, NOT_found )
            ENDIF
            i =  i+1
        ENDIF
    END UNTIL n_tag EQ 0 OR i EQ n_obj

    IF n_tag NE 0 THEN BEGIN
        Message, 'Parameters ' + NOT_found + ' NOT found ', /INFO
    ENDIF

ENDIF

END

;---------------------------------------------------------------------------

;pro framework::disableset

;self.do_not_set = 1b
;
;end

;---------------------------------------------------------------------------

;pro framework::enableset

;self.do_not_set = 0B

;end

;---------------------------------------------------------------------------

PRO Framework::Set,  $
             ADMIN_STRUCT=admin_struct, $
             CONTROL_STRUCT=control_struct, $
;             DEBUG=debug, VERBOSE = verbose, $
             ONLY_INFO=only_info, $
             INFO_STRUCT=info_struct, $
             DELETE_OLD_SOURCE=keep_old_source, $
             NO_UPDATE=no_update, $
             SRC_INDEX=src_index, $
             SOURCE_OBJ=source_obj, $
             THIS_CLASS_ONLY=this_class_only, $
             DONE=done, $
             NOT_found=NOT_found, $
               FW_SET_ID=fw_set_id, $
    current_strat_only = current_strat_only, $
             _EXTRA=_extra

;acs 2007-11-22
;if self.do_not_set then return

; do the error handling

err_nr=0
if self.debug eq 0 then catch, err_nr
;catch, err_nr
if err_nr ne 0 then begin
    catch, /cancel
    message, !error_state.msg + 'Cannot set values.',/info
    done = 0
    if keyword_set( _extra ) then not_found = tag_names( _extra )
    return
endif

;------
; Check for the framework administration commands:
;------

;print, self, no_update


IF Keyword_Set( CONTROL_STRUCT ) THEN BEGIN
    free_var, self.control
    self.control = Obj_New( 'Structure_Manager', control_struct )
    IF Obj_Valid( self.admin ) THEN self.admin->Set, /NEED_UPDATE
ENDIF

IF Keyword_Set( INFO_STRUCT ) THEN BEGIN
    free_var, self.info
    self.info = Obj_New( 'Structure_Manager', info_struct  )
ENDIF

IF Keyword_Set( ADMIN_STRUCT ) THEN BEGIN
    IF DataType( admin_struct ) NE 'STC' THEN BEGIN
        admin_struct =  {admin_control}
    ENDIF
    free_var, self.admin
    self.admin = Obj_New( 'Structure_Manager', admin_struct )
    self.admin->Set, /NEED_UPDATE
ENDIF

;IF N_Elements( DEBUG ) ne 0 THEN BEGIN
;    self.debug =  debug
;    self.admin->Set, DEBUG = debug
;ENDIF
;IF N_Elements( VERBOSE ) ne 0 THEN BEGIN
;    self.verbose =  verbose
;    self.admin->Set, VERBOSE = verbose
;ENDIF

IF Keyword_Set( SOURCE_OBJ ) THEN BEGIN
    CheckVar, src_index, 0
                                ; this test is to avoid a memory
                                ; leakges. When we assign a new
                                ; object we shoudl know wheter to keep
                                ; the old one or discard it
    IF Keyword_Set( DELETE_OLD_SOURCE ) AND Obj_Valid( self.source[src_index] ) THEN BEGIN
        ; stop
        Obj_destroy, self.source[src_index], /THIS_CLASS_ONLY
    END
    self.source[src_index] = source_obj
    IF NOT Obj_Valid( self.admin ) THEN BEGIN
        admin = source_obj->Get( /ADMIN_ONLY )
        IF Obj_Valid( admin ) THEN self.admin = admin
    ENDIF
ENDIF

;nupdt = self->need_update()
;print, nupdt, self

IF Keyword_Set( _EXTRA ) THEN BEGIN

    if not is_number( fw_set_id )  then begin
;	print, '-----------------------------------changing fw_get_id'
;	print, 'new value: ', !fw_get_id + 1, self
        fw_set_id = !fw_set_id+1
        !fw_set_id = fw_set_id
                                ;stop
    endif
    self.fw_set_id = fw_set_id

if chktag( _extra, 'VERBOSE' ) then self.verbose = _extra.verbose

    IF Keyword_Set( THIS_CLASS_ONLY ) THEN BEGIN

        IF Keyword_Set( ONLY_INFO ) THEN BEGIN
            object = self.info
        ENDIF ELSE BEGIN
            object = [self.control, self.info, self.admin]
        ENDELSE
;stop
    ENDIF ELSE BEGIN

        object = [self.control, self.info, self.admin, self.source   ]

    ENDELSE

    n_tag = N_Tags( _extra )

    FOR i=0, N_Elements( object )-1  DO BEGIN
        this_object = object[i]

        if obj_valid( this_object ) then begin
;print, this_object

           if obj_isa( this_object, 'FRAMEWORK' ) then begin
               if this_object->setid() eq fw_set_id then begin
                   ;print, '------------------------------ ' + $
                          ;obj_class( this_object ) + 'is already traversed'
                   CONTINUE
               endif ;else print, 'traversing ' + obj_class( this_object ), fw_set_id, $
                           ;      n_tag, tag_names( _extra )
           endif

 ; this we have to put because hsi_eventlist has no source. In tha case
; we do not want to set the this_class_only keyword.
; There is one situation more, when one of the source is a
; strategy_holder itself. In that case, we also dont want to set the
; this class only keyword, because it needs to go on elevel
; deeper. This is the case for hsi_bproj, which is a strategy_holder
; WE TURN THIS OFF FOR NOW.
; shoudl now be unneeded because of the introduction of fw_set_id
;            IF 0 THEN BEGIN
;            IF i GT 3 and not self.do_all_classes and obj_class(self) ne 'HSI_IMAGE_SINGLE' THEN BEGIN
;                IF self.isa_strat_holder AND $
;            if stregex( obj_class( self ), 'STRATEGY_HOLDER' ) ne -1 and $ ; acs 2005-04-11
;                    OBJ_VALID( self.source[0] ) AND $
;                      NOT Obj_Isa( this_object, 'STRATEGY_HOLDER_TOOLS' ) THEN BEGIN
;                NOT stregex( obj_class( this_object ), 'STRATEGY_HOLDER' ) eq -1 THEN BEGIN
;                        this_class_only = 1
;                        help,self
;                        help,this_object
;                        help,_extra,/st
;                ENDIF
;            ENDIF

;        IF Obj_Class( self ) EQ 'HSI_IMAGE_SINGLE' then stop
;        IF Obj_Valid( this_object ) THEN BEGIN

            this_object->Set, _EXTRA = _extra, DONE=this_done, $
              NOT_found=this_NOT_found, $
              NO_UPDATE=no_update, THIS_CLASS_ONLY=this_class_only, $
              fw_set_id = fw_set_id
                                ;we set need_update only for control params
                                ;
            IF i EQ 0 AND NOT keyword_Set( NO_UPDATE ) THEN IF Total( this_done ) NE 0 THEN BEGIN
;stop
                self.admin->Set, /NEED_UPDATE
            ENDIF
            ;IF OBJ_CLASS( SELF ) EQ 'HSI_PACKET' and self->need_update() eq 1 and nupdt eq 0 THEN STOP
            ; print, this_NOT_found
            done=N_Elements( done ) ? [done, this_done] : this_done
            NOT_found=N_Elements( NOT_found )? $
              [ NOT_found, this_NOT_found ]:this_NOT_found
        ENDIF
    ENDFOR

    done = done[ Uniq( done ) ]
    NOT_found = NOT_found[ Uniq( NOT_found ) ]
                                ; print, obj_class( self ), NOT_found
    ; stop

ENDIF

END

;---------------------------------------------------------------------------

PRO Framework__define

; we are moving some of the admin stuff to the main level for efficiency and for
; simplifying, so they must coexist for a while, eventually we'll get rid if
; the admin object

self = {Framework, $
        debug: 0B, verbose: 0B, $
        progress_bar: 0b, $
        do_all_classes: 0B, $
; this is to control the case where we have a file-based class such as
; hsi_visibility_file__define, and we are not allowed to reprocess
; (controlled in the case of visibilites, by the parameter vis_allow_reprocess).
;        do_not_set: 0B, $
        admin:    Obj_New(), $
        control:  Obj_New(), $
        info: 	  Obj_New(), $
        source:   ObjArr(30), $
        data:     Ptr_New(), $
        fw_get_id: 0L, $
        fw_set_id: 0L, $
        fc_get_id: 0L, $
        isa_strat_holder: 0B}

END


;---------------------------------------------------------------------------
; End of 'hsi_framework__define.pro'.
;---------------------------------------------------------------------------
