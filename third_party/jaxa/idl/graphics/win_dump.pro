;---------------------------------------------------------------------------
; Document name: win_dump.pro
; Created by:    Liyun Wang, GSFC/ARC, April 17, 1996
;
; Last Modified: Fri Apr 19 17:35:58 1996 (lwang@achilles.nascom.nasa.gov)
; Modifications:
;	Now writes JPEG rather than GIF. 2 Apr 2002, T. Kucera
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       WIN_DUMP
;
; PURPOSE: 
;       Use xwd program to dump the contents of whole widget window
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       win_dump, parent, title [, /ps]
;
; INPUTS:
;       PARENT - ID of top level widget which will be dumped
;       TITLE  - Name of top-level widget window
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       FILE - Name of output GIF file; if FILE is missing, the
;              output will be send to a printer directly
;       PS   - Set this keyword to get PS output; if missing, GIF
;              format is assumed
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       Only works for UNIX systems that have the "xwd" program
;       Only works for top level widget windows
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, April 17, 1996, Liyun Wang, GSFC/ARC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

PRO win_dump, parent, title, file=file, error=error, ps=ps
   ON_ERROR, 2
   error = ''
   IF NOT WIDGET_INFO(parent, /valid) THEN BEGIN
      error = 'Invalid widget ID: '+STRTRIM(LONG(parent),2)
      MESSAGE, error, /cont
      RETURN
   ENDIF
   
   IF WIDGET_INFO(parent, /parent) NE 0 THEN BEGIN
      error = 'Widget '+STRTRIM(parent,2)+' is not a top-level widget!'
      MESSAGE, error, /cont
      RETURN
   ENDIF

   xwd = getenv('XWD') 
   IF xwd EQ '' THEN xwd = '/usr/bin/X11/xwd' 
   IF NOT file_exist(xwd) THEN BEGIN
      error = 'Command xwd => '+xwd+' not found. '
      MESSAGE, error, /cont
      xack, [error, '',$
             'Please check your system for its existence. If you find it,', $
             'set the env variable XWD pointing to it.'], group=parent,$
         instruct='Ok', title='Command not Found'
      RETURN
   ENDIF
   
;    xpr = getenv('XPR') 
;    IF xpr EQ '' THEN xpr = '/usr/bin/X11/xpr' 
;    IF NOT file_exist(xpr) THEN BEGIN
;       error = 'Command xpr => '+xpr+' not found. '
;       MESSAGE, error, /cont
;       xack, [error, '',$
;              'Please check your system for its existence. If you find it,', $
;              'set the env variable XPR pointing to it.'], group=parent,$
;          instruct='Ok', title='Command not Found'
;       RETURN
;    ENDIF
   
;    IF N_ELEMENTS(file) EQ 0 THEN BEGIN
;       sel_printer, printer, err=error, status=status, group=parent
;       IF status EQ 0 THEN RETURN
;    ENDIF
   
   IF N_ELEMENTS(file) EQ 0 THEN file = 'win_dump.gif'
   IF N_ELEMENTS(gray) EQ 0 THEN gray = 3
   IF N_ELEMENTS(height) EQ 0 THEN height = 7.5
   
   WIDGET_CONTROL, parent, /hourglass, tlb_get_offset=goff
      
   WIDGET_CONTROL, parent, tlb_set_xoff=0, tlb_set_yoff=0, /show
   
   out = 'win_dump.xwd'
   cmd = xwd+' -name "'+title+'" > '+out
   spawn, cmd
   warray = read_xwd(out, rr, gg, bb)
   spawn, 'rm -f '+out

   IF KEYWORD_SET(ps) THEN BEGIN 
      xps_setup, ps_stc, group=parent, status=status
      IF status THEN BEGIN
         ps, ps_stc.filename, color=ps_stc.color, copy=ps_stc.copy, $
            encapsulated=ps_stc.encapsulated, $
            interpolate=ps_stc.interpolate, portrait=ps_stc.portrait
         tv, warray
         tvlct, rr, gg, bb
         IF ps_stc.hard THEN BEGIN
            psplot, delete=ps_stc.delete, queue=ps_stc.printer
            popup_msg, 'Plot has been sent to printer '+$
               ps_stc.printer+'.', group=parent
         ENDIF ELSE BEGIN
            psclose
         ENDELSE
      ENDIF
   ENDIF ELSE BEGIN
      sav_dev = !d.name
      set_plot, 'z'
      top = !d.table_size-1
      sz = SIZE(warray)
      DEVICE, set_resolution=[sz(1), sz(2)]
      tv, warray
      tvlct, rr, gg, bb
      image = tvrd()
      rgb = BYTARR(3,SZ(1),SZ(2))
      rgb(0,*,*) = rr(image)
      rgb(1,*,*) = gg(image)
      rgb(2,*,*) = bb(image)
      write_jpeg, file, rgb,true=1,quality=100
      set_plot, sav_dev
   ENDELSE
   
   WIDGET_CONTROL, parent, tlb_set_xoff=goff(0), tlb_set_yoff=goff(1)
   xack, 'Window dump completed.', instruct='Ok', group=parent

RETURN

END

