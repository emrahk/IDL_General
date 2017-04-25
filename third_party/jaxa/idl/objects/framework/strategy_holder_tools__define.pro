;---------------------------------------------------------------------------
; Document name: strategy_holder_tools__define
; Created by:    Andre Csillaghy, May 1999
; Last Modified: Wed Mar 19 16:26:31 2003 (csillag@soleil.cs.fh-aargau.ch)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       STRATEGY HOLDER TOOLS ABSTRACT CLASS
;
; PURPOSE:
;       This class provides a generic mechanism for putting
;       together several related classes. The strategy holder allows
;       selecting from several objects which one should be used by the
;       GetData mehod.
;
;       The strategy holder class usually holds multiple implementations of a
;       specifc base class of framework object, called startegies. For instance the
;       hsi_image class is a strategy holder that contains objects
;       implementing the hsi_image_alg class, where each specific
;       implementation of the hsi_image_alg class is a specific image
;       algorithm.
;
;       The strategy holder can be considered as the Context in the
;       strategy design pattern, but it holds multiple instances of
;       the strategies, so I guess it's not only a Context.
;
; CATEGORY:
;       Objects
;
; CONSTRUCTION:
;       This class is abstract, i.e. it needs to be implemented
;       (inherited) by a concrete class
;
; INHERITANCE:
;       Framework
;
; KNOWN DIRECT SUBCLASSES:
;       HSI_Eventlist
;       HSI_Modul_Pattern
;       HSI_Modul_Profile
;       HSI_Bproj
;       HSI_Image
;
; FIELDS:
;       strategy_available: (Ptr to string arr) lists all strategies
;                           (objects) registered at initialization
;                           time for the specific instance
;       strategy_current: (Int) specifies the currently selected
;                         strategy. index to strategy_available
;       strategy_altenate_source: (Ptr to string) specifies the alternate source for
;                                 one or more strategies. Usually this
;                                 is empty and the source is the same
;                                 as the source of the strategy holder
;                                 itself.
;       get_all_strartegies: if set to 1 at implementation, then a
;                            call to Get() will check for parameters
;                            in each instantiated classes. If set to 0
;                            (default) then the call to Get checks for
;                            parameters only in the current class.
; FIELDS INHERITED:
;       From Framework:
;
; METHODS:
;       INIT( strategy_available [, strategy_alternate_source ] ): the
;            startegy_available parameter is required to initialize
;            the object. It is defined in the concrete
;            class. strategy_alternate_source is an optional array
;            of object references, with the same number of elements
;            than strategy_available, that can be used for specifying
;            other sources than the default (common and unique) source
;       CLEANUP: cleans up the strategy fields before cleaning up the Framework
;       CreateStrategy(idx): creates (instanciates) the strategy with
;                            index idx in the  list strategy_available
;                            passed to the strategy holder at initialization
;       GetStrategy([idx]): without the index, returns the object
;                           reference of the current strategy. With
;                           the index idc, returns the object
;                           reference of the strategy with inde xidx
;                           in the list strategy_available passed to
;                           the holder at initialization. Side effect:
;                           if the requested strategy is NOT
;                           instanciated, it will be first created
;       Get(): As with Framework, this is used to get control and info parameter
;            values. However, here we deal with several classes, this
;            som additional functionality must be available
;       Need_Update(): returns the value of the need_upate function of
;                      the current strategy. Note: the need_update
;                                                  flag of
;                                                  the strategy hoder
;                                                  is unused.
;       GetData(): returns the data of the current strategy. By using
;                  the CLASS_NAME keyword, the data from other
;                  strategies can alsos be accessed (pretty much in the
;                  same way as for the frameworks)
;       SetStrategy, stategy: Sets the current strategy to
;                             strategy. If strategy is a string then
;                             it is considered as a class
;                             name. Itherwise it is considered as an index.
;
; KEYWORDS:
;       ALL_STRATEGIES (Get): If set, the Get() function will check
;                             for parameters in all instatiated
;                             classes of the strategy
;                             holder, even if the get_all_startegies
;                             flag is not used.
;       CLASS_NAME (GetData): Allows to get data from another class
;                             than the current class.
;       STRATEGY_INDEX: (GetStrategy) If set, GetStrategy returns the
;                       index of the current strategy instead of the
;                       strategy itself
;       STRATEGY_NAME: (GetStrategy) If set, GetStrategy returns the
;                      strategy with nanme strategy_name,
; SEE ALSO:
;       http://hessi.ssl.berkeley.edu/software/reference.html
;
; HISTORY:
;        2007-aug-07, Kim changed hsi_insert_catch to framework_insert_catch
;        2004-09-01- added fw_get_id mechanism. See framework__define
;                    for more information on that.
;        First version for Release 6, April 2001
;           Andre Csillaghy, csillag@ssl.berkeley.edu
;
;----------------------------------------------------------

