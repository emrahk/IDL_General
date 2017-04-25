;+
; Project     :	STEREO
;
; Name        :	WCS2FITSHEAD()
;
; Purpose     :	Generate FITS header from WCS structure
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure takes a WCS structure and converts it into a
;               either a FITS header or index structure.  Information from the
;               original header can also be folded in.
;
; Syntax      :	Header = WCS2FITSHEAD( WCS  [, DATA ] )
;
; Examples    :	Header = WCS2FITSHEAD( WCS, DATATYPE=3 )
;
; Inputs      :	WCS     = Structure containing World Coordinate System
;                         information.  See FITSHEAD2WCS for more information.
;
; Opt. Inputs :	DATA    = Data array associated with WCS.  This is used only to
;                         determine the data type for setting BITPIX.
;
; Outputs     :	The result of FITS header generated from the WCS.
;               Alternatively can be returned as an index structure via
;               FITSHEAD2STRUCT.
;
; Opt. Outputs:	None.
;
; Keywords    :	DATATYPE = The IDL numerical type code of the data array.  Used
;                          to determine BITPIX.  If passed, then overrides the
;                          DATA parameter.
;
;               BUNIT    = String variable describing the units of the data.
;
;               ADD_XCEN = Add the SolarSoft mapping keywords XCEN, YCEN.  When
;                          applied to an N-dimensional array, the center pixel
;                          along *ALL* the axes is used to calculate the
;                          result.
;
;               ADD_ROLL = Add the nonstandard keyword CROTA (without a number)
;                          to the FITS header.  Ignored if the WCS does not
;                          contain a roll value.
;
;               OLDHEAD  = The original FITS header, in either string array or
;                          index structure format.  Annotative keywords from
;                          OLDHEAD are folded into the result, while keywords
;                          related to the data coordinates or values are
;                          filtered out.
;
;               STRUCTURE= If set, then the result is returned as an index
;                          structure.
;
;               EXTEND   = If set, then the keyword EXTEND=T is added to the
;                          header.
;
;               DATE     = If set, then the DATE keyword is added to the
;                          header.
;
; Calls       :	FXHMAKE, FXADDPAR, TAG_EXIST, STRUCT2FITSHEAD, FXPAR,
;               FITSHEAD2STRUCT
;
; Common      :	None.
;
; Restrictions:	Currently only supports one WCS structure at a time.
;
; Side effects:	Some keywords relating to coordinates from OLDHEAD may show up
;               in the output.  This is particularly true for non-standard
;               keywords.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 19-Sep-2006, William Thompson, GSFC
;               Version 2, 13-Apr-2011, WTT, added GAE for SDO
;
; Contact     :	WTHOMPSON
;-
;
function wcs2fitshead, wcs, data, datatype=k_datatype, oldhead=k_oldhead, $
                       structure=structure, bunit=bunit, add_xcen=add_xcen, $
                       add_roll=add_roll, _extra=_extra
;
;  Check the input parameters.
;
if n_params() lt 1 then begin
    message = 'Syntax: Header = WCS2FITSHEAD( WCS )'
    goto, handle_error
endif
if not valid_wcs(wcs) then begin
    message = 'Input not recognized as WCS structure'
    goto, handle_error
endif
;
;  Make a minimal FITS header.
;
fxhmake, header, _extra=_extra
;
;  Add the size parameters from the WCS structure.
;
naxes = n_elements(wcs.naxis)
fxaddpar, header, 'NAXIS', naxes
for i=0,naxes-1 do fxaddpar, header, 'NAXIS' + ntrim(i+1), wcs.naxis[i]
;
;  If the DATATYPE keyword was passed, then use that to set the BITPIX
;  parameter.  If the DATA parameter was passed, then use it to derive
;  DATATYPE.
;
type = 0
if n_elements(k_datatype) eq 1 then type = k_datatype else $
  if n_elements(data) gt 0 then type = datatype(data, 2)
if type gt 0 then begin
    case type of
        1:  begin
            bitpix = 8
            comment = 'Integer*1 (byte)'
        end
        2:  begin
            bitpix = 16
            comment = 'Integer*2 (short integer)'
        end
        3:  begin
            bitpix = 32
            comment = 'Integer*4 (long integer)'
        end
        4:  begin
            bitpix = -32
            comment = 'Real*4 (floating point)'
        end
        5:  begin
            bitpix = -64
            comment = 'Real*8 (double precision)'
        end
