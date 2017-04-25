pro decode_nar,nardata,nartimes,noaa_ar, $
   area=area, wilson=wilson, macintosh=macintosh,   $
   location=location, xcen=xcen, ycen=ycen, $
   spot_count=spot_count,longitude=longitude, long_extent=long_extent, $
   out_style=out_style, status=status
;
;   Name: decode_nar
;
;   Purpose: decode ssw nar dbase structure
;
;   Input Parameters:
;      nardata - ssw 'nar' (NOAA Active Region) structure vector
;
;   Output Parameters:
;      nartimes - reference times of NOAA locations
;      noaa_ar  - NOAA AR numbers
;
;   Keyword Parameters:
;      wilson (output) - Wilson magnetic classification
;      macintosh (output) - Macintosh class
;      location (output) - Heliographic location 
;      out_style - desired output format for nartimes (per anytim.pro)
;                  {'utc_int', 'ccsds', 'ecs', 'vms', 'int'...}

status=0

if not required_tags(nardata,'time,day,noaa,st$macintosh') then return

nrec=n_elements(nardata)

ew_arr = ['E', 'W']
ns_arr = ['S', 'N']

location=replicate('      ',nrec)

ew=reform(nardata.location(0))
ns=reform(nardata.location(1))

ssloc=where(ew ne -999,lcnt)
if lcnt gt 0 then begin 
   location(ssloc)=ns_arr(ns(ssloc) ge 0) + $
                 string(abs(ns(ssloc)),format='(i2.2)') + $
                 ew_arr(ew(ssloc) ge 0) + $
                 string(abs(ew(ssloc)),format='(i2.2)') 
endif

macintosh=string(nardata.st$macintosh)
wilson=string(nardata.st$mag_type)
xcen=gt_tagval(nardata,/x,missing=0)
ycen=gt_tagval(nardata,/y,missing=0)
spot_count=nardata.num_spots
long_extent=nardata.long_ext
area=nardata.area
longitude=nardata.longitude
if n_elements(out_style) eq 0 then out_style='vms'
nartimes=anytim(nardata,out_style=out_style,/trunc)
noaa_ar=nardata.noaa + ([0,10000])(nardata.noaa lt 6000)

status=1

return
end

