;+
; Project     : SOHO - CDS     
;                   
; Name        : LOCK_ZDBASE
;               
; Purpose     : Lock directories defined by ZDBASE 
;               
; Category    : Planning
;               
; Explanation : creates a LOCK file in a specific directory in ZDBASE
;               
; Syntax      : IDL> LOCK_ZDBASE,FILE
;    
; Examples    : IDL> lock_zdbase,/daily
;
; Inputs      : None
;               
; Opt. Inputs : FILE = optional lock file name (def = lock.dat)
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    :
;               QUIET    = set to suppress messages
;               ERR      = output messages
;               LOCK_FILE = created LOCK file
;               EXPIRE  = expiration time after creation
;               STATUS = 1/0 for success/failure
;               /CAT = set to lock for catalog DB
;               /DEF = set to lock study definitions DB
;               /DAI = set to lock for plan DB
;               /RES = set to lock resources DB (e.g. campaign, etc)
;               CHECK_ONLY = check for LOCK file
;
; Common      : None
;               
; Restrictions: Must have write access to ZDBASE directories
;               
; Side effects: None.
;               
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro lock_zdbase,file,status=status,_extra=extra,expire=expire,$
   check_only=check_only,quiet=quiet,err=err,lock_file=lock_file,over=over

lock_file='' & status=1 & err=''

;-- look for database location 

get_zdbase,db_file,status=status,err=err,_extra=extra
if not status then return

;-- use input file for locking, otherwise default to 'lock.dat'
;   in ZDBASE directory

break_file,db_file,ldsk,ldir,dfile
if datatype(file) ne 'STR' then lfile='lock.dat' else begin
 break_file,file,fdsk,fdir,ffile,fext
 ffile=ffile+fext
 if trim(ffile) ne '' then lfile=ffile
endelse
lock_file=concat_dir(ldsk+ldir,lfile)

;-- check if same file is locked by someone else
;   If not then remove it.

check_only=keyword_set(check_only)
quiet=keyword_set(quiet)
if keyword_set(over) then rm_file,lock_file
expired=check_lock(lock_file,quiet=check_only or quiet,err=err)

if check_only then status=expired else begin
 if expired then begin
  apply_lock,lock_file,err=err,quiet=quiet,status=status,expire=expire
 endif else status=0
endelse

return
end


