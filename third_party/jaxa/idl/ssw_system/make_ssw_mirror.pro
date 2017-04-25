pro make_ssw_mirror, local_env=local_env, master_env=master_env, $
		     mirror_file=mirror_file, $
		     rdircol=rdircol, yohkoh=yohkoh, debug=debug, $
                     remote_user=remote_user, remote_password=remote_password
;+
;   Name: make_ssw_mirror
;
;   Purpose: generate the mirror file required for SSW install/upgrades
;
;   Input Parameters:
;      local_env -  file name containing Environmentals to include
;      master_env - file with remote Environmental:directory mapping
;
;   Keyword Parameters:
;      mirror_file - optional user supplied name of mirror file
;      yohkoh - switch. If set, uses Yohkoh dbase defaults  
;      remote_user, remote_password - optional (default=ANONYMOUS ftp)
;
;   Calls:
;      make_mirror
;
;   Notes:
;      SITE environmental files are expected in the form...
;        # full or partial ok - any column
;        # last edited date, version# etc.
;        #   coment lines 
;        # name            ; [optional comments]                     
;         ENVIRON1          ; optional comment to include in package  # comment
;         ENVIRON2          ; optional comment to show up in package
;         #comments...      Note environ4 is commented out (ignored in mirror)
;         ENVIRON3          ; optional comment to show up in package  # comment
;         #ENVIRON4          ; optional comment to show up in package
;         ENVIRON5          ;
;         (etc)
;  History:
;      18-mar-1996 (S.L.Freeland) SSW Installation and Upgrades
;      21-oct-1996 (S.L.Freeland) Add /YOHOKH switch (work with pubconfig) 
;                                 Input from Bob Bentley 
;      23-oct-1996 (S.L.Freeland) Document, add remote_user, remote_password
;      24-oct-1996 (S.L.Freeland) Add /MODE_COPY in make_mirror call 
;
;   Category:
;      SSW , system 
;
;   Restrictions:
;      Assumes "SSW" or Yohkoh SW environment
;-
; provide backward compatibility with original Yohkoh (pubydb.config)
yohkoh = keyword_set(yohkoh)
if n_elements(rdircol) eq 0 then rdircol=([1,2])(yohkoh)  ; assume colum 1
               
;  ---- Read local (SITE) file to get list of desired environmentals ----
mfname='mirror_env.map'                             ; default file name
if not keyword_set(local_env) then begin
   case 1 of
     keyword_set(yohkoh): local_env=concat_dir('DIR_SITE_SETUP',mfname)
     else: local_env = concat_dir(concat_dir('SSW_SITE','mirror'),mfname)
   endcase
endif

; -------- Read master (SSW or Yohkoh) environmental->directory map file ---
if not keyword_set(master_env) then begin
   case 1 of
      keyword_set(yohkoh): master_env=concat_dir('DIR_GEN_SETUP','pubydb.config')
      else:  master_env = concat_dir(concat_dir('SSW_GEN','mirror'),mfname)
   endcase
endif   

; ------------- verify both files found -----------------
need=[master_env, local_env] & comment=['Master (remote)','SITE (local)'] 
chk=where(1-file_exist(need),ncnt)
if ncnt gt 0 then begin
   prstr,['Cannot find file' + (['','s'])(ncnt gt 1) + '...', comment(chk) + ': ' +need(chk)]
   return
endif

; - read the files (rd_tfile - strips comments and sepearates env from comments
locals=strtrim(rd_tfile(local_env,delim=';',/nocomment,2),2)
remotes=strtrim(rd_tfile(master_env,delim=';',/nocomment,/auto),2)
nrcols=n_elements(remotes(*,0))                      ; number of columns read

lenvs=reform(locals(0,*))                            ; ENVs assumed first col
lcom =reform(locals(n_elements(locals(*,0))-1,*))    ; comments assumed last col

renvs=reform(remotes(0,*))                           ; number columns
rdirs=reform(remotes(rdircol,*))                     ; ENVS in first column
rcom =reform(remotes(n_elements(remotes(*,0))-1,*))  ;

; match local (SITE) ENV request to corresponding remote ENV
flist=-1
for i=0,n_elements(lenvs)-1 do flist=[flist,(where(lenvs(i) eq renvs))(0)]
flist=flist(1:*)
matchok=where(flist ne -1,okcnt)

; verify at least some matches found
case 1 of
  okcnt eq 0: begin
      message,/info,"NONE of your local ENVS mapped into a remote ENV!"
      return
  endcase
  okcnt lt n_elements(flist): $
         message,/info,"No remote ENV for at least one of your local ENVs (continuing..)"
	 else:
endcase

; ------- if not defined, define mirror site and mirror file name -------
if yohkoh then begin
   mirror_site=get_logenv('yssw_sw_host')  
   mirror_site=([mirror_site,'isass0.solar.isas.ac.jp'])(mirror_site eq '')

   if n_elements(mirror_file) eq 0 then begin 
      mname='yohkoh_dbase.mirror'
      outdir='$' + (['DIR_SITE_SCRIPT','SSW_SITE_MIRROR'])(file_exist(get_logenv('SSW_SITE_MIRROR')))               
      mirror_file=concat_dir(outdir,mname)
   endif

 endif else begin
   mirror_site=get_logenv('ssw_mirror_site')
   mirror_site=([mirror_site,'sohoftp.nascom.nasa.gov'])(mirror_site eq '')
   if not keyword_set(mirror_file) then mirror_file=$
      concat_dir(concat_dir('SSW_SITE','mirror'),'make_ssw_mirror.mirror')
endelse   

if keyword_set(debug) then stop,'before make_mirror...'
; call mirror package generator (note use of get_logenv on local env vector)
make_mirror,mirror_site,rdirs(flist(matchok)),get_logenv(lenvs(matchok)), $
   packages=str_replace(renvs(flist(matchok)),'$',''), mirror_file=mirror_file, $
   comments=lcom(matchok), $
   remote_user=remote_user, remote_password=remote_password, /mode_copy

return
end
