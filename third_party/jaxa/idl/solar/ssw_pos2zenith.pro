function ssw_pos2zenith, index, lat, lon, $
	latitude=latitude, longitude=longitude
;+
;   Name: ssw_pos2zenith
;
;   Purpose: Calculate solar zenith angle from an observer's position
;
;   Input Parameters:
;      index - any ssw standard time; optionally includes .LAT,.LON fields
;      lat, lon - observer's latitude/longitude (in degrees) [north/east = + ]
;
;   Keyword Parameters:
;      latitude,longitude - Keyword alternative to positional params
;
;   Calling Sequence:
;      zenith=ssw_pos2zenith(index)   ; index contains SSW UT, .LAT, .LON
;         -OR-
;      zenith=ssw_pos2zenith(index,lat,lon) ; index conatins SSW UT
;         -OR-
;      zenith=ssw_pos2zinith(index, lat=lat, lon=lon )  ;  keyword alternative
;
;   History:
;      15-March-2000 - S.L.Freeland - Wrapper for Greg Slater 'get_zenang.pro'
;       6-Apr-2000   - S.L.Freeland - modifications per Roger J. Thomas
;
;-
blat=n_elements(latitude)  ne 0        ; check pos via keyword?
blon=n_elements(longitude) ne 0

; ----- define position from positional or keyword or structure -----
case 1 of
   n_params() ge 3: begin
     xlat=lat &  xlon=lon
   endcase
   blat and blon: begin
      xlat=latitude & xlon=longitude
   endcase
   data_chk(index,/struct) and required_tags(index,'lat,lon'): begin
      xlat=gt_tagval(index,/lat)
      xlon=gt_tagval(index,/lon)
   endcase
   else: begin
      box_message,['Need to supply UT, LATITUDE, and LONGITUDE',$
         'IDL> zenith=ssw_pos2zenith(index,lat,lon)' ]
      return,-1
   endcase
endcase

ut=anytim(index,/int)          ; rationalize ssw times->internal
zenith=get_zenang(ut,xlat,xlon)

return, zenith
end
