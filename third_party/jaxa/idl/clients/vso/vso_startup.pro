;+
; Project     : VSO
;
; Name        : VSO_STARTUP
;
; Purpose     : Load Java libraries
;
; Category    : vso utility sockets
;
; Example     : IDL> vso_startup [,status=status]
;
; Inputs      : None
;
; Keywords    : STATUS= 1/0 for success or failure             
;               USER_PATH = user directory with Java libraries
;               RESET = set to reset CLASSPATH
;               CPONLY = Only set the CLASSPATH, don't locate Java
;
; History     : Written 31-March-2009, D.M. Zarro (ADNET)
;               16-Jun-09, Kim 
;                - added doc header, status keyword, and check for IDL version
;               23-June-09, Zarro (ADNET) 
;                - added USER_PATH and removed IDL 6.4 limitation
;                  since it won't break anything and can be
;                  useful for other applications.
;               15-Mar-2010, L. I. Etesi (CUA,FHNW/GSFC) 
;                - added locate_java call
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
; 
;-

pro vso_startup, status=status,reset=reset,user_path=user_path,cponly=cponly,_ref_extra=extra

status = 1b

;-- bail if JAVA unavailable

if ~keyword_set(cponly) then locate_java, status=status,_extra=extra

if ~status then return

;-- reset CLASSPATH if wanting to start again

if keyword_set(reset) then mklog,'CLASSPATH',''

add_classpath,user_path,/before,_extra=extra
add_classpath, !DIR + "/resource/bridges/export/java",_extra=extra
add_classpath, !DIR + "/resource/bridges/import/java",_extra=extra
add_classpath, "$SSW/gen/java/vso/libs",_extra=extra
add_classpath, "$SSW/gen/java/prepserver/libs",_extra=extra
add_classpath, "$SSW/gen/java/slibs",_extra=extra

return & end
