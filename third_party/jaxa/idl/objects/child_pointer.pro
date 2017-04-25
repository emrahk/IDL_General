;+
; Project     : SOHO - CDS
;
; Name        : CHILD_POINTER()
;
; Purpose     : to retrieve child of a pointer variable
;
; Category    : Help
;
; Explanation : use appropriate WIDGET or HANDLE info routines
;
; Syntax      : IDL> child=child_pointer(pointer)
;
; Inputs      :  POINTER = pointer variable
;
; Opt. Inputs : None
;
; Outputs     : CHILD = child ID of pointer
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-Sep-1995,  D.M. Zarro.  Written
;               Version 2, 17-Jul-1997, D.M. Zarro. Modified
;                 -- Updated to version 5 pointers
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function child_pointer,pointer

child=0

valid=valid_pointer(pointer,type)
if valid then begin
 case type of
  0: child=widget_info(pointer,/child)
  1: child=call_function('handle_info',pointer,/first_child)
  2: message,'No child function available for pointers',/cont
 else: do_nothing=1
 endcase
endif

return,child & end
