;+
; Project     :	Solar-B
;
; Name        :	FITS2TIFF
;
; Purpose     :	convert FITS file to TIFF file
;
; Explanation :	Reads a FITS file, byte scales it, and
;               then writes it to TIFF file
;
; Use         :	FITS2TIFF,INFILE,OUTFILE
;
; Inputs      :	IFILE = input FITS file name
;               OFILE = output TIFF file name 
;                       [def = same as IFILE with .tiff extension]
;               OUTSIZE = rescale to size [dim1,dim2]
;               COLORS = load color table
;               LOG    = log scale image
;               NOCLOBBER = do not clobber existing files
;
; Written     :	2-May-2006, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro fits2tiff,ifile,ofile,_extra=extra,colors=colors,err=err,outsize=outsize,$
               noclobber=noclobber

err=''
fits_file=loc_file(ifile,/verb,err=err)
if is_string(err) then return

;-- construct output TIFF file name and check it we can write it

if is_string(ofile) then tiff_file=ofile else tiff_file=fits_file
basename=file_break(tiff_file,/no_ext,path=path)
if is_string(path) then outdir=path else outdir=curdir()
if not write_dir(outdir,/verb,err=err) then return

tiff_file=concat_dir(path,basename+'.tiff')
if keyword_set(noclobber) then begin
 chk=loc_file(tiff_file,count=count)
 if count gt 0 then return
endif

;-- read the fits file

fits=obj_new('fits')
fits->read,fits_file,err=err
if is_string(err) then return
data=fits->get(/data,/no_copy)
obj_destroy,fits

;-- bytescale the data

data=cscale(data,_extra=extra,/no_copy)

;-- resize the data

sz=size(data)
if n_elements(outsize) eq 2 then begin
 sz=size(data)
 if (sz[1] ne outsize[0]) or (sz[2] ne outsize[1]) then begin
  data=congrid(data,outsize[0],outsize[1],_extra=extra)
 endif
endif

;-- colorize it

if is_number(colors) then begin
 loadct,colors
 tvlct,r,g,b,/get
endif

write_image,tiff_file,'tiff',reverse(data,2),r,g,b,_extra=extra

return & end

