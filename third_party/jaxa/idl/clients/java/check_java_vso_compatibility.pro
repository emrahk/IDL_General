;+
; Project     : VSO
;
; Name        : CHECK_JAVA_VSO_COMPATIBILITY
;
; Purpose     : This routine should checks in separate IDL sessions if the the specified path contains a valid Java library
;               
; Category    : vso utility java
;
; Example     : IDL> check_java_vso_compatibility, '/usr/lib/jvm/jre/lib/client', status=status
; 
; Inputs      : LIBRARY = Path to the Java libraries (jvm.dll, libjvm.so)
; 
; Keywords    : STATUS = 1 means everything went well, otherwise 0
; 
; Outputs     : ERR = Error string if STATUS == 1
; 
; Returns     : 1 if given library is valid, otherwise 0
;
; History     : 15-Mar-2010,  L. I. Etesi (CUA,FHNW/GSFC), Initial release
;
; Contact     : LASZLO.ETESI@NASA.GOV
;-

FUNCTION check_java_vso_compatibility, path, err=err
  error = 0
  err = ''
  
  CATCH, error
  IF error NE 0 THEN BEGIN
    err = 'Error Code: ' + TRIM(STRING(error)) + ', Routine: check_java_vso_compatibility, Message: ' + STRMESSAGE(error)
    IF isvalid(oBridge) THEN BEGIN
      bridgeCode = oBridge->Status(ERROR=bridgeError)
      OBJ_DESTROY, oBridge
      IF bridgeCode NE 0 THEN err = err + ', Type: IDL_IDLBridge Error, Error Code: ' + TRIM(STRING(bridgeCode)) + ', Message: ' + bridgeError 
    ENDIF
    CATCH, /CANCEL
    RETURN, 0b
  ENDIF
  
  ; Initialize IDL_IDLBridge. For Windows systems, IDL_STARTUP needs to be executed
  oBridge = OBJ_NEW('IDL_IDLBridge')
  IF OS_FAMILY(/lower) EQ 'windows' THEN oBridge->Execute, '@' + PREF_GET('IDL_STARTUP')
        
  ; REMOVE
 ; oBridge->Execute, "cd, '" + curdir() + "'"
        
  oBridge->SetVar, 'valid', 0b
  
  ; Call check inside separate IDL session
  IF KEYWORD_SET(path) THEN BEGIN
    oBridge->SetVar, 'path', path
    oBridge->Execute, "valid = check_java_vso_compatibility_call(path)"
  ENDIF ELSE BEGIN
    oBridge->Execute, "valid = check_java_vso_compatibility_call()"
  ENDELSE
  
  valid = oBridge->GetVar('valid')
  
  OBJ_DESTROY, oBridge
  RETURN, valid
END
