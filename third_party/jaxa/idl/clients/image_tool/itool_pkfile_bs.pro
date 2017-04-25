;---------------------------------------------------------------------------
; Document name: itool_pkfile_bs.pro
; Created by:    Liyun Wang, GSFC/ARC, November 1, 1995
;
; Last Modified: Thu May 29 14:44:44 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_PKFILE_BS
;
; PURPOSE:
;       To create pickfile widget upon a given parent base in IMAGE_TOOL
;
; CATEGORY:
;       Utility, widget, image_tool
;
; EXPLANATION:
;
; SYNTAX:
;       itool_pkfile_bs, parent, child
;
; EXAMPLE:
;       itool_pkfile_bs, parent, child, filter = '*.gif *.fits'
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
;       ITOOL_PKFILE
;
; RESTRICTIONS:
;       Does not recognize symbolic links to other files in UNIX.
;       Multiple filter patterns are not recognized in VMS system
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, November 1, 1995, Liyun Wang, GSFC/ARC
;          Modified from PICKFILE v 1.7 1994/05/02 19:25:51
;       Version 2, February 23, 1996, Liyun Wang, GSFC/ARC
;          Modified such that the side effect of current IDL working
;             directory being changed via the PATH widget is removed
;       Version 3, February 26, 1996, Liyun Wang, GSFC/ARC
;          Directory for personal data is default to the one pointed to
;             PERSONAL_DATA if this env variable is defined
;       Version 4, September 5, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug that returns files not necessarily in displayed
;             path when changing filter field
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-

FUNCTION it_valid_dir, dir
 return,is_dir(dir)

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
        message,'Windows not yet supported',/verb
        RETURN, 1              ; hook into common dialogs for windows
                                ; when this really works.
      END
      ELSE:  BEGIN
         IF (os_family(/lower) NE 'ultrix') THEN $
            spawn, ['test -d '+dir +' -a -x '+dir+' ; echo $?'], result, /sh $
         ELSE $
            spawn, ['/bin/sh5 -c "test -d '+dir+' -a -x '+dir+' ";echo $?'], $
            result, /sh
         IF FIX(result(0)) EQ 0 THEN RETURN, 1 ELSE RETURN, 0
;         RETURN, (NOT FIX(result(0)))
      END
   ENDCASE
END

FUNCTION it_getdirs
;---------------------------------------------------------------------------
; This routine finds the files or directories at the current directory level.
; It must be called with either files or directories as a keyword.
;---------------------------------------------------------------------------

   xhour
   CASE os_family(/lower) OF
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

FUNCTION it_getfiles, filter

   filter=filter(0)
   xhour
   
   CASE os_family(/lower) OF
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
               FOR i=0, N_ELEMENTS(results) - 1 DO BEGIN
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

PRO itool_pkfile_event, event, out_file=out_file, status=status
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

   COMMON itool_pkfile_bs, pathtxt, filttxt, dirlist, filelist, selecttxt, $
      ok_button, here, thefile, separator,last_filt

   status = 0

   WIDGET_CONTROL, filttxt, get_value=filt
   filt = filt(0)  & last_filt=filt

   help,last_filt
   CASE event.id OF

      filttxt: BEGIN
         status = -1
         CD, current=old_dir
         WIDGET_CONTROL, pathtxt, get_value=here
         here=chklog(here,/pre)
         IF (it_valid_dir(here(0))) THEN CD, here(0)
         files = it_getfiles(filt)
         CD, old_dir
         WIDGET_CONTROL, filelist, set_value=files, set_uvalue=files
      END

      dirlist: BEGIN
         status = -1
         WIDGET_CONTROL, dirlist, get_uvalue=directories
         WIDGET_CONTROL, pathtxt, get_value=cur_path
         cur_path=chklog(cur_path,/pre)
         dprint, 'cur_path: ', cur_path
         IF (event.index GT N_ELEMENTS(directories) - 1) THEN RETURN
