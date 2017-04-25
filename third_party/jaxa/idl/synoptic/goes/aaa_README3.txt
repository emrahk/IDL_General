Notes on GOES software, Kim Tolbert

26-Jun-2012

NOTE: There is a file called goes_fits_files_notes.txt in the hesperia goes data dir (/data/goes) that gives some history of the FITS files.

The s/w that writes the SDAC GOES FITS files had 2 errors and a time interpretation change and were re-written - see txt file in goes data dir.

The s/w that reads the SDAC GOES FITS files had an error - we were saving times in seconds as integers, so were losing fractional part of time. Now
save as msec integer long words.