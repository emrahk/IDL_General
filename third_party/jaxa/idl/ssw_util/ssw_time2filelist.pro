function ssw_time2filelist, time0, time1, debug=debug, parent=parent, $
   in_paths=in_paths, count=count, $
   in_files=in_files, pattern=pattern, recurse=recurse, _extra=_extra, $
   fits=fits, paths_prepend=paths_prepend, pflat=pflat, quiet=quiet, $
   extension=extension, loud=loud
;+
;   Name: ssw_time2filelist
;
;   Purpose: return files within time range on local (nfs) or remote (http) chron. organized archive
;
;   Input Paramters:
;      time0, time1 - time range desired
;
;   Keyword Parameters
;      parent - optional top level; assumed structured <parent>/yyyy/mm/dd - nfs or url 
;      in_paths  - list of explicit paths to search (if not chron subdirs)
;      in_files - explicit file list or url list (skip listing segment)
;      pattern - optional file pattern
;      recurse - (switch) recursive search for all PATHS 
;      fits - (switch) - if set, imply PATTERN='*.fts' or '*.fits'
;      extension - optional file extension of interest, like exten='.cdf'
;      /daily,/weekly,/monthly,/year_2digit,/hour - in conjunction w/PARENT
;         describe directory structure 
;         directory structure - default=/DAILY -> <parent>/yyyy/mm/dd/<files>
;      flat (switch -> ssw_time2paths) - if subdirectories are not nested.
;              for example,  <parent>/yyyymmdd instead of <parent>/yyyy/mm/dd
;      pflat (switch) - implies all files in <parent> ; e.g, no cron subdirs.
;      count (output) - number of files/urls returned
;
;   Calling Examples:
;      IDL> eitqkl=ssw_time2filelist(reltime(hours=-6),reltime(/now),parent='$EIT_QKL')
;      IDL> help,eitqkl & more,[eitqkl(0),last_nelem(eitqkl)]
;           /service/eit_data/quicklook/2006/07/31/efr20060731.160009 ; YYYY/MM/DD org
;           /service/eit_data/quicklook/2006/07/31/efr20060731.202409
;
;      IDL> eitlz=ssw_time2filelist('12:00 15-mar-2001','06:00 16-mar-2001',$
;                     parent='$EIT_LZ',/MONTHLY)
;      IDL> help,eitlz & more,[eitlz(0),last_nelem(eitlz)]
;      IDL> /service/eit_data/lz/2001/03/efz20010315.120011 ; YYYY/MM org (/MONTHLY)
;      IDL> /service/eit_data/lz/2001/03/efz20010316.054810
;
;      ---- http server example; web crawl a chronologically organized archive  ----
;      IDL> urls=ssw_time2filelist(parent='http://solarmonitor.org/swap',$
;              '15-jan-2010 23:20', '16-jan-01:10,/flat)
;           (uses /FLAT since This archive uses <parent>YYYYMMDD, not <parent>YYYY/MM/DD
;
;
;   History:
;      27-Jul-2006 - S.L.Freeland - recast file/dir time search using
;                    sss_time2paths & RSI 'file_search' & 'strmatch'
;       4-Dec-2006 - S.L.Freeland - document /FLAT option, used by
;                    STEREO/SECCHI for example (via secchi_time2filelist)
;                    Fixed a type (temporarary mispell in heretofore unexplored path)
;       25-apr-2007 - S.L.Freeland - allow /FLAT in combo with no-prefix filens
;       17-sep-2007 - SLF - tag_exist->required_tags (identical albeit 
;                           quieter behavior)
;       22-may-2008 - SLF - add /PFLAT (parent-flat)
;        4-jun-2009 - SLF - allow parent=url 
;       11-jun-2009 - SLF - add COUNT keyword & return '' when COUNT=0
;       17-Jul-2009 - Zarro (ADNET) - added check for proper
;                     delimiter when prepending path.
;       12-aug-2009 - SLF - allow mixed case filenames in URL segment
;       12-mar-2010 - SLF - add EXTENSION keyword and function
;       21-feb-2013 - SLF - ftp servers (parent=ftp://...)
;       29-aug-2014 - SLF - work around historical .fits bias if PATTERN supplied
;
;   Method:
;      combine implied calls to ssw_time2paths, file_search & strmatch
;
;   Restrictions:
;      if 'in_files' supplied, assume ...[yy]yymmdd[delim[hhmm[ss[mss]]]]]....
;      Need at least V5.4 if internal listing is desired (RSI file_search)
;      Need at least V5.3 if IN_FILES supplied (ie, no listing - need RSI strmatch) 
;      If PARENT supplied, then we assume "standard" chronological 
;      subdirectory ordering per ssw_time2paths - in that case, PATHS
;      is derived from the implied and derived path list
;      For http servers: historically, assumed FITS extensions {.fits,.fts.,FITS,.FTS}
;         12-mar-2010 mod allows EXTENSTION='.<yourextension>', like exten='.cdf'
;-
;

quiet=keyword_set(quiet)
loud=1-quiet
case 1 of 
   since_version(5.4): ;ok
   since_version('5.3') and data_chk(in_files): ; ok
   else: begin 
      box_message,['Sorry, you need at least:',$
                   'IDLV 5.3 if you supply IN_FILES (rsi strmatch) -or-',$
                   'IDLV 5.4 if you do not supply IN_FILES (rsi file_search)']
   endcase
endcase
debug=keyword_set(debug)

count=0
case n_params() of
   0: begin 
         box_message,'Need time or time range'
         return,''
   endcase
   1: begin 
         time1=reltime(time0,/days)
   endcase
   else:
endcase

t0=anytim(time0,/ecs)
t1=anytim(time1,/ecs)

; listing segment
if not data_chk(in_files,/string) then begin 
   retval=''
   case 1 of 
      data_chk(in_paths,/string):  paths=in_paths ; user supplied paths 
      data_chk(parent,/string): begin 
         if keyword_set(pflat) then paths=parent else $
               paths=ssw_time2paths(t0,t1,parent,_extra=_extra)
      endcase
      else: begin
         paths=curdir()
         box_message,'No PATHS or PARENT; assuming currend directory....'
      endcase
   endcase
   if keyword_set(paths_prepend) then begin 
     dates=ssw_strsplit(paths,'/',/tail,head=par)
     paths=concat_dir(par,paths_prepend+dates)
   endif 
   if strpos(paths(0),'://') ne -1 then begin 
      paths=paths+'/'
      paths=str_replace(paths,'\','/')
      urllist=''
       
      for i=0,n_elements(paths)-1 do begin 
         if loud then print,'Listing>> '+ paths(i)
         sock_list,paths(i),ulist
         ulist=web_dechunk(ulist)  
         lulist=strlowcase(ulist)
         sscnt=0 & sspcnt=0
         if keyword_set(pattern) then begin ; a little spagetti since due to historical extension='.fits' bias ; make PATTERN dominate
            ss=where(strmatch(ulist,pattern,/fold),sspcnt)
            if sspcnt gt 0 then begin 
               ulist=ulist[ss]
               lulist=lulist[ss]
            endif
         endif
         ssp=lindgen(n_elements(ulist)) ; init to all matches ; (pattern already considered & filtered on)
         if keyword_set(extension) then begin
            ext='.'+str_replace(extension,'.','')
            ss=where(strpos(lulist,ext) ne -1 ,sscnt)
         endif else begin
            ss=where(strpos(lulist,'.fits') ne -1 or $
                  strpos(lulist,'.fts')  ne -1, sscnt) 
         endelse
         if sscnt eq 0 and sspcnt gt 0 then begin
            ss=ssp
            sscnt=n_elements(ssp)
         endif
         if sscnt gt 0 then begin 
           hrpat=(['href="','HREF="'])(strpos(ulist(ss(0)),'HREF') ne -1)
           files=strextract(ulist(ss),hrpat,'">')
           urllist=[temporary(urllist),paths(i)+files]
         endif ; else if loud then box_message,'No files in ' + paths(i) ; too much noise
      endfor
      if n_elements(urllist) eq 1 then begin 
         box_message,'No files in all paths'
         return,retval ; !! early exist
      endif else in_files=temporary(urllist(1:*))
      
   endif else in_files=file_search(paths,'',/full,count=count)
endif

case 1 of 
   keyword_set(fits): matches=strmatch(in_files,'*.fts',/fold_case) or $
                              strmatch(in_files,'*.fits',/fold_case)
   keyword_set(pattern): begin
      matches=strmatch(in_files,pattern)
      chk=where(matches,ccnt)
      if ccnt eq 0 and strpos(pattern,'"') ne -1 then matches=strmatch(in_files,str_replace(pattern,'"',''))
   endcase
   else: matches=intarr(n_elements(in_files))+1
endcase

ssm=where(matches,mcnt)
if mcnt eq 0 then begin 
   box_message,'No files match your pattern...'
   count=0
   return,''
endif

tfiles=temporary(in_files(ssm))
tfiles=tfiles(sort(tfiles))
flen=strlen(tfiles)
hlen=histogram(flen,min=0)
if get_logenv('check') ne '' then stop,'tfiles'
ssok=where(flen eq (where(hlen eq max(hlen)))(0)) ; eliminate bogus files
tfiles=tfiles(ssok)
 
; time search
if required_tags(_extra,'FLAT') then $

   fid=extract_fids(ssw_strsplit(tfiles,'/',/last,/tail),fidfound=fidfound) else $
   fid=extract_fids(tfiles,fidfound=fidfound)
if fidfound then begin  ; 
   dpos=where(strspecial(fid(0)))
   fdelim=strmid(fid(0),dpos,1)
   tf0=time2file(t0,delim=fdelim,year2=dpos eq 6)
   tf1=time2file(t1,delim=fdelim,year2=dpos eq 6)
   sst=where(fid ge tf0 and fid le tf1,tcnt)
   if tcnt gt 0 then begin 
      retval=tfiles(sst) 
      if n_params() eq 1 then retval=(temporary(retval))(0) ; 
      count=tcnt
   endif else begin
      box_message,'No files in your time range...'
      retval=''
   endelse
endif else begin
   box_message,'Problem parsing times in filenames
endelse
if debug then stop,'before return'

return,retval
end

