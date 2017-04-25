;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_PICKFILE()
;
; PURPOSE:
;       Return a string array of SOHO synoptic or summary image file names
;
; EXPLANATION:
;       ITOOL_PICKFILE searches for filenames of the SOHO synoptic images from
;       variety of sources or SOHO summary images. The search path is
;       determined by environmental variable SYNOP_DATA or
;       SUMMARY_DATA. If neither of the env variables is defined,
;       user's home directory will be used as the search path. All
;       synoptic and summary data files have to be named inthe format
;       of '*yymmdd.*', where the wild card character * can be 1 or
;       more characters.
;
; CALLING SEQUENCE:
;       Results = ITOOL_PICKFILE([start] [,stop] [source=source] [group=group])
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
;                  note that if the keyword INITIALIZE is set,
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
;       FOR_ITOOL_PK_UPDATE (used internally by built-in routines)
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
;       Written September 19, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Liyun Wang, NASA/GSFC, October 5, 1994
;          Modified so that the file extension name does not have to be
;          ".fits"
;       Version 2, Liyun Wang, NASA/GSFC, October 12, 1994
;          Added keyword TYPE to allow choosing images based on image type
;       Version 3, Liyun Wang, NASA/GSFC, November 21, 1994
;          Made the list selected if it is the only one
;       Version 4, Liyun Wang, NASA/GSFC, December 29, 1994
;          Removed the .tags tag, and renamed the .value tag to .dirname in
;             the SOURCES structure;
;       Version 5, Liyun Wang, NASA/GSFC, February 1, 1995
;          Made it work for files with the SOHO filename convention
;       Version 6, Liyun Wang, NASA/GSFC, February 13, 1995
;          Made it work under VMS (requires the "new" version of
;             CONCAT_DIR that can concatinate two directories under VMS).
;       Version 7, Liyun Wang, NASA/GSFC, March 30, 1995
;          Added the Help button
;       Version 8, Liyun Wang, NASA/GSFC, April 19, 1995
;          Added Mauna Loa Solar Obs of HAO site
;       Version 9, Liyun Wang, NASA/GSFC, May 9, 1995
;          Got rid of common blocks in main routine and event handler
;          Remembers the last image source and selected items
;          Returns a structure (with tag names NAME and DIRNAME) when
;             the keyword INITIALIZE is set
;       Version 10, Liyun Wang, NASA/GSFC, May 25, 1995
;          Replaced image source names with the cw_bselector widget
;       Version 11, July 21, 1995, Liyun Wang, NASA/GSFC
;          Replaced call to FINDFILE with LOC_FILE to avoid limitation
;             of number of files being read in
;       Version 12, February 15, 1996, Liyun Wang, NASA/GSFC
;          Changed keyword TYPE to SUMMARY
;          Xresource option disabled for IDL 3.5 and earlier
;       Version 13, March 27, 1996, Liyun Wang, NASA/GSFC
;          Added interface to SOHO private data directory
;       Version 14, April 22, 1996, Liyun Wang, NASA/GSFC
;          Improved file name list (truly list files according to time)
;       Version 15, June 17, 1996, Liyun Wang, NASA/GSFC
;          Used FIND_FILE to fix built-in FINDFILE() problem
;       Version 16, July 1, 1996, Liyun Wang, NASA/GSFC
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
;       Version 21, August 18, 1997, Liyun Wang, NASA/GSFC
;          Renamed from XGET_SYNOPTIC to ITOOL_PICKFILE
;          Added interface to XPICKFILE for loading personal file
;          Added option to turn on/off auto load files
;       Version 22, October 22, 1997, Liyun Wang, NASA/GSFC
;          Modified such that double click the same filename list item
;          within 1 sec will load the image automatically
;       Version 23, January 16, 1998, Zarro, SAC/GSFC
;          Added ability to search for TRACE and Yohkoh Synoptic data 
;          in Yohkoh weekly directories
;       Version 24, June 10, 1998, Zarro, SAC/GSFC
;          Added check for invalid file selection
;       Version 25, July, 2001, Zarro, EITI/GSFC
;          Restored check for invalid time selections
;
;-

