		      SERTS Image Display Routines

		      Last modified: 22 April 1994


These routines form the part of the SERTS subroutine library pertaining
to image display.  They are designed to be compatible with any IDL
device capable of image display, including Sunview, X-windows, Tektronix
4100 series terminals and above, and PostScript.  The routines are
designed to work together as a unit.

There are several non-standard system variables that are used by these
routines.  These system variables are defined in the procedure IMAGELIB.
It is suggested that the command IMAGELIB be placed in the user's
IDL_STARTUP file.

This software also requires the SERTS graphics devices software, generally
found in a parallel directory at the site where this software was obtained.

The software in this directory are described in more detail in the LaTeX
document "image_display.tex".

These routines fall into several categories:

1.  Displaying images:

	EXPTV		PUT		EXPAND_TV	SCALE_TV
	SETIMAGE	WDISPLAY

The basic principle behind these routines is to scale the image to the
size in pixels of the area available for display.  This frees the user
from needing to worry about the details of the image display device
being used.  Images are either magnified or reduced by an integral scale
factor.  For instance, a 100x100 array may be magnified by 5 to 500x500
so as to fit within a 512x512 window.  On the other hand a 2000x300
image would be reduced by 4 to 500x75 to fit within the same window.
Internally, these routines use SCALE_TV to calculate the scale, and
EXPAND_TV to display the images, but these would not normally be used
directly by the user.  EXPTV and PUT are the basic user interface
routines for displaying images.

One can specify that only a certain section of the image display area be
used for a particular image, so that multiple images can be displayed
side by side.  The routine SETIMAGE is used to control this feature.
PUT will call SETIMAGE for you.

WDISPLAY can be used to place an image in a window of its own, sized to
fit.

A number of keywords and flags (see below) can override various aspects
of the default behavior of these routines.

2.  Controlling where the images will appear.

	TVDEVICE	TVSELECT	TVUNSELECT	TVSCREEN

These routines allow one to direct image display output and graphics to
separate displays, or to separate windows on the same display.  The
routine TVDEVICE selects which graphics device or window will be used
for images.  (For instance, TVSCREEN calls TVDEVICE to create a window
and direct image display output.)  TVSELECT and TVUNSELECT will then
switch back and forth between this display and that used for graphics.
These two routines are already incorporated into the routines in this
library.

3.  Manipulating flags defining various default conditions.

	SETFLAG		UNSETFLAG	ENABLEFLAG	SHOWFLAGS
	IM_KEYWORD_SET	GET_IM_KEYWORD

As well as keywords, the routines in this library are programmed to
examine a structured system variable called !IMAGE.  This system
variable contains the state of a number of flags, which are the default
values for a number of keyword parameters.  This saves the user the
trouble of having to pass these keywords to each and every routine.

Many routines have a MISSING keyword.  This keyword is used to set a
value which is used to flag missing pixels, i.e. those pixels that don't
represent valid data.  For example, setting MISSING to 32000 would mean
that pixels with a value of 32000 should be ignored.

4.  Displaying graphics over images.

	CONTV	(CONTOUR)		TVPLOT_TRACE
	TVPLT	(OPLOT)			LABEL_IMAGE
	TVOUT	(XYOUTS)
	TVAXIS	(AXIS)
	TVPOS	(CURSOR)

These routines are designed to take the place of, and augment, the
normal IDL graphics routines.  The coordinate system used by these
routines is that of the pixels of the image array (not the screen pixels
of the displayed image).

There is another way to combine graphics and images.  The routine
PLOT_IMAGE will display an image with axes around it.  Then, ordinary
graphics calls (CURSOR, OPLOT, etc.) can be used instead of the above
equivalents.  There is also an OPLOT_IMAGE routine.

5.  Displaying velocity images.

	LOAD_VEL	COMBINE_VEL	FORM_VEL	FORM_INT

Finally there are routines devoted to displaying velocity images.  These
routines use a special color table to displaying images containing
velocity information, in which positive values come out blue and
negative ones red.  It is also possible to display an intensity image
and a velocity image side by side, each with its own color table.

It's also possible to combine any two color tables through the use of
the routine COMBINE_COLORS.

Although one could call the functions FORM_VEL and FORM_INT directly,
it's easier to let EXPTV or PUT call these routines for you, through the
use of the VELOCITY, COMBINED, and LOWER keywords.  This is especially
true when used in conjunction with other keywords such as MISSING, MIN,
MAX, etc.

Example 1:  Displaying a velocity image using the velocity color table

		LOAD_VEL
		EXPTV, Array, /VELOCITY

Example 2:  Displaying an intensity and velocity image side-by-side,
	    using color table #3 for the intensity image

		LOADCT,3
		COMBINE_VEL
		PUT, Int_array, 1, 2, /COMBINED
		PUT, Vel_array, 2, 2, /COMBINED, /VELOCITY

