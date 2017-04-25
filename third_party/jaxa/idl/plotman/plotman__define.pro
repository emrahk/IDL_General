;+
;
; Name:  plotman
;
; Project:  HESSI
;
; Purpose: Generic plot handling package.
;
; Explanation:  PLOTMAN provides access to standard IDL plotting
;   options for (almost) any data set.  Options for zooming, log scale,
;   image representation and much more are available.  Also offers
;   standard output options such as printing the plot, saving in a
;   file, or printing the data in a text file.  Most options are accessed
;   through the pulldown buttons at the top of the PLOTMAN window.
;   In addition, you can right-click in any plot to display the
;   coordinates of a point, or left-click and drag a box to zoom in
;   on any plot.  A single left-click with no dragging will restore
;   the original plot limits.  The entire plotman window can be stretched
;   by dragging the edges of the window, and the current plot will be
;   redraw in the new window.  
;
;   PLOTMAN is implemented as an object of class 'plotman'
;   The required input to the object are the data (object or array) and
;   the plot type.
;
;   PLOTMAN can be called to run as a standalone widget program, or as part
;   of another program (if mainbase keyword is passed).  If standalone, a
;   widget base is created with pulldown menus and a draw widget.  If
;   part of another program, then the main program should have already
;   created the widget base with at least a file pulldown menu, and the
;   plotman controls are integrated into the existing widget base (this is
;   done in the hessi GUI and OSPEX)
;   
;   Users can set preferences (defaults) for most plot options by using the File /
;   Set Plot Preferences button.  These will persist from session to session.  Also
;   users can change options on multiple existing panels simultaneously by using options
;   under Window_control / Multi-Panel Options /Change Plot Options.
;
; Calling sequence:
;     obj = plotman()  ;creates an empty plotman instance
;     obj = plotman (input=input, plot_type=plot_type, desc=desc) ; creates a plotman instance and plots the input data
;   Once the plotman object is created, new panels can be added by calling:
;	    obj -> new_panel, input=input, plot_type=plot_type, desc=desc
;
;   Can call plotman or new_panel with most of standard plot keywords to set defaults, including
;   plot parameters that aren't available in plotman widget (like xtitle).
;
;   To retrieve parameters that are set in plotman object for currently active panel, use get method.  (can
;      get all tags that are in plotman self structure or any nested structures)
;      e,g. print,obj->get(/charsize)
;
;   Input Keywords:
;
;	INPUT - (required either in plotman call or new_panel call) input data to
;     plotman.  Although input can be data objects or simple arrays of data, we recommend that
;     you use object input.  You have more flexibility and control with object input.  If you're
;     starting from arrays, you can easily insert your data into the appropriate generic
;     object types handled by plotman.  
;      
;     If object, must be one of the following classes:  UTPLOT, XYPLOT, SPECPLOT, MAP or
;       any RHESSI object class.  Unknown object classes have not been tested, but must at least
;       must conform to the rules listed below.  Also see below for examples of creating 
;       the generic objects from data arrays.
;       
;	  If INPUT is not an object, then for plot type:
;       'image' - input is a 2-d array of the image or a map structure.  The easiest way to 
;         supply axis, pixel size, etc. information to plotman is to put the image into 
;         a map structure (or object).
;       'utplot' - input is a 2-d array where data(*,0) are the times and
;         data(*,1) are the y values.  Either time array must be absolute
;         times (fully referenced, type double-precision) or utbase must also
;         be passed in.
;       'xyplot' - input is a 2-d array where data(*,0) are the x values and
;         data(*,1) are the y values.
;       'specplot' - spectrogram array
;
;   PLOT_TYPE - (required in plotman or new_panel call) type of data to plot = 'image', 'utplot', 'xyplot', or 'specplot'
;   
;   DESC - string name of panel
;
;   UTBASE - absolute time of base time of data for 'utplot' plot.  Required
;     if input is not object, and time array is not absolute times. (time
;     array will be relative to utbase)
;
;   WXSIZE,WYSIZE - initial size of draw widget in pixels (default:
;     wxsize=.45 * screen width, wysize=.5 * screen width)
;
;   WXPOS, WYPOS - initial location of widget in pixels from top right corner
;     (default: wxpos=100, wypos=100).  Valid only for standalone plotman.
;
;   MAINBASE - widget id of main widget base that plotman will be integrated into.
;     If MAINBASE is set, then plotman is NOT in standalone mode.
;     If set, then mainbase widget must have a uvalue that is a structure that
;       contains at least the following tags:
;       mbar - widget id of menu bar of main widget
;       w_file - widget id of 'File' pulldown menu on main widget
;
;   MULTI_PANEL - OBSOLETE. This is the default as of 5-Jul-2008
;     if set, then plotman allows more than one panel to be saved
;     and shown.  Each panel will have the panel pulldown menu, and a window_control
;     pulldown menu will be placed on top menubar. 

