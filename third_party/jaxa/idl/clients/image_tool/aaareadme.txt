                        Solar image display and interaction
                        -----------------------------------

The routines in this directory are used to display solar images and to locate
features and locations upon them.

They were provided by CDS but are expected to be generally useful for the SOHO
community.

============================================================================

As of 21-Apr-95  the files were:

 
Directory:  /sohos1/cds/soft/soho_util/plan/image_tool/
 
CNVT_COORD()      - Conversion between any 2 of 4 coord systems for solar images
CROSS_HAIR        - Plot a cross hair on the current plotting device.
CURSOR_INFO       - Report cursor's position to a text widget.
DIFF_ROT()        - Computes the differential rotation of the sun
DMY2YMD()         - To convert date string DD-MM-YY format to YY/MM/DD format.
DSP_STRARR        - To display a string array in a text widget.
FAKE_POINT_STC()  - Create a fake pointing structure for IMAGE_TOOL to use
FIND_LIMB2        - Find the solar coordinates from an aspect camera image.
FIT_CIRCLE()      - Fit a circle to vector of points.
FIX_STRLEN()      - Make a string have a fixed length by appending spaces.
FLASH_PLOTS       - Make a flashing plot of a polygon
FSUMER_DETAIL()   - Create a fake sumer detail structure
FXKVALUE()        - Get value from a set of candidate keywords of a FITS header
GAUSS_FUNCT2      - Evaluate the sum of a gaussian and a 2nd order polynomial.
GET_CDS_POINT     - Create structure from given CDS plan for use in IMAGE_TOOL
GET_OBS_DATE()    - Get date and time of obs. from FTIS header in CCSDS format.
GET_SUMER_POINT() - Make pointing structure for IMAGE_TOOL from SUMER study
IMAGE_TOOL        - User interface of the CDS Pointing Tool
IMAGE_TOOL_COM    - Common blocks for IMAGE_TOOL
ITOOL_ZOOM        - Zoom in on part of an image in a given draw widget window
LIMB_INFO         - Get position of solar disk center and radius from an image.
UPDATE_FITLIMB    - Updates contents of the limb-fitting widget
MK_POINT_BASE     - Make widget base for pointing for SOHO instrument
MK_POINT_STC      - Make a fresh pointing structure to be used by IMAGE_TOOL
PLOT_AXES         - Plot axes and labels around the current displayed image
POLYGON_CSR       - Make a size-fixed polygon cursor movable with a mouse
RASTER_SIZE       - Get raster size based on RASTER structure from GET_RASTER.
RD_IMAGE_FILE     - Driver program of FXREAD and CDS_IMAGE to read any FITS file
ROT_SUBIMAGE      - Modify an image array with a rotated region
SEP_FILENAME      - Separates a filename into its component parts.
SET_CSI           - Obtain image scale and disk center coord. from FITS header
SOLAR_GRID        - To plot gridding lines on the solar image
SUMER_POINT_STC() - Make pointing structure for IMAGE_TOOL from SUMER study
TVZOOM2           - Zooms into the current image display window.
XGET_SYNOPTIC()   - Return a string array of CDS synoptic image file names
XSEL_ITEM()       - Select item from a given string list (similar to XSEL_LIST)

