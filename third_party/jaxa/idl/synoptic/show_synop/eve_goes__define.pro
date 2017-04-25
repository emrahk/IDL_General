;+
; Project     : SDO
;
; Name        : EVE_GOES__DEFINE
;
; Purpose     : Class definition for SDO/EVE GOES Proxy data
; 
; Method      : For user-specified time interval, locates, downloads, and reads the EVE daily text 
;  files containing data that mimics the 2 GOES channels from LASP and returns a structure with times
;  and lo, hi channel.  These files are daily files and have 1-min time resolution. 
;
; Methods:
;   data=e->getdata()
;   e->plot
;   e->plotman
;   
; Input:
;   User sets time interval via tstart and tend keywords (to init, set, or getdata method)
;   
; Output:
;   The getdata method returns a structure containing
;     time - array of times (in TAI format, seconds since 1/1/1958)
;     lo - low channel (like the 1.0-8.0 A GOES channel)
;     hi - high channel (like the .5-4.0 A GOES channel)
; 
; Example:
;   e = obj_new('eve_goes')
;   e->set, tstart='7-may-2012 02:00', tend='7-may-2012 14:00'
;   data = e->getdata()
;
;
; Category    : Objects
;
; Written     : 16-May-2012, Kim Tolbert
; Modifications:
;  24-Aug-2012,Kim. Remove /use_network from call to site::search.  It's the default now.
;  27-Aug-2012, Kim. Use /use_network on search and getfile until DMZ straightens it out
;  01-Nov-2013, Kim. In getdata, initialize time_save in case no files were copied
; 
;-

function eve_goes::init, _ref_extra=extra

self.data = ptr_new(-1)

self.site=obj_new('site', rhost='http://lasp.colorado.edu',delim='/',/full,$
      org='year',topdir='/eve/data_access/quicklook/quicklook_data/L0CS/SpWx',ftype='',ext='txt')
if keyword_set(extra) then self.site->setprop, _extra=extra

return,self->utplot::init(_extra=extra)

end

;------------------------------------------------------------------------

pro eve_goes::cleanup
ptr_free,self.data
obj_destroy,self.site
end

;------------------------------------------------------------------------

pro eve_goes::set, tstart=tstart,tend=tend, plotman_obj=plotman_obj, _ref_extra=extra

if exist(tstart) then begin
   if valid_time(tstart) then self.tstart=anytim2tai(tstart) else message, /info,'Invalid time: ' + tstart
endif
if exist(tend) then begin
   if valid_time(tend) then self.tend=anytim2tai(tend) else message, /info,'Invalid time: ' + tend
endif

if is_class(plotman_obj, 'plotman', /quiet) then begin
    if self.plotman_obj ne plotman_obj then obj_destroy, self.plotman_obj
    self.plotman_obj=plotman_obj
endif

if keyword_set(extra) then self->utplot::set,_extra=extra

end
;
;;------------------------------------------------------------------------
;

function eve_goes::get, tstart=tstart,tend=tend, plotman_obj=plotman_obj, _ref_extra=extra

if keyword_set(tstart) then return, anytim2utc(self.tstart,/vms)
if keyword_set(tend) then return, anytim2utc(self.tend,/vms)
if keyword_set(plotman_obj) then return, self.plotman_obj
if keyword_set(extra) then return,self->utplot::get(_extra=extra)

end

;------------------------------------------------------------------------
;Getdata method - returns structure of times,lo,hi for user's requested time interval

function eve_goes::getdata, _ref_extra=extra

if keyword_set(extra) then self->set,_extra=extra

