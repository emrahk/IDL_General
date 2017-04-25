;---------------------------------------------------------------------------
; Document name: selection_manager__define.pro
; Created by:    Andre Csillaghy, October 1999
;
; Last Modified: Wed Nov 13 12:19:01 2002 (csillag@hercules)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       SELECTION MANAGER ABSTRACT CLASS
;
; PURPOSE: 
;       Provides a selection manager in additon to the basic framework.
;
; CATEGORY:
;       Object
;; 
; CONSTRUCTION: 
;       Only through concrete classes 
;
; PUBLIC METHODS:
;      Compute: performs the operations required to put the object in
;               a consistent state. (Do nothing in this class)
;      Get(): accessor method to retrieve specific object parameter values
;      Set: accessor method to assign specific object parameter values
;      Print: prints all object parameters
;      Plot: in this class, do nothing
;      Need_Update(): tells if the procedure "Compute" must be called
;                     for the current class.
;      Update_Done, term: takes the term "term" out of the list in
;                         need_update. 
;
; INPUTS:
;      Through the accessor method "Set"
;      obj->Set, KEYWORD=value, KEYWORD=value, ...
;      where KEYWORD is one of those listed below
;      Keywords can also be set for  each of the public methods
;
; OUTPUTS:
;      Through the accessor method "Get"
;      value = obj->Get( /KEYWORD )
;      where KEYWORD is one of those listed below
;  
; KEYWORDS: 
;       ASK (Get, Set): asks before performing a critical operation
;                       (e.g. remove files, etc...) Either 0B or
;                       1B. Default is 1B.
;       FILENAME (Get, Set): the file name where data associated with
;                            the class is stored. Default is ''.
;       NEED_UPDATE: 
;       PLOT (Get, Set): plots data while performing. This is the
;                        "display" equivalent to "verbose".
;                        Either 0B or 1B. Default is 1B.
;       VERBOSE (Get, Set): Prints informational messages on the tty
;                           whenever required. Either 0B or 1B. 
;                           Default is 1B.
;
; HISTORY:
;       Based on hsi_super__define, but generalized.
;           June 28, 1999, A Csillaghy, csillag@ssl.berkeley.edu
;       hsi_super: March 4, 1999, for Release 2 
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;


;---------------------------------------------------------------------------

FUNCTION Selection_Manager::INIT, n_item, _EXTRA = _extra

ret=self->Framework::INIT( _EXTRA = _extra )

CheckVar, self.n_item,  1000L

RETURN, 1

END

;---------------------------------------------------------------------------

PRO Selection_Manager::CLEANUP

Ptr_Free, self.selection_list	
self->Framework::CLEANUP

END

;---------------------------------------------------------------------------

FUNCTION Selection_Manager::GetSelection, $
                          ALL = all, $
                          BUNCH_NR = bunch_nr, $
                          DONE = done, $
                          FIRST_BUNCH = first_bunch, $
                          FORCE = force, $
                          FULL_SELECTION = full_selection, $
                          NEXT_BUNCH = next_bunch, $
                          sel_100_next =  sel_100_next,  $
                          _EXTRA = _extra

IF Keyword_Set( _EXTRA ) THEN self->Set, _EXTRA = _extra 

IF NOT Ptr_Valid( self.selection_list ) OR $
    Keyword_Set( FORCE ) OR self.partial_selection OR $
  self -> Need_Update() THEN BEGIN 
; select is the call back to the concrete class
    self->Select, FORCE = force, ALL=all, _EXTRA=_extra
ENDIF 

IF KEYWORD_SET( ALL ) OR $
    NOT ( Keyword_Set( NEXT_BUNCH ) OR $
          Keyword_Set( FIRST_BUNCH ) OR $ 
          Keyword_Set( BUNCH_NR ) ) OR $
    Keyword_Set( FULL_SELECTION ) THEN BEGIN
    done = 1
    if arg_present( sel_100_next ) then sel_100_next = self.sel_100_next
    RETURN, *self.selection_list
ENDIF

IF Keyword_Set( NEXT_BUNCH ) THEN self.curr_bunch =  self.curr_bunch + 1
IF Keyword_Set( FIRST_BUNCH ) THEN self.curr_bunch =  0
IF Keyword_Set( BUNCH_NR ) THEN self.curr_bunch = bunch_nr

index_minmax = [0, self.n_item-1]+ self.n_item*(self.curr_bunch)
IF self.debug GT 5 THEN BEGIN 
    print, "index_minmax = ", index_minmax
ENDIF 

n_sel = N_Elements( *self.selection_list )

if arg_present( sel_100_next ) then begin 
  if index_minmax[1] lt n_sel-1 then begin 
    sel_100_next =  (*self.selection_list)[index_minmax[1]+1]
  endif else begin 
    sel_100_next =  self.sel_100_next
  endelse
endif

index_minmax = index_minmax < ( n_sel-1 )

IF index_minmax[1] EQ (n_sel-1) THEN done = 1 ELSE done = 0

  
RETURN, (*self.selection_list)[index_minmax[0]:index_minmax[1]] 


END

;---------------------------------------------------------------------------

PRO Selection_Manager::SetSelection, selection_list

Ptr_Free, self.selection_list
self.selection_list = Ptr_New( selection_list )

END

;---------------------------------------------------------------------------

PRO Selection_Manager__Define

self = {Selection_Manager, $
        partial_selection: 0B, $
        selection_list: Ptr_New(), $
        curr_bunch: 0L, $
        n_item: 0L, $
        sel_100_next: 0L,  $
        INHERITS Framework }
   
END

;---------------------------------------------------------------------------
; End of 'selection_manager__define.pro'.
;--------------------------------------------------------------------------
