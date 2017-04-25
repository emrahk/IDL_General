function film_thumbnail, thumbnail, mag=mag, pad=pad, sample=sample, $
	frame_size=frame_size, nframes=nframes, fcolor=fcolor, $
	files=files
;+
;   Name: film_thumbnail
;
;   Purpose: embed thumbnail image in "film" (make www logos/thumbnails)
;
;   Input Parameters:
;      thumbnail - image to enclose in film
;   
;   Output:
;      function returns thumbnail embedded in "film" bitmap (always byte)
;
;   mag - if set, film "thickness" (default is auto scale)
;   pad - if set, increase the size of the surrounding pad (default auto scale)
;   sample - if set, rebin called with /sample (sharp edge film "holes")
;   frame_size - if set, draw frame borders (assume equal-width)
;   nframes - if set, draw frame borders (in lieu of frame_size, equal-width)
;   fcolor - if set, use this color for frame borders (default is bright)
;
;   Calling Sequence:
;      thumbnail_logo=film_thumbnail(thumbnail [,mag=mag, pad=pad, /sample, $
; 				frame_size=nn, nframes=nn, fcolor=cn])
;
;   History:
;      26-oct-1995 (S.L.Freeland) - SXT/YPOP/EIT (etc) WWW movie icons
;-

st=size(thumbnail)
sample=keyword_set(sample) or 1			; *** forced on ***

; ----------------- make a single frame bitmap -------------
fx=5
fy=5
frame=bytarr(fx,fy)
frame([0,3,4],*)=255b
frame(*,[0,4])=255b
frame=255-frame
; -----------------------------------------------------------

length=max([st(1),st(2)])			 ; assume edge=long direction
width=min([st(1),st(2)])
horiz=length eq st(1)				 ; boolean

; ------------- auto-scale the "holes" and pad ----------------
if not keyword_set(mag) then mag=(width/32) > 1
if not keyword_set(pad) then pad=(width/32) > 1

; ------------- auto-scale the "holes" and pad ----------------
bframe=rebin(frame,fx*mag,fy*mag, sample=sample) ; zoom it to useful size
nf=(length /(fx*mag))+1				 ; number of film holes > thumb

; ------------- make one film edge --------------------
strip=reform(rebin(bframe,fx*mag, fy*mag, nf,sample=sample), fx*mag, fy*mag*nf)

; --- truncate, rotate (if required), and make mirror image (other side) --
rstrip=rotate(strip(*,0:length-1),horiz)		
lstrip=rotate(rstrip,2)

; -------- surround with pad (embed thumnail in white or transparent) ----
if n_elements(pad) eq 0 then pad=1 	
exestr=(["zs=bytarr(pad,length)","zs=bytarr(length,pad)"])(horiz)
exestat=execute(exestr)
zs=zs+255				; make the pad white
; ------------------------------------------------------------------


tthumb=thumbnail			; dont clobber input

if keyword_set(frame_size) or keyword_set(nframes) then begin
   if keyword_set(frame_size) then nframes=length/frame_size else $
      frame_size=length/nframes
   farray=(lindgen(nframes+1)*frame_size+1) > 1 < (length-1)
   if n_elements(fcolor) eq 0 then fcolor=!p.color	; "white"
   if horiz then begin
       tthumb(farray,*)=fcolor 
       tthumb(*,[0,width-1])=fcolor
   endif else begin
      tthumb(*,farray)=fcolor
      tthumb([0,width-1],*)=fcolor
   endelse
endif

; ---------- concatenate pad, film edges and thumbnail ------------
exestr=(["fthumbnail= [zs,lstrip,tthumb,rstrip,zs]", $
         "fthumbnail=[[zs],[lstrip],[tthumb],[rstrip],[zs]]"])(horiz)
exestat=execute(exestr)
; ------------------------------------------------------------------
return, byte(fthumbnail)
end
