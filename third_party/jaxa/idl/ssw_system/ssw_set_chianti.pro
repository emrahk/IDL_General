pro ssw_set_chianti, update=update
;+
;   Name: ssw_set_chianti
;
;   Purpose: set CHIANTI system variables within SSW environment
;
;   Input Parameters:
;     NONE
;
;   Keyword Parameters:
;     UPDATE - if set, force update even if alread defined.
;
;   History:
;      12-mar-1997 - S.L.Freeland (called from ssw_packages)
;      06-Jul-1999 - J.S.Newmark - upgraded
;      13-Nov-2000 - S.L.Freeland - use $SSW_CHIANTI directly
;      14-Nov-2000 - backwardly compatible/handle chianti restructure (3.1) 
;                    add "installation/upgrade required" message.
;      19-Sep-2002 - forward/backward compat for V4.
;                    Use chianti team supplied $SSW/chianti/setup/IDL_STARTUP
;                    and exit for +=V4.
;-

newvmess=['Ask your SSW sys-admin to add/upgrade via:', $
          'http://www.lmsal.com/solarsoft/ssw_install.html -OR-',$
          'IDL> ssw_upgrade,/chianti,/loud']

update=keyword_set(update)
ctop=get_logenv('SSW_CHIANTI')

if not file_exist(ctop) then begin
    box_message,['Your local SSW does not include chianti', newvmess]
    return
endif

newdb=concat_dir(ctop,'dbase')
chianti_vars=str2arr('!xuvtop,!ioneq_file,!abund_file')

chi_startup=concat_dir(concat_dir(ctop,'setup'),'IDL_STARTUP')
cv4=0                                                          ; after CVersion4?
if file_exist(chi_startup) then begin 
   scont=strlowcase(rd_tfile(chi_startup,nocom=';',/comp))
   v4chk=where(strpos(scont,'use_chianti') ne -1,v4cnt)
   cv4=v4cnt gt 0
endif

case 1 of 
   cv4: begin
      main_execute,chi_startup      ; just use Chianti IDL_STARTUP and exit
      return
   endcase
   file_exist(newdb):begin 
      chianti_vals=[newdb,'mazzotta_etal.ioneq','allen.abund']
      cvx='3'
   endcase
   else: begin
      chianti_vals=[ctop,'arnaud_rothenflug.ioneq','meyer_coronal.abund']
      cvx='2'
   endcase
endcase
box_message,['You are now properly configured to run Chianti Version ' + cvx, 'However, a newer version of Chianti is available',newvmess]

for i=0,n_elements(chianti_vars)-1 do begin
   defsysv,chianti_vars(i),exist=exist
   if update or (1-exist) then defsysv,chianti_vars(i),chianti_vals(i)
endfor

return
end

