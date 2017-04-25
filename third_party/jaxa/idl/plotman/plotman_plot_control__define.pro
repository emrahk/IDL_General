;+
; Name:  plotman_plot_control__define
;
; Purpose: Define structure for plotman plot control parameters
;
; Kim Tolbert   Jan 2000
; Modifications:
;	10 Aug 2000, Added channels
;	26 Sep 2000, Added surface stuff, charsize
;       Kim, 21-Apr-2001.  Changed plot control tags from r,g,b to rcolors,...
;		Kim, 1-May-2001.  Changed dim1_unit to dim1_name
;		Kim, 8-Jul-2001.  Made overlay_panel an array
;		Kim, 30-Aug-2001.  Added mark_limb option
;		Kim, 2-Sep-2001.  Added legend_color, translate_overlay
;		Kim, 22-Jan-2002.  Added mark_pointing option
;   	20-Feb-2002, Kim.  Added user_label option
;		2-Mar-2002, Kim.  Added more_commands option
;		27-May-2002, Kim.  Added derivative option
;		21-Jul-2001, Kim.  Added contour_percent, contour_thickness options
;		19-Sep-2002, Kim.  Added integral option
;		01-Nov-2002, Kim.  Added grid_spacing option
;       05-Nov-2002, Kim.  Add grid_color, limb_color, and translate_image options
;		22-Nov-2002, Kim.  Changed mark_limb to limb_mark for compatibility with map objects
;		24-Nov-2002, KIm.  Changed log_image, square_image to log_scale, square_scale
;		24-Nov-2002, Kim.  Renamed limb_mark to limb_plot
;		27-Jun-2003, Kim.  Added smooth_spec, exp_scale for spectrograms
;		22-Feb-2004, Kim.  Added contour_label, contour_style, overlay_thickness, overlay_label,
;	   overlay_style, n_overlay_levels, overlay_percent, overlay_levels, and
;	   limb_thickness plot control parameters
;		30-Jun-2004, Kim.  Added no_timestamp plot control parameter
;		17-Jun-2005, Kim.  Changed smooth_spec to interpolate to match specplot__define
;		06-Aug-2005, Kim.  Added grid_thickness option
;		9-May-2007, Kim. Removed translate_image, contour_color, contour_thickness,
;		contour_levels, contour_percent,n_contour_levels, contour_label, contour_style. All
;		info for contour of primary image is now stored in the overlay params for overlay[0].
;		Added overlay_ulabel, overlay_ulabel_lev.
;		16-May-2008, Kim.  Added overlay_squish  (don't leave space between stacked overlays)
;   22-Aug-2008, Kim.  Changed rescale_image to rescale_zoom
;   26-Aug-2008, Kim.  Added overlay_roll, overlay_scale, and changed smooth_image to have 2x4 elements
;   20-Jan-2009, Kim. Increased # overlays from 4 to 13 and added nmax_overlay params
;   06-Sep-2012, Kim. Added overlay_ysize
;   08-Mar-2015, Kim. Added overlay_nolabel
;-
;--------------------------------------------------------------------------------------------------

pro plotman_plot_control__define

color_names = {plotman_color_names, $
					violet: 239, $
					lime: 240, $
					black: 241, $
					maroon: 242, $
					red: 243, $
					pink: 244, $
					orange: 245, $
					yellow: 246, $
					olive: 247, $
					green: 248, $
					dkgreen: 249, $
					cyan: 250, $
					blue: 251, $
					dkblue: 252, $
					magenta: 253, $
					purple: 254, $
					white: 255 }

nmax_overlay = 13

plot_control = {plotman_plot_control, $

	xx: !x, $
	yy: !y, $
	zz: !z, $
	pp: !p, $

	xlog: 0, $
	ylog: 0, $

	plot_args: ptr_new (), $	;string with additional arguments to plot routine
	plot_type: '', $			;'image', 'xyplot', or 'utplot'
	utbase: 0.d0, $				;start time of data
	utrange: [0.d0, 0.d0], $	;full time range of data
	timerange: [0.d0, 0.d0], $	;user-selected time range. subset of utrange

	color_file: '', $
	rcolors: bytarr(256), $
	gcolors: bytarr(256), $
	bcolors: bytarr(256), $
	color_names: {plotman_color_names}, $
	bottom: 0, $
	ncolors: 0, $	; bad name!  This is actually the highest index used, so # is ncolors+1
	wcolors: 0, $
	;charsize: 0., $
	cbar: 1, $
	smooth_image: intarr(2,nmax_overlay), $
	interpolate: 0, $
	log_scale: 0, $
	exp_scale: 0, $
	limb_plot: 0, $
	grid_spacing: 0., $
	grid_thickness: 0., $
	square_scale: 0, $
	contour_image: 0, $
;	translate_image: fltarr(2), $
  nmax_overlay: nmax_overlay, $  ; max number of overlays allowed.  13 as of 20-jan-09
	overlay_panel: strarr(nmax_overlay), $
	overlay_stack: 0, $
	overlay_color: intarr(nmax_overlay), $
	drotate_image: intarr(nmax_overlay), $
	overlay_roll: fltarr(nmax_overlay), $
	overlay_scale: fltarr(2,nmax_overlay), $
	translate_overlay: fltarr(2,nmax_overlay), $
	overlay_thickness: fltarr(nmax_overlay), $
	overlay_label: intarr(nmax_overlay), $
	overlay_style: intarr(nmax_overlay), $
	n_overlay_levels: intarr(nmax_overlay), $
	overlay_levels: fltarr(25,nmax_overlay), $
	overlay_percent: intarr(nmax_overlay), $
	overlay_nolabel: intarr(nmax_overlay), $
	overlay_ulabel: strarr(nmax_overlay), $
	overlay_ulabel_lev: intarr(nmax_overlay), $
	overlay_ysize: intarr(nmax_overlay), $
	overlay_squish: 0, $
	shade_surf_image: 0, $
	surface_image: 0, $
	show3_image: 0, $
	ax_surface: 0., $
	az_surface: 0., $
	pos_image: 0, $
	neg_image: 0, $
	rescale_zoom: 0, $
	grid_color: color_names.red, $
	limb_color: color_names.yellow, $
	limb_thickness: 1., $
	axis_color: color_names.white, $
;	contour_color: color_names.red, $
;	contour_thickness: 1., $
;	contour_levels: fltarr(25), $
;	contour_percent: 0, $
;	n_contour_levels: 0, $
;	contour_label: 0, $
;	contour_style: 0, $
	mark_point: 0, $
	dim1_name: '', $	; like 'Time Intervals' or 'Energy Bands'
	dim1_ids: ptr_new(), $
	dim1_use: ptr_new(), $
	dim1_colors: ptr_new(), $
	dim1_linestyles: ptr_new(), $
	dim1_enab_sum: 0, $
	dim1_sum: 0, $
	derivative: 0, $
	integral: 0, $
	fill_gaps: 0, $ ; 1 = fill gaps in xy and ut plots by interpolating
	legend_loc: 0, $	; 0/1/2/3/4 = no legend, upper left, upper right, lower left, lower right
	legend_color: 0, $
	no_timestamp: 0, $
	user_label: '', $
	more_commands: ptr_new()}

end