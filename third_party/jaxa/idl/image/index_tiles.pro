;+
; Project     : HINODE/EIS
;
; Name        : INDEX_TILES
;
; Purpose     : create dirlist.txt and filelist.txt index files
;
; Inputs      : TOP_DIR = top directory under which tiles are stored
;               TOP_DIR/dirlist.txt list all directories under TOP_DIR
;               TOP_DIR/YYYYMMDD/filelist.txt lists the original image
;               file names that were used to create each set of tiles
;               in each YYYYMMDD subdirectory
;
; Outputs     : index files
;
; Keywords    : FORMAT = orginal format of image files [def = 'png']
;
; Version     : Written 20-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
 
pro index_tiles,top_dir,format=format,verbose=verbose

if is_blank(format) then format='png'

if is_blank(top_dir) then begin
 pr_syntax,'index_tiles,top_dir'
 return
endif

if ~file_test(top_dir,/dir,/write) then begin
 message,'non-existent or non-writeable directory - '+top_dir,/cont
 return
endif

verbose=keyword_set(verbose)
dirs=file_search(top_dir+'/*',/test_dir)
tdirs=file_basename(dirs)
wrt_ascii,tdirs,concat_dir(top_dir,'dirlist.txt')
if is_blank(dirs) then return

ndirs=n_elements(dirs)
for i=0,ndirs-1 do begin
 if verbose then message,'indexing '+dirs[i],/cont
 tdirs=file_search(dirs[i]+'/*',/test_dir)
 tfiles=file_basename(tdirs)+'.'+format
 tfiles=str_replace(tfiles,'tiles-','')
 wrt_ascii,tfiles,concat_dir(dirs[i],'filelist.txt')
endfor

return & end
