pro ssw_packages, prepend=prepend, remove=remove, append=append, $
        _extra=_extra, all=all
;+
;   Name: ssw_packages
;
;   Purpose: setup paths for SW packages within SSW framework
;
;   Keyword Parameters:
;      append  - if set, APPEND package path to SSW !path
;      prepend - if set, PREPEND package path to SSW !path
;      remove  - if set, REMOVE associated path from SSW !path
;      /PACKAGE - switch to select package (if not set, current packages showwn)
;      /all     - switch - include ALL packages
;
;   Calling Sequence:
;      ssw_packages, /PACKAGE
;
;   Calling Examples:
;      ssw_package                    - show available packages
;      ssw_package,/chianti           - add CHIANTI package
;      ssw_package,/chianti,/remove   - remove the package
;
;   Calls:
;      ssw_path, str2arr, wc_where, strjustify, prstr, pathfix,....
;
;   Restrictions:
;     Really a warning - NOT ALL PACKAGES ARE FULLY SSW COMPLIANT
;                        (might provide info on SSW blessing in future version)
;
;   History:
;      20-feb-1997 - S.L.Freeland - during Chianti/SSW integration
;      24-feb-1997 - S.L.Freeland - generalized for all $SSW_PACKAGES_ALL
;      12-mar-1997 - S.L.Freeland - add optional package setup routine call
;      23-Dec-1998 - S.L.Freeland - add /ALL switch and function
;	   23-nov-2002 - Richard.Schwartz@gsfc.nasa.gov use chklog to
;		fully translate in windows for ssw_packages_all
;-



allpacks = str2arr( chklog( 'SSW_PACKAGES_ALL',delim=' '),' ')
break_file,allpacks,ll,pp,packnames


if keyword_set(all) then begin
   for i=0,n_elements(packnames)-1 do begin
       estring='ssw_packages,prepend=prepend,append=append,' + $
                'remove=remove,/'+packnames(i)
       print,estring
       estat=execute(estring)
   endfor
   return                             ; early exit
endif


remove=keyword_set(remove)            ; default is ADD
prepend=1-keyword_set(append)         ; default is PREPEND

if not data_chk(_extra,/struct) then begin
   prstr,strjustify(['The following packages are available:' , $
          '   IDL> ssw_packages,/' + strupcase(packnames)],/box)
endif else begin
   pack=(tag_names(_extra))(0)
   whichpack=(wc_where(packnames,pack+'*',mcount,/case_ignore))(0)
   if mcount eq 0 then begin
        message,/info,"No SSW package matching: " + pack
        ssw_packages                                        ; recurse for help
   endif else begin
     	env='SSW_'+strupcase(packnames(whichpack))             ; ENVIRON name
      if remove then pathfix,get_logenv(env),/remove,/quiet else begin
            ssw_path,get_logenv(env), prepend=prepend
;           optional setup routines
            setr=strupcase(['ssw_set_chianti'])
            setrout=where(strpos(setr,pack) ne -1, srcnt)
            if srcnt ne 0 then call_procedure,setr(setrout(0))
         endelse
   endelse
endelse
return
end
