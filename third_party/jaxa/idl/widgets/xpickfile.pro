;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       xpickfile
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
;       xpickfile, parent, child
;
; EXAMPLE:
;       xpickfile, parent, child, filter = '*.gif *.fits'
;
; INPUTS:
;       PARENT - ID of the parent base widget on which the pickfile
;                widget is built
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
; RESTRICTIONS:
;       Does not recognize symbolic links to other files in UNIX.
;       Multiple filter patterns are not recognized in VMS system
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
;	Version 8, 23-Apr-2004, Zarro (L-3Com/GSFC) - replaced SPAWN,'ls' 
;               by LIST_DIR & LIST_FILE; improved widget handling
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-

function xpf_getdirs,path,_ref_extra=extra,count=count

upper='->'
xhour
sdir=list_dir(path,_extra=extra,count=count)
if count eq 0 then return,upper else return,[upper,sdir]
end

;----------------------------------------------------------------------------------

function xpf_getfiles, filter,path,_ref_extra=extra

return,list_file(path,filter=filter,_extra=extra)
end

;--------------------------------------------------------------------------------

pro xpickfile_event, event, outfile=outfile, status=status
;---------------------------------------------------------------------------
;  event handler for widgets in this application. the keyword status
;  is a named variable whose value determines the action to be taken
;  in the main event handler: if status=0, the event is not generated
;  from this application; if status=-1, the event is generated from
;  this application but has been processed (i.e., no further
;  processing is necessary); if status=1, it means that a file has
;  been selected and the "load" button is pressed, ready for loading
;  the selected file.
;---------------------------------------------------------------------------

   common xpickfile, info,last_path,last_filt

   widget_control, info.wid.filttxt, get_value=filt
   widget_control, info.wid.pathtxt, get_value=path
   path=chklog(path[0],/pre)
   filt = filt[0] 
   status = -1
   outfile = ''

   case event.id of
       info.wid.pathtxt: begin
        if not is_dir(path) then begin
         xack,'Invalid pathname - '+path
         return
        endif
        info.here=path
        directories = xpf_getdirs(path,err=err,count=dcount)
        if is_string(err) then begin
         xack,err & return
        endif
        files = xpf_getfiles(filt,path,count=fcount)
        widget_control, info.wid.filelist,set_value=file_break(files), $
               set_uvalue=files
        widget_control, info.wid.dirlist,set_value=file_break(directories), $
                set_uvalue=directories
        widget_control, info.wid.dnum,set_value=trim(dcount)
        widget_control, info.wid.fnum,set_value=trim(fcount)
        widget_control, info.wid.selecttxt, set_value=''
        widget_control, info.wid.accept, sensitive=0
      end

      info.wid.filttxt: begin
       files = xpf_getfiles(filt,path,count=fcount)
       widget_control, info.wid.filelist,set_value=file_break(files),set_uvalue=files
       widget_control, info.wid.fnum,set_value=trim(fcount)
      end

      info.wid.dirlist: begin
        widget_control, info.wid.dirlist, get_uvalue=directories
        if (event.index le (n_elements(directories) - 1)) then begin
         temp=directories[event.index]
         if temp eq '->' then begin
          upath=file_break(path,/path)
          if (upath ne path) and is_string(upath) then path=upath 
         endif else path=temp
         info.here=path
         widget_control, info.wid.pathtxt, set_value=path
         directories = xpf_getdirs(path,err=err,count=dcount)
         if is_string(err) then begin
          xack,err & return
         endif
         files = xpf_getfiles(filt,path,count=fcount)
         widget_control, info.wid.filelist, set_value=file_break(files), set_uvalue=files
         widget_control, info.wid.dirlist, set_value=file_break(directories), $
             set_uvalue=directories
         widget_control, info.wid.dnum,set_value=trim(dcount)
         widget_control, info.wid.fnum,set_value=trim(fcount)
         widget_control, info.wid.selecttxt, set_value=''
         widget_control, info.wid.accept, sensitive=0
        endif
      end

      info.wid.filelist: begin
         widget_control, info.wid.filelist, get_uvalue=files
         if is_string(files) then begin
          info.outfile=files[event.index]
          info.thefile=file_break(info.outfile)
          widget_control, info.wid.selecttxt, set_value=info.thefile
          widget_control, info.wid.accept, sensitive=1
         endif
      end

      info.wid.accept: begin
         status = 1
         widget_control, info.wid.pathtxt, set_text_select=0
         widget_control, info.wid.filttxt, set_text_select=0
         if not info.has_parent then xkill, event.top 
      end

      info.wid.cancel: begin
         status = 0
         widget_control, info.wid.pathtxt, set_text_select=0
         widget_control, info.wid.filttxt, set_text_select=0
         if not info.has_parent then xkill, event.top
      end

