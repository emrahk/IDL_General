;+
;   Name:  go_update_ssw
;
;   Purpose: single point routine to maintain SSW system at remote sites
;
;   Motivation:
;      Main program which (originally) just calls S.L.Freeland routine
;      SSW_UPGRADE.PRO to force an update of the local $SSW tree.
;      See SSW_UPGRADE doc header for options/information.
;      Generally called via cron job (via $SSW/gen/bin/ssw_batch)
;
;      Extended to functioning as a single point SSW maintenence cron job
;      so calls to other routines may be added here without requiring
;      user to update the existing cron references.
;
;   History:
;	        16-Apr-97 M.D.Morrison - batch front end->SLF SSW_UPGRADE
;                2-May-97 S.L.Freeland - document and extend 'scope'
;                9-may-97 S.L.Freeland - add call to SSW_CHECK_CONTRIB
;               17-sep-97 S.L.Freeland - Allow instrument upgrade specification
;                                        ($SSW_INSTR) via configuration file:
;                                        $SSW/site/setup/setup.ssw_upgrade
;		31-Mar-98 M.D.Morrison - Disabled ssw_check_contrib temporarily
;               27-Jan-99 S.L.Freeland - run sswdb_upgrade if
;                                        $SSW/site/setup/setup.sswdb_upgrade exists
;Restrictions:
;   Perl5 must exist on local machine - installed in '/usr/local/bin/perl'
;                                       or must have Perl link with that name
;-
;  ----- S.L.Freeland - add option of site upgrade configuration file ----
upconfig='setup.ssw_upgrade'
ssw_upgradef=concat_dir('$SSW_SITE_SETUP',upconfig) ; AKA $SSW/site/setup/...
if not file_exist(ssw_upgradef) then $
    ssw_upgradef=concat_dir(get_logenv('HOME'),'.cshrc') ; backward compatible
;
sswenv='SSW_INSTR'
if file_exist(ssw_upgradef) then begin
   setup=strtrim(rd_tfile(ssw_upgradef,/nocomment),2)
   ssw_inst=where(strpos(setup,sswenv) ne -1,sscnt)
;  extract the instruments (semi free form permitted)
   if sscnt gt 0 then begin
      setline=strlowcase(str_replace(str_replace(setup(ssw_inst(0)),'"',' '),'"',' '))
      setline=strcompress(strtrim(str_replace(str_replace(setline,strlowcase(sswenv),' '),',',' '),2))
      setline=str_replace(setline,'setenv','')
;     Now set SSW_INSTR based on instrument list
      set_logenv,sswenv,setline
      prstr,strjustify(['Using definition of $SSW_INSTR from file:', $
	    '   ' + ssw_upgradef],/box)
   endif
endif  else message,/info,"No configuration file, using predefined $SSW_INSTR"
;
; ----------- run program to update local SSW from SSW master -------------
ssw_upgrade, /spawnit, group=get_group(), /verbose
; -------------------------------------------------------------------------

; --------- SSWDB upgrade if site config exists ------------------
sswdb_config=concat_dir('$SSW_SITE_SETUP','setup.sswdb_upgrade') ; AKA $SSW/site/setup/...
if file_exist(sswdb_config) then begin
   box_message,'Updating SSWDB...'
   sswdb_upgrade,/spawn, group=get_group(),/verbose
endif  

; ------------- check for local contribution resolution -------------------
;;;;;ssw_check_contrib 
; -------------------------------------------------------------------------
;
end