Example 3:  Display two images side by side, using color table #3 for
	    the first, and color table #5 for the second.

		LOADCT,3
		COMBINE_COLORS,/LOWER
		LOADCT,5
		COMBINE_COLORS
		PUT, Array1, 1, 2, /COMBINED, /LOWER
		PUT, Array2, 2, 2, /COMBINED

In addition to the above routines, there are numerous other routines
related to image processing.

Questions should be directed to:

	PAL::THOMPSON				(SPAN)
	William.T.Thompson.1@gsfc.nasa.gov	(Internet)

-----------------------------------------------------------------------------

As of 21-Apr-95 files are:
 
 
Directory:  /sohos1/cds/soft/util/image/
 
ADJUST()          - Adjust the range of an image.
ADJUST_COLOR      - Adjust the color table with the cursor.
BLINK             - Blinks two images together by modifying the color tables.
BOX_CURSOR2       - Emulate the operation of a variable-sized box cursor.
BSCALE            - Scale images into byte arrays suitable for displaying.
BYTSCLI           - Variation on BYTSCL which allows MAX < MIN.
COLOR_BAR         - Display a color bar on an image display screen.
COMBINE_COLORS    - Combines two color tables into one.
COMBINE_VEL       - Combines current color table with a velocity color table.
CONGRDI()         - Interpolates an array into another array.
CONTV             - Places contour plots over displayed images.
CROSS_CORR2()     - Takes two-dimensional cross-correlation of two arrays.
CW_TVZOOM         - Compound widget for displaying zoomed images. (cf CW_ZOOM).
ENABLEFLAG        - Reenable a previously set but disabled image display flag.
EXPAND_TV         - Expands and displays an image.
EXPTV             - Uses SCALE_TV and EXPAND_TV to display an image.
FORM_INT()        - Scales an intensity image for use with split color tables.
FORM_VEL()        - Scales a velocity image for display.
GET_IM_KEYWORD    - Gets the value of a SERTS keyword/flag.
GET_TV_SCALE      - Retrieves information about displayed images.
GOOD_PIXELS()     - Returns all the good (not missing) pixels in an image.
HISCAL()          - Performs histogram equalization on an array.
IM_KEYWORD_SET()  - Checks whether an image display keyword/flag is set.
IMAGELIB          - Defines variables/common blocks for the SERTS IMAGE library.
INT_STRETCH       - Stretch one of two combined intensity color tables.
INTERP2()         - Performs a two-dimensional interpolation on IMAGE.
LABEL_IMAGE       - Puts labels on images.
LINECOLOR         - Set a color index to a particular color.
LOADCT            - Load predefined color tables.
LOAD_VEL          - Loads a velocity color table.
OPLOT_IMAGE       - Overplot an image.
PLOT_IMAGE        - Display images with plot axes around it.
POLY_VAL()        - Returns values from polygonal areas of displayed images.
PROF()            - Returns profiles from arrays along the path XVAL, YVAL.
PUT               - Places one of several images on the image display screen.
SCALE_TV          - Scales an image to best fit the image display screen.
SET_LINE_COLOR    - Define 11 different colors for the first 11 color indices
SETFLAG           - Sets flags to control behavior of image display routines.
SETIMAGE          - Allow several images in one window.
SHOW_COLORS       - Displays the current color table.
SHOWFLAGS         - Show the settings controlled by SET/UNSET/ENABLEFLAG.
SIGRANGE()        - Selects the most significant data range in an image.
STORE_TV_SCALE    - Store information about displayed images.
TVAXIS            - Places X and/or Y axes on displayed images.
TVBOX             - Interactively select a box on displayed images.
TVDEVICE          - Defines the default image display device or window.
TVERASE           - Erases image display screen.
TVOUT             - Outputs text onto images.
TVPLT             - Plots points on displayed images.
TVPOINTS          - Selects a series of points from a displayed image.
TVPOS             - Returns cursor positions on displayed images.
TVPRINT           - Sends the contents of a window to a PostScript printer.
TVPROF            - Uses the cursor to get a profile from a displayed image.
TVPROFILE         - Interactively draw profile of an image in separate window.
TVREAD()          - Reads contents of an image display screen into an array.
TVSCREEN          - Create window 512 (or 256) pixels on a side for images.
TVSELECT          - Select image display device/window defined by TVDEVICE.
TVSUBIMAGE()      - Interactively selects a subimage from a displayed image.
TVUNSELECT        - Inverse to the TVSELECT routine.
TVVALUE           - Interactively display the values in an image.
TVZOOM            - Zooms into the current image display window.
UNSETFLAG         - Unset a flag field set by SETFLAG.
VEL_STRETCH       - Stretch velocity color tables, either alone or combined.
WDISPLAY          - Displays images in a window all their own, sized to fit.
XBLINK            - Blinks two images together by using XMOVIE.
XGAMMA            - Widget interface to control the screen brightness.
XLOAD             - Widget control of color tables, with SERTS enhancements.
XMOVIE            - Animates a series of images under widget control.
ZOOM              - Zoom in on part of an image.
