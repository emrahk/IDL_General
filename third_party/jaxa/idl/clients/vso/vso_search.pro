;+
; Project     : VSO
;
; Name        : VSO_SEARCH()
;
; Purpose     : Send a search request to VSO
;
; Explanation : Sends a query to VSO, to obtain metadata records corresponding
;               to the records that match the query parameters.
;
; Category    : Utility, Class2, VSO
;
; Syntax      : IDL> a = vso_search('2005-JAN-01', instrument='eit')
;
; Examples    : IDL> a = vso_search(date='2004-01-01', provider='sdac')
;               IDL> a = vso_search(date='2002-1-4 - 2002-1-4T07:05', inst='mdi')
;               IDL> a = vso_search(date='2004/1/4T07:40-2004/1/4T07:45', inst='trace')
;               IDL> a = vso_search(date='2004-1-1', extent='CORONA', /FLAT)
;               IDL> a = vso_search(date='2001-1-1', physobs='los_magnetic_field')
;               IDL> a = vso_search(date='2004/1/1', inst='eit', /DEBUG)
;               IDL> a = vso_search('2004/1/1','2004/12/31', wave='171 Angstrom', inst='eit')
;               IDL> a = vso_search('2004/6/1','2004/6/15', wave='284-305 Angstrom', inst='eit')
;               IDL> a = vso_search('2005-JAN-1', inst='eit', /FLAT, /URL)
;
;               IDL> print_struct, a
;               IDL> print_struct, a.time       ; if not called w/ /FLATTEN
;               IDL> sock_copy, a.url           ; if called w/ /URLS
;               IDL> b = vso_get( a )           ; attempt to download products
;		
;
; History     : Ver 0.1, 27-Oct-2005, J A Hourcle.  split this out from vso__define
;               Ver 1,   08-Nov-2005, J A Hourcle.  Released
;                        12-Nov-2005, Zarro (L-3Com/GSFC)
;                         - added TSTART/TEND for compatability with SSW usage.
;                         - added _REF_EXTRA to communicate useful keywords
;                           such as error messages.
;               Ver 1.1, 01-Dec-2005, Hourcle.  Updated documentation
;               Ver 1.2, 02-Dec-2005, Zarro. Added call to VSO_GET_C
;               Ver 1.3, 18-May-2006, Zarro. Removed call to VSO_GET_C
;                           because it confused the compiler
;               Ver 2.0, 06-Jul-2010, Hourcle.  Updated documentation (see vso__define:buildquery)
;               Ver 2.1, 15-Nov-2011, Hourcle.  Updated docs, add /help
;               Ver 2.2, 30-May-2012, Hourcle.  Fixed docs (vso_get example)
;               Ver 2.3, 22-Apr-2013, Zarro. Added COUNT output keyword
;
; Contact     : oneiros@grace.nascom.nasa.gov
;               http://virtualsolar.org/
;
; Input:
;   (note -- you must either specify DATE, START_DATE or TSTART)
; Optional Input:
; (positional)
;   TSTART     : date   ; the start date
;   TEND       : date   ; the end date
; Keywords:
;   DATE       : string ; (start date) - (end date)
;   START_DATE : date   ; the start date
;   END_DATE   : date   ; the end date
;   WAVE       : string ; (min) - (max) (unit)
;   MIN_WAVE   : string ; minimum spectral range
;   MAX_WAVE   ; string ; maximum spectral range
;   UNIT_WAVE  ; string ; spectral range units (Angstrom, GHz, keV)
;   EXTENT     ; string ; VSO 'extent type' ... (FULLDISK, CORONA, LIMB, etc)
;   PHYSOBS    ; string ; VSO 'physical observable'
;   PROVIDER   ; string ; VSO ID for the data provider (SDAC, NSO, SHA, MSU, etc)
;   SOURCE     ; string ; spacecraft or observatory (SOHO, YOHKOH, BBSO, etc)
;                         synonyms : SPACECRAFT, OBSERVATORY
;   INSTRUMENT ; string ; instrument ID (EIT, SXI-0, SXT, etc)
;                         synonym : TELESCOPE
;   DETECTOR   ; string ; detector ID (C3, EUVI, COR2, etc.)
;   LAYOUT     ; string ; layout of the data (image, spectrum,time_series, etc.)
;   COUNT      ; long   ; number of search results