;
;  Unsigned data types may require use of BZERO/BSCALE--handled in writer.
;
        12: begin               ;Unsigned integer
            bitpix = 16
            comment = 'Integer*2 (short integer)'
        end
        13:  begin              ;Unsigned long integer
            bitpix = 32
            comment = 'Integer*4 (long integer)'
        end
        else:  begin
            message = "Unsupported data type"
            goto, handle_error
        end
    endcase
    fxaddpar, header, 'BITPIX', bitpix, comment
endif
;
;  Add in the BUNIT parameter, if desired.
;
if n_elements(bunit) eq 1 then fxaddpar, header, 'BUNIT', bunit
;
;  Add in the WCSNAME parameter.
;
fxaddpar, header, 'WCSNAME', wcs.wcsname
;
;  Add in the axis information.
;
for i=0,naxes-1 do begin
    iaxis = ntrim(i + 1)
    fxaddpar, header, 'CRPIX'+iaxis, wcs.crpix[i]
    fxaddpar, header, 'CRVAL'+iaxis, wcs.crval[i]
    fxaddpar, header, 'CTYPE'+iaxis, wcs.ctype[i]
    fxaddpar, header, 'CUNIT'+iaxis, wcs.cunit[i]
    if wcs.variation ne 'CD' then fxaddpar, header, 'CDELT'+iaxis, wcs.cdelt[i]
endfor    
;
;  Add in either the roll angle, or the PC or CD matrix.
;
if wcs.variation eq 'CROTA' then begin
    fxaddpar, header, 'CROTA' + ntrim(wcs.iy+1), wcs.roll_angle
end else begin
    for i=0,naxes-1 do begin
        iaxis = ntrim(i + 1)
        for j=0,naxes-1 do begin
            jaxis = ntrim(j + 1)
            if wcs.variation eq 'CD' then $
              fxaddpar, header, 'CD'+iaxis+'_'+jaxis, wcs.cd[i,j] else $
              fxaddpar, header, 'PC'+iaxis+'_'+jaxis, wcs.pc[i,j]
        endfor
    endfor
endelse
;
;  Add in any of the special projection parameters.
;
if tag_exist(wcs,'proj_names') then $
  for i=0,n_elements(wcs.proj_names)-1 do $
  fxaddpar, header, wcs.proj_names[i], wcs.proj_values[i]
;
;  Add in the keywords from the TIME substructure.
;
if tag_exist(wcs, 'time') then begin
    tags = ['FITS_DATE','OBSERV_DATE','OBSERV_END','OBSERV_MID','OBSERV_AVG', $
            'CORRECTED_DATE','CORRECTED_END','CORRECTED_MID','CORRECTED_AVG', $
            'EXPTIME','MJD_OBS','MJD_AVG','EQUINOX','EPOCH','RADESYS']
    keys = ['DATE','DATE-OBS','DATE-END','DATE-MID','DATE-AVG','DATE_OBS', $
            'DATE_END','DATE_MID','DATE_AVG','EXPTIME','MJD-OBS','MJD-AVG', $
            'EQUINOX','EPOCH','RADESYS']
    for i=0,n_elements(tags)-1 do begin
        if tag_exist(wcs.time, tags[i]) then begin
            if not execute('value = wcs.time.' + tags[i]) then begin
                message, 'Unable to extract TIME tag ' + tags[i]
                goto, handle_error
            endif
            fxaddpar, header, keys[i], value
        endif
    endfor
endif
;
;  Add in the keywords from the POSITION substructure.
;
if tag_exist(wcs, 'position') then begin
    tags = ['DSUN_OBS','SOLAR_B0','HGLN_OBS','HGLT_OBS','CRLN_OBS','CRLT_OBS']
    for i=0,n_elements(tags)-1 do begin
        if tag_exist(wcs.position, tags[i]) then begin
            if not execute('value = wcs.position.' + tags[i]) then begin
                message, 'Unable to extract POSITION tag ' + tags[i]
                goto, handle_error
            endif
            fxaddpar, header, tags[i], value
        endif
    endfor
    if wcs.position.soho then fxaddpar, header, 'TELESCOP', 'SOHO'
