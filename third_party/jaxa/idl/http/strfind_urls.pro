function strfind_urls, text, numberfound, urlstrings=urlstrings
;+
;  Name: strfind_urls
;
;  Purpose: find URLS in a text array, useful for TEXT->HTML conversions
;
;  Input Parameters:
;     text - text array to process
;
;  Keyword Parameters:
;     numberfound (output) - number of URLS found (and #structures returned)
;  
;  Output: 
;     function returns structure vector (nelements=number URLS) of format:
;     {line_n:    0L         ; line number (relative to text subscripts)
;      start_pos: 0L         ; position info for extraction, conversion...
;      stop_pos:  0L         ; ditto
;      line:      ''         ; The pristine line
;      URL:       ''}        ; URL identified (checking, str_replace, etc)
;
;
;   History:
;      5-mar-1997 - S.L.Freeland - for auto TEXT->HTML converters
;                   (simplify <str2html.pro> and expand to relative links)
;-
common strfind_urls_blk, url_struct   ; dont bother recreating this each time

; create structure (first time)
if n_elements(url_struct) eq 0 then $
    url_struct={line_n: 0l, start_pos:0L, stop_pos:0L, line:'', url:''}

lowtext=strlowcase(text)                      ; dont worry about CASE 

nlines=n_elements(text)
retval=url_struct                             ; initialize output w/template
numberfound=0

; ----- identify URL containing lines (speeds up downline processing) ------
if not keyword_set(urlstrings) then $
  urlstrings= 'http:,html,.gif,.jpeg,.mpg,.png'   ; default "url strings"

terms=strtrim(str2arr(urlstrings),2)
bmap=bytarr(nlines)                           ; boolean map
for i=0,n_elements(terms)-1 do $                       ; map lines where URLS..
     bmap = bmap or (strpos(lowtext,terms(i)) ne -1)
ss=where(bmap,sscnt)
; ---------------------------------------------------------------------------

for i=0,sscnt-1 do begin                                 ; for each "url line"
   linex=text(ss(i))                                     ; Pristine line
   linearr=str2arr(linex,' ')                            ; break (assume ' ') 
   map=lonarr(n_elements(linearr))                       ; token map

   for patt=0,n_elements(terms)-1 do map=map or $        ; tokens where URL
      (strpos(strlowcase(linearr),terms(patt)) ne -1)
   which =where(map,urlcnt)                              

   if urlcnt eq 0 then message,/info,"???" else begin    ; should be at least 1
     new=replicate(url_struct,urlcnt)

     ;    ---- populate structure for each URL -----
     new.line_n=ss(i)                                    ; line# -> structure
     if urlcnt eq 1 then new.url=(linearr(which))(0) $   ; URL   -> structure
         else new.url=linearr(which)
     new(*).line=linex(0)                                ; line  -> structure
     for url=0,urlcnt-1 do new(url).start_pos= $         ; start -> structure
	    strpos(linex,linearr(which(url)))
     if urlcnt eq 1 then $
	 new.stop_pos=(new.start_pos + strlen(linearr(which)))(0) $
            else new.stop_pos=new.start_pos + strlen(linearr(which))
;    ----------------------------------------------------
     retval=[retval,new]                                 ; update output
     numberfound=n_elements(retval)-1
   endelse
endfor

if n_elements(retval) gt 1 then retval=retval(1:*)        ; strip initial value

; --------- remove trailing periods ---------------
lenurl=strlen(retval.url)-1                               
sslast=where(strlastchar(retval.url) eq '.',sscnt)
for i=0,sscnt-1 do retval(sslast(i)).url= $
     strmid(retval(sslast(i)).url,0,lenurl(sslast(i)))
; ---------------------------------------------------

return, retval
end
