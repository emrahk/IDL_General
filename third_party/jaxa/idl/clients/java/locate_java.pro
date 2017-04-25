;+
; Project     : VSO
;
; Name        : LOCATE_JAVA
;
; Purpose     : LOCATE_JAVA searches a sequence of pre-defined paths for a folder containing the Java Virtual Machine binary.
;               This JVM binary is required by the IDL-Java Bridge for it to work. Before returning, this routine will set
;	              the user environment variable IDLJAVAB_LIB_LOCATION to the JVM folder (if it was found).
;	              NOTICE: You have to call this routine before calling any other routine that depends on the IDL-Java Bridge!
;			                  Otherwise the bridge cannot initialize.
;
; Category    : vso java utility
;
; Example     : IDL> locate_java, status=status, verbose=verbose, force=force
;
; Keywords    : STATUS = 1 means everything went well, otherwise 0
;             : VERBOSE = Activate verbose messages
;             : FORCE = Activate force mode (re-set IDLJAVAB_LIB_LOCATION)
;
; Outputs     : STATUS = 1 means everything went well, otherwise 0
;               ERR = Error string if STATUS == 1
;
; History     : 15-Jun-2009  L. I. Etesi (CUA,FHNW/GSFC), Initial release
;             : 16-Jun-2009  L. I. Etesi (CUA,FHNW/GSFC), Changed documentation, added VERBOSE and FORCE arguments
;             : 15-Mar-2010  L. I. Etesi (CUA, FHNW/GSFC), Rewrote most of the script. Now checking JVM libraries for compatibility
;
; Contact     : LASZLO.ETESI@GSFC.GOV
;-

PRO locate_java, status=status, verbose=verbose, force=force, err=err
  status = 1b
  error = 0
  err = ''
  
  CATCH, error
  IF error NE 0 THEN BEGIN
    CATCH, /CANCEL
    err = 'Error Code: ' + TRIM(STRING(error)) + ', Routine: locate_java, Message: ' + STRMESSAGE(error)
    status = 0b
    RETURN
  ENDIF
  
  ; Configure Java bridge
  idl_bridge_configurator, status=status,_extra=extra, err=err
  if ~status then return
  
  ; Exit on Mac systems
  IF STRLOWCASE(!VERSION.OS) EQ 'darwin' THEN RETURN
  
  ; Configure search paths for Windows and Unix/Linux systems
  IF OS_FAMILY(/lower) EQ 'windows' THEN BEGIN
    IF STRLOWCASE(!VERSION.ARCH) EQ 'x86' THEN RETURN
    searchfolder = (GETENV('PROGRAMFILES') + '\Java')
    removefolder = ['.:(.*\\)+System32', STRJOIN(STRSPLIT(searchfolder[0], '\', /EXTRACT))]
    searchlib = 'jvm.dll'
    whereis = 'where'
    pathextract = '.:\\.+ *'
  ENDIF
  
  IF OS_FAMILY(/lower) EQ 'unix' THEN BEGIN
    searchfolder = ['/usr/lib/jvm', '/usr/java', '/usr/lib/java', '/usr']
    removefolder = ['']  
    searchlib = 'libjvm.so'
    whereis = 'whereis'
    pathextract = '/.+ *'
  ENDIF
  
  IF ~KEYWORD_SET(force) THEN BEGIN
    IF is_string(GETENV('IDLJAVAB_LIB_LOCATION')) THEN BEGIN
      jvm = GETENV('IDLJAVAB_LIB_LOCATION') 
  
      checked = GETENV('IDLJAVAB_LIB_LOCATION_CHECKED')
    
      ; If this setup has already been checked for compatibility, then return.
      IF checked EQ 'true' THEN RETURN
  
      ; Validate current IDLJAVAB_LIB_LOCATION. If incompatible, run script
      IF file_exist(jvm + get_delim() + searchlib) AND find_valid_java(jvm, searchlib, status=status, verbose=verbose, err=err) NE 'none' THEN BEGIN
        IF ~status THEN RETURN
        
        idl_bridge_configurator, jvm=jvm, force=force, status=status, err=err
        IF ~status THEN RETURN        
        
        SETENV, 'IDLJAVAB_LIB_LOCATION_CHECKED=true'
        RETURN
      ENDIF
      IF ~status THEN RETURN
    ENDIF
  ENDIF
  
  IF KEYWORD_SET(verbose) THEN PRINT, 'Standard search path(s): ' + arr2str(searchfolder)
  IF KEYWORD_SET(verbose) THEN PRINT, 'Standard library: ' + searchlib
  
  ; Trying standard search folders first
  FOR i = 0, N_ELEMENTS(searchfolder)-1 DO BEGIN
    valid = find_valid_java(searchfolder[i], searchlib, verbose=verbose, err=err)
    IF ~status THEN RETURN
    IF valid NE 'none' THEN BEGIN
      idl_bridge_configurator, jvm=valid, force=force, status=status, err=err
      SETENV, 'IDLJAVAB_LIB_LOCATION_CHECKED=true'
      RETURN
    ENDIF
  ENDFOR
  
  ; Continue if standard folder does not contain library
  ; Try to find out what Java installations are on the system  
  SPAWN, whereis + ' java', stdout, stderr, /NOSHELL
  whereisjava = STREGEX(arr2str(stdout)+arr2str(stderr), pathextract, /EXTRACT)
  respaths = STRSPLIT(whereisjava, ',', /EXTRACT)
  
  npaths = N_ELEMENTS(respaths)
  
  ; Remove all invalid or doubles from the respath
  FOR i = 0, npaths-1 DO BEGIN
    IF ~FILE_TEST(respaths[i], /DIRECTORY) THEN respaths[i] = FILE_DIRNAME(respaths[i])
    
    FOR j = 0, N_ELEMENTS(removefolder)-1 DO BEGIN
      IF removefolder[i] EQ '' THEN CONTINUE
      IF STREGEX(respaths[i], removefolder[j], /BOOLEAN) THEN BEGIN
        respaths[i] = ''
        BREAK
      ENDIF
    ENDFOR
  ENDFOR
  
  FOR i = 0, npaths-1 DO BEGIN
    IF respaths[i] EQ '' THEN CONTINUE
    
    valid = find_valid_java(respaths[i], searchlib, verbose=verbose, err=err)
    IF ~status THEN RETURN
  
    IF valid NE 'none' THEN BEGIN
      idl_bridge_configurator, jvm=valid, force=force, status=status, err=err
      SETENV, 'IDLJAVAB_LIB_LOCATION_CHECKED=true'
      RETURN
    ENDIF
  ENDFOR
  
  PRINT, '*'
  PRINT, '* Could not locate a valid JVM on your system. You do not appear to'
  PRINT, '* have Java installed. Please talk to your system administrator'
  PRINT, '* or go to http://java.sun.com to download and install Java.'
  PRINT, '*'
  status = 0b
  err = 'No error code, Routine: locate_java, Message: No valid Java Virtual Machine could be detected on the system'
END
