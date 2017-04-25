;+
; Project     : HESSI
;
; Name        : GOES__DEFINE
;
; Purpose     : Define a GOES lightcurve object
;
; Category    : synoptic objects
;
; Explanation : Object to read GOES data, and return or plot the two flux channels or
;               the temperature and emission measure.  Reads either the SDAC or the
;               YOHKOH archive of GOES data.  Can be used from the command line (via
;               set, get, getdata, plot, plotman methods), or from a gui (o->gui).
;
; Syntax      : IDL> new=obj_new('goes')
;
; History     : Written 31 Dec 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
; Modifications:
;   24-Sep-2003, Zarro (GSI/GSFC) - fixed timerange plotting bug
;   21-Oct-2003, Zarro (GSI/GSFC) - fixed timeunits bug
;   17-Nov-2005, Kim Tolbert, lots of changes to enable the following:
;     1. subtracting background
;     2. cleaning glitches out of data
;     3. using either SDAC or YOHKOH archive of GOES data
;     4. calculating temperature and emission measure
;     5. adding plotman capability
;     6. adding a gui interface (in goes__gui.pro).  Access via o->gui.
;   7-Dec-2005, Kim.  In getdata, if timerange is not passed in, use
;     timerange=[tstart,tend] in case tstart,tend is a subset of data read in
;     last read operation.
;   21-Dec-2005, Kim.  Added a /yohkoh switch.  Same as sdac=0.
;   23-Dec-2005, Kim.  Speed up getdata. Also use current plot for select_background.
;     And made yohkoh the default.
;   23-Dec-2005, Zarro. Added a few calls to 'temporary'
;   9-Jan-2006, Kim.  Modified display_message to output to widget only when GUI is running
;   9-Jan-2006, Kim.  Added bkfunc and bk properties.  Got rid of avback.  Background
;     is now computed by fitting an exponential or a polynomial of order 0,1,2,or 3 to
;     the data in the background intervals, and is stored as an array vs time, not 2 numbers.
;     Also added option to compute and plot the total energy loss in flare, and the integral.
;   11-Jan-2006, Kim.  Fix disabling integration times (setting itimes to -1)
;   12-Jan-2006, Kim.  Added ps keyword to plot method to generate PostScript file
;   17-Jan-2006, Kim.  Changed update checking method.  Instead of setting an update flag
;     in set method as params are getting set, check just before new plot or getdata whether we
;     need to reread data.  This requires saving 5 params that show what was read in last time,
;     and new need_update method.
;     Got rid of search, verbose, and update properties.  Replaced get_sat method with sat2index
;     method - covers more types of input.
;   18-Jan-2006, Zarro, reconciled _ref_extr
;   20-Jan-2006, Kim.  Added lx stuff (X-ray energy loss), and added /times keyword to getdata
;   20-Jun-2006, Kim.  Times input as seconds are interpreted as UTC/TAI (rel to 1958).  Fixed
;     inconsistencies so this is true for btimes and itimes too.  Always use get(/btimes) instead
;     of self.btimes (similarly for itimes).  All times are stored in properties as TAI seconds,
;     and are converted to vms ascii format by the get method.  Note that internally, in some
;     cases, ascii times may be temporarily converted to sec since 1979, e.g.  for
;     compatibility with plotman.
;    20-Aug-2006, Zarro (ADNET/GSFC) - added check for GOES FITS files
;                                     in $GOES_FITS
;    8-Sep-2006, Kim.  Added LX (X-ray energy loss rate) to items saved in save file.
;    7-Nov-2006, Zarro (ADNET/GSFC)
;     - moved check for valid $GOES_FITS directory to RD_GOES_SDAC
;    16-Nov-2006, Zarro (ADNET/GSFC) - removed recursive read call in ::READ
;    11-Feb-2007, Zarro (ADNET/GSFC) - added .lremote property to
;                                      re-read when switching between remote=0 or 1
;    19-Apr-2007, Kim - added goes 11 to sat_times
;     6-May-2007, Zarro - fixed passing of sat_num to RD_GOES and RD_GOES_SDAC
;    12-Nov-2007, Kim. Added derivative of flux to items that can be plotted (not returned
;      separately from getdata since can be computed so easily).
;    14-Feb-2008, Kim. Added select_intervals and show_intervals methods and modifed the
;      select_xxx and show_xxx methods to use them.
;    18-Feb-2008, Zarro (ADNET/GSFC) - restored VERBOSE and STATUS keywords
;    25-Feb-2008, Kim. Added end date in show_intervals
;    26-Feb-2008, Kim.  In set, if new plotman obj is being set, destroy old one
;     5-Jul-2008, Kim.  Changed plotman calls to use new simplified version.
;    24-Jul-2008, Kim.  Added b0times, b1times to enable different background time
;      intervals for channels 0 and 1.  If btimes is set, btimes takes priority.
;      get(/bktimes) returns btimes if set as [2,n], otherwise returns 3-D array of
;      [b0times,b1times] dimensioned [2,n,2] where n is the max # of intervals in either
;      b0 or b1times.  valid_bktimes() now returns whether any of the backgrnd
;      time intervals are valid.
;    30-Jul-2008, Kim.  self.sdac can now be 0,1,2,3 - yohkoh,sdac,yohkoh-sdac, or
;      sdac-yohkoh.  Default is 2. Added sdac_used to store which archive accumulated data is.
;      from. In read, pass verbose to sdac and yohhkoh read routines so o->read,/verbose works.
;    3-Aug-2008, Zarro (ADNET) - added _extra, _ref_extras to ::output
;    7-Aug-2008, Kim.  In ::prepare_plot, When plotting subset of orig data, bad points marked
;      wrong because full time array was passed to goes_oplot, instead of subset time array.
;      Also in ::read, consolidated error messages if no data found.
;    3-Oct-2008, Kim. Added b0user,b1user for user background levels.  If set for a channel, this 
;      takes precedence over bk from time intervals. Can mix and match.  If vector, congrid is
;      used to interpolate vector to user's time interval. Set to -1 to disable.
;      Also added use_norm, norm_factors for normalizing diff sats, but not ready for use.
;    9-Oct-2008, Kim.  Set times=-1 after calling rd_goes_sdac if error
;    20-Nov-2008, Kim.  Added get_res method.  Multiply rad loss integrals by time res.
;    02-Dec-2008, Kim.  X-ray energy loss shouldn't use sum of 2 channels since they overlap.
;      Now lx is dimensioned [n,2].
;    03-Dec-2008, Kim.  Call goes_lx with time keyword so can correct dist to Sun 
;    04-Aug-2009, Kim.  Added _extra keyword to cleanup, and pass through to utplot::cleanup
;      Also, destroy new_utplot_obj in plotman method. Memory leak.
;    25-Aug-2009, Kim.  Changed y units for temp and em.meas plots. For deriv flux plots, make linear
;      and disable show_class.
;    03-Sep-2009, Kim.  Added textfile method to write text output file with channels, em, and temp.
;    01-Dec-2009, Kim. In sat_times, added goes 13, 14. In cleanup, added freeing all pointers in props.
;    27-Jan-2010, Kim. In cleanup, exclude plotman_obj from being destroyed. 
;    27-May-2010, Kim. Commented out cleaning up message in ::cleanup.
;    27-Oct-2010, Zarro (ADNET) 
;     - globally changed 'not' to '~' to future-proof against IDL version 8
;       handling negation differently for non-boolean variables.
;     - fixed memory leak by using ptr_free instead of ptr_empty
;    08-Nov-2010, Kim. Added GOES15 to ::sat_times 
;    23-Nov-2010, Kim. In ::get, make times type double to prevent confusion with anytim in utplot
;    10-Jan-2011, Kim. Added some text to readme in ::textfile (yclean is not bk-subtracted)
;    23-May-2011, Kim. Changed dates in sat_times after correcting GOES 6 files (GOES 6 didn't start in 1980)
;    06-Jun-2011, Kim. Call rd_goes with check_sdac=0 because of a change made in rd_gxd.
;    23-Jan-2012, Kim. In get_gev, if date is < 25-aug-1991, set ngdc
;    flag to read older files  
;    24-Jan-2012, Zarro (ADNET) - removed potential duplicate 'sat'
;                                 keyword in fix_keyword.
;    26-Mar-2012, Zarro (ADNET) - propagated /force to ensure
;                                 redownloading files. 
;    16-Apr-2012, Zarro (ADNET) - removed DATA from rd_goes since not used.
;    29-May-2012, Kim.  Added class_decode to get_gev method to convert class designation to float
;    10-Jun-2012, Kim.  When low or high was specified in call to plot, crashed.  Changed getdata to
;      always return a structure if struct or quick_struct (was just returning low or high) and
;      prepare_plot to only plot low or high if specified.
;    14-Jun-2012, Kim. In prepare_plot, if file_id is defined append it to the desc created by mk_file_id - 
;      to allow user to modify panel description in plotman
;    25-Jun-2012, Kim. Was losing fraction of sec in data time when inserted as seconds into gdata
;      struct which has long word for time.  Now insert in gdata struct as msec.
;    11-Oct-2012, Zarro (ADNET) - changed gdata.time from LONG to DOUBLE to support msec (LONG 
;      overflows at 25 days).
;    11-Oct-2012, Kim. Since gdata.time is now double, can save sec
;    instead of msec (original data is in sec.)
;    13-Dec-2012, Zarro (ADNET) 
;     - made default SDAC=3 to search SDAC archives before Yohkoh (which is
;       faster when Yohkoh/GOES data is missing.)
;     - passed REMOTE property as keyword to GOES readers (which
;       somehow got deleted.)
;     - moved ::SET in ::INIT to just before return to allow accepting
;       user-specified keywords to override initial values.
;    26-Dec-2012, Zarro (ADNET)
;     - moved GOES_SERVER network check to GOES reader routines,
;       to avoid duplicate checking.
;    13-Apr-2015, Kim. In get_res, if sat is > 12, then res is 2 sec, not 3.
;       Also added GOES 13 time period to sat_times list. (and started including GOES 13 in data archive)
;    
;
;-
;---------------------------------------------------------------------------

function goes::init,_ref_extra=extra

if ~self->utplot::init(_extra=extra) then return,0

recompile,'sock_goes' ; contains socket-capable version of rd_week_file
self.gdata=ptr_new(/all)
self.numstat = -1
self.tstat=ptr_new(/all)
self.stat=ptr_new(/all)
self.sdac = 3
self.clean = 1b
self.markbad = 1b
self.showclass = 1b
self.bsub = 0b
self.btimes=ptr_new(-1)
self.b0times=ptr_new(-1)
self.b1times=ptr_new(-1)
self.bfunc='0poly'
self.bfunc_options = ['0Poly', '1Poly', '2Poly', '3Poly', 'Exp']
self.b0user=ptr_new(-1)
self.b1user=ptr_new(-1)
self.itimes=[-1.d0,-1.d0]
self.abund_options = ['Coronal', 'Photospheric', 'Meyer']
self.abund = 0
self.use_norm = 0b
self.norm_factors = ptr_new(intarr(n_elements(goes_sat())) + 1.)

;-- default to start of current day

self->def_times,tstart,tend
self->set,tstart=tstart,tend=tend,_extra=extra

return,1

end

;------------------------------------------------------------------------------
;-- flush out old temp files

pro goes::flush,days

if ~is_number(days) then return

old_files=file_since(older=days,patt='g*',count=count,path=goes_temp_dir())

if count gt 0 then file_delete,old_files,/quiet

return & end

;-----------------------------------------------------------------------------
pro goes::cleanup, _extra=extra

;message,'cleaning up...',/info

;self->free_var, exclude='plotman_obj', _extra=extra

ptr_free,self.gdata, $
  self.tstat, $
  self.stat, $
  self.btimes, $
  self.b0times, $
  self.b1times, $
  self.b0user, $
  self.b1user, $
  self.norm_factors

self->flush,10
; self is goes obj, so in utplot cleanup destroys plotman obj, unless we say not to.
self->utplot::cleanup, _extra=extra, exclude='plotman_obj'

return
end

;----------------------------------------------------------------------------
;-- trap cases of missing GOES databases or network

function goes::allow_goes,err=err

; if can get to GOES directory, then that's all we need
if self->have_goes_dir() then return,1b

; otherwise, we'll need socket capability to copy data over network
if ~allow_sockets(err=err) then return,0b

return,1b

end

;---------------------------------------------------------------------------
;-- default start and end times for GOES plot

pro goes::def_times,tstart,tend

get_utc,tstart
tstart.mjd = tstart.mjd-2
tstart.time=0
tend=tstart
tend.mjd=tend.mjd+1

tstart=anytim2tai(tstart)
tend=anytim2tai(tend)

return & end

;---------------------------------------------------------------------------
;-- check whether local sdac or yohkoh data directories exist
; added sdac keyword so when trying each archive, can call it with sdac=sdac_used 30-jul-08

function goes::have_goes_dir,sdac=sdac

sdac = exist(sdac) ? sdac : self->get(/sdac)

case sdac of
  0: return, is_dir('$DIR_GEN_G81')
  1: return, is_dir('$GOES_FITS')
  else: return, (is_dir('$DIR_GEN_G81') or is_dir('$GOES_FITS'))
endcase

end

;----------------------------------------------------------------------------
;-- send progress message to user

pro goes::output,_ref_extra=extra

if self->have_goes_dir(_extra=extra) then return


;server=goes_server(network=network, _extra=extra)
;if network then $
 
output='Local GOES archives not found. Will attempt remote archive search.'

;output='Network connection currently unavailable. Checking cached lightcurves...'

message,output,/info

return & end

;---------------------------------------------------------------------------
; getdata function returns requested data or structure with everything
; timerange - time interval (subset of full interval) to return data for
; temperature - if set, return temperature
; emission - if set, return emission measure
; struct - if set, then return structure with flux, temp, em, and everything
; quick_struct - if set, then return structure with just the items that are set
;    by parameters

function goes::getdata, timerange=timerange, $
   times=times, $
   temperature=temperature, emission=emission, $
   lrad=lrad, lx=lx, integrate=integrate, bk_overlay=bk_overlay, $
   low=low, high=high, $
   struct=struct, quick_struct=quick_struct, err=err, _extra=extra

if keyword_set(extra) then self -> set, _extra=extra

self -> read, _extra=extra, err=err
if err ne '' then return, -1

ret_struct = keyword_set(struct) or keyword_set(quick_struct)

do_tem = keyword_set(temperature) or keyword_set(emission) or keyword_set(struct) or $
	keyword_set(lrad)

; ydata and tarray will be the full data and time array from the last read operation

ydata = self->get(/data)
tarray = self->get(/times)
utbase_ascii = self->get(/utbase)
utbase = anytim(utbase_ascii)

; tarray may contain a bigger interval than the currently set tstart/tend, so
; need to get the subset of data. If timerange passed in, use that interval
; instead of tstart/tend

checkvar, timerange, [self->get(/tstart), self->get(/tend)]
if valid_range(timerange,/time) then begin
   trstart = anytim(timerange[0]) - utbase
   trend =   anytim(timerange[1]) - utbase
   if long(trstart) ne min(tarray,max=maxt) or long(trend) ne maxt then begin
	   chk=where( (tarray le anytim(trend)) and (tarray ge anytim(trstart)),count)
	   if count lt 2 then begin
	      err='No lightcurve data during specified times'
	      message,err,/info
	      return, -1
	   endif
	   if (count gt 0) then begin
	      tarray=tarray[chk]
	      ydata=ydata[chk, *]
	   endif
   endif
endif

if keyword_set(times) and ~ret_struct then return, tarray

sat_num = goes_sat(self.sat,/num)

yclean = -1
bad0 = -1
bad1 = -1
tem = -1
em = -1
rad_loss = -1
rad_loss_x = -1
integrate_times = [-1.d0,-1.d0]

; Call clean even if clean flag isn't set when markbad is selected so  we'll
; have bad0 and bad1 (stat variable are only defined for sdac data, but clean_goes
; will find glitches in both yohkoh and sdac data.) Also call clean if struct
; is set, because then we want everything.

do_clean = self.clean or self.markbad or keyword_set(struct)

; yes_clean will be true if actually did clean.  Even if requested, may get error.
yes_clean = 0

if do_clean and n_elements(tarray) gt 5 then begin
  clean_goes, tarray = tarray, yarray = ydata, $
     yclean = yclean, bad0 = bad0, bad1 = bad1, numstat=self.numstat, $
     satellite=sat_num, tstat=*self.tstat, stat=*self.stat, error=error
  if error then begin
     ;only print this message if user actually asked for clean data.
     if self.clean then message, 'Error in clean_goes. Using non-cleaned data.',/info
  endif else begin
     yes_clean = 1
  endelse
endif

;if self.use_norm then begin
;  factor = (*self.norm_factors)[self.sat]
;  ydata = ydata * factor
;  if yclean[0] ne -1 then yclean = yclean * factor
;endif


yes_clean = yes_clean and self.clean

yuse = yes_clean ? yclean : ydata

; yes_bsub will be true if actually subtracted bk.  Even if requested, may get error.
yes_bsub = 0
ybsub = -1
bk = -1
if self.bsub or keyword_set(bk_overlay) then bk = self -> calc_bk(tarray+utbase, yuse)
if self.bsub then begin
	if bk[0] ne -1. then begin
		if n_elements(bk) eq 2 then begin
			yuse[*,0] = yuse[*,0] - bk[0]
			yuse[*,1] = yuse[*,1] - bk[1]
		endif else yuse = yuse - bk
		ybsub = yuse
		yes_bsub = 1
	endif
endif

if keyword_set(low) and ~ret_struct then return, yuse[*,0]
if keyword_set(high) and ~ret_struct then return, yuse[*,1]

; Now yuse incorporates clean and bsub changes if requested and possible

if do_tem then begin
   ; pass in unbackground-subtracted data (cleaned if cleaning was successful)
   goes_tem, tarray=tarray, yclean=(yes_clean? yclean : ydata), tempr=tem, emis=em, $
      savesat=sat_num, date=utbase_ascii, bkarray=bk, abund=self.abund

   if keyword_set(temperature) then yuse = tem
   if keyword_set(emission)  then yuse = em

endif

if keyword_set(integrate) then begin
	ind = [0,n_elements(tarray)-1]
	if self.itimes[0] ne -1.d0 then begin
		itimes = anytim(self->get(/itimes))
		istart = itimes[0]-utbase > min(tarray) < max(tarray)
		iend = itimes[1]-utbase < max(tarray)
		if istart ge iend then print, 'Invalid integration times.  Using full range.' else $
			ind = value_locate(tarray, [istart,iend])
	endif
	integrate_times = anytim(tarray[ind]+utbase,/vms)
endif

if keyword_set(lrad) or keyword_set(struct) then begin
	rad_loss = calc_rad_loss(em, tem*1.e6)
	if keyword_set(integrate) then begin
		if ind[0] gt 0 then rad_loss[0:ind[0]-1] = 0.
		if ind[1] lt n_elements(tarray)-1 then rad_loss[ind[1]:*] = 0.
		rad_loss = total(rad_loss,/cumulative) * self->get_res()
	endif
endif

if keyword_set(lx) or keyword_set(lrad) or keyword_set(struct) then begin
	rad_loss_x = goes_lx(yes_bsub ? ybsub : yclean, time=tarray[0]+utbase)
	if keyword_set(integrate) then begin
		if ind[0] gt 0 then rad_loss_x[0:ind[0]-1,*] = 0.
		if ind[1] lt n_elements(tarray)-1 then rad_loss_x[ind[1]:*,*] = 0.
		rad_loss_x = total(rad_loss_x, 1, /cumulative) * self->get_res()
	endif
endif

if keyword_set(struct) or keyword_set(quick_struct) then begin
   return, { $	;return everything for flux data
      utbase: utbase_ascii, $
      tarray: tarray, $
      ydata: ydata, $
      yclean: yclean, $
      ybsub: ybsub, $
      bk: bk, $
      bad0: bad0, $
      bad1: bad1, $
      tem: tem, $
      em: em, $
      lrad: rad_loss, $
      lx: rad_loss_x, $
      integrate_times: integrate_times, $
      yes_clean: yes_clean, $
      yes_bsub: yes_bsub }
endif else begin
   if keyword_set(temperature) then return, tem
   if keyword_set(emission)  then return, em
   if keyword_set(lrad) then return, rad_loss
   if keyword_set(lx) then return, rad_loss_x
   return, yuse
endelse

end

;---------------------------------------------------------------------------
; Function to calculate background
; Fit all points in all background intervals to an exponential or a polynomial of
; order 0, 1, 2, or 3.  For exponential, use polynomial of order 1 with log of data, and
; take exponential of that.
; bfunc will have values that are defined in self.bfunc_options
; ybk returned will be an array with values for each time for both channels: (ntime,2)
; 3-Oct-2008, Kim. Added user background - b0user, b1user.  First calculate bk based on
;  any bk time intervals set, then if user value is set, override with that.  If vector
;  interpolate to correct number of data points.

function goes::calc_bk, times, yuse

ybk = -1

if self->valid_bktimes() or (*self.b0user)[0] ne -1 or (*self.b1user)[0] ne -1 then begin

  ny = n_elements(yuse[*,0])
  ybk = make_array(size=size(yuse))
   
  if self->valid_bktimes() then begin
    ; default to 1st order polynomial.  Otherwise get order from first character of string.
    ; but if doing exponential, order will be 1.
    order=1
    do_poly = ~stregex(self.bfunc, 'exp', /boolean, /fold_case)
    if do_poly and stregex(self.bfunc, '^[0-3]', /boolean) then order = fix(strmid(self.bfunc,0,1))

    bktimes=anytim(self->get(/bktimes))
    sizbk = size(bktimes,/str)
    sep_ch = sizbk.n_dimensions eq 3
    nbk = sizbk.dimensions[1] > 1
  
  	for ich = 0,1 do begin
      if ich eq 0 or sep_ch then begin
        ind = -1
        for i=0, nbk-1 do begin
          if bktimes[0,i,ich] ne '' then $
            ind = [ind, where ((times ge bktimes[0,i,ich]) and (times le bktimes[1,i,ich]))]
        endfor
        ind = get_uniq(ind)	;eliminate overlap, and multiple -1's if where returned none
      endif
  
      if n_elements(ind) gt 1 then begin
  	    ind = ind[1:*]   ; get rid of leading -1
        if do_poly then begin
  	      ; polynomial fit
          ybk[*,ich] = fit_backgrnd (times-min(times), yuse[*,ich], $
  	   		                       		fltarr(ny), order, selected=ind, ltime=fltarr(ny)+1.)
        endif else begin
  	   	  ; exponential fit uses exponential of 1st order polynomial fit of log of data
          ybk[*,ich] = exp( fit_backgrnd (times-min(times), alog(yuse[*,ich]), $
  	   		                       		fltarr(ny), order, selected=ind, ltime=fltarr(ny)+1.) )
        endelse
      endif
  	endfor
  	if total(ybk) eq 0. then message,'No data in background time intervals.', /info
  
  endif
  
  ;If user bk value(s) defined then override ybk with that.  If one element, set all elements
  ; in ybk[*,ich] to that, otherwise use congrid to ensure dimensions match yuse array
  if (*self.b0user)[0] ne -1 then $
    ybk[*,0] = n_elements(*self.b0user) eq 1 ? *self.b0user : congrid(*self.b0user, ny, /interp)
  if (*self.b1user)[0] ne -1 then $
    ybk[*,1] = n_elements(*self.b1user) eq 1 ? *self.b1user : congrid(*self.b1user, ny, /interp)

endif
  
if ybk[0] eq -1 then message, 'No valid background times or user background levels are defined.', /info

return, ybk

end

;---------------------------------------------------------------------------

function goes::get,_extra=extra,data=data,low=low,high=high,$
                   times=times,utbase=utbase,no_copy=no_copy,tai=tai,secs79=secs79, $
                   tstart=tstart, tend=tend, $
                   btimes=btimes, b0times=b0times, b1times=b1times, bktimes=bktimes, $
                   b0user=b0user, b1user=b1user, use_norm=use_norm, norm_factors=norm_factors, $                   
                   itimes=itimes, sat=sat

if keyword_set(sat) then return, goes_sat(self->getprop(/sat))  ;returns GOESxx format
if keyword_set(tstart) then return, anytim2utc(self.tstart,/vms)
if keyword_set(tend) then return, anytim2utc(self.tend,/vms)
if keyword_set(btimes) then return, self->valid_btimes() ?  anytim2utc(*self.btimes,/vms) : -1
if keyword_set(b0times) then return, self->valid_b0times() ? anytim2utc(*self.b0times,/vms) : -1
if keyword_set(b1times) then return, self->valid_b1times() ? anytim2utc(*self.b1times,/vms) : -1
; /bktimes means return btimes if set, otherwise b0 and b1 times
if keyword_set(bktimes) then begin
  if self->valid_bktimes() then begin
    if self->valid_btimes() then return, anytim2utc(*self.btimes,/vms)
    ; if returning b0,b1times, force into a 3-D array [2,n,2]
    b0 = self->valid_b0times() ? anytim2utc(*self.b0times,/vms) :  ['','']
    b1 = self->valid_b1times() ? anytim2utc(*self.b1times,/vms) :  ['','']
    maxint = (n_elements(b0) > n_elements(b1) ) / 2
    bktimes = strarr(2, maxint, 2)
    bktimes[0,0,0] = b0
    bktimes[0,0,1] = b1
    return,  bktimes
  endif else return, -1
endif

if keyword_set(b0user) then return, *self.b0user
if keyword_set(b1user) then return, *self.b1user

if keyword_set(itimes) then return, self.itimes[0] eq -1 ? -1. : anytim2utc(self.itimes,/vms)

ktime=keyword_set(times) or arg_present(times)
kbase=keyword_set(utbase) or arg_present(utbase)
klow=keyword_set(low) or arg_present(low)
khigh=keyword_set(high) or arg_present(high)
kdata=keyword_set(data) or arg_present(data)

ktime2=keyword_set(times) and ~arg_present(times)
kbase2=keyword_set(utbase) and ~arg_present(utbase)
klow2=keyword_set(low) and ~arg_present(low)
khigh2=keyword_set(high) and ~arg_present(high)
kdata2=keyword_set(data) and ~arg_present(data)

utbase=self->getprop(/utbase)

if ktime or kdata or khigh or klow  then begin

 if ~self->have_gdata() then begin
  message,'No GOES data yet read in',/info
  return,''
 endif

 if ktime then begin
;  times=double( (*self.gdata).time / 1000.d0)  ;changed to double, 23-nov-2010
  times = (*self.gdata).time  ; DOUBLE, time in sec since base time
  utbase=self->getprop(/utbase)
  if keyword_set(tai) then times=temporary(times)+anytim(utbase,/tai)
  if keyword_set(secs79) then times=temporary(times)+anytim(utbase)
 endif

 if kdata or khigh or klow then begin
  if keyword_set(no_copy) then data=temporary(*self.gdata) else data=*self.gdata
  if klow or kdata then low=data.lo
  if khigh or kdata then high=data.hi
  if kdata then data=[[data.lo],[data.hi]]
 endif

endif

if ktime2 then return,times
if kbase2 then return,utbase
if klow2 then return,low
if khigh2 then return,high
if kdata2 then return,data

if is_struct(extra) then return,self->utplot::get(_extra=extra)

return,''

end

;---------------------------------------------------------------------------

function goes_valid_time_interval, times, type, value

err_msg = ''

case type of

  'Background' : begin
    if n_elements(times) ge 2 then value = anytim2tai(times) else begin
      if times[0] eq -1 or times[0] eq 0 then value = -1
    endelse
    if ~exist(value) then err_msg = 'Background time intervals should be an array of start/ends, or -1 for none.'
    end

  'Integration' : begin
    if n_elements(times) eq 2 then value = anytim2tai(times) else begin
      if times[0] eq -1 or times[0] eq 0 then value = -1
    endelse
    if ~exist(value) then err_msg = 'Integration time interval should be a single start,end, or -1 to disable.'
    end

endcase

if err_msg eq '' then return,1 else begin
  message, /info, err_msg
  return, 0
endelse

end

;---------------------------------------------------------------------------
;-- GOES set method

pro goes::set,tstart=tstart,tend=tend, $
              mode=mode,sat=sat,_extra=extra,$
              sdac=sdac, yohkoh=yohkoh, $
              clean=clean,markbad=markbad,showclass=showclass, $
              bsub=bsub,btimes=btimes,b0times=b0times,b1times=b1times,bfunc=bfunc,$
              b0user=b0user, b1user=b1user, use_norm=use_norm, norm_factors=norm_factors, $
              remote=remote,$
              itimes=itimes,abund=abund, plotman_obj=plotman_obj

;-- user can select GOES satellite by number (sat = 12), name (sat = 'GOES12'), or keyword (/goes12).  
; Store in self.sat as index 0, 1 etc. (index into array in goes_sat.pro which is in reverse order). 0 is most recent sat.
if exist(sat) then begin
   index = self->sat2index(sat)
   if index gt -1 then self.sat = index else message,'No such satellite - '+trim(sat),/info
endif
if have_tag(extra,'goe',/start,ind) then begin
   index = self->sat2index(extra)
   if index gt -1 then self.sat = index else message,'No such satellite - '+(tag_names(extra))[ind],/info
end

if is_number(remote) then self.remote=remote
if is_number(sdac) then self.sdac = sdac
if is_number(yohkoh) then self.sdac = (yohkoh eq 0)

;-- user can select time resolution mode either by number (e.g. mode=1) or keyword (e.g. /three)
if is_number(mode) then self.mode = 0>mode<2 else self.mode = self->get_mode(extra)

if is_struct(extra) then self->utplot::set,_extra=extra

if exist(tstart) then begin
   if valid_time(tstart) then self.tstart=anytim2tai(tstart) else message, /info,'Invalid time: ' + tstart
endif
if exist(tend) then begin
   if valid_time(tend) then self.tend=anytim2tai(tend) else message, /info,'Invalid time: ' + tend
endif

if is_number(clean) then self.clean = 0b > clean < 1b

if is_number(markbad) then self.markbad = 0b > markbad < 1b

if is_number(showclass) then self.showclass = 0b > showclass < 1b

if is_number(bsub) then self.bsub = 0b > bsub < 1b

if is_string(bfunc) then begin
	q = where (strpos(strlowcase(self.bfunc_options), strlowcase(bfunc)) ne -1, count)
	if count gt 0 then self.bfunc=self.bfunc_options[q[0]] else $
		message,/info,'Invalid function.'
endif

if exist(b0user) then *self.b0user = b0user
if exist(b1user) then *self.b1user = b1user

if is_number(use_norm) then self.use_norm = 0b < use_norm < 1b
if exist(norm_factors) then *self.norm_factors = norm_factors

;-- user can select abundance model either by number (e.g. abund=1) or string (abund='Photospheric')
if is_number(abund) then self.abund = 0b > abund < 2b
if is_string(abund) then begin
	q = where (strpos(strlowcase(self.abund_options),  strlowcase(abund)) ne -1, count)
	if count gt 0 then self.abund = q[0] else message, /info, 'Invalid abundance model: ' + abund
endif

if exist(btimes) then if goes_valid_time_interval(btimes, 'Background', value) then *self.btimes = value
if exist(b0times) then if goes_valid_time_interval(b0times, 'Background', value) then *self.b0times = value
if exist(b1times) then if goes_valid_time_interval(b1times, 'Background', value) then *self.b1times = value
if exist(itimes) then if goes_valid_time_interval(itimes, 'Integration', value) then self.itimes = value

if is_class(plotman_obj, 'plotman', /quiet) then begin
	if self.plotman_obj ne plotman_obj then obj_destroy, self.plotman_obj
	self.plotman_obj=plotman_obj
endif

return
end

;------------------------------------------------------------------------
;-- remove duplicate keywords

pro goes::fix_keywords,extra

if is_struct(extra) then begin
 tags=tag_names(extra)
 chk=where(stregex(tags,'goe|one|thr|fiv',/fold) ne -1,count)
 if count gt 0 then extra=rem_tag(extra,chk)
 if ~is_struct(extra) then delvarx,extra
endif

sat=self->getprop(/sat)
mode=self->getprop(/mode)
goes_res=['three_sec','one_min','five_min']
extra=add_tag(extra,1,goes_sat(sat))
extra=add_tag(extra,1,goes_res[mode])
extra=rem_tag(extra,'sat')

return & end

;---------------------------------------------------------------------------
;-- GOES plot method

pro goes::prepare_plot,tstart,tend, timerange=timerange, $
              derflux=derflux, $
              temperature=temperature, emission=emission, $
              lrad=lrad, integrate=integrate, bk_overlay=bk_overlay, $
              low=low, high=high, $
              err=err,_extra=extra,$
              file_id=file_id, new_utplot_obj=new_utplot_obj

err=''
if ~self->allow_goes(err=err) then return

struct = self -> getdata(tstart=tstart, tend=tend, timerange=timerange, $
   temperature=temperature, emission=emission, lrad=lrad, integrate=integrate, $
   bk_overlay=bk_overlay, $
   low=low, high=high, $
   _extra=extra, err=err, /quick_struct)
if err ne '' then return

title=self->title()
showclass = self -> getprop(/showclass)
markbad = self -> getprop(/markbad)
file_id = exist(file_id) ? self->mk_file_id() + ' ' + file_id : self->mk_file_id()

do_bk_plot = 0

case 1 of
   keyword_set(temperature): begin
      ydata = struct.tem
      data_unit = 'Temperature (MK)'
      label = 'Model: ' + self->get_abund_name()
      ylog = 0
      showclass = 0
      dim1_use = 0
      dim1_ids = ''
      dim1_unit = ''
      title = 'Temperature  ' + title
      ybad = get_uniq([struct.bad0,struct.bad1])
      file_id = file_id + ' Temp'
   end
   keyword_set(emission): begin
      ydata = struct.em
      data_unit = 'Emission Measure (10!u49!ncm!u-3!n)'
      label = 'Model: ' + self->get_abund_name()
      ylog = 1
      showclass = 0
      dim1_use = 0
      dim1_ids = ''
      dim1_unit = ''
      title = 'Emission Measure  ' + title
      ybad = get_uniq([struct.bad0,struct.bad1])
      file_id = file_id + ' Emis'
   end
   keyword_set(lrad): begin
      integ = keyword_set(integrate)
      ydata = [[struct.lx[*,0]], [struct.lx[*,1]], [struct.lrad]]
      data_unit = integ ? 'erg' : 'erg s!u-1!n'
      label = 'Model: ' + self->get_abund_name()
      tot_lx0 = ''
      tot_lx1 = ''
      tot_lrad = ''
      if integ then begin
      	itimes = anytim(struct.integrate_times, /vms, /time_only, /truncate)
     	  label = [label, $
     		  'Integration times: ' + itimes[0] + ' to ' + itimes[1] ]
     		tot_lx0 = ', ' + trim(max(struct.lx[*,0]),'(e9.2)') + ' erg'
        tot_lx1 = ', ' + trim(max(struct.lx[*,1]),'(e9.2)') + ' erg'     		
     		tot_lrad = ', ' + trim(max(struct.lrad),'(e9.2)') + ' erg'
      endif
      ylog = 1
      showclass = 0
      dim1_use = [0,1,2]
      dim1_ids = ['X-ray loss 1-8A'+tot_lx0,'X-ray loss .5-4A'+tot_lx1,'Total loss'+tot_lrad]
      dim1_unit = ''
      title = (integ ? 'Radiative Energy Loss ' : 'Radiative Energy Loss Rate ') + title
      ybad = get_uniq([struct.bad0,struct.bad1])
      ybad = [ [ybad], [ybad], [ybad] ]
      file_id = file_id + (integ ? ' Int Eloss' : ' Eloss')
      end
   else: begin
      do_deriv = keyword_set(derflux)
      data_unit='watts m!u-2!n'
      label = ''
      ylog = do_deriv ? 0 : 1
      if do_deriv then showclass = 0
      dim1_ids=['1.0 - 8.0 A','0.5 - 4.0 A']
      dim1_unit='Wavelength (Ang)'
      nbad = n_elements(struct.bad0) > n_elements(struct.bad1)

      do_bk_plot = keyword_set(bk_overlay) and (struct.bk[0] ne -1)
      if do_bk_plot then begin
         bk_is_single = (n_elements(struct.bk) eq 2) ; single bk value for each channel
         ny = n_elements(struct.ydata[*,0])
         ydata = [ [struct.yes_clean ? struct.yclean : struct.ydata], $
                 [ bk_is_single ? transpose(rebin(struct.bk,2,ny)) : struct.bk] ]
         dim1_use = [0,1,2,3]
         dim1_ids = [ [dim1_ids], [dim1_ids]+' Background' ]
         title = 'Flux and Background  ' + title
         ybad = lonarr(nbad,4) - 1
         ybad[0,0] = struct.bad0
         ybad[0,1] = struct.bad1
         ybad[0,2] = struct.bad0
         ybad[0,3] = struct.bad1
         file_id = file_id + ' Flux and Bk'
      endif else begin
         ydata = struct.yes_clean ? struct.yclean : struct.ydata
         ydata = struct.yes_bsub  ? struct.ybsub: ydata
         if do_deriv then begin
         	ydata[*,0] = deriv(struct.tarray, ydata[*,0])
         	ydata[*,1] = deriv(struct.tarray, ydata[*,1])
         	title='Derivative of Flux  ' + title
         	file_id = file_id + ' Deriv Flux'
         	data_unit = data_unit + ' derivative'
         endif else begin
         	title = 'Flux  ' + title
         	file_id = file_id + ' Flux'
         endelse
         dim1_use = [0,1]
         ybad = lonarr(nbad,2) - 1
         ybad[0,0] = struct.bad0
         ybad[0,1] = struct.bad1
         if keyword_set(low) or keyword_set(high) then begin
           chan = keyword_set(low) ? 0 : 1
           ydata = ydata[*,chan]
           ybad = ybad[*,chan]
           dim1_use = 0
           dim1_ids = dim1_ids[chan]
         endif
      endelse
	end
endcase

label = append_arr(label, 'GOES archive: ' + (self.sdac_used ? 'SDAC' : 'Yohkoh'))
if struct.yes_clean then label = append_arr(label, 'Cleaned')
if struct.yes_bsub and ~do_bk_plot then  label = append_arr(label, 'Background subtracted')

self->set,xdata=struct.tarray, ydata=ydata
self->set, $
       ylog=ylog, dim1_use=dim1_use, dim1_ids=dim1_ids, dim1_unit=dim1_unit,$
       label=label, id=title, $
       data_unit=data_unit, /no_copy, filename=file_id, /dim1_sel

if showclass or markbad then begin
;   tarray=self->get(/times)
   addplot_arg = {markbad: markbad, showclass:showclass, $
      tarray:struct.tarray, ydata: ydata, ybad: ybad}
   addplot_name = 'goes_oplot'
endif else addplot_name = ''

self -> utplot::set, addplot_name=addplot_name, addplot_arg=addplot_arg


if arg_present(new_utplot_obj) then begin
  new_utplot_obj = obj_new('utplot', struct.tarray, ydata, utbase=self->get(/utbase), $
    status=status, err_msg=err_msg)
  new_utplot_obj -> set, $
       ylog=ylog, dim1_use=dim1_use, dim1_ids=dim1_ids, dim1_unit=dim1_unit,$
       label=label, id=title, $
       data_unit=data_unit, /no_copy, filename=file_id, /dim1_sel
  new_utplot_obj -> set, addplot_name=addplot_name, addplot_arg=addplot_arg
endif

end

;---------------------------------------------------------------------------

; Need err_msg keyword (not err) because when called from plotman, has err_msg
; in extra already, and gets confused if there's an 'err' too
pro goes::plot, tstart, tend, timerange=timerange, err_msg=err, ps=ps, _extra=extra

;if user passed in start time as arg, but no end time, assume they want full day
if exist(tstart) and ~exist(tend) then tend = anytim2tai(tstart)+86400.

self -> prepare_plot, tstart, tend, $
   timerange=timerange, err=err, _extra=extra
if err ne '' then return

if keyword_set(ps) then begin
	savedev = !d.name
	savefont = !p.font
	tvlct,/get,r,g,b
	set_plot,'ps'
	!p.font = 0
	device, /color, bits=8, /landscape, filename='goesplot.ps'
	linecolors
	self->utplot::plot,_extra=extra,err=err,timerange=timerange, dim1_colors=[0,3,7,9], thick=2
	device,/close
	set_plot, savedev
	tvlct,r,g,b
	!p.font = savefont
endif else begin

	self->utplot::plot,_extra=extra,err=err,timerange=timerange

endelse

return & end

;---------------------------------------------------------------------------
;-- check whether have plotman software in path

function goes::have_plotman_dir

return, have_proc('plotman__define')

end

;---------------------------------------------------------------------------
;-- GOES get_plotman function method - returns plotman object reference.
; Output Keywords:
; valid - 1 if successful, 0 otherwise.

function goes::get_plotman, valid=valid, nocreate=nocreate, quiet=quiet, _extra=extra

err_msg = ''

valid = 0

if is_class(self.plotman_obj, 'PLOTMAN',/quiet) then valid = 1 else begin

	if ~keyword_set(nocreate) then begin

		; first make sure plotman directories are in path
		if self->have_plotman_dir() then begin

		   plotman_obj = obj_new('plotman', /multi_panel,  $
		                   error=err, _extra = extra)
		   if err then err_msg = 'Error creating plotman object.' else begin
		      self.plotman_obj = plotman_obj
		      valid = 1
		   endelse

		endif else begin
		   err_msg = 'Please include HESSI in your SSW IDL path if you want to use plotman.'
		endelse

		if err_msg ne '' and ~keyword_set(quiet) then self->display_message, err_msg
	endif

endelse

return, self.plotman_obj

end

;---------------------------------------------------------------------------
;-- GOES PLOTMAN method
; Previously passed the entire GOES object to plotman, but this is unnecessary.  Added new_utplot_obj
; keyword to prepare_plot - this is a utplot object only containing what plotman needs - send this to plotman.

pro goes::plotman, tstart, tend, plotman_obj=plotman_obj, desc=desc, _extra=extra

if keyword_set(plotman_obj) then self->set, plotman_obj=plotman_obj
plotman_obj = self -> get_plotman (valid=valid)
if ~valid then return

;if user passed in start time as arg, but no end time, assume they want full day
if exist(tstart) and ~exist(tend) then tend = anytim2tai(tstart)+86400.

self -> prepare_plot, tstart, tend, file_id=desc, err=err, new_utplot_obj=new_utplot_obj, _extra=extra
if err ne '' then return

;stat = plotman_obj -> setdefaults (input=new_utplot_obj, plot_type='utplot', _extra=extra)
plotman_obj->new_panel, desc, /replace, input=new_utplot_obj, plot_type='utplot', _extra=extra

obj_destroy, new_utplot_obj

end

;---------------------------------------------------------------------------
;-- GOES read method
; Stores data and times in gdata structure property.  If new tstart/tend is
; within the last full time read, and sat, sdac, and mode (resolution) didn't change,
; we return.  get_data method will handle getting the correct subset of times.

pro goes::read,tstart,tend,$
              err=err,file_id=file_id,_extra=extra,$
              force=force,verbose=verbose,status=status

err=''
if ~self->allow_goes(err=err) then return

;if user passed in start time as arg, but no end time, assume they want full day
if exist(tstart) and ~exist(tend) then tend = anytim2tai(tstart)+86400.

; set any changed parameters into the object
self->set,tstart=tstart,tend=tend,_extra=extra

; only read new data if force is set, or need_update returns 1

status=(keyword_set(force) or self->need_update())
if ~status then return

sdac=self->getprop(/sdac)
remote=self->getprop(/remote)
sat=self->getprop(/sat)

dstart=anytim2utc(self->getprop(/tstart),/vms)
dend=anytim2utc(self->getprop(/tend),/vms)

if keyword_set(verbose) then begin
 xtext,'Please wait. Reading GOES data...',wbase=tbase,/just_reg,/center
endif

self->fix_keywords,extra

sat_num = goes_sat(sat,/num) ; rd_goes_sdac wants sat num, not index (e.g. 12, not 0)

arch_order = (sdac le 1) ? sdac : ((sdac eq 2) ? [0,1] : [1,0])
narch = (sdac gt 1)

 for iarch = 0,narch do begin

   sdac_used = arch_order[iarch]
   self->output,sdac=sdac_used
   if sdac_used then begin
      rd_goes_sdac, tarray=times, yarray=data,clobber=force,$
 	    stime=dstart, etime=dend, error=error,remote=remote, $
 	    sat=sat_num, numstat=numstat, tstat=tstat, stat=stat, $
 	    err_msg=err, /sdac, base_sec=base_sec, verbose=verbose, _extra=extra
      if err eq '' and exist(times) then begin
        times = temporary(times) + base_sec
        if numstat gt 0 then tstat = temporary(tstat) + base_sec
      endif else times=-1
   endif else begin
      rd_goes,times,trange=[dstart,dend],_extra=extra,err=err,remote=remote,clobber=force,$
        type=type,gdata=gdata,sat=sat_num, verbose=verbose, check_sdac=0
   endelse
   if n_elements(times) gt 2 then break
 endfor

 sat = sat_num	; get the sat actually retrieved
 xkill,tbase
 if is_string(err) or (n_elements(times) lt 2) then begin
    err = is_string(err) ? err : 'No GOES data for specified times.'
    self->display_message, err
    return
 endif

self.sdac_used = sdac_used

tmin=times[0]
times=temporary(times)-tmin  ; now times are seconds relative to earliest time in accumulation
utbase=anytim(tmin,/vms)     ; utbase is earliest time in accumulation

if sdac_used then begin
   b = anytim(base_sec, /ints)
   if (is_number(numstat)) then begin
      self.numstat = numstat

;-- need to use ptr_free and not ptr_empty since following lines
;   overwrite with new pointer

      ptr_free, self.tstat
      ptr_free, self.stat
      self.tstat   = ptr_new(temporary(tstat)-tmin,/no_copy)  ; make relative to utbase too
      self.stat    = ptr_new(stat,/no_copy)
   endif else self.numstat = -1

   gbo_struct, gxd_data=data_ref

   gdata      = make_array(n_elements(times),value=data_ref,/nozero)
;   gdata.time = temporary(times * 1000)  ; gdata.time is LONG, so store as msec to keep precision   
   gdata.day  = b.day
   gdata.lo   = temporary(data[*,0])
   gdata.hi   = temporary(data[*,1])
   gdata=rep_tag_value(gdata,times,'time',/no_copy) ; time tag was LONG.  replace it with DBL

endif else begin

    self.numstat = -1
    ptr_empty, self.tstat
    ptr_empty, self.stat
;    gdata.time = temporary(times * 1000)  ; gdata.time is LONG, so store as msec to keep precision
    gdata=rep_tag_value(gdata,times,'time',/no_copy) ; time tag was LONG.  replace it with DBL

endelse

*self.gdata=temporary(gdata)

self->set,sat=sat,utbase=utbase

; store last accumulation parameters
self.lstart=anytim2tai(dstart)
self.lend=anytim2tai(dend)
self.lsat = self->sat2index(sat)
self.lsdac = sdac
self.lmode = self.mode  ;need to check if this mode was actually used (type from rd_goes?) ?????????
self.lremote=self->getprop(/remote)
return & end

;--------------------------------------------------------------------------
; Function to return GOES satellite index from string or number or extra structure, i.e. input
; equal to 12 or 'GOES12' or is structure with tag goes12 returns 0

function goes::sat2index, val

index = -1

input = val

if is_struct(input) then begin
   if have_tag(input,'goe',/start,ind) then begin
      gsat = (tag_names(input))[ind]
      input = stregex(gsat,'[0-9]+',/sub,/extra)
   endif
endif

number = is_number(input)

chk=where(strup(input) eq goes_sat(number=number),count)
if count gt 0 then index = chk[0]

return, index
end


;--------------------------------------------------------------------------
; Function to check whether we need to read data files again.
; If satellite, sdac/yohkoh, mode (for yohkoh) changed, or new time is not within last
; time accumulated, then return 1

function goes::need_update

if ~self->have_gdata() then return, 1

if self.sat ne self.lsat then return, 1
if self.sdac ne self.lsdac then return, 1
if self.remote ne self.lremote then return,1
if ~self.sdac and self.mode ne self.lmode then return, 1

if ~( (self.tstart ge self.lstart) and (self.tstart le self.lend) and $
       (self.tend ge self.lstart) and (self.tend le self.lend) ) then return,1

return, 0

end

;--------------------------------------------------------------------------

function goes::title

;res=['3 sec','1 min','5 min']
;return,goes_sat(self.sat)+' '+res[self.sdac_used ? 0 :self.mode]
return,goes_sat(self.sat)+' '+self->get_res(/string)

end

;--------------------------------------------------------------------------
;-- make unique identifier (for plotman panel description)

function goes::mk_file_id

t1=trim(anytim2utc(self->getprop(/tstart),/vms,/trunc))
t2=trim(anytim2utc(self->getprop(/tend),/vms,/trunc))

file_id=self->title()+' '+trim(t1)+' to '+trim(t2)

return,file_id
end

;----------------------------------------------------------------------------
;-- extract GOES mode from keyword extra

function goes::get_mode,extra

modes=['thr','one','fiv']
nmodes=n_elements(modes)
if is_struct(extra) then begin
 for i=0,nmodes-1 do if have_tag(extra,modes[i],/start) then return,i
endif

if is_string(extra) then begin
 for i=0,nmodes-1 do begin
  textra=strup(extra)
  chk=where(strpos(extra,modes[i]) eq 0,count)
  if count gt 0 then return,i
 endfor
endif

return,self.mode

end

;----------------------------------------------------------------------------
; Return resolution in seconds, or if /string is set, in a string (e.g. '3 sec')
function goes::get_res, string=string
sat = goes_sat(self.sat, /num)
hres = sat gt 12 ? 2 : 3
res = keyword_set(string) ? [trim(hres)+' sec','1 min','5 min'] : [hres,60,300.]
return, res[self.sdac_used ? 0 : self.mode]
end

;----------------------------------------------------------------------------
;-- get full string for abundance model used.  If photospheric or coronal, put chianti
;   version number in string.

function goes::get_abund_name

abund_name = self.abund_options[self.abund]
if self.abund lt 2 then abund_name = abund_name + ' (' + goes_get_chianti_version() + ')'
return, abund_name
end

;----------------------------------------------------------------------------
;-- list time range for each GOES satellite

pro goes::sat_times, out=out

out=['GOES 91 -  01-Jul-1974   to   17-Oct-1975', $
     'GOES 92 -  05-Feb-1975   to   31-Mar-1978', $
     'GOES 1  -  17-Jan-1976   to   01-Jun-1978', $
;     'GOES 2  -  01-Aug-1977   to   04-Jan-1980', $
;     'GOES 3  -  05-Jul-1978   to   04-Jan-1980', $
;     'GOES 6  -  04-Jan-1980   to   18-Aug-1994', $     
     'GOES 2  -  01-Aug-1977   to   30-Apr-1983', $
     'GOES 3  -  05-Jul-1978   to   04-Jan-1980', $
     'GOES 5  -  01-May-1983   to   30-May-1983, 01-Jul-1983  to  31-Jul-1984', $
     'GOES 6  -  02-Jun-1983   to   30-Jun-1983, 01-Aug-1984  to  18-Aug-1994', $
     'GOES 7  -  01-Jan-1994   to   03-Aug-1996', $
     'GOES 8  -  21-Mar-1996   to   18-Jun-2003', $
     'GOES 9  -  20-Mar-1996   to   24-Jul-1998', $
     'GOES 10 -  10-Jul-1998   to   01-Dec-2009', $
     'GOES 11 -  21-Jun-2006   to   11-Feb-2008', $
     'GOES 12 -  13-Dec-2002   to   08-May-2007', $
     'GOES 13 -  13-Jan-2015   to   present', $
     'GOES 14 -  02-Dec-2009   to   04-Nov-2010', $
     'GOES 15 -  01-Sep-2010   to   present' ]

prstr, out, /nomore
end

;---------------------------------------------------------------------------
;-- show properties

pro goes::help, widget=widget

out = [' ', $
	' GOES parameter values:', $
	'   Last data interval read:']
if self->have_gdata() then begin
 out = [out, '     ' + anytim2utc(self.lstart,/vms) + ' to ' + anytim2utc(self.lend,/vms)]
endif else out = [out, '     None.']

if valid_time(self.tstart) and valid_time(self.tend) then begin
 out = [out,'   Current TSTART / TEND:', $
 	'     ' + self->get(/tstart) + ' to ' + self->get(/tend)]
endif

archive = ['YOHKOH', 'SDAC', 'YOHKOH then SDAC', 'SDAC then YOHKOH']
; + 0 in following lines is to convert byte to fix, otherwise prints weird character
out = [out, $
	'   ARCHIVE: ' + archive[self.sdac], $
	'   MODE: ' + trim(self.mode), $
	'   DATA TYPE:  ' + self->title(), $
	'   NEED_UPDATE: ' + trim(self->need_update()+0), $
	'   CLEAN: ' + trim(self.clean+0), $
	'   MARKBAD: ' + trim(self.markbad+0), $
	'   SHOW CLASS: ' + trim(self.showclass+0), $
	'   SUBTRACT BACKGROUND: ' + trim(self.bsub+0), $
	'   BACKGROUND TIMES: ']
if self ->valid_bktimes() then begin
   if self->valid_btimes() then begin
      str_btimes = self->get(/btimes)
      for i=0,n_elements(str_btimes)/2-1 do $
        out = [out,'     ' + str_btimes[0,i] + ' to ' +str_btimes[1,i]]
   endif else begin
      bkout = '     Channel 0 :'
      if self->valid_b0times() then begin
        str_b0times = self->get(/b0times)
        for i=0,n_elements(str_b0times)/2-1 do $
          bkout = [bkout, '       ' + str_b0times[0,i] + ' to ' +str_b0times[1,i]]
      endif else bkout=[bkout, '       None:']
      bkout = [bkout, '     Channel 1 :']
      if self->valid_b1times() then begin
        str_b1times = self->get(/b1times)
        for i=0,n_elements(str_b1times)/2-1 do $
          bkout = [bkout, '       ' + str_b1times[0,i] + ' to ' +str_b1times[1,i]]
      endif else bkout = [bkout, '       None:']
      out = [out,bkout]
    endelse

endif else out = [out, '     None']

out = [out, '   BACKGROUND FUNCTION: ' + self.bfunc]

if self.itimes[0] eq -1 then str_itimes = 'None' else begin
	itimes = self->get(/itimes)
	str_itimes = anytim(itimes[0],/vms) + ' to ' + anytim(itimes[1],/vms)
endelse

val0 = 'None'
val1 = 'None'
if (*self.b0user)[0] ne -1 then $
  val0 = n_elements(*self.b0user) eq 1 ? trim(*self.b0user) : trim(n_elements(*self.b0user)) + ' values'
if (*self.b1user)[0] ne -1 then $
  val1 = n_elements(*self.b1user) eq 1 ? trim(*self.b1user) : trim(n_elements(*self.b1user)) + ' values'  
out = [out, '   USER BACKGROUND:', $
            '     Channel 0 : ' + val0, $
            '     Channel 1 : ' + val1]

out= [out, $
	'   INTEGRATION TIMES: ', $
	'     ' + str_itimes, $
	'   ABUNDANCE: ' + self->get_abund_name(), $
	' ']

if keyword_set(widget) then a = dialog_message (out, /info) else prstr, out, /nomore

return & end

;------------------------------------------------------------------------------
;-- have GOES data?

function goes::have_gdata,count=count

count=0l
chk=ptr_exist(self.gdata)

if chk then count=n_elements(*self.gdata)

return,chk

end

;-----------------------------------------------------------------------------------------
;-- Display message in IDL log.  If running from GUI, also display in a widget.

pro goes::display_message, msg

prstr, msg, /nomore

if xregistered('goes') gt 0 then r=dialog_message(msg)

end

;-----------------------------------------------------------------------------------------
;--  Interactive background selection using plotman intervals method
; NOTE: this is for setting btimes unless ch0 or ch1 is set, then for b0times, b1times

pro goes::select_background, _extra=extra, ch0=ch0,ch1=ch1

bins = -99

; if we want to replot with no bk sub before selecting intervals, uncomment
; these 2 lines and line below resetting bsub. But maybe best to use existing plot.
;bsub_sav = self->getprop(/bsub)
;self->plotman, bsub=0

case 1 of
  keyword_set(ch0): intervals=self->valid_b0times() ? anytim(self->get(/b0times)) : -1
  keyword_set(ch1): intervals=self->valid_b1times() ? anytim(self->get(/b1times)) : -1
  else: intervals = self->valid_btimes() ? anytim(self->get(/btimes)) : -1
endcase

chtitle = ''
if keyword_set(ch0) then chtitle=' for Channel 0'
if keyword_set(ch1) then chtitle=' for Channel 1'

bins = self -> select_intervals ( $
	intervals=intervals,$
	title='Select Time Intervals for Background' + chtitle, $
	type='Background', $
	_extra=extra)

;self -> set, bsub=bsub_sav

if bins[0] ne -99 then begin
  case 1 of
    keyword_set(ch0): self -> set, b0times=bins[0] eq -1 ? -1 : anytim(bins,/vms)
    keyword_set(ch1): self -> set, b1times=bins[0] eq -1 ? -1 : anytim(bins,/vms)
    else: self -> set, btimes=bins[0] eq -1 ? -1 : anytim(bins,/vms)
  endcase
endif

end

;-----------------------------------------------------------------------------------------
;-- Draw boundaries of background interval(s)
pro goes::show_background

if ~self->valid_bktimes() then return

bktimes = self->get(/bktimes)
q = where (bktimes ne '', count)
bktimes = reform(bktimes[q], 2, count/2)
self -> show_intervals, intervals=bktimes, type='Background'

end

;-----------------------------------------------------------------------------------------
;-- Return 1 if background intervals are defined
function goes::valid_btimes
if (n_elements(*self.btimes) gt 1) and  (*self.btimes)[0]  ne -1 then return, 1b
return, 0b
end
;-----------------------------------------------------------------------------------------
;-- Return 1 if background intervals for channel 0 are defined
function goes::valid_b0times
if (n_elements(*self.b0times) gt 1) and (*self.b0times)[0] ne -1 then return, 1b
return, 0b
end
;-----------------------------------------------------------------------------------------
function goes::valid_b1times
;-- Return 1 if background intervals for channel 1 are defined
if (n_elements(*self.b1times) gt 1) and (*self.b1times)[0] ne -1 then return, 1b
return, 0b
end
;-----------------------------------------------------------------------------------------
;-- Return 1 if any type of background intervals are defined
function goes::valid_bktimes
if self->valid_btimes() or self->valid_b0times() or self->valid_b1times() then return, 1b
return, 0b
end

;-----------------------------------------------------------------------------------------
;--  Interactive integration time selection using plotman intervals method

pro goes::select_integration_times, full_options=full_options,_extra=extra

bins = -99

intervals = (self.itimes[0] eq -1) ? -1  : anytim(self->get(/itimes))
type = 'Integration'
title='Select a Single Time Interval for Integration'

bins = self -> select_intervals ( $
	intervals=(self.itimes[0] eq -1) ? -1  : anytim(self->get(/itimes)),$
	title='Select a Single Time Interval for Integration', $
	type='Integration', $
	max_intervals=1, _extra=extra)

if bins[0] ne -99 then self -> set, itimes=bins[0] eq -1 ? -1 : anytim(bins,/vms)

end

;-----------------------------------------------------------------------------------------
;-- Draw boundaries of integration interval(s)
pro goes::show_integration_times

self -> show_intervals, intervals=self->get(/itimes), type='Integration'

end

;-----------------------------------------------------------------------------------------
;-- draw intervals on plot and print a list of intervals
pro goes::show_intervals, intervals=intervals, type=type, widget=widget

checkvar, type, ''

if intervals[0] ne -1 then begin
	plotman_obj = self -> get_plotman(valid=valid, /nocreate)
	if valid then $
		plotman_draw_int,'all',{plotman_obj:plotman_obj}, intervals=anytim(intervals), type=type
	atimes = format_intervals(intervals, /ut, /end_date)
	out = [type + ' times: ', atimes]
endif else out = 'No ' + type + ' times defined.'
prstr, out, /nomore
if keyword_set(widget) then a=dialog_message(out, /info)

end

;-----------------------------------------------------------------------------------------
;-- General plotman interval selection.
function goes::select_intervals, $
	full_options=full_options, $
	intervals=intervals, $
	title=title, $
	type=type, $
	_extra=extra

valid_range = anytim([self->get(/tstart), self->get(/tend)])

plotman_obj = self -> get_plotman(valid=valid)

if ~valid then begin
	case type of
		'Background': type_msg = ['You can select background times by setting the btimes parameter directly: ', $
			"a->set,btimes=['1-Jun-2002 07:53:39.000', '1-Jun-2002 08:34:36.000']" ]
		'Integration': type_msg = ['You can select integration times by setting the itimes parameter directly: ', $
			"a->set,itimes=['1-Jun-2002 07:53:39.000', '1-Jun-2002 08:34:36.000']" ]
		else: type_msg = ''
	endcase

	a=dialog_message (['To use the interactive methods for selecting ',$
		'time intervals, you must include HESSI in your SSW IDL path for now.', $
		'', $
		type_msg], /error)
	return, -99
endif

if keyword_set(full_options) then begin

	; use call_function because if hessi isn't in path, this won't compile
	bins = call_function (xsel_intervals,  $
	                       input_intervals=intervals, $
	                       plotman_obj=plotman_obj, $
	                       group=plotman_obj->get(/plot_base), $
	                       valid_range=valid_range, $
	                       title=title, $
	                       type=type, $
	                       /show_start, $
	                       /force, $
	                       _extra=extra )

endif else begin

    ; if there's not a utplot currently showing in plotman, plot one
	if not plotman_obj->valid_window(/ut) then self -> plotman, _extra=extra

    plotman_obj -> intervals, title=title, $
                            type=type, $
                            intervals=intervals, $
                            /show_start, $
                            /no_replot, $
                            /force, $
                            _extra=extra

    bins = plotman_obj->get( /intervals )

endelse

return, bins

end

;---------------------------------------------------------------------------
;-- Write IDL save file with everything in it.
; filename - output filename string. If not passed, and nodialog is set, then
;    output file is autonamed to idlsave_goes_yyyymmdd_hhmm.sav
; nodialog - don't prompt for filename when not provided

pro goes::savefile, filename=filename, nodialog=nodialog, _extra=extra

if keyword_set(extra) then self -> set, _extra=extra

if ~is_string(filename) then begin
	if ~keyword_set(nodialog) then begin
		filename = dialog_pickfile (path=curdir(), filter='*.sav', $
			file='idlsave_goes.sav', title = 'Select output save file name',  get_path=path)
		if filename eq '' then begin
			self->display_message,'No output file selected.  Aborting.'
			return
		endif
	endif
endif

readme = ['Variables stored in GOES save file: ', $
   '', $
   'SATELLITE - satellite: GOES 6, 7, 8, 9, 10, 11, 12...', $
   'ASCIIBASE - base time in ASCII format  	',$
   'UTBASE - base time in sec since 79/1/1,0',$
   'TARRAY - time in sec since base time     ',$
   '', $
   'YCLEAN - channels 1,2 with gain change spikes smoothed out in watts m^-2, NOT bk-subtracted',$
   '         If bk defined, subtract BK array from YCLEAN to get bk-subtracted data.', $
   '', $
   'EMIS   - Emission measure in 10^49 cm^-3', $
   '', $
   'TEMPR  - Temperature in MegaKelvin', $
   '', $
   'LRAD   - Total energy loss rate in erg s^-1', $
   'LX     - X-Ray energy loss rate in 1-8A, .5-4A in erg s^-1', $
   '', $
   'CH0_BAD - element #s that were interpolated for Chan 1',$
   'CH1_BAD - element #s that were interpolated for Chan 2', $
   '', $
   'BSUB    - If 1, then background was subtracted for calculation of EMIS, TEMPR, LRAD', $
   'BKTIMES - Background time intervals in ASCII', $
   'BFUNC   - Background function', $
   'BK      - Background in two channels in watts m^-2', $
   'B0USER  - User background for Chan 0',$
   'B1USER  - User background for Chan 1', $
   '', $
   'ABUND_MODEL - Abundance Spectral Model' ]

struct = self -> getdata(/struct)
satellite = self -> get(/sat)
asciibase = self -> getprop(/utbase)
utbase = anytim(asciibase)
abund_model = self->get_abund_name()

tarray = struct.tarray
yclean = struct.yclean
emis = struct.em
tempr = struct.tem
lrad = struct.lrad
lx = struct.lx
ch0_bad = struct.bad0
ch1_bad = struct.bad1
bsub = struct.yes_bsub
bktimes = self->valid_bktimes() ? self->get(/bktimes) : ''
bfunc = self.bfunc
bk = struct.bk
b0user = *self.b0user
b1user = *self.b1user

; if still no filename defined, autoname it (don't do this farther up because
; until we call getdata, we don't have the correct utbase)
if ~is_string(filename) then $
	filename = 'idlsave_goes_' + time2file(self.utbase) + '.sav'

save, filename=filename, $
	readme, satellite, asciibase, utbase, tarray, yclean, emis, tempr, lrad, lx, $
	ch0_bad, ch1_bad, bsub, bktimes, bfunc, bk, b0user, b1user, abund_model, /xdr

msg = ['', $
   'Saved in IDL save file ' + filename, $
   '', $
   'To restore and get a list of variables restored, type:', $
   ' ', $
   "restore, '" + filename, $
   'prstr, readme']
self -> display_message, msg

end

;---------------------------------------------------------------------------
; Write text file containing data for two channels, em, and temp, for each
; time interval.  If bk is subtracted, then it's the bk-sub data that's written.
; filename - output filename string. If not passed, and nodialog is set, then
;    output file is autonamed to goes_data.txt
; nodialog - don't prompt for filename when not provided

pro goes::textfile, filename=filename, nodialog=nodialog, _extra=extra

if keyword_set(extra) then self -> set, _extra=extra

if ~is_string(filename) then begin
  if ~keyword_set(nodialog) then begin
    filename = dialog_pickfile (path=curdir(), filter='*.txt', $
      file='goes_data.txt', title = 'Select output text file name',  get_path=path)
    if filename eq '' then begin
      self->display_message,'No output file selected.  Aborting.'
      return
    endif
  endif
endif
      
d = self -> getdata(/struct)

out = ['GOES data for time interval: ' + self->get(/tstart) + ' to ' + self->get(/tend), $
  'Current time: ' + !stime, $
  'GOES archive: ' + (self->get(/sdac_used) ? 'SDAC' : 'Yohkoh'), $
  'Data Type: ' + self->title(), $
  'Data are ' + (d.yes_clean ? 'Cleaned' : 'Not Cleaned'), $
  'Background ' + (d.yes_bsub ? 'is' : 'is not') + ' subtracted.', $
  '' ]

if ~d.yes_bsub then out = [out, 'NOTE: ', $
  'You should subtract background for better estimation of emission measure and temperature.', '']
 
header = [strpad('Time at center of bin', 25, /after) + $
  string('1.0 - 8.0 A', '0.5 - 4.0 A', 'Emission Meas', 'Temp', format='(4a15)'), $ 
  strpad(' ', 25) + $
  string('watts m^-2', 'watts m^-2', '10^49 cm^-3', 'MK', format='(4a15)') ]
out = [out, header, '']

y = d.yes_bsub ? d.ybsub : d.yclean
str = string(transpose( [ [y[*,0]], [y[*,1]], [d.em], [d.tem] ] ), format='(4g15.5)')
times = anytim( anytim(d.utbase) + d.tarray, /vms)
out = [out, times + ' ' + str]

checkvar, filename, 'goes_data.txt'
prstr, file=filename, out

self -> display_message, 'Text file written: ' + filename
end

;---------------------------------------------------------------------------
;-- Get GOES event list for time period.  Returns string array of event list, or
; if /struct set, an array of structures.  If /show set, displays list.
; timestart,timeend - fully qualified time interval.  If not passed, uses times set in obj
; struct - if set, returns array of structures of event info
; class_decode - if set, converts class to number, e.g. 'C1.2' -> 1.2e-6
; show - if set, calls prstr.  Any args in _extra will be passed to prstr, so can use:
;         /nomore - show list in IDL log, not in 'more' window
;         file='xxx.txt'  - sends out the output to file xxx.txt
; count - returns the number of events found
; 
function goes::get_gev, timestart, timeend, count=count, struct=struct, class_decode=class_decode, $
  show=show, _extra=_extra

checkvar, timestart, anytim2utc(self->getprop(/tstart),/vms)
checkvar, timeend, anytim2utc(self->getprop(/tend),/vms)

ngdc = anytim(timeend) lt anytim('25-aug-1991')

gev = get_gev(timestart, timeend, count=count, ngdc=ngdc, err=err)
if err ne '' then begin
   message,/info, err
   count = 0
   return,-1
endif

if count eq 0 then begin
   message, /info, 'No events found in time range 
   return,-1
endif

decode_gev, gev, gstart,gend,gpeak,class=class,loc=loc,noaa_ar=noaa_ar,/vms

sp = '   '
out_string = strmid(gstart,0,17) + sp + strmid(gpeak,12,5) + sp + $
      strmid(gend,12,5) + sp + class + sp + loc + sp + noaa_ar

if keyword_set(show) then prstr,out_string,_extra=_extra

if keyword_set(struct) then begin
   if keyword_set(class_decode) then begin
     class = trim(class)  ; get rid of any extra blanks
     cl_letter = strmid(class,0,1)
     cl_val = float(strmid(class,1,10))
     z=['A','B','C','M','X']
     zvals = 10. ^ [-8.,-7.,-6.,-5.,-4.]
     q=where_arr(cl_letter, z, /map_ss)  ; q will be index into zvals for class letter
     class = zvals[q] * cl_val
   endif
   struct = {gstart:gstart, gend:gend, gpeak:gpeak,class:class,loc:loc,noaa_ar:noaa_ar}
   return, reform_struct(struct)
endif else return, out_string
 
end



;---------------------------------------------------------------------------
;-- define GOES object

pro goes__define



goes_struct={goes, $
	tstart:0.d0,$
	tend: 0.d0,$
	sat:0,$
	sdac: 0, $   ; 0/1/2/3 means use yohkoh/sdac/yohkoh_then_sdac/sdac_then_yohkoh archive of goes files
	sdac_used: 0, $
	mode: 0, $   ; mode = 0,1,2 = 3 sec, 1 min, 5 min
	gdata:ptr_new(),$
	numstat: 0L, $
	tstat: ptr_new(), $
	stat: ptr_new(), $
	lstart:0.d, $   ; lstart through lmode are settings of last accumulation
	lend:0.d, $
	lsat:0, $
	lsdac:0, $
        lremote:0b,$
	lmode:0, $
	showclass: 0b, $
	clean: 0b, $
	markbad: 0b, $
	bsub: 0b, $
	btimes: ptr_new(), $
	b0times: ptr_new(), $
	b1times: ptr_new(), $
	bfunc: '', $	; 0poly, 1poly, 2poly 3poly, or exp
	bfunc_options: strarr(5), $
	b0user: ptr_new(), $  ; user background for chan 0, scalar or vector
	b1user: ptr_new(), $  ; user background for chan 1, scalar or vector
	itimes: [0.d0, 0.d0], $
	abund: 0, $
	abund_options: strarr(3), $
	use_norm: 0b, $             ; not used yet
	norm_factors: ptr_new(), $  ; not used yet
	plotman_obj: obj_new(), $ 
        remote:0b,$
	inherits utplot}

return & end
