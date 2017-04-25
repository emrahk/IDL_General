;+
; Project     : HESSI
;
; Name        : SHOW_SYNOP__DEFINE
;
; Purpose     : widget interface to Synoptic data archive
;
; Category    : HESSI, Synoptic, Database, widgets, objects
;
; Syntax      : IDL> obj=obj_new('show_synop',group=group)
;
; Keywords    : GROUP = widget ID of any calling widget
;               PTR = pointer to last displayed object
;
; History     : 12-May-2000,  D.M. Zarro (SM&A/GSFC) - written
;               11-Nov-2005, Zarro (L-3Com/GSI) - tidied up
;               20-Dec-2005, Kim Tolbert - changed dealing with goes object
;                4-Jan-2006, Zarro - removed old GOES references
;               13-Jan-2006, Zarro - added GROUP and NO_PLOTMAN keywords
;               24-Sep-2006, Zarro (ADNET/GSFC)
;                - moved directory selection from config to main widget
;               10 Dec 2007, Zarro (ADNET)
;                - added VSO search option
;               12 Feb 2008, Zarro (ADNET)
;                - fixed bug with caching search results and passing tstart/tend
;                  to PLOTMAN
;               14 Feb 2007, Kim - modified sub-interval selection using GOES
;               26-Feb-2008, Kim - made show_synop and goes share same plotman obj
;                5-Jul-2008, Kim 
;                 - changed plotman calls to use new simplified version
;                31-Jul-2008, Zarro (ADNET) 
;                - inhibited deleting objects if being used by PLOTMAN
;                13-Nov-2008, Zarro (ADNET)
;                - restored cloning of multi-record data
;                 7-Jan-2009, Zarro (ADNET)
;                - added unique descriptions for multi-record data objects
;                 30-Mar-2009, Kim
;                - if get_plot_obj method exists, get plot object to
;                  plot
;                13 May 2009, Zarro (ADNET)
;                - merged VSO search option into site search
;                21 June 2009, Zarro (ADNET)
;                - removed type-based searching
;                26 October 2009, Zarro (ADNET)
;                - piped all downloads thru sock_copy
;                17 November 2009, Zarro (ADNET) 
;                - incorporated method call to VSO Prepserver
;                25 January 2010, Tolbert (Wyle)
;                - added hooks for selecting prep options
;                9 February 2010, Zarro
;                - merged SHOW_SYNOP__DEFINE with SYNOP__DEFINE
;                24 May 2010, Zarro
;                - made /limb and grid=30 the default display for images
;                11-Jun-2010, Kim
;                - call plotman with /colors to get
;                  instrument's preferred colors
;                10-July-2010, Zarro
;                - fixed bug with prepped file always going to current
;                  directory and not user specified location.
;                27-Dec-2010, Zarro
;                - included filename in DESC to PLOTMAN call for
;                  non-images
;                25-Feb-2012, Zarro (ADNET)
;                - disabled VSO Prepserver
;                28-Mar-2013, Zarro (ADNET)
;                - fixed view header issue showing wrong file date
;                15-Jun-2013, Kim Tolbert
;                - use cw_ut_range compound widget to handle times
;                - added search string to select among downloaded files
;                - added text widget showing how many downloaded files are selected
;                - added sel_update method
;                1-Aug-2013, Zarro (ADNET)
;                - added check for caching search results
;                22-Oct-2013, Zarro (ADNET)
;                - moved SITE property and RSEARCH method to inherited
;                  SITE class
;                - fixed bug with viewing multiple file headers
;                4-Oct-2014, Zarro (ADNET)
;                - removed old time-handling code now handled
;                  by Kim's widget. 
;                - added check for PLOT method if not using PLOTMAN
;                - removed unused SAVE_TIME property
;                - fix bug with not returning last cached results 
;                  when show_synop restarted
;                1-Dec-2014, Zarro (ADNET)
;                - fixed problem with caching being reset by 
;                  cache property on instrument object.
;                31-Jul-2015, Zarro
;                 - added /use_colors when not plotting with PLOTMAN
;                 - removed /use_colors from PLOTMAN call as it
;                   interferes with PLOTMAN's internal use of linecolors
;
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function show_synop::init,verbose=verbose,no_plotman=no_plotman,$
  plotman_obj=plotman_obj,reset=reset,_extra=extra,group=group,$
  messenger=messenger

;-- defaults

if ~allow_windows(err=err) then begin
 if is_string(err) then message,err,/info
 return,0
endif

;-- only single copy allowed

self->setprop,verbose=verbose
if keyword_set(reset) then xkill,'show_synop::setup'
if (xregistered('show_synop::setup') ne 0) then return,0

success=self->site::init(_extra=extra)                                                       
if ~success then return,0
                                                                                             
user_synop_data=chklog('USER_SYNOP_DATA')                                                   
if ~is_dir(user_synop_data) then begin                                                   
 user_synop_data=curdir()                                                                   
 if ~write_dir(user_synop_data) then user_synop_data=get_temp_dir()                      
endif                                                                                       
                                                                                             
self->setprop,org='day',ext='',ldir=user_synop_data,err=err,up_prep=0b,$
  last_time=1b,plotman=have_proc('plotman__define'),down_prep=0b

;-- config file for saving state

case 1 of
 test_dir('$HOME',out=out): save_dir=out 
 test_dir(get_temp_dir(),out=out): save_dir=out
 else: save_dir=curdir()
endcase

config_file=concat_dir(save_dir,'.show_synop_config')

;-- create !SHOW_SYNOP  for caching

defsysv,'!show_synop',exists=defined
if ~defined then begin
 temp={searched:0b,fifo:obj_new(),plotman_obj:obj_new(),goes_obj:obj_new()}
 defsysv,'!show_synop',temp
endif

;-- reset state

if keyword_set(reset) then begin
 free_var,!show_synop
 heap_gc
 file_delete,config_file,/quiet
endif

;-- save copied objects in FIFO object

if ~obj_valid(!show_synop.fifo) then !show_synop.fifo=obj_new('fifo')

;-- create INFO state structure

mk_dfont,lfont=lfont,bfont=bfont

;--- if plotman object is passed on the command line, then send plots
;    to it, else use valid plotman object saved from last time
;    show_synop was called standalone

if obj_valid(plotman_obj) then begin
 if obj_valid(!show_synop.plotman_obj) then begin
  if plotman_obj ne !show_synop.plotman_obj then obj_destroy,!show_synop.plotman_obj
 endif
 !show_synop.plotman_obj=plotman_obj