PRO itool_pk_update, info, sel_id, initial=initial, force=force
;---------------------------------------------------------------------------
;  A routine to update file listing for a given site
;---------------------------------------------------------------------------
   COMMON for_itool_pk_update, start_date, end_date, s_name, s_files, $
      select_id

   IF N_ELEMENTS(sel_id) NE 0 THEN select_id = sel_id

   xhour

   source = info.sources.dirname(info.src_index > 0)
   IF N_ELEMENTS(s_name) EQ 0 THEN s_name = ''
   IF N_ELEMENTS(start_date) EQ 0 THEN BEGIN
      start_date = ''
      end_date = ''
   ENDIF

   WIDGET_CONTROL, info.selected, set_value=''
   xhour

   redo = (source NE s_name) OR (start_date NE date_code(info.start_cur)) OR $
      (end_date NE date_code(info.stop_cur)) OR (info.datasrc NE info.prev_dsrc)


   if info.datasrc ne info.prev_dsrc then begin
     dprint,'data source changed:',info.prev_dsrc,' --> ',info.datasrc
   endif

   IF KEYWORD_SET(force) THEN redo = 1

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

      dprint,'% path ',path
      names = itool_getfile(info.start_cur, info.stop_cur, path, $
                            count=count, dlog=dlog, start_date=start_date, $
                            end_date=end_date)
      IF count EQ 0 THEN delvarx, names

      IF N_ELEMENTS(names) NE 0 THEN s_files = names ELSE delvarx, s_files

      IF N_ELEMENTS(s_files) NE 0 THEN BEGIN
         info = rep_tag_value(info, dlog(0), 'DLOG')
         info.path = path(0)
      ENDIF
   ENDIF
   
   IF !version.release GE '5' THEN WIDGET_CONTROL, info.list_bs, update=0
   n_files = N_ELEMENTS(s_files)
   IF n_files EQ 0 THEN BEGIN
      WIDGET_CONTROL, info.fcount, set_value='No file(s) found'
      WIDGET_CONTROL, info.flist, sensitive=0, set_value=''
   ENDIF ELSE BEGIN
      WIDGET_CONTROL, info.flist, sensitive=1
      IF redo OR KEYWORD_SET(initial) THEN BEGIN
         WIDGET_CONTROL, info.flist, set_value=strip_dirname(s_files)
         WIDGET_CONTROL, info.fcount, set_value='Found '+$
            STRTRIM(n_files, 2)+' file(s):'
         info = rep_tag_value(info, s_files, 'NAMES')
         IF n_files EQ 1 THEN select_id = 0
         IF exist(select_id) THEN $
            WIDGET_CONTROL, info.flist, set_list_select=select_id
      ENDIF
   ENDELSE
   IF !version.release GE '5' THEN WIDGET_CONTROL, info.list_bs, update=1
   
   IF exist(select_id) and exist(s_files) THEN BEGIN
      WIDGET_CONTROL, info.selected, set_value=$
         strip_dirname(s_files(select_id))
   ENDIF
   WIDGET_CONTROL, info.accept, sensitive=N_ELEMENTS(select_id) NE 0 and $
                                          (info.auto_accept eq 0)

END

;----------------------------------------------------------------------------
PRO itool_pickfile_event, event, outfile=outfile, status=status
   COMMON itool_pkfile, info, prev_sel, prev_time

   ON_ERROR, 2
   status = -1
   outfile = ''

   IF info.datasrc EQ 0 THEN BEGIN
      if since_version('5.4') then $ 
       xpickfile_event, event, outfile=outfile, status=status else $
        xpickfile2_event, event, outfile=outfile, status=status
      info.outfile = outfile
      info.status = status
      IF status EQ 1 THEN BEGIN
         IF NOT info.has_parent THEN BEGIN
            xkill, event.top
         ENDIF
         RETURN
      ENDIF
   ENDIF

   WIDGET_CONTROL, event.id, get_uvalue=uvalue
   IF N_ELEMENTS(uvalue) EQ 0 THEN RETURN
   uvalue = uvalue(0)

   if uvalue eq 'QUIT' then begin
    outfile = ''
    status = 0
    IF NOT info.has_parent THEN xkill, event.top
   endif

   if uvalue eq 'AUTO' then BEGIN
    info.auto_list = event.select
    WIDGET_CONTROL, info.reload, sensitive=(info.auto_list EQ 0)
   endif

   WIDGET_CONTROL, info.start_id, get_value=start_str
   WIDGET_CONTROL, info.stop_id, get_value=stop_str

   err=''
   if valid_time(start_str(0)) then begin
    start_str = anytim2utc(start_str(0), /ecs, /date) 
    info.start_cur=start_str
   endif else err='Invalid start date!'

   if err eq '' then begin
    if valid_time(stop_str(0)) then begin
     stop_str = anytim2utc(stop_str(0), /ecs, /date)
     info.stop_cur=stop_str
    endif else err='Invalid stop date!' 
   endif

   if err eq '' then begin
    if info.start_cur gt info.stop_cur then begin
     err='Start time exceeds Stop time'
    endif
   endif

   IF err NE '' THEN BEGIN
    flash_msg, info.selected, err, num=2
    WAIT, 1.0
    WIDGET_CONTROL, info.selected, set_value=''
    RETURN
   ENDIF

   clook = WHERE(uvalue EQ info.sources.dirname, count)
   IF count NE 0 THEN BEGIN
