pro html_doc, filename, header=header, trailer=trailer, title=title, $
   outarr=outarr, credits=credits, template=template, base_url=base_url, $
   notemplate=notemplate
;+
;   Name: html_doc
;
;   Purpose: handle standard header and trailer html documents (templates)
;
;   Input Paramters:
;      filename (optional) - appends the text to this file
;
;   Keyword Paramters:
;      template - if set, name of template file (default from $path_http/...)
;      header -   if set, return header html 
;      trailer -  if set, return trailer html
;      credits -  if set, include SXT credits in trailer
;      outarr  -  (output) - returns contents of template file 
;      base_url - if specified, add a BASE URL tag
;                 (relative tags will default to this parent)
;      notemplate - dont use the default $path_http/template even if it exists
;
;   Note:
;      If template file not supplied, defaults are:
;         $path_http/header_template.html                 /header
;         $path_http/trailer_template.html                /trailer
;         $path_http/trailer_wcredit_template.html        /credits 
;
;
;   Calling Example:
;      IDL> htmlfile='$path_http/xxx.html'      ; doc name                     
;      IDL> html_doc, htmlfile , /header        ; start doc w/header info
;      IDL> file_append,htmlfile , HTML         ; build your html doc
;           (etc, etc)
;      IDL> htmldoc, htmlfile, /trailer         ; finish documnent
;  
;   History:
;      4-Jan-1997 - Sam Freeland (Generic version of 'sxt_html.pro') 
;     14-apr-1998 - S.L.Freeland (supply basal,inline html if no template $
;                     file exists)
;      9-Sep-1999 - S.L.Freeland - add BASE_URL keyword and function
;-

trailer=keyword_set(trailer) 
if not keyword_set(title) then title="Created by " + get_user() + " at " + ut_time() + " UT"
header=keyword_set(header)

writeit=data_chk(filename,/string)

case 1 of 
   keyword_set(header): file='header'
   keyword_set(trailer): file=(['trailer','trailer_wcredit'])(keyword_set(credits))
   else: file=''
endcase

if data_chk(template,/string) then begin
   if file_exist(template) then fname=template else $
       fname=concat_dir('$path_http',template) 
endif else fname=concat_dir(get_logenv('path_http'),file+'_template.html')

notemplate=keyword_set(notemplate)
if not file_exist(fname) or notemplate then begin 
   if not notemplate then box_message,'No template file found, supplying default html'
   case 1 of
      keyword_set(header): outarr=[ $
         '<HTML>','<HEAD>','<TITLE>!TITLE!</TITLE>','</HEAD>', $
	 '<BODY type=fadein bgcolor="#EFEFEF">', $
	 '<H4><EM>Created by '+ get_user()+ ' at ' + systime()+'</EM></H4>']
      keyword_set(trailer): outarr=[$
         '<hr>','<A HREF="mailto: '+ get_user()+'@'+get_host()+'">', $
	                     '<EM>'+ get_user()+'@'+get_host()+'</EM></A>',$
         '</BODY>','</HTML>']
      else: if n_elements(outarr) eq 0 then outarr=''
   endcase
endif else outarr=rd_tfile(fname)

; Add BASE_URL on request
tophttp=get_logenv('top_http')
case 1 of
   data_chk(base_url,/string): begin
      testenv=get_logenv(base_url)
      if testenv ne '' then baseurl=testenv else baseurl=base_url
   endcase
   data_chk(base_url,/defined): begin
      testsub=concat_dir(tophttp,'movies/')            ; default $path_http/movies
      if testsub ne '' then baseurl=testsub else baseurl=tophttp
   endcase
   else: baseurl=''
endcase   
  
if baseurl ne '' then begin
  basestring='<BASE HREF="'+baseurl+'">'
  outarr=strarrinsert(strupcase(outarr),basestring,'<HEAD>')
endif  

if header then outarr=str_replace(outarr,'!TITLE!',title)
if writeit then file_append,filename, outarr, new=header

return
end
