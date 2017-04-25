;+
; Name: framework_get_debug
;
; Project: HESSI
;
; Purpose: Return the current debug level (from SSW_FRAMEWORK_DEBUG env. var.)
;
; Calling sequence:  debug = framework_get_debug()
;
; Written: Kim Tolbert 23-Oct-2002
; Modifications:
;-
;---------------------------------------------------------------------------

function framework_get_debug

return, fix (getenv('SSW_FRAMEWORK_DEBUG') )
end