;---------------------------------------------------------------------------
;     User chooses a new image site or type
;---------------------------------------------------------------------------
      diff = info.src_index NE clook(0)
      IF diff THEN BEGIN
         IF NOT info.auto_list THEN BEGIN
            WIDGET_CONTROL, info.flist, set_value=''
            WIDGET_CONTROL, info.fcount, set_value=''
         ENDIF ELSE BEGIN
            info.src_index = clook(0)
            itool_pk_update, info
         ENDELSE
      ENDIF
      info.src_index = clook(0)
      if info.datasrc eq 1 then info.last_synop_index=info.src_index else $
       info.last_soho_index=info.src_index
   ENDIF

   CASE (uvalue(0)) OF
      'AUTO_ACCEPT': begin
        info.auto_accept=event.select
        widget_control,info.accept,sensitive=(info.auto_accept eq 0)
       end
      'AUTO': BEGIN
         IF info.auto_list THEN itool_pk_update, info
      END

       'list_file': itool_pk_update, info, /force
       'KSTOP': itool_pk_update, info, /force
       'KSTART': itool_pk_update, info, /force

      'DATA_PATH': BEGIN
         WIDGET_CONTROL, info.env_lb, get_value=new_path
         diff = STRTRIM(new_path(0), 2) NE info.env_path
         info.env_path = STRTRIM(new_path(0), 2)
         IF info.auto_list THEN itool_pk_update, info ELSE IF diff THEN BEGIN
            WIDGET_CONTROL, info.flist, set_value=''
            WIDGET_CONTROL, info.fcount, set_value=''
         ENDIF
      END
      'DATA_TYPE': BEGIN

