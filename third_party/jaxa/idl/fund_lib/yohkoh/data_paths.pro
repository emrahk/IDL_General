;+
; Project     : YOHKOH     
;                   
; Name        : DATA_PATHS
;               
; Purpose     : check for directories/subdirectories pointed to by
;               environmentals named yd* where * is an integer (e.g. yd1)
;               
; Category    : utility
;               
; Explanation : Used by Yohkoh software such as YODAT and WBDA
;               
; Syntax      : IDL> paths=data_paths()
;    
; Examples    : 
;
; Inputs      : None.
;               
; Opt. Inputs : SELECT = index to select 
;               (e.g. path=data_paths(0) for first path element)
;               
; Outputs     : paths = list of directories under yd*
;
; Opt. Outputs: None.
;               
; Keywords    : RESET = nulls last search results
;               QUIET = turn off messages
;
; Common      : DATA_PATHS = stores last search results.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; History     : 1-Dec-93, D. Zarro (ARC) - written (based on Yohkoh version)
;               28-Dec-97, Zarro (SAC) - modified for SSW compatibility
;               5-Jan-98, Zarro (SAC) - modified for SSW (again)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function data_paths, select,reset=reset,quiet=quiet

common data_paths,dpaths

loud=1-keyword_set(quiet)
if keyword_set(reset) then delvarx,dpaths
paths=''
if !version.os eq 'vms' then begin
 s='istat = trnlog("ydnn",paths,/full,/issue_error)'
 s=execute(s)
endif else begin
 chk=getenv('ys')

;-- check the old YS way, otherwise look for yd* and subdirs

 look=findfile(chk+'/site/setup/setup.ysdpaths',count=nf)

;-- see if setup.ysdpaths in SSW

 if nf eq 0 then begin
  chk=getenv('SSW')
  look=findfile(chk+'/site/setup/setup.ysdpaths',count=nf)
 endif

 if nf ne 0 then paths=rd_tfile(look(0),/nocomment,/quiet) 
 if trim(paths(0)) eq '' then begin
  if datatype(dpaths) eq 'STR' then paths=dpaths else begin
   if loud then message,'checking yd* environmentals',/cont
   espawn,'printenv | grep yd',out
   out=trim(out)
   if out(0) ne '' then begin

;-- look for patterns: "yd* = "
 
    eq_pos=strpos(out,'=') & yd_pos=strpos(out,'yd')
    ok=where( (eq_pos gt -1) and (yd_pos lt eq_pos),count)
    if count gt 0 then begin
     envs=out(ok) & eq_pos=eq_pos(ok) & dpaths=''
     for i=0,count-1 do begin
      dlog=strmid(envs(i),eq_pos(i)+1,strlen(envs(i)))
      dname=strmid(envs(i),0,eq_pos(i))
      dpos=strpos(dname,'yd')
      num=strmid(dname,dpos+2,strlen(dname))

;-- look for yd* where * is a number

      if is_number(num) then begin
       chk=getenv(dlog)
       if chk ne '' then dlog=chk
       if chk_dir(dlog) then begin
        subs=get_subdirs(dlog)
        dpaths=[dpaths,subs]
       endif
      endif
     endfor
    endif
   endif
   if n_elements(dpaths) gt 1 then begin
    sorder = uniq([dpaths],sort([dpaths]))
    dpaths=dpaths(sorder)
    paths=dpaths
   endif 
  endelse
 endif
endelse

;-- append current directory

cd,current=curr
clook=where(strupcase(curr) eq strupcase(paths),count)
if count eq 0 then paths=[paths,curr]
ok=where(trim(paths) ne '',count)
if count gt 0 then paths=paths(ok)
if n_elements(select) eq 0 then select=indgen(n_elements(paths))
paths=paths(select)
if n_elements(paths) eq 1 then paths=paths(0)

return,paths

end
