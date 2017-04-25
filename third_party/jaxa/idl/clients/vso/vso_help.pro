;+
; Project     : VSO
;
; Name        : VSO_HELP()
;
; Purpose     : Get help on using the VSO IDL commands
;
; Explanation : Prints text to the screen about command usage.
;
; Category    : Utility, Class2, VSO
;
; Syntax      : IDL> vso_help
;
; Examples    : IDL> vso_help
;               IDL> vso_help, /search  ; help for vso_search
;               IDL> vso_help, /help    ; help for vso_help
;
; History     : Ver 1,  06-Dec-2010, J A Hourcle.  Released
;               Ver 1.1 15-Nov-2011, J A Hourcle.  Updated docs
;
; Contact     : oneiros@grace.nascom.nasa.gov ; joseph.a.hourcle@nasa.gov
;               http://virtualsolar.org/
;
; Keywords:
; (flag keywords)
;   HELP    ; boolean ; get help for using this command
;   INFO    ; boolean ; get help for using vso_info
;   SEARCH  ; boolean ; get help for using vso_search()
;   GET     ; boolean ; get help for using vso_get()
;
;-



pro vso_help, search=search, get=get, info=info, object=object, help=help, news=news, query=query

	crlf = 1 ; string(13b) + string(10b)
	print, 'VSO : Virtual Solar Observatory'
	displayed_something = 0

	if keyword_set( help ) then begin
		; help for vso_help

		print, rotate( [ $
			'', $
			'vso_help    : procedure : get information about using the VSO IDL routines', $
			'', $
			'Valid Flag Keywords:', $
		$;	'   /news   : news about updates to the VSO IDL tools', $
			'   /help   : instructions on using this program', $
			'   /info   : instructions on using vso_info()', $
			'   /search : instructions on using vso_search()', $
			'   /get    : instructions on using vso_get()', $
		$;	'   /query  : instructions on using vso_query()', $
		$;	'   /object : instructions on using the VSO object', $
		''], crlf )

		displayed_something = 1
	endif
	
	if keyword_set( news ) then begin
		; VSO news ; try to get an RSS feed for this?

		print, rotate([ $
			'', $
			'VSO News :', $
			'', $
			'SDO Status: The AIA and HMI data are not yet fully calibrated, but test series are ', $
			'            available for scientists to see the headers and otherwise test their ',$
			'            compatability with their tools. We have not yet started on EVE integration.', $
			'            AIA browse data (1024x1024 pixels, ~90sec cadence) from 23 May 2010', $
			'            HMI level 1.5 data (4096x4096, ~45 sec cadence) from 29 March 2010', $
			'              (dopplergrams, magnetograms, continuum intensity, line width/depth, etc.)', $
		''], crlf)

		displayed_something = 1
	endif


	if keyword_set( info ) then begin
		; help for vso_info

		print, rotate([ $
			'', $
			'vso_info    : function  : query the VSO registry', $
			'', $
			'The VSO Registry contains general information about what data is available', $
			'from the various VSO data providers.  This routine will tell you what the', $
			'valid values are for different keywords for vso_search().  Please note that', $
			'as this program searches the registry, it will not show any terms that may be', $
			'defined in the VSO data model, but for which no data is yet available.', $
			'', $
			'Valid Keywords:', $
			'  output       : OUT : anonymous structure : an array of records returned', $
			'', $
			'Valid Flag Keywords:', $
			'  /sources     : list valid sources', $
			'                 aliases : /spacecraft, /observatory', $
			'  /instruments : list valid instruments', $
			'                 aliases : /telescope', $
			'  /detectors   : list valid detectors (sub-instruments)', $
			'  /provider    : list valid data providers', $
			'  /layout      : list valid data layouts', $
			'                 aliases : /datatype', $
			'  /physobs     : list valid physical observables', $
			'                 aliases : /observable', $
		$;	'  /extent      : list valid extent types', $
			'', $
			"  /quiet       : don't print any output to the screen (only useful with OUTPUT) ",$
		''], crlf)

		displayed_something = 1
	endif
	
	if keyword_set( search ) then begin
		; help for vso_search
		
		print, rotate([ $
			'', $
			'vso_search  : function  : search the VSO for data', $
			'', $
			" Syntax      : IDL> records = vso_search( start_time, end_time, ... )",$
			"               IDL> status = vso_get( records )",$
			" Input:",$
			"   (note -- you must either specify DATE, START_DATE or TSTART)",$
			" Optional Input:",$
			" (positional)",$
			"   TSTART     : date   ; the start date",$
			"   TEND       : date   ; the end date",$
			" Keywords:",$
			"   DATE       : string ; (start date) - (end date)",$
			"   START_DATE : date   ; the start date",$
			"   END_DATE   : date   ; the end date",$
			"   WAVE       : string ; (min) - (max) (unit)",$
			"   MIN_WAVE   : string ; minimum spectral range",$
			"   MAX_WAVE   ; string ; maximum spectral range",$
			"   UNIT_WAVE  ; string ; spectral range units (Angstrom, GHz, keV)",$
			"   EXTENT     ; string ; VSO 'extent type' ... (FULLDISK, CORONA, LIMB, etc)",$
			"   PHYSOBS    ; string ; VSO 'physical observable'",$
			"   PROVIDER   ; string ; VSO ID for the data provider (SDAC, NSO, SHA, MSU, etc)",$
			"   SOURCE     ; string ; spacecraft or observatory (SOHO, YOHKOH, BBSO, etc)",$
			"                         synonyms : SPACECRAFT, OBSERVATORY",$
			"   INSTRUMENT ; string ; instrument ID (EIT, SXI-0, SXT, etc)",$
			"                         synonym : TELESCOPE",$
			"   DETECTOR   ; string ; detector ID (C3, EUVI, COR2, etc.)",$
			"   LAYOUT     ; string ; layout of the data (image, spectrum, time_series, etc.)",$
			"",$
			" Keywords with limited support; (may not work with all archives)",$
			"   LEVEL      ; range* ; level of the data product (see below)",$
			"   PIXELS     ; range* ; number of pixels (see below)",$
			"   RESOLUTION ; range* ; effective resolution (1 = full, 0.5 = 2x2 binned, etc)",$
			"   PSCALE     ; range* ; pixel scale, in arcseconds",$
			"   NEAR_TIME  ; date   ; return record closest to the time.  See below.",$
			"   SAMPLE     ; number ; attempt to return only one record per SAMPLE seconds.  See below.",$
			"   ",$
			" (flag keywords)",$
			"   HELP       ; boolean ; display this help screen; returns 0",$
			"   QUICKLOOK  ; boolean ; retrieve 'quicklook' data if available (see below)",$
			"   LATEST     ; boolean ; sets ( near=now, end=now, start=(now - 7 days) ) (see below)",$
			"   URLS       ; boolean ; attempt to get URLs, also",$
			"   QUIET      ; boolean ; don't print informational messages",$
			"   DEBUG      ; boolean ; print xml soap messages",$
			"   FLATTEN    ; boolean ; return vsoFlat Record (no sub-structures)",$
			"",$
			" Outputs:",$
			"   a null pointer -> no matches were found",$
			"   (or)",$
			"   struct[n] : (vsoRecord or vsoFlatRecord) the metadata from the results",$
		$;	'', $
		$;	'For more information (examples, range matching, etc.) see :',$
		$;	'    http://docs.virtualsolar.org/IDL', $
		''], crlf)
		
		displayed_something = 1
	
	endif
	
	if keyword_set( get ) then begin
		; help for vso_get

		print, rotate([ $
			'', $
			'vso_get     : function  : download files using the VSO', $
			'', $
			'', $
			" Syntax      : IDL> meta = vso_search( date='2010.8.5', inst='aia', /FLAT )",$
			"               IDL> wanted = where( meta.wave_min eq 4500 )",$
			"               IDL> results = vso_get( meta[wanted], /RICE )",$
			"               IDL> print_struct, results",$
			" Inputs:",$
			"   ARGS : Can be one of:",$
			"     struct[n] : vsoRecord (returned from vso_search())",$
			"     struct[n] : vsoFlatRecord (returned from vso_search(/FLAT))",$
			" Optional Keywords: (input)",$
			"   OUT_DIR : string    : directory to download files to",$
			"   SITE    : string    : the abbreviation of an SDO caching node",$
			"   EMAIL   : string    : to 'order' data from SHA (they will e-mail where you pick it up)",$
			"   ??      :           : any other input allowed by sock_copy",$
			" Optional Keywords: (output)",$
			"   FILENAMES : string[n] : returns the paths to files downloaded",$
			" Flag Keywords:",$
			"   FORCE   : boolean   : don't prompt for seemingly excessive requests",$
			"   QUIET   : boolean   : work silently (implies /FORCE, as well)",$
			"   NODOWNLOAD : bool.  : don't attempt to download files",$
			"   NOWAIT  : boolean   : download in background without waiting",$
			"   RICE    : boolean   : request Rice-compressed FITS files from SDO JSOC",$
			"   NORICE  : boolean   : make sure we don't get Rice-compressed files, should the default ever change",$
			"   STAGING : boolean   : prefer 'staged' data, rather than immediate URLs.  (requires EMAIL)",$
			" Environmental Variables:",$
			"   VSO_DEFAULT_SITE : string : sets a default SITE; use of SITE will override",$
			"",$
			" Output:",$
			"   struct[n] : getDataRecord",$
		''], crlf)
	
		displayed_something = 1
	endif

	if keyword_set( query ) then begin
		; help for vso_get

		print, rotate([ $
			'', $
			'vso_query   : function  : generate a query to send to the VSO', $
			'', $
			'Note -- this is typically used in conjunction with vso_info()', $
			'        see `vso_help, /info` for examples', $
			'', $
			'', $
			'', $
			'', $
		''], crlf)
	
		displayed_something = 1
	endif

	
	if keyword_set( object ) then begin
		; help on using the vso object
	
		print, rotate([ $
			'', $
			'vso__define : object    : object that handles VSO API interaction', $
			'', $
			'This section of the documentation has not yet been written.', $
		''], crlf)
	
		displayed_something = 1
	endif
	
	if not displayed_something then begin
		; generic help
	
		print, rotate([ $
			'', $
			'vso_help    : procedure : get information about using the VSO procedures', $
			'vso_info    : function  : search the VSO registry', $
			'vso_search  : function  : search the VSO for data', $
			'vso_get     : function  : download files using the VSO', $
		$;	'vso_query   : function  : generate a request to send to the VSO', $
			'vso__define : object    : object that handles VSO API interaction', $
			'For more information, call `vso_help, /help`', $
		''], crlf)

		; doc_library, 'vso_help'

	endif

	at = '@'

	print, rotate([ $
		'', $
		'For more information about the Virtual Solar Observatory, visit', $
		'    http://www.virtualsolar.org/ ', $
		'For more information on the VSO IDL client, visit',$
		'    http://docs.virtualsolar.org/IDL', $
		'', $
		'If you have questions or comments about these functions, contact ', $
		'Joe Hourcle at oneiros'+at+'grace.nascom.nasa.gov or joseph.a.hourcle'+at+'nasa.gov', $
	''], crlf)

return & end


