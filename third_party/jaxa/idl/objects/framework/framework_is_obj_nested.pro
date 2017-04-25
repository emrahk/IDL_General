;+
; Name: framework_is_obj_nested
;
; Project:  HESSI
;
; Purpose: Check whether we are currently inside a chain of HESSI GET or GETDATA
;	calls handled by FRAMEWORK or whether a user called the routine directly.
;	Needed for deciding how to exit when an error is encountered.  Called by
;	the code in framework_insert_catch, which is @'ed into the GET and GETDATA methods
;	of some of the objects.
;
; Method: Looks in traceback to see if there's a 'FRAMEWORK::GET' (which includes
;	'FRAMEWORK::GETDATA')
;
; Category: HESSI
;
; Calling Sequence:  answer = framework_is_obj_nested()
;
; Written: Kim Tolbert, 12-Aug-2002
; Modifications:
;
;-
;---------------------------------------------------------------------------

function framework_is_obj_nested

;caller = get_caller(prev_caller=prev_caller)
;if strpos(prev_caller, 'FRAMEWORK::GETDATA') ne -1 then return, 1 else return,0

help, /trace, out=out
q = where (strpos(out[2:*], 'FRAMEWORK::GET') ne -1 , count)
if count gt 0 then return, 1 else return, 0

end