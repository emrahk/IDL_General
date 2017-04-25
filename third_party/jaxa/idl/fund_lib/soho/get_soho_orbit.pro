;+
; Project     : SOHO
;
; Name        : GET_SOHO_ORBIT
;
; Purpose     : read SOHO orbit file using sockets
;
; Category    : utility system sockets
;
; Syntax      : IDL> file=get_soho_orbit(date)
;                   
; Inputs      : DATE = date of orbit file
;
; Outputs     : STC = structure with orbital information for input date
;
; Keywords    : None
;
; History     : 21-Feb-2009, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_soho_orbit,date,_ref_extra=extra

;-- create stack object to cache results

common get_soho_orbit,fifo
if ~obj_valid(fifo) then fifo=obj_new('fifo')

;-- get date to search [def to current]

if valid_time(date) then tdate=anytim2utc(date) else get_utc,tdate 
ymd=date_code(tdate)

;-- check if data for this day is saved in cache

data=fifo->get(ymd,status=status)

;-- search for orbit files stored by day in yearly directories 

if ~status then begin

 ;-- check if sockets are supported and network is up

 if ~allow_sockets(_extra=extra) then return,-1
 synop=synop_server(/soho,/full,_extra=extra,network=network)
 if ~network then return,-1

;-- cycle thru likely files until a matching one is found. Assume
;   highest version file is in parent predictive directory. Search
;   yearly subdirectories if not found in parent.

 year='/'+strmid(ymd,0,4)
 f1='/SO_OR_PRE_'+ymd+'_V01.FITS'
 f2='/SO_OR_PRE_'+ymd+'_V02.FITS'
 f3='/SO_OR_PRE_'+ymd+'_V03.FITS'

 pred_dir=synop+'/data/ancillary/orbit/predictive'
 year_dir=pred_dir+year
 choices=[pred_dir+f3,pred_dir+f2,pred_dir+f1,year_dir+f3,year_dir+f2,year_dir+f1]

 data=-1
 for i=0,n_elements(choices)-1 do begin
  sock_fits,choices[i],data,ext=1,_extra=extra
  if is_struct(data) then begin
   file=choices[i]
   break
  endif
 endfor

 if is_blank(file) then begin
  message,'No matching SOHO orbit file available',/cont
  return,-1
 endif

;-- cache data

 data=add_tag(data,file,'orbit_file')
 fifo->set,ymd,data

endif

;-- find nearest matching record

diff=abs(data.ellapsed_milliseconds_of_day-tdate.time)
index=where(diff eq min(diff))
return,data[index]

end
