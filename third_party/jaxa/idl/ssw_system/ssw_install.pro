
pro ssw_install, qfile=qfile, upgrade=upgrade
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
;  
;   Method:
;      uses WWW FORM input to define generate a customized C-SHELL 
;      installation script (and now Mirror package file and ssw_install.bat)
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
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
         file_append, outhtml, str2html(str_replace(outftp,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Windows/Mac Users: Links to required installation files')
         file_append, outhtml, str2html(str_replace(outmirror,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Associated Mirror Package (install or upgrades)')
         file_append, outhtml, str2html(str_replace(outmdbat,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Windows MD command bat file')
      endif else begin 	
         file_append, outhtml, str2html(str_replace(outscript,$
            get_logenv('path_http'),get_logenv('top_http')), $
            link='Your UNIX installation script')
         file_append,outhtml, $
            ['<p>UNIX users: copy this script to a local disk and execute it via:<br>', $
	    '<b>% csh -f <em>filename</em></b><p>']
      endelse
    endcase
endcase

; - make a Mirror package using ssw_upgrade.pro -----
print,outmirror,info.path_ssw,sswinstr
ssw_upgrade,ssw_parent=info.path_ssw, ssw_host=sswhost, ssw_instr=sswinstr,$
    outpackage=outmirror,/update_log, remote_user='',remote_password=ssw_email,$
	     user=(ssw_strsplit(ssw_email,'@',/head))(0),group='', $
	     local_sets=local_sets

if windows then begin
  local_sets=[info.path_ssw,info.path_ssw+['\site\setup','\site\mirror'],local_sets]
  file_append,outmdbat,$
    [':: BAT file for generating required MD commands',$
     ':: Generated by ssw_install.pro at: ' + systime(),$
      'md ' + local_sets]
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
