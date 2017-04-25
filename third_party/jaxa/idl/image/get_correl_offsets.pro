;+
;   Name: get_correl_offsets
;
;   Purpose: calculate rigid displacement via cross-correlation 
;
;   Input Paramters:
;      data - image cube 
;
;   Keyword Parameters:
;      reference - image number of reference image (default is 1st = 0 )
;
;   History:
;      15-October-1998 - S.L.Freeland - Directly 'tr_get_disp' by Ted Tarbell
;                        (using algorithm derived from B.Lin)
;      Review/Distillation of SSW cross correlation techniques
;      [One of several cross correl methods under SSW  - others include 
;               'get_off.pro  G.L.Slater  
;               'korrel.pro   J.P.Wuelser
;               'cross_correl T. Berger 
;
;   Restrictions:
;      Under review during review of 'best' cross corr methods
;      Need to add CORR_FOV (permit user specified subfields)
;
;   Category:
;      2D , 3D, Image, Alignment , Cross Correlation, Cube
;   
;-

;  is_in_range		true where x is inside the interval [lo,hi]
;
function is_in_range, x, lo, hi
   return, (x ge lo) and (x le hi)
   end

;  hanning		alternative (flatter than one in ~idl/lib)
;			Hanning function.  This one always square.
;
;From H. Lin's file ccdcal5.pro, 29-Jan-98
function hanning, n, m

k = min([n,m])
x = fltarr (k) + 1.0
tenth =  long (k*.2)
cons = !pi/tenth
for i = 0,tenth do begin
   x(i) = (1.0 - cos (i*cons))/2.0
   x(k-i-1) = x(i)
endfor

return, x # x
end

function get_correl_offsets, data, mad=mad, $
       reference=reference, corr_fov=corr_fov

;  tr_get_disp	get the image displacements
;
;  Method: Correlation tracks the image sequence using a power-of-2
;  square area centered on the image(s).  First image of sequence
;  is the reference.  Returns array of pixel displacements of images
;  with respect to reference first image.
;  The sense is that data(i,j,0) <==> data(i-disp(0,k),j-disp(1,k),k)
;  Changed by TDT to return fractional pixel offsets,
;   added MAD algorithm  29-Jan-98
;   added shift keyword, 1-Jul-98:  if set, shifts all images to match img(*,*,0)
;   variable MAD search area (def = 5x5), fixed bug in subarea size, 11-Sep-98

if n_elements(reference) eq 0 then reference=0
if not keyword_set(mad) then mad=0
nmad = mad > 5
nmad = 2*(nmad/2)+1
nmad2 = (nmad-1)/2
debug=keyword_set(debug)

errorstring = 'Minimum MAD not in '+string(nmad,format='(I2)')+'^2 area--image #, xmin, ymin:'

nx=data_chk(data,/nx)
ny=data_chk(data,/ny)
nz=data_chk(data,/nimage)
disp = fltarr (2,nz)

; TDT  11-Sep-98  added + 1.e-5 to make this work right!
nn = 2^long (alog10 (min ([nx, ny]))/.30103 + 1.e-5)

; TDT 29-Jan-98  added float to this next statement
nnsqd = float(nn)^2
appodize = hanning (nn, nn)
ref = data ((nx-nn)/2:(nx+nn)/2-1, (ny-nn)/2:(ny+nn)/2-1, reference)
tref = conj (fft ((ref-total(ref)/nnsqd)*appodize, -1))

for i = 0, nz-1 do begin
   scene = data ((nx-nn)/2:(nx+nn)/2-1,(ny-nn)/2:(ny+nn)/2-1, i)
   tscene = fft ((scene-total(scene)/nnsqd)*appodize, -1)
   cc = shift (abs (fft (tref*tscene, 1)), nn/2, nn/2)
   printerror = 1

   mx = max (cc, loc)		; locate peak of Cross Correlation
   xmax0 = loc mod nn
   ymax0 = loc/nn
   xmax = ( (xmax0 > nmad2) < (nn-nmad2-1) )
   ymax = ( (ymax0 > nmad2) < (nn-nmad2-1) )
   if debug then begin 
   	print,'Fourier Cross-correlation Peak: ',xmax0,ymax0
	print,cc(xmax-2:xmax+2,ymax-2:ymax+2), format='(5F8.1)'
   endif
   cc = -cc(xmax-nmad2:xmax+nmad2,ymax-nmad2:ymax+nmad2)
   
;   if (is_in_range (xmax,5,nn-6) and is_in_range(ymax,5,nn-6) and (mad ne 0)) then begin
   if (mad) then begin

; Mean Absolute Difference algorithm centered on xmax & ymax

	cc = fltarr(nmad,nmad)
	dx = nn/2-xmax
	dy = nn/2-ymax
	nnx2 = (nn/2-abs(dx)-nmad2-1)/2
	nxl = nn/2-nnx2
	nxh = nn/2+nnx2
	nny2 = (nn/2-abs(dy)-nmad2-1)/2
	nyl = nn/2-nny2
	nyh = nn/2+nny2
	area = float(nxh-nxl+1)*float(nyh-nyl+1)

	for idx=-nmad2,nmad2 do begin
	for idy=-nmad2,nmad2 do begin
	cc(idx+nmad2,idy+nmad2)=total(appodize(nxl:nxh,nyl:nyh)*abs(ref(nxl:nxh,nyl:nyh) - $
	  scene(nxl-dx+idx:nxh-dx+idx,nyl-dy+idy:nyh-dy+idy)))/area
	endfor
	endfor
	cc = cc^2
	if debug then begin
	  print,'Squared MAD array:'
	  print,cc, format='('+string(nmad,format='(i2)')+'F8.1)'
	endif

     endif
; Locate minimum of MAD^2 or -Cross-correlation function
;   hope nmad x nmad is big enough to include minimum
	mx = min (cc, loc)		
	xmax7 = loc mod nmad
	ymax7 = loc/nmad
; 3 point parabolic fit, following Niblack, W.: Digital Image Processing,
; Prentice/Hall, 1986, p 139. 
; Need better 2-D peak interpolation routine here!
	if (xmax7 gt 0 and xmax7 lt (nmad-1) ) then begin
	  denom = mx*2 - cc(loc-1) - cc(loc+1)
	  xfra = (mx-cc(loc-1))/denom
	endif else begin 
	  xfra = 0
	  if (printerror) then print,errorstring,i,xmax7-nmad2,ymax7-nmad2
	  printerror=0
	endelse
	if (ymax7 gt 0 and ymax7 lt (nmad-1) ) then begin
	  denom = mx*2 - cc(loc-nmad) - cc(loc+nmad)
	  yfra = (mx-cc(loc-nmad))/denom
	endif else begin 
	  yfra = 0
	  if (printerror) then print,errorstring,i,xmax7-nmad2,ymax7-nmad2
	  printerror=0
	endelse

	xfra = xfra + xmax7 - nmad2-0.5
	yfra = yfra + ymax7 - nmad2-0.5
	if debug then print,xfra,yfra,format='("Fractional dx, dy: ",2F10.3)'
	xmax = xfra + xmax 
	ymax = yfra + ymax 

;      endif

   disp(0,i) = (nn/2-xmax)
   disp(1,i) = (nn/2-ymax)
   
   if debug then print, i, disp(0,i), disp(1,i), $
     format='("Image ",I4, "    Final offsets ",2F10.2,/)'
   endfor
   
return, disp
end

