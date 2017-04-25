;+
; Project     : RHESSI
;
; Name        : ADD_CLASSPATH
;
; Purpose     : append JAVA class files to current CLASSPATH
;
; Category    : utility, java
;
; Syntax      : add_classpath,path
;
; Inputs      : PATH = directories containing CLASS files
;
; Outputs     : Environment variable $CLASSPATH is re-defined with CLASS files in PATH
;
; Keywords    : BEFORE = set to prepend
;               VERBOSE = set to echo results
;
; History     : Written 16 Sept 2008, Zarro (ADNET)
;               Modified 3 August 2011, Zarro (ADNET)
;                - included fix for Windows/IDL 8.0
;
; Contact     : dzarro@solar.stanford.edu
;-

pro add_classpath,path,before=before,verbose=verbose,err=err

err=''
if is_blank(path) then return
old_path=chklog('CLASSPATH')
verbose=keyword_set(verbose)
class_files=loc_file('*.jar',path=local_name(path),count=count)
if count eq 0 then begin
 err='No CLASS files found in '+arr2str(path)
 if verbose then message,err,/cont
 return
endif

;-- append (or prepend) new class files, checking for duplicates

delim=get_path_delim()
v8=since_version('8.0')
windows=os_family() eq 'Windows'
delim2=get_delim()

if is_string(old_path) then begin
 curr_classes=trim(str2arr(old_path,delim=delim))
 for i=0,n_elements(class_files)-1 do begin
  new_class=trim(class_files[i])
  if windows and v8 then new_class=delim2+new_class
  ckk=where(new_class eq trim(curr_classes),count)
  if count eq 0 then tclass=append_arr(tclass,new_class)
 endfor
 if ~exist(tclass) then begin
  if verbose then message,'No new class files added',/cont
  return
 endif
 if keyword_set(before) then class_files=[tclass,curr_classes] else $
  class_files=[curr_classes,tclass]
endif

new_path=strtrim(arr2str(class_files,delim=delim),2)

mklog,'CLASSPATH',new_path

if verbose then begin
 message,'CLASSPATH set to - ',/cont
 message,chklog('CLASSPATH'),/noname,/cont
endif

return & end
