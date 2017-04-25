function url_hexreplace, bval
;
;  Name: url_hexreplace
;
;  Purpose: replace encoded HEX with byte equivilent
;
;  Calling Sequence:
;    updated=url_hexreplace(bval)  
;
;    (generally called from url_decode)
; 
special=where_pattern(bval,'%',scnt)		; identify HEX characters
if scnt gt 0 then begin 			; 
   zvals=string(transpose(bval(special+1))) + $ ; extract HEX digits
         string(transpose(bval(special+2)))
   bexchange=bytarr(n_elements(zvals))		
   reads,zvals,bexchange,format='(z2.2)'	; convert to byte equiv
   bval(special)=bexchange			; replace '%' with byte(HEX) 
   bval([special+1,special+2])=32b		; blank fill other bytes
endif
return, bval
end

function extract_val, invalue
;
;+ 
;   Name: extract_val
;
;   Purpose: translate one FORM variable to string (or string array)
;
;   Input:
;      invalue - one "raw" POST-query value
;
;   Output:
;      function returns translated string or string array 
;-
value=str2arr(invalue,'%0D%0A')			      ; inter-tag line breaks
bval=url_hexreplace(byte(value))		      ; convert HEX-> byte
value=str_replace(strcompress(bval,/remove),'+',' ')  ; trim excess blanks

return, value
end

function url_decode, query, qfile=qfile
;+
;   Name: url_decode
;
;   Purpose: decode WWW URL-encoded query (ex: POST query -> IDL structure)
;
;   Input Parameters:
;      query - url encoded query (ex: from POST WWW Form)
;
;   Keyword Parameters:
;      qfile - file containing query (used in place of query parameter)
;
;   Output:
;      function returns IDL structure of form...
;         { name1: value1		     ; values are string/string arrays
;         [,name2: value2, nameN: valueN] }  ; one tag per query field
;
;   History:
;      20-Mar-1996 S.L.Freeland (for WWW/IDL server use)
;       7-Jun-1996 S.L.Freeland - changed dynamic structure build 
;      11-Jun-1996 S.L.Freeland - return null string if bad POST 
;      22-Jan-1999 S.L.Freeland - allow encoded variables in addition to values
;       4-oct-2002 S.L.Freeland - handle duplicate variable names
;          (very rare so I immediately ran into them. .)
;       09-May-2003, William Thompson - Use ssw_strsplit instead strsplit
;      27-jan-2006, S.L.Freeland - merged divergent (last two mods)->online
;-
;  read WWW POST Query file
if keyword_set(qfile) then begin			; not found
   if not file_exist(qfile) then begin			; so look in "standard" 
      break_file,qfile,log,path,file,ext,version
      top_http=get_logenv('path_http')
      queryf=concat_dir(top_http,concat_dir('text_client',file+ext+version))
   endif else queryf=qfile
   if not file_exist(queryf) then begin
      message,/info,"Cannot find file: " + queryf
      return,''
   endif
   query=(rd_tfile(queryf))(0)
endif

;  parse query 
parts=str2arr(query,'&')			; field breaks
keys=ssw_strsplit(parts,'=',tail=values)		; tag/value breaks
ssdup=find_dup(keys)
dups=where(ssdup ne -1,dcnt)

for i=0,dcnt-1 do begin
   ssi=where(keys eq keys(ssdup(i)),idups)
   ssnn=where(values(ssi) ne '',nncnt)
   case nncnt of
     0:
     1: values(ssi)=values(ssi(ssnn))
     else: values(ssi)=arr2str(values(ssi(ssnn)))
   endcase
endfor

ssun=uniq(keys,sort(keys))
keys=keys(ssun)
values=values(ssun)


nkeys=n_elements(keys)

; build the output structure template
strstr='{dummy'
for i=0, nkeys-1 do $
   strstr= strstr + ',' + keys(i) + ':' + fmt_tag(size(extract_val(values(i))))
outstr=''
strstr=extract_val(strstr)

badterm=strpos(strstr,",:''")
if badterm eq -1 then begin
   outstr=make_str(strstr+'}')
   ; Second loop - now fill in the tags
   for i=0, nkeys-1 do outstr.(i)=extract_val(values(i))
endif else begin
   len=strlen(strstr)
   if strpos(strstr,",:''") eq (len-4) and len gt 8 then begin
       message,/info,"Query truncated - proceeding..."
       strstr=strmid(strstr,0,badterm)     
       outstr=make_str(strstr+'}')
       for i=0, n_tags(outstr)-1 do outstr.(i)=extract_val(values(i))
   endif else message,/info,"Fatal problem with POST (old browser?)....
endelse

return,outstr
end
