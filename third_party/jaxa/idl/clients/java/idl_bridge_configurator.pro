;+
; Project     : VSO
;
; Name        : IDL_BRIDGE_CONFIGURATOR
;
; Purpose     : Writes a IDL-Java Bridge configuration file. Re-uses an older version if present
;
; Category    : utility, java
;
; Syntax      : idl_bridge_configurator, force=force, jvm=jvm, status=status
;
; Inputs      : JVM = File path to a JVM library (jvm.dll/libjvm.so)
;             
; Keywords    : FORCE = Re-create the config file
;               STATUS = 1 means everything went well, otherwise 0
;
; Outputs     : STATUS = 1 means everything went well, otherwise 0
;               ERR = Error string if STATUS == 1
; 
; History     : 11-Mar-2010  L. I. Etesi (CUA,FHNW/GSFC), Initial release
;
; Contact     : laszlo.etesi@nasa.gov
;-

PRO idl_bridge_configurator, force=force, jvm=jvm, status=status, err=err
  error = 0
  status = 1b
  err = ''
  
  CATCH, error
  IF error NE 0 THEN BEGIN
    CATCH, /CANCEL
    err = 'Error Code: ' + TRIM(STRING(error)) + ', Routine: idl_bridge_configurator, Message: ' + STRMESSAGE(error)
    status = 0b
    RETURN
  ENDIF
  
  ; Determine folder to write bridge config
  home = chklog('HOME')
  IF FILE_TEST(home,/WRITE,/DIRECTORY) THEN confdir=home ELSE confdir=get_temp_dir()
  
  cfg_file=concat_dir(confdir,'.bridgecfg')
  
  IF KEYWORD_SET(jvm) THEN force = 1b

  ; Create and write config
  IF ~file_exist(cfg_file) OR KEYWORD_SET(force) THEN BEGIN  
    endorsed = local_name('$SSW/gen/java/slibs/endorsed')
  
    cfg = 'JVM Option1 = -Djava.endorsed.dirs=' + endorsed
    logloc = 'Log Location = ' + confdir
    loglev = 'Bridge Logging = CONFIGFINE'
    
    ; If jvm was set then populate this variable into the IDL session
    IF KEYWORD_SET(jvm) THEN BEGIN
      jvmlib = 'JVM LibLocation = ' + jvm
      SETENV, 'IDLJAVAB_LIB_LOCATION=' + jvm
    ENDIF
  
    OPENW, mylun, cfg_file, /GET_LUN
    PRINTF, mylun, cfg
    PRINTF, mylun, logloc
    PRINTF, mylun, loglev
    IF KEYWORD_SET(jvm) THEN PRINTF, mylun, jvmlib
    FREE_LUN, mylun
  ENDIF ELSE BEGIN
    OPENR, mylun, cfg_file, /GET_LUN
    line = ''
 
    ; IDLJAVAB_LIB_LOCATION needs to be set, all other parameters are read from the config file directly
    WHILE ~EOF(mylun) DO BEGIN
      READF, mylun, line
      IF STREGEX(line,'JVM LibLocation.*',/bool,/fold) THEN BEGIN
        ptr = STREGEX(line, "=")
        SETENV, 'IDLJAVAB_LIB_LOCATION=' + TRIM(STRMID(line, ptr+1))
        BREAK
      ENDIF
    ENDWHILE
    FREE_LUN, mylun 
    
  ENDELSE
  
  ; Set the config file for IDL to read
  
  SETENV, 'IDLJAVAB_CONFIG=' + cfg_file
;  message,'IDLJAVAB_CONFIG set to '+cfg_file,/cont

  chk=chklog('IDLJAVAB_LIB_LOCATION') 
;  message,'IDLJAVAB_LIB_LOCATION set to '+chk,/cont

RETURN
END
