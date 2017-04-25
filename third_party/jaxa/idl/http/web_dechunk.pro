function web_dechunk, webstuff, compress=compress, maxlen=maxlen, debug=debug
;+
;   Name: www_dechunk
;
;   Purpose: clean chunked html, optionally remove nulls
;
;   Input Paramters:
;      webstuff - web page html, output from cgi... assumed ascii strarr
;
;   Method:
;      Check <webstuff> for valid HEX digits and assume those flag chunks
;
;   History:
;      Circa 15-jun-2008 - S.L.Freeland - done before.. but JSOC/JSON take
;      25-jun-2008 - kludge? only consider >2 HEX characters
;      10-sep-2008 - allow #chars>=2 
;      8-dec-2008 - S.L.Freeland - change (fix) the identification of chunks
;      6-mar-2009 - S.L.Freeland - fix 'nuther discovery
;-
debug=keyword_set(debug)

if n_elements(maxlen) eq 0 then maxlen=5 ; don't waste time on longer lines
;                                        ; (max HEX digits)
;
retval=webstuff           ; default OUT is IN (assume no chunks)
inws=strtrim(webstuff,2)  ; working version

inl=strlen(inws)

ssc=where(inl le maxlen and inl ge 2,ccnt)  ; possible chunk indicators
compress=keyword_set(compress)

if ccnt gt 0 then begin 
   nc=n_elements(ssc)
   css=lonarr(nc)
   test=fix(byte(strlowcase(inws(ssc)))) 
   nn=fix(byte(['0','9']))
   na=fix(byte(['a','f']))
   for i=0,(maxlen<max(inl(ssc)))-1 do begin
     tti=reform(test(i,*))
     css=css+(tti ge nn(0) and tti le (nn(1)) or (tti ge na(0) and tti le na(1)))
   endfor
   hss=where(css eq inl(ssc),hcnt) ; lines where every char is a valid HEX digit
   if hcnt gt 0 then begin ; at least one valid HEX; assume chunk
      chunkss=ssc(hss) ; 
      nc=n_elements(retval)
      ssrl=rem_elem(chunkss,nc-1)
      if debug then stop,'ssrl,chunkss'
      if ssrl(0) ge 0 then chunkss=chunkss(ssrl) else begin 
         chunkss=-1
         retval(nc-1)=''
      endelse
      if chunkss(0) eq 0 then begin
         retval(0)='' ; 1st is special case
         if n_elements(chunkss) gt 1 then chunkss=chunkss(1:*) else chunkss=-1
      endif
      if chunkss(0) ne -1 then begin 
         for i=0,n_elements(chunkss)-1 do begin 
             retval(chunkss(i)-1) = retval(chunkss(i)-1) + retval(chunkss(i)+1)
             retval(chunkss(i))=''
             retval(chunkss(i)+1)=''
         endfor
         buff=''
         for i=0,n_elements(retval)-1 do buff=buff+retval(i)
      endif
      if compress then retval=strarrcompress(retval)
   endif
endif

if debug then stop,'before return, retval'
return,retval
end



