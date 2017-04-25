;+
; Project     : VSO

; Name        : VSO_GET()

; Purpose     : Send a GetData request to VSO

; Explanation : Attempts to download data products corresponding to the
;               metadata from a previous VSO search.  Also returns
;               metadata about the files to be downloaded

; Category    : Utility, Class2, VSO

; Syntax      : IDL> a = vso_get( vso_search( date='2004.1.1', inst='eit' ) )

; Examples    : IDL> meta = vso_search( date='2004.6.5', inst='eit', /FLAT )
;               IDL> wanted = where( meta.wave_min eq 171.0 )
;               IDL> results = vso_get( meta[wanted] )
;               IDL> print_struct, results
;
; History     : Ver 0.1, 27-Oct-2005, J A Hourcle.  split this out from vso__define
;               Ver 1,   08-Nov-2005, J A Hourcle.  Released
;               Ver 1.1, 21-Nov-2005, Hourcle.  Added /DOWNLOAD flag
;               Ver 1.2, 22-Nov-2005, Hourcle.  Replaced /DOWNLOAD flag w/ /NODOWNLOAD
;               Ver 1.3  18-May-2006, Zarro. Added /NOWAIT and removed VSO_GET
;                        procedure because it confused the compiler.
;               Ver 2    24-July-2008, Zarro (ADNET) - added some error checking
;               Ver 2.1  10-June-2010, Hourcle (Wyle) -- Default to HTTP/1.0
;               Ver 2.2  06-July-2010, Hourcle.  Added /rice flag,
;               warning re: downloads from SHA;
;               Ver 2.3  21-July-2010, Zarro (ADNET). Changed _EXTRA to _REF_EXTRA
;               Ver 2.4  13-Aug-2010, Hourcle.  Added FILENAMES,EMAIL
;               and SITE keywords
;               Ver 2.4  7-Oct-2010, Zarro (ADNET). Fixed small bug with /QUIET
;               Ver 2.5  2-April-2011, Zarro (ADNET). Restored /nowait capability.
;               Ver 2.6  19-Sept-2011, Hourcle.  Documenting 'VSO_DEFAULT_SITE'
;               Ver 2.7  15-Nov-2011, Hourcle.  add /HELP, update docs
;               Ver 2.8  7-Feb-2012, Zarro. Set protocol=1.0 as default
;                        for vso->getdata and sock_copy
;               Ver 2.9, 17-Feb-2012, Hourcle.  Use IDLnetURL when necessary
;               Ver 3.0, 20-Feb-2012, Zarro. Deprecated /nowait as
;                        background copying doesn't update the
;                        stack object because it works in a different
;                        thread.
;               17-Apr-12, Zarro (ADNET) - fixed FILENAMES keyword issue.
;               7-Sep-12, Zarro (ADNET)
;                      - changed /NETWORK to /USE_NETWORK for
;                        compatibility with RHESSI.
;                      - removed VERBOSE as a direct keyword as it
;                        conflicted with QUIET. It is still available
;                        via _EXTRA
;                      - ensured FILENAMES and LOCAL_FILE are identical.
;                      - added check for blank filenames returned by
;                        SOCK_COPY when download fails (e.g. network
;                        timeouts).
;                      - preserved order of returned FILENAMES.
;                8-Dec-12, Zarro (ADNET)
;                      - forced HTTP PROTOCOL=1.0 in SOCK_COPY to
;                        avoid chunked encoding (for now).
;                17-Apr-13, Zarro (ADNET)
;                      - removed PROTOCOL=1.0 constraint
;                17-Oct-14, Hourcle - removed SHA warning re: URLs
;
; Contact     : oneiros@grace.nascom.nasa.gov
;               http://virtualsolar.org/
; Inputs:
;   ARGS : Can be one of:
;     struct[n] : vsoRecord (returned from vso::query())
;     struct[n] : vsoFlatRecord (returned from vso::query(/FLAT))
;     struct[n] : datarequest (you probably don't want this)
; Optional Keywords: (input)
;   METHODS : string[n] : acceptable transfer methods
;   OUT_DIR : string    : directory to download files to
;   PROTOCOL: string    : to adjust the HTTP protocol used (default '1.0')
;   SITE    : string    : the abbreviation of an SDO caching node (see below)
;   EMAIL   : string    : to 'order' data from SHA (they will e-mail where you pick it up)
;   ??      :           : any other input allowed by sock_copy
; Optional Keywords: (output)
;   FILENAMES : string[n] : returns the list of files downloaded
; Flag Keywords:
;   HELP    : boolean   : display documentation; returns 0
;   MERGE   : boolean   : if input is vsoRecord or vsoFlatRecord,
;                          will insert URLs into the input structures
;   FORCE   : boolean   : don't prompt for seemingly excessive requests
;   QUIET   : boolean   : work silently (implies /FORCE, as well)
;   NODOWNLOAD : bool.  : don't attempt to download files
;   URLS    : boolean   : override METHODS to only use URL-type transfer methods.
;   RICE    : boolean   : request Rice-compressed FITS files from SDO JSOC
;   NORICE  : boolean   : make sure we don't get Rice-compressed files, should the default ever change
;   STAGING : boolean   : prefer 'staged' data, rather than immediate URLs.  (requires EMAIL)

; Output:
;   struct[n] : getDataRecord

; See Also:
;   for more documentation, see vso__define.pro
;   see also vso_search.pro (w. /URLS flag), and sock_copy.pro
;
; The 'SITES' keyword:
;   There are a number of sites building caches for SDO data.  You can
;   try specifying any of the following values, and we will re-route
;   you to them as they become available.
;     NSO   : National Solar Observatory, Tucson (US)
;     SAO  (aka CFA)  : Smithonian Astronomical Observatory, Harvard U. (US)
;     SDAC (aka GSFC) : Solar Data Analysis Center, NASA/GSFC (US)
;     ORB  (aka ROB)  : Observatoire Royal de Belgique (Belgium)
;     MPS   : Max Planck Institute for Solar System Research (Germany)
;     UCLan : University of Central Lancashire (UK)
;     IAS   : Institut Aeronautique et Spatial (France)
;     KIS   : Kiepenheuer-Institut fur Sonnenphysik Germany)
;     NMSU  : New Mexico State University (US)
;   If you do not pass this value explicitly, the software will check
;   for the existance of an environmental variable 'VSO_DEFAULT_SITE'
;-

