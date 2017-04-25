;+
; Project     : VSO
;
; Name        : SOCK_SERVICE
;
; Purpose     : Execute a socket service IDL command
;               (e.g. /prep_file?"test.fits"&verbose=1)
;               IDL command must return JSON output
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_service,command,lun
;
; Inputs      : COMMAND = command to call
;               LUN = open socket LUN
;
; Outputs     : None
;
; Keywords    : ERR = error string
;               HEAD = don't execute, HEAD request only.
;               MAX_THREADS = max number of background threads (def=5)
;               JSON = JSON string output
;
; History     : 21 March 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_service,command,lun,_extra=extra,head=head,json=json

json=''
get=~keyword_set(head)
jstruct={status:0b,err_message:''}
cr=string(13b)
r=heap_refcount(/enable)

error=0
catch, error
if (error ne 0) then begin
 err=err_state()
 jstruct.err_message=err
 json=json_serialize(jstruct)
 mprint,err
 catch,/cancel
 goto,bail
endif

common thread,obridge_sav,ocontainer
if ~is_number(max_threads) then max_threads=5

switch 1 of

;-- check that we have sufficient resources

 1: begin 
     if obj_valid(ocontainer) then begin
      if ocontainer->count() ge max_threads then begin
       err='Maximum number of background threads exceeded.'
       mprint,err
       jstruct.err_message=err
       json=json_serialize(jstruct)
       break
      endif
     endif
    end

;-- parse URL command for IDL procedure

 2: begin 
     proc=url_command(command,args,err=err)
     if is_string(err) || (proc ne 'prep_server') then begin
      err='Invalid IDL command.'
      jstruct.err_message=err
      json=json_serialize(jstruct)
      mprint,err
      break
     endif
    end

;-- execute IDL command

 3: begin
     if get then begin
      proc=proc+',json=json'
      if is_string(args) then proc=proc+','+args
      if is_struct(extra) then proc=proc+',_extra=extra'
      mprint,'Executing IDL command - '+proc
      success=execute(proc)
     endif
    end
 else: ok=1
endswitch

bail:
bsize=n_elements(byte(json))
hstatus='HTTP/1.1 200 OK'
printf,lun,hstatus+cr
printf,lun,systime(/utc)+' GMT'+cr
printf,lun,'Content-Type: application/json'+cr
printf,lun,'Content-Length: '+trim(bsize)+cr
printf,lun,'Connection: close'+cr
printf,lun,cr
if get && is_string(json) then printf,lun,json

return
end
