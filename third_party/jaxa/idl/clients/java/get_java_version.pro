;+
; Project     : VSO
;
; Name        : GET_JAVA_VERSION
;
; Purpose     : Return JVM version
;
; Example     : IDL> version=get_java_version(status)
;
; Outputs     : VERSION = Java version number
;               STATUS =1 or 0 if standard or not
;
; History     : 16-June-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_java_version,status

espawn,'java -version',out,/noshell
test=arr2str(out)
version=stregex(test,'"(.+)"',/extract,/sub)
status=stregex(test,'standard',/bool,/fold)

return,version[1]
end