;-- restore last saved instrument/site index (src_index)

         info.datasrc = event.index
         IF event.index EQ 0 THEN BEGIN
            WIDGET_CONTROL, info.soho_base, map=0
            WIDGET_CONTROL, info.pickfile_bs, map=1
            WIDGET_CONTROL, info.env_lb, set_value=''
         ENDIF ELSE BEGIN
            WIDGET_CONTROL, info.pickfile_bs, map=0
            WIDGET_CONTROL, info.soho_base, map=1
            IF event.index NE info.prev_dsrc THEN BEGIN
               info.src_index=0
               WIDGET_CONTROL, info.reload, sensitive=1
               CASE (event.index) OF 
                  1: BEGIN
                     info.src_index=info.last_synop_index
                     info.env_path = STRTRIM(GETENV('SYNOP_DATA'), 2)
                     WIDGET_CONTROL, info.soho_bs, map=0
                     WIDGET_CONTROL, info.synop_bs, map=1
                     widget_control,info.source_bs,map=1
                     info = rep_tag_value(info, info.synop_src, 'SOURCES')
                     WIDGET_CONTROL, info.synop_sel, set_value=info.src_index
                  END
                  2: BEGIN
                     info.src_index=info.last_soho_index
                     WIDGET_CONTROL, info.synop_bs, map=0
                     WIDGET_CONTROL, info.soho_bs, map=1
                     widget_control,info.source_bs,map=1
                     WIDGET_CONTROL, info.soho_sel, set_value=info.src_index
                     info.env_path = STRTRIM(GETENV('SUMMARY_DATA'), 2)
                     info = rep_tag_value(info, info.soho_src, 'SOURCES')
                  END
                  3: BEGIN
                     info.src_index=info.last_soho_index
                     WIDGET_CONTROL, info.synop_bs, map=0
                     WIDGET_CONTROL, info.soho_bs, map=1
                     widget_control,info.source_bs,map=1
                     WIDGET_CONTROL, info.soho_sel, set_value=info.src_index
                     info.env_path = STRTRIM(GETENV('PRIVATE_DATA'), 2)
                     info = rep_tag_value(info, info.soho_src, 'SOURCES')
                  END
                  4: BEGIN
                     WIDGET_CONTROL, info.synop_bs, map=1
                     WIDGET_CONTROL, info.soho_bs, map=0
                     widget_control,info.source_bs,map=1
                     WIDGET_CONTROL, info.soho_sel, set_value=info.src_index
                     info.env_path = STRTRIM(GETENV('YOHKOH_SYNOP'), 2)
                     info = rep_tag_value(info, info.synop_src, 'SOURCES')
                     WIDGET_CONTROL, info.synop_sel, set_value=info.src_index
                  END
                  ELSE:
               ENDCASE
            ENDIF
            WIDGET_CONTROL, info.env_lb, set_value=info.env_path

            IF info.auto_list THEN BEGIN
               itool_pk_update, info
            ENDIF ELSE BEGIN
               WIDGET_CONTROL, info.flist, set_value=''
               WIDGET_CONTROL, info.fcount, set_value=''
            ENDELSE
         ENDELSE
         info.prev_dsrc=info.datasrc

      END
      'LIST': BEGIN
         info.idx = event.index
         sel = strip_dirname(STRTRIM(info.names(info.idx), 2))
         curr_time = SYSTIME(1)
         WIDGET_CONTROL, info.selected, set_value=sel
         WIDGET_CONTROL, info.accept, sensitive=(info.auto_accept eq 0)
         itool_pk_update, info, info.idx
         IF N_ELEMENTS(prev_sel) NE 0 THEN BEGIN
;---------------------------------------------------------------------------
;           If clicked twice on the same item within 1 sec, accept it
;           and load the image
;---------------------------------------------------------------------------
            IF (sel EQ prev_sel AND (curr_time-prev_time) LE 1.d0) then $
             uvalue = 'DONE'
         ENDIF
         if info.auto_accept then uvalue='DONE'
         prev_sel = sel
         prev_time = curr_time
      END
;       'HELP': BEGIN
;          xtext, ['Images can be chosen from various institutes through the pull-down', $
;                  'menu button for "Image Source". ', ' ', $
;                  'You can edit the start and stop dates of the period through which the', $
;                  'images are filtered, just follow the YYYYY/MM/DD format. A carriage', $
;                  'return is required for the editing to take effect.'], $
;             title='ITOOL_PICKFILE HELP', group=event.top, /modal, space=1
;       END
      ELSE:
   ENDCASE
   IF uvalue(0) EQ 'DONE' THEN BEGIN
      WIDGET_CONTROL, info.selected, get_value=name_str
      name = STRTRIM(name_str(0), 2)
      IF name EQ '' THEN BEGIN
         flash_msg, info.selected, 'Invalid filename!!', num=2
         WAIT, 1.0
         WIDGET_CONTROL, info.selected, set_value=''
      ENDIF ELSE BEGIN
         status = 1
         outfile = concat_dir(info.path, name)
         IF NOT info.has_parent THEN xkill, event.top
      ENDELSE
   ENDIF
   info.outfile = outfile
   info.status = status
END

FUNCTION itool_pickfile, parent=parent, start=start, stop=stop, $
              source_idx=source_idx, event_pro=event_pro, map=map, $
              group=group, modal=modal, initialize=initialize, $
              path=path, filter=filter, get_path=get_path, status=status, $
              datasource=datasource

