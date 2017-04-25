;+
; Name:  goesplot
;
; Purpose: Dummy routine.  goesplot is obsolete
;
; Category:
;
; Calling Sequence:
;
; Explanation: goesplot was used in the old goes workbench.  This was replaced
;  by a new goes workbench that uses the new goes object in December 2005.
;
; Inputs:
;
; Outputs:
;
; History:  Kim Tolbert, 20-Dec-2005
;
;-

pro goesplot, _extra=_extra

msg = [ $
	'', $
	'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', $
	'', $
	'The goesplot routine is obsolete.  Please use the new GOES software, documented at', $
	'http://orpheus.nascom.nasa.gov/~zarro/idl/goes/goes.html', $
	'', $
	'If you really want to use goesplot or the old GOES workbench, the routines', $
	'you need are in the tar file ssw_packages_goes.tar.Z at', $
	'ftp://sohoftp.nascom.nasa.gov/solarsoft/offline/swmaint/', $
	'Download this tar file, unpack it, and put the routines in your path.', $
	'', $
	'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' ]

prstr, msg, /nomore

end