endif

self.ptr=ptr_new(/all)

info={wtimes:0l,subint:0l,main:0l,lfont:lfont,bfont:bfont,brow:0l,srow:0l,$
      site_drop:0l,$
      timer:0l,$
      slist:0l,slist2:0l,flist:0l,cur_sel:'',cur_fsel:'',$
      site_base:0l,sbuttons:[0l,0l,0l],$
      config_file:config_file,dtext:0l,wsearchstring:0l,wnsel:0l, $
      tbase:0l,hbase:0l,group:0l,messenger:0l}
      
if is_number(group) then info.group=group
if is_number(messenger) then info.messenger=messenger

self->setprop,info=info

;-- setup widget interface

self->setup,_extra=extra

;-- inhibit PLOTMAN selection

if keyword_set(no_plotman) then self->setprop,plotman=-1

return,1

end
;------------------------------------------------------------------------------

pro show_synop::setup,timerange=timerange,_extra=extra

;-- create widgets

self->create_widgets,_extra=extra

info=self->get_info()

;-- reconcile times

secs_per_day=24l*3600l
week=7l*secs_per_day

get_utc,tstart & tstart.time=0
tstart=(utc2tai(tstart)-3.*secs_per_day) > utc2tai(anytim2utc('2-dec-95'))
tend=anytim2utc(!stime)
tend.time=0
tend.mjd=tend.mjd+1
tend=utc2tai(tend)
tstart=anytim2utc(tstart,/vms)
tend=anytim2utc(tend,/vms)

;-- restore settings from last saved object
;   (catch any errors in case saved object has a problem)

reset=0
error=0
catch,error
if error ne 0 then  reset=1

if reset then file_delete,info.config_file,/quiet

xhour
chk=loc_file(info.config_file,count=count)
verbose=self.verbose
if count gt 0 then begin
 restore,file=chk[0]
 if is_struct(props) then begin
  message,'restoring configuration from - '+info.config_file,/info
  self->setprop,_extra=props
  ldir=self->getprop(/ldir)
  self->setprop,ldir=fix_dir_name(ldir)
 endif
 self->setprop,verbose=verbose
endif

catch,/cancel
message,/reset
self->setprop,down_prep=0b,up_prep=0b,prep_widg=0b

;-- use last saved times

last_time=self->getprop(/last_time)
if last_time and is_struct(props) then begin
 tstart=props.tstart
 tend=props.tend
endif

;-- override with command-line times

if n_elements(timerange) eq 2 then begin
 chk=valid_time(timerange)
 if (min(chk) ne 0) then begin
  tstart=timerange[0] & tend=timerange[1]
 endif
endif

widget_control, info.wtimes, set_value=anytim2utc([tstart,tend],/vms)
;widget_control,info.tstart,set_value=anytim2utc(tstart,/vms)
;widget_control,info.tend,set_value=anytim2utc(tend,/vms)
self->setprop,tstart=tstart,tend=tend

;-- last file selection

if have_tag(props,'cur_fsel') then begin
 info=rep_tag_value(info,props.cur_fsel,'cur_fsel')
 self->setprop,info=info
endif

;-- update sort mode

sort_mode=self->getprop(/sort_mode) < 2
widget_control,info.sbuttons[sort_mode],/set_button

;-- update site name

curr_site=self->getprop(/site)
names=self->list_sites(abbr)
chk=str_match(abbr,curr_site,count=count,found=found)
if count gt 0 then widget_control,info.site_drop,set_droplist_select=found[0]

self->dlist

;-- restore last successful listing on startup

self->slist,/no_search,count=count,/quiet,/no_check

if count eq 0 then begin
 search_mess='*** Press "Search" to list filenames ***'
 widget_control,info.slist,set_value=search_mess
 widget_control,info.slist,set_uvalue=''
endif

;-- start  XMANAGER

xmanager,'show_synop::setup',info.main,/no_block,event='show_synop_main',$
 cleanup='show_synop_cleanup'

return & end

;-----------------------------------------------------------------------------
;-- create widgets

pro show_synop::create_widgets,group=group,modal=modal,no_plot=no_plot

info=self->get_info()

;-- load fonts

lfont=info.lfont
bfont=info.bfont

modal=keyword_set(modal)
info.main = widget_mbase(title = 'SHOW_SYNOP',group=group,$
                   modal=modal,/column,uvalue=self,uname='main')

;-- setup timers

info.timer=widget_base(info.main,map=0)
widget_control,info.timer,set_uvalue='timer'

;-- operation buttons

curr=anytim2utc(!stime,/vms,/date)

widget_control,info.main, tlb_set_title ='SHOW SYNOP: '+curr

row1=widget_base(info.main,/row,/frame)
exitb=widget_button(row1,value='Done',uvalue='exit',font=bfont)
if have_proc('plotman') then guig=widget_button(row1,value='GOES Workbench',font=bfont,uvalue='plot',event_pro='plot_goes_eh')
conb=widget_button(row1,value='Configure',font=bfont,uvalue='config')

;-- date/time fields

row2=widget_base(info.main,/column,/frame)

trow=widget_base(row2, /row)
;info.tstart=cw_field(trow,title= 'Start Time:  ',value=' ',xsize = 20,font=lfont)

info.wtimes = cw_ut_range(trow, value=[0.d,1.d], label='', $
  uvalue='times', /noreset,  /oneline, /nomsec)
  
;tsbutton=widget_button(trow,value='Start Time:',font=lfont,uvalue='tstart')
;info.tstart=widget_text(trow,value='',xsize=20,/editable)
;
;tebutton=widget_button(trow,value='End Time:',font=lfont,uvalue='tend')
;info.tend=widget_text(trow,value='',xsize=20,/editable)

;info.tend=cw_field(trow,title='Stop Time:   ', value=' ',xsize = 20,font=lfont)

; Interval selection buttons

if have_proc('plotman') then begin
 value='# Sub-intervals: 0'
 b1=widget_button(trow, value=value,/menu, font=lfont)
 b2=widget_button(b1,value='Select',uvalue='sel_interval',font=bfont,event_pro='plot_goes_eh')
 b3=widget_button(b1, value='Show',uvalue='show_interval',font=bfont,event_pro='plot_goes_eh')
 b4=widget_button(b1, value='Reset',uvalue='del_interval',font=bfont,event_pro='plot_goes_eh')
 info.subint=b1
endif

