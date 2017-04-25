;---------------------------------------------------------------------------
; Document name: xget_synoptic.pro
; Created by:    Liyun Wang, GSFC/ARC, September 19, 1994
;
; Last Modified: Wed Jan 15 14:09:48 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       XGET_SYNOPTIC()
;
; PURPOSE:
;       Return a string array of SOHO synoptic or summary image file names
;
; EXPLANATION:
;       XGET_SYNOPTIC searches for filenames of the SOHO synoptic images from
;       variety of sources or SOHO summary images. The search path is
;       determined by environmental variable SYNOP_DATA or
;       SUMMARY_DATA. If neither of the env variables is defined,
;       user's home directory will be used as the search path. All
;       synoptic and summary data files have to be named inthe format
;       of '*yymmdd.*', where the wild card character * can be 1 or
;       more characters.
;
; CALLING SEQUENCE:
;       Results = XGET_SYNOPTIC([start] [,stop] [source=source] [group=group])
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       Results -- String containing filename selected from the directory
;                  specified by the SYNOP_DATA env. variable (or user's home
;                  directory if SYNOP_DATA is not set), based on the source of
;                  file indicated by the SOURCE keyword. A null string will be
;                  returned if no appropriate file is selected. Please
;                  note that if the keyword ININITIALIZE is set,
;                  RESULTS will be a structure named SYNOP_SRC that
;                  has the following tags:
;
;          NAME    - Name of image sources (if TYPE is not set) or name
;                    of image types (if TYPE is set).
;          DIRNAME - Directory names under SYNOP_DATA in which image
;                    files reside
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       INITIALIZE -- If set, does nothing but initialize the common block
;       START --  Date string in YYYY/MM/DD format, beginning date
;                 from which the image data base is searched. Default:
;                 1990/01/01
;       STOP  --  Date string in  YYYY/MM/DDformat, end date for which the
;                 image data base is searched. If absent, current (system)
;                 date is assumed.
;       SOURCE_IDX --  Index number of image source to be searched.
;                      For synoptic data, the current image sources are:
;
;                0 -- Yohkoh Soft-X Telescope
;                1 -- Big Bear Solar Observatory
;                2 -- Kitt Peak National Observatory
;                3 -- Learmonth Observatory, Australia
;                4 -- Mt. Wilson Observatory
;                5 -- Space Environment Lab
;                6 -- Holloman AFB
;                7 -- Mees Solar Observatory
;                8 -- Sacramento Peak Observatory
;                9 -- Nobeyama Solar Radio Observatory
;               10 -- Other Institutes
;
;       GROUP   -- ID of the widget that functions as a group leader
;       SUMMARY -- Set this keyword for SOHO summary data. If not set,
;                  SOHO synoptic data will be assumed.
;       MODAL   -- Set this keyword to make this program a blocking
;                  widget program
;
; CALLS:
;       GET_UTC, NUM2STR, DELVARX, STRIP_DIRNAME, CONCAT_DIR, XTEXT
;
; COMMON BLOCKS:
;       FOR_SYNOP_UPDATE (used internally by built-in routines)
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Science planning
;
; PREVIOUS HISTORY:
;       Written September 19, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Liyun Wang, GSFC/ARC, October 5, 1994
;          Modified so that the file extension name does not have to be
;          ".fits"
;       Version 2, Liyun Wang, GSFC/ARC, October 12, 1994
;          Added keyword TYPE to allow choosing images based on image type
;       Version 3, Liyun Wang, GSFC/ARC, November 21, 1994
;          Made the list selected if it is the only one
;       Version 4, Liyun Wang, GSFC/ARC, December 29, 1994
;          Removed the .tags tag, and renamed the .value tag to .dirname in
;             the SOURCES structure;
;       Version 5, Liyun Wang, GSFC/ARC, February 1, 1995
;          Made it work for files with the SOHO filename convention
;       Version 6, Liyun Wang, GSFC/ARC, February 13, 1995
;          Made it work under VMS (requires the "new" version of
;             CONCAT_DIR that can concatinate two directories under VMS).
;       Version 7, Liyun Wang, GSFC/ARC, March 30, 1995
;          Added the Help button
;       Version 8, Liyun Wang, GSFC/ARC, April 19, 1995
;          Added Mauna Loa Solar Obs of HAO site
;       Version 9, Liyun Wang, GSFC/ARC, May 9, 1995
;          Got rid of common blocks in main routine and event handler
;          Remembers the last image source and selected items
;          Returns a structure (with tag names NAME and DIRNAME) when
;             the keyword INITIALIZE is set
;       Version 10, Liyun Wang, GSFC/ARC, May 25, 1995
;          Replaced image source names with the cw_bselector widget
;       Version 11, July 21, 1995, Liyun Wang, GSFC/ARC
;          Replaced call to FINDFILE with LOC_FILE to avoid limitation
;             of number of files being read in
;       Version 12, February 15, 1996, Liyun Wang, GSFC/ARC
;          Changed keyword TYPE to SUMMARY
;          Xresource option disabled for IDL 3.5 and earlier
;       Version 13, March 27, 1996, Liyun Wang, GSFC/ARC
;          Added interface to SOHO private data directory
;       Version 14, April 22, 1996, Liyun Wang, GSFC/ARC
;          Improved file name list (truly list files according to time)
;       Version 15, June 17, 1996, Liyun Wang, GSFC/ARC
;          Used FIND_FILE to fix built-in FINDFILE() problem
;       Version 16, July 1, 1996, Liyun Wang, GSFC/ARC
;          Speeded up the file searching process by adding more specific
;             filter pattern
;       Version 17, August 9, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug occuring when switching between summary and
;             private database
;       Version 18, November 27, 1996, Liyun Wang, NASA/GSFC
;          Sorted listed entries by date as well as by time
;       Version 19, December 6, 1996, Liyun Wang, NASA/GSFC
;          Made it more tolerent to date strings. Whatever ANYTIM2UTC
;             accepts will be fine now
;       Version 20, January 15, 1997, Liyun Wang, NASA/GSFC
;          Modified to use ITOOL_GETFILE (which is also used by GET_SYNOPTIC)
;
; VERSION:
;       Version 20, January 15, 1997
;-

