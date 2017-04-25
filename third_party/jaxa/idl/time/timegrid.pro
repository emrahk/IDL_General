function timegrid, startt, stopt, $
	weeks=weeks, days=days,  hours=hours, minutes=minutes, seconds=seconds, $
	npoints=npoints, strings=strings, nsamp=nsamp, quiet=quiet, $
	_extra=_extra, month=month
;+
;   Name: timegrid
;
;   Purpose: create a (approximately) uniform grid of times
;
;   Input Parameters:
;       startt, stopt - start and stop times desired, any format
;
;   Keyword Parameters:
;      days, hours, minutes, seconds - desired grid time resolution
;      nsamp - number of elements in return (use instead of stop time)
;      strings - if set, return value is Yohkoh formatted string time
;      quiet - if set, dont print warning if no interediate points found
;
;   Output:
;      function returns grid in Yohkoh internal format 
;      function returns string format if /strings keyword is set
;
;   Calling Sequence:
;      grid=timegrid(startime, stoptime [, days=days, hours=hours, minutes=minutes, seconds=seconds]
;      grid=timegrid(starttime, nsamp=NN [, days=days, hours=hours , etc]
;
;   Calling Examples:
;      tenmin=timegrid(starttime, stoptime, minutes=10)	; 10 minute spacing
;      onehour=timegrid(starttime, stoptime, /hour)     ;  1 hour spacing
;      onehour=timegrid(starttime, nsamp=10)		; same, for 10 hours
;      yesterday=(timegrid(!stime,day=-1,/string))	; 24 hours ago
;      toffset=timegrid(reference, hour=lindgen(24))    ; offset added to t0
;      ecsfmt=timegrid(t0,t1,/hour, /ecs,/truncate)     ; allow 'anytim.pro'
;                                                       ; format/keyword options  
;
;   History:
;     7-Jul-1994 (SLF) 
;    11-Jul-1994 (SLF) added STRINGS keyword and function
;     4-Aug-1994 (SLF) added NSAMP keyword/function
;    16-Sep-1994 (SLF) allow single parameter (start time) - just add offset
;                      use n_elements instead of keyword_set (to allow 'zeros')
;    16-mar-1995 (SLF) allow vector offsets
;     7-apr-1997 (SLF) add QUIET keyword switch and function
;    12-Jan-1998 (SLF) add keyword inherit -> anytim.pro 
;                      (see 'anytim' doc head for keyword options)
;    16-Sep-1998 (SLF) - if no factor but NSAMP set, set factor accordingly
;    15-Oct-1998 (SLF) - apply 'anytim' to input (as well as output)
;    13-Jul-2000 (RDB) - fixed bug when t1-t0 < 1day but spans day boundary
;    31-Jul-2001 (SFL) - add /MONTH
;     5-Jan-2004 (SLF) - per Nariaki Nitta suggestion, use double precesion
;                        to avoid round off ripples...
;    27-feb-2004 (SLF) - pass QUIET during recursive call
;    28-jul-2006 (SLF) - fix /MONTH logic error 
;
;   Restrictions: 
;      no interpolation - just offsets relative to start time
;-

loud=1-keyword_set(quiet)

case n_params() of
   0: begin
         message,/info, "Must supply start time and resolution..."
         message,/info, "[Optional stop time OR NSAMP]"
         return,-1
   endcase
   1: stopt=startt
   else:
endcase

times=anytim2ints(concat_struct(anytim(startt,/ints),anytim(stopt,/ints)))
secs=int2secarr(times)

case 1 of 
   keyword_set(month): begin 
      tgrid=timegrid(startt,stopt,/day,/vms,/date_only,quiet=quiet)
      tgrid=tgrid(uniq(tgrid))
      fday=strmid(tgrid(0),0,3) ; use first day as Day-Zero for month
      ss=where(strpos(tgrid,fday) eq 0, sscnt)
      if sscnt gt 0 then retval=strtrim(tgrid(ss),2) else retval=[startt,stopt]
      if data_chk(_extra,/struct) then  retval=anytim(retval,_extra=_extra)
      return,retval  ; !!!!!!!!! unstructured exit    
   endcase
   n_elements(seconds) gt 0: fact=double(seconds) 
   n_elements(minutes) gt 0: fact=minutes*60.0d
   n_elements(hours)   gt 0: fact=hours*3600.0d
   n_elements(weeks)   gt 0: fact=weeks*7.*24.*3600.0d
   n_elements(days)    gt 0: fact=days*24*3600.0d 
   n_elements(nsamp)   gt 0: begin
      fact=double(secs(1))/(nsamp-1)        ; in seconds
   endcase
   else: begin
      message,/info,"Please specify one keyword [WEEKS, DAYS, HOURS, MINUTES, SECONDS]
      return,times(0)
   endcase
endcase

if n_elements(secs) eq 2 and n_elements(fact) gt 1 then $
   secs=replicate(secs(0),n_elements(fact))

case 1 of
   keyword_set(npoints): ngrid=npoints	; backward compatible
   keyword_set(nsamp):   ngrid=nsamp-1
   else: begin
         ngrid=abs(float(secs(1))/(fact(0)>1))
;           fix bug when t1-t0 < 1day, but spans a day boundary
         if n_elements(days) gt 0 and times(1).day-times(0).day gt 0 and ngrid lt 1. then ngrid=1.
      end
endcase
;help,ngrid

if ngrid ge 1 then offset=lindgen(ngrid+1)*fact else begin
   if n_params() eq 1 then offset=fact else $
      if loud then message,/info, "No intermediate points at specified resolution..."
endelse

retval=anytim2ints(times(0),offset=offset)

case 1 of 
   keyword_set(strings):  retval=fmt_tim(retval)
   data_chk(_extra,/struct): retval=anytim(retval,_extra=_extra)
   else:
endcase

return, retval
end
