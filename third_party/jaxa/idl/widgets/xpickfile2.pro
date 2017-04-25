;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       xpickfile2
;
; PURPOSE:
;       Compound widget program for file selection
;
; CATEGORY:
;       Utility, widget
;
; EXPLANATION:
;
; SYNTAX:
;       xpickfile2, parent, child
;
; EXAMPLE:
;       xpickfile2, parent, child, filter = '*.gif *.fits'
;
; INPUTS:
;       PARENT - ID of the parent base widget on which the pickfile
;                widget is built
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       CHILD  - ID of the child widget (i.e, the application)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       GET_PATH- Set to a named variable. Returns the path at the
;                 time of selection.
;
;       PATH    - The initial path to select files from.  If this keyword is
;                 not set, the current directory is used.
;
;       FILTER  - A string value for filtering the files in the file
;                 list.  This keyword is used to reduce the number of
;                 files to choose from. The user can modify the
;                 filter. Example filter values might be "*.pro" or "*.dat".
;
;       FONT    - Name of font to be used in the widget
;
; COMMON:
;       xpickfile2
;
; RESTRICTIONS:
;       Does not recognize symbolic links to other files in UNIX.
;       Multiple filter patterns are not recognized in VMS system
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, November 1, 1995, Liyun Wang, NASA/GSFC
;          Modified from PICKFILE v 1.7 1994/05/02 19:25:51
;       Version 2, February 23, 1996, Liyun Wang, NASA/GSFC
;          Modified such that the side effect of current IDL working
;             directory being changed via the PATH widget is removed
;       Version 3, February 26, 1996, Liyun Wang, NASA/GSFC
;          Directory for personal data is default to the one pointed to
;             PERSONAL_DATA if this env variable is defined
;       Version 4, September 5, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug that returns files not necessarily in displayed
;             path when changing filter field
;       Version 5, September 9, 1997, Liyun Wang, NASA/GSFC
;          Allowed pathname to contain tilde in 1st character
;       Version 6, October 28, 1998, Zarro, NASA/GSFC
;          Stored last path/filter selection in memory
;	Version 7, 18-Apr-2000, William Thompson, GSFC
;		Made loop long integer
;	Version 8, 6-May-2004, Zarro (L-3Com/GSFC) - deprecated and renamed from XPICKFILE
;

FUNCTION cutoff_head, str, substr
;---------------------------------------------------------------------------
;  Strip off SUBSTR from STR
;---------------------------------------------------------------------------
   i = STRPOS(str, substr)
   IF i LT 0 THEN RETURN, str
   RETURN, STRMID(str, STRLEN(substr), 10000)
END 

FUNCTION xpf2_valid_dir, dir
   xhour

   CASE os_family(/lower) OF
      'vms': BEGIN
         CD, current=here       ; get pwd
         IF (STRPOS(dir, ']') GT -1) THEN dir = dir + "*.*"
         context = 0l
         resultant = STRING(BYTARR(256)+32b)
         result = CALL_EXTERNAL("librtl", "lib$find_file", dir, resultant, $
                                context, here, 0l, 0l, 0l, $
                                value=[0, 0, 0, 0, 1, 1, 1])
         toss = CALL_EXTERNAL("librtl", "lib$find_file_end", context)

         RETURN, (result EQ 65537)
      END
      'windows': BEGIN
         RETURN, 1              ; hook into common dialogs for windows
                                ; when this really works.
      END
      ELSE:  BEGIN
         IF ( os_family(/lower) NE 'ultrix') THEN $
            spawn, ['test -d '+dir +' -a -x '+dir+' ; echo $?'], result, /sh $
         ELSE $
            spawn, ['/bin/sh5 -c "test -d '+dir+' -a -x '+dir+' ";echo $?'], $
            result, /sh
         IF FIX(result(0)) EQ 0 THEN RETURN, 1 ELSE RETURN, 0
      END
   ENDCASE
END

