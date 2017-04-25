;+
; PROJECT:
;	SDAC
; NAME:
;	WIN_SPAWN
;
; PURPOSE:
;	This procedure allows SPAWN to return output into IDL. 
;
; CATEGORY:
;	SYSTEM, WINDOWS
;
; CALLING SEQUENCE:
;	WIN_SPAWN, Command, Out
;
; INPUTS:
;       COMMAND - String set of DOS commands.
;
; OUTPUT: OUT - output of spawn command
;
; KEYWORDS INPUTS:
;	TEMP_FILE - file to overwrite with text output of command.
;	The default location is c:/windows/temp/spawn_outs.txt
;       DELETE = set to delete temporary file when done
;       NOSHELL = skip using command shell
;       BACKGROUND/NOWAIT = spawn in background
; KEYWORD OUTPUTS:
;	COUNT - number of lines in out
;       ERR - error string
;
; PROCEDURE:
;	This procedure spawns and saves the outs to a local file which
;	is subsequently read back to make the outs available in the same
;	way spawn can return outs under Unix and VMS.
;
; MODIFICATION HISTORY:
;	Version 1. richard.schwartz@gsfc.nasa.gov, 8-Jun-1998
;	Version 2. Kim Tolbert, 18-Aug-1998 - Use TMP env. variable
;       Version 3. Zarro (SM&A/GSFC), 12-Nov-1999 - added /DELETE and a 
;       CONCAT_DIR
;       Version 4. Zarro (SM&A/GSFC), 17-March-2000 - added some input
;       error checking as well as check if return out requested.
;       Also, added a random number to TEMP_FILE to avoid collisions
;       if more than one copy of program runs simultaneously, or TEMP_FILE
;       already exists
;       Version 5. Zarro (SM&A/GSFC), 23-March-2000
;       added spawning a batch file using START /min /b /high.
;       On some systems, these switches "may" inhibit the annoying shell window
;       20-May-00, Zarro (EIT/GSFC) - removed START
;       20-Jan-01, Zarro (EITI/GSFC) - added IDL 5.4 capability
;       29-Nov-06, Zarro (ADNET/GSFC) - added background capability 
;       28-Dec-14, Zarro (ADNET) 
;        - passed _EXTRA to SPAWN support passing keywords
;        - correctly return ERR as keyword (spawn returns error as third
;          optional argument)
;        - removed EXECUTE
;        - automatically delete temporary files
;        - added @ECHO OFF to inhibit outputting spawn command
;        - deprecated TEMP_FILE keyword
;-

pro win_spawn, command,out, count=count,_ref_extra=extra,$
         test=test,err=err

os=os_family(/lower)
count=0 & err=''
if os ne 'windows' or is_blank(command) then begin
 out=''
 return
endif

print_out=~arg_present(out)
out=''

;-- create batch file to spawn multiple commands

ncmd=n_elements(command)
if ncmd eq 1 then cmd=command else begin
 temp_file=get_temp_file('win_spawn.bat')
 file_append,temp_file,['@ECHO OFF',command],/new
 cmd=temp_file
endelse

spawn,cmd,out,err,count=count,/hide,_extra=extra

if keyword_set(test) then begin
 message,'testing...',/cont
 stop
endif

if n_elements(out) eq 1 then out=out[0]
if is_string(err) then err=arr2str(err)
if ncmd gt 1 then file_delete,temp_file,/quiet,/allow_nonex
if is_string(out) and print_out then print,out

return
end
