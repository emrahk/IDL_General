function get_acedata, time0, time1, debug=debug, bad_data=bad_data, $
    status=status, missing=missing,  _extra=_extra, $
    daily=daily, monthly=monthly, keep_quality=keep_quality

;+
;   Name: get_acedata
;
;   Purpose: read/return ACE data for desired time range & cadence
;
;   Input Paramters:
;      time0, time1 - time range desired , any SSW format
;
;   Output:
;      function returns ACE data, utplot-ready time tags
;
;   Keyword Parameters:
;      /swepam, /epam, /mag, /sis - ACE instrument to read/return
;      (default is /SWEPAM)
;
;      daily - if set, use daily files (cadence one or five minutes)
;      monthly - if set, use monthly files, cadence = 1 hour
;      missing - if set, include missing sample points (def removes these)
;      _extra - ACE data type (see current restrictions) - default=SWEPAM
;      status - return status, =1 if ANY data in time range, 0 if NONE
;      bad_data - include data flagged as missing/bad by ACE
;                 (default only returns "perfect" data)
;      keep_quality - if set, returned structures include the quality
;                     flag (or flags) - this is default if /BAD_DATA is set
;      /SWEPAM, /EPAM, /SIS, /MAG - which ACE instrument to read/return
;      (historical default is SWEPAM)
;
;   Calling Examples:
;           get last 24 hours of data (cadence = 1 minute)
;      IDL> acedata=get_acedata(reltime(/yest),reltime(/now),/daily,/swepam)
;
;           long term data (cadence = 1 hour)
;      IDL> acedata=get_acedata('1-jan-2001','1-mar-2001',/monthly,/epam)
;
;   History:
;      6-Sep-2001 - S.L.Freeland - for eit/sxt comparative studies, LWS
;     26-Sep-2001 - S.L.Freeland - remove SWEPAM only restriction
;                                  add /BAD_DATA switch and function
;
;   Calls:
;      ace_files, read_ace & usual SSW suspects
;-

bad_data=keyword_set(bad_data)
valid=1-bad_data                    
delete_quality=1-keyword_set(keep_quality) or bad_data

debug=keyword_set(debug)
retval=-1                                          ; assume the worst
status=0

if n_params() lt 2 then begin 
   box_message,['Need time range...', $
                'IDL> acedata=get_acedata(t0,t1 [,/TYPE ] [,status=status] )']
   return,retval
endif   

acefiles=ace_files(time0,time1, fcount, $           ;  ~relevant files
    _extra=_extra, daily=daily, monthly=monthly)

if fcount gt 0 then begin
   read_ace, acefiles, acedata,valid=valid, debug=debug, delete_quality=delete_quality ;ascii-> SSW str
   if data_chk(acedata,/struct) then begin 
      ss=sel_timrange(anytim(acedata,/ints), $      ; trim to user times
        anytim(time0,/ints),anytim(time1,/ints))
      if ss(0) ne -1 then retval=acedata(ss) else $     
        box_message,'No data found in time range'
   endif else box_message,'No valid data samples'   ; probably never
endif else begin 
   box_message,'No ACE files for timerange/type'
endelse

status=data_chk(retval,/struct)                      ; return success 
return, retval
end
