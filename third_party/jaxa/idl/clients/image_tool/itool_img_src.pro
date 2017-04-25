;---------------------------------------------------------------------------
; Document name: itool_img_src.pro
; Created by:    Liyun Wang, NASA/GSFC, March 12, 1996
;
; Last Modified: Fri Sep  5 15:10:05 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_IMG_SRC()
;
; PURPOSE: 
;       Return a string of an appropriate image source for a given code
;
; CATEGORY:
;       image_tool, utility
; 
; EXPLANATION:
;       
; SYNTAX: 
;       Result = itool_img_src(str)
;       Result = itool_img_src(/stc)
;
; INPUTS:
;       STR - String scalar, 4-char image source code
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - Full name of the image source if STC keyword not set; 
;                Strcuture array containing image source codes and
;                corresponding labels if STC keyword is set
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       STC    - Set this keyword to return only a structure array
;                containing image source codes and corresponding labels.
;
; COMMON:
;       ITOOL_SRC_COM
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, March 12, 1996, Liyun Wang, NASA/GSFC. Written
;       Version 2, July 30, 1996, Liyun Wang, NASA/GSFC
;          Added Kiepenheuer Institute and Pic du Midi Observatory
;       Version 3, August 29, 1997, Liyun Wang, NASA/GSFC
;          Added Kanzelhohe Solar Observatory
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION itool_img_src, str, stc=stc
   COMMON itool_src_com, src_code
   ON_ERROR, 2
   IF N_ELEMENTS(src_code) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Change nsrc whenever a source is added/removed
;---------------------------------------------------------------------------
      nsrc = 25
      src_code = REPLICATE({code:'', label:''}, nsrc)
      src_code( 0).code = 'KBOU' & src_code( 0).label='Space Environment Lab'
      src_code( 1).code = 'KHMN' & src_code( 1).label='Holloman AFB'
      src_code( 2).code = 'HTPR' & SRC_CODE( 2).label='Haute-Provence'
      src_code( 3).code = 'LEAR' & SRC_CODE( 3).label='Learmonth Observatory'
      src_code( 4).code = 'MITK' & SRC_CODE( 4).label='Mitaka, Japan'
      src_code( 5).code = 'MLSO' & SRC_CODE( 5).label='Mauna Loa Solar Obs. at HAO'
      src_code( 6).code = 'NOBE' & SRC_CODE( 6).label='Nobeyama Radio Observatory'
      src_code( 7).code = 'PDMO' & SRC_CODE( 7).label='Pic du Midi Observatory'
      src_code( 8).code = 'MEUD' & SRC_CODE( 8).label='Obs. of Paris at Meudon'
      src_code( 9).code = 'ONDR' & SRC_CODE( 9).label='Ondrejov'
      src_code(10).code = 'KSAC' & SRC_CODE(10).label='Nat. Solar Obs. at Sac. Peak'
      src_code(11).code = 'BBSO' & SRC_CODE(11).label='Big Bear Solar Observatory'
      src_code(12).code = 'KPNO' & SRC_CODE(12).label='Nat. Solar Obs. at Kitt Peak'
      src_code(13).code = 'MEES' & SRC_CODE(13).label='Mees Solar Observatory'
      src_code(14).code = 'MWNO' & SRC_CODE(14).label='Mt. Wilson Observatory'
      src_code(15).code = 'YOHK' & SRC_CODE(15).label='Yohkoh Soft-X Telescope'
      src_code(16).code = 'KISF' & SRC_CODE(16).label='Kiepenheuer Institute'
      src_code(17).code = 'KANZ' & SRC_CODE(17).label='Kanzelhohe Solar Observatory'
      src_code(18).code = 'SCDS' & SRC_CODE(18).label='SOHO CDS'
      src_code(19).code = 'SSUM' & SRC_CODE(19).label='SOHO SUMER'
      src_code(20).code = 'SEIT' & SRC_CODE(20).label='SOHO EIT'
      src_code(21).code = 'SLAS' & SRC_CODE(21).label='SOHO LASCO'
      src_code(22).code = 'SUVC' & SRC_CODE(22).label='SOHO UVCS'
      src_code(23).code = 'SMDI' & SRC_CODE(23).label='SOHO MDI'
      src_code(24).code = 'STRA' & SRC_CODE(24).label='TRACE'
   ENDIF
   IF KEYWORD_SET(stc) THEN RETURN, src_code
   junk = grep(str, src_code.code, index=index)
   IF index(0) GE 0 THEN $
      RETURN, src_code(index(0)).label $
   ELSE RETURN, 'Unknown Image Origin'
END

;---------------------------------------------------------------------------
; End of 'itool_img_src.pro'.
;---------------------------------------------------------------------------