; If we've already accumulated data for these times, just return what we've stored
; Otherwise, search for, download, and read files.  If more than one file, concatenate
; data.
if (self.tstart ne self.last_tstart or self.tend ne self.last_tend) then begin
  file = self->search(count=count, _extra=extra)
  *self.data = -1
  if count gt 0 then begin
    self->getfile, file, local_file=local_file, count=count, /use_network, _extra=extra
    time_save = -1  ; initialize in case no files were copied
    for i = 0,count-1 do begin
      self->read, local_file[i], data=data
      if i eq 0 then begin
        time_save = data.time
        lo_save = data.lo
        hi_save = data.hi
      endif else begin
        q = where (data.time - last_item(time_save) ge -.0005, kq)
        if kq gt 0 then begin
          time_save = [time_save, data.time]            
          lo_save = [lo_save, data.lo]
          hi_save = [hi_save, data.hi]
        endif
      endelse          
    endfor
    
    ; Only return data within user's requrested times
    q = where (time_save ge self.tstart and time_save lt self.tend, kq)
    if kq gt 0 then begin
      *self.data = {time: time_save[q], lo: lo_save[q], hi: hi_save[q]}
      self.last_tstart = self.tstart
      self.last_tend = self.tend
    endif           
  endif
endif

return, *self.data
end 
  
;------------------------------------------------------------------------
; Search method.  Returns list of URLs at remote site containing data for tstart/tend
; Input:
;  tstart, tend - start /end time in ascii or TAI (sec since 1/1/1958)
; Output:
; count - number of URLs found
; Value of function is list of URLs

function eve_goes::search,tstart,tend,_ref_extra=extra,count=count

if n_params() ge 1 then self->set,tstart=tstart
if n_params() eq 2 then self->set,tend=tend

; Use /round because files are daily, but tstart/tend may be within a day
files=self.site->search(self.tstart, self.tend, _extra=extra, count=count, /round, /use_network)
retval = ''

; Search returns both '...DIODES_1m_counts.txt' and '...DIODES_1m.txt'. Eliminate the '...counts' files.
if count gt 0 then begin
  q = where(stregex(files,'DIODES_1m.txt',/fold,/bool), count)
  if count gt 0 then retval = files[q] 
endif
return, retval
end

