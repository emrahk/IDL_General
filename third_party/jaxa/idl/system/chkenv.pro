;+
; Project     : VSO
;
; Name        : CHKENV

; Purpose     : Translate environment variable. Supports array inputs
;               and translating substrings 
;               (e.g. $SSW/gen/idl -> /solarsoft/gen/idl)
;
; Inputs      : VAR = String (scalar or array) to be translated
;
; Outputs     : OVAR = translated string
;
; Keywords    : DELIM = delimiter to use for separating substrings
;               PRESERVE = return input name if no translation found
;               LOCAL = set to force return output using OS-dependent delimiters
;               NORECURSE = do not recurse on substrings
;
; Category    : Utility, System
;
; Written     : 15-Jan-14, Zarro (ADNET)
;
; Contact     : dzarro@stanford.edu
;-

  function chkenv_s,var,norecurse=norecurse,delim=delim,$
                       preserve=preserve,local=local

   preserve=keyword_set(preserve)
   recurse=~keyword_set(norecurse)
   local=keyword_set(local)
   var=trim2(var)

;-- parse out user-delimiters

   tvar=getenv(var)
   if tvar eq '' then tvar=var
   if is_string(delim) then begin
    lvar=str2arr(tvar,delim=delim)
    if n_elements(lvar) gt 1 then begin
     result=chkenv(lvar,/norecurse,/preserve,local=local)
     ovar=arr2str(result,delim=delim)
     if (ovar eq var) and ~preserve then return,''
     return, local ? local_name(ovar,/no_expand) : ovar
    endif
   endif

;-- parse out OS-delimiters
   
   if recurse then begin
    pieces=strsplit(tvar,'(\\|/|\.)',/regex,/extract)
    np=n_elements(pieces)
    ovar=tvar
    for i=0,np-1 do begin
     opiece=chkenv(pieces[i],/preserve,/norecurse,local=local)
     ovar=strep2(ovar,pieces[i],opiece,_extra=extra,/nopad)
    endfor
    if (ovar eq var) and ~preserve then return,''
    return, local ? local_name(ovar,/no_expand) : ovar
   endif
 
   svar=var

;-- check for preceding $

   doll=strpos(svar,'$')
   if doll eq 0 then begin
    name=trim2(getenv(svar))
    if name eq '' then begin
     tvar=strmid(svar,1,strlen(svar))
     name=trim2(getenv(tvar))
    endif
   endif else begin
    name=trim2(getenv(svar))
   endelse
   
;-- finally expand tildes

   os=os_family(/lower)
   if os eq 'unix' then begin
    if name ne '' then temp=name else temp=svar
    tilde=strpos(temp,'~')
    if (tilde gt -1) then name=expand_tilde(temp)
   endif

   if n_elements(name) eq 1 then name=name[0]
   name=trim2(name)
   translated=name[0] ne ''
   if preserve and ~translated then name[0]=var

   return, local ? local_name(name,/no_expand) : name
   end
  
;--------------------------------------------------------------------------

   function chkenv,var,_ref_extra=extra

   if ~is_string(var) then return,''   
   np=n_elements(var)
   for i=0,np-1 do begin
    tvar=chkenv_s(var[i],_extra=extra)
    ovar=append_arr(ovar,tvar,/no_copy)
   endfor

   return,ovar
   end