srow=widget_base(row2,/row)
searchb=widget_button(srow,value='Search',uvalue='search',font=bfont)
slabel=widget_label(srow,font=lfont,value=' remote sites ->')
names=self->list_sites(abbr)
info.site_base=widget_base(srow,/row,space=10)
info.site_drop=widget_droplist(info.site_base,value=trim(names),font=bfont,uvalue=abbr,/dynamic)

;--  files list

row3=widget_base(info.main,/column,/frame)

;-- sort buttons

xmenu2,['Filename','Decreasing Date','Increasing Date'],row3,/row,/exclusive,font=lfont,/no_rel,$
      buttons=sbuttons,uvalue=['by_file','by_date_d','by_date_i'],$
      title='Sort By: ',lfont=lfont

info.sbuttons=sbuttons
info.srow=widget_base(row3,/row)
downb=widget_button(info.srow,value='Download',font=bfont,uvalue='download')
dlabel2=widget_label(info.srow,font=lfont,value=' selected remote file(s)  ')
detb=widget_button(info.srow,value='View',font=bfont,uvalue='details')
dlabel3=widget_label(info.srow,font=lfont,value=' remote file header')


slabel='FILENAME                                    DATE_OBS                          '
label=widget_list(info.main,value=slabel,/frame,ysize=1,font='fixed',xsize=80)
info.slist=widget_list(info.main,value='   ',ysize=4,font='fixed',/multiple,xsize=80)
info.slist2=widget_base()

;-- downloaded files list

info.brow=widget_base(info.main,/row,/frame)
headb=widget_button(info.brow,value='View Header',font=bfont,uvalue='head')
plotb=widget_button(info.brow,value='Display',font=bfont,uvalue='plot')
;refb=widget_button(info.brow,value='Refresh',font=bfont,uvalue='refresh')
remb=widget_button(info.brow,value='Delete',font=bfont,uvalue='delete')
dlabel=widget_label(info.brow,value='Search string:', font=lfont)
info.wsearchstring=widget_text(info.brow,value='',xsize=40,/editable,uvalue='searchstring')
info.wnsel=widget_text(info.brow,value='0 selected')

row4=widget_base(info.main,/column,/frame)
drow=widget_base(row4,/row)
ldir=self->getprop(/ldir)
dlabel=widget_label(/align_left,drow,value='Currently downloaded files in: ',font=lfont)
info.dtext=widget_text(drow,value=ldir,xsize=30,/editable,uvalue='directory')
dbutt=widget_button(drow,value='Change',uvalue='change',font=bfont)

info.flist=widget_list(info.main,value='',uvalue='',ysize=8,xsize=80,font='fixed',/multiple)

;-- realize widgets and start timers

widget_control,info.main,/realize
widget_control,info.timer,timer=1.

self->setprop,info=info

return & end

;-----------------------------------------------------------------------------
;-- set INFO structure

pro show_synop::setprop,info=info,sort_mode=sort_mode,err=err,$
               clobber=clobber,_extra=extra,progress=progress,$
               plotman=plotman,up_prep=up_prep,$
               down_prep=down_prep,prep_widg=prep_widg,ldir=ldir

err=''

if is_number(sort_mode) then self.sort_mode =  0 > sort_mode < 2
if is_number(clobber) then self.clobber =  0b > clobber < 1b
if is_number(progress) then self.progress =  0b > progress < 1b
if is_struct(info) then *self.ptr=info
if is_number(plotman) then self.plotman= -1 > plotman < 1                                    
if is_number(up_prep) then self.up_prep= 0b > up_prep < 1b                              
if is_number(down_prep) then self.down_prep= 0b > down_prep < 1b
if is_number(prep_widg) then self.prep_widg= 0b > prep_widg < 1b    
if is_string(ldir) then self.ldir=ldir                          
                                                                                             
;-- set the rest                                                                             
                                                                                             
if is_struct(extra) then self->site::setprop,_extra=extra,err=err                            
                                                                                             
return & end

;-----------------------------------------------------------------------------
;-- return widget state INFO

function show_synop::get_info

if ~ptr_valid(self.ptr) then return,-1
if ~exist(*self.ptr) then return,-1
return,*self.ptr
end

;-----------------------------------------------------------------------------
;-- main event handler

 pro show_synop::main,event

;-- retrieve object reference from uvalue of main widget

 widget_control,event.top,get_uvalue=self
 widget_control,event.id, get_uvalue=uvalue
 if ~exist(uvalue) then uvalue=''
 bname=''
 if is_string(uvalue) then bname=trim(uvalue[0])
 info=self->get_info()

;-- timer

 if bname eq 'timer' then begin
  widget_control,info.timer,timer=1.

  widget_control,info.slist,get_uvalue=hold
  sens=is_string(info.cur_sel) and is_string(hold)
  widget_control,info.srow,sensitive=sens

  sens=is_string(info.cur_fsel)
  widget_control,info.brow,sens=sens

  return
 endif

;-- quit here

 if bname eq 'exit' then begin
  show_synop_cleanup,event.top
  xkill,event.top
  return
 endif

;-- sort mode

 chk=where(strlowcase(bname) eq ['by_file','by_date_d','by_date_i'],count)
 if count gt 0 then begin
  sort_mode=chk[0]
  self->setprop,sort_mode=sort_mode
  widget_control,info.slist2,get_uvalue=stc,/no_copy
  if is_struct(stc) then begin
   fdata=stc.fdata
   fnames=stc.fnames
   times=stc.times
   widget_control,info.slist,get_uvalue=files
   self->display,fdata,files,fnames,times
  endif
  return
 endif

;-- calendar buttons

 if bname eq 'times' then begin
  widget_control, info.wtimes, get_value=times
  self->setprop,tstart=times[0],tend=times[1]
 endif
 
;-- check time inputs and search pattern

 if (bname eq 'search') or (bname eq 'reload') then begin

;-- validate times

  info.cur_sel=''
  self->setprop,info=info

  widget_control,info.site_drop,get_uvalue=duvalue
  drop_index=widget_info(info.site_drop,/droplist_select)
  new_site=trim(duvalue[drop_index])
  self->setprop,site=new_site
  self->slist,reload=bname eq 'reload'
  self->setprop,info=info
  return
 endif

;-- configure

 if bname eq 'config' then self->config_create,group=event.top

;-- top list selection event

 if event.id eq info.slist then begin
  widget_control,info.srow,/sens
  new_sel=widget_selected(info.slist)
  info=rep_tag_value(info,new_sel,'cur_sel')
  self->setprop,info=info