;
    tags = ['GEI_OBS','GEO_OBS','GSE_OBS','GAE_OBS','GSM_OBS','SM_OBS',$
            'MAG_OBS','HAE_OBS','HEE_OBS','HEQ_OBS','HCI_OBS']
    xyz = ['X','Y','Z']
    for i=0,n_elements(tags)-1 do begin
        if tag_exist(wcs.position, tags[i]) then begin
            if not execute('value = wcs.position.' + tags[i]) then begin
                message, 'Unable to extract POSITION tag ' + tags[i]
                goto, handle_error
            endif
            prefix = strmid(tags[i], 0, strpos(tags[i], '_'))
            for j=0,n_elements(value)-1 do $
              fxaddpar, header, prefix + xyz[j] + '_OBS', value[j]
        endif
    endfor
endif
;
;  Add in the keywords from the SPECTRUM substructure.
;
if tag_exist(wcs, 'spectrum') then begin
    tags = ['RESTFRQ', 'RESTWAV', 'SPECSYS', 'SSYSOBS', 'OBSGEO_X', $
            'OBSGEO_Y', 'OBSGEO_Z', 'VELOSYS', 'ZSOURCE', 'SSYSSRC', $
            'VELANGL']
    for i=0,n_elements(tags)-1 do begin
        if tag_exist(wcs.spectrum, tags[i]) then begin
            if not execute('value = wcs.spectrum.' + tags[i]) then begin
                message, 'Unable to extract SPECTRUM tag ' + tags[i]
                goto, handle_error
            endif
            fxaddpar, header, tags[i], value
        endif
    endfor
endif
;
;  If requested, add in the keywords XCEN, YCEN.
;
if keyword_set(add_xcen) then begin
    pix = (wcs.naxis - 1.) / 2.
    coord = wcs_get_coord(wcs,pix)
    xcen = coord[wcs.ix]
    case wcs.cunit[wcs.ix] of
        'arcmin': xcen = xcen * 60
        'arcsec': xcen = xcen
        'mas':    xcen = xcen * 1000
        'rad':    xcen = xcen * (!dpi/180.d0) * 3600
        else:     xcen = xcen
    endcase
    fxaddpar, header, 'XCEN', xcen
    ycen = coord[wcs.iy]
    case wcs.cunit[wcs.iy] of
        'arcmin': ycen = ycen * 60
        'arcsec': ycen = ycen
        'mas':    ycen = ycen * 1000
        'rad':    ycen = ycen * (!dpi/180.d0) * 3600
        else:     ycen = ycen
    endcase
    fxaddpar, header, 'YCEN', ycen
endif
;
;  If requested, add in the non-standard keyword CROTA (no number).
;
if keyword_set(add_roll) and tag_exist(wcs, 'roll_angle') and $
  (wcs.variation ne 'CROTA') then fxaddpar, header, 'CROTA', wcs.roll_angle
;
;  Incorporate keywords from the old header.
;
if n_elements(k_oldhead) gt 0 then begin
;
;  Make sure the old header is a string array.
;
    case datatype(k_oldhead,1) of
        'String': oldhead = k_oldhead
        'Structure': oldhead = struct2fitshead(k_oldhead)
        else: begin
            message = 'OLDHEAD must be either a string or a structure'
            goto, handle_error
        endcase
    endcase
;
;  Clean the header, and extract the tag names.
;
    wcs_hclean, oldhead
    tags = strupcase(strtrim(strmid(oldhead,0,8)))
;
;  Step through the tag names, and append any that aren't already in the
;  header.
;
    quiet = !quiet
    !quiet = 1
    for i=0,n_elements(tags)-1 do begin
        test = fxpar(header, tags[i], count=count0)
        if count0 eq 0 then begin
            value = fxpar(oldhead, tags[i], count=count, comment=comment)
            if tags[i] eq '' then begin
                w = where(value ne '', count)
                if count gt 0 then begin
                    value = value[w]
                    comment = comment[w]
                endif
            endif
            if count gt 0 then for j=0,count-1 do $
              fxaddpar, header, tags[i], value[j], comment[j]
        endif
    endfor
    !quiet = quiet
endif
;
;  If requested, convert to an index structure, and return.
;
if keyword_set(structure) then header=fitshead2struct(header)
return, header
;
;  Error handling point.
;
HANDLE_ERROR:
if n_elements(errmsg) ne 0 then errmsg = 'WCS_RECTIFY: ' + message else $
  message, message, /continue
end
