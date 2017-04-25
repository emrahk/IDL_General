pro html_linklist, htmlfiles, giffiles, head=head, tail=tail, $
     absolute=absolute, relative=relative, insert=insert, prehtml=prehtml
;+
;   Name: html_linklist
;
;   Purpose: make a series of htmlfiles a 'linked list'
;
;   Input Parameters:
;      htmlfiles    - list of html files 
;      giffiles (optional) - list of gifs for inline menu
;
;   Keyword Parameters:
;      absolute - use absolute URL links (default is relative)
;                 (requires $path_http and $top_http defined)
;      relative - all linked files assumed relative (default)
;      insert - INSERT the linked list html after this string pattern
;               (required on initial run - subsequent updates use
;               inserted markers (see strarrinsert for generic routine)
;
;              
;      
;   Calling Sequence:
;      html_linklist, htmlfiles [,gifs, head='headfile', tail='tailfile']
;   
;   Restrictions:
;      GIF stuff not yet implemented directly 
;      (see mkthumb.pro and str2html.pro for ~solution)
;
;   History:
;      12-Jun-1997 - S.L.Freeland (extract code from fl_queue and simplify
;                                 (via call to <strarrinsert.pro> )
;                                 
;   TODO:
;      generate HTML linked docs if not supplied directly from a GIFLIST
;      (ie, series of images -> linked HTML list w/inline GIFS)
;
;   Side Effects:
;     every file in <htmlfiles> list is updated - inserted HTML includes
;     markers (comments) forward and backward links - optionally <tail>
;     and <head> links if supplied. Uses HTML V3 table via <strarr2html.pro>
;-
if not data_chk(htmlfiles,/string,/vector) then begin
   message,/info,"IDL> html_linklist, htmlfiles [,giffiles, ...]"
   return
endif

;  ------- Verify that all files exist ----------
ifiles=htmlfiles
nfiles=n_elements(ifiles)
exist=where(file_exist(ifiles),ecnt)
if ecnt ne nfiles then begin
   ifiles=http_names(ifiles)             ; user entered URLS, not pathnames?
   exist=where(file_exist(ifiles),ecnt)
   if ecnt ne nfiles then begin
      prstr,["Only found " + strtrim(ecnt,2) + " of " + strtrim(nfiles,2) + "files",   $
             "Returning with no action..."]
      return
   endif
endif
; -----------------------------------------------------

;
absnames=http_names(ifiles)                 ; full URLS
break_file,ifiles,ll,pp,ff,ee,vv            

case 1 of 
   keyword_set(absolute):urls=absnames   ; use absolute URLs
   else: urls=ff+ee                      ; otherwise, relative
endcase

urls=str2html(urls,link=ff,/nopar)       ; CURRENT->HTML
nexturl=shift(urls,-1)                   ; NEXT
lasturl=shift(urls,1)                    ; PREVIOUS

header=['Previous','Current','Next']     ; menu header
header='<em>'+header+'</em>'

first=keyword_set(insert)                ; user supplied insertion tag
d1='<!** HTML_LINKLIST Start **>'        ; default d1
d2='<!** HTML_LINKLIST Stop  **>'        ; default d2

prefix=data_chk(prehtml,/string)
for i=0,nfiles-1 do begin
   urltable=[[header],[lasturl(i),urls(i),nexturl(i)]]  ; Make the HTML table
   html=strtab2html(urltable)                           ; (linked list)
   html=['<center>',html,'</center><p>']                ; center table
   if prefix then html=[prefix,html]                    ; user xtra html   
   oldhtml=rd_tfile(ifiles(i))                          ; existing html->
   
   if first then $
      newhtml=strarrinsert(oldhtml,[d1,html,d2],$       ; initial links
	      insert,/first,status=status) else $
      newhtml=strarrinsert(oldhtml, html, $             ; subsquent links
             d1,d2,status=status)
   if status then file_append,ifiles(i),newhtml,/new    ; html change?-> update
endfor
return
end