;-- highlight first file in download list

  self->fbreak,new_sel[0],sdir,sname
  widget_control,info.flist,get_uvalue=files
  self->fbreak,files,cdir,cname
  sel=where(sname eq cname,scount)
  if scount gt 0 then begin
   widget_control,info.flist,set_list_select=sel[0]
   info=rep_tag_value(info,files[sel[0]],'cur_fsel')
   self->setprop,info=info
   self->sel_update, /reset
  endif
 endif

;-- bottom list selection event

 if event.id eq info.flist then begin
  widget_control,info.flist,get_uvalue=files
  sel_index=widget_selected(info.flist,/index)
  ok=where( (sel_index gt -1) and (sel_index lt n_elements(files)),ocount)
  if ocount gt 0 then begin
   new_sel=files[sel_index[ok]]
   info=rep_tag_value(info,new_sel,'cur_fsel')
   self->setprop,info=info
   self->sel_update, /reset
  endif
 endif

;-- show selected file details

 if xalive(info.tbase) and (event.id eq info.slist) then begin
  if have_tag(event,'clicks') then begin
   if (event.clicks eq 1) then bname='details'
  endif
 endif

 if bname eq 'details' then self->file_info,info.cur_sel[0]

;-- download selected file

 if (event.id eq info.slist) then begin
  if have_tag(event,'clicks') then begin
   if (event.clicks eq 2) then bname='download'
  endif
 endif

 if bname eq 'download' then begin
  if is_blank(info.cur_sel) then return
  ldir=self->getprop(/ldir)
  if ~write_dir(ldir) then begin
   xack,['Cannot download to: '+ldir,$
         '  -> No write access <-  ']
   return
  endif
  xhour

;-- update with new files

  cancel=0b
  self->rcopy,info.cur_sel,lfile,err=err,cancel=cancel
  if is_string(err) and ~cancel then xack,err,group=info.main
  if is_string(lfile) then begin
   clobber=self->getprop(/clobber)
   use_plotman=(self->getprop(/plotman) eq 1)
   if clobber and ~use_plotman then !show_synop.fifo->delete,lfile
  endif
  fname=lfile[0]
  info=rep_tag_value(info,fname,'cur_fsel')
  self->setprop,info=info
  self->dlist
 endif

 if (bname eq 'change') or (bname eq 'directory') then begin
  old_dir=self->getprop(/ldir)
  if bname eq 'change' then $
   new_dir=dialog_pickfile(/directory,/must_exist,dialog_parent=event.top,path=old_dir) else $
    widget_control,info.dtext,get_value=new_dir
  new_dir=fix_dir_name(trim(new_dir))
  if new_dir eq '' then begin
   widget_control,info.dtext,set_value=old_dir
   return
  endif
  if old_dir eq new_dir then return

  if ~is_dir(new_dir) then begin
   xack,'Non-existent directory: '+new_dir
   widget_control,info.dtext,set_value=old_dir
   return
  endif

  info=rep_tag_value(info,'','cur_fsel')
  self->setprop,ldir=new_dir,info=info
  self->dlist
 endif

 if bname eq 'searchstring' then self->sel_update
  
;-- refresh download list

 if bname eq 'refresh' then self->dlist,/refresh

;-- delete from download list

 if bname eq 'delete' then begin
  have_files=is_string(info.cur_fsel,cfiles)
  if have_files then begin
   for i=0,n_elements(cfiles)-1 do begin
    dfile=cfiles[i]
    self->fbreak,dfile,fdir,fname
    ans=xanswer('Delete '+fname+' from local directory?',$
                message_supp='Do not request confirmation for future deletes',$
                /suppre,/check,instruct='Delete ? ',space=1)
 
;-- delete local file, compressed copy, and cached copy

    if ans then begin
     file_delete,dfile,/quiet
     dprint,'..deleting '+dfile
     use_plotman=(self->getprop(/plotman) eq 1)
     if ~use_plotman then !show_synop.fifo->delete,dfile
    endif
   endfor
   info=rep_tag_value(info,'','cur_fsel')
   self->setprop,info=info
   self->dlist
  endif
 endif

 if (event.id eq info.flist) and have_tag(event,'clicks') then $
  if (event.clicks eq 2) then bname='plot'

;-- read header only

 if (bname eq 'head') then begin
  file_id=trim(info.cur_fsel)
  file_id=file_id[0]
  if (file_id eq '') then return

;-- check if header already read (disabled)

  header=''
  mrd_head,file_id,header,err=err
  if is_string(err) or is_blank(header) then begin
   xack,err,group=info.main
   return
  endif
 
  if is_string(header) then begin
   hbase=info.hbase
   desc=['File: '+file_id,' ']
   xpopup,[desc,header],wbase=hbase,group=info.main,tfont=info.lfont,bfont=info.bfont,$
           title='File Header Information',xsize=80
   info.hbase=hbase
   self->setprop,info=info
  endif else xack,['No header in: ',file_id],group=info.main,/info
 endif

;-- read & plot downloaded file

 if (bname eq 'plot') then begin

  use_plotman=(self->getprop(/plotman) eq 1)
  file_id=trim(info.cur_fsel[0])
  if (file_id eq '') then return

  if widget_info(info.messenger,/valid) then begin
   widget_control,info.messenger,set_uvalue='SYNOP'+file_id,timer=1
   return
  endif

  nf=n_elements(info.cur_fsel)
  if ~use_plotman then nf=1
  clobber=self->getprop(/clobber)
  for i=0,nf-1 do begin
   file_id=info.cur_fsel[i]
   rfile=file_id

;-- check if this selection already cached

   self->setprop,info=info
   data=!show_synop.fifo->get(file_id)
   status=(obj_valid(data))[0]
   if status then begin
    if have_method(data,'has_data') then begin
     status=data->has_data()
     if ~status then message,'Object is missing data.',/info
    endif
   endif
  
  ;-- if not, read it

   if ~status then begin
    class=self->get_class(file_id)
    data=obj_new(class)
    if ~obj_valid(data) then begin
     xkill,tbase
     xack,'Error creating object for - '+class,group=info.main
     continue
    endif

