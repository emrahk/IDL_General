pro image2gifanim, filelist, r, g, b, _extra=_extra
;+
; ----------------------------------------------------------------------------
;   Name: image2gifanim
;
;   Purpose: convert an image file sequence (gif, jpeg) to gif animation
;
;   ======================================================================
;   INTERFACE: - SEE IMAGE2MOVIE FOR INTERFACE DETAILS, RESTRICTIONS, etc.
;   ======================================================================
;
;   History:
;      5-mar-1997 (SLF) - Just made this a call to image2movie
;
; ----------------------------------------------------------------------------
;-
; Just call image2movie,/gif_animate via keyword inheritance
; -----------------------------------------------------------------------------
image2movie,  filelist, r, g, b, _extra=_extra , /gif_animate
; -----------------------------------------------------------------------------
return
end
