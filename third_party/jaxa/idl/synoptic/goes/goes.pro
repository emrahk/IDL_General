;+
; Project     : HESSI
;
; Name        : GOES
;
; Purpose     : GOES procedure and function.  Procedure starts GOES GUI interface and
;               optionally returns GOES object.
;               GOES function creates a new GOES object
;
; Category    : synoptic objects
;
; Explanation : Provide a GUI to plot GOES flux, temperature, emission measure,
;               select background time intervals, and write a save file.
;
; Syntax      : IDL> goes  or goes, obj (for procedure)
;               IDL> o = goes()  (for function)
;
; Arguments:  : When called as a procedure:
;               obj - returns GOES object reference
;
; Keywords    : Any keywords to pass into goes object
;
; History     : Written 17-Nov-2005, Kim Tolbert
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;
; Modifications:
; 01-Dec-2009, Kim.  If obj will not be passed out of routine, set kill_obj flag so
;   goes gui will destroy goes object when user exits.  Plugs memory leak.
;
;-

;---------------------------------------------------------------------------
; This file contains the GOES procedure as well as the GOES function.  The one used
; depends on whether it was called as a procedure or a function.

; GOES procedure starts GOES GUI interface and optionally returns GOES object
; GOES function creates a new GOES object

pro goes, obj, _ref_extra=_extra

obj = ogoes(_extra=_extra)

; if obj will not be passed out, destroy obj when the user closes gui
kill_obj = ~arg_present(obj)
obj->gui, kill_obj=kill_obj

end

;hmm, this doesn't work yet, need to make it compile the whole thing
;function goes, _extra=_extra
;
;return, obj_new('goes', _extra=extra)
;
;end