;+
; Project     : VSO
;
; Name        : CHECK_JAVA_VSO_COMPATIBILITY_CALL
;
; Purpose     : This routine should not be called directly but by CHECK_JAVA_VSO_COMPATIBILITY. It is executed
;               inside a separate IDL session (IDL_IDLBridge) and determines if the given library path contains a valid
;               Java library. If library is not set, the standard library that is determined by IDL is used.
;               
; Category    : vso utility java
;
; Example     : IDL> check_java_vso_compatibility, '/usr/lib/jvm/jre/lib/client'
; 
; Inputs      : LIBRARY = Path to the Java libraries (jvm.dll, libjvm.so)
; 
; Returns     : 1 if given library is valid, otherwise 0
;
; History     : 15-Mar-2010,  L. I. Etesi (CUA,FHNW/GSFC), Initial release
;               18-Mar-2010, Zarro (ADNET)
;                - added check for valid VSO prep object
;
; Contact     : LASZLO.ETESI@NASA.GOV
;-

FUNCTION check_java_vso_compatibility_call, library
  error=0
  status=1b
  
  CATCH, error
  IF error NE 0 THEN BEGIN
    message,err_state(),/cont
    CATCH, /CANCEL
    RETURN, 0b
  ENDIF
  
  ; If library is set, then use specific library. Otherwise the standard library is used (specified by IDL)
  IF KEYWORD_SET(library) THEN SETENV, 'IDLJAVAB_LIB_LOCATION=' + library

  ; Initialize environment
  vso_startup, status=status, /cponly
  
  IF ~status THEN return, 0b
  
  ; Try to create a VSO Prep Client object
  vsoprep = OBJ_NEW('IDLJavaObject$STATIC$GOV_NASA_GSFC_JIDL_VPS_CLIENT_PREPROCESSORCLIENTREQUEST', 'gov.nasa.gsfc.jidl.vps.client.PreprocessorClientRequest')
  
  valid=obj_valid(vsoprep)
  OBJ_DESTROY, vsoprep
  
  RETURN,valid
END