;      info.wid.selecttxt: begin
;         widget_control, info.wid.selecttxt, get_value=temp
;         widget_control, info.wid.accept, sensitive=1
;      end

      else:
   endcase
   
   info.status=status
   last_path=path
   last_filt=filt
   outfile=info.outfile
   return

end

function xpickfile, parent=parent, map=map, path=path, event_pro=event_pro, $
              filter=filter, get_path=get_path, font=font, status=status
   common xpickfile

   if xregistered('xpickfile') ne 0 then return,''
   if not keyword_set(map) then map = 0

   case 1 of
    is_dir(path) : here=path
    is_dir(last_path): here=last_path
    is_dir('personal_data',out=out): here=out
    else: here=curdir()
   endcase
 
   file=''
   case 1 of
    is_string(filter): filt=filter
    is_string(last_filt): filt=last_filt
    else: filt=''
   endcase
   
   directories = xpf_getdirs(here,count=dcount)
   files = xpf_getfiles(filt,here,count=fcount)

   version = widget_info(/version)
   mk_dfont, lfont=lfont, bfont=bfont
   if n_elements(font) ne 0 then lfont = font

   if n_elements(parent) ne 0 then begin
      if widget_info(parent, /valid) then begin
         if n_elements(event_pro) eq 0 then event_pro = 'xpickfile_event'
         base = widget_mbase(parent, /column, map=map, $
                            event_pro=event_pro)
         has_parent = 1
      endif
   endif
   if n_elements(base) eq 0 then begin
      base = widget_mbase(title='xpickfile', /column,/modal,/map)
      has_parent = 0
   endif
   wid = {base:base}

   widebase = widget_base(base, /row, /fr)
   label = widget_label(widebase, value="Path:", font=lfont)
   pathtxt = widget_text(widebase, val=here, uvalue='pathtxt', $
                         /edit, xs=34, font=lfont)
   wid = add_tag(wid, pathtxt, 'pathtxt')

   filtbase = widget_base(base, /row, /fr)
   filtlbl = widget_label(filtbase, value="Filter:",font=lfont)
   filttxt = widget_text(filtbase, val=filt, uvalue='filttxt', $
                         /edit, xs=34, font=lfont)
   wid = add_tag(wid, filttxt, 'filttxt')

   sbase=widget_base(base,/row)
   
   lbl = widget_label(sbase, value="Subdirectories:",font=lfont)
   dnum=widget_text(sbase,value='',font=lfont,xsize=5)

   dirlist = widget_list(base, value=file_break(directories), ysize=6, $
                         uvalue=directories, font=lfont)
   wid = add_tag(wid, dirlist, 'dirlist')
   wid=  add_tag(wid,dnum,'dnum')
   lbase=widget_base(base,/row)
   lbl = widget_label(lbase, value="Files:",font=lfont)
   fnum=widget_text(lbase,value='',font=lfont,xsize=5)
   filelist = widget_list(base, value=file_break(files), ysize=6, uvalue=files, font=lfont)
   wid = add_tag(wid, filelist, ' filelist')
   wid=  add_tag(wid,fnum,'fnum')
   widget_control, wid.dnum,set_value=trim(dcount)
   widget_control, wid.fnum,set_value=trim(fcount)
   widebase = widget_base(base, /row, /frame)
   label = widget_label(widebase, value="Selection:",font=lfont)
   selecttxt = widget_text(widebase, val=file, xs=31, $
                           font=lfont)
   wid = add_tag(wid, selecttxt, 'selecttxt')

   rowbase = widget_base(base, /row, /frame)

   cancel = -1l
   wid = add_tag(wid, cancel, 'cancel')
   if !version.release lt '3.6' then begin
      accept = widget_button(rowbase, value='Accept', font=bfont, $
                             uvalue='something')
      if not has_parent then begin
         cancel = widget_button(rowbase, value='Cancel', font=bfont, $
                                uvalue='something')
      endif
   endif else begin
      accept = widget_button(rowbase, value='Accept', font=bfont, $
                             uvalue='something', resource='acceptbutton')
      if not has_parent then begin
         cancel = widget_button(rowbase, value='Cancel', font=bfont, $
                                uvalue='something', resource='quitbutton')
      endif
   endelse
   if file eq '' then widget_control, accept, sensitive=0
   wid = add_tag(wid, accept, 'accept')
   wid.cancel = cancel

   if not has_parent then parent=0
   info = {status:0, outfile:'',has_parent:has_parent, here:here, $
           thefile:'', wid:wid,parent:parent}

   if not has_parent then begin
      widget_control, base, /realize,/map
      xmanager, 'xpickfile', base
      status = info.status
      get_path=info.here
      return, info.outfile
   endif else return, base
end

