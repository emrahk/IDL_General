;+
; Project     : SOHO - CDS     
;                   
; Name        : APPEND_SDB
;               
; Purpose     : append 'sdb' directories  to ZDBASE
;               
; Category    : Planning
;               
; Syntax      : IDL> append_sdb
;    
; Side effects: Environment/logical ZDBASE is reset
;               
; History     : 15-Feb-2004, Zarro (L-3Com/GSFC), Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro append_sdb,original=original,err=err,verbose=verbose

err=''

common append_sdb,orig_zdbase

verbose=keyword_set(verbose)

if keyword_set(original) and is_string(orig_zdbase) then begin
 mklog,'ZDBASE',orig_zdbase
 exp_zdbase
 if verbose then print,chklog('ZDBASE')
 return
endif

zdb=chklog('ZDBASE')
if is_blank(orig_zdbase) and is_string(zdb) then orig_zdbase=zdb

;-- check for SDB databases

case 1 of
 is_dir('$sdb',out=out): sdb = out
 is_dir('$SSWDB',out=out): sdb=out
 is_dir('$SDB',out=out): sdb=out
 else: begin
  err='sdb environmental not defined'
  if verbose then message,err,/cont
  return
 end
endcase

sdb_dir=local_name(sdb+'/soho/cds/data/plan/database')
if not is_dir(sdb_dir) then return

;-- check if SDB already appended

spos=strpos(zdb,sdb_dir)
if spos gt -1 then return

sdbase='+'+sdb_dir
delim=get_path_delim()
if is_blank(zdb)  then zdbase=sdbase else zdbase=zdb+delim+sdbase

mklog,'ZDBASE',zdbase
exp_zdbase

if verbose then print, chklog('ZDBASE')

return & end
