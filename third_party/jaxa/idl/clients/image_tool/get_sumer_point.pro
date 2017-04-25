;---------------------------------------------------------------------------
; Document name: get_sumer_point.pro
; Created by:    Liyun Wang, NASA/GSFC, January 26, 1995
;
; Last Modified: Tue Feb 18 18:29:29 1997 (LWANG@sumop1.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION get_sumer_point, sumer_detail
;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:
;       GET_SUMER_POINT()
;
; PURPOSE:
;       Make a pointing structure for use by IMAGE_TOOL from SUMER study
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = get_sumer_point(sumer_study)
;
; INPUTS:
;       SUMER_DETAIL - SUMER detail structure returned from GET_DETAIL.
;                      It currently (as of January 26, 1995) has the 
;                      following tags: 
;
;          STRUCT_TYPE - The character string 'SUMER-DETAIL'
;          PROG_ID     - Program ID, linking one or more studies together
;          STUDY_ID    - Number defining the study
;          STUDYVAR    - The number 0 (for compatibility with CDS software).
;          SCI_OBJ     - Science objective from the daily science meeting
;          SCI_SPEC    - Specific science objective from meeting
;          CMP_NO      - Campaign number
;          OBJECT      - Code for object planned to be observed
;          OBJ_ID      - Object identification
;          DATE_OBS    - Date/time of beginning of observation, in TAI format
;          DATE_END    - Date/time of end of observation, in TAI format
;          TIME_TAGGED - True (1) if the start of the study is to be a 
;                        time-tagged event.  Otherwise, the study will begin
;                        immediately after the previous study.
;          N_POINTINGS - Number of pointing areas associated with the study.
;          POINTINGS   - A array describing the area for each study to be 
;                        used during the study.  If there are no pointings
;                        associated with the array, then this tag will have a
;                        dummyvalue instead.
;          
;          The POINTINGS descriptions themselves are structures, of
;          type "sumer_plan_pnt", with the following tags:
;          
;             XCEN    - Center pointing of the study part in the X direction.
;             YCEN    - Same in the Y direction.
;             WIDTH   - Width to use for the study.
;             HEIGHT  - Height to use for the study.
;             ZONE_ID - 1-byte integer, the zone ID for the pointing.
;             ZONE    - String, the zone description, e.g. "Off Limb"
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - A pointing structure that can be used by IMAGE_TOOL. 
;                It has the following tags:
;
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
;                       IMAGE_TOOL)
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
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       DATATYPE, MK_POINT_STC, NUM2STR
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
;       Written January 26, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, January 26, 1995
;       Version 2, February 18, 1997, Liyun Wang, NASA/GSFC
;          Added SCI_SPEC and STD_ID in output structure
;
; VERSION:
;       Version 2, February 18, 1997
;-
;
   ON_ERROR, 2
   IF datatype(sumer_detail) NE 'STC' THEN MESSAGE, $
      'Requires one SUMER study structure'
   n_pointings = sumer_detail.n_pointings
   
;---------------------------------------------------------------------------
;  Make an "empty" pointing structure based on number of pointings and rasters
;---------------------------------------------------------------------------
   delvarx, point_stc
   mk_point_stc, point_stc, n_pointings=n_pointings
   
;---------------------------------------------------------------------------
;  Fill out some tags specific to CDS
;---------------------------------------------------------------------------
   point_stc.instrume = 'S'
   point_stc.sci_spec = sumer_detail.sci_spec
   point_stc.std_id = sumer_detail.study_id
   point_stc.g_label = 'INDEX'
   point_stc.x_label = 'XCEN'
   point_stc.y_label = 'YCEN'
   point_stc.date_obs = sumer_detail.date_obs
   
;---------------------------------------------------------------------------
;  Check to see if pointing needs to be handled by IMAGE_TOOL
;---------------------------------------------------------------------------
   IF n_pointings EQ 0 THEN BEGIN
      point_stc.do_pointing = 0 
   ENDIF ELSE BEGIN 
      point_stc.pointings.width = sumer_detail.pointings(0:n_pointings-1).width
      point_stc.pointings.height = sumer_detail.pointings(0:n_pointings-1).height
      point_stc.pointings.ins_x = sumer_detail.pointings(0:n_pointings-1).xcen
      point_stc.pointings.ins_y = sumer_detail.pointings(0:n_pointings-1).ycen
   
      FOR i=0, n_pointings-1 DO BEGIN
         point_stc.pointings(i).point_id = '   '+STRTRIM(i, 2)
         IF sumer_detail.pointings(i).zone_id EQ 3 THEN $
            point_stc.pointings(i).off_limb = 1 $
         ELSE $
            point_stc.pointings(i).off_limb = 0
         point_stc.pointings(i).zone = sumer_detail.pointings(i).zone
      ENDFOR
   ENDELSE

   RETURN, point_stc
END

;---------------------------------------------------------------------------
; End of 'get_sumer_point.pro'.
;---------------------------------------------------------------------------
