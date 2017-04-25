;+
; Project     : HINODE/EIS
;
; Name        : FILE2TILES
;
; Purpose     : Read and tile image files
;
; Inputs      : FILENAME = image filename
;
; Outputs     : Individual tile files
;
; Keywords    : see MK_TILES/WR_TILES
;
; Version     : Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro file2tiles,filename,_extra=extra,verbose=verbose

if is_blank(filename) then return

;-- supported format?

query=query_image(filename,type=type)
if ~query then begin
 message,'invalid image file',/cont
 return
endif

;-- start tiling

image=read_image(filename,r,g,b)
if keyword_set(verbose) then message,'tiling '+filename,/cont
mk_tiles,image,red=r,green=g,blue=b,$
   format=strlowcase(type),_extra=extra,verbose=verbose

return & end