FUNCTION xpf2_getdirs
;---------------------------------------------------------------------------
; This routine finds the files or directories at the current directory level.
; It must be called with either files or directories as a keyword.
;---------------------------------------------------------------------------
   xhour
   CASE ( os_family(/lower) ) OF
      'vms': BEGIN
         retval = ['[-]']
         results = FINDFILE("*.DIR") ;directories have an
         IF(KEYWORD_SET(results)) THEN BEGIN
            endpath = STRPOS(results(0), "]", 0) + 1
            results = STRMID(results, endpath, 100)
            dirs = WHERE(STRPOS(results, ".DIR", 0) NE -1, found)
            IF (found GT 0) THEN BEGIN
               results = results(dirs)
               retval = [retval, results]
            ENDIF
         ENDIF
      END
      'windows': BEGIN
         MESSAGE, "unsupported on this platform",/cont
         return,''
      END
      ELSE: BEGIN
         retval = ['../']
         SPAWN, "ls -laL", results , /sh
         numfound = N_ELEMENTS(results)
         IF(KEYWORD_SET(results)) THEN BEGIN
            firsts = STRUPCASE(STRMID(results, 0, 1))
            dirs = (WHERE(firsts EQ "D", found))
            IF (found GT 0) THEN BEGIN
               results = results(dirs)
               spaceinds = WHERE(BYTE(results(0)) EQ 32)
               spaceindex = spaceinds(N_ELEMENTS(spaceinds)-1)
               retval = [retval, STRMID(results, spaceindex + 1, 100)]
               retval = retval(WHERE((retval NE '.') AND (retval NE '..')))
            ENDIF
         ENDIF
      END
   ENDCASE
   RETURN, retval
END

FUNCTION xpf2_getfiles, filter

   xhour

   CASE ( os_family(/lower) ) OF
      'vms': BEGIN
         results = FINDFILE(filter)
         IF (KEYWORD_SET(results)) THEN BEGIN
            endpath = STRPOS(results(0), "]", 0) + 1
            results = STRMID(results, endpath, 100)
            dirs = WHERE(STRPOS(results, ".dir", 0) EQ -1, found)
            IF (found GT 0) THEN BEGIN
               results = results(dirs)
               RETURN, results
            ENDIF
         ENDIF
      END
      'windows': BEGIN
         MESSAGE, "unsupported on this platform",/cont
         return,''
      END
      ELSE: BEGIN
         SPAWN, ["/bin/sh", "-c", "ls -lal " + filter + $
                 " 2> /dev/null"], results, /noshell
         IF(KEYWORD_SET(results)) THEN BEGIN
            firsts = STRUPCASE(STRMID(results, 0, 1))
            fileinds = (WHERE(((firsts EQ "F") OR (firsts EQ "-") OR $
                               (firsts EQ "L")), found))
            IF (found GT 0) THEN BEGIN
               results = results(fileinds)
               FOR i=0L, N_ELEMENTS(results) - 1L DO BEGIN
                  spaceinds = WHERE(BYTE(results(i)) EQ 32)
                  spaceindex = spaceinds(N_ELEMENTS(spaceinds) - 1)
                  results(i) = STRMID(results(i), spaceindex + 1, 100)
               ENDFOR
               RETURN, results
            ENDIF
         ENDIF
      END
   ENDCASE
   RETURN, ''
END

