function ssw_getapkp,time0,time1, sec=sec, _extra=_extra, last7=last7
;
;   Name:  ssw_getapkp
;
;   Purpose: return A/K indices for desired time range
;
;   Input Parameters:
;      time0 - desired time or start of time range
;      time1 - end time of range
;
;   Output Parameters:
;      function returns ssw/utplot-ready indices
;
;   History:
;      9-mar-2005 - S.L.Freeland
;
;   Calls
;      get_solar_indices / ssw_sec_aktxt2struct
;
;-
;
last7=keyword_set(last7)

if last7 then begin
   if n_elements(time0) eq 0 then time0=reltime(days=-7)
   if n_elements(time1) eq 0 then time1=reltime(/now)
endif

case 1 of
   last7:
   n_params() eq 0: begin 
         box_message,'Need a time or timerange...'
         return,-1
   endcase
   n_params() eq 1: time1=reltime(time0,/day)
   else:
endcase

sec=keyword_set(sec) or $
   ssw_deltat(time0,ref=reltime(days=-120),/day) gt 0

case 1 of
   sec: begin 
      if last7 then begin ; special processing due to overlap+diff endtimes.. 
         l2=ssw_sec_aktxt2struct(ssw_sec_time2akfiles(/last2),/expand,_extra=_extra)
         l7=ssw_sec_aktxt2struct(ssw_sec_time2akfiles(/last7),/expand,_extra=_extra)
         retval=sort_index(l7,l2) 
      endif else begin 
      secfiles=ssw_sec_time2akfiles(time0,time1,count=count)
      if count gt 0 then begin 
         retval=ssw_sec_aktxt2struct(secfiles,/expand,_extra=_extra)
      endif else begin 
         box_message,'No SEC/A/K files in your time range(?)
         retval=-1
      endelse
      endelse
   endcase
   else: begin 
      retval=get_solar_indices(time0,time1,/apkp_3hour)
   endcase
endcase

if data_chk(retval,/struct) then begin
   ss=sel_timrange(anytim(retval,/int),anytim(time0,/int),anytim(time1,/int),/bet)
   if ss(0) ne -1 then retval=retval(ss) else retval=-1
endif

return,retval
end