;----------------------------------------------------------------------
;  Main routine
;----------------------------------------------------------------------
   COMMON itool_pkfile, info, prev_sel, prev_time

   ON_ERROR, 2
   status = 0

   IF N_ELEMENTS(datasource) NE 0 THEN datasrc = datasource
   IF N_ELEMENTS(source_idx) NE 0 THEN src_index = source_idx
   IF N_ELEMENTS(info) NE 0 THEN BEGIN
      src_index = info.src_index
      auto_list = info.auto_list
      auto_accept=info.auto_accept
      datasrc = info.datasrc
      idx = info.idx
      sources = info.sources
      names = info.names
      last_soho_index=info.last_soho_index
      last_synop_index=info.last_synop_index
   ENDIF ELSE BEGIN
      IF N_ELEMENTS(datasrc) EQ 0 THEN datasrc = 1
      IF N_ELEMENTS(src_index) EQ 0 THEN src_index = 0
      auto_list = 0
      auto_accept=1
      last_soho_index=0
      last_synop_index=0
      idx = 0
      names = ''
      sources = get_source_stc(datasource=datasrc)
   ENDELSE

   i_num = N_ELEMENTS(sources.name)
   IF KEYWORD_SET(initialize) THEN RETURN, sources

   IF src_index LT 0 OR src_index GT i_num THEN BEGIN
      PRINT, 'ITOOL_PICKFILE -- Invalid Image source.'
      src_index = 0
   ENDIF
   sources.dir_index = src_index
   env_path = ''
   CASE (datasrc) OF
      1: BEGIN
         env_path = STRTRIM(GETENV('SYNOP_DATA'), 2)
         IF env_path EQ '' THEN BEGIN
            MESSAGE, 'Environment variable SYNOP_DATA not set. '+$
               'Using personal data.', /cont
            datasrc = 0
         ENDIF
      END
      2: BEGIN
         env_path = STRTRIM(GETENV('SUMMARY_DATA'), 2)
         IF env_path EQ '' THEN BEGIN
            MESSAGE, 'Environment variable SUMMARY_DATA not set. '+$
               'Using personal data.', /cont
            datasrc = 0
         ENDIF
      END
      3: BEGIN
         env_path = STRTRIM(GETENV('PRIVATE_DATA'), 2)
         IF env_path EQ '' THEN BEGIN
            MESSAGE, 'Environment variable PRIVATE_DATA not set. '+$
               'Using personal data.', /cont
            datasrc = 0
         ENDIF
      END
      4: BEGIN
         env_path = STRTRIM(GETENV('YOHKOH_SYNOP'), 2)
         IF env_path EQ '' THEN BEGIN
            MESSAGE, 'Environment variable YOHKOH_SYNOP not set. '+$
               'Using personal data.', /cont
            datasrc = 0
         ENDIF
      END
      ELSE:
   ENDCASE

   IF env_path EQ '' THEN env_path = GETENV('HOME')
   path = env_path

   IF datasrc GT 0 THEN $
      path=concat_dir(env_path, sources.dirname(src_index), /dir)

   IF N_ELEMENTS(stop) NE 0 THEN BEGIN
      IF valid_time(stop, err) THEN $
         stop_cur = anytim2utc(stop, /ecs, /date) $
      ELSE MESSAGE, 'Invalid STOP date/time string!', /cont
   ENDIF ELSE BEGIN
      IF N_ELEMENTS(info) NE 0 THEN stop_cur = info.stop_cur
   ENDELSE

   IF N_ELEMENTS(stop_cur) EQ 0 THEN BEGIN
      get_utc, tt, /ecs
      stop_cur = anytim2utc(tt, /ecs, /date)
   ENDIF

   IF N_ELEMENTS(start) NE 0 THEN BEGIN
      IF valid_time(start, err) THEN $
         start_cur = anytim2utc(start, /ecs, /date) $
      ELSE $
         start_cur = '1990/01/01'
   ENDIF ELSE BEGIN
      IF N_ELEMENTS(info) NE 0 THEN start_cur = info.start_cur
   ENDELSE 
   
   IF N_ELEMENTS(start_cur) NE 0 THEN BEGIN
      IF anytim2tai(start_cur) GE anytim2tai(stop_cur) THEN delvarx, start_cur
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

   mk_dfont, bfont=bfont, tfont=tfont, lfont=lfont

   IF N_ELEMENTS(parent) NE 0 THEN BEGIN
      IF WIDGET_INFO(parent, /valid) THEN BEGIN
         IF N_ELEMENTS(event_pro) NE 0 THEN $
            base=WIDGET_BASE(parent, /column, map=map, event_pro=event_pro) $
         ELSE $
            base=WIDGET_BASE(parent, /column, event_pro='itool_pickfile',$
                             map=map)
         has_parent = 1
      ENDIF
   ENDIF
   IF N_ELEMENTS(base) EQ 0 THEN BEGIN
      map = 1
      base = WIDGET_BASE(title='ITOOL_PICKFILE', /column, map=map)
      has_parent = 0
   ENDIF
   junk = WIDGET_LABEL(base, value='Image Tool Image Picker')

   data_path = WIDGET_BASE(base, /row, /frame)
   temp = cw_bselector2(data_path, font=lfont, $
                       ['PERSONAL DATA', 'SYNOPTIC DATA', $
                        'SUMMARY DATA ', 'PRIVATE DATA ','YOHKOH SYNOPTIC'],$
                       /return_index, uvalue='DATA_TYPE', ids=ids)
   IF GETENV('SYNOP_DATA') EQ '' THEN WIDGET_CONTROL, ids(1), sensitive=0
   IF GETENV('SUMMARY_DATA') EQ '' THEN WIDGET_CONTROL, ids(2), sensitive=0
   IF GETENV('PRIVATE_DATA') EQ '' THEN WIDGET_CONTROL, ids(3), sensitive=0
   IF GETENV('YOHKOH_SYNOP') EQ '' THEN WIDGET_CONTROL, ids(4), sensitive=0


   WIDGET_CONTROL, temp, set_value=datasrc
   env_lb = WIDGET_TEXT(data_path, font='fixed', uvalue='DATA_PATH', $
                        value=path, xsize=34)

   holder = WIDGET_BASE(base)

