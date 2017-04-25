function conv_h2p, helio, date0, behind=behind, arcmin=arcmin, $
		roll=roll, $
		hxa=hxa, cmd=cmd, suncenter=suncenter, $
		pix_size=pix_size0, radius=radius
;
;+
;NAME:
;	conv_h2p
;PURPOSE:
;	To convert from a pixel location to heliocentric coordinates
;SAMPLE CALLING SEQUENCE:
;	pix = conv_h2p(helio, date)
;	pix = conv_h2p( [ew,ns], date)
;	pix = conv_h2p(helio, suncenter=[400,400])
;INPUT:
;	helio	- The heliocentric angle in degrees
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;OPTIONAL INPUT:
;	date	- The date for the conversion in question.  This is needed
;		  for SXT so that the pixel location of the center of the sun
;		  can be determined.
;OUTPUT:
;	pix	- The pixel coordinates of the point(s) in question.  Larger pixel
;		  address towards the N and W.
;			(0,*) = E/W direction
;			(1,*) = N/S direction
;OPTIONAL KEYWORD INPUT:
;	roll	- This is the S/C roll value in degrees
;	
;	hxa	- If set, use HXA_SUNCENTER to determine the location of the
;		  sun center in pixels.  Default is to use GET_SUNCENTER.
;	cmd	- If set, use SXT_CMD_PNT to determine the location of the
;                 sun center in pixels. Default is to use GET_SUNCENTER.
;	suncenter- Pass the derived location of the sun center in pixels (x,y)
;
;	pix_size- The size of the pixels in arcseconds.  If not passed, it
;		  uses GT_PIX_SIZE (2.45 arcsec).  This option allows the
;		  routine to be used for ground based images.
;	radius	- The radius in pixels.  GET_RB0P is called to get the radius
;		  and it is used to get the pixel size.  This option allows the
;		  routine to be used for ground based images.
;OPTIONAL KEYWORD OUTPUT:
;	behind -  A flag which is set to 1 when there are points behind the limb.
;HISTORY:
;	Written 16-Jun-93 by M.Morrison
;       Corrected keyword useage 29-jun-93 A.McA.
;       16-Oct-93 (MDM) - Removed the tilt keyword input
;-
;
ang = conv_h2a(helio, date0, behind=behind, arcmin=arcmin)

out = conv_a2p(ang, date0, arcmin=arcmin, roll=roll, $
		hxa=hxa, cmd=cmd, suncenter=suncenter, $
		pix_size=pix_size0, radius=radius)
;
return, out
end