;------------------------------------------------------------------------
; Getfile method - ; Check if file is already local or we've already copied the URL to out_dir.  If not, 
; copy the file from the remote site to out_dir
; Input:
;  file - List of files or URLs to get
;  out_dir - directory to write to (default is curdir, or temp dir /eve
; Output:
;  local_file returns the names of the files on local system
;  err - blank string if OK
;  count - number of files copied

pro eve_goes::getfile, file, out_dir=out_dir, local_file=local_file, err=err, count=count, _extra=extra

count = 0
err = ''
local_file = ''
if is_blank(file) then begin
 err='No file name entered.'
 message,err,/info
 return
endif

file=strtrim(file,2)
nf=n_elements(file)
local_file=strarr(nf)

;-- create temp directory for download

if is_blank(out_dir) then out_dir=curdir()
if ~write_dir(out_dir,/quiet) then begin
  out_dir=concat_dir(get_temp_dir(),'eve')
  mk_dir,out_dir
endif

for i=0,nf-1 do begin
 if file_test(file[i]) then begin
   local_file[i]=file[i]
 endif else begin
;   Previously checked for local version of file then don't copy.  But might not be
;   up to date, so always copy
;   fname = concat_dir(out_dir, file_basename(file[i]))
;   if file_test(fname) then local_file[i] = fname else begin
     if is_url(file[i]) then begin
       message,'Checking for local file or downloading file...',/info
       sock_copy,file[i],out_dir=out_dir,_extra=extra,local_file=copy_file
       local_file[i]=copy_file
     endif
;   endelse
 endelse
endfor

chk=where(local_file ne '',count)
if count eq 0 then begin
 err='File not found.'
 message,err,/info
endif else local_file=local_file[chk]

; if just one file, make scalar. If multiple, then sort so they'll be in time order
if count eq 1 then local_file=local_file[0] else local_file = local_file[sort(local_file)] 
return & end

;------------------------------------------------------
; Read method.
; Input:
;  file - list of local files to read
; Output:
;  data - structure with times, lo, hi for entire input file

pro eve_goes::read, file, data=data, err=err, _ref_extra=extra

err = ''

if ~file_test(file) then begin
  err = 'File not found: ' + file
  message, /info, err
  return
endif

a = rd_tfile(file, hskip=32, 4)
date = arr2str(a[[0,2,3],0],'/')
a = a[*,1:*]
time = transpose(strmid(a[0,*],0,2) + ':' + strmid(a[0,*],2,2))

time = anytim2tai(date + ' ' +time)

lo = float(a[1,*])
hi = float(a[2,*])

data = {time: time, lo: reform(lo), hi: reform(hi)}
return & end

;------------------------------------------------------

pro eve_goes::prepare_plot, ylog=ylog, new_utplot_obj=new_utplot_obj, err=err, _ref_extra=extra

err = 0
checkvar, ylog, 1

data = self->getdata(_extra=extra)
if ~is_struct(data) then begin
  message,/info,'No data accumulated.'
  err = 1
  return
end

dim1_ids = ['EVE 1.0-8.0 A', 'EVE .5-4.0 A']
dim1_unit='Wavelength (Ang)'
data_unit = 'watts m!u-2!n'
title = 'EVE GOES Proxy 1-minute'
linecolors
self->set,xdata=data.time, ydata=[[data.lo], [data.hi]], /tai
self->set, $
       ylog=ylog, dim1_ids=dim1_ids, dim1_unit=dim1_unit,$
       id=title, dim1_color=[255,12], $
       data_unit=data_unit, /no_copy, /dim1_sel

if arg_present(new_utplot_obj) then begin
  new_utplot_obj = obj_new('utplot', data.time, ydata=[[data.lo], [data.hi]], /tai, $
    status=status, err_msg=err_msg)
  t1=trim(anytim2utc(self.tstart,/vms,/trunc))
  t2=trim(anytim2utc(self.tend,/vms,/trunc))
  desc = 'EVE GOES Proxy '+trim(t1)+' to '+trim(t2)
  new_utplot_obj -> set, $
       ylog=ylog, dim1_ids=dim1_ids, dim1_unit=dim1_unit,$
       id=title, filename=desc, $
       data_unit=data_unit, /no_copy, /dim1_sel
endif
end

;------------------------------------------------------

pro eve_goes::plot, _ref_extra=extra

self->prepare_plot, err=err, _extra=extra      
if ~err then self->utplot::plot, _extra=extra 
end

;------------------------------------------------------
 
pro eve_goes::plotman, plotman_obj=plotman_obj, _ref_extra=extra

self->prepare_plot, new_utplot_obj=new_utplot_obj, err=err, _extra=extra
if err then return

if keyword_set(plotman_obj) then self->set, plotman_obj=plotman_obj
if ~is_class(self.plotman_obj, 'plotman', /quiet) then begin
  plotman_obj = obj_new('plotman', error=err, _extra = extra)
  if err then begin
    message, /info, 'Error creating plotman object.'
    return
  endif else self.plotman_obj = plotman_obj
endif

desc = new_utplot_obj->getprop(/filename)
self.plotman_obj->new_panel, desc, /replace, input=new_utplot_obj, plot_type='utplot', _extra=extra

obj_destroy, new_utplot_obj    

end

;------------------------------------------------------

pro eve_goes__define,void                 

void={eve_goes, $
  tstart: 0.d0, $       ; start time in sec since 1/1/1958
  tend: 0.d0, $         ; end time in sec since 1/1/1958
  last_tstart: 0.d0, $  ; last tstart used in accumulation
  last_tend: 0.d0, $    ; last tend used in accumulation
  data: ptr_new(), $    ; data structure containing time, lo, hi
  site: obj_new(), $    ; site object for finding remote data files
  plotman_obj: obj_new(), $ 
  inherits utplot}

return & end
