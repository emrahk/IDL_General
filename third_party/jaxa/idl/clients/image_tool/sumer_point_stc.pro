;---------------------------------------------------------------------------
; Document name: sumer_point_stc.pro
; Created by:    Liyun Wang, NASA/GSFC, January 26, 1995
;
; Last Modified: Mon Mar 13 16:23:57 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION sumer_point_stc, sumer_detail
;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:
;       SUMER_POINT_STC()
;
; PURPOSE:
;       Make pointing structure for IMAGE_TOOL from SUMER study
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = sumer_point_stc(sumer_study)
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
;          The pointing descriptions themselves are structures, of
;          type "sumer_plan_pnt", with the following tags:
;          
;          XCEN        - Center pointing of the study part in the X direction.
;          YCEN        - Same in the Y direction.
;          WIDTH       - Width to use for the study.
;          HEIGHT      - Height to use for the study.
;          ZONE_ID - 1-byte integer, the zone ID for the pointing.
;          ZONE    - String, the zone description, e.g. "Off Limb"
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - Pointing structure that has the following tags:
;
;          INSTRUME   - Code specifying the instrument; e.g., 'C' for CDS
;          G_LABEL    - Generic label for the pointing; e.g., 'RASTER'
;          X_LABEL    - Label for X coordinate of pointing; e.g., 'INS_X1'
;          Y_LABEL    - Label for Y coordinate of pointing; e.g., 'INS_Y1'
;          POINT_NUM  - Number of pointings to be performed by IMAGE_TOOL
;          POINT_SPEC - Pointing specification (identifier)
;          X_COORD    - X coordinate in arcs
;          Y_COORD    - Y coordinate in arcs
;          WIDTH      - Area width in arcsec
;          HEIGHT     - Area height in arcsec
;          OFF_LIMB   - An interger with value 1 or 0 indicating whether
;                       or not the pointing area should be off limb
;
;
;       Note: POINT_SPEC, X_COORD, Y_COORD, WIDTH, HEIGHT are all POINT_NUM
;             element arrays
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
;
; VERSION:
;       Version 1, January 26, 1995
;-
;
   ON_ERROR, 2
   IF datatype(sumer_detail) NE 'STC' THEN MESSAGE, $
      'Requires one SUMER study structure'
   point_num = sumer_detail.n_pointings
   mk_point_stc, point, point_num = point_num
   point.instrume = 'S'
   point.g_label = 'INDEX'
   point.x_label = 'XCEN'
   point.y_label = 'YCEN'
   temp = INDGEN(sumer_detail.n_pointings)
   FOR i = 0, point_num-1 DO BEGIN
      point.point_spec(i) = '    '+num2str(temp(i))
      IF sumer_detail.pointings(i).zone_id EQ 3 THEN $
         point.off_limb(i) = 1 $
      ELSE $
         point.off_limb(i) = 0
   ENDFOR
   point.x_coord = sumer_detail.pointings.xcen
   point.y_coord = sumer_detail.pointings.ycen
   point.width   = sumer_detail.pointings.width
   point.height  = sumer_detail.pointings.height
   RETURN, point
END

;---------------------------------------------------------------------------
; End of 'sumer_point_stc.pro'.
;---------------------------------------------------------------------------