PRO synop_update, info, sel_id, initial=initial
;---------------------------------------------------------------------------
;  A routine to update file listing for a given site
;---------------------------------------------------------------------------
   COMMON for_synop_update, start_date, end_date, s_name, s_files, $
      select_id, last_summary

   IF N_ELEMENTS(sel_id) NE 0 THEN select_id = sel_id
   IF N_ELEMENTS(last_summary) EQ 0 THEN last_summary = -1

   WIDGET_CONTROL, /hourglass
   source = info.sources.dirname(info.src_index)
   IF N_ELEMENTS(s_name) EQ 0 THEN s_name = ''
   IF N_ELEMENTS(start_date) EQ 0 THEN BEGIN
      start_date = ''
      end_date = ''
   ENDIF

   WIDGET_CONTROL, info.selected, set_value=''

   redo = (source NE s_name) OR (start_date NE date_code(info.start_cur)) OR $
      (end_date NE date_code(info.stop_cur)) OR (info.summary NE last_summary)

   IF redo THEN BEGIN
;---------------------------------------------------------------------------
;     Deal with a new site
;---------------------------------------------------------------------------
      s_name = source
      delvarx, select_id
      IF source EQ 'any' THEN path = info.env_path ELSE BEGIN
         IF !version.os EQ 'vms' THEN $
            path = concat_dir(info.env_path, source, /dir) $
         ELSE $
            path = concat_dir(info.env_path, source)
      ENDELSE

      names = itool_getfile(info.start_cur, info.stop_cur, path, $
                            count=count, dlog=dlog, start_date=start_date, $
                            end_date=end_date)
      IF count EQ 0 THEN delvarx, names

      IF N_ELEMENTS(names) NE 0 THEN s_files = names ELSE delvarx, s_files

      IF N_ELEMENTS(s_files) NE 0 THEN BEGIN
         info = rep_tag_value(info, dlog(0), 'DLOG')
         info.path = path(0)
      ENDIF
      last_summary = info.summary
   ENDIF

   n_files = N_ELEMENTS(s_files)
   IF n_files EQ 0 THEN BEGIN
      WIDGET_CONTROL, info.f_list, $
         set_value=['No files found for this peroid!', $
                    '(Check to see the SOHO archive disk', $
                    'is still mounted on your machine!)']
      WIDGET_CONTROL, info.f_list, sensitive=0
   ENDIF ELSE BEGIN
      WIDGET_CONTROL, info.f_list, sensitive=1
      IF redo OR KEYWORD_SET(initial) THEN BEGIN
         WIDGET_CONTROL, info.f_list, set_value=strip_dirname(s_files)
         info = rep_tag_value(info, s_files, 'NAMES')
         IF n_files EQ 1 THEN select_id = 0
         IF exist(select_id) THEN $
            WIDGET_CONTROL, info.f_list, set_list_select=select_id
      ENDIF
   ENDELSE
   IF exist(select_id) THEN BEGIN
      WIDGET_CONTROL, info.selected, set_value=$
         strip_dirname(s_files(select_id))
   ENDIF
   WIDGET_CONTROL, info.accept, sensitive=N_ELEMENTS(select_id) NE 0

