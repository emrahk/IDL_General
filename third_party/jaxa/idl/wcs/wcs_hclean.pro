;+
; Project     :	STEREO
;
; Name        :	WCS_HCLEAN
;
; Purpose     :	Clean FITS header of WCS keywords.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	Removes any keywords relevant to array structure or WCS
;               coordinates from a FITS header, preparatory to recreating it
;               with the proper values.  The objective is to leave only
;               annotative keywords.
;
; Syntax      :	WCS_HCLEAN, HEADER
;
; Examples    :	See WCS2FITSHEAD
;
; Inputs      :	HEADER	= FITS header to be cleaned.
;
; Opt. Inputs :	None.
;
; Outputs     :	The cleaned FITS header is returned in place of the input
;               array.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG	= If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               WCS_HCLEAN, ERRMSG=ERRMSG, ...
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	FXPAR, SXDELPAR, VALID_NUM
;
; Common      :	None.
;
; Restrictions:	HEADER must be a string array containing a properly formatted
;               FITS header.
;
; Side effects:	Some coordinate-related keywords may leak through, especially
;               the non-standard ones.
;
; Prev. Hist. :	Based on FXHCLEAN.
;
; History     :	Version 1, 19-Sep-2006, William Thompson, GSFC
;               Version 2, 13-Apr-2011, WTT, add GAE for SDO
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_hclean, header, errmsg=errmsg
on_error, 2
;
;  Check the number of input parameters.
;
if n_params() ne 1 then begin
    message = 'syntax:  wcs_hclean, header'
    goto, handle_error
endif
;
;  Check the type of HEADER.
;
s = size(header)
if (s[0] ne 1) or (s[2] ne 7) then begin
    message = 'HEADER must be a (one-dimensional) string array'
    goto, handle_error
endif
;
;  Determine whether the header is a simple header or a binary table header.
;  For binary tables, get the number of columns.
;
xtension = strupcase(fxpar(header, 'XTENSION'))
tfields = fxpar(header, 'TFIELDS')
;
;  Start removing the various keywords relative to the structure of the FITS
;  file.
;
sxdelpar, header, ['SIMPLE', 'EXTEND', 'BITPIX', 'PCOUNT', 'GCOUNT', 'THEAP', $
                   'BZERO', 'BSCALE', 'BUNIT', 'XTENSION', 'TFIELDS']
;
;  Filter out the non-standard or solar-specific coordinate-related keywords,
;  as well as a few WCS keywords.
;
sxdelpar, header, ['SC_ROLL', 'P_ANGLE', 'ANGLE', 'SOLAR_P0', 'XCEN', 'YCEN', $
                   'SOLAR_R', 'SOLAR_B0', 'SOLAR_L0', 'TIME-OBS', 'TIME_OBS', $
                   'DATE-OBS', 'DATE_OBS', 'DATE-AVG', 'DATE_AVG', 'MJD-OBS', $
                   'MJD-AVG', 'OBSGEO-X', 'OBSGEO-Y', 'OBSGEO-Z', 'RESTFREQ', $
                   'CROT', 'CROTA', 'DSUN_OBS', 'HGLN_OBS', 'HGLT_OBS', $
                   'CRLN_OBS', 'CRLT_OBS']
;
;  Get the number of axes as stored in the header.  Then, remove it, and any
;  NAXISnnn keywords implied by it.
;
naxis = fxpar(header, 'NAXIS')
sxdelpar, header, 'NAXIS'
if naxis gt 0 then for i=1,naxis do sxdelpar, header, 'NAXIS'+strtrim(i,2)
;
;  Find any WCSAXESa keywords.  Replace NAXIS with the largest value 
;
tags = strupcase(strtrim(strmid(header,0,8)))
if xtension eq 'BINTABLE' then teststr = 'WCAX' else teststr = 'WCSAXES'
ntest = strlen(teststr)
w = where(strmid(tags,0,ntest) eq teststr, count)
if count gt 0 then begin
    naxis = naxis > fxpar(header, tags[w[i]])
    sxdelpar, header, tags[w]
endif
;
;  Find all the WCS systems within the header, looking for CRPIX1a (or 1CRPna).
;
system = ''
if xtension eq 'BINTABLE' then teststr = '1CRP' else teststr = 'CRPIX1'
ntest = strlen(teststr)
w = where(strmid(tags,0,ntest) eq teststr, count)
if count gt 0 then for i=0,count-1 do begin
    tag = tags[w[i]]
    if strlen(tag) gt (ntest+1) then begin
        suffix = strmid(tag,ntest,strlen(tag)-ntest-1)
        letter = strmid(tag,strlen(tag)-1,1)
        if valid_num(suffix) and (not valid_num(letter)) then $
          system = [system, letter]
    endif
