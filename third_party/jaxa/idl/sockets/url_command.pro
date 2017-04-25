;+
; Project     : VSO
;
; Name        : URL_COMMAND
;
; Purpose     : Parse URL for command and arguments
;
; Category    : system utility sockets
;
; Syntax      : IDL> proc=url_command(command,arguments)
;
; Inputs      : COMMAND = URL command (e.g: /prep_file?"test.dat"&verbose=1)
;
; Outputs     : ARGUMENTS = command arguments
;               PROC = progam name
;
; Keywords    : ERR = error string
;
; History     : 21 March 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function url_command,command,arguments,err=err

err=''
arguments=''
if is_blank(command) then return,''

chk=stregex(command,'(\\|\/)?([^\&\?]+)(\?)?(.*)',/ext,/sub)
cmd=file_basename(chk[2])
if ~have_proc(cmd) then begin
 err='Invalid IDL command.'
 return,''
endif

if is_string(chk[4]) then arguments=str_replace(chk[4],'&',',')
return,cmd
end