END

PRO info_update, event, unseen, info
;---------------------------------------------------------------------------
;  Procedure to stuff info back to the base widget
;---------------------------------------------------------------------------
   IF WIDGET_INFO(event.top, /valid) THEN BEGIN
      WIDGET_CONTROL, unseen, set_uvalue=info, /no_copy
      WIDGET_CONTROL, event.top, set_uvalue=unseen
   ENDIF
   RETURN
END

PRO XGET_SYNOPTIC_EVENT, event
;---------------------------------------------------------------------------
;  Event handler
;---------------------------------------------------------------------------

   ON_ERROR, 2
   WIDGET_CONTROL, event.top, get_uvalue=unseen
   IF NOT WIDGET_INFO(unseen, /valid) THEN BEGIN
      PRINT, 'Invalid unseen widget ID!'
      RETURN
   ENDIF
   WIDGET_CONTROL, unseen, get_uvalue=info, /no_copy
   WIDGET_CONTROL, event.id, get_uvalue=uvalue

   look = WHERE(uvalue EQ info.sources.dirname, count)
   IF count NE 0 THEN BEGIN
;---------------------------------------------------------------------------
;     User chooses a new image site or type
;---------------------------------------------------------------------------
      info.src_index = look(0)
      synop_update, info
   ENDIF

   CASE (uvalue) OF
      'QUIT': BEGIN
         info.file_name = ''
         info.update = 0
         info_update, event, unseen, info
         xkill, event.top
         RETURN
      END
      'DONE': BEGIN
         WIDGET_CONTROL, info.selected, get_value=name_str
         name = STRTRIM(name_str(0), 2)
         IF name EQ '' THEN BEGIN
            flash_msg, info.selected, 'Invalid filename!!', num=2
            WAIT, 1.0
            WIDGET_CONTROL, info.selected, set_value=''
         ENDIF ELSE BEGIN
            info.update = 1
            info.file_name = concat_dir(info.path, name)
            info_update, event, unseen, info
            xkill, event.top
            RETURN
         ENDELSE
      END
      'DATA_PATH': BEGIN
         WIDGET_CONTROL, info.env_lb, get_value=new_path
         info.env_path = STRTRIM(new_path(0), 2)
         synop_update, info
      END
      'DATA_TYPE': BEGIN
         CASE (event.index) OF
            0: BEGIN
               info.env_path = STRTRIM(GETENV('SYNOP_DATA'), 2)
               temp = get_source_stc()
               info = rep_tag_value(info, temp, 'SOURCES')
            END
            1: BEGIN
               info.env_path = STRTRIM(GETENV('SUMMARY_DATA'), 2)
               temp = get_source_stc(/summary)
               info = rep_tag_value(info, temp, 'SOURCES')
            END
            2: BEGIN
               info.env_path = STRTRIM(GETENV('PRIVATE_DATA'), 2)
               temp = get_source_stc(/summary)
               info = rep_tag_value(info, temp, 'SOURCES')
            END
            ELSE:
         ENDCASE
         info.summary = event.index

         xkill, info.img_src
         i_num = N_ELEMENTS(info.sources.name)
         IF info.src_index GT i_num-1 THEN info.src_index = i_num-1
         info.img_src = cw_bselector(info.source_bs, info.sources.name, $
                                     return_uvalue=info.sources.dirname, $
                                     set_value=info.src_index, $
                                     label_left='Image Source:')
         WIDGET_CONTROL, info.env_lb, set_value=info.env_path
         synop_update, info
      END
      'LIST': BEGIN
         info.idx = event.index
         sel = strip_dirname(STRTRIM(info.names(info.idx), 2))
         WIDGET_CONTROL, info.selected, set_value=sel
         WIDGET_CONTROL, info.accept, sensitive=1
         synop_update, info, info.idx
      END
      'KSTART': BEGIN
         WIDGET_CONTROL, info.start_id, get_value=start_str
         err = ''
         start_str = anytim2utc(start_str(0), err=err, /ecs, /date)
         IF err EQ '' THEN BEGIN
            info.start_cur = start_str
            IF info.start_cur GT info.stop_cur THEN err = 'Invalid start date!'
         ENDIF
         IF err NE '' THEN BEGIN
            flash_msg, info.selected, err, num=2
            WAIT, 1.0
            WIDGET_CONTROL, info.selected, set_value=''
            info_update, event, unseen, info
            RETURN
         ENDIF
         synop_update, info
      END
      'KSTOP': BEGIN
         WIDGET_CONTROL, info.stop_id, get_value=stop_str
         err = ''
         stop_str = anytim2utc(stop_str(0), err=err, /ecs, /date)
         IF err EQ '' THEN BEGIN
            info.stop_cur = stop_str(0)
            IF info.stop_cur LT info.start_cur THEN err = 'Invalid stop date!'
         ENDIF
         IF err NE '' THEN BEGIN
            flash_msg, info.selected, err, num=2
            WAIT, 1.0
            WIDGET_CONTROL, info.selected, set_value=''
            info_update, event, unseen, info
            RETURN
         ENDIF
         synop_update, info
      END
      'HELP': BEGIN
         xtext, ['Images can be chosen from various institutes through the pull-down', $
                 'menu button for "Image Source". ', ' ', $
                 'You can edit the start and stop dates of the period through which the', $
                 'images are filtered, just follow the YYYYY/MM/DD format. A carriage', $
                 'return is required for the editing to take effect.'], $
            title='XGET_SYNOPTIC HELP', group=event.top, /modal, space=1
      END
      ELSE:
   ENDCASE

   info_update, event, unseen, info

