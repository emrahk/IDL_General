;+
; Project - HESSI
;
; Name        : AIA_CUTOUT__DEFINE
;
; Purpose     : Define an SDO/AIA cutout data object
; 
; Method      : Access the database of AIA cutout FITS files made for each RHESSI
;               flare interval.  Used in SHOW_SYNOP. User selects a time interval,
;               and selects remote site = SDO/AIA cutouts, and click search, a window
;               will pop up allowing them to select the directory (corresponding to 
;               RHESSI flare time) and AIA wavelength.  Then show_synop proceeds as usual
;               displaying the files available for that dir and wave, and the user can
;               choose which ones to download and display. 
;               
;               We use the inherited site class to find the directories of AIA cutouts
;               within the specified times, and use a second interal site object (site2)
;               to find the files in that directory.
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('aia_cutout')
;
; History     : Written 15-Feb-2013, Kim Tolbert
;
; Contact     : kim.tolbert@nasa.gov
; Modifications:
; 1-Aug-2013, Kim. Added /tai to parse_time call in search (needed for caching in show_synop)
; 2-Aug-2013, Kim. Added no_cache to properties, and init to 1, so full list will appear on search in show_synop
; 9-Jun-2014, Kim. Previously aia_cutout fits files were organized in directories by year/month/hsi_flare_yyyymmdd_hhmmss where
;   the time was the beginning of the RHESSI flare.  Now they are in year/month/day/yyyymmdd_hhmm-hhmm directories that 
;   indicate the range of times contained in the directory.  Changed init and search to reflect this, and added dir2time
;   method to convert the directory name to a time range.
; 10-Jun-2014,Kim. Fixed reform bug in search, and in select print to screen names of directories for users who are connected
;   to hesperia and want to change show_synop directory to a hesperia directory instead of downloading cutout files.
;-

function aia_cutout::init,_ref_extra=extra

if ~self->aia::init(_extra=extra) then return,0
if ~self->site::init(_extra=extra) then return, 0

rhost = 'hesperia.gsfc.nasa.gov'
self->setprop, rhost=rhost, ext='', org='day', $
  topdir='/sdo/aia',/full, delim='/'
  
self.site2 = obj_new('site')
self.site2->setprop, rhost='hesperia.gsfc.nasa.gov',ext='fts',org='none',delim='/'
self.no_cache=1b 
  
return,1 & end

;---------------------------------------------------

pro aia_cutout::cleanup
destroy, self.site2
end

;---------------------------------------------------

function aia_cutout::search,tstart,tend,count=count,times=times,err=err,_ref_extra=extra

err = ''
cancel = 0

; use inherited site search to find directories within tstart to tend expanded by 2 hours in each direction
urls = self->site::search(tstart-7200.d,tend+7200.d,inst='aia',count=nurls,_extra=extra)

; Narrow down the directories to those that overlap requested times
if nurls gt 0 then begin
  dir_times = self->dir2time(dir=urls)
  if n_elements(dir_times) eq 2 then dir_times = reform(dir_times,2,1)
  q = where(dir_times[1,*] gt tstart and dir_times[0,*] lt tend, count)
  if count gt 0 then begin
    nurls = count
    urls = urls[q]
  endif else nurls = 0
endif

; pop up widget for user to select dir and wave
count = 0 
if nurls gt 0 then files = self->select(urls, count=count, cancel=cancel, _extra=extra)
if cancel then return, -1

; This is not operational.  Could add question to selection widget to set show_synop directory to
; directory on hesperia for users who are connected to hesperia, and if they say yes, set_dir will be 1
set_dir = 0
if set_dir then begin
  show_synop = get_objref('show_synop')
  dir = str_replace(urls,'http://hesperia.gsfc.nasa.gov','\\hesperia\data')
  show_synop->setprop, ldir=dir
  info = show_synop->get_info()
  widget_control, info.dtext, set_value=show_synop->getprop(/ldir)
  show_synop->dlist
  widget_control,info.wsearchstring, set_value='*_171_*'
  show_synop->sel_update
