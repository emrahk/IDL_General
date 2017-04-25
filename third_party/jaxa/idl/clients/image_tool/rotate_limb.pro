;---------------------------------------------------------------------------
; Document name: rotate_limb.pro
; Created by:    Liyun Wang, NASA/GSFC, May 5, 1995
;
; Last Modified: Wed Sep  3 11:17:09 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION rotate_limb, time_gap
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       ROTATE_LIMB()
;
; PURPOSE:
;       Make a 2xN array that results from rotating points on the limb
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = rotate_limb(rot_dir, time_gap)
;
; INPUTS:
;       TIME_GAP   - Time interval (in days) over which the rotation is made;
;                    the sign of TIME_GAP determines whether the rotation is
;                    forward or backward
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - A Nx2 array: result(*,0) latitude of points in degrees
;                             result(*,1) longitude of points in degrees
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written May 5, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, May 5, 1995
;       Version 2, September 2, 1997, Liyun Wang, NASA/GSFC
;          Changed to column major operation 
;
; VERSION:
;       Version 2, September 2, 1997
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(time_gap) EQ 0 THEN BEGIN
      MESSAGE, 'Syntax: RESULT = rotate_limb(time_gap)'
      RETURN, -1
   ENDIF
   
   lat = -85.0+5.0*FINDGEN(35)
   
   n_pnt = N_ELEMENTS(lat)
   longi = FLTARR(n_pnt) 
   IF time_gap GT 0 THEN longi(*) = -90.0 ELSE longi(*) = 90.0

   longi = longi+diff_rot(time_gap, lat, /synodic)

   RETURN, [[lat], [longi]]
END

;---------------------------------------------------------------------------
; End of 'rotate_limb.pro'.
;---------------------------------------------------------------------------
