;---------------------------------------------------------------------------
; Document name: binning.pro
; Created by:    Andre_Csillaghy, August 21, 2003
;
; Time-stamp: <Sat May 22 2004 11:18:11 Administrator CRAPPY3>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI
;
; NAME:
;       binning()
;
; PURPOSE:
;       wrapper around obj_new to create a binning object
;
; CATEGORY:
;       utilities
;
; INSTANCE CREATION:
;       o = binning()
;
; SEE ALSO:
;       binning__define
;
; HISTORY:
;       01-feb-2004 - acs created
;                     csillag@ssl.berkeley.edu
;--------------------------------------------------------------------------

function binning, _extra = _extra

return, obj_new( 'binning', _extra = _extra )

end









