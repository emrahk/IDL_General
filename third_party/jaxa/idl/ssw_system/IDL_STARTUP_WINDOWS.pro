;
;+
;   Name: IDL_STARTUP_WINDOWS
;
;   Purpose: Initial startup file for Windows
;
;   Input Parameters:
;               None
;   Calling Examples:
;
;               Should be called as prefered startup file
;
;   Restrictions:
;               WINDOWS only
;               Must be called as initial startup file
;   History:
;        1-Jun-1999 - R.D.Bentley  - Created
;        9-Jun-1999 - S.L.Freeland - renamed IDL_WINDOWS_STARTUP=>IDL_STARTUP_WINDOWS
;       18-Mar-2000 - R.D.Bentley  - added gen/idl_libs; reordered the path assembly
;       23-Mar-2000 - R.D.Bentley  - fixed typo from 18/3 edit
;       17-Apr-2000 - R.D.Bentley  - removed $ from initial env. var. checks
;                                    delvar on variables used to make path
;       09-May-2000 - (RDB) - small code reorder...
;       26-Jul-2000 - (RDB) - added default definition of SSW_SITE
;
;-

;       If the SSW and SSWDB branches of SolarSoft are stored under C:\ then
;       the following will define the environment variables correctly without
;       the need to define them elsewhere. If the branches are to be stored in
;       a different location, define environment variables SSW and SSWDB
;       before calling IDL.

if getenv('SSW') eq '' then setenv,'SSW=C:\ssw'
if getenv('SSWDB') eq '' then setenv,'SSWDB=C:\sswdb'

SSW = getenv('SSW')

;       following may be needed if site branch not part of main SSW tree
if getenv('SSW_SITE') eq '' then setenv,'SSW_SITE='+SSW+'\site'
SSW_SITE = getenv('SSW_SITE')


;       Need to define this much path so that the SolarSoft tree is available.
;       The first line site dependant changes to be made
path = expand_path('+'+SSW_SITE+'/idl')
path = path + ';' + expand_path('+'+SSW+'/gen/idl')
path = path + ';' + expand_path('+'+SSW+'/gen/idl_libs')
!path = path + ';' + !path

delvar,path,ssw

;       define the SSW_XXXX stuff
ssw_setup_windows
