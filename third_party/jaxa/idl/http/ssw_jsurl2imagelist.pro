function ssw_jsurl2imagelist,jsurl, debug=debug
;
;+
;   Name: ssw_jsurl2imagelist
; 
;   Purpose: return urls of image files within javascript movie html
;
;   Input Paramters:
;      jsurl - url of desired javascript movie -or- thumbnail table html
;
;   Output:
;     returns implied url list of remote graphics (png/gif)
;
;  Keyword Parameters:
;     copy - if set, copy the full list of remote -> local
;
;  Calling Sequence:
;      imgurls=ssw_jsurl2imagelist('http://.../<JSMOVIE>.html')
;
;  History:
;     23-Sep-2005 - S.L.Freeland
;     20-Jan-2006 - S.L.Freeland - thumbnail table (still movie) hook
;
;-

if not data_chk(jsurl,/scalar,/string) then begin 
   box_message,'Require input url of remote javascript movie'
   return,'' 
endif

break_url,jsurl,serv,paths,files,http=http
if not http then begin 
   box_message,'Need an http url input'
   return,''
endif

sock_list,jsurl,jslist

ssimg=where(strpos(jslist,']=url_path') ne -1 and $   ; javascript wrapper?
            strpos(jslist,'";') ne -1,sscnt)

ssimgs=where(strpos(jslist,'HREF=') ne -1 and $       ; thumbnail wrapper? 
            strpos(jslist,'IMG SRC') ne -1, sscnts)

case 1 of 
   sscnt gt 0: imgs=strextract(jslist(ssimg),'url_path+"','";')
   sscnts gt 0: imgs=strextract(jslist(ssimgs),'HREF="','"><IMG SRC')
   else: begin 
      box_message,'Cannot seem to find the image list in this html wrapper"'
      return,''
   endcase
endcase

retval='http://' + serv+'/'+paths+imgs


debug=keyword_set(debug)
if debug then stop,'before return'
return,retval
end
