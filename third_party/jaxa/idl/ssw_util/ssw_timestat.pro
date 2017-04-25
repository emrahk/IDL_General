function ssw_timestat, times, $
   average=averaget, mean=meant, mindiff=mindifft, ss=ss, out_style=out_style
;+
;   Name: ssw_timestat
;
;   Purpose: return time 'statistics'
;
;   Input Paramters:
;      times - vector of times, any SSW format (per anytim.pro)
;
;   Output:
;      function returns requested value based on user keywords
;
;   Keyword Parameters:
;      average - return average of input times
;      mean    - return mean time
;      mindiff - return time with minimum residuals 
;      out_style - optional output time style (for 'average') per anytim.pro
;      ss - if set, return the SS (subscript) of <times> (def= actual time)
;
;   History:
;      3-November-1999 - S.L.Freeland - simplify some repeat logic
;
;   Method:
;      call ssw_deltat and act per user keyword settings
;-
if n_params() eq 0 then begin
   box_message,['Require input time vector',$
                'IDL> stat=ssw_timestat(times [,/average][,/mean][,/mindiff])']
   return,-1
endif

if not keyword_set(out_style) then out_style='ccsds'
ntimes=n_elements(times)

case 1 of 
   ntimes eq 1: timex=times(0)
   keyword_set(averaget): timex=anytim(average(anytim(times)),out_style=out_style)
   keyword_set(meant):    timex=times(ntimes/2)
   keyword_set(mindifft): begin
      resids=fltarr(ntimes)
      for i=0,ntimes-1 do resids(i)=total(abs(ssw_deltat(times,ref=times(i))))
      ssmin=where(resids eq min(resids))
      timex=times(ssmin(0))   
   endcase
   else: timex=times(ntimes/2)
endcase

if keyword_set(ss) then retval=tim2dset(times,timex) else retval=timex
return, retval
end