; Keywords with limited support; (may not work with all archives)
;   LEVEL      ; range* ; level of the data product (see below)
;   PIXELS     ; range* ; number of pixels (see below)
;   RESOLUTION ; range* ; effective resolution (1 = full, 0.5 = 2x2 binned, etc)
;   PSCALE     ; range* ; pixel scale, in arcseconds
;   NEAR_TIME  ; date   ; return record closest to the time.  See below.
;   SAMPLE     ; number ; attempt to return only one record per SAMPLE seconds.  See below.
;   
; (flag keywords)
;   HELP       ; boolean ; display usage summary.  returns 0
;   QUICKLOOK  ; boolean ; retrieve 'quicklook' data if available (see below)
;   LATEST     ; boolean ; sets ( near=now, end=now, start=(now - 7 days) ) (see below)
;   URLS       ; boolean ; attempt to get URLs, also
;   QUIET      ; boolean ; don't print informational messages
;   DEBUG      ; boolean ; print xml soap messages
;   FLATTEN    ; boolean ; return vsoFlat Record (no sub-structures)
;
; (placeholders for the future)
;   FILTER     ; string ; filter name (same problems as detector)
;   WAVETYPE   ; string ; type of spectral range (LINE, NARROW, BROAD)
;                         (WARNING : causing errors to be thrown when using 'wave')
;   CARTID     ; string ; load a VSO Cart by its identifier
;   EVENT      ; string ; search for data using an event from HEK
;
; Outputs:
;   a null pointer -> no matches were found
;   (or)
;   struct[n] : (vsoRecord or vsoFlatRecord) the metadata from the results
;
; Limitations : if using /URLS, you may wish to examine output.getinfo for messages
;               SHA requires 'STAGING' the data, and vso_get() does not yet have
;                 support for anything other than direct URLs
;
; Other Notes :
;
; VSO Searching:
; * By default, if a VSO data provider (ie, archive) does not support
;   a given search parameter, it will default to returning everything
;   that *might* match.  This will occassionally result in many more
;   fields being returned than expected.
; * Some data providers will limit the number of results that they 
;   return, and you'll see a message such as:
;       Records Returned : SDAC : 1000/31772
;   You will need to break the query into smaller time ranges to get all
;   of the records.  Some data providers have implemented a 'summary rows'
;   feature where excessive returns will cause the archive to return records
;   corresponding to more than one record:
;       IDL> sot = vso_search( '2006-01-01', '2007-01-01', inst='sot' )
;       Records Returned : SDAC_SOT : 488118/488118
;       IDL> help, sot
;       SOT             STRUCT    = -> VSORECORD Array[5321]
;   Examine the 'info' field for a clue as to how many observations were
;   rolled up into each record.  We hope to provide improved support
;   for expanding these 'summary' records into individual observations
;   in the future.
; * If you have a query that's not returning what you're expecting,
;   please contact :  joseph.a.hourcle AT nasa.gov
;   (and make sure to send the query!)
;
; Source / Instrument / Detector / Phys. Obs. / Layout / Extent Tye / etc:
; * These items are enumerations.  For a list of valid values, see:
;     http://sdac.virtualsolar.org/cgi/show_details
; * We hope to soon have a 'vso_info' program to get the list from within IDL
;
; Dates within VSO_SEARCH:
; * All dates are in UTC.
; * Dates may be entered in any format accepted by 'anytim2utc', EXCEPT for the
;   'DATE' keyword, which expects a string containing a range
;       (eg, '2004/01/01 - 2004/02/01')
; * The 'NEAR_TIME' keyword is not yet supported by all data providers.  As a
;   precaution, using NEAR without specifying a start or end time will use a
;   window of +/- 1hr to prevent extremely large data returns from data providers
;   that do not support this keyword, but it may cause the data provider to return
;   no data if there is no data in that 2 hr window.  You can override the window.
; * The /LATEST flag will set the following, where 'NOW' is the current time
;       START_DATE=(NOW - 7 days), END_DATE=NOW, NEAR_TIME=NOW
;   It will not override existing start dates, so if the data you're interested in
;   lags by more than a week, you can set START_DATE further into the past, and
;   it will still set END_DATE and NEAR_TIME for you.
; * Order of precidence for start and end dates:
;     * DATE keyword (a string containing 2 dates)
;     * TSTART/TEND (positional parameters)
;     * START_DATE/END_DATE keywords
; * If no end date is specified, it will use the start of the next day
;
; Numeric Ranges : (marked as 'range*')
; * May be entered as a string or any numeric type for equality matching
; * May be a string of the format '(min) - (max)' for range matching
; * May be a string of the form '(operator) (number)' where operator is one of:
;     lt gt le ge < > <= >=
;
; Level :
; * Whatever numeric value the PI assigns.
; * If the PI's designation is '1.5q', search for : LEVEL=1.5,/QUICKLOOK
;
; Quicklook : 
; * Quicklook items are assumed to be generated with a focus on speed rather
;   than scientific accuracy.  They are useful for instrument planning and
;   space weather but should not be used for science publication.
; * This concept is sometimes called 'browse' or 'near real time' (nrt)
; * Quicklook products are *not* searched by default
;
; Resolution / Pixels / Pixel Scale :  (currently SDO/AIA and HMI only)
; * The "resolution" is a function of the highest level of data available.
;   If the CCD is 2048x2048, but it's binned to 512x512 before downlink,
;   the 512x512 product is designated as '1'.  If a 2048x2048 and 512x512
;   product are both available, the 512x512 product is designated '0.25'.
; * Pixels are (currently) limited to a single dimension. (and only implemented
;   for SDO data)  We hope to change this in the future to support TRACE,
;   Hinode and other investigations where this changed between observations
; * Pixel Scale (PSCALE) is in arc seconds.  It's currently only implemented
;   for SDO, which is 0.6 arcsec per pixel at full resolution for AIA.
;
;-

function vso_search, tstart,tend, urls=urls, help=help, count=count,_ref_extra=extra

        count=0l
	if keyword_set(help) then begin
	  vso_help, /search
	  return, 0;
	endif

        contents=''
        vso = obj_new('vso',_extra=extra)
        if ~obj_valid(vso) then return,contents

;-- construct VSO query and send it

        query = vso->buildquery(tstart,tend,_extra=extra )
        records = vso->query(query, _extra=extra)

;-- check for results

        err_msg='no matching records found'
        if obj_valid(records) then begin
         if exist(records->contents()) then begin
          contents=records->contents()
          if ( keyword_set(urls) ) then $
           contents=vso->getdata(contents, /merge, _extra=extra )
          count=n_elements(contents)
         endif else message,err_msg,/cont
        endif else message,err_msg,/cont

;-- cleanup

        obj_destroy,[records,vso]

        return,contents

end