END

FUNCTION XGET_SYNOPTIC, start=start, stop=stop, source_idx=source_idx, $
                        group=group, modal=modal, initialize=initialize, $
                        summary=summary
;----------------------------------------------------------------------
;  Main routine
;----------------------------------------------------------------------
   COMMON for_xgetsynoptic, src_index

   ON_ERROR, 2
   update = 0
   idx = 0
   IF N_ELEMENTS(summary) EQ 0 THEN summary = 0

;----------------------------------------------------------------------
;  Make SOURCES structure. It has two tags: NAME is the string that gets
;  displayed; DIRNAME serves two purposes, one is the actual directory name
;  where synoptic files locate, the other is the lable for the pull-down
;  menu.
;----------------------------------------------------------------------
   sources = get_source_stc(summary=summary)
   i_num = N_ELEMENTS(sources.name)
   IF KEYWORD_SET(initialize) THEN RETURN, sources

   IF N_ELEMENTS(source_idx) NE 0 THEN src_index = source_idx
   IF N_ELEMENTS(src_index) EQ 0 THEN src_index = 0

   IF src_index LT 0 OR src_index GT i_num THEN BEGIN
      PRINT, 'XGET_SYNOPTIC -- Invalid Image source.'
      src_index = 0
   ENDIF
   sources.dir_index = src_index
   CASE (summary) OF
      0: env_path = STRTRIM(GETENV('SYNOP_DATA'), 2)
      1: env_path = STRTRIM(GETENV('SUMMARY_DATA'), 2)
      2: env_path = STRTRIM(GETENV('PRIVATE_DATA'), 2)
      ELSE:
   ENDCASE

   IF env_path EQ '' THEN BEGIN
      env_path = GETENV('HOME')
      bell
      PRINT, 'XGET_SYNOPTIC -- Warning: Environment variable SYNOP_DATA'+$
         ' not set.'
      PRINT, 'Your home directory is used.'
   ENDIF

   IF !version.os EQ 'vms' THEN $
      path = concat_dir(env_path, sources.dirname(src_index), /dir) $
   ELSE $
      path = concat_dir(env_path, sources.dirname(src_index))
   path = path(0)

   IF N_ELEMENTS(stop) NE 0 THEN BEGIN
      IF valid_time(stop, err) THEN $
         stop_cur = anytim2utc(stop, /ecs, /date) $
      ELSE MESSAGE, 'Invalid STOP date/time string!', /cont
   ENDIF
   IF N_ELEMENTS(stop_cur) EQ 0 THEN BEGIN
      get_utc, tt, /ecs
      stop_cur = anytim2utc(tt, /ecs, /date)
   ENDIF

   IF N_ELEMENTS(start) NE 0 THEN BEGIN
      IF valid_time(start, err) THEN $
         start_cur = anytim2utc(start, /ecs, /date) $
      ELSE $
         start_cur = '1990/01/01'
   ENDIF
   IF N_ELEMENTS(start_cur) EQ 0 THEN BEGIN
