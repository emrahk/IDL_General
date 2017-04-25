;NOTE:  RENAMED TO OLD_AXIS to avoid conflict with IDL 8.0 axis function / object. I think no one is using this
; and I don't think it works anyway.  Will offline if no one complains.  Kim Tolbert 24-Apr-2014
;
;---------------------------------------------------------------------------
; Document name: axis__define.pro
; Created by:    Andre_Csillaghy, August 21, 2003
;
; Time-stamp: <Mon Sep 15 2003 11:03:20 csillag soleil.ifi.fh-aargau.ch>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       AXIS__DEFINE
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       axis__define,
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURE:
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLES:
;
;
; SEE ALSO:
;
; HISTORY:
;       Version 1, August 21, 2003,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;--------------------------------------------------------------------------
;

function axis, axis, _extra = _extra

return, obj_new( 'axis', axis, _extra = _extra )

end