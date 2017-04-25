;
;+
;   Name: setssw_windows
;
;   Purpose: Emulate script SETSSW for window
;               Executes any _paths or _env files, then creates path.
;
;   Input Parameters:
;               required instruments selected by keyword....
;   Calling Examples:
;
;               setssw_windows,/trace,/sxt
;
;   Calls:
;               set_logenv, ssw_path
;   Keyword Parameters:
;       ssw_instr   if set, use instruments in SSW_INSTR env. variable
;               verbose         if set, more info. printed
;   Restrictions:
;       WINDOWS only
;   History:
;        1-Jun-1999 (RDB) - Created
;        3-Jun-1999 (SLF) - renamed setssw.pro->setssw_windows.pro
;       29-Mar-2000 (RDB) - do site env. after instrument at instrument level
;        8-May-2000 (RDB) - add ucon dirs to path if yohkoh included
;                           execute instrument and personal IDL_STARTUP files
;       12-May-2000 (rdb) - moved setup.ssw_paths into ssw_seup_windows
;                           forther refinements on startups
;       16-May-2000 (rdb) - use env. var. SSW_INSTR if keyword set
;       30-Jun-2000 (rdb) - check if common block variables defined - error if not
;       27-Jul-2000 (rdb) - also execute setup.xxx; use $SSW_SITE for $SSW/site
;       15-Jan-2004 (WTT) - Allow files ending in "_win" to replace standard
;                           files in Windows.
;
;-

pro setssw_windows,verbose=verbose,ssw_instr=ssw_instr,_extra=_extra

common ssw_setup_common,instr_list,instr_list_flag      ;defined in ssw_setup_windows

if strlowcase(!version.os_family) ne 'windows' then $
   message,/info,'  *** This routine should only be used under WINDOWS ***'
print,''

if n_elements(instr_list) eq 0 then begin
   msg = ['       ****   There seems to be a problem   ****       ', $
          'Common block  "ssw_setup_common"  variables NOT defined', $
          '>> Check SSW was started using  IDL_STARTUP_WINDOWS  <<', $
          '>> This calls SSW_SETUP_WINDOWS to initialize things <<', $
          '  Type  help_windows  for information on starting SSW  ']
   box_message,msg
   return
endif

quiet = 1-keyword_set(verbose)
!quiet = 1

SSW = get_logenv('$SSW')
SSW_SITE = get_logenv('$SSW_SITE')      ;may be needed...
instr_list_flag = intarr(n_elements(instr_list))


;       examine the keywords and see what was selected
instr=''
if n_elements(_extra) eq 1 then begin
   instr=tag_names(_extra)

endif else begin
   ii = str2arr(strupcase(get_logenv('$SSW_INSTR')),' ')
   ;help,ii & print,ii
   if ii(0) ne '' then begin
      if keyword_set(ssw_instr) then begin
         instr=ii
         print,'*** Instrument list set using $SSW_INSTR'
;       need to set _extra for ssw_path
         ninst = n_elements(instr)
         res = execute(string(instr(0),format='(6htemp={,a,2h:1,1h})'))
         if ninst gt 1 then for jt=1,ninst-1 do temp=add_tag(temp,1,instr(jt))
;         help,/st,temp
         _extra=temp
      endif
   endif
endelse

if keyword_set(verbose) then begin
   help,instr
   print,instr
endif
if instr(0) eq '' then begin
      print,'** No instruments selected **'
      return
endif

for j = 0,n_elements(instr)-1 do begin
   wq = where(strpos(strupcase(instr_list),instr(j)) ge 0)
   if wq(0) ge 0 then instr_list_flag(wq(0)) = 1
endfor

;       following were selected...
print,'* Following instruments selected:'
print,instr_list(where(instr_list_flag gt 0))
;print,instr_list_flag


qq = strarr(2,n_elements(instr_list))
for j=0,n_elements(instr_list)-1 do qq(*,j)=str_sep(instr_list(j),'/')
;help,qq

qq = qq(*,where(instr_list_flag gt 0))
;help,qq

