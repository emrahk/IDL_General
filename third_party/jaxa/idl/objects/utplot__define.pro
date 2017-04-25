;+ Project     : HESSI
;
; Name        : UTPLOT__DEFINE
;
; Purpose     : Define a UTPLOT plot class
;
; Category    : objects
;
; Syntax      : IDL> new=obj_new('utplot')
;
; History     : Written 3 April 2001, D. Zarro (EITI/GSFC)
;               Modified 6 Sept 2001, Zarro (EITI/GSFC) - added ->SET_TRANGE
;               Modified 6 Jan  2002, Zarro (EITI/GSFC) - added TIMES,DATA keywords
;               Modified 16 Sep 2002, Zarro (LAC/GSFC) - added GETDATA
;               Modified 24 Nov 2002, Zarro (EER/GSFC) - added checks for different
;                                                        input time formats
;               Modified 5 Feb 2003, Zarro (EER/GSFC) - added ability to
;                                                       override UTBASE
;               Modified 7 May 2003, Zarro (EER/GSFC) - added check for
;               simultaneous XRANGE and TIMERANGE keywords in PLOT method.
;               Previously XRANGE could override TIMERANGE. Now TIMERANGE takes
;               precedence.
;               Modified 24 Jan 2004, Zarro (L-3Com/GSFC) - allowed UTBASE
;                to be entered independently of XDATA
;               Modified 17-Apr-2004, Zarro (L-3Com/GSFC) - replaced WHERE by WHERE2
;               Modified 8-Jul-2004, Zarro (L-3Com/GSFC) - fixed UTBASE problem
;               when seconds array is entered
;               Modified 1-August-2004, Zarro (L-3Com/GSFC) - made UTBASE units
;               self-consistent with input times.
;               Modified 1-April-2005, Zarro (L-3Com/GSFC) - use _REF_EXTRA
;                to pass keyword values back to caller.
;               Modified 16-Jun-2005, Kim - allow utbase to be 0, and in set_trange,
;                if timerange is integer, float it so won't be misinterpreted by anytim
;               Modified 17-Jan-2006, Zarro. Made err and err_msg self consistent.
;               Modified 14-Sep-2006, Zarro. Added e (errorbar) argument to init
;               Modified 26-Apr-2009, Zarro (ADNET)
;                - modified GET to return status=0 if property undefined
;               Modified 04-Aug-2009, Kim.  
;                - Added _extra keyword to cleanup, and pass through to xyplot::cleanup
;               Modified 23-Nov-2010, Kim.
;                - tim2secs changed to use anytim except when /secs or /tai set
;               Modified 09-Nov-2011, Kim.
;                - in tim2secs, check first finite time for
;                  double(times) eq time                               
;               19-Feb-2012, Zarro (ADNET)
;                 - changed message,/cont to message,/info because
;                   /cont was setting !error_state
;
; Contact     : dzarro@solar.stanford.edu
;-

function utplot::init,t,y,e,_ref_extra=extra

return,self->xyplot::init(t,y,e,plot_type='utplot',_extra=extra)

dprint,'% UTPLOT::INIT'

end

;-----------------------------------------------------------------------
;--destroy object

pro utplot::cleanup, _extra=extra

dprint,'% UTPLOT::CLEANUP'

self->xyplot::cleanup, _extra=extra

return

end

;--------------------------------------------------------------------------
;-- get at underlying data arrays

function utplot::getdata,times=times,_ref_extra=extra,utbase=utbase

if arg_present(utbase) then utbase=self->get(/utbase)
if arg_present(times) then times=self->get(/xdata)
return,self->xyplot::getdata(_extra=extra)

end

;---------------------------------------------------------------------------
;-- get method

function utplot::get,_ref_extra=extra,timerange=timerange,status=status

status=1b
if keyword_set(timerange) then begin
 xrange=self->xyplot::get(/xrange)
 if ~valid_range(xrange) then xrange=self->get_def_xrange()
 if valid_range(xrange) then begin
  utbase=anytim2tai(self.utbase)
  return,anytim2utc(utbase+xrange,/vms)
 endif
endif

if keyword_set(utbase) then return,self.utbase

if is_string(extra) then return,self->xyplot::get(_extra=extra,status=status)
status=0b
return,''

end

;----------------------------------------------------------------------------
;--set data and plot properties

pro utplot::set,times=times,data=data,_ref_extra=extra,$
                 xdata=xdata,ydata=ydata,utbase=utbase,timerange=timerange

;-- remove conflicting XRANGE keyword if TIMERANGE is set

if is_string(extra) then begin
 if valid_range(timerange,/allow,/time) then begin
  temp=strpos(strup(extra),'XRA') eq 0
  check=where2(temp,complement=complement,ncomplement=ncomplement)
  if ncomplement gt 0 then extra=extra[complement] else delvarx,extra
 endif
endif

if exist(data) then self->xyplot::set,ydata=data,_extra=extra

;-- times in XYPLOT object are stored in double precision secs since UTBASE

if exist(times) then $
 self->xyplot::set,xdata=self->tim2secs(times,_extra=extra,utbase=utbase),_extra=extra

if exist(ydata) then self->xyplot::set,ydata=ydata,_extra=extra

if exist(xdata) then $
 self->xyplot::set,xdata=self->tim2secs(xdata,_extra=extra,utbase=utbase),_extra=extra

if is_string(extra) then self->xyplot::set,_extra=extra
		; /zero added 10-jun-05 kim !!!!