PRO xpickfile2_event, event, outfile=outfile, status=status
;---------------------------------------------------------------------------
;  Event handler for widgets in this application. The keyword STATUS
;  is a named variable whose value determines the action to be taken
;  in the main event handler: If STATUS=0, the event is not generated
;  from this application; if STATUS=-1, the event is generated from
;  this application but has been processed (i.e., no further
;  processing is necessary); if STATUS=1, it means that a file has
;  been selected and the "Load" button is pressed, ready for loading
;  the selected file.
;---------------------------------------------------------------------------
   COMMON xpickfile2, info,last_filt,last_path

   WIDGET_CONTROL, info.wid.filttxt, get_value=filt
   WIDGET_CONTROL, info.wid.pathtxt, get_value=newpath
   newpath=newpath(0) & last_path=newpath
   filt = filt(0) & last_filt=filt
   status = -1
   outfile = ''


   CASE event.id OF
      info.wid.filttxt: BEGIN
         CD, current=old_dir
         old_dir = cutoff_head(old_dir, '/tmp_mnt')
         WIDGET_CONTROL, info.wid.pathtxt, get_value=here
         IF (xpf2_valid_dir(here(0))) THEN BEGIN
            CD, here(0)
            info.here = here(0)
         ENDIF
         files = xpf2_getfiles(filt)
         CD, old_dir
         WIDGET_CONTROL, info.wid.filelist, set_value=files, set_uvalue=files
      END

      info.wid.dirlist: BEGIN
         WIDGET_CONTROL, info.wid.dirlist, get_uvalue=directories
         WIDGET_CONTROL, info.wid.pathtxt, get_value=cur_path
         IF (event.index GT N_ELEMENTS(directories) - 1) THEN RETURN
         IF NOT chk_dir(cur_path(0), tmp, /fullname) THEN BEGIN
            xack, ['Invalid directory path:', cur_path(0)], $
               group=event.top, /modal
            WIDGET_CONTROL, info.wid.pathtxt, set_value=info.here
            RETURN
         ENDIF         
         CD, current=old_dir
         old_dir = cutoff_head(old_dir, '/tmp_mnt')         
         IF ( os_family(/lower) EQ 'vms') THEN BEGIN
            IF (event.index EQ 0) THEN found = 3 ELSE $
               found = STRPOS(directories(event.index), ".", 0)
            new_dir = STRMID(directories(event.index), 0, found)
            IF (event.index NE 0) THEN $
               new_dir = concat_dir(cur_path(0), new_dir, /dir)
            CD, new_dir
            CD, current=here
         ENDIF ELSE IF os_family(/lower) EQ 'windows' THEN BEGIN
            MESSAGE, "Unsupported on this platform.",/cont
            return
         ENDIF ELSE BEGIN
            cur_path = concat_dir(cur_path(0), directories(event.index), /dir)
            CD, cur_path
            CD, current=here
            here = cutoff_head(here, '/tmp_mnt')+info.separator
         ENDELSE
         WIDGET_CONTROL, info.wid.pathtxt, set_value=here
         info.here = here(0)
         directories = xpf2_getdirs()
         files = xpf2_getfiles(filt)
         CD, old_dir
         WIDGET_CONTROL, info.wid.filelist, set_value=files, set_uvalue=files
         WIDGET_CONTROL, info.wid.dirlist, set_value=directories, $
            set_uvalue=directories
         WIDGET_CONTROL, info.wid.selecttxt, set_value=''
         WIDGET_CONTROL, info.wid.accept, sensitive=0
      END

      info.wid.pathtxt: BEGIN
         WIDGET_CONTROL, info.wid.pathtxt, get_value=newpath
         IF NOT chk_dir(newpath(0), tmp, /fullname) THEN BEGIN 
            xack, ['Invalid directory path:', newpath(0)], $
               group=event.top, /modal
            WIDGET_CONTROL, info.wid.pathtxt, set_value=info.here
            RETURN
         ENDIF
         newpath = tmp
         len = STRLEN(newpath) - 1
         IF STRPOS(newpath, '/', len) NE -1 THEN $
            newpath = STRMID(newpath, 0, len)
         newpath = cutoff_head(newpath, '/tmp_mnt')  
         IF (xpf2_valid_dir(newpath(0))) THEN BEGIN
            here = newpath(0) + info.separator
            CD, current=old_dir
            old_dir = cutoff_head(old_dir, '/tmp_mnt')         
            CD, here
            directories = xpf2_getdirs()
            files = xpf2_getfiles(filt)
            CD, old_dir
            WIDGET_CONTROL, info.wid.filelist, set_value=files, $
               set_uvalue=files
            WIDGET_CONTROL, info.wid.dirlist, set_value=directories, $
               set_uvalue=directories
            info.here = here(0)
         ENDIF 
         WIDGET_CONTROL, info.wid.pathtxt, set_value=info.here
         WIDGET_CONTROL, info.wid.selecttxt, set_value=''
         WIDGET_CONTROL, info.wid.accept, sensitive=0
      END

      info.wid.filelist: BEGIN
         WIDGET_CONTROL, info.wid.filelist, get_uvalue=files
         IF (KEYWORD_SET(files)) THEN BEGIN
            info.thefile = files(event.index)
            WIDGET_CONTROL, info.wid.selecttxt, set_value=info.thefile
            WIDGET_CONTROL, info.wid.accept, sensitive=1
         ENDIF
      END

      info.wid.accept: BEGIN
         WIDGET_CONTROL, info.wid.selecttxt, get_value=temp
         ON_IOERROR, print_error
         fname = concat_dir(info.here, temp(0))
         OPENR, unit, fname, /GET_LUN
         FREE_LUN, unit
         info.thefile = temp(0)
         status = 1
         outfile = fname
         WIDGET_CONTROL, info.wid.pathtxt, set_text_select=0
         WIDGET_CONTROL, info.wid.filttxt, set_text_select=0
         IF NOT info.has_parent THEN xkill, event.top 
      END

      info.wid.cancel: BEGIN
         status = 0
         info.thefile = ''
         WIDGET_CONTROL, info.wid.pathtxt, set_text_select=0
         WIDGET_CONTROL, info.wid.filttxt, set_text_select=0
         IF NOT info.has_parent THEN xkill, event.top
      END

      info.wid.selecttxt: BEGIN
         WIDGET_CONTROL, info.wid.selecttxt, get_value=temp
         ON_IOERROR, print_error
         fname = concat_dir(info.here, temp(0))
         OPENR, unit, fname, /GET_LUN
         FREE_LUN, unit
         info.thefile = temp(0)
         info.outfile = fname
         WIDGET_CONTROL, info.wid.accept, sensitive=1
      END

      ELSE:
   ENDCASE
   info.outfile = outfile
   info.status = status
   RETURN

   print_error:
   info.outfile = ''
   if not exist(fname) then fname=''
   WIDGET_CONTROL, info.wid.selecttxt, set_value="Invalid file name: "+fname
   WIDGET_CONTROL, info.wid.accept, sensitive=0

