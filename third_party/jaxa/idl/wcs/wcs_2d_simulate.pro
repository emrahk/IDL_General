;+
; Project     :	STEREO
;
; Name        :	WCS_2D_SIMULATE()
;
; Purpose     :	Create simulated WCS structure for 2D data.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	Creates a simulated WCS structure for 2D data based on various
;               input keywords.  The user is able to specify the type of data
;               (e.g. helioprojective vs. heliographic), the pixel scale, the
;               position and value of the reference pixel, the projection used,
;               the observation date, and the observer position.
;
;               For more complicated cases, some care is needed to select the
;               proper keywords to achieve the desired results.  It's suggested
;               that the user run the resulting WCS structure through
;               wcs_get_coord.pro for verification.
;
; Syntax      :	WCS = WCS_2D_SIMULATE( NX  [, NY ]  [, keywords ... ] )
;
; Examples    :	This example creates a 512x512 Helioprojective-Cartesian image,
;               centered at 570 arcseconds west, and 250 arcseconds north, with
;               a plate scale of 2.5 arcseconds/pixel.
;
;               WCS = WCS_2D_SIMULATE(512, CRVAL=[570, 250], CDELT=2.5)
;
;               This example creates a simulated view from Carrington longitude
;               110 degrees, and latitude 25 degrees, looking down on Sun
;               center from a distance of ~1 A.U.
;
;               WCS = WCS_2D_SIMULATE(512, CDELT=2.5, DSUN_OBS=1.5E11, $
;                       CRLN_OBS=110, CRLT_OBS=25)
;
; Inputs      :	NX = Number of pixels along X (longitude) axis.
;
; Opt. Inputs :	NY = Number of pixels along Y (latitude) axis.  If not passed,
;                    then same as NX.
;
; Outputs     :	WCS = Structure containing World Coordinate System information
;
; Opt. Outputs:	None.
;
; Keywords    :	In all cases, keywords described as "XY values" can either be a
;               two element array giving the X and Y values, or a scaler value
;               which applies equally to both values.
;
;               CRPIX = XY values for reference pixel.  The default is the
;                       array center, i.e. ([NX,NY]+1)/2.
;
;               CRVAL = XY values for the coordinate value at the reference
;                       pixel.  The default is [0,0].
;
;               CDELT = XY values for pixel scale.  Default is [1,1].
;
;               TYPE = Type code for coordinate system, from the following
;                       table.  Default is HP (Helioprojective-Cartesian).
;
;                       HP      Helioprojective-Cartesian
;                       HR      Helioprojective-Radial
;`                      HG      Stonyhurst-Heliographic
;                       CR      Carrington-Heliographic
;                       HCPA    Heliocentric-Radial
;                       SOLX    Heliocentric-Cartesian
;                       RA      Celestial-Equatorial
;                       G       Celestial-Galactic
;                       E       Celestial-Ecliptic
;                       H       Celestial-Helioecliptic
;                       S       Celestial-Supergalactic
;
;               PROJECTION = Projection code.  Default is "TAN", except for
;                       heliographic coordinates, where the default is "CAR".
;
;               CUNIT = XY values for coordinate units.  Default is either
;                       "deg" or "m", except for helioprojective-cartesian,
;                       where the default is "arcsec".  Proper case should be
;                       used.
;
;               Only one of the CROTA, PC, or CD keywords should be used.
;
;               CROTA2 = Rotation angle
;               PC_MATRIX = PC matrix
;               CD_MATRIX = CD matrix
;
;               LONPOLE = Native pole longitude (to override projection default)
;               LATPOLE = Native pole latitude (to override projection default)
;
;               PV1VAL = Array of parameter values for the longitude axis
;                        i.e. PV1_0, PV1_1, etc., rarely used.
;
;               PV1START = Index of first element of PV1VAL.  Default is 0.
;
;               PV2VAL = Array of projection-specific parameter values for the
;                        latitude axis.  For example, if PV2START is not
;                        specified, the first element of PV2VAL will be PV2_1.
;
;               PV2START = Index of first element of PV2VAL.  Since most
;                          projections don't use PV2_0, the default for
;                          PV2START is 1.
;
;               DATE_OBS = Date/time value of DATE-OBS keyword
;               DATE_END = Date/time value of DATE-END keyword
;               DATE_AVG = Date/time value of DATE-AVG keyword
;
;               DSUN_OBS = Observer distance from Sun center
;               HGLN_OBS = Observer Stonyhurst heliographic longitude
;               HGLT_OBS = Observer Stonyhurst heliographic latitude
;               CRLN_OBS = Observer Carrington heliographic longitude
;               CRLT_OBS = Observer Carrington heliographic latitude
;
;               Note that HGLT_OBS and CRLT_OBS are always equal.
;
; Calls       :	FXHMAKE, FXADDPAR, NTRIM, FITSHEAD2WCS, ANYTIM2UTC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 8-Feb-2010, William Thompson, GSFC
;               Version 2, 25-May-2011, WTT, Fixed PC and CD keyword bug
;               Version 3, 15-Feb-2013, WTT, Fixed CD/CDELT keyword ambiguity
;
; Contact     :	WTHOMPSON
;-
;
function wcs_2d_simulate, nx, ny, crpix=crpix, crval=crval, cdelt=cdelt, $
                          type=type, projection=projection, cunit=cunit, $
                          crota2=crota2, pc_matrix=pc, cd_matrix=cd, $
                          lonpole=lonpole, latpole=latpole, $
                          pv1val=pv1val, pv1start=pv1start, $
                          pv2val=pv2val, pv2start=pv2start, $
                          date_obs=date_obs, date_end=date_end, $
                          date_avg=date_avg, dsun_obs=dsun_obs, $
                          hgln_obs=hgln_obs, hglt_obs=hglt_obs, $
                          crln_obs=crln_obs, crlt_obs=crlt_obs
;
on_error, 2
if n_params() lt 1 then message, 'Syntax: wcs = wcs_2d_simulate(nx  [, ny ])'
;
;  Create the basic 2D header structure.
;
fxhmake, hdr, bytarr(2,2)
fxaddpar, hdr, 'naxis1', nx
if n_params() eq 1 then ny = nx
fxaddpar, hdr, 'naxis2', ny
;
;  Add in the CRPIX information.
;
crpix1 = (nx + 1) / 2.
crpix2 = (ny + 1) / 2.
if n_elements(crpix) gt 0 then begin
    crpix1 = crpix[0]
    if n_elements(crpix) eq 1 then crpix2 = crpix1 else crpix2 = crpix[1]
endif
fxaddpar, hdr, 'crpix1', crpix1
fxaddpar, hdr, 'crpix2', crpix2
;
;
;  Add in the CRVAL information.
;
crval1 = 0.
crval2 = 0.
if n_elements(crval) gt 0 then begin
    crval1 = crval[0]
    if n_elements(crval) eq 1 then crval2 = crval1 else crval2 = crval[1]
endif
fxaddpar, hdr, 'crval1', crval1
fxaddpar, hdr, 'crval2', crval2
;
;  Add in the CDELT information.
;
cdelt1 = 1.
cdelt2 = 1.
if n_elements(cdelt) gt 0 then begin
    cdelt1 = cdelt[0]
    if n_elements(cdelt) eq 1 then cdelt2 = cdelt1 else cdelt2 = cdelt[1]
endif
fxaddpar, hdr, 'cdelt1', cdelt1
fxaddpar, hdr, 'cdelt2', cdelt2
;
;  Form the first part of the CTYPE keywords, along with WCSNAME.  Define the
;  default projection, and units.
;
if n_elements(type) eq 0 then type = 'HP'
def_proj = 'TAN'
def_cunit = 'deg'
case strupcase(type) of
    'HP': begin
        coord_type = 'Helioprojective-Cartesian'
        ctype1 = 'HPLN'
        ctype2 = 'HPLT'
        def_cunit = 'arcsec'
    endcase
    'HR': begin
        coord_type = 'Helioprojective-Radial'
        ctype1 = 'HRLN'
        ctype2 = 'HRLT'
    endcase
    'HG': begin
        coord_type = 'Stonyhurst-Heliographic'
        ctype1 = 'HGLN'
        ctype2 = 'HGLT'
        def_proj = 'CAR'
    endcase
    'CR': begin
        coord_type = 'Carrington-Heliographic'
        ctype1 = 'CRLN'
        ctype2 = 'CRLT'
        def_proj = 'CAR'
    endcase
    'HCPA': begin
        coord_type = 'Heliocentric-Radial'
        ctype1 = 'HCPA'
        ctype2 = 'SOLI'
        def_cunit = ['deg','m']
        def_proj = ''
    endcase
    'SOLX': begin
        coord_type = 'Heliocentric-Cartesian'
        ctype1 = 'SOLX'
        ctype2 = 'SOLY'
        def_cunit = 'm'
        def_proj = ''
    endcase
    'RA': begin
        coord_type = 'Celestial-Equatorial'
        ctype1 = 'RA--'
        ctype2 = 'DEC-'
    endcase
    'G': begin
        coord_type = 'Celestial-Galactic'
        ctype1 = 'GLON'
        ctype2 = 'GLAT'
    endcase
    'E': begin
        coord_type = 'Celestial-Ecliptic'
        ctype1 = 'ELON'
        ctype2 = 'ELAT'
    endcase
    'H': begin
        coord_type = 'Celestial-Helioecliptic'
        ctype1 = 'HLON'
        ctype2 = 'HLAT'
    endcase
    'S': begin
        coord_type = 'Celestial-Supergalactic'
        ctype1 = 'SLON'
        ctype2 = 'SLAT'
    endcase
    else: begin
        message, /continue, 'Unrecognized type declaration -- defaulting to HP'
        coord_type = 'Helioprojective-Cartesian'
        ctype1 = 'HPLN'
        ctype2 = 'HPLT'
        def_cunit = 'arcsec'
    endcase
endcase
fxaddpar, hdr, 'wcsname', coord_type
;
;  Apply the projection.
;
if n_elements(projection) eq 0 then projection = def_proj
if projection ne '' then begin
    ctype1 = ctype1 + '-' + strupcase(projection)
    ctype2 = ctype2 + '-' + strupcase(projection)
endif
fxaddpar, hdr, 'ctype1', ctype1
fxaddpar, hdr, 'ctype2', ctype2
;
;  Add in the CUNIT information.
;
if n_elements(cunit) eq 0 then cunit = def_cunit
cunit1 = cunit[0]
if n_elements(cunit) eq 1 then cunit2 = cunit1 else cunit2 = cunit[1]
fxaddpar, hdr, 'cunit1', cunit1
fxaddpar, hdr, 'cunit2', cunit2
;
;  Add in the rotation angle.
;
if n_elements(crota2) eq 1 then fxaddpar, hdr, 'crota2', crota2
;
;  Add in the PC matrix
;
if n_elements(pc) gt 0 then begin
    sz = size(pc)
    if (sz[0] eq 2) and (sz[1] eq 2) and (sz[2] eq 2) then begin
        for i=0,1 do begin
            keyword0 = 'PC' + ntrim(i+1) + '_'
            for j=0,1 do begin
                keyword = keyword0 + ntrim(j+1)
                fxaddpar, hdr, keyword, pc[i,j]
            endfor
        endfor
    end else message, /continue, 'PC matrix must by 2x2 array -- ignoring'
endif
;
;  Add in the CD matrix
;
if n_elements(cd) gt 0 then begin
    sz = size(cd)
    if (sz[0] eq 2) and (sz[1] eq 2) and (sz[2] eq 2) then begin
        for i=0,1 do begin
            keyword0 = 'CD' + ntrim(i+1) + '_'
            for j=0,1 do begin
                keyword = keyword0 + ntrim(j+1)
                fxaddpar, hdr, keyword, cd[i,j]
            endfor
        endfor
    end else message, /continue, 'CD matrix must by 2x2 array -- ignoring'
endif
;
;  Add in the LONPOLE and LATPOLE values.
;
if n_elements(lonpole) eq 1 then fxaddpar, hdr, 'LONPOLE', lonpole
if n_elements(latpole) eq 1 then fxaddpar, hdr, 'LATPOLE', latpole
;
;  Add in the PV values associated with the longitude axis.
;
if n_elements(pv1val) gt 0 then begin
    if n_elements(pv1start) eq 0 then pv1start = 0
    for i=0,n_elements(pv1val)-1 do begin
        keyword = 'PV1_' + ntrim(i + pv1start)
        fxaddpar, hdr, keyword, pv1val[i]
    endfor
endif
;
;  Add in the PV values associated with the latitude axis.
;
if n_elements(pv2val) gt 0 then begin
    if n_elements(pv2start) eq 0 then pv2start = 1
    for i=0,n_elements(pv2val)-1 do begin
        keyword = 'PV2_' + ntrim(i + pv2start)
        fxaddpar, hdr, keyword, pv2val[i]
    endfor
endif
;
;  Add in the time keywords.
;
if n_elements(date_obs) eq 1 then fxaddpar, hdr, 'DATE-OBS', $
  anytim2utc(date_obs, /ccsds)
if n_elements(date_end) eq 1 then fxaddpar, hdr, 'DATE-END', $
  anytim2utc(date_end, /ccsds)
if n_elements(date_avg) eq 1 then fxaddpar, hdr, 'DATE-AVG', $
  anytim2utc(date_avg, /ccsds)
;
;  Add in the observer position keywords.
;
if n_elements(dsun_obs) eq 1 then fxaddpar, hdr, 'DSUN_OBS', dsun_obs
if n_elements(hgln_obs) eq 1 then fxaddpar, hdr, 'HGLN_OBS', hgln_obs
if n_elements(hglt_obs) eq 1 then fxaddpar, hdr, 'HGLT_OBS', hglt_obs
if n_elements(crln_obs) eq 1 then fxaddpar, hdr, 'CRLN_OBS', crln_obs
if n_elements(crlt_obs) eq 1 then fxaddpar, hdr, 'CRLT_OBS', crlt_obs
;
;  Form the WCS header, and return.
;
return, fitshead2wcs(hdr)
end
