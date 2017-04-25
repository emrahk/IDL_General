pro html_get_files, htmldoc, filelist, recurse=recurse, $
    tarfile=tarfile, loud=loud, debug=debug, ppath=ppath, $
    striptemplate=striptemplate, rewrite=rewrite, original=original
;+
;   Name: html_get_files
;
;   Purpose: get relative files referenced by an html doc (recursive)
;
;   Input Parameters:
;      htmlparent - the top level .html document
;
;   Output Parameters
;      filelist - the relative filelist referenced by this htmldoc
;
;   Keyword Parameters:
;      tarfile - if set, write a tarfile (supply name or use as switch)
;      loud - if set, more verbose
;      ppath (output) - the parent path implied for htmldoc and filelist
;      striptemplate, rewrite, original - strip html header/trailer from 
;                     parent html (often site specific)
;                
;   Motivation:
;     Simplify relocation of an html doc and its local files
;         
;   Calls:
;      rd_tfile, strfind_urls, file_exist, str2arr, str_replace,
;      the usual suspects.
;
;   History:
;      15-November-2000 - S.L.Freeland - written
;      16-November-2000 - S.L.Freeland - protect against endless recursion
;                         (list of processed *.html files)
;
;
;   Restrictions:
;      only gets those things (gif/mpeg/html...) which are
;      RELATVIE to input htmldoc (does not follow aboslute URLS...)
;
;   Side Effects:
;      may write a tar file
;-
common html_get_files_blk1, htmlparent, parentpath
common html_get_files_blk2, htmlsdone

recurse=keyword_set(recurse)    ; internal use
loud=keyword_set(loud) 
debug=keyword_set(debug)
newparent=keyword_set(rewrite) or keyword_set(original) or keyword_set(striptemplate)

if loud then box_message,htmldoc      ; current *.html document

if not keyword_set(recurse) then begin 
   break_file, htmldoc, ll, parentpath, ff,vv,ee
   if parentpath eq '' then parentpath =curdir()

   if newparent then begin 
      if data_chk(rewrite,/string) then begin 
         break_file,rewrite,ll,pp
         if pp eq '' then rewrite=concat_dir(parentpath,rewrite)
         rewrite=str_replace(rewrite,'.html','') + '.html'
      endif 
      delvarx,newname
      html_remove_template, htmldoc, rewrite=rewrite, original=original, newname=newname
      if data_chk(newname,/string) then htmldoc=newname
   endif
   htmlsdone=strlowcase(htmldoc)    ; initilize 'done list'
   htmlparent=htmldoc
   filelist=htmldoc
   ppath=parentpath
endif 

html=rd_tfile(htmldoc)               ; read html
urls=strfind_urls(html)              ; find the urls

exturl=strtrim(strextract(urls.url,'"'),2)
exturl=strmids(exturl,([0,1])(strpos(exturl,'/') eq 0),strlen(exturl))

fexist=file_exist(exturl)      ; only consider local urls
ssno=where(1-fexist,ncnt)      ; 

if ncnt gt 0 then $
   exturl(ssno)=concat_dir(parentpath,exturl(ssno))  ; try again w/parent path
fexist=file_exist(exturl)
ssexist=where(fexist and (1-is_dir(exturl)),ecnt)    ; exist & NOT directory
if ecnt gt 0 then begin 
   exturl=exturl(ssexist) 
   ssexist=lindgen(ecnt)
endif else exturl=""

sshtml=wc_where(exturl,'*.html',/case_ignore,mcount) ; find *.html subset
ssfinal=rem_elem(ssexist,sshtml,fincnt)              

if mcount gt 0 then begin                        ; some *.html urls
   htmls=exturl(sshtml)                           
   ssremain=rem_elem(htmls,htmlsdone,mcount)     ; remove already done 
   if mcount gt 0 then begin                     ; some remaing?
      htmls=htmls(ssremain)                      ; current TODO list
      htmlsdone=[htmlsdone,htmls]                ; add to donelist
   endif
endif

if fincnt gt 0 then begin                        ; add to filelist
   ssfinal=ssexist(ssfinal)
   if not data_chk(filelist,/string) then filelist=exturl(ssfinal) else $
      filelist=[filelist,exturl(ssfinal)]
endif

; -------------- recurse for each unprocessed *.html file -------------
for i=0,mcount-1 do $
   html_get_files, exturl(sshtml(i)), filelist, /recurse, loud=loud


filelist=[htmlsdone,filelist]            ; referenced
filelist=filelist(uniqo(filelist))       ; uniq set
notdir=where(1-is_dir(filelist))         ; strip dictories if any
filelist=filelist(notdir)

if debug then stop

if keyword_set(tarfile) then begin 
   case 1 of 
      data_chk(tarfile,/string): tarname=str_replace(tarfile,'.tar','') + '.tar'
      else: tarname=str_replace(htmlparent,'.html','.tar')
   endcase
   break_file,tarname,ll,pp,ff,vv,ee
   if pp eq '' then tarname=concat_dir('$HOME',tarname)
   break_file,filelist,ll,pp,ff,vv,ee
   relfiles=ff+vv+ee
   tarcmd=['tar','-cf',tarname,'-C',parentpath,relfiles]
   starcmd=arr2str(tarcmd,' ')
   if loud then print,starcmd
   box_message,'Writing tar file: ' + tarname
   tcmd=(['spawn,tarcmd,/noshell','spawn,starcmd'])(strpos(starcmd,'$') ne -1)
   estat=execute(tcmd)           
endif


return
end


