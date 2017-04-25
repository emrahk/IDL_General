function where_title, status=status, text, title=title

;+
;   Name: where_title
;
;   Purpose: identify titles/headers in text array
;
;   Calling Sequence:
;      ss=where_title(text)
;-

ttext=strlowcase(text)			; 

bttext=byte(ttext)
null=where(bttext eq 0b,ncnt)
if ncnt gt 0 then bttext(null)=32	 ; blank fill 

charalpha=arr2str([alphagen(26),strtrim(indgen(10),2)],'')

first=strmid(strtrim(bttext,2),0,1)
last= strmid(strtrim(reverse(bttext),2),0,1) 

chk=where((first eq last) and $
   (strspecial(first) and strspecial(last)) and 		$
   (strlen(strcompress(string(bttext),/remove))) gt 0,ccnt)

if ccnt gt 0 then begin
   title=strarr(ccnt)
   for i=0,ccnt-1 do begin
      stit=strspecial(text(chk(i)))
      titss=where(1-stit,titcnt)
      if titcnt gt 0 then title(i)=$
         strmid(text(chk(i)),titss(0),( (titss(titcnt-1))-titss(0))+1)
   endfor
endif

return,chk
end
