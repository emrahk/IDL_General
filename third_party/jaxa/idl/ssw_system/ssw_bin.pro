function ssw_bin, routine, find=find, no_packages=no_packages, $
   found=found, warning=warning, loud=loud, paths=plist, ssw_only=ssw_only
;+
;   Name: ssw_bin
;
;   Purpose: return system-dependent BIN directory OR executable name w/path
;
;   Input Parameters:
;      routine - if supplied, return executable name (with path)
;
;   Keyword Parameters:
;      found (output) - boolean (TRUE if found, FALSE if not found)
;      warning - if set and routine NOT found, print a warning message
;
;   Calling Sequence:
;      bindir=ssw_bin()                            ; default SSW bin for system
;      exenam=ssw_bin('name', found=found)         ; form&find executable
;
;   Calling Examples (as run on an Alpha-OSF):
;      IDL> mpeg=ssw_bin('mpeg_encode', found=found)  ; find executable
;      IDL> print,strrep_logenv(mpeg,'SSW')           ; show answer  
;           $SSW/bin/OSF_alpha/mpeg_encode            ; <- the SSW standard
;      
;      IDL> print,ssw_bin('whirlgif')            ; also checks other areas
;           $HOME/bin/whirlgif                   ; found a local version
;
;   History:
;      5-Mar-1997 - S.L.Freeland - written
;     15-apr-1997 - S.L.Freeland - look add SSW_XXX/bin and SSW_XXX/exe
;     30-apr-1997 - S.L.Freeland - check $SSW/packages/XXX/bin and exe
;     18-aug-1997 - S.L.Freeland - include $SSW_BIN (scripts, mirror, etc)
;      9-sep-1998 - S.L.Freeland - include user $path, add /SSW_ONLY
;     24-apr-1999 - S.L.Freeland - protect agains NULL instrument...
;     14-Feb-2007 - D. Zarro (ADNET)     
;                 - added $SSW/gen/bin to SSW standard
;                 - added /NO_PACKAGES to accelerate search
;                 - reverse search order so that SSW standard directories
;                   are searched first
;-
warning=keyword_set(warning) or keyword_set(loud)

osdir=!version.OS + '_' + !version.ARCH
ssw_stand=[get_logenv('SSW_BIN'),concat_dir(concat_dir('$SSW','bin'),osdir),concat_dir(concat_dir('$SSW','gen/bin'),osdir)]        ; SSW system standard

if n_params() eq 0 then retval = ssw_stand else begin

;  Allow some user & system standard 'binary' places in addition to SSW "standard"
   case os_family() of
      'unix': begin
          if keyword_set(ssw_only) then bpaths='' else begin 
	     upaths=str2arr(get_logenv('PATH'),':')
	     bpaths=['/bin','/usr/bin','/usr/local/bin','/usr/sbin','$HOME/bin']
             bpaths=[upaths,bpaths]
	     bpaths=bpaths(uniqo(bpaths))
           endelse
	endcase
	  else:   bpaths=''
   endcase
   plist=[bpaths, ssw_stand]
   ilist=str2arr(strupcase(get_logenv('SSW_INSTR')),' ')
;  handle packages

   if (1-keyword_set(no_packages)) then begin
    packlist=str2arr(get_logenv('SSW_PACKAGES_ALL'),' ')
    break_file,packlist,ll,pp,ff
    ilist=strtrim([ilist,strupcase(ff)],2)
   endif

   ss=where(ilist ne '',sscnt)
   if sscnt gt 0 then ilist=ilist(ss)
   if ilist(0) ne '' then begin
      allroots=get_logenv('SSW_'+ilist)
      ipaths=[concat_dir(allroots,'exe'),concat_dir(allroots,'bin')]
      ipaths=concat_dir(ipaths,osdir)
      plist=[ipaths,plist]
   endif

   plist=reverse(plist)                                    ; reverse order
   retval=concat_dir(plist,routine)                        ; form names
   chk=where(file_exist(retval),fcnt)                      ; look for them


   if fcnt gt 0 then retval=retval(chk(0)) else $          ; at least 1 found 
      retval=retval(0)                                     ; return name
endelse

found=(file_exist(retval))(0)                              ; set found flag
; pring warning message on request
if not found and warning then $
   message,/info,"Warning - Could not find: " + strrep_logenv(retval,'SSW')  

return,retval
end
