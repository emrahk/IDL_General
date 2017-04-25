;+
; Project     : HINODE/EIS
;
; Name        : DO_TILES
;
; Purpose     : Write image into tiles into directories 
;
; Inputs      : FILES = images files to tile
;               TOP_DIR = top directory under which tiles are stored
;               A sub-directory named YYYYMMDD is created under TOP_DIR for each file
;               based on date encoded in filename.
;               A sub-directory named tiles-filename is created under YYYYMMDD
;               to store individual tiles.
;
; Outputs     : Individual tile files
;
; Keywords    : See FILE2TILES
;
; Version     : Written 20-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
 
pro do_tiles,files,top_dir,_extra=extra

if is_blank(files) or is_blank(top_dir) then begin
 pr_syntax,'do_tiles,files,top_dir'
 return
endif

if ~file_test(top_dir,/dir,/write) then begin
 message,'non-existent or non-writeable directory - '+top_dir,/cont
 return
endif

prefix='tiles-'
nfiles=n_elements(files)
for i=0,nfiles-1 do begin
 file=files[i]
 ymd=(stregex(file,'_?([0-9]{6,8})_?',/extra,/sub))[1]
 file_dir=concat_dir(top_dir,ymd)
 mk_dir,file_dir
 tile_dir=concat_dir(file_dir,prefix+file_break(file,/no_ext))
 mk_dir,tile_dir
 file2tiles,file,out_dir=tile_dir,_extra=extra
endfor

return & end
