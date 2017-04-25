;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_IMG_TYPE()
;
; PURPOSE:
;       Return a full label of an appropriate image type
;
; CATEGORY:
;       image_tool, utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = itool_img_type(str)
;
; INPUTS:
;       STR - String scalar, 5-char image type code
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - Full name of image type if STC keyword not set; 
;                Strcuture array containing image source codes and
;                corresponding labels if STC keyword is set
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       STC    - Set this keyword to return only a structure array
;                containing image type codes and corresponding labels.
;
; COMMON:
;       ITOOL_TYPE_COM
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, March 12, 1996, Liyun Wang, NASA/GSFC. Written
;       Version 2, March 28, 1996, Liyun Wang, NASA/GSFC
;          Added a new image type: 'Magnetogram, Longitudinal Component'
;       Version 3, May 24, 1996, Liyun Wang, NASA/GSFC
;          Added SOHO CDS synoptic image types
;       Version 4, December 13, 1996, Liyun Wang, NASA/GSFC
;          Added SOHO UVCS image types
;       Version 5, July 21, 1997, Liyun Wang, NASA/GSFC
;          Added a few more UVCS image types
;       Version 6, June 8, 1998, Zarro (SAC/GSFC) - added TRACE type
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION itool_img_type, str, stc=stc
   COMMON itool_type_com, src_code
   ON_ERROR, 2
   IF N_ELEMENTS(src_code) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Change nsrc whenever an image type is added/removed
;---------------------------------------------------------------------------
      nsrc = 48
      a = STRING(197B)
      src_code = REPLICATE({code:'', label:''}, nsrc)
      src_code( 0).code='SOFTX' & src_code( 0).label = 'Soft X Rays'
      src_code( 1).code='BBAND' & src_code( 1).label = 'Broadband'
      src_code( 2).code='CAIIK' & src_code( 2).label = 'Calcium II K'
      src_code( 3).code='CAXVM' & src_code( 3).label = 'Calcium XV Synoptic Coronal Map'
      src_code( 4).code='COGHA' & src_code( 4).label = 'H Alpha Coronograph'
      src_code( 5).code='DOPPL' & src_code( 5).label = 'Dopplergram'
      src_code( 6).code='HALPH' & src_code( 6).label = 'H Alpha'
      src_code( 7).code='HEIMP' & src_code( 7).label = 'He I 10830 '+a+', Synoptic Map'
      src_code( 8).code='MAGFE' & src_code( 8).label = 'Magnetogram, Fe 5250 '+a
      src_code( 9).code='MAGMP' & src_code( 9).label = 'Magnetogram, Synoptic Map'
      src_code(10).code='MAGLC' & src_code(10).label = 'Magnetogram, Longi. Comp.'
      src_code(11).code='IGRAM' & src_code(11).label = 'Intensitygram'
      src_code(12).code='RADIO' & src_code(12).label = 'Radio'
      src_code(13).code='VMGAV' & src_code(13).label = 'Vectomagnetogram, Average'
      src_code(14).code='VMGCI' & src_code(14).label = 'Vectomagnetogram, Component I'
      src_code(15).code='VMGCQ' & src_code(15).label = 'Vectomagnetogram, Component Q'
      src_code(16).code='VMGCU' & src_code(16).label = 'Vectomagnetogram, Component U'
      src_code(17).code='VMGCV' & src_code(17).label = 'Vectomagnetogram, Component V'
      src_code(18).code='VMGTF' & src_code(18).label = 'Vectomagnetogram, Transverse Field'
      src_code(19).code='WHITE' & src_code(19).label = 'White Light'
      src_code(20).code='HARDX' & src_code(20).label = 'Hard X Rays'
      src_code(21).code='10830' & src_code(21).label = 'He I 10830 '+a
      src_code(22).code='00171' & src_code(22).label = 'Fe IX/X 171 '+a
      src_code(23).code='00195' & src_code(23).label = 'Fe XII 195 '+a
      src_code(24).code='00284' & src_code(24).label = 'Fe XV 284 '+a
      src_code(25).code='00304' & src_code(25).label = 'He II 304 '+a
      src_code(26).code='00361' & src_code(26).label = 'Fe XVI 361 '+a
      src_code(27).code='00368' & src_code(27).label = 'Mg IX 368 '+a
      src_code(28).code='00584' & src_code(28).label = 'He I 584 '+a
      src_code(29).code='00630' & src_code(29).label = 'O V 630 '+a
      src_code(30).code='C1WLC' & src_code(30).label = 'C1 White Light'
      src_code(31).code='C2WLC' & src_code(31).label = 'C2 White Light'
      src_code(32).code='C3WLC' & src_code(32).label = 'C3 White Light'
      src_code(33).code='01032' & src_code(33).label = 'O VI 1032 '+a
      src_code(34).code='LALPH' & src_code(34).label = 'Lyman Alpha 1216 '+a
      src_code(35).code='LBETA' & src_code(35).label = 'Lyman Beta 1025 '+a
      src_code(36).code='01206' & src_code(36).label = 'Si III, 1206 '+a
      src_code(37).code='01238' & src_code(37).label = 'N V, 1238 '+a
      src_code(38).code='01242' & src_code(38).label = 'Fe XII, 1242 '+a
      src_code(39).code='CAK3L' & src_code(39).label = 'Ca II K3 '
      src_code(40).code='CAK3P' & src_code(40).label = 'Ca II K3 (long exp.)'
      src_code(41).code='CAK1L' & src_code(41).label = 'Ca II  K1v'
      src_code(42).code='MAGNA' & src_code(42).label = 'Magnetogram, Na 5896 '+a      
      src_code(43).code='01216' & src_code(43).label = 'Lyman Alpha 1216 '+a
      src_code(44).code='01600' & src_code(44).label = 'C I/Fe II 1600 '+a
      src_code(45).code='01550' & src_code(45).label = 'C IV 1550 '+a
      src_code(46).code='01700' & src_code(46).label = 'Continuum 1700 '+a
      src_code(47).code='KLINE' & src_code(47).label = 'Ca II  K1v'
   ENDIF
   IF KEYWORD_SET(stc) THEN RETURN, src_code

   junk = grep(str, src_code.code, index=index)
   IF index(0) GE 0 THEN BEGIN 
      RETURN, src_code(index(0)).label 
   ENDIF ELSE BEGIN 
      IF str NE '' THEN RETURN, str ELSE RETURN, 'Unknown Image Type'
   ENDELSE 
END