END

FUNCTION xpickfile2, parent=parent, map=map, path=path, event_pro=event_pro, $
              filter=filter, get_path=get_path, font=font, status=status
   COMMON xpickfile2

   IF NOT KEYWORD_SET(map) THEN map = 0

   CASE STRLOWCASE( os_family(/lower) ) OF
      'vms':     separator = ''
      'windows': separator = ''
      'macos':   separator = ""
      ELSE:      separator = '/'
   ENDCASE

   CD, current=old_dir
   old_dir = cutoff_head(old_dir, '/tmp_mnt')         

   IF (N_ELEMENTS(path) EQ 0) THEN BEGIN
      path = getenv('PERSONAL_DATA')+separator
      IF path EQ separator THEN path = old_dir + separator
      here = path
   ENDIF ELSE BEGIN
      path = expand_tilde(path)
      IF (( os_family(/lower) EQ 'windows' ) AND  $
         (STRPOS(path, '\', STRLEN(path)-1) NE -1)) THEN  BEGIN
         IF(STRLEN(path) GT 3)THEN  $ ; root dirs are 3 chars long.
            path = STRMID( path, 0, STRLEN(path)-1)
      ENDIF

      IF(STRPOS(path, separator, STRLEN(path)- 1) EQ -1) AND $
         (path NE separator)THEN $
         path = path + separator
      CD, path                  ;if the user selected
      here = path               ;a path then use it
   ENDELSE
   if exist(last_path) then here=last_path

   IF (N_ELEMENTS(file) EQ 0) THEN file = ""

   IF (KEYWORD_SET(filter)) THEN filt = filter ELSE filt = ""
   if exist(last_filt) then filt=last_filt

   directories = xpf2_getdirs()
   files = xpf2_getfiles(filt)

   CD, old_dir
   old_dir = cutoff_head(old_dir, '/tmp_mnt')         
   version = WIDGET_INFO(/version)

   mk_dfont, lfont=lfont, bfont=bfont
   IF N_ELEMENTS(font) NE 0 THEN lfont = font

   IF N_ELEMENTS(parent) NE 0 THEN BEGIN
      IF WIDGET_INFO(parent, /valid) THEN BEGIN
         IF N_ELEMENTS(event_pro) EQ 0 THEN event_pro = 'xpickfile2_event'
         base = WIDGET_BASE(parent, /column, map=map, $
                            event_pro=event_pro)
         has_parent = 1
      ENDIF
   ENDIF
   IF N_ELEMENTS(base) EQ 0 THEN BEGIN
      map = 1
      base = WIDGET_BASE(title='xpickfile2', /column, map=map)
      has_parent = 0
   ENDIF
   wid = {base:base}

   widebase = WIDGET_BASE(base, /row, /fr)
   label = WIDGET_LABEL(widebase, value="PATH  ", font=lfont)
   pathtxt = WIDGET_TEXT(widebase, val=here, uvalue='pathtxt', $
                         /edit, xs=34, font=lfont)
   wid = add_tag(wid, pathtxt, 'pathtxt')

   filtbase = WIDGET_BASE(base, /row, /fr)
   filtlbl = WIDGET_LABEL(filtbase, value="FILTER",font=lfont)
   filttxt = WIDGET_TEXT(filtbase, val=filt, uvalue='filttxt', $
                         /edit, xs=34, font=lfont)
   wid = add_tag(wid, filttxt, 'filttxt')

   lbl = WIDGET_LABEL(base, value="SUBDIRECTORIES",font=lfont)
   dirlist = WIDGET_LIST(base, value=directories, ysize=5, $
                         uvalue=directories, font=lfont)
   wid = add_tag(wid, dirlist, 'dirlist')

   lbl = WIDGET_LABEL(base, value="FILES",font=lfont)
   filelist = WIDGET_LIST(base, value=files, ysize=6, uvalue=files, font=lfont)
   wid = add_tag(wid, filelist, ' filelist')

   widebase = WIDGET_BASE(base, /row, /frame)
   label = WIDGET_LABEL(widebase, value="SELECTION",font=lfont)
   selecttxt = WIDGET_TEXT(widebase, val=file, xs=31, $
                           /edit, font=lfont)
   wid = add_tag(wid, selecttxt, 'selecttxt')

   rowbase = WIDGET_BASE(base, /row, /frame)

   cancel = -1L
   wid = add_tag(wid, cancel, 'cancel')
   IF !version.release LT '3.6' THEN BEGIN
      accept = WIDGET_BUTTON(rowbase, value="Accept", font=bfont, $
                             uvalue='something')
      IF NOT has_parent THEN BEGIN
         cancel = WIDGET_BUTTON(rowbase, value='Cancel', font=bfont, $
                                uvalue='something')
      ENDIF
   ENDIF ELSE BEGIN
      accept = WIDGET_BUTTON(rowbase, value="Accept", font=bfont, $
                             uvalue='something', resource='AcceptButton')
      IF NOT has_parent THEN BEGIN
         cancel = WIDGET_BUTTON(rowbase, value='Cancel', font=bfont, $
                                uvalue='something', resource='QuitButton')
      ENDIF
   ENDELSE
   IF file EQ '' THEN WIDGET_CONTROL, accept, sensitive=0
   wid = add_tag(wid, accept, 'accept')
   wid.cancel = cancel

   if not has_parent then parent=0
   info = {status:0, outfile:'', has_parent:has_parent, here:here, $
           thefile:'', separator:separator, wid:wid,parent:parent}

   IF NOT has_parent THEN BEGIN
      WIDGET_CONTROL, base, /realize, map=1
      xmanager, 'xpickfile2', base, modal=1
      status = info.status
      RETURN, info.outfile
   ENDIF ELSE RETURN, base
END
