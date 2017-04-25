pro image2mpeg, filelist, r, g, b, _extra=_extra
;+
; ----------------------------------------------------------------------------
;   Name: image2mpeg
;
;   Purpose: convert an image file sequence (gif, jpeg) to mpeg movie
;   
;   ======================================================================= 
;   INTERFACE: - SEE IMAGE2MOVIE FOR INTERFACE DETAILS, RESTRICTIONS, etc.
;   ======================================================================= 
;
;   History:
;      5-mar-1997 (SLF) - Just made this a call to image2movie
; ----------------------------------------------------------------------------
;-
; Just call image2movie,/mpeg via keyword inheritance
; -----------------------------------------------------------------------------
image2movie,  filelist, r, g, b,  _extra=_extra , /mpeg 
; -----------------------------------------------------------------------------
return
end
