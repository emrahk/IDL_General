;+
; Project     : HINODE/EIS
;
; Name        : WR_TILES
;
; Purpose     : Write image into specified number of subtiles
;
; Inputs      : IMAGE = 2-d byte image
;               NX, NY = # of tiles in X- and Y- directions
;
; Outputs     : Individual tile files 
;
; Keywords    : FORMAT = output image format [def = 'gif']
;               OUT_DIR = output directory [def = current]
;               STAMP = stamp for each tile filename [def = 'tile']
;               RED, GREEN, BLUE = image color table [def = currently loaded]
;
; Version     : Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-


pro wr_tiles,image,nx,ny,format=format,_extra=extra,$
               stamp=stamp,red=red,green=green,blue=blue,$
               out_dir=out_dir,verbose=verbose,zoom=zoom

;-- def to current directory

verbose=keyword_set(verbose)
if is_blank(out_dir) then out_dir=curdir()
if ~write_dir(out_dir) then begin
 message,'no write access to '+out_dir,/cont
 return
endif

sz=size(image)
if (sz[0] ne 2) or (size(image,/type) ne 1) then begin
 message,'input image must be 2-D byte array',/cont
 return
endif
n1=sz[1] & n2=sz[2]

if ~is_number(nx) then begin
 message,'enter # of tiles',/cont
 return 
endif

if ~is_number(ny) then ny=nx
nx = nint(nx) > 1
ny = nint(ny) > 1

if is_blank(stamp) then stamp='tile'
if is_blank(format) then format='png'
if is_blank(zoom) then dzoom='' else dzoom='-'+zoom
ns1=nint(n1/nx) & ns2=nint(n2/ny)
if verbose then begin
 message,'processing '+trim(nx)+'x'+trim(ny)+' tiles',/cont
endif

for j=0,ny-1 do begin
 for i=0,nx-1 do begin
  k=ny-j-1
  filename=stamp+dzoom+'-'+trim(i)+'-'+trim(k)+'.'+format
  istart=i*ns1 < (n1-1)
  iend=((i+1)*ns1-1) < (n1-1)
  jstart=j*ns2 < (n2-1)
  jend=((j+1)*ns2-1) < (n2-1)
  out_file=concat_dir(out_dir,filename)
;  if keyword_set(verbose) then message,'writing '+out_file,/cont
  write_image,out_file,format,image[istart:iend,jstart:jend],$
              red,green,blue,quality=100,_extra=extra
 endfor
endfor
  
return & end
