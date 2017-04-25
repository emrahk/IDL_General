;+
; Project     : SOHO/CDS
;                   
; Name        : CHECK_FTP
;               
; Purpose     : check if ftp server is alive
;               
; Category    : utility
;               
; Explanation : uses 'ping' and 'ftp'
;               
; Syntax      : IDL> check_ftp,server,alive
;    
; Inputs      : SERVER = server name (e.g. smmdac.nascom.nasa.gov)
;               
; Outputs     : ALIVE = 0/1 if dead or alive
;
; Keywords    : QUIET = turn off messages
;               ERR = error string
;               PING = ping before ftp'ing
;
; History     : 6-Jan-1997, Zarro (SAC) - written
;               7-Jan-2015, Zarro (ADNET)
;               - modified espawn to catch error in keyword
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro check_ftp,server,alive,quiet=quiet,err=err,nodel=nodel,user=user,$
     pass=pass,noprompt=noprompt,ping=ping

alive=0 & err=''
if datatype(server) ne 'STR' then begin
 err='Invalid server input'
 pr_syntax,'check_ftp,server,alive'
 return
endif

loud=1-keyword_set(quiet)

;-- no point going on if server is down

if keyword_set(ping) then begin
 alive=is_alive(server,loud=0)
 if not alive then begin
  err='No response from '+server
  if loud then message,err,/cont
  return
 endif
endif else alive=1

;-- if user and pass entered then use them

user_and_pass=(datatype(user) eq 'STR') and (datatype(pass) eq 'STR')
if user_and_pass then user_and_pass=(trim(user) ne '') and (trim(pass) ne '')

have_net=0
if not user_and_pass then begin

 def_user='anonymous'
 def_pass=get_user_id()

;-- check if .netrc file is present

 ftp_net=concat_dir(getenv('HOME'),'.netrc')
 check=loc_file(ftp_net,count=count)
 have_net=count gt 0

;-- if server not in .netrc then use anonymous login

 if have_net then begin
  net=rd_ascii(ftp_net)
  chk=grep('machine'+strlowcase(server),strlowcase(strcompress(net,/rem)),index=index)
  have_net=(index gt -1) 
 endif

 if not have_net then begin
  user=def_user
  pass=def_pass
  user_and_pass=1
 endif
endif

ftp_com='ftp'
ftp_input=mk_temp_file('check_ftp.inp')

noprompt=keyword_set(noprompt)
openw,unit,ftp_input,/get_lun 
if not have_net then ftp_com=ftp_com+' -n'
if user_and_pass then begin
 if noprompt then begin
  printf,unit,user
  printf,unit,pass
 endif else begin
  printf,unit,'user '+user
  printf,unit,'pass '+pass
 endelse
endif
printf,unit,'quit'
free_lun,unit 

;-- spawn ftp command and look for likely errors

cmd=ftp_com+' < '+ftp_input
dprint,' cmd: ',cmd
espawn,cmd,out,err=err
dprint,'out:',out
out=strlowcase(out)
  
if err ne '' then begin
 if loud then message,err,/cont
 alive=0
endif else begin
 if loud then message,'FTP server is alive',/cont
 alive=1
endelse

if not keyword_set(nodel) then rm_file,ftp_input
return & end
