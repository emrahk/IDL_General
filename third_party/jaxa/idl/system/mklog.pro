;+
; Project     : SOHO - CDS
;
; Name        : MKLOG
;
; Purpose     : define a logical (VMS) or environment (UNIX) variable
;
; Category    : Utility, OS
;
; Explanation : checks OS to determine which SET function to use
;
; Syntax      : IDL> mklog,name,value or mklog,'name=value'
;
; Inputs      : NAME  = string name of variable to define logical
;             : VALUE = string name of logical 
;
; Keywords    : VERBOSE = print result
;               LOCAL = convert input value to local name
;
; Side effects: logical will become undefined if name=''
;
; History     : Written, 1-Sep-1992,  D.M. Zarro. 
;               Modified, 25-May-99, Zarro (SM&A/GSC) 
;                - add better OS check
;               Modified, 27-Nov-2007, Zarro (ADNET) 
;                - added check for $ prefix
;               Modified, 8-Jan-2008, Zarro (ADNEY)
;                - added /local
;               Modified, 29-Jan-2008, Zarro (ADNET)
;                - added option to parse name=value
;               Modified, 29-Oct-2013, Zarro (ADNET)
;                - Moved LOCAL keyword to _EXTRA
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro mklog,name,value,verbose=verbose,_extra=extra

if is_blank(name) then return

pair=str2arr(name, delim='=')
if n_elements(pair) eq 2 then begin
 tname=strtrim(pair[0],2)
 tvalue=strtrim(pair[1],2)
endif else begin
 if ~exist(value) then return
 tname=name
 tvalue=value
endelse

sz=size(tvalue)
np=n_elements(sz)
svalue=tvalue
if sz[np-2] eq 7 then svalue=chklog(tvalue,/pre,_extra=extra)

if sz[np-2] eq 1 then svalue=fix(tvalue)

os=strupcase(os_family())

case os of
 'VMS'   : begin
            if strtrim(svalue,2) eq '' then begin
             ok=chklog(tname)
             if ok ne '' then call_procedure,'dellog',tname
            endif  else call_procedure,'setlog',tname,svalue
           end
 else    : begin
            sname=strtrim(tname,2)
            doll=strpos(sname,'$') eq 0
            svalue=strtrim(string(svalue),2)
            setenv,sname+'='+svalue
            if doll then begin
             sname=strmid(sname,1,strlen(sname))
             setenv,sname+'='+svalue
            endif else setenv,'$'+sname+'='+svalue
           end
endcase
verbose=keyword_set(verbose)
if verbose then print,'% MKLOG: '+name+' = '+chklog(tname,_extra=extra)

return & end