endif

if count gt 0 then begin
  times = self->parse_time(files, /tai)
  return, files
endif else begin
  err = 'No files found.'
  return, -1
endelse

end

;---------------------------------------------------

function aia_cutout::dir2time, dir=indir

dir = file_basename(indir)
ndir = n_elements(dir)

for ii=0,ndir-1 do begin
  if ~stregex(dir[ii], '[0-9]{8}_[0-9]{4}-[0-9]{4}', /bool) then begin
    message,/cont,'Invalid directory: ' + dir[ii] + '. Directories must be of form yyyymmdd_hhmm-hhmm'
    return, -1
  endif
endfor

stime = file2time(dir, out_style='sec')
end_hm = ssw_strsplit(dir, '-', /tail)
end_hm = strmid(end_hm,0,2) + ':' + strmid(end_hm,2,2) + ':00'
etime = anytim(stime,/date) + anytim(end_hm)
q = where(etime lt stime, count)
if count gt 0 then etime[q] = etime[q] + 86400.d0
dir_times = ndir eq 1 ? [stime,etime] : transpose([[stime],[etime]])
return, anytim(dir_times,/tai)
end


;---------------------------------------------------

; select method pops up a widget with two selection lists, one for directory (which
; corresponds to RHESSI flare), and one for AIA wavelengths.  User can choose one or
; multiple of each.  Returns file names matching those selections. 
function aia_cutout::select, urls, count=count, cancel=cancel, _ref_extra=extra

count = 0
files = ''
err = 'No files found.'
cancel = 0

waves = trim([94,131,171,193,211,304,335,1600,1700,4500])
; Return directory choice(s) as index, and wavelength choice(s) as string
ind = xsel_list_multi(file_basename(urls), /index, cancel=cancel, $
  title='Select AIA directories and wavelengths', $
  label='Select AIA cutout directories (named by time range contained in dir):', $
  n2_items=waves, n2_label='Select wavelength(s):',n2_initial=1, n2_item_sel=n2_item_sel)
if cancel then begin
  err = 'Operation Cancelled.'
  return, ''
endif

print,' '
message, /cont, 'If you are running on hesperia itself, or on a PC with hesperia mounted, you may want to cut and paste the'
print, '                      directory selected (just one) into the show_synop folder selection instead of downloading the cutout files.'

print,' '
print, 'Directory names if running on hesperia: '
hesp_dir = fix_slash(str_replace(urls[ind],'http://hesperia.gsfc.nasa.gov/','/data/'))
for i=0,n_elements(ind)-1 do print, hesp_dir[i]

print,' '
print,'Directory names if running on a PC with hesperia mounted: '
hesp_pc_dir = fix_slash(str_replace(urls[ind],'http://hesperia.gsfc.nasa.gov/','\\hesperia\data\'))
for i=0,n_elements(ind)-1 do print, hesp_pc_dir[i]
print,' '

; Now use internal site object to search for files within times specified in the directories chosen
tstart = self->getprop(/tstart)
tend = self->getprop(/tend)
for i=0,n_elements(ind)-1 do begin
  url_struct = parse_url(urls[ind[i]])  
  self.site2->setprop, topdir='/'+url_struct.path
  file=self.site2->search(tstart,tend, count=nf, _extra=extra)
  if nf gt 0 then files = [files, temporary(file)]
endfor

; Then select among those files for wavelengths chosen
if n_elements(files) eq 1 then return, ''
chk_waves = arr2str('_' + n2_item_sel + '_', '|')
chk = where(stregex(files, chk_waves, /bool), count)
if count gt 0 then begin
  err = ''
  return, files[chk]
endif

return, ''

end
;---------------------------------------------------

;pro aia_cutout::select_widget, urls

;---------------------------------------------------

;function site::parse_time,input,_ref_extra=extra
;
;return,parse_time(file_basename(input),_extra=extra)
;
;end

pro aia_cutout__define,void                 

void={aia_cutout, no_cache:0b, site2: obj_new(), inherits aia, inherits site}

return & end
