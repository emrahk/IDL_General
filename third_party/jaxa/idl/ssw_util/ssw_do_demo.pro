pro ssw_do_demo, demofile, index, data,  pause=pause, wait=wait, $
    demo_dir=demo_dir, command_array=command_array, no_execute=no_execute
;+
;   Name: ssw_do_demo
;
;   Purpose: run an idl demo program (format can be IDL main routine)
;
;   Input Parameters:
;      demofile - name of file to demo (execute) - if none, menu select from
;                 files in DEMO_DIR (keyword) or $SSW_DEMO_DIR (environmental) 
;
;   Keyword Parameters:
;      pause - if set, pause after IDL statement execution until user <CR>s
;      wait  - if set, number of seconds to wait between each line
;      demo_dir - optional directory containing *demo* files
;      command_array (output) - return just the IDL commands found in the demo file
;      no_execute=no_execute - do not actually execute the commands but do every thing else
;                              (in conjunction with COMMAND_ARRAY output
;
;   Calling Sequence:
;      ssw_do_demo [,demofile] [,demo_dir='demopath']  ; run a demo w/optionally demo select
;      ssw_do_demo,demofile,command_array=command_array [,/no_execute]
;
;   Non comment lines in demofile are displayed with highlights to terminal
;   and then executed - comment lines are echoed
;
;   History:
;      10-Jan-1995 (SLF)
;      23-oct-2007 (! time to retire) - use xmenu_sel
;       2-nov-2007 - allow "IDL>" in commands      
;      12-nov-2007 - return 'index,data' if they exist, add DEMO_DIR
;                    do_demo -> ssw_do_demo
;                    add COMMAND_ARRAY output and /NO_EXECUTE option; Greg Slater suggestions
;   Restrictions:
;      single line IDL commands for now
;-
if keyword_set(wait) then iwait=wait else iwait=0.
pause=keyword_set(pause)

if n_elements(demofile) eq 0 then begin
   demodir=get_logenv('SSW_DEMO_DIR')
   case 1 of
      data_chk(demo_dir,/string):  ; user supplied
      file_exist(demodir): demo_dir=demodir
      else: begin
         box_message,'Need to supply a demo file, DEMO_DIR or define $SSW_DEMO_DIR
         return
      endcase
   endcase
   demofiles=file_search(str2arr(demo_dir),'*demo*.pro')
   ndemos=n_elements(demofiles)
   case 1 of 
      demofiles(0) eq '': begin
         tbeep
         message,/info,"Can't find any demo files and none supplied, returning..."
         return
      endcase
      ndemos gt 1: begin
         tbeep
         purp=strarr(ndemos)
         for demoii=0,ndemos -1 do begin 
            pdat=rd_tfile(demofiles(demoii))
            ppos=strpos(strupcase(pdat),'PURPOSE:')
            pf=where(ppos ge 0,pcnt)
            if pcnt gt 0 then purp(demoii)=strtrim(strmid(pdat(pf(0)),ppos(pf(0))+strlen('PURPOSE:'),1000),2)
         endfor
         message,/info,"Select a demo file..."
         ss=xmenu_sel(demofiles + ' ' + purp,/one)
         if ss(0) eq -1 then message,"Nothing selected, Aborting..."
         demofile=demofiles(ss)
      endcase
      else: demofile=demofiles(0)
   endcase
endif

if not file_exist(demofile) then begin
   tbeep
   message,/info,"Demo file: " + demofile + " not found, returning..."
   return
endif

input=rd_tfile(demofile(0),/compress)
execit=1-keyword_set(no_execute) ; default executes the idl lines
line="--------------------------------------------------------"
prstr,["","Executing Demo File: " + demofile,line,""]
qtemp=!quiet
!quiet=1		; shut off compilation messages
resp=''
command_array=''        ; initialize the output vector containing all commmands (only)
for demoii=0,n_elements(input) -1 do begin
   case 1 of 
      input(demoii) eq 'end':
      strlen(input(demoii)) le 1: print
      strmid(input(demoii),0,1) eq ';': prstr,[strmid(input(demoii),1,1000)]
      else: begin
         cmd=strtrim(input(demoii),2)
         if strpos(cmd,'IDL>') eq 0 then cmd=strtrim(strmid(cmd,4,1000),2)
         if strmid(cmd,0,1) ne strupcase(strmid(cmd,0,1)) then begin 
         prstr,strjustify(["IDL> " + cmd],/box)
         wait,iwait
         command_array=[temporary(command_array),cmd]
         if execit then exestat=execute(cmd) else print,'(not executing on request)'
         lastcom=0
         if pause then begin
            print
            read,"Enter <CR> to continue, anything else to quit: ",resp
            if resp ne "" then message,"Aborting on request..."
         endif    
         endif ; else box_message,cmd,nbox=2
      endcase
   endcase
endfor

!quiet=qtemp
tbeep
prstr,["","End of Demo..."]
return 
end
