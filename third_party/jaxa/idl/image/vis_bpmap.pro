function vis_bpmap_get_spatial_weights, visin, $
  spatial_frequency_weight, uniform_weighting=uniform_weighting,$
  error=error, err_msg=err_msg

default, uniform_weighting, 0
default, spatial_frequency_weight, fltarr(n_elements(visin))+1.0
spatial_frequency_weight = vis_spatial_frequency_weighting( visin, spatial_frequency_weight, $
  uniform_weighting=uniform_weighting,$
  error=error, err_msg=err_msg)
;nvis = n_elements(visin)
;isc  =  get_uniq( visin.isc)
;nisc = n_elements( isc )
;default, spatial_frequency_weight, fltarr(nvis)+1.0
;
;
;;mapcenter = total(visin.xyoffset,2)/nvis    ; =[xcenter,ycenter] this  will be moved to if and where it is used
;;and the mapcenter is reform(visin[0].xyoffset)
;;spatial_frequency_weight = FLTARR(9) + 1.           ; Default corresponding to NATURAL WIEGHTING
;if keyword_set(uniform_weighting) then spatial_frequency_weight = $ ;rhessi specific (3^(FINDGEN(9)+1.))^(-0.5)        ; UNIFORM WEIGHTING
;	;just use u and v from the visibilities
;	sqrt( visin.u^2 + visin.v^2)
;nsfw = n_elements(spatial_frequency_weight)
;if nsfw ne nvis then begin
;	case 1 of
;		nsfw eq nisc: begin ;match each sc with each sfw in order
;		sfw = fltarr(nvis)
;		weight = fltarr(max(isc))
;		weight[isc] = spatial_frequency_weight
;		spatial_frequency_weight = weight[visin.isc]
;		end
;		nsfw eq 9 and max(isc) le 8: $ ;In case they are RHESSI weights
;		spatial_frequency_weight = spatial_frequency_weight[visin.isc]
;		else: message, 'Inconsistent number of spatial_frequency_weights'
;		endcase
;	endif


;normalize spatial weights
spatial_frequency_weight /= total(spatial_frequency_weight)
return, spatial_frequency_weight
end

function vis_bpmap_get_xypi, npx, pixel, verbose=verbose

common xypi_com, xypi, npx_sav, pixel_sav
default, verbose, 0
;Check for new npx or pixel and make the xypi if they have changed
if ~same_data( npx_sav, long(npx)) || ~same_data( pixel_sav, float(pixel)) then begin
;The next line works for even or odd npx, ras, 14-feb-2013
	xypi  = Reform( ( Pixel_coord( [npx, npx] ) ), /overwrite, 2, npx, npx ) * (-2.0 * !pi * pixel) ;
	pixel_sav = float(pixel)
	npx_sav = long(npx)
	if verbose then help, xypi
Endif
return, xypi
end

;+
; Project:
;	Gen/Image
; Name:
;	VIS_BPMAP
; Purpose:
;	This procedure makes and optionally displays a backprojection map from a visibility bag
; Calling Sequence:
;	vis_bpmap, visin,time=time,_EXTRA=extra,BP_FOV=bp_fov, PIXEL=pixel, MAP=map, $
;	    QUIET=quiet, PEAKXY=peakxy, NOPLOT=noplot, EDGEFLAG=edgeflag,  $
;	    label=label, UNIFORM_WEIGHTING=uniform_weighting, spatial_freqency_weight =spatial_frequency_weight, $
;	    data_only = data_only, $
;	    LOOPSTYLE = loopstyle, $
;	    _EXTRA=_extra
; Inputs:
;	Visin - visibility bag.  See {hsi_vis} for a compliant structure, must have
;		fields, isc, u, v, and obsvis
;		IDL> help, {hsi_vis},/st
;		** Structure HSI_VIS, 15 tags, length=104, data length=94:
;		ISC             INT              0
;		HARM            INT              0
;		ERANGE          FLOAT     Array[2]
;		TRANGE          DOUBLE    Array[2]
;		U               FLOAT          0.000000
;		V               FLOAT          0.000000
;		OBSVIS          COMPLEX   (     0.000000,     0.000000)
;		TOTFLUX         FLOAT          0.000000
;		SIGAMP          FLOAT          0.000000
;		CHI2            FLOAT          0.000000
;		XYOFFSET        FLOAT     Array[2]
;		TYPE            STRING    ''
;		UNITS           STRING    ''
;		ATTEN_STATE     INT              0
;		COUNT           FLOAT          0.000000
; Outputs:
;	Map - flat array back projection map or map structure if DATA_ONLY is set to 0
;		Overall normalization is arbitrary.
; Keywords
;
; /QUIET suppresses  output to the screen, default is 1
; /NOPLOT suppresses plot output, default is 1
; DATA_ONLY - default is 1, if set, return a flat array, otherwise a map structure
; PEAKXY = 2-element vector to receive location of |map| maximum
; EDGEFLAG is set to -1 if peak map pixel is at one edge of the map.  In that case, peakxy is not interpolated
; LABEL = plot title (Default is current time.)
; UNIFORM_WEIGHTING - 0/1 default is 0,
;   changes subcollimator weighting from default (NATURAL) to UNIFORM
;	  setting to 0 uses NATURAL weighting, either sets SPATIAL_FREQUENCY_WEIGHT
; BP_FOV = field of view (arcsec) Default = 80. arcsec
; SPATIAL_FREQUENCY_WEIGHT - weighting for each collimator, set by UNIFORM_WEIGHTING if used
;	The number of weights should either equal the number of unique sub-collimators or the number of visibilities
; 	Also, the default RHESSI case is supported, passing 9 weights and the ones for each sc are selected from those
; LOOPSTYLE- for debugging, if set supports original style of bp computation in hsi_vis_bpmap
; History
; 14-feb-13 ras Originally developed for RHESSI, as hsi_vis_bpmap, but this adaptation is generic for any visibility bag
;		with u, v, and obsvis
;		Vectorized computation of the xy pixel values and scaled them by -2 * !pi
;               Also fixed centering of xy pixels for odd npx
; 18-jul-2013, ras, cleaned up documentation, use vis_spatial_frequency() function in vis_bpmap_get_spatial_weights()
; 23-jul-2013, ras, changed arg_present(peakxy) to exist(peakxy)
;-
PRO vis_bpmap, visin,  MAP = map, $
    BP_FOV = bp_fov, PIXEL = pixel, $
    QUIET = quiet, PEAKXY = peakxy, NOPLOT = noplot, EDGEFLAG = edgeflag,  $
    label = label, time = time, $
    UNIFORM_WEIGHTING = uniform_weighting, spatial_freqency_weight = spatial_frequency_weight, $
    data_only = data_only, $
    LOOPSTYLE = loopstyle, $
    _EXTRA =_extra

