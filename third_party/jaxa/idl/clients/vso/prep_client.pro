;+
; Project     : VSO
;
; Name        : PREP_CLIENT
;
; Purpose     : Client to send file to PREP_SERVER
;
; Category    : utility sockets analysis
;
; Inputs      : FILE = file to prep (can be URL)
;
; Outputs     : OFILE = URL of  prepped file
;
; Keywords    : EXTRA = prep keywords to pass to prep routine
;               ERR = error string
;               SESSION = unique session ID number
;               JSON = JSON string with URL of prepped file
;
; History     : 29-March-2016, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro prep_client,file,ofile,json=json,_extra=extra,err=err,verbose=verbose

verbose=keyword_set(verbose)
err='' & json='' & ofile=''
sock_def_server,server,port
prep_server=server+':'+trim(port)

if is_blank(file) then begin
 err='Input file not entered.'
 mprint,err
 pr_syntax,'prep_client,file,json'
 return
endif
 
if ~have_network(prep_server,interval=1) then begin
 err='PREP_SERVER not running.'
 mprint,err
 return
endif

;-- if not URL then have to upload it to PREP_SERVER

if is_url(file) then location=file else begin
 sock_put,file,prep_server,err=err,head=head
 sock_content,head,location=location,code=code
 if (code ne 201) || is_string(err) || is_blank(location) then begin
  mprint,'Failed to upload file. Check PREP_SERVER configuration.'
  return
 endif
 mprint,'File uploaded successfully.'
endelse

location=str_replace(location,'http://','')
prep_cmd=prep_server+'/prep_server?"'+location+'"'
query=stc_query(extra)
if is_string(query) then prep_cmd=prep_cmd+'&'+query

if verbose then begin
 mprint,'Executing -'
 print,prep_cmd
endif

sock_list,prep_cmd,json,err=err

if verbose || is_blank(err) || is_string(json) then begin
 result=json_parse(json,/tostruct)
 if have_tag(result,'output') then begin
  mprint,'Prepped file available at - ' 
  ofile=result.output
  print,ofile
 endif
endif
 
return
end
