pro html_basics, filename, header=header, trailer=trailer, title=title, $
   nologo=nologo, noimg=noimg, outarr=outarr, credits=credits, $
   simple=simple
;+
;   Name: html_basics
;
;   NOTE: see html_doc.pro , slightly different but ~supported evolutionary branch 
;
;   Purpose: Return standard header/trailer html
;
;   Input Paramters:
;      filename (optional) - appends the text to this file
;
;   Keyword Paramters:
;      header -  if set, return header html
;      trailer - if set, return trailer html
;      credits - if set, include credits in trailer
;      noimg -   if set, leave off logo
;      simple -  if set, then just make the basic header and trailer
;
;   History:
;	Written ?? by S.Freeland
;	24-Oct-96 (MDM) - Renamed from "sxt_html" to "html_basics"
;	 6-Jan-99 (MDM) - Added /SIMPLE option
;-
trailer=keyword_set(trailer) 
if not keyword_set(title) then title="UNTITLED: Created by " + get_user() + " at " + ut_time() + " UT"
header=keyword_set(header) or keyword_set(nologo) 

writeit=data_chk(filename,/string)

case 1 of 
   keyword_set(header): begin
      file='header'
   endcase
   keyword_set(trailer): begin
      file=(['trailer','trailer_wcredit'])(keyword_set(credits))
   endcase
endcase

fname=concat_dir(get_logenv('path_http'),file+'_template.html')

if (keyword_set(simple)) then begin
    case 1 of 
	   keyword_set(header): begin
		outarr = ['<HTML>', $
			'<HEAD>', $
			'<TITLE>!TITLE!</TITLE>', $
			'</HEAD>', $
			'<BODY type=fadein bgcolor="#EFEFEF">']
	   endcase
	   keyword_set(trailer): begin
		outarr = ['</BODY>', '</HTML>']
	   endcase
    endcase

end else begin
    if not file_exist(fname) then begin
	message,/info,"Cannot find template file: " + fname	
	return
    endif

    outarr=rd_tfile(fname)
end

if keyword_set(nologo) and header then begin
   logoss=where(strpos(strcompress(strupcase(outarr),/remove),'<IMG') ne -1,lcnt)
   if lcnt gt 0 then outarr=outarr(0:logoss(0)-1)
endif

if header then outarr=str_replace(outarr,'!TITLE!',title)

if writeit then file_append,filename, outarr, new=header

return
end
