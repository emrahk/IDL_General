function ssw_nar2armurl,narrecs, utdate=utdate, ar_number=ar_number, $
   arm_topurl=arm_topurl, top_url=top_url
;
;+
;   Name: ssw_nar2armurl
;
;   Purpose: map from NAR data records -> corresponding ARM URLs
;
;   Input Parameters:
;      narrecs - vector of records from NAR dbase (Noaa Active Region)
;
;   Keyword Parameters:
;      utdate - user supplied date in lieu of NARRECS      
;               (scalar in any ssw format or 1:1 vector n_elements(ar_number)
;      ar_number - NOAA AR(s) - user supplied in lieu of NARRECS
;      top_url - if set, return ARM parent URL
;      arm_topurl - parent url of ARM; default='http://www.solarmonitor.org'
;
;   Output:
;      function returns implied ARM URL(s);
;         AR urls if NARRECS or AR_NUMBER supplied
;         DATE index urls if only UTDATE supplied
;         TOP/ARM parent if /TOP_URL switch set
;
;   Calling Sequence:
;      armurls=ssw_nar2armurl(narrecs) ; NAR dbase -> ARM region urls
;      armurls=ssw_nar2armurl(utdate=dates, ar_num=arlist) ; region urls
;      armurls=ssw_nar2armurl(utdate=dates) ; By-DATE index urls
;      armurls=ssw_nar2armurl(/top) ; top/parent ARM url
;
;   Calling Examples:
;      IDL> more,ssw_nar2armurl(get_nar('15-dec-2004')) ; NAR DBASE->ARM URL
;      http://www.solarmonitor.org/region.php?date=20041215&region=10711
;      http://www.solarmonitor.org/region.php?date=20041216&region=10710
;      (..etc..)
;
;      IDL> more,ssw_nar2armurl(utdate='15-dec-2004',ar_num=[710,711])
;      http://www.solarmonitor.org/region.php?date=20041215&region=10710
;      http://www.solarmonitor.org/region.php?date=20041215&region=10711
;
;      IDL> more,ssw_nar2armurl(utdate='15-dec-2004') ; -> DATE index URLS
;      http://www.solarmonitor.org/index.php?date=20041215

;
;   History:
;      4-aug-2005 - S.L.Freeland - single point beauty -> solarmonitor PHP
;-
;
status=0

if not data_chk(arm_top,/string) then $
   arm_top='http://www.solarmonitor.org/'

case 1 of
    keyword_set(top_url): return,arm_top ; !!!! Early EXIT 
    required_tags(narrecs,'time,day,noaa,location'): begin ; NAR records in
       dates=anytim(narrecs,/ecs)
       ars=gt_tagval(narrecs,/noaa)
    endcase
    keyword_set(utdate) and keyword_set(ar_number): begin 
       if n_elements(utdate) eq 1 then $     
          dates=replicate(utdate(0),n_elements(ar_number)) else dates=utdate
       ars=fix(ar_number)
    endcase
    keyword_set(utdate): dates=utdate ; date only -> index URLS
    else: begin 
       box_message,'Need either NAR records -or- UTDATE(s) + AR(s)'
       return,''
    endcase
endcase

datedirs=time2file(dates,/date_only)
dquery='date=' +datedirs
aquery=''

if n_elements(ars) gt 0 then begin 
   ars=ars+([0,10000])(ars lt 4000)
   sars=strtrim(ars,2)
   aquery="&region="+sars
endif

query=dquery+aquery
arurls=arm_top+(['index','region'])(aquery ne '') +".php?" +query
return,arurls
end