if ~exist(times) and ~exist(xdata) and valid_time(utbase,/zero) then self->set_utbase,utbase

if exist(timerange) then self->set_trange,timerange

return & end

;-------------------------------------------------------------------------
;-- convert times to secs relative to UTBASE

function utplot::tim2secs,times,tai=tai,secs=secs,utbase=utbase,err_msg=err_msg,no_copy=no_copy

;--- if /TAI then 'times' is TAI seconds (since 1/1/1958)
;--- if /SECS then 'times' is seconds since UTBASE (which must be given or already set)
;--- Otherwise use anytim to convert times to sec, compute utbase if times are absolute 

; Note: for relative times, UTBASE keyword should be passed in on object initialization call, or
; in same call as the call setting xdata.  Otherwise here we set times to times-min(times) and utbase
; is set to min(times), but user later sets utbase and expects times to be relative to that.

err_msg=''

fin = where(finite(times), nfinite)
if nfinite eq 0 then begin
  err_msg = 'No input times are finite.'
  message,err_msg, /info
  return,0
endif

;-- if seconds since UTBASE, check UTBASE was passed

if keyword_set(secs) then begin
 if ~valid_time(utbase,/zero) then begin		; /zero added 10-jun-05 kim !!!!
  utbase=self->get(/utbase)
  if ~valid_time(utbase,/zero) then begin		; /zero added 10-jun-05 kim !!!!
   err_msg='Missing UTBASE'
   message,err_msg,/info
   return,0
  endif
 endif
 self->set_utbase,utbase
 return,double(times)
endif

;-- if TAI, compute UTBASE

if keyword_set(tai) then begin
 tmin=min(times,/nan)
 if keyword_set(no_copy) then time=temporary(times)-tmin else time=times-tmin
 self->set_utbase,tmin,/tai
 return,double(time)
endif

; Try converting times using anytim.  If error, quit.  
; If input times were absolute times, then set utbase to the min of those times and subtract 
; min from array of times.  
; If input times were seconds, then if utbase was passed in or is already set in object, 
; use that and time array is interpreted as seconds since that time; otherwise set utbase 
; to min of seconds (assume relative to 1979/1/1), and subtract min from array of times.
; We determine if the input time was absolute or just seconds (as int, long, float, 
; double) by checking if anytim returns an array of the same dimension as input, AND whose 
; first element is equal to the first element of the input converted to DOUBLE.  If so then 
; array is seconds.
time = reform(anytim(times, error=error))
if error then begin
 err_msg='Invalid input TIMES'
 message,err_msg,/info
 return,0
endif

; first time may be NaN, so check first finite time (changed times[0] to times[fin[0]]), 9-nov-2011
if ~is_struct(times) && (n_elements(times) eq n_elements(time)) && $
   (double(times[fin[0]]) eq time[fin[0]]) then begin

  ;-- if here, time is seconds since 79 or seconds since UTBASE (if entered)

  if valid_time(utbase,/zero) then tbase=utbase else begin
    ; see if utbase already set in obj
    tmin = min(time, /nan)
    tbase=self->get(/utbase)
    if is_blank(tbase) then begin
      ; no utbase passed in or set.  Use min of data.
      tbase = anytim(tmin,/vms)
      if keyword_set(no_copy) then time=temporary(time)-tmin else time=time-tmin
    endif
  endelse
endif else begin

  ;-- if here, have absolute time.  Set utbase to min and subtract min from time.

  tmin=min(time,/nan)
  tbase=anytim(tmin,/vms)
  if keyword_set(no_copy) then time=temporary(time)-tmin else time=time-tmin

endelse

self->set_utbase,tbase
return, time
end

;---------------------------------------------------------------------------

function utplot::where_zero,count=count

count=0
zeros=where( (self->get(/times) eq 0.),count)

return,zeros
end


;---------------------------------------------------------------------------
pro utplot::set_utbase,utbase,tai=tai

if valid_time(utbase, /zero) then begin		; /zero added 10-jun-05 kim !!!!
 if ~is_number(utbase) or keyword_set(tai) then $
  self.utbase=anytim2utc(utbase,/vms) else $
   self.utbase=anytim(utbase,/vms)
 return
endif

return & end

;---------------------------------------------------------------------------
;-- convert external TIMERANGE  into internal XRANGE

pro utplot::set_trange,timerange

if valid_range(timerange,/allow,/time,zeros=zeros) then begin
 if zeros then self.xrange=timerange else begin
  utbase=self->get(/utbase)
  if size(timerange,/tname) eq 'INT' then timerange=float(timerange)
  self.xrange=anytim(timerange,/tai)-anytim(utbase,/tai)
 endelse
endif

return & end

;----------------------------------------------------------------------------
;-- UTPLOT method

pro utplot::plot_cmd,x,y,overlay=overlay,_extra=extra

utbase=self->get(/utbase)

dprint,'% UTPLOT::PLOT_CMD - utbase = ',utbase

if keyword_set(overlay) then outplot,x,y,utbase,_extra=extra else $
                          utplot,x,y,utbase,_extra=extra

return
end

;------------------------------------------------------------------------------

pro utplot::show

self->xyplot::show
print,'% UTBASE: ',self->get(/utbase)

return & end

;------------------------------------------------------------------------------
;-- UTPLOT properties definition

pro utplot__define

temp={utplot,               $
      utbase:'',            $
      inherits xyplot}

return
end

