;---------------------------------------------------------------------------
; Document name: framework_template__define.pro
; Created by:    Andre Csillaghy, March 4, 1999
;
; Last Modified: Mon Apr 23 14:19:32 2001 (csillag@soleil)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       HESSI FRAMEWORK TEMPLATE CLASS
;
; PURPOSE: 
;      
;       (*
;       THIS IS NOT RUNNING CODE
;       Use this framework to create your own object classes. Replace
;       all occurences of framework_template with your own class name,
;       delete the comments that are bewteen (* *), and fill up the
;       blanks.
;
;       More detailed instructions are in 
;       http://hessi.ssl.berkeley.edu/software/hessi_oo_concept.html
;       *)
;
; CATEGORY:
;       Objects
; 
; CONTRUCTION:
;       o = Obj_New( 'framework_template' )
;       or
;       o = Framework_Template( ) 
;
; INPUT (CONTROL) PARAMETERS:
;       Defined in {framework_template_control}
;
; SEE ALSO:
;       framework_template_control__define
;       framework_template_control
;       framework_template_info__define
;
; HISTORY:
;       Development for Release 5.1 January-March 2001
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;


;--------------------------------------------------------------------

FUNCTION Framework_Template::INIT, SOURCE = source, _EXTRA=_extra

; (* 
; This is the standard call that passes the control and info parameters to
; the framework. You must also change the code of
; framework_template_control__define.pro,
; framework_template_control.pro, and framework_template_info__define.pro
; *)

;(*
; The following IF block checks for a source object. If you have a
; source object for this class, then you should replace
; framework_template_source by its name. If you dont have a source
; object you should comment out the whole block.
; *)
IF NOT Obj_Valid( source ) THEN BEGIN 
    source =  obj_new( 'framework_template_source' )
ENDIF 

;(* 
; Here we pass the control and info parameters to the framework, and,
; optionally, the source object.
;*)
RET=self->Framework::INIT( CONTROL = framework_template_control(), $
                           INFO={framework_template_info}, $
                           SOURCE=source, $
                           _EXTRA=_extra )
;(* 
; here you may include all operations that may be necessary at initialization.
; *)

RETURN, RET

END

;--------------------------------------------------------------------

;(*
; In the declaration of the Process method, you can declare keywords
; that can be passed at run-time without involving the Set
; method. This is not really recomended, however, so usually you may
; want to just erase KEYWORD1 and KEYWORD2. If you really want to use
; them, however, replace their names by whatever names are needed.
; *)

PRO Framework_Template::Process, $
             KEYWORD1=keyword1, $
             KEYWORD2=keyword2, $
             _EXTRA=_extra

; (*
; First, get the value of any parameters that must be passed to the
; algorithm. Here you should replace param1, param2 by the name of the
; parameters needed by your algorithm
; *)

param1 = self->Get( /PARAM1 )
param2 = self->Get( /PARAM2 )
...

;(* 
; Second, get the object reference of the source data ant get whatever
; data is needed. Of course this does not necessarily involve a source
; object. It could be e.g. a call to a file read procedure
; *)

source = self->Get( /SOURCE )
data = source->GetData( )


; (*
; Third, call the algorithm, with all parameters --- also the
; keyword parameters.
; The algorithm could also use the source or the self references
; such that any of the functionality of the source object could be
; available in the algorithm.
; *)

Framework_Template, source, param1, param2, out_data, $
    out_param1, out_param2, $
    KEYWORD1=keyword1, KEYWORD2=keyword2, $
    _EXTRA=_extra

; (* 
; Fourth, store the outputs of the algorithm into variables,
; the primary data...
; *)

self->SetData, output

;(*
; ... then the information parameters 
; *)

self->Set, OUT_PARAM1 = out_param1
self->Set, OUT_PARAM2 = out_param2

END

;--------------------------------------------------------------------

; (*
; This is optional. You may want to extend the functionality of the
; predefined GetData method in order to access subsets of the full
; data set. If you want this, then replace the keywords THIS_SUBSET1
; and THIS_SUBSET2 by whatever you need, and add any necessary
; keywords with THIS_ prepended.
; *)

FUNCTION Framework_Template::GetData, $
                  THIS_SUBSET1=this_subset1, $
                  THIS_SUBSET2=this_subset2, $
                  _EXTRA=_extra

; first we call the predefined GetData in Framework:

data=self->Framework::GetData( _EXTRA = _extra )

; (*
; then we select whatever is needed from THIS_SUBSET1. Here you need
; to adapt the code such that it is consistent with the data structure
; stored in the object. The procedures Some_selection and
; Some_More_Selection may be replaced by a direct selection
; such as indexing.
; *)

IF Keyword_Set( THIS_SUBSET1 ) THEN BEGIN 
    data = Some_Selection( data, this_subset1 )
ENDIF 
IF Keyword_Set( THIS_SUBSET2 ) THEN BEGIN 
    data = Some_More_Selection( data, this_subset2 )
ENDIF 

RETURN, data

END 

;--------------------------------------------------------------------

; (* 
; This shows how to configure the Set procedure. In general, you don't
; need this and you can just get rid of it, i.e. use the default Set
; procedure in Framework. However, in some cases you need to take some
; action before setting a parameter. In this case this is the place to
; put these actions. 
; *)

PRO Framework_Template::Set, $
       PARAMETER=parameter, $
       _EXTRA=_extra

; (*
; let's say parameter is the parameter that will generate some action
; to be done.
; *)

IF Keyword_Set( PARAMETER ) THEN BEGIN
    
    ; first set the parameter using the original Set
    self->Framework::Set, PARAMETER = parameter
    
    ; then take some action that depends on this parameter
    Take_Some_Action, parameter
    
ENDIF 

; for all other parameters (included in _extra), just pass them to the
; original Set procedure in Framework

IF Keyword_Set( _EXTRA ) THEN BEGIN
    self->Framework::Set, _EXTRA = _extra
ENDIF

END

;---------------------------------------------------------------------------

;(*  
; This shows how to configure the Get function.
; The Get function needs to be modified only in very special cases, 
; e.g. if you need to modify a value before passing in back to the
; user.  This is not recommended, however. In any case, you should add two
; keyword variables NOT_FOUND and FOUND that must be passed to the Get 
; function in Framework. It is important that self->Framework::Get(...
; ) is called (see end of the routine) such that it can search for
; further parameters in other classes.
; *)

FUNCTION Framework_Template::Get, $
                  NOT_FOUND=NOT_found, $
                  FOUND=found, $
                  PARAMETER=parameter, $
                  _EXTRA=_extra 

; not_found and found are needed by Framework::Get() to pass parameters
; back

;(*
; you should change PARAMETER to whatever your paraneter name is
; *)

IF Keyword_Set( PARAMETER ) THEN BEGIN
    parameter_local=self->Framework::Get( /PARAMETER )
    ; (*
    ; here do whatever needs to be done with parameter as a control
    ; *)
    Do_Something_With_Parameter, parameter_local
ENDIF 

; here pass the control back to the original Get function. Dont forget
; to have NOT_FOUND and FOUND passed to the Get function
RETURN, self->Framework::Get( PARAMETER = parameter, $
                              NOT_FOUND=not_found, $
                              FOUND=found, _EXTRA=_extra )
END

;---------------------------------------------------------------------------
   
PRO Framework_Template__Define

self = {Framework_Template, $
        INHERITS Framework }

END


;---------------------------------------------------------------------------
; End of 'framework_template__define.pro'.
;---------------------------------------------------------------------------
