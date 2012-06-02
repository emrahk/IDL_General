PRO CCD_OBS, COORD=coord, LAT=lat, LON=lon, DATE=date, $
             OBJECT=object
;
;+
; NAME:
;	CCD_OBS
;
; PURPOSE:   
;	Plot a graph of height above horizon and airmass
;	of given object versus time [UT].
;
; CATEGORY:
;	CCD PHOTOMETRY.
;
; CALLING SEQUENCE:
;	CCD_OBS, [ COORD=coord, LAT=lat, LON=lon, DATE=date, $
;                  OBJECT=object ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	COORD  : Coordinate string with R.A. and Dec.,
;	         e.g. '19 37 27 -10 32 25' (default).
;	LAT    : Latitude [degrees].
;	LON    : Longitude [degrees].
;	         Default: Tuebingen coordinates.
;	DATE   : Vector [year,month,date], defaulted to today.
;	OBJECT : Object name, defaulted to RXJ1940.
;
; OUTPUTS:
;	PS-File CCD_OBS.PS of plot.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - written 1997.
;-


on_error,2                      ;Return to caller if an error occurs

if not exist(lat) then latitude=48.5d0 else latitude=lat
if not exist(lon) then longitude=-10.0d0 else longitude=lon
;west>0, east<0
time_zone=0.0	;UT - Local Time

if not EXIST(coord) then begin
   coord='19 37 27 -10 32 25'
   object='RXJ1940.1-1025'
endif

if not EXIST(object) then object='see Coord.'

if EXIST(date) then begin
   year=date(0)
   month=date(1)
   day=date(2)
endif else begin
   GET_DATE,da
   da=STR_SEP(STRTRIM(da,2),'/')
   day=long(da(0))
   month=long(da(1))
   year=long(da(2)+1900)
endelse


;create datestring
dastr='!6Object: '+object+'   '+ $
      'Date: '+STRTRIM(STRING(year),2)+'/'+ $
      STRTRIM(STRING(month),2)+'/'+ $
      STRTRIM(STRING(day),2)+'!3'

;ra und dec in degrees
STRINGAD,coord,ra,dec


num=200
height=dblarr(num)
time=double(findgen(num))*24.1d0/double(num)	;time UT in hours

;calculate jd of time
JDCNV, year, month, day, time, jd

;calculate local sidereal time
CT2LST, loc_sid, longitude, time_zone, time, day, month, year


;OBJECT
h_ang=loc_sid-ra*12.0d0/180.0d0	;calculate hour angle

;calculate height above horizon
h=asin(cos(h_ang*!pi/12.0d0)*cos(dec*!pi/180.0d0)* $
       cos(latitude*!pi/180.0d0)+$
       sin(dec*!pi/180.0d0)* $
       sin(latitude*!pi/180.0d0))*180.0d0/!pi


sec=1.0d0/cos(!dpi/2.0d0-h*!dpi/180.0d0)

;air mass Hardie (1962)
;uses true zenith angle
x=sec $
  -0.0018167d0*(sec-1.0d0) $
  -0.002875d0*(sec-1.0d0)^2 $
  -0.0008083d0*(sec-1.0d0)^3

ind=where(h lt 5)
if ind(0) ne -1 then x(ind)=100.0d0


;SUN
;calculate sun position [radians]
SUNPOS,jd,ra_sun,dec_sun

h_ang_sun=loc_sid-ra_sun*12.0d0/!dpi     ;calculate hour angle

;calculate height of SUN above horizon
h_sun=asin(cos(h_ang_sun*!pi/12.0d0)*cos(dec_sun)* $
           cos(latitude*!pi/180.0d0)+$
           sin(dec_sun)* $
           sin(latitude*!pi/180.0d0))*180.0d0/!pi



;max solar height [deg] for twilight
max_sol=-18.0d0 


for g=0,1 do begin

if g eq 1 then begin
   set_plot,'ps'
   device,/landscape,xsize=26,ysize=16,yoffset=29,filename='CCD_OBS.PS'
   message,'Creating PS file CCD_OBS.PS',/inf
endif


!p.multi=[0,1,2]

plot,time,h,xrange=[12.0,36.0],yrange=[0.0,90.0], $
     xstyle=1,ystyle=1,thick=2,title=dastr, $
     xtitle='!6Time [UT]',ytitle='Height [Deg.]'

oplot,time+24.0d0,h,thick=2

for ii=0, n_elements(h_sun)-1 do begin
   if h_sun(ii) ge 0.0 then begin
      oplot,[time(ii),time(ii)],[0.0,90.0]
      oplot,[time(ii)+24.0d0,time(ii)+24.0d0],[0.0,90.0]
   endif
   if (h_sun(ii) ge max_sol) then begin
      oplot,[time(ii),time(ii)],[0.0,90.0],linestyle=1
      oplot,[time(ii)+24.0d0,time(ii)+24.0d0],[0.0,90.0],linestyle=1
   endif
endfor


plot,time,x,xrange=[12.0,36.0],yrange=[1.0,2.0d0], $
     xstyle=1,ystyle=1,thick=2,title='!6Coord.: '+coord, $
     xtitle='!6Time [UT]',ytitle='Air Mass!3'

oplot,time+24.0d0,x,thick=2

for ii=0, n_elements(h_sun)-1 do begin
   if h_sun(ii) ge 0.0 then begin
      oplot,[time(ii),time(ii)],[0.0,90.0]
      oplot,[time(ii)+24.0d0,time(ii)+24.0d0],[0.0,90.0]
   endif
   if (h_sun(ii) ge max_sol) then begin
      oplot,[time(ii),time(ii)],[0.0,90.0],linestyle=1
      oplot,[time(ii)+24.0d0,time(ii)+24.0d0],[0.0,90.0],linestyle=1
   endif
endfor

!p.multi=0

if g eq 1 then begin
   device,/close
   set_plot,'x'
endif

endfor


RETURN
END
