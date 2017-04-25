function str2html, text, _extra=_extra, headers=headers, nolinks=nolinks, $
	link_text=link_text, noparagraph=noparagraph, nouniq=nouniq, $
        bold=bold, paragraph=paragraph
;+
;   Name: str2html
;
;   Purpose: format a block of free-form ascii text into a standard 'html'
;
;   Input Parameters:
;      text - string array to convert to html
;      link_text - if present, lable links with this text 
;                  (default = URL file name)
;      noparagraph - if set, inhibit leading <p>  (1st output element) 
;
;   Calling Sequence:
;      html=str2html(text)
;      html=str2html(text, link_text=link_labels, /nopar)
;
;   Calling Examples:
;      These examples are scalar strings for illustration but this routine
;      will convert a text array (ex: ascii file contents) in one call
;      URLS may be embedded anywhere in the array
; 
;      IDL> more,str2html('http://www/big.gif',/nopar)                 << IN
;         <A HREF="http://www/big.gif"><B>http://www/big.gif</B></A>   << OUT
;
;      IDL> more,str2html('img/big.gif', link='img/thumb.gif',/nopar)  << IN
;         <A HREF="img/big.gif"><B><IMG SRC="img/thumb.gif"></B></A>   << OUT
;
;   Method:
;      identify tables - block with <p><pre>TABLE</pre> ;
;         (note - see strtab2html.pro for IDL string->Version 3 table convert)
;      replace null lines with <p>			; paragraph
;      insert link when URL is detected 
;      some fuzzy logic list detection/conversion is possible
;      
;   History:
;      29-mar-1995 (S. L. Freeland) - for automated TEXT->HTML conversions
;       2-jun-1995 (SLF) - add auto links and NOLINKS keyword
;       6-jun-1995 (SLF) - add auto-title & auto <hr>
;      26-jul-1995 (SLF) - add call to strlist2html
;       8-aug-1995 (SLF) - fixed typo in ascii URL->html reference code
;      25-aug-1995 (SLF) - add LINK_TEXT keyword
;      23-aug-1995 (SLF) - allow LINK_TEXT to be a vector
;			   (to format linked diretory lists, for example) 
;      17-jun-1996 (SLF) - use ".html" instead of "html" for auto-url dectection
;       5-mar-1997 (SLF) - Major upgrade - call <strfind_urls> to simplify
;                          this routine and permit extension to RELATIVE urls
;                          (previous rev only auto-linked ABSOLUTE urls)
;                          Changed default link text to associated URL name
;                          If LINK_TEXT includes .gif or .jpg, they  are
;                          assumed to be inlined images - <img src="... added
;                          All added html is capatilized (industry standard...)
;      27-sep-2005 (SLF) - change default link to non-Bold ; use /BOLD to change back
;      Circa 1-jan-2005 (SLF) - made /NOPAR the default;
;                         use /PARAGRAPH to restore "old" behavior
;-
noparagraph=1-keyword_set(paragraph) 
bold=keyword_set(bold)
boldo=(['','<B>'])(bold)
boldc=(['','</B>'])(bold)
if not keyword_set(link_text) then link_text=""
remtab,text,ttext				; tabs -> spaces
if n_elements(ttext) eq 1 then ttext=['',ttext]
ttext=strlist2html(ttext,/all)			; convert ordered lists

; ----------- find URLS and substitute active links -------------
term=['.html',' ']

titss=where_title(ttext,title=titles)
if titss(0) ne -1 then begin
   ttext(titss)='<HR>'
   sst=where(titles ne '',sstcnt)
   if sstcnt gt 0 then ttext(titss(sst))=ttext(titss(sst)) + $
      '<H4>' + titles(sst) + '</H4>'
endif
; -------------------------------------------------------------------
; SLF - 5-march-1997 - Major upgrade - broke url detection code into
;                      strfind_urls.pro - this extends use to RELATIVE links
; -------------------------------------------------------------------
if not keyword_set(nolinks) then begin
   urls=strfind_urls(ttext,mcount)                        ; slf, 5-mar-1997 
   if mcount gt 1 and n_elements(link_text) eq 1 then $
      link_text=replicate(link_text,mcount)

;  ----------------------------------
;  if LINK "text" includes .gif or .jpeg, assume they are inline images
   link_urls=strfind_urls(link_text,lurlcnt, urlstrings='.gif,.jpg,.png')
   for i=0,lurlcnt-1 do begin
     if strpos(strupcase(link_urls(i).url),'SRC') eq -1 then $
        link_text(link_urls(i).line_n) = $
          str_replace(link_text(link_urls(i).line_n), $
             link_urls(i).url, '<IMG SRC="' + link_urls(i).url + '">')
   endfor
;  ----------------------------------
   for i=0,mcount-1 do begin
      break_file,urls(i).url,ll,pp,ff,vv
      ltext=([link_text(i),urls(i).url])(link_text(i) eq "")
      new=str_replace(ttext(urls(i).line_n),urls(i).url, $
          '<A HREF="' + urls(i).url + '">' + boldo + ltext + boldc + '</A>')
      ttext(urls(i).line_n)=new
   endfor
endif
; -------------------------------------------------------------------

; bracket tables with <P><PRE>TABLE</PRE>
tables=where_table(ttext,tcnt,_extra=_extra)	; find tables

if tcnt gt 0 then begin
   ttext(tables(*,0))='<P><PRE>' + ttext(tables(*,0))
   ttext(tables(*,1))=ttext(tables(*,1)) + '</PRE>'
endif

nulls=where(ttext eq '',ncnt)
nnulls=where(ttext ne '',nncnt)		; not nulls

if ncnt gt 0 then ttext(nulls)='<P>'

if keyword_set(headers) then begin
   hlev=strtrim(headers < 5,2)
   headers=where(deriv_arr(nulls) eq 2,hcnt)
   hss=nulls(headers)+1 < (n_elements(ttext)-1) 
   if hcnt gt 0 then ttext(hss) = $
      '<H'+hlev+'>' + ttext(hss) + '</H' + hlev + '>'
endif

; eliminate duplicate records (['<P>','<P>','<HR>','<HR']

unikit=1-keyword_set(nouniq)
;ttext=ttext(uniq(ttext)) ; historical default?

; upgrade First line titles headers

ss=where(ttext eq '<HR>' and shift(ttext,-1) eq '<P>' and $
   shift(ttext,-2) ne '<P>' and shift(ttext,-3) eq '<P>',tcnt)

if tcnt gt 0 then ttext(ss+2)='<H5>' + ttext(ss+2) + '</H5>'

if keyword_set(noparagraph) and n_elements(ttext) gt 1 and ttext(0) eq '<P>' then $
      ttext=ttext(1:*)

return,ttext
end
