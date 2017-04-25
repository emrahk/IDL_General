function mkthumb, data, r, g, b, 				$
   labels=labels, charsize=charsize, align=align,		$
   outsize=outsize, factor=factor, ns=ns, nx=nx, ny=ny, 	$
   ss=ss, outfile=outfile, ingif=ingif, 			$
   film=film, nofilm=nofilm, frame=frame,			$
   time=time, vertical=vertical, labstyle=labstyle, maxxy=maxxy
;+
;   Name: mkthumb
;   
;   Purpose: make a thumbnail of an image or movie sequence
;
;   Input Parameters:
;      data - full size 2D or 3D image array (may use GIF files instead)
;
;   Keyword Parameters:
;      ingif   - optionally use GIF files for input (instead of DATA)
;      outsize - if set, thumbnail output size (nx or [nx,ny])
;      factor  - thumbnail scale, as a percentage or fraction of input size
;      labels  - if set, image lables (like times information, etc)
;      nx,ny   - if set, thumbnail output size (in lieu of OUTSIZE or FACTOR)
;      maxxy   - if set, apply this to largest nx/ny dimension
;                (used to limit output size for extremely rectangular input)
;      r,g,b   - optional color table (only used if outfile specified)
;      vertical - if set, stack movies and lables in vertical icon
;
;   History:
;      25-oct-1995 - S.L.Freeland - for mpeg/WWW movie icons
;       6-nov-1995 (SLF) - keywords, add gif file option
;       1-may-1996 (SLF) - bug fix (1 image case)
;      20-nov-1997 (SLF) - if only nx supplied, scale ny properly
;                          (correct aspect ratio for non-square sequences)  
;      17-nov-1999 (SLF) - add LABSTYLE (execute string -> align_label.pro)
;      8-Sep-2005, Zarro (L-3Com/GSFC) - add SSW_WRITE_GIF
;     11-oct-2006 (SLF) - add MAXXY keyword & function
;-
if n_elements(charsize) eq 0 then charsize=1.
vertical=keyword_set(vertical)				; orientation

;  ------------- GIF file input -----------------
if keyword_set(ingif) then begin
   if n_elements(ss) eq 0 then ss=lindgen(n_elements(ingif))
   ns=n_elements(ss)
   if n_elements(r) gt 0 and n_elements(b) gt 0 then begin
      message,/info,"RGB supplied"  
      read_gif,ingif(ss(0)),image 
   endif else read_gif,ingif(ss(0)),image, r,g,b 
   simage=size(image)
   data=bytarr(simage(1),simage(2),ns)
   for i=0,n_elements(ss)-1 do begin
         read_gif,ingif(ss(i)),img
      data(0,0,i)=img
   endfor
   ss=lindgen(ns)
endif
; -------------------------------------------------------

; get some data parameters 
sdata=size(data)
tdata=data_chk(data,/type)
ddata=data_chk(data,/ndimen)

dx=data_chk(data,/nx)
dy=data_chk(data,/ny)
if keyword_set(maxxy) then begin 
   delvarx,nx,ny,outsize,factor   ; override all of these
   if dy gt dx then ny=maxxy else nx=maxxy
endif

; -------------------------------------------------------
case 1 of
   n_elements(ingif) ne 0: 
   tdata eq 0 or tdata eq 7 or tdata eq 8 or (ddata lt 2 or ddata gt 3): begin
      message,/info,"input data must be 2D or 3D matrix"
      return,data
   endcase
   ddata eq 3: nimg=sdata(ddata)
   ddata eq 2: nimg=1
   else:
endcase
if n_elements(ss) eq 0 then ss=lindgen(nimg)
if n_elements(ns) eq 0 then ns=n_elements(ss)
nimg=ns
movie=nimg gt 1
; --------------------------------------------------------------------

; ---- determine thumbnail size (via OUTSIZE, FACTOR, NX/NY or defaults) ---
nout=n_elements(outsize)
if nout gt 0 then begin
   nx=outsize(0)
   if nout gt 1 then ny=outsize(1)
endif

if keyword_set(factor) then begin
   if factor gt 1 then fact=float(factor)/100. else fact=factor
   nx=fact*sdata(1)
   ny=fact*sdata(2)
endif

; assign defaults
if not keyword_set(nx) then nx=64
if not keyword_set(ny) then ny= round( (float(nx)/sdata(1))*sdata(2))
; --------------------------------------------------------------------

; ---------------- make thumbnail array -------------------------
out=bytarr(nx,ny,ns)
for i=0,ns-1 do out(0,0,i)=congrid(data(*,*,ss(i)),nx,ny)

; write thumbnail to Z-buffer
dtemp=!d.name

; allow labels
if n_elements(labels) eq 0 then labs=strarr(ns) else begin
   labs = labels
   if n_elements(labs) ne ns then begin
      message,/info, "Warning: Number of labels must match number of images..."
      labs=strarr(ns)
   endif
endelse

size= ((nx/8)*.05) + ([.35,.5])(strupcase(!d.name) eq 'X')


if data_chk(labstyle,/string) then begin
   template=rotate(out(*,*,0),vertical)
   wdef,xx,/zbuffer, im=template
   thumb=make_array(nx*ns,ny,/byte)
   for i=0,ns-1 do begin 
      tv,out(*,*,i)
      estring='align_label,labs(i),size=size,' + labstyle(0)
      estat=execute(estring)
      thumb(i*nx,0)=tvrd()
    endfor
endif else begin 
   wdef,xx,/zbuffer, nx*ns, ny
   for i=0,ns-1 do begin
      tv,rotate(out(*,*,i),vertical),i
      xyouts,([(i*nx)+5,(i*nx)+nx-5])(vertical),5,labs(i),size=charsize,$
        /device,orient=([0,90])(vertical)
   endfor
   thumb=tvrd()
endelse

; --------------------------------------------------------------------

; if movie sequence, then add FILM borders for icon

if movie and not keyword_set(nofilm) then $
   thumb=film_thumbnail(thumb, frame=([0,nx])(keyword_set(frame)) )

set_plot,dtemp				; restore device

; --------- optionally store thumbnail as a GIF file ------------
if keyword_set(outfile) then begin
   if data_chk(outfile,/string) then tname=outfile else tname='thumbnail.gif'
   message,/info,"Writing thumbnail to file: " + tname
   ssw_write_gif,tname,thumb,r,g,b
endif
; --------------------------------------------------------------------
return,rotate(thumb,([0,3])(vertical))
end
