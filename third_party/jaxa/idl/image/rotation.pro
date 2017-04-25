;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: rotation.pro
; Created by:    Liyun Wang, GSFC/ARC, September 8, 1994
;
; Last Modified: Thu Sep 22 15:12:36 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION ROTATION, axis_id, angle
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       ROTATION()
;
; PURPOSE:
;       Make a 3x3 matrix for a rotation transformation conversion.
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = ROTATION(axis_id, angle)
;
; INPUTS:
;       axis_id -- An integer that indicates the axis about which the system
;                  is rotated. For x, y, and z axes, the value is 1, 2, and 3
;                  respectively. 
;       angle   -- Angle of rotation in radians. Positive value indicates a
;                  rotation that follows the right-hand rule.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Result  -- A 3x3 two-dimensional array, the transformation matrix
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
;       Utilities, coordinates
; PREVIOUS HISTORY:
;       Written in Fortran by Liyun Wang, UF, January 17, 1988      
;
; MODIFICATION HISTORY:
;       Written September 8, 1994, by Liyun Wang, GSFC/ARC
;       
; VERSION:
;       
;-
;
   ON_ERROR, 2
   ii = FIX(axis_id)
   IF (ii LT 1) OR (ii GT 3) THEN BEGIN
      PRINT, 'ROTATION -- Axis_id has to be either 1, 2, or 3'
      PRINT, ' '
      RETURN, 0
   ENDIF
   aa = FLTARR(3,3)
   sx = SIN(angle)
   cx = COS(angle)
;
;  Initialize the array
;
   aa(*,*) = 0.0
   aa(ii-1,ii-1) =  1.0
   CASE (ii) OF
      1: BEGIN
         aa(1,1) = cx
         aa(2,2) = cx
         aa(1,2) = sx
         aa(2,1) =-sx
      END
      2: BEGIN
         aa(0,0) = cx
         aa(0,2) =-sx
         aa(2,0) = sx
         aa(2,2) = cx
      END
      3: BEGIN
         aa(0,0) = cx
         aa(0,1) = sx
         aa(1,0) =-sx
         aa(1,1) = cx
      END
      ELSE: BEGIN
         PRINT, 'ROTATION -- Wrong type of axis ID.'
         PRINT, ' '
         RETURN, 0
      END
   ENDCASE
   RETURN, aa
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'rotation.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