FUNCTION Strategy_Holder_Tools::INIT, strategy_available, strategy_alternate_source, $
                 _EXTRA=_extra

; we tell the holder which strategies (i.e. which list of objects) it will
; have to manage
self.strategy_available = Ptr_New( strategy_available )
IF N_Elements( strategy_alternate_source ) NE 0 THEN BEGIN
    self.strategy_alternate_source = Ptr_New( strategy_alternate_source )
ENDIF

RETURN, self->Framework::INIT(_EXTRA = _extra )

END

;----------------------------------------------------------

PRO Strategy_Holder_Tools::Cleanup

; delete the internal pointer vars
Ptr_Free, self.strategy_available
Ptr_Free, self.strategy_alternate_source
self->Framework::CLEANUP

END

;----------------------------------------------------------

FUNCTION Strategy_Holder_Tools::CreateStrategy, idx

; look for an alternate source. This is used in case the source of the
; startegy is not the default source self.source[0]
IF Ptr_Valid( self.strategy_alternate_source ) THEN BEGIN
    source_name = (*self.strategy_alternate_source)[idx]
    IF source_name[0] NE '' THEN BEGIN
;        source = self->GetStrategy( STRATEGY_NAME=source_name )
        source = self->get( class = source_name, /obj )
;        IF NOT Obj_Valid( source ) THEN source =  self->CreateStrategy( source_name )
    ENDIF ELSE BEGIN
        source = self->Framework::Get( /SOURCE )
    ENDELSE
ENDIF ELSE BEGIN
    source = self->Framework::Get( /SOURCE )
ENDELSE

strategy = Obj_New( ((*self.strategy_available)[idx])[0], SOURCE=source )
IF self.debug GE 5 THEN BEGIN
    print, '*************************   creating ', ((*self.strategy_available)[idx])[0]
ENDIF

self->Framework::Set, SOURCE = strategy, SRC_INDEX=idx+1, /DELETE_OLD_SOURCE

RETURN, strategy

END

;---------------------------------------------------------

FUNCTION Strategy_Holder_Tools::GetStrategy, idx, $
                 NO_COMPLAIN=no_complain, $
                 STRATEGY_NAME=strategy_name, $
                 STRATEGY_INDEX=strategy_index

; the subtility here is that the index defines the current strategy, not the
; object. Therefore the object creation can be delayed as much as possible
; (and may be never done).

IF Keyword_Set( STRATEGY_NAME ) THEN BEGIN
    idx = Where( *self.strategy_available EQ Strupcase( strategy_name ), count )
    IF count EQ 0 THEN BEGIN
        IF NOT Keyword_Set( NO_COMPLAIN ) THEN BEGIN
            Message, 'This strategy is unavailable: ' + strategy_name, /CONTINUE
        ENDIF
        RETURN, -1
    ENDIF
ENDIF ELSE BEGIN
    CheckVar, idx, self.strategy_current
ENDELSE

strategy=self->Strategy_Holder_Tools::Get( /SOURCE, SRC_INDEX = idx+1 )
IF NOT Obj_Valid( strategy ) THEN strategy = self->CreateStrategy( idx )

IF Keyword_Set( STRATEGY_INDEX ) THEN BEGIN
    RETURN, idx
ENDIF ELSE BEGIN
    RETURN, strategy
ENDELSE

END

;----------------------------------------------------------

FUNCTION Strategy_Holder_Tools::Get, $
                 ALL_STRATEGIES=all_strategies, $
                 CLASS_NAME=class_name, $
                 FOUND=found, $
                 NOT_FOUND=NOT_found, $
                 OBJECT_REFERENCE=object_reference, $
                 SOURCE=source, $
    fw_get_id = fw_get_id, $
                 _EXTRA=_extra

@framework_insert_catch

IF Keyword_Set( CLASS_NAME ) THEN BEGIN
    IF Is_Member( class_name, *self.strategy_available, /IGNORE_CASE ) THEN BEGIN
        this_strat = self->GetStrategy( STRATEGY_NAME=class_name )
        IF Keyword_Set( OBJECT_REFERENCE ) THEN RETURN, this_strat
        RETURN, this_strat->Get( _EXTRA=_extra, $$
                                 FOUND=found, NOT_FOUND=NOT_found, $
                                 fw_get_id = fw_get_id)
    ENDIF ELSE BEGIN
        strategy_idx = -1
    ENDELSE