;-- check if sending to Prepserver

    if self->getprop(/up_prep) then begin
     self->vso_prep,data,file_id,prepped_file,status=status,cancel=cancel,err=err
     if cancel or is_string(err) then continue
     if status then begin
      rfile=prepped_file
      info=rep_tag_value(info,rfile,'cur_fsel')
      self->setprop,info=info
      self->dlist
     endif
    endif

    xtext,['Source: '+class,'Reading '+rfile+'...'],wbase=tbase,/just_reg,/center,$
         group=info.main
    xhour
    prep_widg = self->getprop(/prep_widg)
    data->read,rfile,err=err,prep_widg=prep_widg
    xkill,tbase
    if is_string(err) then begin
     if obj_valid(data) then obj_destroy,data else $
      err=[err,'File probably still downloading, or an invalid FITS file.']
     xack,err,group=info.main
     continue
    endif
   endif else message,'Re-using object from last read.',/info

;-- if using PLOTMAN, then disable channel selection options

   cancel=0b
   plot_type=trim(data->get(/plot_type))

   if plot_type eq 'utplot' then begin
    data->set,dim1_sel=~use_plotman
    data->options,cancel=cancel
   endif

   if plot_type eq 'image' then begin
    count=data->get(/count)
    cancel=count eq 0
    if count gt 0 then data->set,/limb,grid=30
   endif

   if ~cancel then begin
    self->plot_data,data,rfile
   endif

;-- don't save object if file has to be re-read when prepped.

   chk=self->do_prep(rfile,read_again=read_again)
   if ~read_again then !show_synop.fifo->set,rfile,data

  endfor
 endif

 return & end
 
;---------------------------------------------------------------------------
;-- send file to Prepserver if level 0 and software not installed

 pro show_synop::vso_prep,data,file,prepped_file,status=status,$
                       cancel=cancel,err=err
 cancel=0b & err=''
 status=0b
 if is_blank(file) then return
 if ~obj_valid(data) then return
 if ~have_method(data,'check_prep') then return
 if ~data->check_prep(file) then return
 if ~vso_prep_check() then begin
  do_read=xanswer('VSO Prepserver currently unavailable. Read and display raw file anyway?')
  if ~do_read then cancel=1b
  return
 endif

 xstatus,['Please wait.','Uploading file to VSO Prepserver for processing'],/no_dismiss,/back
 xhour
 prep_widg = self->getprop(/prep_widg)
 ldir=self->getprop(/ldir)
 vso_prep,file,ofile=prepped_file,odir=ldir,status=status,err=err,inst=inst,prep_widg=prep_widg,cancel=cancel
 xstatus,/kill,/back,/keep
 if ~status then xack,err
 return & end  

;-----------------------------------------------------------------------------
;-- main plotter

 pro show_synop::plot_data,data,file_id

 if ~obj_valid(data) then return

;-- use data's internal plot method if not using PLOTMAN

 if have_method(data,'get_plot_obj') then plot_obj = data->get_plot_obj()
 xhour
 use_plotman=(self->getprop(/plotman) eq 1)  
 if ~use_plotman then begin
  if exist(plot_obj) then plot_obj -> plot, err=err else begin
   if ~have_method(data,'plot') then err=obj_class(data)+' does not have a Plot method' else data->plot,err=err,/use_colors
  endelse
  if is_string(err) then xack,err
  return
 endif

;-- create new plotman object if not already done so

 if ~obj_valid(!show_synop.plotman_obj) then begin
  if obj_valid(!show_synop.goes_obj) then p = !show_synop.goes_obj ->get_plotman(/quiet,/nocreate)
  !show_synop.plotman_obj = obj_valid(p) ? p : obj_new('plotman')
 endif

;-- if file had to be re-prepped, then we need to replace what
;   was last saved in PLOTMAN

 chk=self->do_prep(file_id,read_again=read_again)
 replace=0b & nodup=1b
 if read_again then begin
  replace=1b & nodup=0b
 endif
 
;-- use data object plotman method if available

 ;if trim(data->get(/plot_type)) eq 'image' then desc=desc+' '+data->get(/id)+' '+data->get(/time)

 if have_method(data,'plotman') then begin
  data->plotman,plotman=!show_synop.plotman_obj,/noclone,nodup=nodup,replace=replace
  return
 endif

 desc=file_basename(file_id)
 !show_synop.plotman_obj->new_panel,desc=desc,input=exist(plot_obj) ? plot_obj : data,replace=replace,nodup=nodup,/noclone
 return & end

;--------------------------------------------------------------------------
;-- list currently downloaded files

pro show_synop::dlist,refresh=refresh,no_highlight=no_highlight

info=self->get_info()

relist=~keyword_set(refresh)
if relist then begin
 ldir=self->getprop(/ldir)
 widget_control,info.dtext,set_value=ldir
 xhour
 files=file_search(concat_dir(ldir,'*'),/test_regular,count=count)
 if count eq 0 then begin
  widget_control,info.flist,set_value='',set_uvalue=''
  return
 endif
endif else begin
 widget_control,info.flist,get_uvalue=files
endelse

widget_control,info.flist,set_value=file_basename(files),set_uvalue=files

if keyword_set(no_highlight) then return

self->fbreak,files,cdir,cnames
self->fbreak,info.cur_fsel[0],sdir,sname
sel=where(sname eq cnames,scount)
if scount eq 0 then sel=0
if sel[0] gt -1 then begin
 widget_control,info.flist,set_list_select=sel[0]
 info=rep_tag_value(info,files[sel[0]],'cur_fsel')
 self->setprop,info=info
 self->sel_update, /reset
endif

return & end

;-------------------------------------------------------------------------
;-- update selection widgets (search string, and number of files seected to display)
; if called with /reset, resets search string to blank.
pro show_synop::sel_update, reset=reset

info=self->get_info()

if keyword_set(reset) then begin
  widget_control,info.wsearchstring, set_value=''
endif else begin
  widget_control,info.wsearchstring, get_value=searchstring
  if searchstring ne '' then begin
    widget_control,info.flist,get_uvalue=files
    res = strmatch(file_basename(files), searchstring, /fold_case)
    ind = where (res, count)
    if count gt 0 then begin
     widget_control, info.flist, set_list_select=ind
     info=rep_tag_value(info,files[ind],'cur_fsel')
     self->setprop,info=info
    endif else message, 'No files match search string.', /cont
  endif
endelse

; how many files are selected in flist list?
sel_index=widget_selected(info.flist,/index)
widget_control, info.wnsel, set_value=trim(n_elements(sel_index)) + ' selected'
  
end

;-------------------------------------------------------------------------
;-- sort output

function show_synop::sort,fnames,times

sort_mode=self->getprop(/sort_mode) < 2

