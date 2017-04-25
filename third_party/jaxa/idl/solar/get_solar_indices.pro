function get_solar_indices, time0, time1, struct=struct, kp=kp, $
         kpmean=kpmean, apmean=apmean, sunspot=sunspot, cp=cp, f10_7=f10_7, $
         interpolate=interpolate, apkp_3hour=apkp_3hour 
;+
;   Name: get_solar_indices
;
;   Purpose: return selected solar/geomag indices for time range
;
;   Input Parameters:
;      time0, time1 - time range of interest
;
;   Output - function returns selected indices (structure or selected)
;
;   Keyword Parameters:
;      apkp_3hour - switch - return higher cadence structure including
;                   kp and ap @ 3 hour cadence (time:0l,mjd:0l,ap:0,kp:0}
;      apmean,kpmean,sunspot,f10_7 - switch selects desired output 
;         (@default cadence = one sample per day)
;      kp - backward compat synonym for kpmean
;      struct (output) - the complete dbase structure between t0/t1
;      interpolate - if set and only one input time, interpolate value
;
;   Calling Seqence:
;      indices=get_solar_indices(time0 time1 [,/SUNSPOT] [/F10_7] [/KPmean] $
;                                                [/APmean])
;      kpap3hr=get_solar_indices(time0, time1 ,/apkp_3hour)
;
;   Calling Examples:
;      IDL> struct=get_solar_indices('1-jan-1960','1-jan-2000')
;      IDL> help,struct,/str
;
;      IDL> spots=get_solar_indices('1-jan-1960','1-jan-2000',/sunspot,struct=struct)
;      IDL> help,sunspots
;
;   Method:
;     setup and call 'read_genxcat' for $SSW_SOLAR_INDICES/ssw_indices*.genx
;     [ genx catalog files via ngdc_make_genxcat & ngdc_kpap2struct ]
;
;   History:
;      13-March-2000 - S.L.Freeland (originally for atmospheric absorption)
;       4-April-2000 - S.L.Freeland - rationalize input time(s)
;      12-Dec-2001   - S.L.Freeland - check $SSWDB/ngdc/indices/genx if
;                         $SSW_SOLAR_INDICES not defined
;       8-Mar-2005 - S.L.Freeland - add /APKP_3HOUR keyword + function
;
;   Restrictions:
;      Assumes $SSWDB  set $SSW_SOLAR_INDICES is installed locally
;      /interpolate not yet implemented - just a reminder of possible 'todo'...
;
;   Method:
;      Inidices from NGDC are stored as a 'genx' catalog 
;      (see read_genxcat / write_genxcat )
;-
common get_solar_indices_blk,apkp_3 

catdir=get_logenv('SSW_SOLAR_INDICES')
if catdir(0) eq '' then catdir=$
   concat_dir(concat_dir(concat_dir('$SSWDB','ngdc'),'indices'),'genx')

if not file_exist(catdir) then begin
   box_message,'No files found in $SSW_SOLAR_INDICES, returning...'
   return,-1
endif

case n_params() of 
   0: begin 
      box_message,['Need start/stop time...',$
     'IDL> indices=get_solar_indices(t0,t1 [,/f10_7] [,/sunspot] [,/ap] [,/kp]']
   endcase
   1: begin
         time_window, time0, tx, time1,day=1    ; day=day+1
   endcase
   else: 
endcase

t0=anytim(time0,/vms)                           ;
t1=anytim(time1,/vms)

read_genxcat, t0, t1,   struct, topdir=catdir   ; genx catalog

if n_params() eq 1 then begin 
  ss=tim2dset(anytim(struct,/int),t0)             ; 1-param ? take closest
  struct=struct(ss(0))
endif

case 1 of
   keyword_set(apkp_3hour): begin
      nsamps=8*n_elements(struct)
      if not data_chk(apkp_3,/struct) then $
         apkp_3={time:0l,mjd:0l,ap:0,kp:0}
      retval=replicate(apkp_3,nsamps)      ; 8 samples per day
      stimes=timegrid(struct(0),nsamp=nsamps,hours=3,out='utc_int')
      retval.time=stimes.time
      retval.mjd =stimes.mjd
      retval.ap  =reform(struct.ap,nsamps)
      retval.kp  =reform(struct.kp,nsamps)
   endcase
   keyword_set(apmean): tag='apmean'
   keyword_set(kp) or keyword_set(kpmean): tag='kpsum'
   keyword_set(sunspot): tag='sunspot'
   keyword_set(f10_7): tag='f10_7)
   keyword_set(cp): tag='cp'
   else: tag='xxx'
endcase

if n_elements(retval) eq 0 then begin         ; false for apkp_3hour...
   retval=gt_tagval(struct,tag,found=found)   ; strip requested keyword
   if not found then retval=struct            ; else return entire struct
endif

return,retval
end
