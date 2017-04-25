;+
; Name: vis_clean
;
; Purpose: This function returns the clean map including residuals using visibilities
;
; Inputs:
;   - vis - visibility bag  
;   Typical visibility structure for vis, only the fields used in vis_clean marked with ***
;   the operation of vis_clean only depends on the fiels, U, V, OBSVIS, and XYOFFSET
;   This is the RHESSI visibility structure, see this reference for details
;   http://sprg.ssl.berkeley.edu/~tohban/wiki/index.php/User's_Guide_to_RHESSI_Visibilities
;   The values of obsvis, totflux, sigamp, and chi2 are derived within hsi_vis_gen
;   from fitting a sine/cosine profile to the count rates in the calibrated_eventlist as a function of phase for
;   a single position angle bin bin
;    ** Structure HSI_VIS, 15 tags, length=112, data length=102:
;    ISC             INT              0                     Subcollimator index (=0,,,,8)  
;    HARM            INT              1
;    ERANGE          FLOAT     Array[2]                     Energy range (keV) 
;    TRANGE          DOUBLE    Array[2]
;    U               FLOAT          0.220757                 ****  u=East-west spatial frequency component (arcsec^-1)
;    V               FLOAT         0.0105846                 ****  v=North-south spatial frequency component (arcsec^-1)
;    OBSVIS          COMPLEX   (     -570.841,     -1448.74) ****  Observed (semicalibrated) visibility (ph/cm2/s)
;    TOTFLUX         FLOAT           49844.5
;    SIGAMP          FLOAT           2008.48
;    CHI2            FLOAT           1.62104
;    XYOFFSET        FLOAT     Array[2]                      **** West, north heliocentric offset of phase center (arcsec)
;    TYPE            STRING    'photon'
;    UNITS           STRING    'Photons cm!u-2!n s!u-1!n'
;    ATTEN_STATE     INT              3
;    COUNT           FLOAT           75801.4

;   
;
; Keyword inputs:
;   - niter        max iterations  (default 100)
;   - image_dim    number of pixels in x and y, 1 or 2 element long vector or scalar
;       images are square so the second number isn't used
;   - pixel        pixel size in asec (pixels are square)
;   - gain         clean loop gain factor (default 0.05)
;   - clean_box    clean only these pixels (1D index) in the fov
;   - negative_max if set stop when the absolute maximum is a negative value (default 1)
;   - nmap         1/frequency for intermediate plotting
;   - make_map     If set, final map is a map structure
;   - wait_time    Time in seconds for dwelling on intermediate plots
;   - beam_width   psf beam width (fwhm) in asec
;   - noresid      If set, final clean_image output does not have the residuals added in
;   - uniform_weighting      assign weights by uniform weighting which preferentially weights higher spatial
;     frquencies. Takes precedence over the next argument, SPATIAL_FREQUENCY_WEIGHT
;     For natural weighting (no spatial preference) set uniform_weighting to 0 or set
;     spatial_frequency_weight to 1 as a scalar or an array with the same number of elements as the
;     input visibility bag
;   - spatial_frequency_weight - an array with the same number of elements as the input vis bag computed
;     by the user's preference. 
;   
;
; Keyword outputs:
;   - iter
;   - dirty_map    two maps in an [image_dim, 2] array (3 dim), original dirty map first, last unscaled dirty map second
;   - clean_beam   the idealized Gaussian PSF
;   - clean_map    the clean components convolved with normalized clean_beam
;   - clean_components structure containing the fluxes of the identified clean components
;         ** Structure <1ee894d8>, 3 tags, length=8, data length=8, refs=1:
;             IXCTR           INT              0
;             IYCTR           INT              0
;             FLUX            FLOAT            0.00000
;	- clean_sources_map the clean components realized as point sources on an fov map (lik)
;	  - weight_used - weighting factors applied to each visibility based on input
;	Finally make all of the outputs available as a single structure for convenience
;	  - info_struct = { $
;          image: clean_image, $  ;image returned by vis_clean, clean image + residual map convolved with clean beam
;          iter: iter, $
;          dirty_map: dirty_map[*,*,0], $
;          last_dirty_map: dirty_map[*,*,1], $
;          clean_map: clean_map, $
;          clean_components: clean_components, $
;          clean_sources_map: clean_sources_map, $
;          resid_map: resid_map }

; History:
;	12-feb-2013, Anna Massone and Richard Schwartz, based on hsi_map_clean
;	11-jun-2013, Richard Schwartz, identified error in subtracting gain modified psf from
;	 dirty map. Before only psf had been subtracted!!!
;	17-jul-2013, Richard Schwartz, converted beam_width to pixel units for st_dev on call to
;	 psf_gaussian for self-consistency
;	23-jul-2013, Richard Schwartz, added info_struct for output consolidation
;	10-mar-2016, Richard Schwartz, added to the documentation, fixed the propagation of the
;	  spatial weighting to the psf and dirty map, and clarified how the weighting could
;	  be specified. Described the elements of the visibility structure that are used in the construction.
;	
;-


