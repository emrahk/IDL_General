#!/bin/csh
# This script is run by a cron job on sdac2.nascom.nasa.gov to
# retrieve the GOES daily file from NGDC and write a FITS file.
# Kim Tolbert

setenv SSW /service/soho-archive/solarsoft
alias idl /Applications/itt/idl/bin/idl
setenv OS OSX
source $SSW/gen/setup/setup.ssw
setenv IDL_PATH +~/sdac/soft:+~/software/sdac

cd /Users/ktolbert/goes
sswidl get_goes_run.pro
exit

