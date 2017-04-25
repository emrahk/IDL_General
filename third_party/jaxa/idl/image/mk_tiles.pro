;+
; Project     : HINODE/EIS
;
; Name        : MK_TILES
;
; Purpose     : Make zoom tiles for image
;
; Inputs      : IMAGE = 2-d byte image
;               TSIZE = tile size [def=256]
;
; Outputs     : Individual tile files
;
; Keywords    : See WR_TILES
;
; Version     : Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mk_tiles,image,tsize,_extra=extra

;-- check inputs

sz=size(image)
if (sz[0] ne 2) or (size(image,/type) ne 1) then begin
 message,'input image must be 2-D byte array',/cont
 return
endif

n1=sz[1] & n2=sz[2]
if (n1 ne n2) then begin
 message,'input image must be square',/cont
 return
endif

nsize=exponent(n1,2)
if nsize eq 0 then begin
 message,'input image size must be a power of 2',/cont
 return
endif

;-- check tiling

if is_number(tsize) then tsize=fix(tsize) else tsize=256
if (tsize gt n1) then begin
 message,'tile size must be less than image size',/cont
 return
endif

if exponent(tsize,2) lt 1 then begin
 message,'tile size must be a power of 2',/cont
 return
endif

;-- start tiling

i=0l & i2=1
nsize=tsize
repeat begin
 i=i+1l
 tile=rebin(image,nsize,nsize)
 zoom=trim(i-1)
 wr_tiles,tile,i2,_extra=extra,zoom=zoom
 nsize=nsize*2l
 i2=2^i
endrep until (nsize gt n1)

return & end
