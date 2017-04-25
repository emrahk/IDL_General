pro ssw_move,files, script=script, infile=infile, append=append, $
   local=local, online=online, loc2online=loc2online
;+
;   Name: ssw_move
;
;   Purpose: assist "mass" onlines (new) or moves (existing) routines->SSW
;
;   Input Paramters:
;      files -  list of files (assumed idl routines)
;
;   Keyword Parameters:
;      script - name of script file to use (def= 'ssw_move.csh')
;      infile - optionally ascii file containing files (in lieu of files)
;      append - if set, append to an existing script
;      local  - if set, copy 1st SSW version to local directory
;      online - if set, SSW directory to move things to 
;
;   Calling Sequence:
;      IDL> ssw_move, infile='files.dat', online='$SSW/gen/idl/util'
;      IDL> ssw_move, infile='files.dat', /local       ; copy from SSW->local
;
;   Method: use 'sswloc' to find current versions
;           use 'online' to move to target 
;           will not move online if multiple version exist which are not
;           identical (you need to resolve conflicts and use 'online')
;           (those files listed in 'ssw_move_nomove.dat')
;
;   Restrictions:
;      Dont use this without an appreciation of what it does or might do
;
;-

append=keyword_set(append)
local=keyword_set(local)

if keyword_set(infile) then files=rd_tfile(infile,nocom=';',/compress)

ifiles=str_replace(files,'.pro','')+'.pro'

if n_elements(script) eq 0 then script=1       
case data_chk(script,/type) of 
   0: message,'Need script for now...'
   7: sfile=script
   else: sfile=concat_dir(curdir(),'ssw_move.csh')   
endcase
nmfile=concat_dir(curdir(),'ssw_move_nomove.dat')

file_append,nmfile,['# sswmove run at: ' + systime(), $
                    '# Could not move the following...'], new=1-append

file_append,sfile, ['# sswmove run at: ' + systime()],new=1-append

local=keyword_set(local)

case data_chk(online,/type) of 
   0:
   7:    ondir=online
   else: ondir='/sswgen'
endcase
online=keyword_set(online)

for i=0,n_elements(ifiles)-1 do begin
   sswloc,'/'+ifiles(i),ofiles,count
   mvit=1
   case 1 of 
      count eq 0: message,/info,"No files found " + files(i)
      count eq 1: message,/info,"Only one copy online: " + ofiles(0)
      count eq 2 and not file_diff(ofiles(0),ofiles(1)): begin
         message,/info,"Only two identical copies online: " + ofiles(0)
      endcase
      else: begin
         mvit=0
      endcase                    
   endcase

   if mvit then begin 
      if local then file_append,sfile, 'cp -p ' + ofiles(0) + ' . '
      if online then file_append,sfile, 'ssw_online ' + files(i) + ' ' + ondir
   endif else begin
      file_append,nmfile,files(i) + '#occur: ' + strtrim(count,2)
   endelse

endfor

return
end


