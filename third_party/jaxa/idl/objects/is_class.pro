
;+
; Project     : HESSI
;
; Name        : IS_CLASS
;
; Purpose     : check if an object is an instance of the specified class.  Calls RSI's OBJ_ISA
;	but here, if object argument isn't an object, doesn't halt.
;
; Category    : utility objects
;
; Explanation : checks the argument is an object, and if so, then if it is an instance of the
;	specified class
;
; Syntax      : IDL> answer=is_class(object, class)
;
; Examples    : if  is_class (object, 'hsi_image') then object -> plot
;
; Inputs      :		OBJECT - object to check
;						CLASS = class name
;
; Opt. Inputs : None
;
; Outputs     : 1/0 if object is/isn't an instance of class
;
; Opt. Outputs: None
;
; Keywords    : ERROR - blank string, or text of error message
;						QUIET - if set, don't print error message
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 17 Aug 2000, Kim Tolbert
;
; Contact     : kim.tolbert@gsfc.nasa.gov
; Modifications:
;    31-Jan-2001, Kim - Changed size(xxx,/dim) to n_elements(xxx) because 5.4 returns 0 for scalar
;    11-May-2010, Kim - If object not defined, just return 0 right away
;-

function is_class, object, class, error=error, quiet=quiet

error = ''

if n_elements(object) eq 0 then return, 0

if n_params() ne 2 or $
	size(class,/tname) ne 'STRING' or $
	n_elements(class) ne 1 or $
	n_elements(object) ne 1 then begin
	error = 'Syntax - answer = is_class(object, classname, error=error)'
	if not keyword_set(quiet) then message, error, /cont
	return,0
endif

if not obj_valid(object) then return, 0

return, obj_isa (object, class)

end