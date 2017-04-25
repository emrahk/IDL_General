

pro ssw_install2, qfile=qfile, upgrade=upgrade, zipit=zipit
;+
;   Name: ssw_install
;
;   Purpose: Interface routine to SolarSoft library installation
;
;   History:
;      25-May-1996 - S.L.Freeland (Written)
;       4-Jun-1996 - S.L.Freeland enhanced
;      19-feb-1997 - S.L.Freeland Yohkoh reorganization (ysgen->gen, etc)    
;      12-mar-1997 - S.L.Freeland allow WWW upgrade flag (inhibit site)
;      10-jun-1997 - S.L.Freeland add SIZE calcualtion and info->WWW
;      29-May-1998 - S.L.Freeland set 'ssw_tar_old_style' on request
;      19-Nov-1999 - S.L.Freeland - add link to compressed tar (WNT/W98 users)
;      29-Nov-1999 - S.L.Freeland - add Windows hooks
;      30-Nov-1999 - S.L.Freeland - check for 'ssw_parent' definition (menu)
;      21-Feb-2000 - S.L.Freeland - more Windows automation, make Zip file.
;      25-Feb-2000 - S.L.Freeland - more Windows, add information anchors
;       1-Mar-2000 - S.L.Freeland - increased Perl path support, $
;                                   make M.Berg suggestions
;      20-Mar-2000 - S.L.Freeland - put ftp in "per-INSTR loop"
;                    change some logging/redirection
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;   Method:
;      uses WWW FORM input to define generate a customized C-SHELL 
;      installation script (and now Mirror package file and ssw_install.bat)
;-

common ssw_install_blk, ssw_install_txt

if n_elements(ssw_install_txt) eq 0 then $
   ssw_install_txt=rd_tfile('/ssw/gen/bin/ssw_install')

break_file,qfile,ll,pp,ff,ee,vv

top=get_logenv('path_http')
outhtml=concat_dir(top,concat_dir('html_client',ff+'.html'))
outftp=str_replace(outhtml,'.html','_ftp.html')
outscript=concat_dir(top,concat_dir('text_client',ff+'.csh'))
outmirror=concat_dir(top,concat_dir('text_client',ff+'.mirror'))
outmdbat =concat_dir(top,concat_dir('text_client',ff+'.batx'))

wsetup_dir=concat_dir('$SSW_SITE_SETUP',ff)
woutsetup =concat_dir(wsetup_dir,'setup.bat')
woutmirror =concat_dir(wsetup_dir,'ssw_install.pkg')
woutftp    =concat_dir(wsetup_dir,'FTP.TXT')
woutdaily  =concat_dir(wsetup_dir,'Daily.cmd')
watcheck   =concat_dir(wsetup_dir,'check_at.pl')
woutzip=concat_dir(concat_dir('$path_http','exe_client'),ff+'.ZIP')

; ----------- entire package contents for copy --------------------
wpackfiles=['setup.bat','ssw_install.pkg','FTP.TXT','Daily.cmd',$
	    'GZIP.EXE','UNTGZ32.EXE']

info=url_decode(qfile=qfile)

html_doc,/header,outhtml,title='SolarSoft (SSW) Installation', $
	  template='$path_http/../solarsoft/header_template.html'

tags=tag_names(info)
inst=wc_where(tags,'SSW_*',cnt)
sswhost=where(tags eq 'SSWHOST',hcnt)
tar_old_style=(tag_index(info,'TAR_OLD_STYLE'))(0) ne -1

if hcnt eq 0 then $
   sswhost='sohoftp.nascom.nasa.gov' else sswhost=info.(sswhost(0))

sets='SSW_SSW_GEN'			; everybody gets this

if cnt gt 0 then begin
   lsets=ssw_strsplit(tags(inst),'_',/last,/tail)
   ssw_install_explinkages,lsets,sswinstr
   implied_sets=strupcase(ssw_instr2set(sswinstr))
   sets=[sets,implied_sets]
endif   

cnt=n_elements(sets)

