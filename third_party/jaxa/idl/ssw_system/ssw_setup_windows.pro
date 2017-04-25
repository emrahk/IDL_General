;
;+
;   Name: ssw_setup_windows
;
;   Purpose: Initial setup for Windows
;
;   Input Parameters:
;               None
;   Calling Examples:
;
;               ssw_setup_windows
;
;   Calls:
;               set_logenv
;   Keyword Parameters:
;   Restrictions:
;               WINDOWS only
;               should be called from initial startup file
;   History:
;        1-Jun-1999 - R.D.Bentley - Created
;       18-Mar-2000 - R.D.Bentley - added decompose statement
;                                   call idl_startup.pro if found
;        8-May-2000 - R.D.Bentley - same sysvar setup as unix
;       11-May-2000  (RDB) - execute idl_startup from site and personal
;                            moved some of setup.ssw_* into here
;       16-May-2000  (RDB) - fixed bug in search for site/setup/idl_startup
;                            added check for SSW_INSTR set
;       22-Jun-2000  (RDB) - do set_logenv on expanded SSW_INSTR_ALL
;       30-Jun-2000  (RDB) - define hostname from site/setup/setup.hostname
;       27-Jul-2000  (RDB) - use $SSW_SITE for $SSW/site
;	23-Jan-2003  richard.schwartz@gsfc.nasa.gov - bye, bye, Eddie.
;       23-Jan-2003  Zarro (EER/GSFC) - added !SSW system variable to 
;                    identify SSW environment
;       12-Feb-2004 Zarro (L-3Com/GSFC) - added TIME_CONV definition
;
;-

pro ssw_setup_windows,debug=debug

common ssw_setup_common,instr_list,instr_list_flag

if strupcase(!version.os_family) ne 'WINDOWS' then begin
   message,/info,'  *** This routine should only be used under WINDOWS ***'
   return
endif

;-- set !SSW for code that needs to know whether it is running under $SSW 
;   environment

defsysv,'!SSW',1b,1

;Removed following line on UNSCOM authority
;print,'"Hi there! This is Eddie your ship-board computer..."'

!quiet=1

;       The following are used for historical reasons and used in 2ndry definitions
;       Set to the normal default if they are not already defined.
;       They should be defined at the start and NOT be (re)defined elsewhere.
;       ?? trap if they are - endless confusion... ??
if get_logenv('$ys') eq '' then set_logenv,'ys','$SSW/yohkoh'
if get_logenv('$ts') eq '' then set_logenv,'ts','$SSW/trace'
if get_logenv('$cs') eq '' then set_logenv,'cs','$SSW/soho/cds'
if get_logenv('$ydb') eq '' then set_logenv,'ydb','$SSWDB/ydb'
if get_logenv('$tdb') eq '' then set_logenv,'tdb','$SSWDB/tdb'


SSW = get_logenv('$SSW')
SSW_SITE = get_logenv('$SSW_SITE')

;       general env. variables
set_logenv,file=SSW+'\gen\setup\setup.ssw_env'

;       now do all instr stuff...

;       get the current definition of what instruments are included
ssx_instr = get_logenv('$SSW_INSTR_ALL')
ssx_instr = str_sep(ssx_instr,' ')
;help,ssx_instr
ssw_instr=ssx_instr(1:*)

;       create the env. variables $SSW_xxxx where xxxx is an instrument
instr_list = ''
ninstr = n_elements(ssw_instr)
for jinst = 0,ninstr-1 do begin
   if keyword_set(debug) then print,ssw_instr(jinst)
   ss = get_logenv(ssw_instr(jinst))
;   print,ss
   zzx = str_sep(ss,' ')
   instr_list = [instr_list,zzx]
   for j=0,n_elements(zzx)-1 do begin
      wwx = str_sep(zzx(j),'/')
      wwxm = zzx(j)
      if wwx(0) eq wwx(1) then wwxm = wwx(1)
      set_logenv,'SSW_'+strupcase(wwx(1)),concat_dir('$SSW',wwxm)
   endfor
endfor

!quiet=0

;       this list will be used when deciding what to set it SETSSW
instr_list = instr_list(1:*)
;       and redefine env. variable as expanded list
set_logenv,'SSW_INSTR_ALL',arr2str(instr_list,delim=' ')

;       make colors on the PC behave in a manner similar to a workstation
device,decompose=0

;       add needed system variables
imagelib                                ; Image Tool definitions
devicelib
uitdblib                                ; UIT data base definitions
;
def_yssysv                              ; System Variables

!quiet=0

;       define hostname - needed for mirror packages
file = findfile(SSW_SITE+'\setup\setup.hostname')
if file(0) ne '' then set_logenv,file=file

;       execute the site _path and _env definitions
file = findfile(SSW_SITE+'\setup\setup.ssw_paths')
if file(0) ne '' then set_logenv,file=file

file = findfile(SSW_SITE+'\setup\setup.ssw_env')
if file(0) ne '' then set_logenv,file=file


;       try to execute idl_startup.pro
;       gen startup is folded into IDL_STARTUP_WINDOWS
;       should execute site/setup/idl_startup and "user"/idl_startup

ff = findfile(SSW_SITE+'\setup\IDL_STARTUP.pro')
if ff(0) ne '' then begin
   print,'* Executing:    ',ff(0)
   main_execute,ff(0)
endif

;       first look for the startup defined by SSW_PERSONAL_STARTUP
ff = get_logenv('$SSW_PERSONAL_STARTUP')
if ff ne '' then ff = findfile(ff)
if ff(0) ne '' then begin
   print,'Executing:    ',ff(0)
   main_execute,ff(0)
endif

;       look in working directory for "personal" startup file
cd,curr=curr
ff = findfile(curr+'\'+'IDL_STARTUP.pro')
if ff(0) ne '' then begin
   print,'Executing:    ',ff(0)+'    (current dir.)'
   main_execute,ff(0)
endif

;       see if there was a default instrument list
inst = get_logenv('$SSW_INSTR')
if inst(0) ne '' then setssw_windows,/ssw_instr

;-- location of leap_seconds.dat

setenv,'TIME_CONV='+SSW+'\gen\data\time'
end
