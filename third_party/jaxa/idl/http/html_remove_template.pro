pro html_remove_template, htmldoc, strippeddoc, $
      rewrite=rewrite, original=original, newname=newname
;
;+
;   Name: html_remove_template
;
;   Purpose: remote html header and trailer templates (site specific)
;
;   Input Paramters:
;      htmldoc - the html file to look at
;
;   Output Parameters:
;      strippeddoc -  the html text less header/trailer
;   
;   Keyword Parameters:
;      rewrite - if set, name rewrite the file 
;                   if string, new name
;                   if switch, old name *.html -> *_v2.html
;      original - if set, rewrite with original name (replace) - WWW masters only
;      newname (output) - html file name used for rewrite
;             
;   Restrictions:
;      not for casual use...
;      assumes header & trailer template html files in $path_http
;
;-
htemp=concat_dir('$path_http','header_template.html')
ttemp=concat_dir('$path_http','trailer_template.html')
if total(file_exist([htemp,ttemp])) lt 2 then begin 
   box_message,'cannot find template files under $path_http'
   return
endif

head =rd_tfile(htemp)
nhead=n_elements(head)
trail=rd_tfile(ttemp)
ntrail=n_elements(trail)

data=rd_tfile(htmldoc)
head =rd_tfile(htemp)
nhead=n_elements(head)
trail=rd_tfile(ttemp)
ntrail=n_elements(trail)

data=rd_tfile(htmldoc)
ndata=n_elements(data)

sshead=where(head eq data,hcnt)
sstrail=where(trail eq last_nelem(data,n_elements(trail)),tcnt)
if hcnt lt (nhead-2)  or tcnt lt (ntrail-2)  then begin 
   box_message,'Warning - dont think these have standard header/trailer - bailing out
   return  
endif

sshead=where(head eq data,hcnt)
sstail=where(trail eq last_nelem(data,n_elements(trail)),tcnt)

newdat=data(max(sshead):ndata-tcnt-1)

if keyword_set(rewrite) then begin 
   case 1 of 
      data_chk(rewrite,/string): newname=rewrite
      keyword_set(original):  newname=htmldoc 
      else: newname=str_replace(htmldoc,'.html','_v2.html')
   endcase
   box_message,'Writing html file: ' + newname
   html_doc,newname,/header,/notemplate
   file_append,newname,newdat
   html_doc,newname,/trailer,/notemplate
endif

return
end

