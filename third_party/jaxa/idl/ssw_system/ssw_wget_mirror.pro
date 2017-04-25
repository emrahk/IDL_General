function ssw_wget_mirror, geturls, outdirs,  $
   spawn=spawn, accept=accept, pattern=pattern, mirror_file=mirror_file, $
   site=site, nowait=nowait, $
   old_paradigm=old_paradigm, new_paradigm=new_paradigm, cleanup=cleanup
;+
;    Name: ssw_wget_cmds
;
;    Purpose: return and optionally spawn implied mirror-like wget commands 
;   
;    Input Paramters:
;       geturls - list of one or more urls to get
;       outdirs - corresponding parent directory(ies) for output (def=curdir())
; 
;    Output:
;       function returns implied wget commmand(s)
;
;    Keyword Paramters:
;       spawn - if set, execute the wget command(s)
;       accept,pattern (synonyms) - optional file pattern/pattern list to get
;       mirror_file - optionally, mirror package file which will be used
;                   to derive 'geturls' and 'outdirs' (Not Yet Implemented)
;       nowait - don't insert random wait switch (default is kinder to server)
;       NOTE: mirror_file provides plan for transitioning ssw_upgrade.pro
;             from ftp to wget
;       new_paradigm (/switch) - large change in switches; may be better
;                       than original, but I'll wait before default change
;                       reccomended though for new apps.
;       NOTE: /NEW_PARADIGM is default as of 12-nov-2007 - use /OLD_PARDIGM
;             to override
;       old_paradigm (/switch) - force "old" switches
;       cleanup - is /spawn is set, then run ssw_wget_cleanup After execution
;                 (removes 'html*index' recursively under OUTDIR/....) 
;
;   Calling Sequence:
;      IDL> wgetcmds=ssw_wget_mirror(urls, parentdirs [,/spawn] [,pattern=patt])
;      IDL> wgetcmds=ssw_wget_mirror(urls,parentdirs,/NEW_PARADIGM,/spawn...)
;           (the /new_paradigm forces different switches - try that 1st!)
; 
;  Calling Example:
;      Get EIT quicklook files for 15-jan-2007 (assuming still online..; otherwise, use ..'eit_lz'.. in place of ..'eit_qkl')
;      IDL> wgetc=ssw_wget_mirror('http://umbra.nascom.nasa.gov/eit_qkl/2007/01/15/',curdir(),/spawn,pattern='efr*')
;    
;  Restrictions:
;     This routine Purposefully limits wget options to most closely
;     mimic the historical perl Mirror while providing (imho) a more
;     intuitive ssw interface - if you want fancy/advanced wget options,
;     just use wget since you must be an expert - this is wget for dummies.
;     (don't ask me why the -mirror option in wget still requires a wrapper,
;     such as -nP (noparent) and -nH (nohost), but there it is...)
;     If /SPAWn is set, local/client machine must have 'wget' avaialble'
;     TODO? - distribute OS/ARCH wget binaries under $SSW_BINARIES
;     mirror_file not implemented as of today...
;     unix only for today...
;
;   History:
;      17-jan-2007 - S.L.Freeland - preparing for the day when Mirror is 
;                    phased out for ssw/sswdb distribution/upgrades...
;                    this is planned as an ssw_upgrade.pro swapin/option
;       6-mar-2007 - S.L.Freeland - ignore robots.txt , add random wait
;      20-oct-2007 - S.L.Freeland - add /NEW_PARADIGM keyword+function
;                    (different algorithm/switches and ~better)
;      12-nov-2007 - S.L.Freeland - made /new_paradigm the default and
;                    added /old_paradigm
;-
;
case 1 of 
   data_chk(mirror_file,/string): begin 
      box_message,'MIRROR_FILE input not yet implemented...'
      return,''
   endcase
   n_params() eq 0: begin
      box_message,'Must supply MIRROR_FILE or geturls input'
      return,''
   endcase
   n_params() eq 1:begin
      outdirs=curdir() ; no user supplied output
   endcase
   else:
endcase

nurl=n_elements(geturls)
nout=n_elements(outdirs)

case 1 of 
   nurl eq nout:
   nout eq 1: outdirs=replicate(outdirs(0),nurl)
   else: begin 
stop,'??
      box_message,'Number OUTDIRS ne number GETURLS, returning...'
      return,''
   endcase
endcase

case 1 of 
   data_chk(pattern,/string): apat=' -A "'+pattern+'" '
   data_chk(accept,/string):  apat=' -A "'+accept +'" '
   else: apat=' '
endcase
wget='wget'
if keyword_set(site) then wget=concat_dir('$SSW/site/bin',wget)
waits=(['--wait=2 --random-wait ',''])(keyword_set(nowait))

wcmd="cd "+outdirs + "; wget -mirror -np -nH -erobots=off " + $
   waits + apat + geturls

new_paradigm=1-keyword_set(old_paradigm) ; /NEW_PARADIGM=default 12-nov-2007
if new_paradigm then begin 
;  SLF - added this different approach circa 20-oct-2007
;  I believe more Mirror like and less likely to behave wierdly
   break_url,geturls,ip,path
   path=str_replace(path,'//','/')
   ss=where_pattern(path,byte('/'),ndirs)
   cutdirs=' --cut-dirs='+strtrim(ndirs,2)+' '
   prefix=' -P ' + outdirs + ' '
   wcmd='wget -np -nH -N -r -erobots=off -P ' + outdirs + $
      ' ' +  waits + apat + cutdirs + prefix  + geturls
endif
cleanup=keyword_set(cleanup)
if keyword_set(spawn) then begin 
   cur=curdir()
   for i=0,nurl-1 do begin 
     cd,outdirs(i)
     espawn, wcmd(i)
     if cleanup then ssw_wget_cleanup,outdirs(i) ; remove residual wget crap
   endfor
   cd,cur
endif

return,wcmd
end
  