;   GROUP - Widget id of widget id calling plotman, if any.  (Note: this is different
;     from mainbase - with mainbase, plotman will be integrated into the mainbase
;     widget; with group, plotman is called as a standalone widget from another widget)
;
; Output Keywords:
;
;   WIDGETS - structure containing widget ids of plotman widgets.  Used mainly by
;     calling program if not running in standalone mode.
;
;   ERROR - 0/1 means no error, error.
;
; Some objects have a plotman method (map, xyplot, utplot, rhessi objects).  Once you have created
; one of these object types, you can call the plotman method as follows:
; o -> plotman [,desc='xxxx']
; If you want to retreive the plotman object reference on the call to plotman so that you can
; add more panels to the same plotman instance, use the plotman_obj keyword:
; o -> plotman, desc='yyyy', plotman_obj = pobj
; On the first call pobj will be created, on subsequent calls it will be reused.
; 
; Each time you call new_panel, a new panel is added to the plotman instance (panels are selected via
; the Window_Control menu).  To modify the current panel that's showing, you can do something like:
;   obj-> set, charsize=2.
;   obj-> select
;   obj-> plot
;
; Examples:
;
;   RHESSI Object input:
;   o = hsi_image(obs_time=['2000/9/1 12:00','2000/9/1 12:01']
;   pobj = plotman (input=o, plot_type='image', desc='hessi image')
;   or if pobj already exists, add a new panel via:
;   pobj -> new_panel, input=o, plot_type='image', desc='hessi image' 
;   or use 
;   o->plotman, desc='hessi image', plotman_obj=pobj
;   z->plotman, desc='something else', plotman_obj=pobj ; where z is any obj with a plotman method
;   
;   XYPLOT object from x array and y array:
;   o = obj_new('xyplot',x, y, id='test')
;   pobj = plotman (input=o, plot_type='xyplot', desc='test xy')
;   or
;   o->plotman, desc='blah blah'
;   If y is a 2-d array (should be dimensioned [npoints,ntraces] where npoints matches the 
;   number of points in the x array), can identify the two traces via
;   o -> set, dim1_id = ['trace 1', 'trace 2']
;   o->plotman, plotman=pobj
;
;   UTPLOT object from arrays:
;   If x is an array of seconds since a base time, and utbase is the base time in a fully
;   referenced format (e.g. ascii, ext), and you want the y axis to be log, then:
;   o = obj_new('utplot', x, y, utbase=utbase, /ylog)
;   o->plotman, desc='whatever'
;   (as above in xyplot example, y can hold multiple traces)
;   
;   MAP object:
;   o = obj_new('map')
;   If you have a map structure
;   o->set, _extra=map_struct  
;   or if you don't have a map structure:
;   o->set,data=image_array,xc=xcenter,yc=ycenter,dx=xpixel_size,dy=ypixel_size, time=time, id='test'
;   o->plotman, desc='xxxx'
;   or plotman_obj = plotman(input=o, plot_type='image', desc='xxxx' 
;   
;   MAP object from an instrument:
;   o = obj_new('eit')
;   o->read, filename
;   o->plotman   
;   
;   Non-object input, X vs Y plot with labels, log y axis:
;   data = indgen(10,2)
;   plotman_obj = plotman (input=data, plot_type='xyplot', xtitle='Latitude', $
;      ytitle='Longitude', title='Test plot', /ylog)
;
;   Non-object input, utplot with absolute time input:
;   data = dblarr(10,2)
;   data(*,0) = anytim('2000/9/2 15:00') + dindgen(10)*1000.
;   data(*,1) = sin(indgen(10))
;   plotman_obj = plotman (input=data, plot_type='utplot')
;
;   Non-object input, utplot with relative time input  (here you must supply a utbase):
;   data = dblarr(10,2)
;   data(*,0) = dindgen(10)*1000.
;   data(*,1) = sin(indgen(10))
;   plotman_obj = plotman (input=data, plot_type='utplot', utbase = '2000/9/2 15:00')
;
;	Plotman with two panels (note: input for each new panel can be any of the allowed
;   input types listed above) (also note, for image, to supply axis and other info, it's
;   best to put image into a map object and use that as input to plotman):
;   image1=dist(512) & image2=dist(200)
;   plotman_obj = plotman(input=image1,plot_type='image', desc='my first image')
;   plotman_obj -> new_panel, input=image2, plot_type='image', desc='my second image'
;
;   Unknown input object classes must conform to the following rules to have a chance of working:
;       Must have 'PLOT', 'LIST', and 'GETDATA' methods.
;       Must have:
;         GET(/CONTROL) - get all params that control how to retrieve data from object
;         GET(/INFO) - get all info parameters that describe data retrieved
;         GET(/UT_REF) - get reference time
;         GET(/TIME_RANGE) - get full time range of data
;       For image objects, the 'PLOT' method must use the SSW plot_map routine
;       For time profile objects, the 'PLOT' method must use the SSW utplot routine
;
; Written: Kim Tolbert, Dec 1999.  kim.tolbert@nasa.gov
;
; Modifications:
;   8-Jan-2001 - added colorbar option for images
;   21-Jan-2001 - Kim, added fits export option. Involved rewriting export method for list too.
;   1-Feb-2001 - Kim, Do loadct,0 before checking total number of colors available
;   17-Feb-2001 - Kim.  Don't unset colors after each plot (better for unix?),
;		overlay_self became overlay_panel with option to overlay different images, and
;		added drotate_image parameter for solar-rotating overlaid image.
;   9-Mar-2001 - Kim.  Moved init of intervals to init method from setdefaults method, so
;      intervals would persist.
;   3-Apr-2001 - Kim.  Added dim1_... arguments to xyplot plot call.
;   11-Apr-2001 - Kim.  Made dim1_use a ptr_new(/alloc) instead of ptr_new(indgen(20)), which
;      was arbitrary but covered most cases.  Now have to set dim1_use in plotman obj explicitly.
;   21-Apr-2001 - Kim.  Changed plot control tags from r,g,b to rcolors,...
;   22-Apr-2001 - Kim.  Added set,colortable=x feature
;	1-May-2001 - Kim.  Changed dim1_unit to dim1_name.
;	19-Jun-2001 - Kim.  Added getaxis method
;	5-Jul-2001 - Kim.  Added make_plot_cmd method, and rewrote plot method
;		to use it.  Also made overlay_panel an array so can have multiple
;		overlays for xy and ut plots.
;	10-Jul-2001 - Kim.  Added magnify method
;	19-Jul-2001 - Kim.  Use get(/utbase) as well as get(/ut_ref) to get base time. (previously
;		just used ut_ref)  If neither available, do retall
;	30-Jul-2001 - Kim.  Changed image_flux method.  Before relied on data object having a
;	  flux method, now it will work on any input data - object or data array.
;	  Also modified get(/saved_data_data) to return array if *self.data is not an object.
;	31-Jul-2001, Kim.  Added get(/image_info)
;	3-Aug-2001, Kim.  Moved image_flux method to its own file
;	30-Aug-2001, Kim.  Added mark_limb option
;	2-Sep-2001, Kim.  Added translate_overlay and legend_color options
;	24-Sep-2001, Kim.  When colortable keyword is set, use color_file already saved, and
;      use bottom and ncolors keywords so we don't lose individual colors in highest indices.
;   29-Dec-2001, Kim.  Added psym explicitly to argument list constructed by
;      make_plot_cmd (hsi_spectrum__plot checks if it's in _extra)
;	22-Jan-2002, Kim.  Added mark_point option
;	19-Feb-2002, Kim.  Check for white->black for PS files here instead of in
;		plotman_create_files_event because didn't work for stacked plots.  Also
;		contour color wasn't being used.
;   20-Feb-2002, Kim.  Added user_label option
;   2-Mar-2002, Kim.  Added more_commands option
;	13-Apr-2002, Kim.  xneat default.  Added ways to look for start time of data
;	   when input keyword is given.
;   14-May-2002, Kim.  In plot method, on overlay, was calling with xrange and timerange, but
;      xrange was overiding timerange.  Pass xrange=[0.,0.] to overlay if doing time plot.
;   17-May-2002, Kim.  In export method, use self.class_name instead of self.saved_data.class_name.
;      Also, make dialog_message use info type when it's not an error message in export method
;	27-May-2002, Kim.  Added derivative option
;	9-Jun-2002, Kim.  Enabled export to idl save file
;	18-Jun-2002, Kim.  Added params_list, screen, quiet args to summ_params method. Added filename,
;		quiet to export method
;	28-Jun-2002, Kim.  Added  current_panel_struct and widgets to data returned by GET.  Check
;	   if image_units tag exists before using in get(/image_info)
;   18-Jul-2002, Kim.  Added times tag to image_info structure returned in get
;	21-Jul-2002, Kim.  Added contour_percent, contour_thickness and imgflux structure to control parameters.  Also
;		when transferring plot params, added contour_percent and overlay_panel (if it's 'self' or '')
;	22-Jul-2002, Kim.  Added mark_box_contour_level, mark_box_contour_percent
;	19-Sep-2002, Kim.  Added integral option
;	11-Oct-2002, Kim.  Added load_colors and dev2data methods, and get(/is_hessi_obj), call
;		load_colors for new panel when doing an overlay, and skip to end of overlay loop if
;		panel we want to overlay has been deleted in the meantime.
;   05-Nov-2002, Kim.  Retrieve image start and end times in image_info for synop images too
;   05-Nov-2002, Kim.  Added grid_spacing option for image plots
;   05-Nov-2002, Kim.  Add grid_color, limb_color, and translate_image options
;	22-Nov-2002, Kim.  Added set_props_from_obj method, and call to it in setdefaults when
;		input keyword is set.  Transfers properties from certain kinds of objects
;		(e.g. xyplot, utplot, specplot, map) to plotman defaults
;	22-Nov-2002, Kim.  Changed mark_limb to limb_mark for compatibility with map objects
;	24-Nov-2002, KIm.  Changed log_image, square_image to log_scale, square_scale
;	10-Dec-2002, Kim.  In dev2data method, use object saved in common if necessary.
;	11-Dec-2002, Kim.  Only draw red box around plot if device is WIN or X
;   09-Jan-2003, Kim.  In ::select, only draw red box if valid_window is true.
;	05-Feb-2003, Kim.  Made getaxis,/yaxis work.
;	13-Mar-2003, Kim.  Added _extra to getaxis call, and pass on to object's getaxis
;	19-Mar-2003, Kim.  Added ut keyword to getaxis method.
;	30-Mar-2003, Kim.  Save !x,!y after overlays so that interactive zooming and
;	  pointing will work with any plot in a multiplot.  Also eliminated kludgy stuff
;	  in dev2data that was needed for old kludgy version of spectro_plot
;	30-Mar-2003, Kim.  Added desc_without_time keyword to get(/current_panel_desc)
;	26-Jun-2003, Kim.  Added smooth_spec and exp_scale paramaters for spectrograms
;	24-Jul-2003, Kim.  In plot method, replicate dim1_colors until # elements = # chan plotted
;   13-Aug-2003, Mimi. In init method, changed x and y values for output_control ps structures
;	26-Aug-2003, Kim.  Corrected problem with plotting color bar on images with overlays
;	1-Oct-2003, Kim.  Fixed check on dim1_ids (is_string now instead of = -1)
;	10-Oct-2003, Kim.  Change zlog,zexp to log_scale, exp_scale make_plot_cmd for spectrograms. Also take
;		log out of arguments for spectrogram, only use for image.
;	3-Nov-2003, Kim.  In get(/image_info), if current plot_type isn't image, return -1
;	5-Nov-2003, Kim.  Added drange= to image plot command (using z axis limits) and added
;		passing in limb_plot, grid_spacing, log_scale when doing self overlay (contours on image)
;	24-Nov-2003, Kim.  In plot method, when doing overlay, was setting !x and !y to those of
;	   overlay panel, but that screwed up PS plots of overlaid images.  Only set !x and !y for
;	   non-image plots now.
;	21-Feb-2004, Kim.  Added contour_label, contour_style, overlay_thickness, overlay_label,
;	   overlay_style, n_overlay_levels, overlay_percent, overlay_levels, and
;	   limb_thickness plot control parameters
;	26-Feb-2004, Kim.  In setdefaults method, call ->set,input=input before set_plot_params
;	   so user setting will get set after settings from input object (if it's an object)
;	16-Mar-2004, Kim.  Undid change of Feb 26.  Have to find a better way - it was losing
;		the default settings from data objects always - not just after user set their own
;		preferences (so, e.g. trace images didn't come out in log, so look blank).
;		Also, moved in make_plot_cmd, moved drange from parameters that are always set,
;		to just being set if doing an image or spectrogram.
;	5-Apr-2004, Kim.  Fixed user_label for overlays
;   29-Jun-2004, Kim.  Added 'valid' function method.
;	30-Jun-2004, Kim.  Added no_timestamp plot control parameter
;	7-Jan-2005, Kim.  When setting input to a user image, allow map structure input
;	   in addition to image array
;	8-Jan-2005, Kim.  Removed /extend in calls to plot images.  Not nec. and collision with hessi obj.
;		If info.pixel_area=0., use pixel_size to get pixel_area. Changed smooth to smooth_width to
;		avoid collision with hessi obj params.
;   22-Jan-2005, Kim.  Changed export, /fits method to call new image_writefits method
;   16-Mar-2005, Kim.  In get(/image_info) use info.absolute_time_range
;	17-Mar-2005, Kim.  In set colortable, set new color in plot_control, not image_defaults and
;	   corrected bug in setdefaults (n dim eq 2, previously n dim ne 2)
;	29-Mar-2005, Kim.  In getaxis, allow choice of output (edges, mean, etc) through
;		call to get_edges
;	30-Mar-2005, Kim.  When plot fails, print error traceback!!  Much better.
;	14-Apr-2005, Kim.  In set method for 'input', if can't find time_range in data object,
;		try timerange.
;	24-May-2005, Kim. In set colortable, set new color in plot_control, AND image_defaults.
;		Previously only in plot_control (and before that, only in image_defaults)
;	24-May-2005, Kim.  Added nomap option to not map widget when plotman obj created.
;	17-Jun-2005, Kim.  Changed smooth_spec to interpolate to match specplot__define
;	23-Jun-2005, Kim.  Added wxsize,wysize to set method, so can set size after widget has been
;		created in addition to in initialization
;	29-Jul-2005, Kim.  Pass quiet keyword to image_fitswrite
;	6-Aug-2005, Kim.  Added grid_thickness parameter
;	11-Jan-2006, Kim.  Limit data coord to 1.e38 if it's Inf (exceeds float max) in dev2data
;	22-May-2006, Kim.  Pass nomap to plotman_widget, call new_panel with noplot based on nomap,
;		and commented out a widget_control.../map that I think (?) isn't necessary
;	21-Jun-2006, Kim.  Added widget_control.../map change of 22-may back in.  Now that I corrected
;		the nomap setup, if you init plotman with nomap, and then do a plot, it never shows up on
;		screen without this.
;	15-Sep-2006, Kim.  Removed some special code for PS in plot method
;   21-Sep-2006, Kim.  Re-added that special PS code - needed for stacked plots
;	11-Oct-2006, Kim.  On Unix, clicking the x in top right corner of hessi gui, and selecting yes
;     to quit, often crashed IDL session (seemed to depend on location on screen of terminal
;     window that started IDL!  for me, but not Paolo).  Error message like:
;	  Xlib:unexpected async reply (sequence 0x115a)!
;	  % X windows protocol error: BadFont (invalid Font parameter)
;	  Traced to the tvlct in plotman::cleanup!  Now extract r,g,b out of self structure,
;	  moved widget destroy down, and moved call to tvlct to be last.  Seems to fix problem,
;	  but no idea why.
;	9-May-2007,, Kim.  Previously had separate parameters controlling contours of
;	  primary image from those controlling overlaid contours.  Now all contour info
;	  is stored in overlay params, and the 0th overlay is always reserved for self.
;	  Added overlay_ulabel, overlay_ulabel_lev params - user label for each contour
;	  and option for whether to append user defined contour labels on label. Overlay label
;	  is constructed in plot method
;	16-May-2007, Kim.  Fix set_plot_params - was setting panel_overlay[0] which was 'self'
;	  into all 4 panel_overlay. Also - don't transfer overlay_ulabel for 0th overlay
;	  since that's self and will be different for each plot.
;	8-Jun-2007, Kim.  Added charthick option (controls xthick and ythick too) for better PS plots.
;	30-Jul-2007, Kim.  When applying plot defaults to future or existing plots, now also save
;	  x,y, or time limits (changes are in set_plot_params and set).  Previously saved other plot
;	  params but not limits to protect user - new plot in different range won't show anything.
;	23-Aug-2007, Kim.  translate_overlay was being dimensioned wrong
;	30-Oct-2007, Kim. Major changes to handle plot defaults better.  Now have xy_pref, ut_pref,
;	  image_pref, and spec_pref plotman properties which are structures that store the settings
;	  that override all other settings ( this structure is set via _extra in set_plot_defaults
;	  after all other settings done). These structures are set via the new 'Set Plot Preferences'
;	  button under File, which brings up the red/green boxes next to each option to allow users
;	  to choose which options to use.  Note: these structures contain ONLY the settings the user
;	  wants (e.g. *self.xy_pref = {charsize: 1.5, grid_spacing: 5.}. Previously had only xy_defaults
;	  and image_defaults which were the entire plot_control structure (and therefore contained
;	  all options - some of which user may not have wanted to set).
;	  These settings are stored in files (in temp_dir) named .plotman_xy_pref.geny... and are read
;     when plotman starts up.  Added new plotman preferences widget for each data type to
;	  set options - red and green buttons let user control which settings to remember (previously
;	  just used all - no fine control)
;	  Also added option in multi-panel widget to set options for multiple panels - again using the
;	  red/green buttons to allow fine control of which options to apply. (use self.temp_pref for this)
;	  Call plotman_widget is now called as a method
;	  Removed set_plot_params method
;	  Added set_plot_defaults, getcolors, color_change methods
;	  Added lots of items to get in GET method
;	  Added options to SET and GET overlay options for a particular overlay by prepending cn_ to
;	  option name where n is the overlay number it applies to.
;	11-Mar-2008, Kim. changed check for times from 6.e7 to 1.e7 so 1980 will work.
;	18-Mar-2008, Kim. In get(/saved_data_data), if it's a struct, return the data tag of the struct.
;	24-Mar-2008, Kim. Changed data_dep_tags prop to tags_data_dep because of conflict with data prop.
;	28-Mar-2008, Kim. Stacked plots zooming together wasn't working for xyplots.  Save ov_xrange of base
;	  plot before looping through overlays, and use that.
;	9-May-2008, Kim. For stacked time or spectrogram plots, set /nolabel, xtickname to blanks, and ymargin=[0,4]
;     on all but bottom plot so start time label and tick labels don't print, and space is smaller.
;     Also, correct doing overlay user labels with colors and levels only for images.  Also change
;     default for drotate_image to 1.
;	16-May-2008, Kim.  Added overlay_squish option (don't leave space between stacked overlays)
;	05-Jul-2008, Kim.  In make_plot_cmd, added plot cmd (spectro_plot2) for non-obj spectrogram input
;	  Made multi_panel the default. (call with multi=0 to get non-multi version)
;	  Made it plot the first panel in multi mode by default (previously user had to call new_panel), unless
;	  nopanel keyword is set, and added desc keyword for description for initial panel.
;	  Also, for stacked plots, xthick,/ythick should get their values from top plot.  Added ov_charthick keyword to plot, make_plot_cmd.
;   Also, call call_procedure,'hsi_image_plotman2fits',... instead of self->image_fitswrite... so that
;   if hessi isn't in path, will still compile.  The fits write option only works for hessi anyway.
;   Also, cleaned up explanations of using plotman from command line in this header doc.
; 19-Aug-2008, Kim. Corrected get(/image_info) for case when input data is a map structure
; 20-Aug-2008, Kim. In setdefaults, pass plot_type through to set. In set, call out plot_type
;   on command line and set it first.  Problem was if input was set, it set that first,
;   and didn't have plot_type set yet, so didn't set the time stuff right for plot_type='utplot'
; 22-Aug-2008, Kim.
;   1.  Changed plot_map parameter names after DMZ changed plot_map
;   cstyle->c_linestyle, clabel->c_labels, lcolor->c_colors, charsize->c_charsize, cthick->c_thick
;   charthick->c_charthick, lmthick->lthick, lmcolor->lcolor,positive_only->plus_only,
;   negative_only->minus_only, rescale_image->rescale_zoom
;   2. smooth_image is now 2x4 elements (x,y) by 4 images
;   3. added overlay_roll(4)
; 10-Oct-2008, Kim. Changed surface plot angles from ax_surf,az_surf to ax,az (due to changes in plot_map)
; 22-Oct-2008, Kim. When stacking non-time plots, with autoscaled x axis, they didn't line up. Corrected.
; 6-Nov-2008, Kim.  Look for plotman_colors_hessi.tbl in plotman dir (which is now in gen), not $SSWDB_HESSI
; 12-Jan-2009, Kim. In make_plot_cmd, add xrange, yrange only if not doing image overplot
; 20-Jan-2009, Kim. Changed number of allowed overlays to 12 (from 4)
; 3-Feb-2009, Kim. Add fill_gaps option for xy and ut plots
; 2-Apr-2009, Kim.  Added desc_without_time keyword to get(/all_panel_desc)
; 27-Apr-2009, Kim. nmax_overlay is now 13.  Added an extra color for contours.
; 29-Apr_2009, Kim. In make_plot_cmd, for specplots, include xstyle in plot argument string
; 18-Jun-2009, Kim. Added replace_pc method
; 17-Aug-2009, Kim. Make active plot_control (in self.plot-control) totally independent of the plot_control
;   in the panel linked list.  Always destroy it before replacing it. Trying to plug memory leaks. Added
;   set_plot_control method - should call this every time I set something into current plot_control (it frees
;   the current one, and clones the new one before saving.
;   Also, in cleanup, free ptr to self.data.
;   Also, in make_plot_cmd, xstyle was added twice for spectrograms overlays. If overlay, just set to 1.
; 20-Jan-2010, Kim.  Added get_panel_times method 
; 17-Mar-2010, Kim. For self overlay on log-scaled images, was setting log on overlay as well, so
;   % max was taken on max of log(data).  Now don't pass log, so % is taken on max(data)
; 11-Jun-2010, Kim. Added set for red, green, blue, so user can set separate colors from outside plotman 
;   (red,green,blue arrays will be congridded to the 238 colors we use) into r,g,bcolors in plot_control.
;   If input is struct, set plot_type='image'.  And if _extra is set, set it at end of setdefaults so that 
;   whatever caller has in args will take precedence over any defaults that were set.
; 14-Jan-2010, Kim.  Changed keyword name in call to strip_panel_desc method.
; 08-Nov-2011, Kim.  Use linkedlist2 instead of linkedlist (name changed due to conflict in ssw)
; 14-Feb-2011, Kim.  Store top-level base (via call to get_tlb) in plot_base so that plotman will work 
;   whether its base is the top level or any other base in a widget tree (such as a tab widget) 
;   Thanks to Gelu Nita for this solution.
; 06-Sep-2012, Kim.  Added overlay_ysize. When overlay_ysize is not all zeros, use !p.region to set region
;   in multi plot panel for each overlay. Added ov_yloc to plot args when called for plotting an overlay.
;   Also fixed bug in GET - was getting thick from first nested structure (xx) instead of
;   pp structure inside plot_control structure.
; 27-Nov-2012, Kim. Call get_yloc with /frac and ov_num keywords
; 29-Jan-2013, Kim. Added explicit get for zrange in get method
; 29-Jan-2013, Kim. In setdefaults, commented out line setting _extra at end - don't understand why I had added this
;   since it undoes what was set by the preferences.
; 07-Nov-2013, Kim. In IDL 8.2, they added MASK keyword to widget_button - makes the
;   red/green buttons in the defaults widget transparent (no color), unless I set mask=0, but older
;   versions won't accept mask keyword. So change lower left pixel to slightly different color (254)
;   so mask doesn't mask the whole button.
; 01-Apr-2014, Kim. In dev2data, add /double to convert_coord, and don't limit returned value to 1.e38 (float max)
; 26-Oct-2014, Kim. In make_plot_cmd, add xtitle, ytitle, and title to args. In get, add code to
;   get xtitle, ytitle, and title (since they're not explicit, they're in xx,yy,pp structs)
; 31-Oct-2014, Kim. In make_plot_cmd, move where we set titles - wasn't working correctly for stacked plots
; 08-Mar-2015, Kim. Added overlay_nolabel option
; 25-may-2015, Kim. Added xgridline,ygridline,zgridline to extend axis major tick marks across plot (controls plot_control
;  xx. yy. and zz.ticklen)
; 19-Aug-2015, Kim. In set_props_from_obj, if red,green,blue are set in obj and has_colors is 1, then set explicitly in plotman.
;  Also, in set, for x,y,z,gridline and cn_... overlay params, added a goto,end_of_loop. Otherwise get added to plot_args.
; 11-Feb-2016, Kim. In plot method, when PS set, and color NOT set, error setting dim1_colors (is null string error not numbers)
;  now check wheterh color is set. If not, just set to null strings.
;-
;
;=========================================================================

@plotman__new_panel.pro
@plotman__profiles.pro

;-------


function plotman::init, input=input, plot_type=plot_type, $
	wxsize=wxsize, wysize=wysize, wxpos=wxpos, wypos=wypos, $
	group=group, mainbase=mainbase, multi_panel=multi_panel, $
	desc=desc, $
	nomap=nomap, $
	nopanel=nopanel, $
	widgets=widgets,  error=error, $
	_extra=_extra

checkvar, multi_panel, 1

; find printers defined on this computer
list_printer, printers
if printers(0) eq '' then printers = 'None'
self.output_control.printers = ptr_new(printers)

self.output_control.printer = printers(0)

cd, current=thisdir

; define structures for different plot file types

; changed x and y size and offset, mimster@stars.gsfc.nasa.gov
self.output_control.ps =   {ps_form_info, xsize:7.50, xoff:0.6, ysize:10.0, $
       yoff:0.6, filename:filepath(root_dir=thisdir,'plotman.ps'), $
       inches:1, color:1, bits_per_pixel:8, $
       encapsulated:0, landscape:0}

self.output_control.psprint =   {ps_form_info, xsize:7.50, xoff:0.6, ysize:10.0, $
       yoff:0.6, filename:filepath(root_dir=thisdir,'plotman_print.ps'), $
       inches:1, color:1, bits_per_pixel:8, $
       encapsulated:0, landscape:0}

self.output_control.pslocal = {ps_form_info, xsize:7.50, xoff:0.6, ysize:10.0, $
       yoff:0.6, filename:filepath(root_dir=thisdir,'plotman.ps'), $
       inches:1, color:1, bits_per_pixel:8, $
       encapsulated:0, landscape:0}

self.output_control.png =  {xwindow_png,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.png'), $
       order:0, quality:-1}

self.output_control.jpeg = {xwindow_jpeg,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.jpg'), $
       order:0, quality:75}

self.output_control.tiff = {xwindow_tiff,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.tif'), $
       order:0, quality:-1}

self.output_control.imgflux = {flux_options, writefile: 1, filename:'flux_output.txt', append: 1}

; get and save current colors.  Will restore in cleanup
tvlct, r, g, b, /get
self.orig_r = r
self.orig_g = g
self.orig_b = b

;initialize mark box contour information
self.mark_box_contour_level = 50.
self.mark_box_contour_percent = 1

self.xy_pref = ptr_new(-1)
self.ut_pref = ptr_new(-1)
self.image_pref = ptr_new(-1)
self.spec_pref = ptr_new(-1)
self.temp_pref = ptr_new(-1)

; these are data-dependent tags.  When copying settings from one panel to another, don't copy these.
self.tags_data_dep = ['plot_type', 'utbase', 'utrange', 'dim1_name', 'dim1_ids', 'dim1_use', 'dim1_enab_sum']

; Check for existence of preference file for each type of data, and if exists, read and
; store in self.zz_pref pointer.

if is_dir('$HOME',out=home) then save_dir=home else save_dir=get_temp_dir()
self.xy_file_pref = concat_dir(save_dir,'.plotman_xy_pref.geny')
self.ut_file_pref = concat_dir(save_dir,'.plotman_ut_pref.geny')
self.image_file_pref = concat_dir(save_dir,'.plotman_image_pref.geny')
self.spec_file_pref = concat_dir(save_dir,'.plotman_spec_pref.geny')

if file_test(self.xy_file_pref,/read) then begin
	restgenx, file=self.xy_file_pref, struct, /relaxed
	*self.xy_pref = struct
endif

if file_test(self.ut_file_pref,/read) then begin
	restgenx, file=self.ut_file_pref, struct, /relaxed
	*self.ut_pref = struct
endif

if file_test(self.image_file_pref,/read) then begin
	restgenx, file=self.image_file_pref, struct, /relaxed
	*self.image_pref = struct
endif

if file_test(self.spec_file_pref,/read) then begin
	restgenx, file=self.spec_file_pref, struct, /relaxed
	*self.spec_pref = struct
endif

self.red_bmp[*,*,0] = 255
self.red_bmp[0,0,0] = 254
self.green_bmp[*,*,1] = 255
self.green_bmp[0,0,1] = 254

; initialize overall plot defaults
status = self -> init_plot_defaults()
error = status eq 0
if status eq 0 then return, 0

; initialize plot variables
status = self -> setdefaults (input=input, plot_type=plot_type, _extra=_extra)
error = status eq 0
if status eq 0 then return, 0

; create plotman widget (or integrate into mainbase widget)
self.plot_base = self -> widget ( $
	wxsize=wxsize, wysize=wysize, wxpos=wxpos, wypos=wypos, $
	group=group, mainbase=mainbase, multi_panel=multi_panel, $
	widgets=widgets, nomap=nomap)

; Store in plot_base the top-level base that contains plot_base
self.plot_base = get_tlb(self.plot_base)

self.intervals = ptr_new(/alloc)

self.max_panels = 30

self.panels = obj_new('linkedlist2')

self -> init_saved_data
self.use_extracted = 0

self.current_panel_number = -1

self.multi_panel = multi_panel

self.last_window_choice = 'None'

;if not self.multi_panel then if ptr_exist(self.data) then self -> new_panel, noplot=keyword_set(nomap) eq 1
if ptr_exist(self.data) and not keyword_set(nopanel) then self -> new_panel, noplot=keyword_set(nomap) eq 1, desc=desc

; make sure astrolib, devicelib system variables are defined
astrolib
devicelib

return,1		; return success
end

;-----
; CLEANUP method - restore original colors and free all pointers and destroy
; all objects, except data

pro plotman::cleanup

r = self.orig_r
g = self.orig_g
b = self.orig_b

add_method,'free_var',self
; Free pointer to data, but not data.  May be an object user is still using.
ptr_free, self.data
self->free_var, exclude='data'

if xalive(self.plot_base) then widget_control, self.plot_base, /destroy

print,'Cleanup of plotman object complete.'

tvlct,r,g,b
end

;-----

; I'm not sure if this is needed.  I think as long as plotman
; object exists, plot_base is alive, and if it doesn't exist, then
; this method is not accessible.  But maybe there's another case.

function plotman::valid
return, xalive(self.plot_base)
end

;-----
; Define program defaults for plotting.  Initialize user-selected xy_defaults
; and image_defaults to the program defaults.

function plotman::init_plot_defaults

cleanplot, /silent
self.plot_defaults.xx = !x
self.plot_defaults.yy = !y
self.plot_defaults.zz = !z
self.plot_defaults.pp = !p

self.plot_defaults.xx.style=1   ; make x neat the default
self.plot_defaults.pp.psym=10  ; make histogram style the default

self.plot_defaults.xlog = 0
self.plot_defaults.ylog = 0

self.plot_defaults.plot_args = ptr_new ({dummy: 0})

self.plot_defaults.utbase = 0.d0
self.plot_defaults.timerange = [0.d0, 0.d0]

; first make sure device has enough colors to use ( > 50)
loadct, 0, /silent
tvlct, r, g, b, /get
wcolors = n_elements(r)		; total number of colors available  ( <=256)
if wcolors lt 50 then begin
	print, ' '
	print, 'ERROR - Not enough colors available for use.  Aborting.'
	print, ' '
	return, 0
endif
bottom = 0					; first element in color tables that we'll use for color maps
ncolors = wcolors - 17 - 1	; last element in color tables that we'll use for color maps. Bad name!

; if HESSI color table available, then use it and load HESSI colors (HESSI color
; table has all standard color schemes plus a HESSI color and HESSI b/w scheme)
; if hessi file not found, then we'll save a blank string, and will default to
; normal IDL color tables.
; colors_hessi.tbl used to be in $SSWDB_HESSI, but now needs to exist without
; hessi tree, so it's now in dir that plotman__define is in.
dir = path_dir('plotman')
self.plot_defaults.color_file = loc_file(path=dir, 'plotman_colors_hessi.tbl')
;loadct, file=self.plot_control.color_file, get_names=names
;q = where (names eq 'HESSI color', count)
;if count gt 0 then $
;	loadct, file=self.plot_control.color_file, q[0], bottom=bottom, ncolors=ncolors
tvlct, r, g, b, /get

; load constant colors into top 15 color elements.  Names of colors are in plot_control.color_names
;	(defined in plotman_plot_control__define).  When user loadsdifferent color tables in later, will only use
;	ncolors+1 elements of color tables so these top 17 won't change.
distinct_r = [128, 140, 0,128,255,255,255,213,128,  0,  0,  0,  0,  0,255,128,255]
distinct_g = [  0, 255, 0,  0,  0,  0,128,213,128,255,128,255,  0,  0,  0,  0,255]
distinct_b = [170,   0, 0,  0,  0,128,  0,  0,  0,  0,  0,255,255,128,255,128,255]

r[ncolors+1:  wcolors-1] = distinct_r
g[ncolors+1: wcolors-1] = distinct_g
b[ncolors+1: wcolors-1] = distinct_b
tvlct,r,g,b
for i = 0, 16 do self.plot_defaults.color_names.(i) = ncolors +1 + i

self.plot_defaults.rcolors = r
self.plot_defaults.gcolors = g
self.plot_defaults.bcolors = b
self.plot_defaults.bottom = bottom
self.plot_defaults.ncolors = ncolors
self.plot_defaults.wcolors = wcolors

good_colors = ['white', 'magenta', 'green', 'cyan', 'yellow', 'red', 'blue', 'orange', 'olive', 'purple']
for i = 0,9 do r = execute ('cc= append_arr(cc, self.plot_defaults.color_names.'  + good_colors[i] + ')' )
self.plot_defaults.dim1_name = ''
self.plot_defaults.dim1_ids = ptr_new(/alloc)
self.plot_defaults.dim1_use = ptr_new(/alloc)
self.plot_defaults.dim1_colors = ptr_new(cc)
self.plot_defaults.dim1_linestyles = ptr_new( [indgen(6),indgen(4)] )
self.plot_defaults.dim1_enab_sum = 0
self.plot_defaults.dim1_sum = 0
self.plot_defaults.derivative = 0
self.plot_defaults.integral = 0
self.plot_defaults.fill_gaps = 0

self.plot_defaults.cbar = 1
self.plot_defaults.smooth_image = 0
self.plot_defaults.interpolate = 1
self.plot_defaults.log_scale = 0
self.plot_defaults.exp_scale = 0
self.plot_defaults.limb_plot = 1
self.plot_defaults.grid_spacing = 0.
self.plot_defaults.grid_thickness = 1.
self.plot_defaults.square_scale = 1
self.plot_defaults.contour_image = 0
self.plot_defaults.overlay_panel = ''
self.plot_defaults.overlay_stack = 1
self.plot_defaults.drotate_image = 1
self.plot_defaults.translate_overlay = 0.
self.plot_defaults.overlay_color = [self.plot_defaults.color_names.white, $
	self.plot_defaults.color_names.blue, $
	self.plot_defaults.color_names.green, $
	self.plot_defaults.color_names.cyan, $
	self.plot_defaults.color_names.violet, $
	self.plot_defaults.color_names.lime, $
	self.plot_defaults.color_names.maroon, $
	self.plot_defaults.color_names.yellow, $
	self.plot_defaults.color_names.red, $
	self.plot_defaults.color_names.purple, $
	self.plot_defaults.color_names.pink, $
	self.plot_defaults.color_names.orange, $
	self.plot_defaults.color_names.blue]
self.plot_defaults.overlay_thickness = 1.
nmax_overlay = 13
self.plot_defaults.nmax_overlay = nmax_overlay
self.plot_defaults.overlay_label = 0
self.plot_defaults.overlay_style = 0
self.plot_defaults.n_overlay_levels = 5
self.plot_defaults.overlay_percent = 1
self.plot_defaults.overlay_nolabel = intarr(nmax_overlay)
self.plot_defaults.overlay_ulabel = ''
self.plot_defaults.overlay_ulabel_lev = [intarr(nmax_overlay)+1]
self.plot_defaults.overlay_levels[0:4,*] = rebin([10.,30., 50., 70., 90.], 5, nmax_overlay)
self.plot_defaults.overlay_ysize = intarr(nmax_overlay)
self.plot_defaults.overlay_squish = 0
self.plot_defaults.surface_image = 0
self.plot_defaults.shade_surf_image = 0
self.plot_defaults.show3_image = 0
self.plot_defaults.ax_surface = 30.
self.plot_defaults.az_surface = 30.
self.plot_defaults.pos_image = 0
self.plot_defaults.neg_image = 0
self.plot_defaults.rescale_zoom = 0
self.plot_defaults.mark_point = 0
self.plot_defaults.grid_color = self.plot_defaults.color_names.white
self.plot_defaults.limb_color = self.plot_defaults.color_names.yellow
self.plot_defaults.limb_thickness = 1.
self.plot_defaults.axis_color = self.plot_defaults.color_names.white

self.plot_defaults.legend_loc = 1
self.plot_defaults.no_timestamp = 0
self.plot_defaults.legend_color = self.plot_defaults.color_names.white
self.plot_defaults.user_label = ''
self.plot_defaults.more_commands = ptr_new('')

return,1
end

;-----
; Added 14-Aug-2009, Kim.  Now current plot_control (self.plot_control) is always totally 
; independent of all plot_controls in panels.  Al
pro plotman::set_plot_control, new_plot_control

free_var, self.plot_control
self.plot_control = stc_clone(new_plot_control)

end

;-----
; Apply user default preferences for plot defaults
; Sets them in self.plot_control unless return_struct is provided as an output variable to return structure in.
;
; plot_type - Type of plot defaults to set.
; out_struct - if present, don't leave self.plot_control set - return value in out_struct instead and
;   restore previous value of self.plot_control

pro plotman::set_plot_defaults, $
	plot_type=plot_type, $
	out_struct=out_struct

; if we're just returning structure, need to save old plot_control so we can
; restore it before we leave
ret = arg_present(out_struct)
if ret then save_plot_control = self.plot_control

;self.plot_control = stc_clone(self.plot_defaults)

case plot_type of
	'xyplot': begin
		if is_struct(*self.xy_pref)  then self -> set, _extra=*self.xy_pref
		end
	'utplot': begin
		if is_struct(*self.ut_pref)  then self -> set, _extra=*self.ut_pref
		end
	'image': begin
		if is_struct(*self.image_pref)  then self -> set, _extra=*self.image_pref
		end
	'specplot': begin
		if is_struct(*self.spec_pref)  then self -> set, _extra=*self.spec_pref
		end
endcase

self.plot_control.plot_type = plot_type

if ret then begin
	out_struct = self.plot_control
	self.plot_control = save_plot_control
endif

end

;-----
; Modify the plot_control structure in pc_struct with the values in set_struct.
; Use plotman's set method to do this by:
; 1. Save current plot_control
; 2. Set pc_struct into current plot_control
; 3. Use set method to set set_struct values (via _extra)
; 4. Set pc_struct to the modified current plot_control
; 5. Set the current plot_control back to the saved version

pro plotman::modify_plot_params, pc_struct, set_struct, this=this

save_plot_control = self.plot_control
self.plot_control = pc_struct
self -> set, _extra=set_struct
pc_struct = self.plot_control
self.plot_control = save_plot_control

end

;-----
; SETDEFAULTS method - set plot defaults
; return value is 1 if successful, 0 otherwise
function plotman::setdefaults, input=input, plot_type=plot_type, _extra=_extra

if keyword_set (input) then begin

	ptr_free, self.data
	self.data = ptr_new(input)

	if datatype (input,1) eq 'Object' then begin

		; ??? somehow check that object has a plot method.  obj_methods doesn't work
		; if the plot method isn't in the overall define pro

		ptype = *self.data -> get(/plot_type)
		if size(ptype,/tname) eq 'STRING' then plot_type = ptype

	endif else begin
	  if is_struct(input) then plot_type = 'image'
	  
		if not (is_struct(input) or (n_dimensions (input) eq 2)) then begin
			message, 'ERROR: data array must be 2-D, or for images, a structure', /cont
			return, 0
		endif
	endelse

endif else begin
	;self.data = ptr_new ([[indgen(10)], [indgen(10)] ])
	self.data = ptr_new(/alloc)
endelse

self.class_name = ''

select_windows
device, decomposed=0, retain=2

checkvar, plot_type, 'xyplot'

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
self -> set_plot_control, self.plot_defaults
;free_var, self.plot_control
;self.plot_control = stc_clone(self.plot_defaults)

; now override what we just set with anything in extra
self -> set, _extra=_extra, plot_type=plot_type, input=input

; the set above will set defaults from the object if input is an object, so now set users def and curr options
self -> set_plot_defaults, plot_type=plot_type

;new2 = {psym:3,symsize:4., timerange:'20-feb-2002 ' + ['11:05','11:10']}
;if plot_type eq 'utplot' then self->set, _extra=new2

; And finally, if it's in extra, user really wants it to override defaults, so set again.  Added 11-Jun-2010
; 29-Jan-2013.  I don't know why I added this, but if for example, plot was requested with /ylog, but user
; preferences have ylinear, this undoes that setting.  So I'm removing this for now.  See what problems arise.
;if keyword_set(_extra) then self -> set, _extra=_extra

return, 1
end

;-----
; modify the plot control saved in panels specified by chg_panel (will be 1 if want to change,
; 0 otherwise) with the values in use structure.

pro plotman::reset_panel_pc, use, panels=chg_panel;, all=all

;if keyword_set(all) then begin
if not is_struct(use) then return

npanel = self.panels -> get_count()
npanel = npanel < n_elements(chg_panel)
if npanel eq 0 then return
for i=0,npanel-1 do begin
	if chg_panel[i] then begin
		panel = self.panels->get_item(i)
		pc = (*panel).plot_control
;		self -> set_plot_params, use, plot_control=pc
		self -> modify_plot_params, pc, use
		(*panel).plot_control = pc
	endif
endfor

;endif else begin
;	self -> set_plot_params, use
;endelse

end

;-----
; REPLACE_PC method.  Replace current panel's plot control structure with the structure
; in new_pc.
; Added 18-Jun-2009

pro plotman::replace_pc, new_pc

panel = self.panels->get_item(self.current_panel_number)

(*panel).plot_control = stc_clone(new_pc)
self.plot_control = new_pc

end

;-----
; VALID_WINDOW method - function returns 1 if current window has a plot.  If utplot,
; image, or xyplot keyword is set, only returns 1 if current plot is that kind of plot.
; if message is set then writes error message in dialog_message if not valid plot.

function plotman::valid_window, message=message, utplot=utplot, image=image, xyplot=xyplot, use_text=use_text

widget_control, self.plot_base, get_uvalue=state

plot_type = self.plot_control.plot_type
text = ''
if self.current_panel_number ne -1 then begin
	if keyword_set(utplot) then if plot_type ne 'utplot' and plot_type ne 'specplot' then $
		text = 'Current plot is not a time plot.'
	if keyword_set(image) then if plot_type ne 'image' then text = 'Current plot is not an image.'
	if keyword_set(xyplot) then if plot_type ne 'xyplot' then text = 'Current plot is not an xy plot.'
	if keyword_set(specplot) then if plot_type ne 'specplot' then text = 'Current plot is not an spectrogram plot.'
	if text eq '' then return,1
	if keyword_set(use_text) then text = use_text
endif else text = 'No plots created yet or no plot window currently selected.'

if keyword_set(message) then a = dialog_message(text)
return,0

end

;-----
; SELECT method - If currently selected panel is valid, then sets and shows
;	the window corresponding to that panel, and restores the plot control for that panel.

pro plotman::select

screen_output = (!d.name eq 'WIN') or (!d.name eq 'X')
; if device is screen then bring it to foreground and set focus on it
if screen_output then begin
	widget_control, self.plot_base, get_uvalue=state
	if  state.plotman_obj->valid_window() then begin
		wset, state.widgets.window_id
		wshow, state.widgets.window_id
		;print,'current window = ', state.widgets.window_id
		;print,'drawing red outline in plotman::select  ', self.current_panel_number
		plots, [0,1,1,0,0], [0,0,1,1,0], /norm, thick=5, color=243, psym=0
		plots, [0,0], [0,0], /norm,  psym=0
	endif
endif

;self -> save_utplot

; restore plot variables for the selected plot

pc = self.plot_control
!x = pc.xx
!y = pc.yy
!z = pc.zz
!p = pc.pp

self -> load_colors

end

;-----

pro plotman::load_colors
tvlct, self.plot_control.rcolors, self.plot_control.gcolors, self.plot_control.bcolors
end

;-----
; function to check whether colors in plot_control are the same as the current loaded colors

function plotman::color_change, r=r,g=g,b=b

changed = 0

tvlct,r,g,b, /get
pc = self.plot_control
r = r(pc.bottom:pc.bottom+pc.wcolors-1)
g = g(pc.bottom:pc.bottom+pc.wcolors-1)
b = b(pc.bottom:pc.bottom+pc.wcolors-1)

if total(r-pc.rcolors) + total(g-pc.gcolors) + total(b-pc.bcolors) ne 0 then changed = 1
;print,'returning from color_change: ', changed
return, changed
end

;-----

; function to load current colors into plot_control if they're not what's already loaded.
; Also, if replot is set, redo the plot.

pro plotman::getcolors, replot=replot

;print,'in getcolors, replot=', keyword_set(replot)

; do something only if colors have changed
if self->color_change(r=r,g=g,b=b) then begin

	self -> set, rcolors=r, gcolors=g, bcolors=b
	if keyword_set(replot) then begin
		self -> select
		self -> plot
	endif
endif

end

;-----
; 13-Aug-2009, Kim. commented out - not called by anything.
;pro plotman::save_utplot
;getut, utbase=utbase, utstart=utstart, utend=utend
;self.utplot_save.utbase = utbase
;self.utplot_save.utstart = utstart
;self.utplot_save.utend = utend
;self.utplot_save.bangx = !x
;self.utplot_save.bangy = !y
;self.utplot_save.bangp = !p
;end

;-----
; 13-Aug-2009, Kim. commented out - not called by anything.
;pro plotman::restore_utplot
;setut, utbase=self.utplot_save.utbase, $
;	utstart=self.utplot_save.utstart, $
;	utend=self.utplot_save.utend
;!x = self.utplot_save.bangx
;!y = self.utplot_save.bangy
;!p = self.utplot_save.bangp
;end

;-----
; UNSELECT method -
; After a plotman window is selected and used, it must be unselected and plot parameters
; set back to defaults.  This is so that if user does a plot outside of plotman, then it will
; open a new window and have a black and white  color table and default parameters.

pro plotman::unselect

if xdevice(!d.name, /is_it_x) eq 'X' then  begin
	wset,-1
	cleanplot, /silent
;	loadct,0, /silent
endif

;self->restore_utplot

end

;-----
; GET method - Gets information from plotman object.  Can only handle one
;	item at a time.
; Modifications:
;
function plotman::get, _extra=_extra, err_msg=err_msg

err_msg = ''

if not keyword_set(_extra) then return, -1

; any keywords that are tags in the self structure will be set automatically
; can't call get_tag_value with self because self is a structure only within method,
; so handle top level tags separately, then call get_tag_value for any tags that are
; structures themselves.

tag = strlowcase( (tag_names(_extra))(0) )
props = obj_props (self)
found = -1

idx = wc_where (props, tag+'*', count, /case_ignore)
if count gt 1 then begin
	err_msg = 'Keyword is not unique.'
	message, err_msg, /cont
	return, -1
endif
if count eq 1 then begin
	index = idx[0]
	if size(self.(index), /tname) eq 'POINTER' then begin
		if ptr_exist(self.(index)) then return, *self.(index) else return, -1
	endif else return, self.(index)
endif
; move this to end of case statement, so we can do our special cases first, then this generic case
; needed because this found the wrong charsize (found the xx one, not the pp one)
;for i = 0, n_elements(props)-1 do begin
;	if size(self.(i), /tname) eq 'STRUCT' then begin
;		r = execute ('value = get_tag_value(self.(i), /' + tag + ',err=err, /quiet)')
;		if not err then begin
;			if size(value, /tname) eq 'POINTER' then begin
;				if ptr_exist(value) then return, *value else return, -1
;			endif else return, value
;		endif
;	endif
;endfor

; now take care of any keywords that are not also tags in the the self structure

; first check if it's a pseudo-keyword:
; if getting overlay information for just one overlay (instead of the array of n values for all n overlays)
; then the parameter name will have 'c#_' prepended, where # is the number of the overlay this parameter name/value
; applies to. Put the real param name in an _extra structure, with a value of 1, so that the rest of the code works
; as normal, and then extract the value for the overlay we want at the end.
; look for regular expression, starts with c, has any number of numbers (0-9), followed by _
cnum_pos = stregex(tag, '^c[0-9]+_', length=length)
ov_num = -1
if cnum_pos ne -1 then begin
   cnum = strmid(tag, cnum_pos, length)
   tag = strmid(tag, length, 99)
   _extra = create_struct(tag,1)
   nmax_overlay = self.plot_control.nmax_overlay
   ov_num = fix(strmid(cnum, 1, length-2))
   if ov_num gt nmax_overlay then return, -1
endif

;char3 = strmid(tag,0,3)
;ov_num = -1
;if is_member (char3, ['c0_','c1_','c2_','c3_']) then begin
;	tag = strmid(tag,3,99)
;	_extra = create_struct(tag, 1)
;	ov_num = fix (strmid(char3,1,1))
;endif

input_struct=_extra
@unpack_struct

; added explicit cases for xrange... because those variables aren't explicitly named in structure,
; i.e. xrange is really xx.range
; also added case charsize because there's also an xx.charsize and yy.charsize, but we want the pp one.
case 1 of

	exist(xrange): return, self.plot_control.xx.range

	exist(yrange): return, self.plot_control.yy.range
	
	exist(zrange): return, self.plot_control.zz.range

	exist(xexact): return, self.plot_control.xx.style

	exist(yexact): return, self.plot_control.yy.style
	
	exist(xgridline): return, self.plot_control.xx.ticklen
	
	exist(ygridline): return, self.plot_control.yy.ticklen
	
	exist(zgridline): return, self.plot_control.zz.ticklen

	exist(xthick): return, self.plot_control.xx.thick

	exist(ythick): return, self.plot_control.yy.thick
	
	exist(xtitle): return, self.plot_control.xx.title
	
	exist(ytitle): return, self.plot_control.yy.title
	
	exist(title): return, self.plot_control.pp.title
	
	exist(thick): return, self.plot_control.pp.thick

	exist(charsize): return, self.plot_control.pp.charsize

	exist(all_panel_desc): begin
		num = self.panels ->get_count()
		if num gt 0 then begin
			for ip = 0,num-1 do begin
				panel = self.panels ->get_item(ip)
				new = (*panel).description
				if keyword_set(desc_without_time) then begin
          s2 = ssw_strsplit (new, '(', /tail, head=head)
          new = head[0]
        endif
				desc = append_arr(desc, new)
			endfor
		endif else desc = ''
		return, desc
		end

	exist(all_panel_plot_type): begin
		num = self.panels ->get_count()
		if num gt 0 then begin
			for ip = 0,num-1 do begin
				panel = self.panels ->get_item(ip)
				panel_plot_types = append_arr(panel_plot_types, (*panel).plot_control.plot_type)
			endfor
		endif else panel_plot_types = ''
		return, panel_plot_types
		end

	exist(all_panel_drawbase): begin
		num = self.panels ->get_count()
		if num gt 0 then begin
			for ip = 0,num-1 do begin
				panel = self.panels ->get_item(ip)
				bases = append_arr(bases, (*panel).w_drawbase)
			endfor
		endif else bases = -1
		return, bases
		end

	exist(current_panel_desc): begin
		if self.current_panel_number eq -1 then return, ' '
		if self.current_panel_number gt self.panels ->get_count() then return, ' '
		panel = self.panels ->get_item(self.current_panel_number)
		s = (*panel).description
		if keyword_set(desc_without_time) then begin
			s2 = ssw_strsplit (s, '(', /tail, head=head)
			return, head[0]
		endif else return, s
		end

	exist(current_panel_struct): begin
		if self.current_panel_number eq -1 then return, -1
		if self.current_panel_number gt self.panels ->get_count() then return, -1
		return, *( self.panels ->get_item(self.current_panel_number) )
		end

	exist(saved_data_data): begin
		if ptr_valid(self.saved_data.data) then return, *(self.saved_data.data) else begin
			dtype = size(*self.data, /tname)
			if dtype eq 'STRUCT' then if tag_exist(*self.data,'data') then return, (*self.data).data
			if dtype ne 'OBJREF' then return, *self.data
			a = *self.data -> getdata()
			if obj_valid(a[0]) then return, a -> getdata() else return, a
		endelse
	end

	exist(widgets): begin
		widget_control, self.plot_base, get_uvalue=s
		return, s.widgets
		end

	exist(image_info): begin
		if self.plot_control.plot_type ne 'image' then return, -1
		image = self -> get(/saved_data_data)
		control = (self -> get(/saved_data)).control
		info = (self -> get(/saved_data)).info
		dim = size (image, /dim)
		pixel_area = 1.
		image_units = ''
		pixel_units = ''

		if ptr_exist(control) then begin
			if tag_exist((*info),'used_xyoffset') then xyoffset = (*info).used_xyoffset else $
				xyoffset = (*control).xyoffset
			pixel_size = (*control).pixel_size
			pixel_area = 0.
			if tag_exist((*info),'pixel_area') then pixel_area = (*info).pixel_area
			if pixel_area eq 0. then pixel_area = pixel_size[0] * pixel_size[1]
			if tag_exist((*info),'image_units') then image_units = str_pow_conv((*info).image_units)
			pixel_units = 'asec'
			times = (*info).absolute_time_range
			;times = hsi_get_time_range(*control, *info)
		endif else begin
			sdata = self -> get(/data)
			times = [0.d,0.d]
			if (obj_valid(sdata))[0] then begin
				xyoffset = sdata -> get(/xyoffset)
				pixel_size = sdata -> get(/pixel_size)
				pixel_area = pixel_size[0] * pixel_size[1]
				t = anytim(sdata -> get(/time))
				d = sdata -> get(/dur)
				times = [t,t]
				if size(d, /tname) ne 'STRING' then times[1] = times[0] + d
			endif else begin
				if is_struct(sdata) then begin  ; previously used image here and below 19-aug-08
					xyoffset = [sdata.xc, sdata.yc]
					pixel_size = [sdata.dx, sdata.dy]
					pixel_area = pixel_size[0] * pixel_size[1]
					pixel_units = sdata.xunits
					times = anytim(sdata.time) + [0., sdata.dur]
					image = sdata.data
					dim = size(image,/dim)
				endif else begin
					xyoffset = [dim[0]/2., dim[1]/2.]
					pixel_size = [1.,1.]
				endelse
			endelse
		endelse
                ; NOTE - xvals,yvals are the left/bottom of each pixel (NOT center)
		xvals = xyoffset[0] - dim[0]*pixel_size[0]/2. + indgen(dim[0])*pixel_size[0]
		yvals = xyoffset[1] - dim[1]*pixel_size[1]/2. + indgen(dim[1])*pixel_size[1]
		return, {image: image, pixel_area: pixel_area, xyoffset:xyoffset, pixel_size:pixel_size, $
			image_units:image_units, pixel_units:pixel_units, xvals: xvals, yvals: yvals, times: times}
		end

	exist(is_hessi_obj): begin
		if self.saved_data.class eq '' then begin
			if stregex(obj_class(*self.data), 'hsi', /bool, /fold_case) then return, 1
		endif else begin
			if stregex(self.saved_data.class, 'hsi', /bool, /fold_case) then return,1
		endelse
		return,0
		end

	else: begin
		; if there wasn't a special case for the param above, look for the tag name in the self structure
		for i = 0, n_elements(props)-1 do begin
			if size(self.(i), /tname) eq 'STRUCT' then begin
				r = execute ('value = get_tag_value(self.(i), /' + tag + ',err=err, /quiet)')
				if not err then begin
					if size(value, /tname) eq 'POINTER' then begin
						if ptr_exist(value) then return, *value else return, -1
					endif else begin
						if ov_num ne -1 then value = (size(value,/n_dim) eq 1) ? value[ov_num] : value[*,ov_num]
						return, value
					endelse
				endif
			endif
		endfor
		;if didn't find it by now, it's unknown.
		err_msg = 'Keyword not found.'
		message, err_msg, /cont
		return, -1
	end
endcase

end

;-----
; For panels specified by panel_numbers, return start/end times of panels.  Output is [2,n]
; For image panels, return the time from the image_info structure in a 2xn array where n is number of panels
; For ut and specplots, return min, max of x axis
; For xyplots, sometimes times are in y axis, but if that's not available, return 0s.
function plotman::get_panel_times, panel_numbers
current_panel_number = self -> get(/current_panel_number)
np = n_elements(panel_numbers)
panels = self -> get(/panels)
for ii=0,np-1 do begin
  p = panels -> get_item(panel_numbers[ii])
  self -> focus_panel, *p, panel_numbers[ii], /minimal
  plot_type = (*p).plot_control.plot_type
  case 1 of
   plot_type eq 'image': begin
      image_info = self -> get(/image_info)
      t = is_struct(image_info) ? image_info.times: [0.d,0.d0]
      end
    plot_type eq 'utplot' or plot_type eq 'specplot': begin
      utaxis = self -> getaxis(/ut,/edges_2)
      t = minmax(utaxis)
      end
    else: begin
      yaxis = self -> getaxis(/y,/edges_2)
      t =  yaxis[0] eq -1 ? [0.d,0.d] : minmax(yaxis)
      end 
  endcase
  boost_array, times, t
endfor
self -> focus_panel, dummy, current_panel_number
return, times
end

;-----

function plotman::getdata, _extra=_extra

isobj = datatype(*self.data,1) eq 'Object'

if isobj then begin
; maybe don't need to do the following if all objects have an getdata(/xaxis) option
;	if keyword_set(_extra) then begin
;		if tag_exist(_extra, 'XAXIS') then begin
;			case obj_class(*self.data) of
;				'HSI_LIGHTCURVE': begin
;					lc = *self.data -> getdata()
;					time_res = *self.data -> get(/time_res)
;					return, indgen(n_elements(lc[*,0,0])) * time_res
;					end
;				;'HSI_OBS_SUMMARY': return, *self.data -> get(/time_array)
;				'HSI_OBS_SUMMARY': return, -1
;				else:  begin
;					message,'No XAXIS case for object ' + obj_class(*self.data), /cont
;					end
;			endcase
;		endif
;	endif

	return, *self.data -> getdata(_extra=_extra)

endif else return, *self.data

end

;-----

function plotman::getaxis, ut=ut, xaxis=xaxis, yaxis=yaxis, _extra=_extra

if keyword_set(xaxis) or keyword_set(ut) then begin
	if ptr_exist(self.saved_data.xaxis) then return, get_edges(*self.saved_data.xaxis, _extra=_extra)
	if size(*self.data, /tname) eq 'OBJREF' then  $
		return, *self.data -> getaxis(/xaxis, class_name=self.class_name, _extra=_extra)
	return, -1
endif

if keyword_set(yaxis) then begin
	if ptr_exist(self.saved_data.yaxis) then return, get_edges(*self.saved_data.yaxis, _extra=_extra)
	if size(*self.data, /tname) eq 'OBJREF' then  $
		return, *self.data -> getaxis(/yaxis, class_name=self.class_name, _extra=_extra)
	return, -1
endif

end

;-----
;30-jul-2007 - check if stored timerange is valid before setting to [0.d,0.d] for new input so if
; user set timerange default from earlier plot, it won't get overridden

pro plotman::set, plot_type=plot_type, _extra=_extra, err_msg=err_msg

err_msg = ''

if keyword_set(plot_type) then self.plot_control.plot_type = plot_type

if not keyword_set(_extra) then return

tags = strlowcase (tag_names(_extra))
ntags = n_elements(tags)
props = obj_props (self)

;input_struct = _extra
;@unpack_struct

for itag = 0,ntags-1 do begin
	tag = tags(itag)

	; first see if keyword is one of allowed keywords that's not a tag in self structure, or one that needs
	; special handling (like times)

	if tag eq 'wxsize' then begin
		w = self -> get(/widgets)
		widget_control, w.w_maindrawbase, xsize=_extra.(itag)
		goto, end_of_loop
	endif

	if tag eq 'wysize' then begin
		w = self -> get(/widgets)
		widget_control, w.w_maindrawbase, ysize=_extra.(itag)
		goto, end_of_loop
	endif

	if tag eq 'utrange' then begin
		self.plot_control.utrange = anytim(_extra.(itag), /sec)
		goto, end_of_loop
	endif

	if tag eq 'utbase' then begin
		self.plot_control.utbase = anytim(_extra.(itag), /sec)
		goto, end_of_loop
	endif

	if tag eq 'timerange' then begin
		self.plot_control.timerange = anytim(_extra.(itag), /sec)
		goto, end_of_loop
	endif

	if tag eq 'input' then begin
		*self.data = _extra.(itag)
		; some objects (xyplot, utplot, specplot) have properties that should
		; be transferred into plotman defaults
		if datatype(*self.data,1) eq 'Object' then self -> set_props_from_obj

		plot_type = self.plot_control.plot_type
		if plot_type eq 'utplot' or plot_type eq 'specplot' then begin

			; utbase may be in _extra, but may not have been extracted yet. Need it here.
			if tag_exist(_extra, 'utbase') then utbase = anytim(_extra.utbase,/sec)
			if datatype(*self.data,1) ne 'Object' then begin
				trange = minmax( (*self.data)[*,0])
				if not exist(utbase) then utbase = 0.d0
			endif else begin
				if not exist(utbase) then begin
					utb = *self.data -> get(/absolute_time)
					if trim(utb[0]) ne '' and trim(utb[0]) ne '-1' then utbase=utb[0]
				endif
				if not exist(utbase) then utbase = *self.data -> get(/ut_ref)
				if trim(utbase) eq '-1' or trim(utbase) eq '' then utbase=*self.data->get(/utbase)
				if trim(utbase) eq '-1' or trim(utbase) eq '' then begin
					err_msg = 'Object ' + obj_class(*self.data) + ' does not have a ut_ref or utbase. Aborting.'
					message, err_msg, /cont
					retall
				endif
				; added valid_range check 30-jul-2007
				if not valid_range(self.plot_control.timerange) then self.plot_control.timerange = [0.d0, 0.d0]
				trange = anytim(*self.data -> get (/time_range))
				if not valid_range(trange) then begin
					try = anytim(*self.data->get(/timerange))
					if valid_range(try) then trange = try
				endif

			endelse
			self.plot_control.utbase = anytim(utbase)
			; trange might be full time, or might be relative to ut_ref.  check if > ~1980.
			if trange[0] gt 1.e7 then $
				self.plot_control.utrange = trange else $
				self.plot_control.utrange = self.plot_control.utbase + trange

		endif

		goto, end_of_loop
	endif

	if tag eq 'xlog' then begin
		 self.plot_control.xlog = _extra.(itag)
		 goto, end_of_loop
	endif

	if tag eq 'ylog' then begin
		 self.plot_control.ylog = _extra.(itag)
		 goto, end_of_loop
	endif

	if tag eq 'ynozero' then  begin
		maskon = '10'X  ; mask with 2^4 bit on
		maskoff = '11111101'X ; longword mask with every bit on except 2^4
		if _extra.(itag) eq 0 then $
			self.plot_control.yy.style = (self.plot_control.yy.style and maskoff) else $
			self.plot_control.yy.style = (self.plot_control.yy.style or maskon)
		goto, end_of_loop
	endif

	if tag eq 'xexact' then  begin
		maskon = '1'X  ; mask with 2^0 bit on
		maskoff = '11111110'X ; longword mask with every bit on except 2^0
		if _extra.(itag) eq 0 then $
			self.plot_control.xx.style = (self.plot_control.xx.style and maskoff) else $
			self.plot_control.xx.style = (self.plot_control.xx.style or maskon)
		goto, end_of_loop
	endif

	if tag eq 'yexact' then begin
		maskon = '1'X  ; mask with 2^0 bit on
		maskoff = '11111110'X ; longword mask with every bit on except 2^0
		if _extra.(itag) eq 0 then $
			self.plot_control.yy.style = (self.plot_control.yy.style and maskoff) else $
			self.plot_control.yy.style = (self.plot_control.yy.style or maskon)
		goto, end_of_loop
	endif
	
	if tag eq 'xgridline' then begin
	 self.plot_control.xx.ticklen=_extra.(itag)
	 goto, end_of_loop
  endif
	
	if tag eq 'ygridline' then begin
	  self.plot_control.yy.ticklen=_extra.(itag)
	  goto, end_of_loop
	endif
	
	if tag eq 'zgridline' then begin
	 self.plot_control.zz.ticklen=_extra.(itag)
	 goto, end_of_loop
  endif

	if tag eq 'colortable' then begin
		tvlct,rr,gg,bb,/get
		loadct, file=self.plot_control.color_file, _extra.(itag), $
			bottom=self.plot_control.bottom, ncolors=self.plot_control.ncolors+1, /silent
		tvlct,r,g,b,/get
		self.plot_control.rcolors = r
		self.plot_control.gcolors = g
		self.plot_control.bcolors = b
		tvlct,rr,gg,bb
		goto, end_of_loop
	endif

  if tag eq 'red' then begin
    red = congrid(_extra.(itag), self.plot_control.ncolors+1, /minus_one)
    self.plot_control.rcolors[self.plot_control.bottom: self.plot_control.bottom + self.plot_control.ncolors] = red    
    goto, end_of_loop
  endif
  
  if tag eq 'green' then begin
    green = congrid(_extra.(itag), self.plot_control.ncolors+1, /minus_one)
    self.plot_control.gcolors[self.plot_control.bottom: self.plot_control.bottom + self.plot_control.ncolors] = green
    goto, end_of_loop
  endif
  
  if tag eq 'blue' then begin
    blue = congrid(_extra.(itag), self.plot_control.ncolors+1, /minus_one)
    self.plot_control.bcolors[self.plot_control.bottom: self.plot_control.bottom + self.plot_control.ncolors] = blue
    goto, end_of_loop
  endif
  
	if tag eq 'exp_scale' then begin
		value = _extra.(itag)
		self.plot_control.exp_scale = value
		if value eq 1 then self.plot_control.log_scale = 0
		goto, end_of_loop
	endif

	if tag eq 'log_scale' then begin
		value = _extra.(itag)
		self.plot_control.log_scale = value
		if value eq 1 then self.plot_control.exp_scale = 0
		goto, end_of_loop
	endif

	q = tag_index (self.plot_control.pp, tag)
	if q ne -1 then begin
		self.plot_control.pp.(q[0]) = _extra.(itag)
		goto, end_of_loop
	endif

	char1 = strmid(tag,0,1)
	if is_member (char1, ['x','y','z']) then begin
		shorttag = strmid (tag,1,99)
		q = tag_index (self.plot_control.xx, shorttag)    ;xx and yy structures have same tags
		if q ne -1 then begin
			case char1 of
				'x': begin
					self.plot_control.xx.(q[0]) = _extra.(itag)
					goto, end_of_loop
					end
				'y': begin
					self.plot_control.yy.(q[0]) = _extra.(itag)
					goto, end_of_loop
					end
				'z': begin
					self.plot_control.zz.(q[0]) = _extra.(itag)
					goto, end_of_loop
					end
				else:
			endcase
		endif
	endif

	; if setting overlay information for just one overlay (instead of the array of 4 values for all 4 overlays)
	; then the parameter name will have 'c#_' prepended, where # is the number of the overlay this parameter name/value
	; applies to
	; look for regular expression, starts with c, has any number of numbers (0-9), followed by _
  cnum_pos = stregex(tag, '^c[0-9]+_', length=length)
  ov_num = -1
  nmax_overlay = self.plot_control.nmax_overlay
  if cnum_pos ne -1 then begin
       cnum = strmid(tag, cnum_pos, length)
       shorttag = strmid(tag, length, 99)
       ov_num = fix(strmid(cnum, 1, length-2))
       if ov_num gt nmax_overlay-1 then continue ; skip to end of loop

;	    char3 = strmid(tag,0,3)
;	    if is_member (char3, ['c0_','c1_','c2_','c3_']) then begin
;	  	shorttag = strmid(tag,3,99)
		  q = tag_index (self.plot_control, shorttag)
		  if q ne -1 then begin
;		  	ov_num = fix (strmid(char3,1,1))
		  	full = self.plot_control.(q[0])
		  	; some params are dimensioned (x,n), some just (n). Figure out which
		  	; dimension is the n - that's the overlay number
		  	dim = size(full,/dim)
		  	w = where (dim eq nmax_overlay)
		  	if w[0] eq 0 then full[ov_num] = _extra.(itag) else begin
		  		full[*,ov_num] = 0.  ; first 0 all values for this overlay, in case new val has fewer elements.
		  		full[0,ov_num] = _extra.(itag)
		  	endelse
		  	self.plot_control.(q[0]) = full
		  	goto, end_of_loop
		  endif
	endif

	; now look in top level of self structure
	idx = wc_where (props, tag+'*', count, /case_ignore)
	if count gt 1 then begin
		err_msg = 'Keyword is not unique.'
		message, err_msg, /cont
		return
	endif
	if count eq 1 then begin
		index = idx[0]
		if size(self.(index), /tname) eq 'POINTER' then begin
			if ptr_valid(self.(index)) then *self.(index)=_extra.(itag) else self.(index)=ptr_new(_extra.(itag))
		endif else self.(index) = _extra.(itag)
		goto, end_of_loop
	endif

	; and finally look in nested structures under self.  Will find plot_control struture before plot_defaults
	; so any tags that are in both will be changed in plot_control, not plot_defaults.
	for i = 0, n_elements(props)-1 do begin
		;help,self.(i),/st
		if size(self.(i), /tname) eq 'STRUCT' then begin
			temp = self.(i)
		   change_tag_value, temp, _extra.(itag), tag,found=found, err_msg=err_msg
		   self.(i) = temp
			if found then goto, end_of_loop
		endif
	endfor

	; if got here, then keyword was unrecognized, save in plot_args
	;message,  'Unrecognized keyword passed in.', /cont
	;help,_extra,/st
	plot_args = *self.plot_control.plot_args
	if tag_index (plot_args, tag) eq -1 then $
		plot_args = add_tag (plot_args, _extra.(itag), tag) else $
		plot_args = rep_tag_value (plot_args, _extra.(itag), tag )
	if tag_index(plot_args,'dummy') ne -1 then plot_args = rem_tag (plot_args, 'dummy')
	*self.plot_control.plot_args = plot_args

end_of_loop:
endfor

end

;-----
; For any properties that have the same name in the input object as those in the
; plot_control structure, set the value from the object into plotman.

pro plotman::set_props_from_obj

props = *self.data -> get(/all_props)
if size(props,/tname) ne 'STRUCT' then return

data_names = tag_names(props)

plotman_props = {plotman_plot_control}
plotman_props = rem_tag(plotman_props, 'dim1_colors')
plotman_names = tag_names(plotman_props)

for i = 0,n_elements(data_names)-1 do begin
	q = where (data_names[i] eq plotman_names, count)
	if count gt 0 then begin
		use_temp = 1
	 	if size(props.(i), /tname) eq 'POINTER' then begin
	 		if ptr_exist(props.(i)) then temp = *props.(i) else use_temp = 0
	 	endif else temp = props.(i)
		if use_temp then status = execute('self -> set,' + data_names[i] + '=temp')
	endif
endfor

; the color tags red,green,blue aren't properties of plotman. The internal names are rcolors, gcolors, 
; bcolors, but don't want to set those directly because then we'd lose the 17 discrete line colors at the top
; of the table. self->set,red=... congrids the array into the lower 238 slots.
if *self.data->get(/has_colors) eq 1 then begin
  if tag_exist(props,'red') then self->set, red=props.red
  if tag_exist(props,'green') then self->set, green=props.green
  if tag_exist(props,'blue') then self->set, blue=props.blue
endif

end

;-----

pro plotman::prepare_data, $
	data=data, madedummyobj=madedummyobj, use_obj_method=use_obj_method, err_msg=err_msg

err_msg=''
dataisobj = 0

if ptr_exist(self.data) then begin
	data = *self.data
	dataisobj = size(data,/tname) eq 'OBJREF'
endif

madedummyobj = 0

if self.use_extracted then begin
	objclass = self.saved_data.class

	; if using extracted data, data variable needs to be object of correct
	; class (i.e. matching the saved data) so that the correct class's method
	; will be called.  If data isn't already the correct object class,
	; make a new dummy object.

	if not dataisobj then madedummyobj = 1
	if dataisobj then if objclass ne obj_class(data) then madedummyobj = 1
	if madedummyobj then data = obj_new(objclass)

endif else begin
	if not exist(data) then begin
		err_msg = 'No data in plot object.'
		message, err_msg, /cont
		return
	endif
endelse

use_obj_method = (dataisobj)  or  (self.use_extracted)

end

;--- construct plot command depending on what's being plotted and options

pro plotman::make_plot_cmd, cmd, args, use_obj_method, $
	overlay=overlay, ov_stack=ov_stack, ov_number=ov_number, ov_squish=ov_squish

overlay = keyword_set(overlay)
ov_stack = keyword_set(ov_stack)
ov_squish = keyword_set(ov_squish)

pc = self.plot_control

q = where (pc.overlay_panel ne '', nq)
has_overlay = nq ne 0
;has_overlay = not same_data(pc.overlay_panel, ['','','',''])

do_xyplot = pc.plot_type eq 'xyplot'
do_utplot = pc.plot_type eq 'utplot'
do_image =  pc.plot_type eq 'image'
do_spec =   pc.plot_type eq 'specplot'

; overplot is 1 if we're not doing a stack type of overlay
overplot = overlay and (do_image or not ov_stack)

;args = ', xrange=xrange, yrange=yrange, zrange=pc.zz.range, ' + $
;	'charsize = charsize'
args = ', zrange=pc.zz.range, charsize = charsize'  ; 12-jan-09 - set xrange,yrange only if not overplot

if overplot then args = args + ', /overlay, legend_loc=0' else args = args + ', xrange=xrange, yrange=yrange'

if use_obj_method then begin

	cmd = 'data -> plot'

	if not overplot then args = args + ', legend_loc=pc.legend_loc, legend_color=pc.legend_color'

	args = args + $
		', no_timestamp=pc.no_timestamp, saved_data=self.saved_data, ' + $
		'plotman_obj=self, ' + $
		'_extra=plot_args'
endif else begin

	if do_xyplot then cmd = 'plot, data[*,0], data[*,1]'

	if do_utplot then cmd = 'utplot, data[*,0], data[*,1]'

	if do_image then cmd = 'plot_map, map'

	if do_spec then cmd = 'spectro_plot2, data'

	if pc.xx.title ne '' then args = args + ', xtitle=pc.xx.title' ; want default ut x title
	args = args + ', title=pc.pp.title, ' + $
		'ytitle=pc.yy.title, ' + $
		'_extra=plot_args'

endelse

if use_obj_method or do_image then $
	args = args + ', status=status, err_msg=err_msg'

if ~do_image then begin
    ; if doing multiple plots, only put xticks and x label on bottom plot, minimize y margins on
    ; other than bottom plot, and don't put titles on plots
	if ov_squish and !p.multi[2] ne 0 then begin
		args = args + ", id='', title=''"
		case !p.multi[0] of
			0: ymargin='[0,.8]'
			1: ymargin='[4,0]'
			else: ymargin='[0,0]'
		endcase
		args = args + ", ymargin="+ymargin
		; put x title only on the bottom plot (!p.multi[0] eq 1).  Middle plots have no label, no tick labels, and no xtitle.
		if !p.multi[0] eq 1 then begin
		  if pc.xx.title ne '' then args = args + ', xtitle=pc.xx.title'
		endif else args = args + ", xtickname=strarr(30)+' ', /nolabel, xtitle=''"
	endif else begin
	 ; if not squishing, set xtitle and title 
	 if pc.pp.title ne '' then args = args + ', title= pc.pp.title'
	 if pc.xx.title ne '' then args = args + ', xtitle=pc.xx.title'
	endelse
	; in all cases (non-image) set ytitle
	if pc.yy.title ne '' then args = args + ', ytitle=pc.yy.title'
endif

; For images, if not doing overlay, always set xtitle, ytitle, and title
if do_image and ~overlay then begin
  if pc.xx.title ne '' then args = args + ', xtitle=pc.xx.title'
  if pc.yy.title ne '' then args = args + ', ytitle=pc.yy.title'
  if pc.pp.title ne '' then args = args + ', title= pc.pp.title'
endif

if do_xyplot or do_utplot then begin

	if do_xyplot then args = args + ', xlog = pc.xlog'

	args = args + ', ylog = pc.ylog,' + $
				'symsize=pc.pp.symsize,' + $
				'nsum=pc.pp.nsum, psym=pc.pp.psym'

	if use_obj_method then args = args + ', class_name=self.class_name,' + $
				'dcolor=pc.color_names,' + $
				'dim1_use=dim1_use,' + $
				'dim1_colors=dim1_colors, dim1_linestyles=*pc.dim1_linestyles,' + $
				'dim1_sum=pc.dim1_sum, derivative=pc.derivative, integral=pc.integral,' + $
				'fill_gaps=pc.fill_gaps'

	if do_utplot then begin
		args = args + ', timerange=timerange'
		if not use_obj_method then args = args + ', pc.utbase'
	endif

	if overlay and not overplot then args = args + ', xstyle=1'

; End of do_xyplot or do_utplot
endif else begin  ; start of image or specplot

	if do_spec then args = args + ', timerange=timerange, ylog=pc.ylog, log_scale=pc.log_scale, ' + $
		  'interpolate=pc.interpolate, exp_scale=pc.exp_scale, ystyle=pc.yy.style'

	args = args + ', drange=pc.zz.range, ncolors=pc.ncolors+1, bottom=pc.bottom'

	if overlay then begin
		if do_image then begin
			if pc.n_overlay_levels[ov_number] gt 0 then begin
				levels = pc.overlay_levels(0:(pc.n_overlay_levels[ov_number]-1),ov_number)
				alevels = '[' + arr2str(string(levels,form='(g12.4)')) + ']'
			endif
			args = args + $
			  ', smooth_width=pc.smooth_image[*,ov_number]' + $
			  ', roll=pc.overlay_roll[ov_number], ' + $
				'xshift=pc.translate_overlay[0,ov_number], yshift=pc.translate_overlay[1,ov_number],' + $
				'c_colors=pc.overlay_color[ov_number], c_thick=pc.overlay_thickness[ov_number],' + $
				'c_labels=pc.overlay_label[ov_number], c_linestyle=pc.overlay_style[ov_number],' + $
				'percent=pc.overlay_percent[ov_number]'
			if exist(alevels) then args = args + ',levels=' + alevels
			if ov_number eq 0 then args = args + ', grid_spacing=0, limb_plot=0' ;, log_scale=pc.log_scale'
			if ov_number ne 0 then args = args + ', drotate=pc.drotate_image[ov_number]'
		endif
		if do_spec then args = args + ',xstyle=1'
		args = args + ', cbar=0'
	endif  ; end of image or specplot, yes overlay

	if not overlay then begin
    if do_spec then args = args + ',xstyle=pc.xx.style
		; use log for image, but not spec, since conflicts with log_scale in spec
		if do_image then args = args + ', log_scale=pc.log_scale'

		args = args + $
	;		'ncolors=pc.ncolors,' + $
	;		'bottom=pc.bottom,' + $
			', smooth_width=pc.smooth_image[*,0],' + $
			'limb_plot=pc.limb_plot,' + $
			'grid_spacing=pc.grid_spacing,' + $
			'gthick=pc.grid_thickness,' + $
			'gcolor=pc.grid_color,' + $
			'lcolor=pc.limb_color,' + $
			'lthick=pc.limb_thickness,' + $
			'plus_only=pc.pos_image,' + $
			'minus_only=pc.neg_image,' + $
			'rescale_zoom=pc.rescale_zoom,' + $
			'square=pc.square_scale,' + $
			'roll=pc.overlay_roll[0],' + $
			'xshift=pc.translate_overlay[0,0],' + $
			'yshift=pc.translate_overlay[1,0],' + $
			'contour=pc.contour_image,' + $
			'acolor=pc.axis_color,' + $
			'c_colors=pc.overlay_color[0],' + $
			'percent=pc.overlay_percent[0],' + $
			'c_labels=pc.overlay_label[0],' + $
			'c_thick=pc.overlay_thickness[0],' + $
			'c_linestyle=pc.overlay_style[0],' + $
			'surface=pc.surface_image,' + $
			'shade_surf=pc.shade_surf_image,' + $
			'show3=pc.show3_image,' + $
			'ax=pc.ax_surface,' + $
			'az=pc.az_surface,' + $
			'mark_point=pc.mark_point' ;,' + $
			;'/extend'

;			if pc.n_contour_levels gt 0 then begin
;				levels = pc.contour_levels(0:(pc.n_contour_levels-1))
;				alevels = '[' + arr2str(string(levels,form='(g12.4)')) + ']'
;				args = args + ',levels=' + alevels
;			endif
			if pc.n_overlay_levels[0] gt 0 then begin
				levels = pc.overlay_levels(0:(pc.n_overlay_levels[0]-1), 0)
				alevels = '[' + arr2str(string(levels,form='(g12.4)')) + ']'
				args = args + ',levels=' + alevels
			endif

		if (not has_overlay) or do_image then args = args + ', cbar = pc.cbar' else $
			args = args + ', cbar=0'			
	  
	endif  ; end of image or spec plot, not overlay 
endelse

return

end

;-----

;if plot has an overlay, then on first call to plot, overlay is 0, and then plot
; calls itself recursively with overlay=1 for overlays.  ov_stack set means we're
; stacking plots instead of a true overlay
pro plotman::plot, _extra=_extra, status=status, err_msg = err_msg, $
	overlay=overlay, ov_stack=ov_stack, $
	ov_xrange=ov_xrange, ov_timerange=ov_timerange, $
	ov_charsize=ov_charsize, ov_number=ov_number, ov_panel=ov_panel, ov_squish=ov_squish, $
	ov_yloc=ov_yloc;, ov_charthick=ov_charthick ;, ov_self=ov_self

; having this hourglass gobbles up widget events that might be queued (?) so get rid of it.
;widget_control, /hourglass

if keyword_set(_extra) then self -> set, _extra=_extra

; can't do select here because it resets !p.  Problem if we're creating a PS file.
; so do instead in each event handler that's going to do a plot in plotman.
; self -> select

status = 1
err_msg = ''

overlay = keyword_set(overlay)
ov_stack = keyword_set(ov_stack)

pc = self.plot_control

do_xyplot = pc.plot_type eq 'xyplot'
do_utplot = pc.plot_type eq 'utplot'
do_image =  pc.plot_type eq 'image'
do_spec =   pc.plot_type eq 'specplot'

default, ov_squish, pc.overlay_squish

self -> prepare_data, $
	data=data, madedummyobj=madedummyobj, use_obj_method=use_obj_method, err_msg=err_msg

if err_msg ne '' then return

!p.region = [0.,0.,0.,0.]
if not overlay then begin
	q = where (pc.overlay_panel ne '', nover)  ; and pc.overlay_panel ne 'self', nover)
	!p.multi = 0
	if nover gt 0 and pc.overlay_stack and not do_image then begin
	  !p.multi = [0,1,nover+1,0,-1]
	  yloc = self->get_yloc(ov_num=0, /frac)
	  if total(yloc) ne 0. then !p.region = [0., yloc[0], 1., yloc[1]]
	endif
endif else if total(!p.multi) ne 0 and total(ov_yloc)ne 0. then !p.region = [0., ov_yloc[0], 1., ov_yloc[1]]

self -> make_plot_cmd, cmd, args, use_obj_method, overlay=overlay, $
	ov_stack=ov_stack, ov_number=ov_number, ov_squish=ov_squish

;self -> ps_adjust

if ptr_valid(pc.plot_args) then plot_args = *pc.plot_args

val = get_pointer(pc.dim1_use, status=good)
if good then dim1_use=val

val = get_pointer(pc.dim1_colors, status=good)
if good then begin
	dim1_ids = self->get(/dim1_ids)
	nchan = is_string(dim1_ids[0]) ? n_elements(dim1_ids) : 60
	while n_elements(val) lt nchan do val = append_arr (val, val)
	dim1_colors = val[0:nchan-1]
	self -> set, dim1_colors=dim1_colors
endif

; not necessary?
; oops, this is necessary for stacked PS plots.  plotman__create_plot_file.
; only switches white to black for the first plot, so need this here for others.
; For non-color plots, plotman__create_plot_file sets dim1_colors to null string array,
; so do that here for non-color plots.
if !d.name eq 'PS' and exist(dim1_colors) and is_number(dim1_colors[0]) then begin
  if self.output_control.ps.color eq 1 then begin
    q = where (dim1_colors eq pc.color_names.white, count)
    if count gt 0 then (dim1_colors)[q] = pc.color_names.black
  endif else dim1_colors = strarr(nchan) 
endif

xrange = exist(ov_xrange) ? ov_xrange : pc.xx.range
yrange = pc.yy.range
timerange = exist(ov_timerange) ? ov_timerange : pc.timerange
;charthick = exist(ov_charthick) ? ov_charthick : pc.pp.charthick
charsize0 = exist(ov_charsize) ? ov_charsize : pc.pp.charsize
; don't scale by ch_scale here.  For multiplots, axis labels will be too small
; because we scaled here, and then IDL scales again for multiplot.  Instead
; scale all other labels that will be written individually.
;charsize = ch_scale (charsize0, /xy)
;if charsize eq 0. then charsize = ch_scale(1., /xy)
charsize = charsize0
if charsize eq 0. then charsize = 1.

if not use_obj_method then begin

	if do_xyplot then check_plotlimits, xrange, yrange, data[*,0], data[*,1], xrange, yrange

	if do_utplot or do_spec then begin
		timerange = pc.timerange
		if total(timerange) eq 0. then timerange = pc.utrange
		check_plotlimits, timerange-pc.utbase,!y.range, data[*,0], data[*,1], xrange, yrange
		timerange = xrange + pc.utbase
	endif

	if do_image then begin
		if is_struct(data) then begin
			nx = n_elements(data.data[*,0]) & ny = n_elements(data.data[0,*])
			map = data
		endif else begin
			nx = n_elements(data[*,0]) & ny = n_elements(data[0,*])
        	map = make_map( data, xc=nx/2., yc=ny/2., dx=1., dy=1., time=0. )
        endelse
        xrange = !x.range & yrange = !y.range
        ;if xrange[0] eq xrange[1] then xrange=[0,nx]
        ;if yrange[0] eq yrange[1] then yrange=[0,ny]
    endif

endif

ok = execute (cmd + args)
if not ok then begin
	print, 'Error executing plot command.  Traceback =  '
	help, /last_message, out=out
	prstr,out, /nomore
	print,'Aborting plot.'
endif

more_commands = self->get(/more_commands)
if is_string(more_commands[0]) then begin
	for i = 0,n_elements(more_commands)-1 do ok=execute(more_commands[i])
endif

if madedummyobj then obj_destroy, data

; if overlay label, space down with !C so doesn't overwrite previous label
; if ov_self don't print label, since already did for this plot
;user_label = pc.user_label
;if exist(ov_number) then user_label = arr2str(replicate('!C',ov_number+1),'') + user_label
;if not fcheck(ov_self,0) then userlabel, user_label, bottom=0, charsize=charsize*.9

; display user label for main plot, and for overlays only if not overlaying self (ov_number=0)
user_label = pc.user_label

if (overlay and do_image)or pc.contour_image then begin
	user_label = '' ; save space for user label that might have already been written
	ov_index = overlay ? ov_number : 0 ;for contour_image, we're on index 0
	if ~pc.overlay_nolabel[ov_index] then begin
  	ov_label = pc.overlay_ulabel[ov_index]
	  if ov_label eq '' then ov_label = self->strip_panel_desc(panel_desc=ov_panel)
	  if pc.overlay_ulabel_lev[ov_index] then begin
	  	nlev = pc.n_overlay_levels[ov_index]
		  if nlev gt 0 then begin
		  	levs = pc.overlay_levels[*,ov_index]
		  	levels = arr2str (trim (string (levs[0:nlev-1], format='(g15.2)')), ',')
			  ov_label = ov_label + ' ' + levels
		  endif
	  endif
	  if ov_label ne '' then $
		  user_label = arr2str(replicate('!C',ov_index+1),'') + $
			  self->color2name(pc.overlay_color[ov_index]) + ': ' + ov_label
	endif
endif

userlabel, user_label, bottom=0, charsize=charsize*.9, maxlen=90;, charthick=pc.pp.charthick

if do_utplot or do_spec then begin
	self.plot_control.utbase = getutbase()
	if self.plot_control.utrange[0] lt 0 then self.plot_control.utrange = !x.crange
	if self.plot_control.utrange[0] lt  1.e7 then $
		self.plot_control.utrange = self.plot_control.utbase + self.plot_control.utrange
endif

orig_panel_number = self.current_panel_number
;print,'orig_panel_number = ', orig_panel_number

;If this is base plot (not overlay) then run this.  When we want overlays, this block
; will call plot method recursively for overlays (but will skip this block when
; we're actually doing the overlay).
if not overlay then begin
	plotman_storesys, self
	self -> update_panel	;in case we changed any of plot control parameters
	ov_yloc = self->get_yloc(/frac)
	if nover gt 0 then begin
		ov_timerange = self.plot_control.utbase + !x.crange
		ov_xrange = crange('X') ;  self.plot_control.xx.range  correct to actual range plotted 22-oct-08
		ov_squish = self.plot_control.overlay_squish
;		ov_charthick = self.plot_control.pp.charthick
		for ip = 0,pc.nmax_overlay-1 do begin
			if pc.overlay_panel[ip] ne '' then begin
;				if pc.overlay_panel[ip] ne 'self' then begin
				if ip ne 0 then begin  ; > 0 if for overlays other than self
;					ov_self = 0
					panel = self->desc2panel(pc.overlay_panel[ip])
					if not ptr_exist(panel) then goto, next
					self -> restore_saved_data, *panel
					;Store overlay options before we load self.plot_control from this panel.
					; Then we'll restore these values, because we want to use setting of these params
					; for base image panel when plotting contour, not the value in the panel containing the
					; overlaid image
					ov_save = str_subset(self.plot_control, $
						['overlay_roll', 'smooth_image', $
						 'drotate_image', 'translate_overlay', 'overlay_color', $
						 'overlay_thickness', 'overlay_label', 'overlay_style', $
						 'n_overlay_levels', 'overlay_levels', 'overlay_percent', $
						 'overlay_nolabel', 'overlay_ulabel', 'overlay_ulabel_lev', 'no_timestamp'] )

          ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          self -> set_plot_control, (*panel).plot_control
;         free_var, self.plot_control           
;					self.plot_control = stc_clone((*panel).plot_control)
;					
					; PS files for overlaid images get screwed up when restore !y
					if self.plot_control.plot_type ne 'image' then begin
					  ; Treat thick differently because PS routine may have modified it. So get current
					  ; value and set it, but save original thick for this panel so we can restore it later.
					  ; Don't have to do this for !p variables because we're not storing them after drawing
					  ; the plot (plotman_storesys is called with no_p_
					  tempthick = !x.thick
						!x = self.plot_control.xx
						!y = self.plot_control.yy
						origthick = !x.thick
						!x.thick = tempthick
						!y.thick = tempthick
					endif
					self -> load_colors
					;now put saved overlay options in self.plot_control
					pctemp = self.plot_control
					struct_assign, ov_save, pctemp, /nozero
					self.plot_control=pctemp

				endif

				if do_utplot or do_spec then xr = [0.,0.] else xr = ov_xrange ;crange('x')
				
				self -> plot, /overlay, ov_stack=pc.overlay_stack, $		; recurse to overlay plots
					ov_xrange=xr, ov_timerange=ov_timerange, ov_charsize=charsize0, $
					ov_number=ip, ov_panel=pc.overlay_panel[ip], ov_squish=ov_squish, $
					ov_yloc=ov_yloc[*,ip] ;, ov_charthick=ov_charthick ;, ov_self=ov_self
				if pc.overlay_panel[ip] ne 'self' and not do_image then begin
					; store !x,!y variables in panel structure for panel that was overlaid, so
					; that interactive commands (zooming, pointing) will work in any plot in a multiplot
					; (don't need to do this for images, since overlay always uses base plot's limits,
					; and if do this then when overlaid plot is plotted separately, it has the limits of
					; the base plot - wrong.)
					; (then restore the original thick value for this plot)
					plotman_storesys, self, /no_p
					if exist(origthick) then begin
						self.plot_control.xx.thick = origthick
						self.plot_control.yy.thick = origthick
					endif
					(*panel).plot_control.xx = self.plot_control.xx
					(*panel).plot_control.yy = self.plot_control.yy
				endif

			endif
			next:
		endfor
	endif
endif

if overlay then return

!p.multi = 0

; after making a plot, sometimes can't click in the IDLDE window until click in the widget first.
; Don't know why, but this seems to fix that problem.
; Hmm maybe this isn't necessary? 22-may-2006.  Added back in 20-jun-2006, otherwise if init plotman
; with nomap, and then do a plot, it never shows it.
widget_control, self.plot_base, /map

;print,'setting focus to ', orig_panel_number
self -> focus_panel, dummy, orig_panel_number

self -> unselect

end

;-----

pro plotman::utplot, _extra=_extra

self -> plot, _extra=_extra
end

;-----

function plotman::dev2data, x, y

;common last_spectro_plotobj, plotobj_save

;if self.plot_control.plot_type eq 'specplot' then begin
;	if not self -> get(/is_hessi_obj) then begin
;		xd = (self -> get(/data)) -> dev2data (x, valdev=x, dir='X')
;		yd = (self -> get(/data)) -> dev2data (y, valdev=y, dir='Y')
;		data = [xd, yd]
;	endif else begin
;		if is_class(plotobj_save, 'specplot') then begin
;			xd = plotobj_save -> dev2data (x, valdev=x, dir='X')
;			yd = plotobj_save -> dev2data (y, valdev=y, dir='Y')
;			data = [xd, yd]
;		endif
;	endelse
;endif

if not exist(data) then data = (convert_coord  (x, y, /device,/to_data, /double))[0:1]; just x,y not z

return, data ; < 1.e38	; if data is Inf, restrict to largest float
end

;-----

pro plotman::export, text=text, $
	idlsave=idlsave, $
	fits=fits, $
	filename=filename, $
	quiet=quiet, $
	msg=msg, $
	_extra=_extra

self -> prepare_data, $
	data=data, madedummyobj=madedummyobj, use_obj_method=use_obj_method, err_msg=err_msg

if err_msg ne '' then return

dialog_type = 'warning'

if use_obj_method then begin

	; use execute in case object doesn't have a 'command' method, then won't stop here, just prints
	; message.
	if exist(_extra) then args = join_struct(_extra, *self.plot_control.plot_args) else args=*self.plot_control.plot_args
	ok = 0
	case 1 of
		keyword_set(text): begin
			command = 'list'
			ok = execute('list = data -> list (saved_data=self.saved_data, ' + $
				'filename=filename, class_name=self.class_name, err_msg=err_msg, _extra=args)')
			end

		keyword_set(fits): begin
;			self -> image_fitswrite, filename=filename, err_msg=err_msg, quiet=quiet
      ; if we find routine, then err_msg will be reset by it to either a blank string (success) or
      ; and error message.  By setting err_msg first, avoid writing success message below if failed
      ; to find routine.
      err_msg = 'Only for RHESSI images.  No hsi_image_plotman2fits routine found. Aborting.'
      call_procedure, 'hsi_image_plotman2fits', plotman_obj=self, filename=filename, err_msg=err_msg, quiet=quiet
			ok = 1
			; print err_msg below (quiet=0) only if failed to find procedure (i.e. err_msg hasn't changed)
			quiet = strmid(err_msg,0,4) eq 'Only' ? 0 : 1
			end

		keyword_set(idlsave): begin
			command = 'savwrite'
			ok = execute ('data -> savwrite, saved_data=self.saved_data, ' + $
				'savfile=filename, err_msg=err_msg,' + $
				'class_name=self.class_name, quiet=quiet, _extra=args' )
			end

		else: print, 'This export not implemented yet.'
	endcase

	if ok then begin
		msg = err_msg
		if msg eq '' then if exist(filename) then msg = '  Created output file: ' + filename else $
			msg = '  Created output file.  '
		dialog_type = 'info'
	endif else msg = 'ERROR - no ' + command + ' method for this object.'

endif else begin
	msg = 'Can not use export function yet for data that is not in an object.'
endelse

if not keyword_set(quiet) then begin
	message, msg, /cont
	a = dialog_message (msg, info=(dialog_type eq 'info') )
endif

if madedummyobj then obj_destroy, data

end

;-----

pro plotman::summ_params, params_list=out, screen=screen, quiet=quiet

self -> prepare_data, $
	data=data, madedummyobj=madedummyobj, use_obj_method=use_obj_method, err_msg=err_msg

if err_msg ne '' then return

msg = ''
if use_obj_method then begin

	; use execute in case object doesn't have a 'command' method, then won't stop here, just prints
	; message.
	ok = 0
	ok = execute('data -> params, saved_data=self.saved_data, params_list=out, screen=screen')
	if not ok then msg = 'ERROR - no PARAMS method for this object.'

endif else $
	msg = 'Can not use Summ Params function yet for data that is not in an object.'

if msg ne '' and not keyword_set(quiet) then begin
	message, msg, /cont
	widget_control, self.plot_base, get_uvalue=state
	widget_control, state.widgets.w_message, set_value=msg
endif

if madedummyobj then obj_destroy, data

end

;-----

pro plotman::magnify, _extra=_extra

if  self -> valid_window(/message) then begin

	widget_control, self.plot_base, get_uvalue=state
	flash_msg, state.widgets.w_message,  num=3, rate=.1, $
		'Press left mouse button to magnify, right button to quit.'
	self -> select
	bottom = self -> get(/bottom)
	ncolors = self -> get(/ncolors)
	scope, psym=0, /noscale, _extra=_extra
	widget_control, self.plot_base, /clear_events
	self -> unselect
endif
end

;-----
; return name of color corresponding to colorindex, e.g. 243 -> 'RED'
function plotman::color2name, colorindex
ncolors = self -> get(/ncolors)
cn = self -> get(/color_names)
return, (tag_names(cn))[colorindex - ncolors -1]
end

;-----

pro plotman__define

self = { plotman, $

	plot_base: 0L, $			; widget ID of base widget for plotman (may have been created outside of plotman)
	data: ptr_new(), $			; pointer to data array or object to plot
	class_name: '', $			; class_name within object to plot

	saved_data: {plotman_saved_data},$			;structure containing info for reconstructing a plot panel
	use_extracted: 0, $

	plot_control: {plotman_plot_control}, $		;structure of parameters used to control plot (see plotman_plot_control__define)
	plot_defaults: {plotman_plot_control}, $

	tags_data_dep: strarr(10), $	; data-dependent tags in plot_control structure (i.e. if setting defaults, exclude)

	temp_pref: ptr_new(), $		; when changing plot setting for multiple files, store here first

	xy_pref: ptr_new(), $		; users's xy plot preferences structure (or -1 if none)
	ut_pref: ptr_new(), $		; users's ut plot preferences structure (or -1 if none)
	image_pref: ptr_new(), $	; users's image plot preferences structure (or -1 if none)
	spec_pref: ptr_new(), $		; users's spectrogram plot preferences structure (or -1 if none)

	xy_file_pref: '', $			; file to read xy plot preferences from and save to (in temp_dir)
	ut_file_pref: '', $			; file to read ut plot preferences from and save to (in temp_dir)
	image_file_pref: '', $		; file to read image plot preferences from and save to (in temp_dir)
	spec_file_pref: '', $		; file to read spectrogram plot preferences from and save to (in temp_dir)

	red_bmp: bytarr(7,7,3), $		; file containing red button bitmap
	green_bmp: bytarr(7,7,3), $		; file containing green button bitmap

	output_control: {plotman_output_control}, $		; structure of parameters used to control plot output (see plotman_output_control__define)
	intervals: ptr_new(), $

	mark_box_contour_level: 0., $ 	; initial contour level in mark box widget
	mark_box_contour_percent: 0, $	; initial setting for percent option in mark box widget

	orig_r: intarr(256), $		; original red, green, blue color table
	orig_g: intarr(256), $
	orig_b: intarr(256), $

	max_panels: 0, $			; maximum number of panels to save
	panels: obj_new(), $		; linked list containing info about all panels
	current_panel_number: 0, $  ; item number in linked list of current panel

	multi_panel: 0, $
	last_window_choice: 'None' }

end