sorder=0
if (n_elements(fnames) gt 1) then begin
 if sort_mode eq 0 then sorder=bsort(fnames) else $
  sorder=bsort(times,reverse=sort_mode eq 1)
endif

return,sorder & end

;-------------------------------------------------------------------------
;-- list data archive

pro show_synop::slist,reload=reload,quiet=quiet,count=count,_ref_extra=extra,$
                      no_check=no_check

;-- initialize

info=self->get_info()

;-- start listing

verbose=~keyword_set(quiet)
old_cache=self->getprop(/cache)
old_round=self->getprop(/round)
if keyword_set(reload) then self->setprop,cache=0

if verbose then $
 xtext,'Please wait. Searching for remote files...',wbase=tbase,/just_reg,/center,$
        group=info.main

site=self->getprop(/site)
self->setprop,round=0b
xhour

if ~keyword_set(no_check) then begin

;-- check if site requires time rounding or caching 

 sobj=obj_new(site)

 if have_method(sobj,'getprop') then begin
  no_cache=fix(sobj->getprop(/no_cache))
  if no_cache eq 1 then self->setprop,cache=0
 endif

 if obj_isa(sobj,'site') then begin
  round=sobj->getprop(/round)
  if is_byte(round) then self->setprop,round=round
 endif

 obj_destroy,sobj
endif

self->list,files,sizes=sizes,times=times,count=count,cats=cats,stimes=stimes,err=err,_extra=extra

if is_string(err) then message,err,/info
self->setprop,cache=old_cache
self->setprop,round=old_round

xkill,tbase

if count eq 0 then begin
 names=self->list_sites(abbr)
 chk=where(site eq abbr,scount)
 if scount gt 0 then begin
  no_files=names[chk[0]]
  no_files='No files matching '+no_files+' during specified time range.'
 endif else no_files='No matching files during specified time range.'
 widget_control,info.slist,set_value=no_files
 widget_control,info.slist,set_uvalue=''
 widget_control,info.slist2,set_uvalue=''
 return
endif

;-- format output

fnames=file_basename(files)
;mcat=str_cut(cats,20,pad=22)
fcat=str_cut(fnames,40,pad=40)
fdata=temporary(fcat)+'   '+temporary(stimes)+'      '+temporary(cats)+'    '+temporary(sizes)

;-- display output

self->display,fdata,files,fnames,times

return & end

;-------------------------------------------------------------------------
;-- display list output

pro show_synop::display,fdata,files,fnames,times

info=self->get_info()
sorder=self->sort(fnames,times)
widget_control,info.slist,set_value=fdata[sorder]
widget_control,info.slist,set_uvalue=files[sorder]
widget_control,info.slist2,set_uvalue={fdata:fdata[sorder],fnames:fnames[sorder],times:times[sorder]}

chk=where(info.cur_sel[0] eq files[sorder],count)
if count gt 0 then widget_control,info.slist,set_list_select=chk[0]

return & end

;---------------------------------------------------------------------------
;-- widget cleanup

pro show_synop_cleanup,id

dprint,'% show_synop_cleanup...'

widget_control,id,get_uvalue=object

if obj_valid(object) then begin
 info=object->get_info()
 if is_struct(info) then begin
  xtext_reset,info
  obj_destroy,object
 endif
endif
return & end

;----------------------------------------------------------------------------
;-- object cleanup

pro show_synop::cleanup

dprint,'% show_synop::cleanup...'

info=self->get_info()
if ~is_struct(info) then return

props=self->getprop(/all_props)

;-- clean up GOES files

if obj_valid(!show_synop.goes_obj) then !show_synop.goes_obj->flush,2

;-- save some useful configuration info

ptags=tag_names(props)
for i=0,n_tags(props)-1 do begin
 type=size(props.(i),/tname)
 if (type eq 'POINTER') or (type eq 'OBJREF') then $
  rtags=append_arr(rtags,ptags[i])
endfor

;if have_tag(props,'plotman') then rtags=append_arr(rtags,'plotman')
props=rem_tag(props,rtags)

props=rep_tag_value(props,info.cur_fsel,'cur_fsel')
props=rep_tag_value(props,self->getprop(/ldir),'ldir')
self->fbreak,info.config_file,fdir
if write_dir(fdir,/quiet) then begin
 message,'saving configuration to - '+info.config_file,/info
 save,file=info.config_file,props
endif

self->site::cleanup

ptr_free,self.ptr
xkill,'show_synop::setup'

return & end

;--------------------------------------------------------------------------
;-- display site info based on filename

pro show_synop::file_info,file

if ~is_string(file) then return

xhour
desc=['File: '+file_break(file),'']
sock_fits,file,header=header,/nodata,err=err,/no_badheader
if is_string(err) then desc=[desc,err] else desc=[desc,header]

;-- create pop-up

info=self->get_info()
tbase=info.tbase
xpopup,desc,wbase=tbase,group=info.main,tfont=info.lfont,bfont=info.bfont,$
            xsize=80,title='Remote File Information'
info.tbase=tbase
self->setprop,info=info

return
end

;---------------------------------------------------------------------------                 
;-- copy remote files                                                                        
                                                                                             
pro show_synop::rcopy,rfiles,ofiles,count=count,err=err,cancel=cancel,$                      
                 _ref_extra=extra
                                                                                             
;-- rfiles = remote files to copy                                                                    
;-- ofiles = actual files copied                                                             

ofiles='' & count=0 & err=''
down_prep=self->getprop(/down_prep)
rcount=n_elements(rfiles)
clobber=self->getprop(/clobber)                                                              
progress=self->getprop(/progress)
ldir=self->getprop(/ldir)
prep_widg=self->getprop(/prep_widg)                                                             
info=self->get_info()

