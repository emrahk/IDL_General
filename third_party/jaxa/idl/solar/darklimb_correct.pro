PRO darklimb_correct,imgin, imgoutt, lambda=lambda, bandpass=bandpass,$
   limbfilt=limbfilt, imgout=imgout, limbxyr=limbxyr

;       ---------------------------------------------------------------
;+                                                      14-Oct-96
;       NAME: darklimb_correct
;
;       PURPOSE: Calculate limb darkening function for specified wavelength
;                or wavelength range and use to remove limb darkening effects
;                from input image.
;
;       CALLING SEQUENCE:
;               darklimb_correct, imgin, imgout, lambda=lambda
;               darklimb_correct, imgin, imgout, lambda=lambda, limbxyr=[x,y,r]
;               darklimb_correct,imgin,imgout, lambda=lambda,bandpass=bandpass
;
;       INPUT:
;               imgin - img to be corrected 
;		lambda - wavelength of image in Angstroms
;
;       OUTPUT:
;		imgout - corrected image
;
;       OPTIONAL INPUT:
;               limbxyr  - limb centroid, 3 element array [x,y,r] 
;                          (if not passed,it will attempt to find it) 
;              	bandpass - input bandpass if image is integrated over a range
;   			   of wavelengths.  If this is set the program takes
;                          averages the limb darkening coefficients over a
;		 	   wavelength range: lambda +/- bandpass/2
;
;       OPTIONAL OUTPUT:
;               limbfilt - an image of the limb darkening function
;
;       NOTES and WARNINGS:
;		The limb darkening function uses a 5th order polynomial fitting
;		to the limb darkening constants obtained from Astrophysical 
;		Quantities.  
;
;		!!! THIS ONLY WORKS IN THE WAVELENGTH RANGE 4000<LAMBDA<15000 ANGSTROMS. !!!
;
;	ROUTINES CALLED:
;		DARKLIMB_U, DARKLIMB_V, DARKLIMB_R
;       HISTORY:
;              14-oct-96 - D. Alexander, Written w/SLF
;               5-feb-97 - S.L.Freeland - Changed names / SSW compatibility
;                                         Allow imgout via positional param
;                                         Missing Lambda protection
;                                        
;-
;       ---------------------------------------------------------------

if n_elements(lambda) eq 0 then begin
   message,/info,"You must supply wavelength via LAMBDA=NN keyword
   message,/info,"IDL> darklimb_correct, imagin, imgout, LAMBDA=LAMBDA
   return
endif

ll=1.*lambda         ; make sure lambda is floating point

; get constants for limb darkening function

if keyword_set(bandpass) then begin    ;average over wavelength range

  ul = darklimb_r(ll,bandpass,'darklimb_u')
  vl = darklimb_r(ll,bandpass,'darklimb_v')

endif else begin

   ul = darklimb_u(ll)
   vl = darklimb_v(ll)

endelse

; find limb and generate coordinates of sun centre and solar radius

if n_elements(limbxyr) eq 3 then begin
   x_center=limbxyr(0) 
   y_center=limbxyr(1)
   radius=limbxyr(2)
endif else begin
   trgt=target(imgin)
   x_center=trgt(0) & y_center=trgt(1) & radius=trgt(2)
endelse

; calculate distances to solar centre

isize=size(imgin)
isize=isize(1)

dist_circle,dist_grid,isize,x_center,y_center

dist_grid=dist_grid/radius
outside=where(dist_grid gt 1.)
dist_grid(outside)=0.                    ; zero all distances outside solar disk

; calculate limb darkening function

limbfilt = 1 - ul - vl + ul*cos(asin(dist_grid)) + vl*cos(asin(dist_grid))^2


;  correct imput image for limb darkening effects

imgout=imgin/limbfilt
if n_params() eq 2 then imgoutt=temporary(imgout)       ; out via positional

end

