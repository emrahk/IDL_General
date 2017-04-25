;+
;
; NAME: WINDOW_TEST
;	
;
; PURPOSE:
;	This procedure is used to test whether X windows are available if
;	requested.  If not available, device might be wrong or in batch, then
;	the device is switched to the default, PS, or NULL
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;	WINDOW_TEST
;
; CALLS:
;	none
;
; INPUTS:
;       none explicit, only through commons;
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	NULL - Switched to 'NULL' is 'X' not available.
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	Version 1, ras, 3-oct-1996
;-
pro window_test, null=null

if !d.name eq 'X' and !d.window eq -1 then begin  ;Uninitialized?
;       If so, make a dummy window to determine the # of colors available.
        test = execute('window,/free,/pixmap,xs=4, ys=4')
        if test then wdelete, !d.window else set_plot,(['PS','NULL'])(keyword_set(null))
        endif

end