for i=0,rcount-1 do begin
 do_prep=0b & do_down=1b & cancel=0b & status=0

 if down_prep then begin
  do_prep=1b
  nfile=concat_dir(ldir,'prepped_'+file_basename(rfiles[i]))
  if ~clobber and file_test(nfile) then begin
   xtext,'Prepped file: '+nfile+' already exists.',/center,/just_reg,wait=2
   do_prep=0b & status=2 & do_down=0b
  endif

  if status ne 2 then do_prep=self->do_prep(rfiles[i])
  if do_prep then begin
   if ~vso_prep_check() then begin
    do_down=xanswer('VSO Prepserver currently unavailable. Download raw file anyway?')
    if ~do_down then cancel=1b
    do_prep=0b
   endif
  endif

  if do_prep then begin
   xstatus,['Please wait.','Sending file to VSO Prepserver for processing'],/no_dismiss,/back
   xhour
   det=self->get_class(rfiles[i])
   vso_prep,rfiles[i],inst=det,ofile=nfile,odir=ldir,prep_widg=prep_widg,status=status,err=err
   xstatus,/kill,/back,/keep
   do_down=0b
  endif
 endif

 if do_down then begin
  if ~progress then xtext,'Please wait. Downloading '+trim(file_basename(rfiles[i]))+'...',wbase=tbase,/center,group=info.main,/just_reg
  sock_copy,rfiles[i],out_dir=ldir,_extra=extra,err=err,local_file=nfile,$
            cancel=cancel,clobber=clobber,progress=(i eq 0) && progress,$
            status=status,/verbose,/no_check
  xkill,tbase
 endif

 if status eq 2 then begin
  xack,['Requested file has already been downloaded.',$
        'Check "Overwrite" option in "Configure" menu to re-download.'],/suppress
 endif
 
 if is_string(err) then status=0
 if ~cancel and (status gt 0) then tfiles=append_arr(tfiles,nfile,/no_copy)
endfor                                                                                       
                                                                                             
count=n_elements(tfiles)                                                                     
if count gt 0 then ofiles=temporary(tfiles)                                                  
                                                                                             
return & end                                                                                 
        
;------------------------------------------------------------------------------              
                                                                                             
pro show_synop::apply,event                                                                       
                                                                                             
xkill,event.top                                                                              
                                                                                             
return & end                                                                                 
               
;----------------------------------------------------------------------------
;-- object event handler. Since actual methods cannot be
;   event-handlers, we shunt events thru this wrapper.
;   We use the base UNAME to identify which event method to invoke.

pro show_synop_main,event

if ~is_struct(event) then return
widget_control,event.top,get_uvalue=object
if ~obj_valid(object) then return
uname=widget_info(event.top,/uname)
if is_blank(uname) then return
call_method,uname,object,event

return & end
                                                                              
;----------------------------------------------------------------------------                
;-- widget base setup                                                                        
                                                                                             
pro show_synop::config_create,group=group

progress=self->getprop(/progress)                                                                                             
clobber=self->getprop(/clobber)                                                              
cache=self->getprop(/cache)                                                                  
ldir=self->getprop(/ldir)                                                                    
last_time=self->getprop(/last_time)                                                          
plotman=self->getprop(/plotman)
down_prep=self->getprop(/down_prep)                             
up_prep=self->getprop(/up_prep)
prep_widg=self->getprop(/prep_widg)                             
save_config={clobber:clobber,progress:progress,cache:cache,ldir:ldir,$                                         
             last_time:last_time,plotman:plotman,up_prep:up_prep,down_prep:down_prep, $
             prep_widg:prep_widg}                            
      
mk_dfont,bfont=bfont,lfont=lfont                                                             
base=widget_mbase(/column,title="SHOW_SYNOP OPTIONS",group=group,uname='config',uvalue=self)
                                                                                             
 ;-- save time interval                                                                       
                                                                                             
base1=widget_base(base,/column,/frame)                                                       
                                                                                             
trow=widget_base(base1,/row)                                                                 
xmenu2,['Yes','No'],trow,/row,/exclusive,font=lfont,/no_rel,$                                
       buttons=tbuttons,uvalue=['yes_save','no_save'],$                                       
       title='Save last search time interval? ',lfont=lfont                                   
widget_control,tbuttons[1-last_time],/set_button                                             
                                     
;-- use caching                                                                              
                                                                                             
crow=widget_base(base1,/row)    
col1=widget_base(crow,/column)
                                                             
xmenu2,['Yes','No'],col1,/row,/exclusive,font=lfont,/no_rel,$                                
      buttons=sbuttons,uvalue=['yes_cache','no_cache'],$                                     
      title='Cache search results (recommended for speed)? ',lfont=lfont                     
widget_control,sbuttons[1-cache],/set_button                                                 
        
col2=widget_base(crow,/column)                                                                 
cbutt=widget_button(col2,value='Clear current cache',uvalue='clear',font=lfont)
                                                                                     
;-- clobber data?                                                                            
                                                                                             
row3=widget_base(base1,/row)                                                                 
xmenu2,['Yes','No'],row3,/row,/exclusive,font=lfont,/no_rel,$                                
      buttons=cbuttons,uvalue=['yes_clobber','no_clobber'],$                                 
      title='Overwrite existing files when downloading or prepping? ',lfont=lfont                        
widget_control,cbuttons[1-clobber],/set_button                                               

;-- show progress bar?                                                                            
                                                                                             
row3=widget_base(base1,/row)                                                                 
xmenu2,['Yes','No'],row3,/row,/exclusive,font=lfont,/no_rel,$                                
      buttons=cbuttons,uvalue=['yes_progress','no_progress'],$                                 
      title='Show progress bar when downloading ? (can slow things down) ',lfont=lfont                        
widget_control,cbuttons[1-progress],/set_button                                               

;-- Send to VSO_PREP before downloading?

;row4=widget_base(base1,/row)                                                                
;xmenu2,['Yes','No'],row4,/row,/exclusive,font=lfont,/no_rel,$                               
;       buttons=vbuttons,uvalue=['yes_down_prep','no_down_prep'],$                                
;       title='Send remote file to VSO Prepserver before downloading?',lfont=lfont                                        
;down_prep = 0b > down_prep < 1b
;widget_control,vbuttons[1-down_prep],/set_button                                              

;-- Unpload to VSO_PREP?

;row4=widget_base(base1,/row)                                                                
;xmenu2,['Yes','No'],row4,/row,/exclusive,font=lfont,/no_rel,$                               
;       buttons=vbuttons,uvalue=['yes_up_prep','no_up_prep'],$                                
;       title='Upload local file to VSO Prepserver when displaying (if instrument software not loaded)? ',lfont=lfont                                        
;up_prep = 0b > up_prep < 1b
;widget_control,vbuttons[1-up_prep],/set_button                                              
                                                                                             
;-- use PLOTMAN?                                                                             
                                                                    
if have_proc('plotman__define') then begin               
 row5=widget_base(base1,/row)                                                                
 xmenu2,['Yes','No'],row5,/row,/exclusive,font=lfont,/no_rel,$                               
       buttons=cbuttons,uvalue=['yes_plotman','no_plotman'],$                                
       title='Use PLOTMAN for plotting? ',lfont=lfont                                        
 plotman = 0b > plotman < 1b
 widget_control,cbuttons[1-plotman],/set_button                                              