;----------------------------------------------------------------------
;     Set image enquiry start time 14 days before the given study
;     start time
;----------------------------------------------------------------------
      tt = anytim2utc(stop_cur)
      tt.mjd = tt.mjd-14
      start_cur = anytim2utc(tt, /ecs, /date)
   ENDIF

   bfont = "-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1"
   bfont = (get_dfont(bfont))(0)

   ffont = (get_dfont('-*-courier-*-r-normal-*-18-*-*-*-*-*-*-*'))(0)
   IF ffont EQ '' THEN ffont = '9x15bold'

   base = WIDGET_BASE(title='XGET_SYNOPTIC', /column)

   data_path = WIDGET_BASE(base, /row, /frame)
   temp = cw_bselector(data_path, $
                       ['SYNOP_DATA', 'SUMMARY_DATA', 'PRIVATE_DATA'], $
                       /return_index, uvalue='DATA_TYPE', ids=ids)
   IF GETENV('SUMMARY_DATA') EQ '' THEN WIDGET_CONTROL, ids(1), sensitive=0
   IF GETENV('PRIVATE_DATA') EQ '' THEN WIDGET_CONTROL, ids(2), sensitive=0

   WIDGET_CONTROL, temp, set_value=summary
   CASE (summary) OF
      0: BEGIN
         env_lb = WIDGET_TEXT(data_path, font='fixed', uvalue='DATA_PATH', $
                              value=GETENV('SYNOP_DATA'), /edit, xsize=38)
      END
      1: BEGIN
         env_lb = WIDGET_TEXT(data_path, font='fixed', uvalue='DATA_PATH', $
                              value=GETENV('SUMMARY_DATA'), /edit, xsize=38)
      END
      2: BEGIN
         env_lb = WIDGET_TEXT(data_path, font='fixed', uvalue='DATA_PATH', $
                              value=GETENV('PRIVATE_DATA'), /edit, xsize=38)
      END
      ELSE:
   ENDCASE

   source_bs = WIDGET_BASE(base, /row, space=3, /frame)

   bb_list = '"'+sources.name+'" '+sources.dirname

