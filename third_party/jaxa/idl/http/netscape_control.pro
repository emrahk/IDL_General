
pro netscape_control, item, remote, which_netscape=which_netscape, $
		      install=install, noinstall=noinstall, $
		      iconic=iconic, id=id, display=display, $
		      nosplash=nosplash, splash=splash, $
		      raise=raise, noraise=noraise, geometry=geometry, $
		      nospawn=nospawn, remote_command=remote_command,  $
                      command_output=command_output,                   $
                      nobackground=nobackground, $
                      openurl=openurl, openfile=openfile, $
                      new_window=new_window, exit=exit,   $
                      netscape_command=netscape_command, $
		      loud=loud, debug=debug
;+
;   Name: netscape_control
;
;   Purpose: control Netscape client process(es) from within SSW/IDL
;
;   Input Parameters:
;      item    - optional url or file name for action (ex: to open)
;      remote -  optional remote control command (synonym for keyword: REMOTE_COMMAND)
;      SEE: http://home.netscape.com/newsref/std/x-remote.html
;
;   Keyword Parameters:
;      which_netscape          - Full Netscape path (default assume in $path)
;      install                 - privatecolor map
;      noinstall               - shared color map
;      iconic                  - start iconified
;      id                      window id
;      display                 X Client(s) Default=current OR last specified
;                              [may be an array]
;      splash                  include license info (default=NOSPLASH)
;      raise                   raise Netscape window
;      noraise                 do not raise Netscape window
;      geometry                Position / size of window
;                              String "WxH+X+Y" -OR- 4 element array [W,H,X,Y]
;      remote_command          explicit remote command (synonym for positional)
;      openURL                 if set, open URL  (via ITEM)
;      openFile                open File (via ITEM)
;      new_window              open in url or file in a New Netscape window
;      exit                    if set, sends remote 'exit' command
;      nospawn                 Do not spawn the command
;      nobackground            Do not background command
;      netscape_command (OUTPUT) - implied/spawned command
;      command_output   (OUTPUT) - output from spawned command(s)
;
;   Calling Sequence:
;      IDL> netscape_control [,URL] [,display=IP] [,/install] [,/iconic], $
;                            [,/openURL] [,/nobackground] [/noraise] ...
;
;   Calling Example:
;    1. Initial Call - open a Netscape Client on the designated display
;                      Optionally supply an initial URL
;    IDL> netscape_control,'http://www.lmsal.com/SXT/html/First_Light.html',$
;                           display='sxt1.lmsal.com', /install
;
;    2. Open a new URL in an existing Netscape Client (opened in preceding)
;    IDL> netscape_control, /openURL, $
;            'http://vestige.lmsal.com/TRACE/last_movies/'
;
;    3. Same - this time kick of a JavaScript movie in existing Client
;    IDL> netscape_control, /openURL, $
;            'http://www.lmsal.com/SXT/movies/sxt_goes_last72hours_j.html'
;
;         a) display defaults to previous call
;         b) uses 'remote' control capabilities of Netscape; 'openURL' in this
;            example.
;
;   Restrictions:
;      X Client must permit X requests from the Server (IDL caller)
;
;   History:
;      25-April-2000  S.L.Freeland - "leverage" browser technologies
;                                    simplify SSWIDL<->Netscape interface
;                     Initially for automated QKL/NRT display of solar data
;      26-April-2000  S.L.Freeland - fix 'id' typo
;
;       3-May-2000    S.L.Freeland - add /NEW_WINDOW keyword and function
;                                    add /EXIT, implement GEOMETRY
;                                    use D.M.Zarro 'espawn'
;      15-Oct-2001    Kim Tolbert - if Windows, just start the file that was passed in
;                                   as item.  None of the keywords has any effect.  The
;                                   file should be an html, otherwise opens in whatever
;                                   application the file is associated with.
;-
common netscape_control_blk, last_display, last_id

if os_family() eq 'Windows' then begin
	spawn, 'start ' + item
	return
endif

debug=keyword_set(debug)
loud=debug or keyword_set(loud)

if not data_chk(which_netscape,/string) then which_netscape='netscape'

; ------------- display windows IDs and X Server options
xid=''
if data_chk(id,/string) then xid='-id '+id            ; Window ID supplied?
xdisplay=''
if data_chk(display,/string) then begin              ; X Client(s) supplied?
   xdisplay='-display ' + display
   xdisplay=$
     xdisplay+(['',':0'])(strpos(xdisplay,':0') ne strlen(xdisplay)-2)
   last_display=xdisplay
endif else if data_chk(last_display,/string) then xdisplay=last_display
; -----------------------------------------------------------------------

; ----------  binary keyword command options ---------------------------
xinstall=(['','-install'])(keyword_set(install))         ; private colors?
xicon=(['','-iconic'])(keyword_set(iconic))              ; iconify on start?
xraise=(['','-noraise'])(keyword_set(noraise))           ; dont raise?
xsplash=(['-no-about-splash',''])(keyword_set(splash))   ; include lic info?
xback=([' &',''])(keyword_set(nobackground))             ; dont background?
; -----------------------------------------------------------------------

netscape_command=strcompress(arr2str( $
  [which_netscape,xid,xinstall,xicon,xraise,xsplash],' ')) + $  ; command
                                      ' ' + xdisplay            ; ->display(s)
case 1 of
   data_chk(geometry,/string): geom='-geometry ' + $
	     str_replace(str_replace(geometry,'geometry',''),'-','')
   n_elements(geometry) eq 4: begin
      gs=strtrim(geometry,2)
      geom='-geometry ' + arr2str(gs(0:1),'x') +'+' + arr2str(gs(2:3),'+')
   endcase
   else: geom=''
endcase

; -------- look for/assemble remote commands or URL input --------------
if not keyword_set(item) then item=''                   ; force string oper.
nw=(['',',new-window'])(keyword_set(new_window))        ; new window?
if data_chk(remote_command,/string) and $
    n_elements(remote) eq 0 then remote=remote_command  ; via Keyword?

; remote command "shortcuts"
if keyword_set(exit) then remote='exit'

; look for and format any REMOTE commands
case 1 of
   data_chk(remote,/string): $
	 remcmd="-remote " + str_replace(remote,'-remote','') ; user remote cmd
   keyword_set(openurl) and data_chk(item,/string): $         ; remcmd=openURL?
	remcmd="-remote 'openURL(" + item(0) + nw + ")'"
   keyword_set(openfile) and data_chk(item,/string): $        ; remcmd=openFile?
	remcmd="-remote 'openFile(" + item(0) + nw + ")'"
   data_chk(item,/string): remcmd=item                        ; URL passed?
   else: remcmd=''
endcase

netscape_command=netscape_command + ' ' + $      ; command strings
	 geom + ' ' + remcmd + ' ' + xback       ; geometry/remote/background
; ----------------------------------------------------------------------

; -------- spawn command(s) if not told otherwise -------------------
if not keyword_set(nospawn) then begin
   if loud then box_message,['Executing commands:',netscape_command]
   espawn,netscape_command, command_output
endif else if loud then box_message,['Commands','   ' + netscape_command]
; ----------------------------------------------------------------------

if debug then stop
return
end
