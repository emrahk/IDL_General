function ssw_index2gxd, index, _extra=_extra, append=append
;
;   Name: ssw_index2gxd, 
;
;   Purpose: get GOES XRS samples closest to each input index optionally append
;
;   Input Parameters:
;      index - structure vector, assumed to include ssw compliant DATE_OBS
;
;   Output:
;      function returns corresponding GOES XRS records ('gxd' database)
;      If /APPEND is set, then return is input 'index' with gxd LO&HI tags 
;
;   Keyword Parameters:
;      append (switch) - if set, return input structures w/gxd LO&HI appended
;      _extra - inheritance -> rd_gxd , including /ONE,/FIVE,/GOESn,/ASCII..etc
;      Default is /THREE (closest 3 second samples)
;
;   Calling Example:
;      IDL> sxi_cat,'10:00 5-dec-2006','16:00 5-dec-2006', sxicat
;      IDL> sxigxd=ssw_index2gxd(sxicat,/append [,/one,/five,/goes12...])
;
;   History:
;      6-Dec-2006 - S.L.Freeland
;
if not required_tags(index,/date_obs) then begin 
   box_message,'Need structure vector including tag .DATE_OBS, returning..'
   return,-1
endif

int=anytim(index.date_obs,/int)
time_window,int,t0,t1
rd_gxd,t0,t1,gxd,_extra=_extra  ; get GOES XRS 'gxd' for range

ss=tim2dset(gxd,anytim(index.date_obs,/int),delta=dts)


matchgxd=gxd(ss)
if keyword_set(append) then begin  ; append GXD to 'index' as return value
   tags=(['lo,hi,time,day','lo,hi'])(required_tags(index,'time,day'))
   retval=join_struct(index,str_subset(matchgxd,tags))
endif else retval=matchgxd

return,retval
end
