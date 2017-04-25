function ssw_getapplet, _extra=_extra, html=html
;
;+
;   Name:   ssw_getapplet
;
;   Purpose: return user requested java applet for insertion into HTML doc
;
;   Calling Sequence
;      applet=ssw_getapplet,/APPLETNAME      ; return specific applet
;      check=ssw_getapplet                   ; see whats available
;
;   Input Parameters:
;      NONE
;
;   Keyword Parameters:
;      /XXXXX - name of applet (ex: /GMTCLOCK)
;      /HTML  - if set, include extra HTML, if any (anything after the <HTML> )
;
;   Calling Examples:
;      gmtclock=ssw_getapplet(/gmtclock [,/html] )
;
;   History:
;      20-Jun-1997 - S.L.Freeland
;
;   Restrictions:
;      Assume SSW environment (applet data base)
;
;   Method:
;      ascii applet files and keyword inheritence for self updating action
;-
; ------------ determine online applets -----------------------
dlist=[get_logenv('SSW'),str2arr('gen,idl,http,applets')]
appdir='' & for i=0,n_elements(dlist)-1 do appdir=concat_dir(appdir,dlist(i))
applets=file_list(appdir,'*.dat',/cd)
;----------------------------------------------------------------

break_file,applets,ll,pp,ff,vv,ee
if data_chk(_extra,/struct) then begin
    fapplet=concat_dir(appdir,strlowcase( (tag_names(_extra))(0) ) +'.dat')
    if file_exist(fapplet) then begin
          retval =rd_tfile(fapplet(0))  
          nl=n_elements(retval)
          htinc=(where(strpos(retval,strupcase('<!** html')) ne -1,htcnt))(0)
          case 1 of 
             htcnt eq 0 or keyword_set(html):           ; return everything
             htcnt ne 0 and (1-keyword_set(html)): retval=retval(0:htinc-1)
             else:
          endcase
    endif else begin
       message,/info,"Applet < " + (tag_names(_extra))(0) + " > not available..."        
       retval=ssw_getapplet()          ; recurse (will show available applets)
    endelse
endif else begin
   mess=['The following applets/calls are avalable:', '',$
	 '    IDL> applet=ssw_getapplet(/'+ strupcase(ff)+')']
   prstr,strjustify(mess,/box)
   retval=''
endelse

return,retval
end
