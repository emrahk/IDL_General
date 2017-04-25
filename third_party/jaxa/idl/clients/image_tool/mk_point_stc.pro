PRO mk_point_stc, structure, n_pointings=n_pointings, n_rasters=n_rasters,$
                  fov=fov
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       MK_POINT_STC
;
; PURPOSE:
;       Make a fresh pointing structure to be used by IMAGE_TOOL
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       mk_point_stc, structure
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       N_POINTINGS - Number of pointings desired. Default is 1.
;       N_RASTERS   - Number of rasters for each pointing. Default is 1.
;
; OUTPUTS:
;       STRUCTURE - The pointing structure siutable for use in IMAGE_TOOL. It
;                   contains the following tags:
;          MESSENGER  - ID of widget in the caller that triggers a
;                       timer event in the planning tool to signal the
;                       completion of pointing; must be a widget that
;                       does not usually generate any event
;          INSTRUME   - Code specifying the instrument; e.g., 'C' for CDS
;          SCI_SPEC   - Science specification
;          STD_ID     - Study ID   
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
;                       ZONE     - Description of the zone for pointing
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
; CATEGORY:
;       Planning, Image_tool, pointing
;
; PREVIOUS HISTORY:
;       Written January 26, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, January 26, 1995
;       Version 2, Liyun Wang, NASA/GSFC, April 5, 1995
;          Added the ZONE tagname in POINTINGS
;       Version 3, December 27, 1995, Liyun Wang, NASA/GSFC
;          Added  MESSENGER tag in the returned pointing structure
;       Version 4, February 7, 1996, Liyun Wang, NASA/GSFC
;          Set raster and ppinting default size to 20x20 so that engineering
;             studies can be pointed with Pointing Tool
;       Version 5, February 18, 1997, Liyun Wang, NASA/GSFC
;          Added tags SCI_SPEC and STD_ID
;       Version 6, March 22, 1997, Zarro, GSFC
;          Enlarged default rasters sizes to 240
;       Version 7, Feb, 1998, Zarro, GSFC
;          Enlarged default rasters sizes to 480
;       29 August 2006, Zarro (ADNET/GSFC) - added /FOV
;-
;
   IF N_ELEMENTS(n_pointings) EQ 0 THEN n_pointings = 1
   IF N_ELEMENTS(n_rasters) EQ 0 THEN n_rasters = 1
   IF N_PARAMS() NE 1 THEN MESSAGE, 'Requires an output parameter.'

   pointings = {detail_point, point_id:'0', ins_x:0.0, ins_y:0.0, $
                width:250.0, height:250.0, zone:'', off_limb:0}

   if keyword_set(fov) then pointings=add_tag(pointings,0b,'out_fov')
   IF n_pointings GT 1 THEN begin
    pointings = REPLICATE(pointings, n_pointings)
    pointings.point_id=trim(sindgen(n_pointings))
   endif
   rasters = {raster_point, pointing:0, ins_x:0.0, ins_y:0.0, $
              width:250.0, height:250.0}
   IF n_rasters GT 1 THEN rasters = REPLICATE(rasters, n_rasters)

   get_utc,utc
   utc=anytim2tai(utc)
   structure = {messenger:0L, instrume:'', sci_spec:'', std_id:-1L, $
                g_label:'INDEX', x_label:'XCEN', y_label:'YCEN', $
                date_obs:utc, do_pointing:1, n_pointings:n_pointings, $
                pointings:pointings, n_rasters:n_rasters, rasters:rasters}
END