endfor
system = system(sort(system))
system = system(uniq(system))
;
;  Remove the standard WCS coordinate keywords.  Start with binary tables.
;
for isys = 0,n_elements(system)-1 do begin
    if xtension eq 'BINTABLE' then begin
        for ifield = 1,tfields do begin
            sfield = ntrim(ifield)
            for iaxis = 1,naxis do begin
                if system[isys] eq '' then $
                  rem = ['CTYP','CUNI','CRVL','CDLT','CRPX','CROT'] else $
                  rem = ['CTY', 'CUN', 'CRV', 'CDE', 'CRP']
                rem = [rem, 'CNA', 'CRD', 'CSY']
                sxdelpar, header, ntrim(iaxis) + rem + sfield + system[isys]
;
;  Remove the PC and/or CD matrices.
;
                for jaxis = 1,naxis do sxdelpar, header, ntrim(iaxis) + $
                  ntrim(jaxis) + ['PC','CD'] + sfield + system[isys]
;
;  Remove any coordinate parameters.
;
                test = ntrim(iaxis) + 'V' + sfield + '_'
                w = where(strmid(tags,0,strlen(test)) eq test, count)
                if count gt 0 then sxdelpar, header, tags[w]
;
                test = ntrim(iaxis) + 'S' + sfield + '_'
                w = where(strmid(tags,0,strlen(test)) eq test, count)
                if count gt 0 then sxdelpar, header, tags[w]
            endfor
;
;  Remove the parameters which don't depend on the axes.
;
            rem = ['LONP','LATP','WCST','WCSX','EQUI','RADE','RFRQ','RWAV', $
                   'SPEC','SOBS','VSYS','ZSOU','SSRC','VANG']
            sxdelpar, header, rem + sfield + system[isys]
            if system[isys] eq '' then begin
                rem = ['MJDOB','MJDA','DAVG','OBSGX','OBSGY','OBSGZ']
                sxdelpar, header, rem + sfield
            endif
        endfor
;
;  Do the same for ordinary headers.
;
    end else begin
        for iaxis = 1,naxis do begin
            rem = ['CTYPE', 'CUNIT', 'CRVAL', 'CDELT', 'CRPIX', 'CROTA', $
                   'CNAME', 'CRDER', 'CSYER']
            sxdelpar, header, rem + ntrim(iaxis) + system[isys]
;
;  Remove the PC and/or CD matrices.
;
            for jaxis = 1,naxis do sxdelpar, header, ['PC','CD'] + $
              ntrim(iaxis) + '_' + ntrim(jaxis) + system[isys]
;
;  Remove any coordinate parameters.
;
            test = 'PV' + ntrim(iaxis) + '_'
            w = where(strmid(tags,0,strlen(test)) eq test, count)
            if count gt 0 then sxdelpar, header, tags[w]
;
            test = 'PS' + ntrim(iaxis) + '_'
            w = where(strmid(tags,0,strlen(test)) eq test, count)
            if count gt 0 then sxdelpar, header, tags[w]
        endfor
;
;  Remove the parameters which don't depend on the axes.
;
        rem = ['LONPOLE','LATPOLE','WCSNAME','EQUINOX','RADESYS','RESTFRQ', $
               'RESTWAV','SPECSYS','VELOSYS','ZSOURCE','SSYSSRC','VELANGL']
        sxdelpar, header, rem + system[isys]
    endelse
endfor
;
;  For binary tables, remove any column definitions, including the non-standard
;  keywords used by SOHO.
;
if tfields gt 0 then for i=1,tfields do sxdelpar, header, $
  ['TFORM','TTYPE','TDIM','TUNIT','TSCAL','TZERO','TNULL','TDISP','TDMIN', $
   'TDMAX','TDESC','TROTA','TRPIX','TRVAL','TDELT','TCUNI']  + strtrim(i,2)
;
;  Remove keywords associated with the various coordinate systems.
;
csys = ['CAR','GEI','GEO','GSE','GAE','GSM','SM_','MAG','HAE','HEE','HEQ','HCI']
axes = ['X','Y','Z']
for i=0,n_elements(csys)-1 do sxdelpar, header, csys[i] + axes + '_OBS'
;
if n_elements(errmsg) ne 0 then errmsg = ''
return
;
;  Error handling point.
;
HANDLE_ERROR:
if n_elements(errmsg) ne 0 then errmsg = 'WCS_HCLEAN: ' + message else $
  message, message, /continue
end