default, bp_fov,   80
default, pixel,    bp_fov/200.
default, quiet,  1
default, noplot, 1
default, data_only, 1
default, loopstyle, 0
default, uniform_weighting, 0
fov = bp_fov
npx = fov / pixel
map = fltarr( npx, npx )
;For RHESSI case, preserve 9 spatial weights if they are passed
spatial_frequency_weight = vis_bpmap_get_spatial_weights( visin, spatial_frequency_weight, $
	uniform_weighting = uniform_weighting)

xypi = vis_bpmap_get_xypi( npx, pixel ) ;reuses xypi when possible. reuse if npx and pixel are the same
ic   = complex(0.0, 1.0) ; imaginary 1
nvis = n_elements(visin)
if loopstyle then begin
	for nv = 0, nvis-1 do begin
		;for ix = 0, npx-1 do uv[ix,*] = (visin[nv].u*xypi[ix] + visin[nv].v*xypi)
		uv = reform( /over, visin[nv].u * xypi[0,*,*] + visin[nv].v * xypi[1,*,*] )
		map += spatial_frequency_weight[nv] * float( visin[nv].obsvis * complex( cos( uv ), sin(uv) ) )
		endfor
	endif else begin

	npx2  = long(npx)^2
	phase = visin.u # reform( xypi[0,*,*], npx2) + visin.v # reform( xypi[1,*,*], npx2)
	map    = float( (spatial_frequency_weight * visin.obsvis) # exp( ic * phase ))
	map    = reform( map, /over, npx, npx )
	endelse

mapcenter = reform(visin[0].xyoffset)

; Optionally find map peak location
if exist(peakxy) then begin
    ; Save map extrema
    mapmax          = MAX(map, ixymax)
    mapmin          = MIN(map, ixymin)
    iymax = fix(ixymax / npx)
    ixmax = ixymax mod npx
    edgeflag = 0
    if ixmax eq 0 or ixmax eq npx-1 or iymax eq 0 or iymax eq npx-1 then begin
        ixyint = [0,0]                                                               ; if peak pixel is at map edge
        edgeflag = -1
    endif else ixyint = parapeak( map[ixmax-1:ixmax+1, iymax-1:iymax+1])          ; otherwise interpolate map peak index
    peakxy = mapcenter + pixel * ([ixmax,iymax]+ixyint[0:1]) - pixel*npx/2.
endif

;Map is a map structure unless DATA_ONLY is set. Default is 0
if ~data_only then begin
	;
	;
	if keyword_set(quiet)  eq 0 then message, 'dmax='+dmax+', dmin='+dmin,/info
	map = make_map(map, xc=mapcenter[0], yc=mapcenter[1], dx=pixel, dy= pixel, fov=fov, xunits='arcsec', yunits='arcsec',time=time)

	if ~noplot then begin
		if n_elements(label) eq 0 then label = map.time
		loadct, 5, /silent
		plot_map, map,/limb,_extra=extra,title=label
		endif
	;

endif


END