endif                                                                                        
                                               
;row6=widget_base(base1,/row)                                                                
;xmenu2,['Yes','No'],row6,/row,/exclusive,font=lfont,/no_rel,$                               
;       buttons=obuttons,uvalue=['yes_prep_opts','no_prep_opts'],$                                
;       title='Allow selection of instrument prep options? ',lfont=lfont                                        
;prep_widg = 0b > prep_widg < 1b
;widget_control,obuttons[1-prep_widg],/set_button                                         

row0=widget_base(base,/row,/align_center)                                                    
                                                                                             
doneb=widget_button(row0,value='Apply',uvalue='apply',$                                      
       font=bfont,/frame)                                                                    
cancb=widget_button(row0,value='Cancel',uvalue='cancel',$                                    
       font=bfont,/frame)                                                                    
                                                                                             
;-- share widget id's thru child's uvalue                                                    
                                                                                             
child=widget_info(base,/child)                                                               
widget_control,child,set_uvalue=save_config                                                         
                                                                                             
xrealize,base

xmanager,'show_synop::config_create',base,event='show_synop_main',/modal                                            
                                                                                             
return & end                                                                                 
                                                                                             
;----------------------------------------------------------------------------                
                                                                                             
pro show_synop::config,event                                                                 
                                                                                             
widget_control,event.id,get_uvalue=uvalue                                                    
widget_control,event.top,get_uvalue=self                                                     
child=widget_info(event.top,/child)                                                          
widget_control,child,get_uvalue=save_config                                                         
              
tvalue=trim(uvalue[0])                                                                       
  
case tvalue of                                                                               
      
 'yes_clobber': self->setprop,clobber=1                                                      
 'no_clobber': self->setprop,clobber=0                                                       

 'yes_progress': self->setprop,progress=1                                                      
 'no_progress': self->setprop,progress=0                                                       
                                                                                             
 'yes_cache': self->setprop,cache=1                                                          
 'no_cache': self->setprop,cache=0                                                           
      
 'yes_plotman': self->setprop,plotman=1                                                      
 'no_plotman': self->setprop,plotman=0                                                       

 'yes_up_prep': self->setprop,up_prep=1                                                      
 'no_up_prep': self->setprop,up_prep=0                                                       

 'yes_down_prep': self->setprop,down_prep=1                                                      
 'no_down_prep': self->setprop,down_prep=0                                                       
                                                                                             
 'yes_save': self->setprop,last_time=1                                                       
 'no_save': self->setprop,last_time=0                                                        
      
 'yes_prep_opts': self->setprop,prep_widg=1
 'no_prep_opts':  self->setprop,prep_widg=0                                                            
                                                                                             
 'apply':xkill,event.top                                                                     
      
 'clear': self->list_cache,/clear
                                                                                       
 'cancel': begin                                                                             
   struct_assign,save_config,self,/nozero                                               
   xkill,event.top                                                                           
  end                                                                                        
                                                                                             
 else: return                                                                                
endcase                                                                                      
                                                                                             
return & end                                                                                 
              
;----------------------------------------------------------------------------
;-- create unique cache id for storing search results
                                                                               
function show_synop::get_cache_id                                                   
                                                                               
site=self->getprop(/site)                                                      
round=self->getprop(/round)                                                    
cache_id=site+'_'+trim(round)
return, cache_id                                                               
                                                                               
end                

;----------------------------------------------------------------------------
;-- event handler for GOES lightcurve plots

pro plot_goes_eh,event

widget_control,event.top,get_uvalue=self
widget_control,event.id, get_uvalue=uvalue
if ~exist(uvalue) then uvalue=''
bname=''
if is_string(uvalue) then bname=trim(uvalue[0])
info=self->get_info()

;-- catch any errors

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 if is_string(err) then message,err,/info
 message,/reset
 return
endif

;-- create GOES lightcurve object

if ~obj_valid(!show_synop.goes_obj) then !show_synop.goes_obj=obj_new('goes')

goes=!show_synop.goes_obj
; if plotman obj already created, this will share it. If not, goes will make one.
!show_synop.goes_obj -> set, plotman_obj = !show_synop.plotman_obj

;-- clear sub-intervals

if bname eq 'del_interval' then begin
 self -> clear_intervals
 widget_control, info.subint, set_value='# Sub-intervals: 0'
 return
end

;-- get and set GOES times

tstart=self->getprop(/tstart)
tend=self->getprop(/tend)
goes->set,tstart=tstart, tend=tend

;-- GOES workbench

if (bname eq 'plot') then begin
 if xregistered('goes') eq 0 then goes->gui
 return
endif

;-- check for GOES data

goes->read,err=err,/verbose,status=status
if is_string(err) then begin
 xack,[err,'Use GOES GUI to select different satellite.']
 if xregistered('goes') eq 0 then goes->gui
 return
endif

case bname of

;-- sub-interval selection

 'sel_interval': begin

  ; plot goes data for time interval, and let user select sub-intervals
  ; for data search

  int=self->get_intervals(count=c)
  if c gt 0 then intervals = anytim2utc(int,/vms)
  goes->plotman
  intervals = goes -> select_intervals (intervals=intervals, $
   title='Select Sub-intervals for Search',/modal,group=info.main)

  ; if no intervals were selected, intervals[0] = -1
  ; if cancel from selection, intervals[0]=-99, so do nothing

  if intervals[0] ne -99 then begin
   n_int = n_elements(intervals)
   if n_int gt 1 then self->setprop,intervals=anytim(intervals,/tai) $
    else self->clear_intervals
   widget_control, info.subint, set_value='# Sub-intervals: '+trim(n_int / 2)
  endif
 end

 'show_interval': begin
  int=self->get_intervals(count=c)
  intervals = c gt 0 ? anytim(anytim2utc(int, /vms), /sec) : -1
  if (c gt 0) then goes->plotman
  goes -> show_intervals, intervals=intervals, $
   type='Search Sub-interval', /widget
  end

 else: message,'No option selected',/info
endcase

return & end


;------------------------------------------------------------------------------
;-- SHOW_SYNOP definition

pro show_synop__define

self={show_synop,sort_mode:0,ptr:ptr_new(),clobber:0b,progress:0b,$
      plotman:0,down_prep:0b,up_prep:0b,prep_widg: 0b,$
      ldir:'',inherits site, inherits synop_inst}

return & end      
