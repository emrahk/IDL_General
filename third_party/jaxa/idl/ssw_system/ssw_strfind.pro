pro ssw_strfind, pattern, match_files, files=files, _extra=_extra, $
   case_sensitive=case_sensitive, outfile=outfile,  comments=comments, $
   details=details, flag=flag, mail=mail,compress=compress, $
   loud=loud, append=append
;+
;   Name: ssw_strfind
;
;   Purpose: find a string pattern in SSW online files (or input file list)
;
;   Input Parameters:
;      pattern - string pattern to search for (see _EXTRA keyword for option)
;
;   Output Parameters:
;      match_files - list of files where pattern found
;
;   Keyword Parameters:
;      files          - file list to search (default is entire SSW tree)
;      case_sensitive - switch, if set, search is CASE sensitive (def=insens)
;      comments       - switch, if set, include COMMENTS in search (def=EXCLUDE)
;      details     - switch, if set, run SEARCH.PRO on matching files
;      outfile     - output file name for search results 
;                    (if switch, /outfile, then name=$HOME/ssw_strfind.dat)
;
;      _extra      - assume PATTERN passed via keyword inheritence
;                    (ex: IDL> ssw_strfind,/uniq) - pattern='uniq')
;
;   Side Effects:
;      Creates output file of search results (OUTFILE, 
;                     default=$HOME/ssw_strfind.dat)
;
;   History:
;      14-oct-1996 - S.L.Freeland 
;       2-may-1996 - S.L.Freeland - make file anem include part of string
;
;   Method - calls SSWLOC, WC_WHERE, RD_TFILE, etc.
;-

; define pattern to search for
case 1 of
   n_elements(pattern) gt 0: spattern=pattern(0)
   data_chk(_extra,/struct): spattern=_extra.(0)        ; only First 
   else: begin
      message,/info,"Must supply pattern to look for, returning"
      return
   end
endcase

; define file list for search
if n_elements(files) eq 0 then sswloc,undefined,files	; SSW tree
nf=n_elements(files)					; #files to search

if not keyword_set(flag) then flag=(nf/100)>1


; define output file name
if data_chk(outfile,/string) then  outf=outfile

case_sensitive=data_chk(_extra,/struct) or keyword_set(case_sensitive)

mmap=lonarr(nf)

if strpos(spattern,'*') eq -1 then spattern='*'+spattern+'*'
special=strspecial(spattern)
ss=where(special,scnt)
if not data_chk(outf,/string) then begin
   bpat=byte(spattern)
   bpat(ss)=95b
   outf=(concat_dir('$HOME','ssw_strfind_'+string(bpat)))(0)
endif
message,/info,"Writing to file: " + outf

file_append,outf, new=1-keyword_set(append), [ $
   "","ssw_strfind run at: " + systime() + " on host " + get_host(), $
   "; Searching " + strtrim(nf,2) + " files for pattern <" + spattern +">"]

for i=0,nf-1 do begin
   dat=strcompress(rd_tfile(files(i),nocomment=([';',''])(keyword_set(comments))),remove_all=keyword_set(compress))
   ss=wc_where(dat,spattern,case_ignore=(1-keyword_set(case_sensitive)),count)
   mmap(i)=count
   print,(['','*'])(i mod flag eq 0),format='(t1,a,$)'
endfor

nmatch=where(mmap gt 0,mcnt)

if mcnt eq 0 then begin
   match_files=''
   mess="NO MATCHES FOUND!!"
   file_append,outf,mess
endif else begin
   match_files=files(nmatch)
   mess="Number of files where pattern found: " + strtrim(mcnt,2)
   file_append,outf,['; ' + mess,match_files]
   if keyword_set(details) then begin
      message,/info,"Preparing detailed list...
      delim='; --------------------------------------------------'
      for i=0,mcnt-1 do begin
         dat=strcompress(rd_tfile(match_files(i),/compress,nocomment=([';',''])(keyword_set(comments))),remove_all=keyword_set(compress))
         ss=wc_where(dat,spattern,case_ignore=(1-keyword_set(case_sensitive)),count)
         file_append,outf, [delim, match_files(i), dat(ss)]
      endfor
   endif
endelse

if keyword_set(mail) then begin
   mess=["Results from file: " + outf,rd_tfile(outf)]
   if n_elements(mess) gt 24 then mess=[mess(0:23),'; ... (more) ...']
   mail,mess, /no_defsubj, subj="ssw_strfind <"+spattern+"> results"
endif

return
end