function vso_get, records, merge=merge, nodownload=nodownload, force=force, quiet=quiet,$
                  help=help, methods=methods, rice=rice, norice=norice,$
                  filenames=filenames, email=email, site=site,local_file=local_file,_ref_extra=extra
 
    if ( keyword_set(help) ) then begin
        vso_help, /get
        return,''
    endif

    if ~is_struct(records) then begin
        pr_syntax,'results=vso_get(records)'
        return,''
    endif
    if ~have_tag(records,'url') then begin
        message,'Input records do not have valid URL tags',/info
        return,records
    endif

    vso = obj_new('vso',_extra=extra)
    if is_blank(methods) then $
        methods = vso->getprop(/methods)

    if keyword_set(staging) then begin
	if is_blank(email) then $
            message, '/STAGING requires setting EMAIL'
        methods = [ 'STAGING-TAR_GZ', 'STAGING-TAR', 'STAGING-ZIP', methods ]
    endif else begin
	if ~is_blank(email) then $
            methods = [ methods, 'STAGING-TAR_GZ', 'STAGING-TAR', 'STAGING-ZIP' ]
    endelse


    if keyword_set(norice) then rice=0
    if keyword_set(rice) then $
        methods = [ 'URL-FILE_Rice', 'URL-TAR_Rice', methods ]

    results = vso->getdata( records, methods=methods, email=email, site=site, _extra=extra )
    obj_destroy, vso

;    undef = where( records.provider eq 'SHA', sha_count )
;    if sha_count then begin
;        message, 'SHA does not currently support URL downloads.', /info
;        if is_blank(email) then begin
;            message, '  You can provide an email address with the EMAIL keyword', /info
;            message, '  to request the data be staged for later retrieval', /info
;        endif else begin
;            message, '  Request for data staging was sent', /info
;            message, '  Please watch your email ('+email+') for information', /info
;        endelse
;    endif

    if keyword_set( nodownload ) then return, results
    check=where(strtrim(results.url) ne '',count)
    if count eq 0 then begin
        message,'Sorry, no valid URL addresses associated with these data records',/info
        message,'  (this may not be an error if you sent an e-mail address for data staging)', /info
        return,results
    endif
    results=results[check]
    urls=results.url

; if we made it this far, we need to download the files
; TODO : benchmark the following two methods

    unique_urls = urls[uniq([urls])]
    quiet=keyword_set(quiet)

    if ~quiet then begin

; check if any of the fileids had messages associated with them
; minor problem -- the 'merge' flag changes the returned structure

        info = keyword_set(merge) ? results.getinfo : results.info

; TODO : we might've had duplicated fileids in the structure, if it were
; from trace ... need to make sure we only print each uniq provider/fileid
; combo

        if ~is_blank(info) then begin
            messages = where ( info ne '' )
            print, strtrim(n_elements(messages),2)+' file(s) had informational messages:'
            print_struct, results[messages], ['provider', 'fileid', keyword_set(merge) ? 'getinfo' : 'info']
        endif

        message, 'This will download '+ strtrim(n_elements(unique_urls),2)+' file(s)', /info

; need to prompt to continue (maybe just if it's too large)
; but I don't know if there's a generic way to prompt in solarsoft
; 50 is just an arbitrary number ... it's probably a factor of the
; network someone's on, and the size of the files they're asking for  -- Joe

        if ~keyword_set( force ) and n_elements(unique_urls) gt 50 then begin
            userinput = ''
            read, userinput, prompt='Do you wish to continue? [Yn] '
            if ( stregex( userinput, '^n', /bool,/fold ) ) then $
                return, results ; end now
        endif

    endif ; end of if  keyword_set(quiet)

    np = n_elements( unique_urls )
    filenames=strarr(np)
    for i=0,np-1 do begin
     if ~quiet then print, strtrim(i+1,2)+' : '+unique_urls[i]
     use_network = strmatch( unique_urls[i], '*lasp.colorado.edu*', /fold)
     sock_copy, unique_urls[i], use_network=use_network, local_file=temp, _extra=extra,$
                verbose=~quiet
     filenames[i]=temp
    endfor
    if ~quiet then message, 'Downloading completed',/info

;-- remove blanks (corresponding to failed downloads)

    check=where(filenames ne '',count)
    if (count gt 0) and (count lt np) then filenames=filenames[check]
    if count eq 1 then filenames=filenames[0]
    if count eq 0 then filenames=''
    local_file=filenames
    
    return, results

end

