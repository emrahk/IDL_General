function ssw_sec_aktxt2struct, aktxt_files, station=station, $
      expand_3hour=expand_3hour, debug=debug
;+
;   Name: ssw_sec_aktxt2struct
;
;   Purpose: convert one or more NOAA/SEC A/K index text files->ssw structures
;
;   Input Parameters:
;      aktxt_files - local nfs filenames or urls on SEC server
;
;   Output:
;      function returns ssw/utplot compliant strucutures
;
;   Keyword Parameters:
;      expand_3hour - if set, expand return structures to 3 hour K-ind cadence
;      station - optional station - default=Boulder
;
;   NOTE: - generally invoked from a wrapper routine which will map
;   from user times to the implied file list - but help yourself to 
;   this lower level routine as desired.
;
;   Calling Examples:
;      ==================== EX #1 =================================
;      IDL> kind=ssw_sec_aktxt2struct('7day_AK.txt')  ; last 7 day SEC file
;      ============================================================
;      IDL> help,kind & help,kind,/str
;IDL> help,kind & help,kind,/str
;KIND            STRUCT    = -> <Anonymous> Array[7]  << default=1-per-day
;** Structure <24fdb8>, 8 tags, length=96, data length=90, refs=4:
;   MJD             LONG             53431
;   TIME            LONG                 0
;   STATION         STRING    'Boulder' <<<< default station
;   LAT             STRING    'N49'
;   LON             STRING    'W42'
;   A               INT             12
;   ESTAP           INT       Array[8]  <<< 8 samples per record (3hour)
;   K               INT       Array[8]  <<< Ditto
;      
;      ================ EX #2 (override STATION and cadence defaults) ======
;      IDL> kind=ssw_sec_aktxt2struct('7day_AK.txt', station='Fredericksburg',$
;                                        /expand_3hour)
;      ====================================================================
;      IDL> help,kind & help,kind,/str
;KIND            STRUCT    = -> <Anonymous> Array[56]  <<< 3 hour samples
;** Structure <250208>, 8 tags, length=64, data length=62, refs=2:
;   MJD             LONG             53431
;   TIME            LONG                 0
;   STATION         STRING    'Fredericksburg' <<< Not Boulder...
;   LAT             STRING    'N38'
;   LON             STRING    'W78'
;   A               INT              8
;   ESTAP           INT              3  <<< now "flattened"
;   K               INT              2  <<< Ditto, 1 sample per 3 hour rec
;      
;
;   History:
;      8-mar-2005 - S.L.Freeland
;     15-mar-2005 - S.L.Freeland - moved time tags forward by 1.5 hours (center of 3 hour sample, I think..)
;
;   Restrictions:
;      If NOAA/SEC files are not local/nfs, data is read from  
;        SEC server via socket - therefore, IDL V. >= 5.4 required
;-

common ssw_sec_aktxt2struct_blk,strtemp,strtemp_exp

debug=keyword_set(debug)
if not data_chk(aktxt_files,/strin) then begin 
   box_message,'Need at least one input file name or url'
   return,-1
endif

chkloc=file_exist(aktxt_files)
locss=where(chkloc,lcnt)

sectop='http://www.sec.noaa.gov/ftpdir/lists/geomag/'
htext=''  ; init - will contain contanated contents of all files/urls
case 1 of 
   lcnt eq n_elements(aktxt_files): htext=rd_tfiles(aktxt_files(locss)) 
   strpos(aktxt_files(0),sectop) eq 0: begin   ; urls
      for i=0,n_elements(aktxt_files)-1 do begin 
         sock_list,aktxt_files(i),ht
         htext=[temporary(htext),ht]
      endfor
   endcase
   strpos(aktxt_files(0),'/') eq -1: begin
      securls=sectop+aktxt_files
      for i=0,n_elements(securls)-1 do begin 
         sock_list,securls(i),ht
         htext=[temporary(htext),ht]
      endfor
   endcase
   else: begin 
      box_message,'Don"t understand input - try NFS files or SEC URLS...'
      return,-1
   endcase
endcase

if n_elements(htext) eq 0 then begin 
   box_message,'Problem with file read or remote url access, returning...'
   return,-1
endif

if not data_chk(strtemp,/struct) then  begin
   strtemp={mjd:0l,time:0l,station:'',lat:'',lon:'',A:0, $
      estAP:intarr(8), K:intarr(8)}
   strtemp_exp={mjd:0l,time:0l,station:'',lat:'',lon:'',A:0, $
      estAP:0, K:0}
endif

htext=htext(1:*)
ssdates=where(is_number(htext),dcnt)
if dcnt eq 0 then begin 
   box_message,'Problem determing data-dates, returning...
   return,-1
endif

dcols=str2cols(strtrim(htext(ssdates),2),/unal)
strtab2vect,dcols,yy,mm,dd
ddates=anytim(dd+'-'+mm+'-'+yy,/utc_int)

retval=replicate(strtemp,dcnt)
retval.time=ddates.time
retval.mjd=ddates.mjd

if not data_chk(station,/string) then station='Boulder'
ssstat=where(strpos(strlowcase(htext),strlowcase(station)) ne -1,stacnt)

if stacnt ne dcnt then begin 
   box_message,'Mismatch between dates and station entries for: ' + station(0)
   return,-1
endif

retval.station=station(0)

statab=str2cols(htext(ssstat),ncols=6,/trim)
strtab2vect,statab,sta,lat,lon0,lon1,aind,ktab

retval.lat=lat
retval.lon=lon0+lon1
retval.a=fix(aind)
retval.k=fix(str2cols(ktab))

ssap=where(strpos(htext,'Planetary') eq 0,apcnt)

if apcnt gt 0 then begin 
   apcols=str2cols(htext(ssap),/un)
   aptab=apcols(data_chk(apcols,/nx)-8:*,*)
   retval.estap=fix(aptab)
endif else begin 
   box_messges,'No estimated AP found, setting to -1...'
   retval.estap=-1
endelse 

if keyword_set(expand_3hour) then begin  ; one samp per 3 hours
   nsamp=dcnt*8
   tempret=replicate(strtemp_exp,nsamp)
   tempret.station=retval(0).station
   tempret.lat=retval(0).lat
   tempret.lon=retval(0).lon
   tempret.a=rebin(retval.a,nsamp,/samp)
   tim0=anytim(anytim(retval(0)) +  (90.*60.),/ecs)
   tgrid=timegrid(tim0,nsamp=nsamp,hours=3,out='utc_int')
   tempret.time=tgrid.time
   tempret.mjd=tgrid.mjd
   tempret.estap=reform(retval.estap,nsamp)
   tempret.k=reform(retval.k,nsamp)
   ssok=where(tempret.k ne -1,okcnt)
   if okcnt gt 0 then tempret=tempret(ssok) else tempret=-1
   delvarx,retval
   retval=temporary(tempret)
endif
if debug then stop
return,retval
end