;---------------------------------------------------------------------------
;   The above operation is equivalent to the following loop:
;   FOR i = 0, N_ELEMENTS(sources.name)-1 DO BEGIN
;      bb_list(i) = sources(i).name+sources(i).dirname
;   ENDFOR
;---------------------------------------------------------------------------

   img_src = cw_bselector(source_bs, sources.name, $
                          return_uvalue=sources.dirname, $
                          set_value=src_index, label_left='Image Source:')

   base1 = WIDGET_BASE(base, /column, /frame)

   start_id = cw_field(base1, title='Start Date', value=start_cur, /row, $
                       xsize=10, /RETURN, /frame, uvalue='KSTART', $
                       font=ffont)
   stop_id = cw_field(base1, title='Stop Date ', value=stop_cur, /row, $
                      xsize=10, /RETURN, /frame, uvalue='KSTOP', $
                      font=ffont)
   
   list_bs = WIDGET_BASE(base, /column, space=1)
   f_title = WIDGET_LABEL(list_bs, value='Files Found:')
   f_list = WIDGET_LIST(base, value=STRARR(20), ysize=10, $
                        uvalue='LIST', font='9x15bold')
   sel_bs = WIDGET_BASE(base, /row, /frame)
   label = WIDGET_LABEL(sel_bs, value='Selection:')
   selected = WIDGET_TEXT(sel_bs, value='', xsize=35, font='fixed')

   cmd_bs = WIDGET_BASE(base, /row, space=20, /frame, xpad=20)
   IF !version.release LT '3.6' THEN BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', font=bfont)
      quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', font=bfont)
   ENDIF ELSE BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', $
                             font=bfont, resource_name='AcceptButton')
      quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', $
                           font=bfont, resource_name='QuitButton')
   ENDELSE
   help_bt = WIDGET_BUTTON(cmd_bs, value='Help', uvalue='HELP', $
                           font=bfont)

   WIDGET_CONTROL, accept, sensitive=0

   offsets = get_cent_off(base, valid=valid)

   IF valid THEN $
      WIDGET_CONTROL, base, /realize, /map, tlb_set_xoff=offsets(0), $
      tlb_set_yoff=offsets(1), /show $
   ELSE $
      WIDGET_CONTROL, base, /realize, /map, /show
   
   info = {start_id:start_id, stop_id:stop_id, env_lb:env_lb, $
           selected:selected, f_list:f_list, env_path:env_path, $
           accept:accept, sources:sources, src_index:src_index, $
           path:path, idx:idx, update:update, start_cur:start_cur, $
           stop_cur:stop_cur, file_name:'', names:'', dlog:'', $
           img_src:img_src, source_bs:source_bs, summary:summary}

;---------------------------------------------------------------------------
;  The INITIAL keyword is needed so that the next time when this routine is
;  called, the previous listings are still available
;---------------------------------------------------------------------------
   synop_update, info, /initial

   unseen = WIDGET_BASE()
   WIDGET_CONTROL, unseen, set_uvalue=info, /no_copy
   WIDGET_CONTROL, base, set_uvalue=unseen
   XMANAGER, 'xget_synoptic', base, group=group, modal=KEYWORD_SET(modal)
   WIDGET_CONTROL, unseen, get_uvalue=info, /no_copy, /destroy, $
      /clear_events, bad_id=junk
   IF NOT KEYWORD_SET(group) THEN XMANAGER

   summary = info.summary
   src_index = info.src_index
   IF info.update THEN BEGIN
      RETURN, info.file_name
   ENDIF ELSE RETURN, ''

END

;---------------------------------------------------------------------------
; End of 'xget_synoptic.pro'.
;---------------------------------------------------------------------------