;;;     execute the site path definition
;;file = findfile(SSW_SITE+'\setup\setup.ssw_paths')
;;if file(0) ne '' then set_logenv,file=file

;       define env. variables at mission level
print,'* Mission level setup files'
missions = qq(0,uniq(qq(0,*)))
isy = 0 & if max([strpos(missions,'yohkoh')]) ge 0 then isy=1
iss = 0 & if max([strpos(missions,'soho')]) ge 0 then iss=1

for j=0,n_elements(missions)-1 do begin
;               generic setup...
;       do setup.xxxx_paths then setup.xxxx_env
   wwx = SSW+'\gen\setup\setup.'+missions(j)
   file = findfile(wwx+'_paths_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_paths')
       if file(0) ne '' then set_logenv,file=file
   endelse
   file = findfile(wwx+'_env_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_env')
       if file(0) ne '' then set_logenv,file=file
   endelse
;               site specific setup
;       do setup.xxxx_paths then setup.xxxx_env
   wwx = SSW_SITE+'\setup\setup.'+missions(j)
   file = findfile(wwx+'_paths_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_paths')
       if file(0) ne '' then set_logenv,file=file
   endelse
   file = findfile(wwx+'_env_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_env')
       if file(0) ne '' then set_logenv,file=file
   endelse
endfor

;       now define those set at the instrument level
;       do setup.xxxx_paths then setup.xxxx_env
print,'* Instrument level setup files'
startup = ''
for j=0,n_elements(qq)/2-1 do begin
   mission_set = arr2str(qq(*,j),'\')
   if qq(0,j) eq qq(1,j) then mission_set = qq(1,j)   ;e.g. trace/trace
;
   wwx = SSW+'\'+mission_set+'\setup\setup.'+qq(1,j)
   file = findfile(wwx+'_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx)
       if file(0) ne '' then set_logenv,file=file
   endelse
   file = findfile(wwx+'_paths_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_paths')
       if file(0) ne '' then set_logenv,file=file
   endelse
   file = findfile(wwx+'_env_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_env')
       if file(0) ne '' then set_logenv,file=file
   endelse
;       do site version of the instrument file
   wwx = SSW_SITE+'\setup\setup.'+qq(1,j)
;   print,wwx
   file = findfile(wwx+'_env_win')
   if file(0) ne '' then set_logenv,file=file else begin
       file = findfile(wwx+'_env')
       if file(0) ne '' then set_logenv,file=file
   endelse

   ff = findfile(SSW+'\'+mission_set+'\setup\IDL_STARTUP*')
   if ff(0) ne '' then startup=[startup,ff(0)]

endfor

if keyword_set(verbose) then help,_extra,/st

;       Set path to include whatever instruments were set by keywords
;       Note: $SSW_xxxx (where xxxx is an instrument) must have been set
;       before this can be done. If the standard location define by $SSW_xxxx
;       needs to be changed, this should be done in the setup.xxxx_env file in
;       directory $SSW/site/setup (e.g to change HESSI to released version).
;
ssw_path,_extra=_extra,quiet=quiet
if isy then ssw_path,/ucon,/yohkoh,quiet=quiet
;if iss then ssw_path,/soho

!quiet=0

;
;       execute instrument and personal IDL_STARTUP files
;
if n_elements(startup) gt 1 then begin
   startup=startup(1:*)
   print,'* Instrument level startup files'
   for j=0,n_elements(startup)-1 do begin
      print,'Executing:    ',startup(j)
      main_execute,startup(j)
   endfor
endif

print,'* Personal startup files'
;       first look for the startup defined by SSW_PERSONAL_STARTUP
ff = get_logenv('$SSW_PERSONAL_STARTUP')
if ff ne '' then ff = findfile(ff)
if ff(0) ne '' then begin
   print,'Executing:    ',ff(0)
   main_execute,ff(0)
endif

;       look in working directory for "personal" startup file
cd,curr=curr
ff = findfile(curr+'\'+'IDL_STARTUP.pro')
if ff(0) ne '' then begin
   print,'Executing:    ',ff(0)+'    (current dir.)'
   main_execute,ff(0)
endif

end