; add multi-mission GEN areas
mm=strupcase(str2arr('yohkoh,ydb,soho,smm,radio'))	; what they want (request)
mg=strupcase(str2arr('yohkoh,yohkoh,soho,smm,radio'))  ; implied GEN branch

for i=0,n_elements(mm)-1 do begin
   chk=where(strpos(sets,'SSW_'+mm(i)) eq 0,ccnt)			; 
   if ccnt gt 0 then sets=['SSW_'+mg(i)+'_GEN',sets]	; map->implied GEN
endfor

yosets=where(strpos(sets,'YOHKOH') ne -1, ycnt)
if ycnt gt 0 then sets=[sets,'SSW_YOHKOH_UCON'] 	; backward compatible

sets=sets(uniq(sets,sort([sets])))			; no redundanc

order=sort(strmid(sets,4,1))				; sort by 'mission'
sets=sets(order)

sline=string(replicate((byte('#'))(0),60))

install_type=(["NEW","UPG"])(keyword_set(upgrade))      ; allow upgrades
if tag_exist(info,"install_type") then begin
  install_type=strupcase(strmid(info.install_type(0),0,3)) 
  message,/info,"INSTALL_TYPE TAG= " + install_type
endif else message,/info,"No INSTALL_TYPE tag, type= "+ install_type

; ---------- check for $SSW path via menu ---------------
ssw_parent=(gt_tagval(info,/ssw_parent,missing='none'))(0)
ssw_email= (gt_tagval(info,/ssw_email,missing=''))(0)

if ssw_parent ne 'none' then begin
   ssw_parent=(strtrim(ssw_strsplit(ssw_parent,'[',/head),2))(0)
   if strpos(ssw_parent,'Suggestions') eq -1 and info.path_ssw eq '' then begin
      box_message,'Using $SSW from Menu>> '+ssw_parent
      info.path_ssw=ssw_parent
   endif
endif

