;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_ZDBASE
;               
; Purpose     : set ZDBASE to appropriate CDS/USER/SOHO Database location
;               
; Category    : Planning
;               
; Explanation : Searches personal and official DB locations
;               
; Syntax      : IDL> find_zdbase,type,status=status
;    
; Examples    : 
;
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : TYPE = 'User', 'CDS', 'SOHO', or 'Unknown'
;
; Opt. Outputs: None
;               
; Keywords    : STATUS = 1 if DB found, 0 if unsuccessfull
;               /CAT = set to look for catalog DB
;               /DEF = set to look for study definitions DB [default]
;               /DAI = set to look for plan DB
;               /RES = set to look for resources (e.g. campaign, etc)
;               /OFF_FIRST = search official before personal DB
;               FILE = full path name to DB file
;               ERR  = any error string
;               NORETRY = don't retry by cycling thru different DB's
;               VERBOSE = echo messages
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: Environment/logical ZDBASE set to first found DB location
;               
; History     : Version 1,  7-September-1996,  D M Zarro.  Written
;		Version 2, 11-Mar-1997, William Thompson, GSFC
;			Fixed problem under VMS when logical name ZDBASE has
;			multiple values.
;               Version 3, 23-April-1998, Zarro (SAC/GSFC), added /VERBOSE
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro find_zdbase,type,status=status,off_first=off_first,verbose=verbose,$
                file=file,err=err,_extra=extra,noretry=noretry

retry=1-keyword_set(noretry)
status=0 & type='Unrecognized' & file='' & err=''
zdbase=trim(get_environ('ZDBASE'))
zdbase_user=trim(get_environ('ZDBASE_USER'))
zdbase_cds=trim(get_environ('ZDBASE_CDS'))
zdbase_soho=trim(get_environ('ZDBASE_SOHO'))
defsysv,'!priv',3

keywords=['DET','DAI','CAT','DEF','RES','SEA']
db_files=['sci_details.dbf','sci_plan.dbf','main.dbf','study.dbf','resource.dbf',$
          'instrument.dbf']

;--- type of database being selected [def = PLANS]

ifil=0
if datatype(extra) eq 'STC' then begin
 tags=strmid(tag_names(extra),0,3)
 ikey=where_vector(tags,keywords,count)
 if count gt 0 then begin
  key_tags=keywords(ikey)
  ikey=where(key_tags(0) eq keywords,count)
  if count gt 0 then ifil=ikey(0)
 endif
endif
db_file=db_files(ifil)

;-- search current, USER, CDS, and SOHO DB's

soho_first=keyword_set(soho_first)
off_first=keyword_set(off_first)
first_key='/user' & sec_key='/cds'
if off_first then begin
 first_key='/cds' & sec_key='/user'
endif

for i=0,3 do begin
 err=''
 case i of
  0:   try_it=zdbase(0) ne ''
  1:   s=execute('try_it=fix_zdbase('+first_key+',err=err)')
  2:   s=execute('try_it=fix_zdbase('+sec_key+',err=err)')
 else: try_it=fix_zdbase(/soho,err=err)
 endcase
 if try_it then begin
  file=find_with_def(db_file,'ZDBASE')
  if trim(file) ne '' then begin
   type=strupcase(which_zdbase())
   if (type eq 'ORIGINAL') then begin
    case i of
     0: begin
         if (zdbase_user eq '') and (zdbase_cds ne '') then type='CDS' else $
          if (zdbase_cds eq '') and (zdbase_user ne '') then type='User' else begin
           if (zdbase_cds ne '') and (zdbase_user ne '') then begin
            exp_zdbase
            if getenv('ZDBASE') eq zdbase_user then type='User' else $
             if getenv('ZDBASE') eq zdbase_cds then type='CDS'
           endif
          endelse
        end
     1: if (first_key eq '/cds') then type='CDS' else type='User'
     2: if (sec_key eq '/cds') then type='CDS' else type='User'
     else: type='SOHO'
    endcase
   endif
   if keyword_set(verbose) then message,'setting DB to type - '+type,/cont
   status=1
   return
  endif else begin
   if not retry then begin
    err='Could not find pertinent DB files in ZDBASE'
    status=0
    return
   endif
  endelse
 endif
endfor

err='Could not set DB. Please point ZDBASE to DB directories.'
if err ne '' then message,err,/cont
return & end



