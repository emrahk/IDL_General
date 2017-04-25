pro sswdb_install, qfile=qfile, upgrade=upgrade
;+
;   Name: sswdb_install
;
;   Purpose: Interface routine to SolarSoft library installation
;
;   History:
;      22-Jan-1999 - S.L.Freeland - Written (from ssw_install.pro)
;  
;   Method:
;      uses WWW FORM input to define generate a customized site configuration
;      file...
;-
break_file,qfile,ll,pp,ff,ee,vv

top=get_logenv('path_http')
outhtml=concat_dir(top,concat_dir('html_client',ff+'.html'))
siteroot='setup.sswdb_upgrade'
siteconfig=concat_dir(top,concat_dir('text_client',siteroot))


html_doc,/header,outhtml,title='SolarSoft DBASE (SSWDB) Installation', $
	  template='$path_http/../solarsoft/header_template.html'

if file_size(qfile) le 1 then begin
   file_append,outhtml,'No DBASE sets selected...<p><p><p><p>'
   html_doc,outhtml,/trailer
   return
endif   

info=url_decode(qfile=qfile)
tags=tag_names(info)
	     
dbsets=strlowcase(str_replace(tags,'$','/'))
sswdb_info, dbsets, dbenv=dbenv, table=table, header=header, dbsize=dbsize

htmltab=str2cols([header,table],/trim)
htmltab=strtab2html(htmltab,/row0,/right)

; -------- write the site configuration file ---------
file_append, siteconfig, /new, $
   ['# SSWDB Site Configuration File - Generated via WWW at ' + systime()]
file_append, siteconfig, dbenv

; --------- write the output html ---------------
file_append, outhtml,$
   ['<h1> SolarSoft DBASE configuration run at: '+systime()+'</h1>', $
    'Requested DBASE Sets',htmltab , $
    '<p><font size=+2>Total Size of requested sets: ' + $
     string(total(dbsize),format='(f10.2)') + '<b>Mb</b></font>', $ 
   '<p><a href="' + http_names(siteconfig) + '"> <font size=+2>Your SITE configuration file</a></font><p>',$
   '<b>Copy this file to local <font size=+2 color=red>$SSW/site/setup/</font>setup.sswdb_upgrade for input into <em>sswdb_upgrade.pro</em>',$
   ' </b> <br>(run as part of <em> go_update_ssw</em>).<p> ',$
   '<a href="http://www.lmsal.com/solarsoft/sswdb_install.html"> Details on SolarSoft DBASE upgrades</a><p><p><p><p>']

html_doc,/trailer, outhtml

box_message,siteconfig
box_message,outhtml
box_message,http_names(outhtml)

return
end
