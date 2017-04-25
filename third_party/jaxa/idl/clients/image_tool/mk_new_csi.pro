;---------------------------------------------------------------------------
; Document name: mk_new_csi.pro
; Created by:    Liyun Wang, GSFC/ARC, June 2, 1995
;
; Last Modified: Mon Apr  1 10:18:05 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION mk_new_csi
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:	
;       MK_NEW_CSI()
;
; PURPOSE:
;       Create a new CSI (coordinate system info) structure
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       csi = mk_new_csi()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. It should
;              have the following 15 tags:
;
;              XD0 -- X position of the first pixel of the
;                     image (lower left corner), in device pixels
;              YD0 -- Y position of the first pixel of the
;                     image (lower left corner), in device pixels
;              XU0 -- X position of the first pixel of the image (lower 
;                     left corner), in user (or data) pixels. 
;              YU0 -- Y position of the first pixel of the image (lower 
;                     left corner), in user (or data) pixels
;              MX  -- X size of the image in device pixels
;              MY  -- Y size of the image in device pixels
;              RX  -- ratio of SX/MX, (data unit)/(device pixel), 
;                     where SX is the image size in X direction in data pixels
;              RY  -- ratio of SY/MY, (data unit)/(device pixel), 
;                     where SY is the image size in Y direction in data pixels
;              X0  -- X position of the reference point in data pixels
;              Y0  -- Y position of the reference point in data pixels
;              XV0 -- X value of the reference point in absolute units
;              YV0 -- Y value of the reference point in absolute units
;              SRX -- scaling factor for X direction in arcsec/(data pixel)
;              SRY -- scaling factor for Y direction in arcsec/(data pixel)
;              FLAG - indicator with value 0 or 1 showing if the solar
;                     coodinate system is established. 1 is yes.
;              RADIUS - Solar disc radius in arcsecs, initialized to 960.0
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
; HISTORY:
;       Version 1, June 2, 1995, Liyun Wang, GSFC/ARC. Written
;       Version 2, April 1, 1996, Liyun Wang, GSFC/ARC
;          Added RADIUS tag in output structure
;
; VERSION:
;       Version 2, April 1, 1996
;-
;
   csi = {csi, xd0:0, yd0:0, xu0:0, yu0:0, rx:0.0, ry:0.0, mx:0, my:0, $
          x0:0, y0:0, xv0:0.0, yv0:0.0, srx:0.0, sry:0.0, flag:0, $
          radius:960.0}
   RETURN, csi
END

;---------------------------------------------------------------------------
; End of 'mk_new_csi.pro'.
;---------------------------------------------------------------------------