;         IF (NOT it_valid_dir(cur_path)) THEN RETURN
         CD, current=old_dir
         IF (!version.os EQ 'vms') THEN BEGIN
            IF (event.index EQ 0) THEN found = 3 ELSE $
               found = STRPOS(directories(event.index), ".", 0)
            new_dir = STRMID(directories(event.index), 0, found)
            IF (event.index NE 0) THEN $
               new_dir = concat_dir(cur_path(0), new_dir, /dir)
            dprint, 'new_dir: ', new_dir
            CD, new_dir
            CD, current=here
         ENDIF ELSE IF os_family(/lower) EQ 'windows' THEN BEGIN
            MESSAGE, "Unsupported on this platform.",/cont
         ENDIF ELSE BEGIN
            cur_path = concat_dir(cur_path(0), directories(event.index), /dir)
            CD, cur_path
            CD, current=here
            here = here + separator
         ENDELSE
         WIDGET_CONTROL, pathtxt, set_value=here
         here=chklog(here,/pre)
         directories = it_getdirs()
         files = it_getfiles(filt)
         CD, old_dir
         WIDGET_CONTROL, filelist, set_value=files, set_uvalue=files
         WIDGET_CONTROL, dirlist, set_value=directories, set_uvalue=directories
         WIDGET_CONTROL, selecttxt, set_value=''
         WIDGET_CONTROL, ok_button, sensitive=0
      END

      pathtxt: BEGIN
         status = -1
         WIDGET_CONTROL, pathtxt, get_value=newpath
         newpath=chklog(newpath,/pre)

         newpath = newpath(0)
         len = STRLEN(newpath) - 1
         IF STRPOS(newpath, '/', len) NE -1 THEN $
            newpath = STRMID(newpath, 0, len)
         IF (it_valid_dir(newpath(0))) THEN BEGIN
            here = newpath(0) + separator
            CD, current=old_dir
            CD, here
            directories = it_getdirs()
            files = it_getfiles(filt)
            CD, old_dir
            WIDGET_CONTROL, filelist, set_value=files, set_uvalue=files
            WIDGET_CONTROL, dirlist, set_value=directories, $
               set_uvalue=directories
         ENDIF ELSE $
            WIDGET_CONTROL, pathtxt, set_value=chklog(here,/pre)
         WIDGET_CONTROL, selecttxt, set_value=''
         WIDGET_CONTROL, ok_button, sensitive=0
      END

      filelist: BEGIN
         status = -1
         WIDGET_CONTROL, filelist, get_uvalue=files
         IF (KEYWORD_SET(files)) THEN BEGIN
            thefile = concat_dir(here, files(event.index))
            WIDGET_CONTROL, selecttxt, set_value=thefile
            WIDGET_CONTROL, ok_button, sensitive=1
         ENDIF
      END

      ok_button: BEGIN
         WIDGET_CONTROL, selecttxt, get_value=temp
         ON_IOERROR, print_error
         OPENR, unit, temp(0), /GET_LUN
         FREE_LUN, unit
         thefile = temp(0)
         out_file = thefile
         status = 1
      END

      selecttxt: BEGIN
         status = -1
         WIDGET_CONTROL, selecttxt, get_value=temp
         ON_IOERROR, print_error
         OPENR, unit, temp(0), /GET_LUN
         FREE_LUN, unit
         thefile = temp(0)
         out_file = thefile
         WIDGET_CONTROL, ok_button, sensitive=1
      END

      ELSE:
   ENDCASE
   RETURN

   print_error:
   if exist(temp) then fname=temp(0) else fname=''
   WIDGET_CONTROL, selecttxt, set_value="Invalid file name: "+fname
   thefile = ""
   WIDGET_CONTROL, ok_button, sensitive=0

END

PRO itool_pkfile_bs, parent, child, path=path, filter=filter, $
                     get_path=get_path, font=font

   COMMON itool_pkfile_bs

   thefile = ''
   IF N_ELEMENTS(font) EQ 0 THEN BEGIN
      font='-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1'
      font = (get_dfont(font))(0)
   ENDIF
   bfont = '-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1'
   bfont=(get_dfont(bfont))(0)

   CASE os_family(/lower) OF
      'vms':     separator = ''
      'windows': separator = ''
      'macos':   separator = ""
      ELSE:      separator = '/'
   ENDCASE

   CD, current=old_dir

   IF (N_ELEMENTS(path) EQ 0) THEN BEGIN
      path = getenv('PERSONAL_DATA')+ separator
      IF path EQ separator THEN path = old_dir + separator
      here = path
   ENDIF ELSE BEGIN

      IF((os_family(/lower) EQ 'windows')AND  $
         (STRPOS(path, '\', STRLEN(path)-1)NE -1))THEN  BEGIN
         IF(STRLEN(path) GT 3)THEN  $ ; root dirs are 3 chars long.
            path = STRMID( path, 0, STRLEN(path)-1)
      ENDIF

      IF(STRPOS(path, separator, STRLEN(path)- 1) EQ -1) AND $
         (path NE separator)THEN $
         path = path + separator
      CD, path                  ;if the user selected
      here = path               ;a path then use it
   ENDELSE

   IF (N_ELEMENTS(file) EQ 0) THEN file = ""

   IF (KEYWORD_SET(filter)) THEN filt = filter ELSE filt = ""
   if exist(last_filt) then filt=last_filt

   directories = it_getdirs()
   files = it_getfiles(filt)

   CD, old_dir
   version = WIDGET_INFO(/version)

   child = WIDGET_BASE(parent, /column, map=0)

   widebase = WIDGET_BASE(child, /row, /fr)
   label = WIDGET_LABEL(widebase, value="PATH  ", font=font)
   pathtxt = WIDGET_TEXT(widebase, val=here, /edit, xs=34,font=font)

   filtbase = WIDGET_BASE(child, /row, /fr)
   filtlbl = WIDGET_LABEL(filtbase, value="FILTER",font=font)
   filttxt = WIDGET_TEXT(filtbase, val=filt, /edit, xs=34, font=font)

   lbl = WIDGET_LABEL(child, value="SUBDIRECTORIES",font=font)
   dirlist = WIDGET_LIST(child, value=directories, ysize=5, $
                         uvalue=directories,font=font)

   lbl = WIDGET_LABEL(child, value="FILES",font=font)
   filelist = WIDGET_LIST(child, value=files, ysize=6, uvalue=files, $
                          font=font)

   widebase = WIDGET_BASE(child, /row, /frame)
   label = WIDGET_LABEL(widebase, value="SELECTION",font=font)
   selecttxt = WIDGET_TEXT(widebase, val=file, xs=31, $
                           /edit,font=font)

   rowbase = WIDGET_BASE(child, /column, /fr, xpad=50)
   ok_button = WIDGET_BUTTON(rowbase, value="Load File", font=bfont)
   IF file EQ '' THEN WIDGET_CONTROL, ok_button, sensitive=0
END

;---------------------------------------------------------------------------
; End of 'itool_pkfile_bs.pro'.
;---------------------------------------------------------------------------
