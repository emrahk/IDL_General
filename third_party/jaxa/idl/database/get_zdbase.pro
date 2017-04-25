;+
; Project     : SOHO - CDS     
;                   
; Name        : GET_ZDBASE
;               
; Purpose     : set ZDBASE file appropriate CDS/USER/SOHO Database location
;               
; Category    : Planning
;               
; Explanation : 
;               
; Syntax      : IDL> get_zdbase,file
;    
; Examples    : 
;
; Inputs      : DBFILE = string file name to search for (e.g. 'main.dbf')
;               
; Opt. Inputs : None
;               
; Outputs     : FILE = full path name to DB file
;
; Opt. Outputs: None
;               
; Keywords    : STATUS = 1 if fil DB found, 0 if unsuccessful
;               ERR  = any error string
;               /CAT = set to look for catalog DB
;               /DEF = set to look for study definitions DB [default]
;               /DAI = set to look for plan DB
;               /RES = set to look for resources (e.g. campaign, etc)

; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; History     : Version 1,  7-September-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro get_zdbase,file,status=status,err=err,_extra=extra

status=0 & err=''

zdbase=trim(getenv('ZDBASE'))
if zdbase eq '' then begin
 err='Undefined ZDBASE'
 message,err,/cont
 return
endif

keywords=['DAI','CAT','DEF','RES','SEA']
db_files=['sci_plan.dbf','main.dbf','study.dbf','resource.dbf',$
          'instrument.dbf']

;--- type of database being selected 

if datatype(extra) eq 'STC' then begin
 tags=strmid(tag_names(extra),0,3)
 ikey=where_vector(tags,keywords,count)
 if count gt 0 then begin
  key_tags=keywords(ikey)
  ikey=where(key_tags(0) eq keywords,count)
  if count gt 0 then ifil=ikey(0)
 endif
endif

if not exist(ifil) then begin
 err='No database entered'
 message,err,/cont
 return
endif

db_file=db_files(ifil)

file=find_with_def(db_file,'ZDBASE')

status=trim(file) ne ''

return & end

