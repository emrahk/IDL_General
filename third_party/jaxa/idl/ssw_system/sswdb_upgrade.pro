pro sswdb_upgrade, relsets, _extra=_extra,             $
		 outdir=outdir, outpackage=outpackage, $
                 passive_ftp=passive_ftp,              $
		 nopackage=nopackage,                  $
		 nospawn=nospawn, noexecute=noexecute, $
		 local_sets=local_sets, remote_sets=remote_sets, $
		 debug=debug, spawnit=spawnit, $
		 loud=loud, verbose=verbose, result=result, $
		 user=user, group=group, mirror=mirror, local_mirror=local_mirror
;+
; Name: sswdb_upgrade
;
; Purpose: generate SSWDB set list, generate packages and spawn mirror job
;
; Input Parameters:
;   relsets -    list of directories under $SSWDB, or list of environment
;                variables, indicateing direcories to be updated.
;                (optional - if absent, tries to use setup.sswdb_upgrade)
;
; Keyword Parameters:
;   outdir -     local path to keep mirror files (def=$SSW_SITE_MIRROR)
;   outpackage - name of mirror file (def='sswdb_upgrade.mirror')
;   no package - if set, do not generate new package
;   spawnit    - if set, spawn the mirror job
;   nospawn    - if set, do not spawn/execute mirror (ex: just make package) DEFAULT
;   noexecute  - synonym for nospawn
;   remote_sets (output) - list of remote sets/paths (on SSW master)
;   local_sets  (output) - list of local ( relative to $SSWDB)
;   loud - switch, if set, echo Mirror output
;   verbose - switch , if set, synonym for /LOUD
;   result (output) - output of mirror command
;   mirror - optional path/name of mirror to run (default = ssw_bin('mirror'))
;   passive_ftp - force use of Passive ftp, required by some firewalls/proxys
;                 (same effect is had by setting $ssw_passive_ftp outside)
;
; Calling Examples:
;
;   sswdb_upgrade,['ydb','tdb']       ; update $SSWDB/ydb/... and
;                                            $SSWDB/tdb/...
;   sswdb_upgrade,'ydb/att'           ; update $SSWDB/ydb/att (only)
;                                       NOTE: no leading "/"
;   sswdb_upgrade                     ; update SSWDB sets listed in
;                                     ; $SSW/site/setup/setup.sswdb_upgrade
;
; History:
;    11-Feb-1998 - S.L.Freeland - Starting from ssw_upgrade.pro
;    22-Jan-1999 - S.L.Freeland - If relsets not passed in and
;                  $SSW/site/setup/setup.sswdb_upgrade exists, use
;                  sets in that site configuration file
;    26-Jan-1999 - S.L.Freeland - allow DBSETS (relsets) to be
;                  environmentals as well as relative paths
;                  (removes earlier restriction on 'split trees'
;    22-Jun-2000 - RDB - added conditional code for Windows
;    29-Jun-2000 - RDB - corrected case statement so command line request
;                  takes precedence over any files
;                  Flag error under windows if $SSWDB does not exist
;     6-Feb-2001 - Verify sswdb_info returned valid data - exit on error
;    22-Jun-2001 - S.L.Freeland - 'file_delete'->'ssw_file_delete' since RSI 
;                  screwed me again in V5.4
;     6-Feb-2002 - S.L.Freeland - added PASSIVE_FTP keyword and function
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;     28-Apr-2004 - S.L.Freeland - protect against inadvertant use of $HOME
;                   for $tdb/$ydb/$PERM_DATA/$smm per Jeff Payne commen.
;     25-sep-2007 - S.L.Freeland - finally added ssw_whereis_perl.pro hook
;                  
;
; Restrictions:
;   Assume SolarSoft & Perl installed on local machine
;-
debug=keyword_set(debug)
spawnit=keyword_set(spawnit)               ; 17-Januaray-1997 DEFAULT = /NOSPAWN
loud=keyword_set(loud) or keyword_set(verbose)

if n_elements(group) eq 0 then group=get_group()
if n_elements(user) eq 0 then user=get_user()

sswdbtop='/sdb'                                        ; host tree top
ssw_host=(get_logenv('ssw_mirror_site'))(0)            ; default=sohoftp

if ssw_host eq '' then ssw_host='sohoftp.nascom.nasa.gov'  ; default at GSFC

multi_miss=str2arr('yohkoh,soho,smm')             ; multiple instrument missions

; Optionally generate Instrument list via keyword inheritance
if keyword_set(_extra) then begin
   instr=strlowcase(str_replace(tag_names(_extra),'SSW_',''))
endif else instr=   str2arr(get_logenv('SSW_INSTR'),' ')

; ---------- prepare the lists (remote and local SSW pathames) ------------
allinstrx=str2arr(get_logenv('SSW_INSTR_ALL'),' ')
allmiss =ssw_strsplit(allinstrx,'/',tail=allinstr)
missions=str2arr(get_logenv('SSW_MISSIONS'),' ')
; ------------------------------------------
; protect against unexpected environmentals (missions ne '')

for i=0,n_elements(missions)-1 do set_logenv,missions(i),'',/quiet

ss=where_arr(allinstr,instr, count)                       ; map local->remote
gensets=['gen']                                           ; implied GEN trees

if count gt 0 then begin
   sss=where(allmiss(ss) eq allinstr(ss),smcnt)           ; mission=instrument?
   if smcnt gt 0 then allinstr(ss(sss))=''                ; null out
   insets=concat_dir(allmiss(ss),allinstr(ss))            ; instruments
;endif
mm=where_arr(multi_miss,allmiss(ss),count)
if count gt 0 then gensets=[gensets,concat_dir(multi_miss(mm),'gen')]     ; implied mission GEN

gensets=gensets(uniq(gensets,sort(gensets)))
allsets=[gensets,insets]
allsets=allsets(uniq(allsets,sort(allsets)))              ; uniq list
if keyword_set(relsets) then allsets=relsets
endif   ;<<<<<<

sitedb=concat_dir('$SSW_SITE_SETUP','setup.sswdb_upgrade')

case 1 of
    n_params() eq 1: dbsets=relsets                   ; user supplied
    file_exist(sitedb): begin
       box_message,'Using site sswdb configuration file: '+ sitedb
       dbsets=rd_tfile(sitedb)
       dbsets=strnocomment(dbsets,comment='#',/remove_nulls)
       if dbsets(0) eq '' then begin
	   box_message,'No sets defined in site file after de-commenting'
	   return
       endif
    endcase
    else: begin
      box_message,['Need either desired path list or site configuration file',$
                   'Site file: $SSW/site/setup/setup.sswdb_upgrade']
      return
    endcase
endcase
box_message,['SSWDB sets to upgrade:',dbsets]

; define local and remote

sswdb_env = get_logenv('$SSWDB')
is_sswdb_dir  = file_exist(sswdb_env)
if strlowcase(!version.os_family) eq 'windows' then begin
   if sswdb_env eq '' or is_sswdb_dir eq 0 then begin
      box_message,['SSWDB directory or environment variable not defined', $
                   '      Exit IDL, correct this, and re-enter IDL     ']
      print,'$SSWDB= ',sswdb_env
      if is_sswdb_dir eq 0 then print,'** Directory missing **'
      return
   endif
endif

; ---------- translate logicals, map to local ---------
sswdb_info, dbsets, dbenv=dbenv, relpath=relpath, status=status

if 1-status(0) then begin 
   box_message,'No matching sets found, returning with no action'
   return
endif

local_sets=concat_dir('$SSWDB',relpath)          ; set default local names

delim=get_delim()
head=ssw_strsplit(dbenv+delim,delim,/head,tail=tail)
envs=get_logenv(head)
ss=where(envs ne '' and strpos(envs,get_logenv('HOME')) eq -1,ecnt)
if ecnt gt 0 then begin
   local_sets(ss)=concat_dir(head(ss),tail(ss))     ; use local ENV instead
   local_sets(ss)=strmids(local_sets(ss),0,strlen(local_sets(ss))-1)
endif

remote_sets=concat_dir(sswdbtop,relpath)          ; name on SSWDB master
remote_sets=str_replace(remote_sets,'\','/')      ; ensure unix syntax

;------------------------------------------------------------------------

; ----------------- generate mirror package -------------------------

if not keyword_set(nopackage) then begin
   if not keyword_set(outpackage) then outpackage='sswdb_upgrade.mirror'
   break_file,outpackage,ll,pp,ff,ee,vv
   case 1 of
      keyword_set(outdir):
      file_exist(pp): outdir=pp
      file_exist(get_logenv('SSW_SITE_MIRROR')): outdir=get_logenv('SSW_SITE_MIRROR')
      else: outdir=get_logenv('SSW_SITE_SETUP')
   endcase
   pfile=concat_dir(outdir,ff+ee+vv)
   ssw_file_delete,pfile, status
   if file_exist(pfile) then begin
      prstr,strjustify(["WARNING: File: " + pfile , $
        "exists and you do not have update priviledge - aborting...", $
        "Remove file or use OUTPACKAGE and OUTDIR keywords to define a", $
        "different mirror file name...","", $
        "   IDL> sswdb_upgrade[,/switches], OUTDIR='pathname',OUTPACK='filename'"],/box)
        return
   endif
   if n_elements(remote_sets) eq 1 then begin
     remote_sets=remote_sets(0)
     local_sets=local_sets(0)
   endif

  passive_ftp=keyword_set(passive_ftp) or $
                  get_logenv('ssw_passive_ftp') ne '' 

   make_mirror,ssw_host,remote_sets,local_sets, $
      comment='sswdb_upgrade_'+ str_replace(remote_sets,'/','_'), $
      mirror_file=pfile,/mode_copy, group=group, user=user, $
      max_delete_file='99%', max_delete_dirs='99%', passive_ftp=passive_ftp
endif

; --------------- spawn mirror (do the update) ----------------------
cd,current=curr		  ;save current directory - changed under windows

if spawnit then begin
   sswmirr_dir=concat_dir(concat_dir('$SSW','gen'),'mirror')

   case 1 of
      data_chk(mirror,/string):                     ; user passed
      keyword_set(local_mirror): mirror='mirror'    ; local alias
      else: begin
          mirror=$    ; default Mirror (makes assumption about perl loc...
          concat_dir(concat_dir(concat_dir('$SSW','gen'),'mirror'),'mirror')
          if os_family() eq 'unix' then begin 
             if not file_exist(ssw_whereis_perl(/default)) then begin
      box_message,'Checking for perl location...'
      locperl=ssw_whereis_perl(status=status)
      if status then begin
         mtemp=rd_tfile(mirror)

         locmirr=concat_dir(sswmirr_dir,'mirror_local.pl')
         mtemp(0)='#!'+locperl  ; gotta be a better way which works for ALL OS/SHELL/1980-2048...
         file_append,locmirr,mtemp,/new
         spawn,['chmod','775',locmirr],/noshell
         mirror=locmirr
         dirtemp=curdir()
         cd,sswmirr_dir
      endif else begin
         box_message,['Sorry, dont see "perl" where I expected...','Please make symbolic link like:',$
                      '','(from root - ask your sysadmin. if thats not you)','', $
                     '# ln -s </your_perl_path_here> /usr/local/bin/perl','','..then retry']
         return ; !!! early error exit
      endelse
   endif



          endif
      endcase
   endcase
   if not file_exist(mirror)  then mirror='mirror'
   mircmd=mirror + ' ' + pfile

;	syntax of mirror command different in windows
;	also, need to be in the directory containing mirror
   if strlowcase(!version.os_family) eq 'windows' then begin
      mirror_dir=concat_dir(concat_dir('$SSW','gen'),'mirror')
      mirror_cmd=concat_dir(mirror_dir,'mirror.pl')
      mircmd = 'perl '+mirror_cmd+' -d '+pfile
      cd,mirror_dir

      cd,curr=now_in
      print,'Temporarily in: ',now_in
   endif


   message,/info,"Spawning mirror cmd: " + mircmd
   if loud then spawn,mircmd else spawn,mircmd,result
endif
cd,curr

if debug then stop
return
end
