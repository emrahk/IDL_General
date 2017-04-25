;---------------------------------------------------------------------------
; Document name: fake_point_stc.pro
; Created by:    Liyun Wang, NASA/GSFC, March 27, 1995
;
; Last Modified: Thu Dec 28 16:10:01 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION fake_point_stc, p_mode, n_pointings=n_pointings, n_rasters=n_rasters
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       FAKE_POINT_STC()
;
; PURPOSE:
;       Create a fake pointing structure for IMAGE_TOOL to use
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = fake_point_stc()
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       P_MODE - Pointing mode; valid values are -1, 0, and 1. Default: 0
;
; OUTPUTS:
;       RESULT - Pointing structure suitable for use by IMAGE_TOOL. It has the
;                following tags:
;
;          INSTRUME   - Code specifying the instrument; e.g., 'C' for CDS
;          G_LABEL    - Generic label for the pointing; e.g., 'RASTER'
;          X_LABEL    - Label for X coordinate of pointing; e.g., 'INS_X'
;          Y_LABEL    - Label for Y coordinate of pointing; e.g., 'INS_Y'
;          DATE_OBS   - Date/time of beginning of observation, in TAI format
;          DO_POINTING- An integer of value 0 or 1 indicating whether pointing
;                       should be handled at the planning level (i.e., by
;                       IMAGE_TOOL); default is set to 1.
;          N_POINTINGS- Number of pointings to be performed by IMAGE_TOOL
;          POINTINGS  - A structure array (with N_POINTINGS elements) of type
;                       "DETAIL_POINT" to be handled by IMAGE_TOOL. It has
;                       the following tags:
;
;                       POINT_ID - A string scalar for pointing ID
;                       INS_X    - X coordinate of pointing area center in arcs
;                       INS_Y    - Y coordinate of pointing area center in arcs
;                       WIDTH    - Area width (E/W extent)  in arcsec
;                       HEIGHT   - Area height (N/S extent) in arcsec
;                       OFF_LIMB - An interger with value 1 or 0 indicating
;                                  whether or not the pointing area should
;                                  be off limb
;
;          N_RASTERS  - Number of rasters for each pointing (this is
;                       irrelevant to the SUMER)
;          RASTERS    - A structure array (N_RASTERS-element) of type
;                       "RASTER_POINT" that contains raster size and pointing
;                       information (this is irrelevant to the SUMER). It has
;                       the following tags:
;
;                       POINTING - Pointing handling code; valis
;                                  values are: 1, 0, and -1
;                       INS_X    - Together with INS_Y, the pointing to use
;                                  when user-supplied values are not
;                                  allowed.  Only valid when POINTING=0
;                                  (absolute) or POINTING=-1 (relative to
;                                  1st raster).
;                       INS_Y    - ...
;                       WIDTH    - Width (E/W extent) of the raster, in arcs
;                       HEIGHT   - Height (N/S extent) of the raster, in arcs
;
;      Note: For the case of CDS, pointings.width, pointings.height,
;            pointings.ins_x, and pointings.ins_y should match the first
;            raster's rasters.width, rasters.height, rasters.ins_x, and
;            rasters.ins_y, respectively.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       N_POINTINGS - Number of pointing areas; default: 4
;       N_RASTERS   - Number of rasters in each pointing area; default: 6
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
;       Written March 27, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, March 27, 1995
;
; VERSION:
;       Version 1, March 27, 1995
;-
;
   ON_ERROR, 2

   IF N_ELEMENTS(n_pointings) EQ 0 THEN n_pointings = 4
   IF N_ELEMENTS(n_rasters) EQ 0 THEN n_rasters = 6

   IF N_ELEMENTS(p_mode) EQ 0 THEN p_mode = 0
   IF ABS(p_mode) GT 1 THEN MESSAGE,'Invalid pointing mode!'
   
   dprint, 'Pointing mode: '+STRTRIM(p_mode,2)
   
   get_utc, date
   tai = utc2tai(date)

   rasters = {raster_point, pointing:0, ins_x:0.0, ins_y:0.0, $
              width:0.0, height:0.0}
   IF n_rasters GT 1 THEN rasters = REPLICATE(rasters, n_rasters)
   FOR i = 0, n_rasters-1 DO BEGIN
      rasters(i).pointing = p_mode
   ENDFOR
   IF p_mode EQ -1 THEN rasters(0).pointing = 1
   IF p_mode LE 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Pointing is defined in study
;---------------------------------------------------------------------------
      FOR i = 0, n_rasters-1 DO BEGIN
         rasters(i).ins_x = FLOAT(-200+70*i)
         rasters(i).ins_y = FLOAT(-400+90*i)
      ENDFOR
   ENDIF

   FOR i = 0, n_rasters-1 DO BEGIN
      rasters(i).width = FLOAT(100+30*i)
      rasters(i).height = FLOAT(160+50*i)
   ENDFOR

   pointings = {detail_point, point_id:'', ins_x:0.0, ins_y:0.0, $
                width:0.0, height:0.0, zone:'', off_limb:0}
   IF n_pointings GT 1 THEN pointings = REPLICATE(pointings, n_pointings)

   FOR i = 0, n_pointings-1 DO BEGIN
      pointings(i).point_id = '   '+STRTRIM(i,2)
      pointings(i).width = rasters(0).width
      pointings(i).height = rasters(0).height
      pointings(i).zone = 'Zone '+STRTRIM(i,2)
   ENDFOR

;---------------------------------------------------------------------------
;  Make the last pointing area off limb
;---------------------------------------------------------------------------
   pointings(n_pointings-1).zone = 'Off Limb'
   pointings(n_pointings-1).off_limb = 1
   
   mk_point_stc, structure, n_pointings=n_pointings, n_rasters=n_rasters
   
   structure.date_obs = tai
   structure.rasters = rasters
   structure.pointings = pointings
   structure.instrume = 'C'
   
   IF p_mode EQ 0 THEN structure.do_pointing = 0
   RETURN, structure
END

;---------------------------------------------------------------------------
; End of 'fake_point_stc.pro'.
;---------------------------------------------------------------------------