ENDIF ELSE IF Keyword_Set( SOURCE ) THEN BEGIN
; in this case we pass directly to framework, otherwise we cannot
; proceed, because this get called in getstrategy
    RETURN, self->Framework::Get( SOURCE = source, _EXTRA=_extra, fw_get_id = fw_get_id )
ENDIF

IF Keyword_Set( ALL_STRATEGIES ) OR self.get_all_strategies THEN BEGIN
; make sure the strategy is actually present. this is at this point
; that the strategy holder needs to create its strategy if it is not
; present.
    RETURN, self->Framework::Get( CLASS_NAME = class_name, $
                                  OBJECT_REFERENCE=object_reference, $
                                  FOUND=found, NOT_FOUND=NOT_found, $
                                  /NO_ADMIN, fw_get_id = fw_get_id, $
                                  _EXTRA=_extra )
ENDIF ELSE BEGIN
; we want the parameters only for the current strategy.
    strategy_idx = self->GetStrategy( /STRATEGY_INDEX )
    RETURN, self->Framework::Get( SRC_INDEX = strategy_idx + 1, $
                                  CLASS_NAME=class_name, $
                                  OBJECT_REFERENCE=object_reference, $
                                  /NO_ADMIN, fw_get_id = fw_get_id, $
                                  FOUND=found, NOT_FOUND=NOT_found, $
                                  _EXTRA=_extra )
ENDELSE

END

;----------------------------------------------------------

FUNCTION Strategy_Holder_Tools::Need_Update, _EXTRA = _extra

; we need to redefine need_update, because it needs to be passed to the
; strategy class

this_strat = self->GetStrategy( _EXTRA=_extra )
RETURN, this_strat->Need_Update()

END

;----------------------------------------------------------

function strategy_holder_tools::getaxis, $
                        _extra=_extra

; acs this broke the getaxis( /energy ) as it was trying to set energy binning to 1 in binned eventlist
; 2003-08-01
;if keyword_set(_extra) then self -> set, _extra=_extra

this_strat = self->getstrategy()
axis = this_strat->getaxis( _extra = _extra )
return, axis

end

;----------------------------------------------------------

FUNCTION Strategy_Holder_Tools::GetData, $
                 CLASS_NAME=class_name, $
                 DONE=done, $
                 _ref_EXTRA=_extra

@framework_insert_catch

; this function overwrites the GetData from Framework. One crucial thig here
; is that it does not call any Process procedure, but rather passes the
; control to one of the strategies.

IF Keyword_Set( _EXTRA ) THEN self->Set, _EXTRA = _extra

IF Keyword_Set( CLASS_NAME ) THEN BEGIN
    IF class_name NE Obj_Class( self ) AND $
        NOT Is_Member( class_name, *self.strategy_available, /IGNORE_CASE ) THEN BEGIN
        RETURN, self->Framework::GetData( _EXTRA = _extra, $
                                          CLASS_NAME=class_name, $
                                          DONE=done )
    ENDIF ELSE BEGIN
        this_strat = self->GetStrategy( STRATEGY_NAME=class_name )
        RETURN, this_strat->GetData( _EXTRA=_extra )
    ENDELSE
ENDIF ELSE BEGIN
    this_strat=self->GetStrategy()
ENDELSE

;IF self.debug GT 8 THEN BEGIN
;    help, this_strat
;ENDIF

; IF Obj_Class( this_strat ) EQ 'HSI_BPROJ_ANNSEC' THEN STOP
RETURN, this_strat->GetData( _EXTRA=_extra, CLASS_NAME=class_name, DONE=done )

END

;----------------------------------------------------------

PRO Strategy_Holder_Tools::SetStrategy, strategy

; strategy can be set either by name or diretly by index
IF Size( strategy, /TYPE ) EQ 7 THEN BEGIN
    idx = self->Strategy_Holder_Tools::GetStrategy( STRATEGY_NAME=strategy, /STRATEGY_INDEX )
ENDIF ELSE BEGIN
    idx =  strategy
ENDELSE

self.strategy_current = idx
dummy =  self->Strategy_Holder_Tools::GetStrategy( idx )

END

;----------------------------------------------------------

PRO Strategy_Holder_Tools__define

dummy = {Strategy_Holder_Tools, $
         get_all_strategies: 0B, $
         strategy_available: Ptr_New(), $
         strategy_current: 0, $
         strategy_alternate_source: Ptr_New() }
END


;---------------------------------------------------------------------------
; End of 'strategy_holder_tools__define.pro'.
;---------------------------------------------------------------------------
