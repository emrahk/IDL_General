Kim Tolbert

26-Jun-2012 
GOES 13 (no data for us), 14, and 15 data are now provided as full day ascii (csv) files at http://satdat.ngdc.noaa.gov/sem/goes/data/new_full/.  The routines that copy them, read them, and create the SDAC GOES FITS files are get_goes, do_fitsfiles_ascii, gfits_w_ascii and goes_day_ascii.  There is a file called goes_fits_files_notes.txt in the hesperia goes data dir (/data/goes) that gives some history of the FITS files.

20-Dec-2005

do_fitsfiles, gfits_w, goes_3hour were the routines that write the SDAC GOES FITS files until ~September 2005.  At that time, NOAA started sending ASCII 3-hour files instead of binary 3-hour files.  Amy Skowronek modified the routines to accomodate this change, so now the routines used are do_fitsfiles_ascii, gfits_w_ascii, goes_3hour_ascii.