function vis_clean, vis, niter = niter, image_dim = image_dim_in, pixel = pixel, $
  _extra = _extra,  $
  spatial_frequency_weight = spatial_frequency_weight, $
  uniform_weighting = uniform_weighting, $
  
	gain = gain, clean_box = clean_box, negative_max = negative_max, $
	beam_width = beam_width, $
	clean_beam = clean_beam, $
	make_map   = make_map, $
	plot = plot, $
	wait_time = wait_time, $
	nmap = nmap, $
	noresid = noresid, $
	;Outputs
	weight_used = weight_used, $
	iter = iter, dirty_map = dirty_map,$
	clean_map = clean_map, clean_components = clean_components, $
	clean_sources_map = clean_sources_map, $
	resid_map = resid_map, $
	info_struct = info_struct

;clean using vis
;obj->set, _extra=_extra

;image_dim = obj->get(/image_dim)
default, noresid, 0
default, wait_time, 0.2
default, plot, 0
default, make_map, 0
default, image_dim_in, 65
default, pixel, 1.0
negative_max = fix(fcheck(negative_max,1)) > 0 < 1
default, niter, 100
default, gain, 0.05
image_dim = image_dim_in[0]
image_dim = image_dim / 2 *2 + 1 ;forces odd image_dim
default, beam_width, 4. ;convolving beam sigma in asec
;beam_width_factor=fcheck(beam_width_factor,1.0) > 1.0
default, clean_beam, psf_gaussian( npixel = image_dim[0], st_dev = beam_width / pixel, ndim = 2)
default, nmap, 20  ;1/frequency that intermediate maps are plotted 

;realize the dirty map and build a psf at the center, use odd numbers of pixels to center the map
weight_used = vis_spatial_frequency_weighting( vis, spatial_frequency_weight, UNIFORM_WEIGHTING = uniform_weighting )

vis_bpmap, vis, map = dmap0, bp_fov = image_dim[0] * pixel, pixel = pixel, /data_only, $
  spatial_freqency_weight = weight_used

default, clean_box, where( abs( dmap0)+1) ;every pixel is the default
component = {clean_comp,  ixctr: 0, iyctr: 0, flux:0.0}
clean_components = replicate( component, niter) ;positions in pixel units from center

;Now we can begin a clean loop
;Find the max of the dirty map, save the component, subtract the psf at the peak from dirty
iter = 0
clean_map = dmap0 * 0.0
dmap = dmap0
test = 1

while  test do begin
	
	zflux = max(  ( negative_max ? abs( dmap[clean_box] ) : dmap[ clean_box ] ), iz  )

	if dmap[ clean_box[ iz ] ] lt 0 then begin   ;;;;;; only enters if negative_max is set
		test = 0
		break ;leave while loop
  endif
	
	psf = vis_psf( vis, clean_box[iz], pixel = pixel, psf00 = psf00, image_dim = image_dim, $
	  spatial_freqency_weight = weight )
	default, pkpsf, max( psf )
	flux = zflux * gain / pkpsf
	
	dmap[clean_box] -= psf *flux
	izdm = get_ij( iz, image_dim ) ;convert 1d index to 2d form

	clean_components[ iter ] = { clean_comp, izdm[0], izdm[1], flux }
	clean_map[ iz ] += flux
	if keyword_set( plot ) and (iter mod nmap eq 0) then begin
	  pmulti = !p.multi
	  ;!p.multi = [0, 2, 1]
	  plot_image, dmap
	  cleaned_map_iter = convol( clean_map, clean_beam, /norm, /center, /edge_zero)
	  contour, /over, cleaned_map_iter, col=2, thick=2, levels = interpol( minmax( cleaned_map_iter ), 5)
	  wait, wait_time
	  !p.multi = pmulti
	endif

	iter++
	test = iter lt niter
	endwhile



;Convolve with a clean beam
clean_sources_map = clean_map
clean_map = convol( clean_map, clean_beam, /norm, /center, /edge_zero) / pixel^2 ;add pixel^2 to make it per arcsecond^2

resid_map = dmap / total(clean_beam) / pixel^2   
               ;;;; just as in hsi_map_clean normalize the residuals just like the clean image
               ;;;; 11 feb 2013, N.B. in hsi_map_clean the normalization factor, nn, is used on
               ;;;; both residual map and clean map because they do not use convol() as here with /norm
               ;;;; but instead multiply the clean sources by the unnormalized cbm
dirty_map = [[[dmap0]], [[dmap]]] ;original dirty map first, last unscaled dirty map second
;clean_image=clean_map + resid_map
clean_image = noresid ? clean_map : clean_map + convol( resid_map, clean_beam, /norm, /center, /edge_zero)
info_struct = { $
          image: clean_image, $
          iter: iter, $
          dirty_map: dirty_map[*,*,0], $
          last_dirty_map: dirty_map[*,*,1], $
          clean_map: clean_map, $
          clean_components: clean_components, $
          clean_sources_map: clean_sources_map, $
          resid_map: resid_map }
out = make_map ? make_map( clean_image, dx = pixel[0], dy = pixel[0], $
  xcen = vis[0].xyoffset[0], ycen = vis[1].xyoffset[1],  units = 'Photons cm!u-2!n asec!u-2!n s!u-1!n',$
  image_alg = 'vis_clean',$
  time = anytim(/vms, avg(vis[0].trange )), erange=arr2str( string( form='(2f7.2)' ,vis[0].erange ),' - ')+' keV' ): clean_image
  
return, out
end