;---------------------------------------------------------------------------
;  Build widget XPICKFILE for handling personal data files
;---------------------------------------------------------------------------

   if since_version('5.4') then xpickfile='xpickfile' else xpickfile='xpickfile2'
   IF N_ELEMENTS(event_pro) NE 0 THEN BEGIN
      pickfile_bs = call_function(xpickfile,parent=holder, filter=filter, map=0, $
                              get_path=get_path, event_pro=event_pro)
   ENDIF ELSE BEGIN
      pickfile_bs = call_function(xpickfile,parent=holder, filter=filter, map=0, $
                              get_path=get_path,$
                              event_pro='itool_pickfile_event')
   ENDELSE

;---------------------------------------------------------------------------
;  Build widget to handle data files in SOHO environment
;---------------------------------------------------------------------------
   soho_base = WIDGET_BASE(holder, map=0, /column)
   synop_src = get_source_stc(datasource=1)
   soho_src = get_source_stc(datasource=2)

   source_bs = WIDGET_BASE(soho_base, /frame)

   synop_bs = WIDGET_BASE(source_bs, map=0)
   IF src_index GT N_ELEMENTS(synop_src.name)-1 THEN $
      src_index = N_ELEMENTS(synop_src.name)-1
   synop_sel= cw_bselector2(synop_bs, synop_src.name, font=lfont, $
                            return_uvalue=synop_src.dirname, $
                            set_value=src_index, label_left='Source:')

   soho_bs = WIDGET_BASE(source_bs, map=0)
   IF src_index GT N_ELEMENTS(soho_src.name)-1 THEN $
      src_index = N_ELEMENTS(soho_src.name)-1

   soho_sel= cw_bselector2(soho_bs, soho_src.name, font=lfont, $
                           return_uvalue=soho_src.dirname, $
                           set_value=src_index, label_left='Source:')

   tmp = WIDGET_BASE(soho_base, /row, /frame)
   reload = WIDGET_BUTTON(tmp, value=' List files ', uvalue='list_file', $
                          font=lfont)
   junk = WIDGET_LABEL(tmp, value='      Auto list files', font=lfont)
   junk = WIDGET_BASE(tmp, /row, /nonexclusive)
   aload = WIDGET_BUTTON(junk, value='', font=lfont, uvalue='AUTO')

   base1 = WIDGET_BASE(soho_base, /row, /frame)
   junk = WIDGET_LABEL(base1, value='Date -> Start:', font=lfont)
   start_id = WIDGET_TEXT(base1, value=start_cur, font='fixed', /edit, $
                          xsize=10, uvalue='KSTART')
   junk = WIDGET_LABEL(base1, value=' Stop:', font=lfont)
   stop_id = WIDGET_TEXT(base1, value=stop_cur, font='fixed', /edit, $
                         xsize=10, uvalue='KSTOP')

   list_bs = WIDGET_BASE(soho_base, /column, space=1)
   fcount = WIDGET_LABEL(list_bs, value='', font=lfont)
   flist = WIDGET_LIST(soho_base, value=STRARR(20,10), ysize=10, $
                       uvalue='LIST', font=lfont, xsize=31)

   sel_bs = WIDGET_BASE(soho_base, /row, /frame)
   label = WIDGET_LABEL(sel_bs, value='Selection:', font=lfont)
   selected = WIDGET_TEXT(sel_bs, value='', xsize=34, font='fixed')

   cmd_bs = WIDGET_BASE(soho_base, /row, /frame)
   IF !version.release LT '3.6' THEN BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', font=bfont)
      IF NOT has_parent THEN $
         quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', $
                              font=bfont)
   ENDIF ELSE BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', $
                             font=bfont, resource_name='AcceptButton')
      IF NOT has_parent THEN $
         quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', $
                              font=bfont, resource_name='QuitButton')
   ENDELSE

   tmp=widget_base(cmd_bs,/row)
   junk = WIDGET_LABEL(tmp, value='      Auto accept selection', font=lfont)
   junk = WIDGET_BASE(tmp, /row, /nonexclusive)
   a_accept = WIDGET_BUTTON(junk, value='', font=lfont, uvalue='AUTO_ACCEPT')

