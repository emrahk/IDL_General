pro ssw_conflicts, pattern,  conffile=conffile, _extra=_extra, $
   full=full, conflicts=conflicts , debug=debug, nomail=nomail, $
   except=except
;+
;   Name: ssw_conflicts
;
;   Purpose: check input files or files matching pattern against online SSW
;
;   Input Parameters:
;      pattern - string pattern of files or paths to check (ex: 'yohkoh/gen' )
;
;   Keyword Parameters:
;      conffile     - optional conflict file name 
;      full         - if set, do a full listing
;      conflicts    - if set, only show conflicts
;      nomail       - if set, don't mail results
;      /XXX (anything else) - instrument, mission, or package to check
;      except - optional string/path pattern to ignore (beta testing for examp
;               might exclude release area since conflicts expected       
;
;   Calling Sequence:
;      ssw_conflicts,/xxx		; Routines instrument/mission/pack XXX 
;      ssw_conflicts,'pattern'          ; check SSW files matching pattern
;
;   Calling Examples:
;      ssw_conflicts,/cds               ; conflicts under CDS branch
;      ssw_conflicts,/chianti           ; conflicts under Chianti Package
;      ssw_conflicts,/gen               ; conflicts under $SSW/gen/...
;      ssw_conflicts,'soho/gen'         ; conflicts unser $SSW/soho/gen
;      ssw_conflicts,/sxig12_YYMMDD, except='/sxig12/' ; EXCEPT to ignore "expected" conflicts
;
;   History:
;      31-oct-1996 - S.L.Freeland - derive from chk_conflict 
;      12-apr-1997 - protect output in case where number conflicts eq ZERO!
;                    (a sign that we are making progress...)
;                    add a status line (SSWLOC search pattern used)
;                    cleanup and document - send mail by default
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;      13-May-2003, S.L.Freeland, added EXCEPT keyword and function
;  
;   Method:
;      Call sswloc to get matching file list
;      Call file_diff(/idlpro) to differentiate CODE & HEADER differences
;      Keyword Inheritance used for self updating actioin
;      (new misstions, instruments, packages added to SSW need no change)
;-
case 1 of 
   keyword_set(_extra) and n_elements(pattern) eq 0: begin
      epat=(tag_names(_extra))(0)                           ; keyword inherit
      pattern=strrep_logenv(get_logenv('SSW_'+epat),'SSW')
      if pattern eq '' then pattern='/'+epat+'/'
      conffile=concat_dir('SSW_SITE_LOGS', $
         str_replace(strmid(pattern,1,100),'/','_')) + '.conflicts'
      sswloc,pattern,tfile
   endcase 
   file_exist(pattern(0)): tfile=pattern
   n_elements(pattern) gt 1: tfile=pattern
   else: sswloc,pattern,tfile
endcase

pros=ssw_strsplit(tfile,'/',/last,/tail)
npros=n_elements(pros)

statmess  =strarr(npros)
cstatus    =intarr(npros)
sswconf   =strarr(npros)

for i=0,n_elements(tfile) -1 do begin
  sswloc, '/'+pros(i), sswfiles, count,/quiet,except=except
  sswfile=''
  case 1 of 
     count eq 0: mess="Not in SSW MAP"
     count eq 1: mess="No conflicts 
     else: begin
        sswfiles=sswfiles(rem_elem(sswfiles,tfile(i)))  ; remove THIS one
        diff=file_diff(tfile(i),sswfiles(0), mess=mess, status=status,/idlpro)
        sswfile=sswfiles(0)
     endelse
  endcase
  cstatus(i)=count
  statmess(i)= mess
  sswconf(i)=sswfile  
  if keyword_set(full) or count gt 1 then $
      more,strpad(tfile(i),50,fill='.',/after) + ' #Occur ' + strtrim(count,2) + ' ' + mess
  if count gt 1 and keyword_set(debug) then stop
endfor

conflicts =where(cstatus gt 1,nconf)

omess=strjustify(tfile) + '  ' + strjustify(sswconf) + $ 
      string(cstatus,format='(i3)') + '  ' + strjustify(statmess)

if data_chk(conffile,/string) then begin
   message,/info,"Writing results to: " + conffile
   pr_status,status,/idldoc, caller='ssw_conflicts'
   file_append,conffile,status,/new
   if n_elements(pattern) eq 1 then $
      file_append,conffile,"; SEARCH PATTERN: '"+pattern(0)+"'"
   file_append,conffile,"; Number of files checked: " + strtrim(npros,2)
   file_append,conffile,";     Number of conflicts: " + strtrim(nconf,2) 
   file_append,conffile,"; ----------------------------------------------"
   if keyword_set(full) then ss=lindgen(npros) else ss=conflicts
   if ss(0) eq -1 then file_append,conffile,'*** NO CONFLICTS FOUND ***' else $
      file_append,conffile,omess(ss)
   if not keyword_set(nomail) then $
      mail, user=get_user(), /no_def, file=conffile, $
         subj='ssw_conflicts result for pattern <'+pattern(0)+'>'
endif

return
end
