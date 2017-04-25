;+
; Project     : VSO
;
; Name        : FIND_VALID_JAVA
;
; Purpose     : This routine searches the specified path for all possible jvm.dll/libjvm.so library files and then checks
;               each of them for compatibility. Returns as soon as a valid JVM has been found.
;               
; Category    : vso utility java
;
; Example     : IDL> find_valid_java, '/usr/lib/jvm', 'libjvm.so', status=status, verbose=verbose 
; 
; Inputs      : PATH = Folder that may contain a JVM
;               SEARCHLIB = jvm.dll on Windows, libjvm.so on Unix/Linux
;               
; Keywords    : STATUS = Status flag, 1 means everything went well, 0 means error occurred
;               VERBOSE = Activate verbose messages
;               
; Outputs     : STATUS = Status flag, 1 means everything went well, 0 means error occurred
;             : ERR = Error string if STATUS == 1
; 
; Returns     : 'none' if no JVM was found, otherwise the path to the valid JVM is returned
;
; History     : 15-Mar-2010,  L. I. Etesi (CUA,FHNW/GSFC), Initial release
;
; Contact     : LASZLO.ETESI@NASA.GOV
;-

FUNCTION find_valid_java, path, searchlib, status=status, verbose=verbose, err=err
  status = 1b
  error = 0
  err = ''
  
  CATCH, error
  IF error NE 0 THEN BEGIN
    CATCH, /CANCEL
    err = 'Error Code: ' + TRIM(STRING(error)) + ', Routine: find_valid_java, Message: ' + STRMESSAGE(error)
    status = 0b
    RETURN, 0b
  ENDIF
  
  ; Get all directories within path
  folders = FILE_SEARCH(path + get_delim() + '*', /TEST_DIRECTORY)
  
  ; If no sub-folders are found, then path is pointing directly at JVM location
  IF N_ELEMENTS(folders) EQ 1 THEN BEGIN
    IF folders EQ '' THEN folders = path
  ENDIF
  
  ; Remove symlinks on Unix/Linux systems. Reduces unnecessary searches
  FOR j = 0, N_ELEMENTS(folders)-1 DO BEGIN
    IF OS_FAMILY(/lower) NE 'windows' THEN BEGIN
      IF FILE_TEST(folders[j], /SYMLINK) THEN CONTINUE
    ENDIF
    
    IF KEYWORD_SET(verbose) THEN PRINT, "Searching folder '" + folders[j] + "' for library '" + searchlib + "'"
    
    ; Find all instances of jvm.dll/libjvm.so
    res = FILE_SEARCH(folders[j], searchlib)
   
    ; Check each possible candidate for compatibility. Return if valid candidate was found
    FOR i = 0, N_ELEMENTS(res)-1 DO BEGIN
      IF res[i] EQ '' THEN CONTINUE   
      libpath = FILE_DIRNAME(res[i])
      
      IF KEYWORD_SET(verbose) THEN PRINT, "Checking '" + res[i] + "' for compatibility"
      
      valid = check_java_vso_compatibility(libpath)
               
      IF valid THEN BEGIN
        IF KEYWORD_SET(verbose) THEN PRINT, "Library '" + res[i] + "' is valid"
        RETURN, libpath
      ENDIF
    ENDFOR
  ENDFOR

  IF KEYWORD_SET(verbose) THEN PRINT, "No valid library could be found"
  RETURN, 'none'
END