;   junk = WIDGET_LABEL(cmd_bs,value='  ',font=lfont)

;-- map/sensitive depending on last/current settings

   WIDGET_CONTROL, accept, sensitive=0
   IF datasrc EQ 0 THEN BEGIN
      WIDGET_CONTROL, pickfile_bs, map=1
   ENDIF ELSE BEGIN
      WIDGET_CONTROL, soho_base, map=1
      IF datasrc GT 1 THEN $
         WIDGET_CONTROL, soho_bs, map=1 $
      ELSE $
         WIDGET_CONTROL, synop_bs, map=1
   ENDELSE

   info = {start_id:start_id, stop_id:stop_id, env_lb:env_lb, $
           selected:selected, flist:flist, env_path:env_path, $
           accept:accept, sources:sources, src_index:src_index, $
           path:path, idx:idx, status:status, start_cur:start_cur, $
           stop_cur:stop_cur, outfile:'', names:names, dlog:'', $
           source_bs:source_bs, datasrc:datasrc, list_bs:list_bs, $
           pickfile_bs:pickfile_bs, soho_base:soho_base, lfont:lfont,$
           has_parent:has_parent, auto_list:auto_list, reload:reload, $
           prev_dsrc:datasrc, fcount:fcount, synop_bs:synop_bs, $
           soho_bs:soho_bs, soho_src:soho_src, synop_src:synop_src, $
           soho_sel:soho_sel, synop_sel:synop_sel,aload:aload,$
           auto_accept:auto_accept,a_accept:a_accept,$
           last_synop_index:last_synop_index,last_soho_index:last_soho_index}

   WIDGET_CONTROL, aload, set_button=info.auto_list
   WIDGET_CONTROL, a_accept, set_button=info.auto_accept
   WIDGET_CONTROL, reload, sensitive=(info.auto_list EQ 0)

   IF STRPOS(info.path, info.env_path) NE -1 THEN BEGIN
      WIDGET_CONTROL, info.flist, $
         set_value=strip_dirname(STRTRIM(info.names,2))
      IF info.names(0) NE '' THEN $
         WIDGET_CONTROL, info.fcount, set_value='Found '+$
         STRTRIM(N_ELEMENTS(info.names), 2)+' file(s):' $
      ELSE $
         WIDGET_CONTROL, info.fcount, set_value='                            '
   ENDIF

;---------------------------------------------------------------------------
;  The INITIAL keyword is needed so that the next time when this routine is
;  called, the previous listings are still available
;---------------------------------------------------------------------------

   itool_pk_update, info,/init

   IF NOT has_parent THEN BEGIN
      xrealize, base, group=group, /screen
      xmanager, 'itool_pickfile', base, group=group, modal=KEYWORD_SET(modal)
      IF NOT KEYWORD_SET(group) THEN xmanager
      datasrc = info.datasrc
      src_index = info.src_index
      IF info.status THEN BEGIN
         RETURN, info.outfile
      ENDIF ELSE RETURN, ''
   ENDIF ELSE RETURN, base

END

