;+
; Project     : HESSI
;
; Name        : SOCK_MAP
;
; Purpose     : return nearest map for specified data type 
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_map,map,time,/type (e.g. sxi)
;                   
; Inputs      : TIME = nearest time to search for [def = current UT]
;
; Outputs     : MAP = map structure
;
; Keywords    : TYPE = /sxi, /eit
;             : FILTER = 'p_thn_b' , or '195' , etc
;               /p_thn_b
;               TIME = time to search
;
; Examples    : IDL> sock_map,map,/sxi,filter='p_med_b'
;               IDL> sock_map,map,/sxi,/p_med_b,time='1-may-03'
;
; History     : 12-Feb-2004  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_map,map,time,time=ktime,_extra=extra,filter=filter,err=err,verbose=verbose

map=''
err=''
verbose=keyword_set(verbose)

if (n_params() lt 1) or (not is_struct(extra)) then begin
 pr_syntax,'sock_map,map, /sxi [,filter= , time= ]'
 return
endif

;-- create object based on keyword input

class=strlowcase( (tag_names(extra)))
chk=where(stregex(class,'sxi',/bool,/fold),count)
if count eq 0 then begin
 message,'Sorry. I only recognize SXI at the moment.',/cont
 return
endif
class=class[chk[0]]
obs=call_function('obj_new',class)
if not obj_valid(obs) then return

;-- find URL to nearest file matching filter

if valid_time(ktime) then time=ktime
url=obs->nearest(time,_extra=extra,filter=filter,verbose=verbose,err=err)
if is_string(err) then return

;-- read file directly from server

if verbose then message,'Reading data...',/cont
sock_fits,url,data,index=index,err=err,verbose=verbose
if is_string(err) then return

;-- make a map and voila

if verbose then message,'Making map...',/cont
index2map,index,data,map

return

end

