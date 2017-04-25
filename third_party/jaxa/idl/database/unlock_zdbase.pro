;+
; Project     : SOHO - CDS     
;                   
; Name        : UNLOCK_ZDBASE
;               
; Purpose     : Unlock directories defined by ZDBASE 
;               
; Category    : Planning
;               
; Explanation : remove LOCK file created by LOCK_ZDBASE 
;               
; Syntax      : IDL> UNLOCK_ZDBASE,FILE
;    
; Examples    : 
;
; Inputs      : FILE = lock file name (with full path)
;               
; Opt. Inputs : 
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    :
;               QUIET    = set to suppress messages
;               ERR      = output messages
;               STATUS = 1/0 for success/failure
;               TIMER  = seconds to wait before retrying
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

pro unlock_zdbase,file,err=err,status=status,timer=timer,quiet=quiet,$
                  retry=retry,over=over

err='' & status=1

if datatype(file) eq 'STR' then lock_file=file else begin
 err='Please enter LOCK file name'
 status=0
 if not keyword_set(quiet) then message,err,/cont
 return
endelse

;-- check if specific directory is requested

if datatype(extra) eq 'STC' then begin
 get_zdbase,db_file,status=found,_extra=extra,err=err
 if found then begin
  break_file,db_file,ldsk,ldir,dfile
  if datatype(file) ne 'STR' then lfile='lock.dat' else begin
   break_file,file,fdsk,fdir,ffile,fext
   ffile=ffile+fext
   if trim(ffile) ne '' then lfile=ffile
  endelse
  lock_file=concat_dir(ldsk+ldir,lfile)
 endif
endif

rm_lock,lock_file,status=status,err=err,over=over,timer=timer,quiet=quiet,retry=retry

return & end

