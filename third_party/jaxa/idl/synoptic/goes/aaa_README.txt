Kim Tolbert
13-Dec-2005


This directory contains:

1. The new improved goes object which now calculates temperature and emission measure as well as returning the two flux channels, and can find the SDAC or YOHKOH GOES files either locally or across the network.  The goes object can subtract background, and incorporates the chianti/abundance additions Stephen White made in September 2005.  It can be run from the command line and/or the GUI.

2.  The new GOES workbench which completely supercedes both the original GOES workbench and the newer SW_GOES workbench.  The new GOES workbench (called by typing goes in IDL) uses the new goes object.  This GUI and the command line can be used interchangeably to set parameters and get data from the object. 

3.  The routines that calculate the GOES response functions.

4.  The routines used to write the GOES SDAC FITS files.

The new GOES object is described in http://beauty.nascom.nasa.gov/~zarro/idl/goes/goes.html

This directory, $SSW/gen/idl/goes, replaces $SSW/packages/goes/idl.  We moved the routines from a 'packages' directory to a 'gen' directory so that users will get the GOES software by default, reasoning that users from many instruments/groups use goes regularly.  Eventually we will phase out the selection of GOES as a package on the SSW installation page.

The old GOES workbench and the old goesplot routine are stored in an offline tar file:
ftp://sohoftp.nascom.nasa.gov/solarsoft/offline/swmaint/ssw_packages_goes.tar.Z
in case you really need to retrieve them.  


--------------------
For reference here are Stephen White's comments when he modified the temp and em meas calculations to use chianti in September, 2005.  His explanation:

"The routine SW_GOES is a drop-in replacement for the old GOES widget that
adds the ability to choose the abundances used in calculation of
temperature and emission measure, as explained in White, Thomas, Schwartz,
Solar Phys, 2005.  It has been corrected (August 2005) for the fact that
the reported GOES fluxes for GOES 8-12 are not the true measured fluxes
(the scl89 factor in goes_chianti_tem.pro).

This version of the routines uses spectra from CHIANTI 5.1.

The convolution of GOES XRS responses with CHIANTI spectra needed to
invert the GOES measurements into temperature T and emission measure EM
are contained in the routines GOES_GET_CHIANTI_TEMP and
GOES_GET_CHIANTI_EM. These are called by the routine GOES_CHIANTI_TEM
which replaces GOES_TEM in the old version. In order for the GOES widget
to call up the CHIANTI versions, the routine SW_TEM_CALC replaces the old
TEM_CALC.

Implementation: just make sure that the five new routines are in the IDL
search path under SolarSoft and type "sw_goes"."
--------------------

This new version has a few changed names from S. White's version for simplicity and consistency:

sw_goes is gone.  goes is the main goes workbench GUI, and includes the chianti/abundance stuff.

goes_tem is now the main routine to call to calculate temperature or emission measure (previously was tem_calc, or later sw_tem_calc).

goes_tem calls either goes_mewe_tem (previously goes_tem) or goes_chianti_tem depending on user's choice of abundance model.  goes_chianti_tem calls goes_get_chianti_em and goes_get_chianti_temp.

(Previously, goes_tem just did the mewe version, so the old goes_tem is now goes_mewe_tem.  The old sw_tem_calc called goes_tem (for mewe) and goes_chianti_tem(for coronal and photosperic)).

NOTE:  Added the routine goes_get_chianti_version.  This has the version number hard-coded (I don't know how else to get it!).  If goes_get_chianti_temp or goes_get_chianti_em or updated to a new version of chianti, goes_get_chianti_version needs to be modified.
