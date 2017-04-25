;+
;
; NAME:
;	DO_FITSFILES_ASCII
;
; PURPOSE:
;	Create FITS format files for all days between firstday and lastday 
;	for GOES 6, GOES 7, GOES 8, GOES 9, and GOES 10, 11, 12, 14.
;
; CATEGORY:
;       GOES
;
; CALLING SEQUENCE:
;       DO_FITSFILES, Firstday, Lastday
;
; CALLS:
;       UTIME, GFITS_W, ATIME
;
; INPUTS:
;       Firstday:	First day passed as ASCII times - 'yy/mm/dd'
;	Lastday:	Last day passed as ASCII times - 'yy/mm/dd'
;
; OUTPUTS:
;       None explicit. Gfits_w crates fits file on disk.
;
; PROCEDURE:
;       Call utime atime to turn 'yy/mm/dd' into number of seconds past
;	79/1/1,000 ; call atime to turn the firstday into 
;	'dd-Mon-yy hh:mm:ss.xxx' and call gfits_w to write fits files for 
;	all days between firstday and lastday.
;
; MODIFICATION HISTORY:
;	Written by Kim Tolbert, 07/93
;	Mod. 05/95 by AES. Added call for GOES 8.
;	Mod. 08/12/96 by RCJ. Added documentation.
;	Mod. 10/07/96 by AES. Removed calls for GOES 6 & 7,
;		since that data has stopped coming in.
;       Mod. 7/21/98 by AES.  Added call for GOES 10.
;	Mod. 1/19/98 by AES.  Added y2k keyword so FITS headers will
;	        be y2k compliant. Removed call for GOES 9, no longer funct.
;	Mod. 6/25/03 by AES.  Added call for GOES 12.
;	Mod. 10/17/05 by AES  Changed calls to use ascii 3-hour files
;	Mod. 6/21/06 by AES Added call for GOES 11.
;	Mod. 4/13/10 by Kim Tolbert.  Added call for GOES14
;	Mod. 8-Nov-2010 by Kim Tolbert.  Added call for GOES15
;	29-Nov-2012, Kim.  NOTE - THIS ROUTINE IS NO LONGER CALLED BY GET_GOES (or anything!)
;-

pro do_fitsfiles_ascii, firstday, lastday

ufirstday = utime(firstday)
ulastday = utime(lastday)

utime = ufirstday
while utime le ulastday do begin
;   gfits_w, atime(utime), 6
;   gfits_w, atime(utime), 7
   gfits_w_ascii, atime(utime), 8, /y2k
;   gfits_w, atime(utime), 9, /y2k
   gfits_w_ascii, atime(utime), 10, /y2k
   gfits_w_ascii, atime(utime), 11, /y2k
   gfits_w_ascii, atime(utime), 12, /y2k
   gfits_w_ascii, atime(utime), 14, /y2k
   gfits_w_ascii, atime(utime), 15, /y2k   
   utime = utime + 86400.d0
endwhile

return & end