windows=strpos(info.path_ssw,':\') ne -1

case 1 of 
   info.path_ssw eq '': file_append,outhtml,$
	"<p><b>Warning:You did not specify a local path for SSW</b>"
   cnt eq 0: file_append,outhtml,"No Instruments requested"
   else: begin
      outenv=strlowcase(sets)
      ssw_set2size,outenv,tarsize,treesize,table=stable       ; THIS SORTS THEM
      missinst=ssw_strsplit(strupcase(outenv),'_',tail=miss)
      miss=ssw_strsplit(miss,'_',tail=branch)   
      table=transpose([ ['Mission/Top',miss],['Instrument/Branch',branch], $
	                ['Compressed Tar Size (Mb)',reform(stable(1,*))  ], $
	                ['Installed Tree Size (Mb)',reform(stable(2,*))  ] ] )

      boost_array,table,[" "," ", $
		   "<b>TOTAL: "+string(total(tarsize) ,format='(f7.2)')+"</b>", $
		   "<b>TOTAL: "+string(total(treesize),format='(f7.2)')+"</b>"]
      file_append,outhtml,$
	['Requested SSW Parent Path Location>> <font color=red size=+1>' + info.path_ssw,'</font><p>']
      file_append,outhtml, $
         ['Requested installation will include...',strtab2html(table,/row0header)]
;     customize the installation script
      file_append,/new,outscript,['#!/bin/csh -f',sline,$
                          '# created via WWW at ' + systime(), sline]
;     prepend default sets...
      file_append,outscript,'setenv SSW ' + info.path_ssw
      outenv=strlowcase(sets)
      case install_type of
         "NEW": begin
            message,/info,"New Installation (adding site)"
	    outenv=['ssw_ssw_site',outenv]
          endcase                          
	     "UPG": begin
                message,/info,"UPGRADE (inhibiting site)"
          endcase
          else:
      endcase
      ssdb=where(strpos(outenv,'db_') ne -1,dbcnt)
      sssw=where(strpos(outenv,'db_') eq -1,swcnt)
      swsets=''
      dbsets=''
      if swcnt gt 0 then swsets=arr2str(outenv(sssw),' ')
      if dbcnt gt 0 then dbsets=arr2str(outenv(ssdb),' ')
      file_append, outscript, 'setenv ssw_host ' + sswhost
      file_append, outscript, 'setenv ssw_sw_host ' + sswhost
      file_append, outscript, 'setenv ssw_tar_old_style ' + '"'+ (['','1'])(tar_old_style) +'"'
      file_append, outscript, 'setenv ssw_sw_sets "' + swsets + '"'
      file_append, outscript, 'setenv ssw_db_sets "' + dbsets + '"'
      file_append, outscript, [sline,'',ssw_install_txt(1:*)]
      if windows then begin
         file_append, outhtml, str2html(str_replace(woutzip,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Windows Installation (ZIP) file')
         file_append, outhtml, ['<p>', $
	   '<A href="http://www.lmsal.com/solarsoft/ssw_install_howto.html#Windows">What do I do next?</a>']
     endif else begin 	
         file_append, outhtml, str2html(str_replace(outscript,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Your UNIX installation script')
         file_append, outhtml, ['<p>', $
	   '<A href="http://www.lmsal.com/solarsoft/ssw_install_howto.html#Unix/Linux/FreeBSD">What do I do next?</a>']
      endelse
    endcase
endcase

; - make a Mirror package using ssw_upgrade.pro -----
print,outmirror,info.path_ssw,sswinstr
ssw_upgrade,ssw_parent=info.path_ssw, ssw_host=sswhost, ssw_instr=sswinstr,$
    outpackage=outmirror,/update_log, remote_user='',remote_password=ssw_email,$
	     user=(ssw_strsplit(ssw_email,'@',/head))(0),group='', $
	     local_sets=local_sets

ftpnames=strlowcase(sets)+'.tar.Z'
ftpupath='/solarsoft/offline/swmaint/tar/'+ ftpnames
ftploc='http://'+sswhost+ftpupath

if windows then begin
;                       0                   1       2             3
  local_sets=[info.path_ssw,info.path_ssw+['\site','\site\setup','\site\mirror','\site\logs'],local_sets]
  wsetup=local_sets(2)
  wmirror=local_sets(3)

; -------- assure that all mission/package level parents created before children -----
; [Dont know the DOS equivilent of UNIX 'mkdir -p xxx' command ]  
  
  local_sets=strmids(local_sets,0,strlen(local_sets)- $
	     (str_lastpos(local_sets,'\') eq strlen(local_sets)-1))
  msets=str2cols(ssw_strsplit(local_sets,info.path_ssw,/tail),/unaligned,'\')
  strtab2vect,msets,mission,residual
  ssr=where(residual ne '' and mission ne 'site',ssrcnt)
  if ssrcnt gt 0 then begin
     need=all_vals(info.path_ssw+'\'+all_vals(mission(ssr)))
     local_sets=[local_sets(0),need,local_sets(1:*)]
  endif
  
  mdcmds=  ['echo.','echo Generating Subdirectories (not done by Mirror under Windows...)',$
      'echo.','md ' + local_sets]

  file_append, outmdbat, mdcmds, /new

  if keyword_set(zipit) then begin
         if not file_exist(wsetup_dir) then begin
            box_message,'Creating Subdirectory: ' + wsetup_dir
            spawn,['mkdir','-p',wsetup_dir],/noshell
	 endif

;        -------- Generate Windows Installation Script -------------
         box_message,'Building Windows setup script...'
         nftp=n_elements(ftpnames)
         cmdperfile=10                          ; DOS commands per tarfile
         inscmds=strarr(nftp*cmdperfile)       ; INIT DOS command array    
         
         gzipcmds=wsetup+'\gzip -d ' + wsetup + '\' + ftpnames  ; GZIP cmd definition

         tartop=strextract(ftpnames,'_')
         sswtop=where(tartop eq 'ssw',sswcnt)
         mtop=where(tartop ne 'ssw',mtcnt)
         if sswcnt gt 0 then tartop(sswtop)=info.path_ssw
         if mtcnt gt 0 then tartop(mtop)= $
	        info.path_ssw+'\'+tartop(mtop)
         cdcmds='cd '+tartop                             ; CD cmd

	 ;
         ftpfiles  = strmid(str_replace(ftpnames,'.tar.Z','.ftp'),4,100)
         ftpscript = concat_dir(wsetup_dir,ftpfiles)	 

;        ----------------- FTP command files ------------------------
         anonuser= ([info.ssw_email,get_user()+'@'+get_host()])(info.ssw_email eq '')
         for ff=0,n_elements(ftpfiles)-1 do begin
            file_append,ftpscript(ff),              $
	     ['user ftp',anonuser,'binary',        $
	      'cd /solarsoft/offline/swmaint/tar', $
	      'get ' + ftpnames(ff),'bye'], /new
	 endfor  

         ftpcmds='ftp -n -d -s:'+wsetup+'\'+ftpfiles + ' ' + $
		  sswhost + ' >> setup_ftp.log'
	 
         tarnames=str_replace(ftpnames,'.Z','')
	 untarcmds=wsetup + '\untgz32 -y '+ wsetup+'\'+tarnames ; UNTAR cmds
	 
         delcmds='del ' + wsetup + '\' + tarnames        ; Delete cmds

	 
         inscmds(indgen(nftp)*cmdperfile+0)  ='echo.'
         inscmds(indgen(nftp)*cmdperfile+1) = $           ; comment
	      'echo Installing file: ' + ftpnames      
         inscmds(indgen(nftp)*cmdperfile+2)  ='echo.'
	 inscmds(indgen(nftp)*cmdperfile+3)  ='cd ' + wsetup
         inscmds(indgen(nftp)*cmdperfile+4) = ftpcmds     ;
         inscmds(indgen(nftp)*cmdperfile+5) = gzipcmds    ; gzip (uncompress)
	 inscmds(indgen(nftp)*cmdperfile+6) = cdcmds      ; cd command
	 inscmds(indgen(nftp)*cmdperfile+7) = untarcmds   ; untar (install)
	 inscmds(indgen(nftp)*cmdperfile+8) = delcmds     ; delete tar
	 
         file_append, woutsetup, ['echo off','echo.', $
                      'echo SSW Install [Windows] Generated by ssw_install.pro at: ' + systime(),$
		      mdcmds, '', $
		      'echo MOVING FILES TO SETUP   DIRECTORY',$
		      'copy '+ [wpackfiles,ftpfiles] + ' ' + wsetup, $
                      strmid(wsetup,0,2), $     ; "naked" drive
	              'cd ' + wsetup, ''], /new
		      
	 file_append, woutsetup, inscmds

;        ------------ Windows initial Mirror/Upgrade --------------
         mirdir=info.path_ssw  + '\gen\mirror'
         mircmd= mirdir + '\mirror.pl'
;        find perl path, if any:
         path_perl=gt_tagval(info,/path_perl,missing='')
	 perl_parent =gt_tagval(info,/perl_parent,missing='')
         perlcmd='perl.exe'
         domirror=1
	 case 1 of
             path_perl ne '': perlcmd=$
		       str_replace(strlowcase(path_perl),'perl.exe','')+'\perl.exe'
             strpos(perl_parent,'DOS') ne -1: perlcmd='perl.exe'
             strpos(perl_parent,':') ne -1: perlcmd=perl_parent
	     else: begin
                domirror=0 
	     endcase
	 endcase  
         perlcmd=str_replace(perlcmd,'\\','\')
         help,perlcmd
         if domirror then begin 
            file_append, woutsetup, ['', 'echo.',$ 
               'echo SYNCHRONIZING TIME STAMPS AND RUNNING MIRROR FOR THE FIRST TIME',$
               'echo.',strmid(mirdir,0,2), $
	       'cd '+mirdir, $
               arr2str([perlcmd,mircmd,'-d',wsetup+'\ssw_install.pkg'],' '),'']
	 endif else begin
            box_message,'Not enabling Mirror job'
	    file_append,woutsetup,['','echo Not running Mirror job (upgrade)','']
	 endelse
	 
;        ------------- Windows Task Schedual (AT) command file -------------
         daily_log=wsetup+'\daily_log'
         file_append, woutdaily, $
             [strmid(mirdir,0,2),'cd ' + mirdir, $
              'date /t>' + daily_log,'time /t>>'+daily_log, $
	      arr2str([perlcmd,mircmd,'-d',wsetup+'\ssw_install.pkg'],' ')+' >> '+daily_log]

;        --------- Windows (NT ONLY) - Auto Task Schedule / SSW Upgrade -------	 
         if gt_tagval(info,'windows_task',missing='') eq 'on' then begin
            chkat_temp=concat_dir(concat_dir('SSW_GEN','perl'),'check_at.pl')
            if file_exist(chkat_temp) then $
		file_append,watcheck,rd_tfile(chkat_temp)
;           pseudo random time between 00:00 and 06:00 local
	    atime=string([fix(randomu(s,2)*6)]*[1,10],format='(i2.2,":",i2.2)')
            file_append, woutsetup, ['','echo.', $
               'echo SCHEDULING DAILY SSW UPGRADE TASK',$
	       'echo UPGRADE will run every day at: '+atime +'(Local)','echo.',$
	      	arr2str([perlcmd,wsetup+'\check_at.pl'],' '), $	 
	       'at ' + atime +  ' /every:su,m,t,w,th,f,sa ' + wsetup+'\daily.cmd','']
         endif  else begin
            box_message,'SSW Automatic Upgrade Task Scheduling - NOT Enabled'
	    file_append,woutsetup,['','echo NOT SCHEDULING AUTOMATIC SSW UPGRADE TASK','']
	 endelse
         file_append,woutsetup,'PAUSE'
	 
;        ---------------- Mirror File ------------------
         file_append, woutmirror, rd_tfile(outmirror)
	 
;        ------------ make Zip file -------------------
         zipbin=ssw_bin('zip',found=found)
         if found then begin
            winbin=concat_dir(concat_dir('$SSW_BINARIES','exe'),'Win32_x86')
	    exes=file_list(winbin,['GZIP.EXE','UNTGZ32.EXE'])        ; required ZIP exes
	    if n_elements(exes) ne 2 then box_message,'Required Wxx executables not found' else begin
               newfiles=file_list(wsetup_dir,'*')
	       zipcmd=[zipbin,'-j',woutzip,exes]                  ; add EXEs -> ZIP
	       spawn,zipcmd,/noshell 
	       zipcmd=[zipbin,'-jlg',woutzip,newfiles]            ; add new(ascii) -> ZIP 
	       spawn,zipcmd,/noshell                              ; (LF->LF/CR) 
            endelse
	 endif  else box_message,'No ZIP found on this server...'

  endif
  
endif
  
; ------------ build ftp links file for Windows & Mac -------------
ftpnames=strlowcase(sets)+'.tar.Z'
ftploc='http://'+sswhost+'/solarsoft/offline/swmaint/tar/'+ ftpnames
html_doc,/header,outftp,title='SolarSoft (SSW) Installation File Links', $
	  template='$path_http/../solarsoft/header_template.html'
file_append,outftp,'<h2>Non-Unix systems: ftp links to required <em>SSW</em> installation files</h2>'
file_append,outftp,$
 'Uncompress and untar (via <b><em>WinZip</em></b> for example) in the desired <em>SSW</em> parent directory to complete the installation<br>'
linktab=str_replace(str2html(ftploc,link_text=sets,/nopar),'http:','ftp:')
linktab=strtab2html(transpose(linktab),padding=2,spacing=2,border=2)
file_append,outftp,linktab
file_append,outftp,strtab2html(table,/row0header)
html_doc,outftp,/trailer
	  
print,'- ' + outhtml + ' -'
html_doc,/trailer, outhtml
wait,3
return
end
