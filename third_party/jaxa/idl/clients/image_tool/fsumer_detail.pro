;---------------------------------------------------------------------------
; Document name: FSUMER_DETAIL.PRO
; Created by:    Liyun Wang, NASA/GSFC, February 13, 1995
;
; Last Modified: Thu Mar  9 10:19:20 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION FSUMER_DETAIL, n_pointings
;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:
;       FSUMER_DETAIL()
;
; PURPOSE:
;       Create a fake sumer detail structure
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = FSUMER_DETAIL(n_pointings)
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS:
;       N_POINTINGS - Number of pointings areas, default to 1
;
; OUTPUTS:
;       Result -- A fake detail structure for SUMER containing the following
;                 tags: 
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
;          XCEN    - Center pointing of the study part in the X direction.
;          YCEN    - Same in the Y direction.
;          WIDTH   - Width to use for the study.
;          HEIGHT  - Height to use for the study.
;          ZONE_ID - 1-byte integer, the zone ID for the pointing.
;          ZONE    - String, the zone description, e.g. "Off Limb"
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
;       Written February 13, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, NASA/GSFC, February 13, 1995
;
; VERSION:
;       Version 1, February 13, 1995
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(n_pointings) EQ 0 THEN n_pointings = 1
   pointings = REPLICATE({SUMER_PLAN_PNT, xcen:123.000, ycen:456.000,$
                          width:100.00,height:100.000,zone_id:3,$
                          zone:'Off Limb'},n_pointings)
   aa = {struct_type:'SUMER-DETAIL',prog_id:1L,study_id:2L,studyvar:0,$
         sci_obj:'SYNOPTIC STUDIES',sci_spec:'',cmp_no:0L,object:'SYN',$
         obj_id:'',date_obs:1.1991384d+09,date_end:1.1991528d+09,$
         time_tagged:1b,n_pointings:n_pointings,pointings:pointings}

   RETURN, aa
END

;---------------------------------------------------------------------------
; End of 'FSUMER_DETAIL.PRO'.
;---------------------------------------------------------------------------
