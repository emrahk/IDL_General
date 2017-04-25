pro mwritefits, iindex, data, $
    outfile=outfile, outdir=outdir, $
    NaNvalue=NaNvalue, $
    flat_fits=flat_fits, fitstype=fitstype,   $
    append=append, nocomment=nocomment, loud=loud,  quiet=quiet, $
    prefix=prefix, extension=extension, incsize=incsize, $
    comments=comments, fcomments=fcomments, history=history, temp=temp
    
;+
;   Name: mwritefits
;
;   Purpose: index/data to specified type of FITS file 
;
;   Input Parameters:
;      index - index structures 
;      data  - corresponding 2d/3d data array
;  
;   Keyword Parameters:
;      NaNvalue - passed through to writefits
;      outfile - if supplied, use this/these file names (including outdir/path)
;                if not supplied, files are auto-named based on DATE_OBS
;      outdir  - if supplied, direct files to this directory (names derived)
;      prefix  - if supplied, 'PREFIX' prepended to autonamed files (def='mwf')
;      extension - if supplied, appended to auto-named files (def='.fits')
;      fitstype - type of file; 0=>mxf (trace-like) 1=>2D FITS (1/image)
;      nocomment - switch, if set, dont add comment from this routine
;      flat_fits - switch, if set, fitstype=1 (2D FITS, 1/image)
;  
;   History:
;      24-Jun-1998 - S.L.Freeland - from write_trace
;      19-Nov-1998 - S.L.Freeland - include SECONDs in auto named files
;                                   (via time2file(/sec)
;                                   strip nested structure tags 
;  
;   Calling Sequence:
;      mwritefits, index, data           ; 1 image per index/data pair  

;      mwritefits, index, data [,outfile=outfile, outdir=outdir,  $
;                                prefix=prefix, extension=extension]
;   Calls:
;      data_chk, time2file, fxhmake, struct2fitshead, writefits, 
;      box_message, required_tags, str_taginfo
;
;   TODO:
;      allow non-flats output (mxf (tracelike) and 3D standard)
;-

version='1.0'
pcomment='Written by mwritefits, Version:' + version + '  ' + systime()
nocomment=keyword_set(nocomment)

case 1 of
  nocomment:
  data_chk(fcomments,/string):fcomments=[fcomments,pcomment]
  else: fcomments=pcomment
endcase

; ----------------------------------------------
index=iindex

loud=keyword_set(loud)
named=data_chk(outfile,/string)
nooutdir=1-data_chk(outdir,/string)
nind=n_elements(index)                                 ; number of struct
nimg=data_chk(data,/nimages)                           ; number of images
if n_elements(fitstype) eq 0 then fitstype=1           ; default = 2D 

case 1 of
   named:                                             ; fully specified
   data_chk(outdir,/string): outdir=outdir(0)
   nooutdir: outdir=curdir()
   else: box_message,'I thought it would never get here???'
endcase

if not data_chk(outdir,/string) then outdir=curdir()

if not file_exist(outdir) then begin
  box_message,['Requested output directory',outdir(0), 'does not exist'],/center
  return
end  

flat=keyword_set(flat_fits) or fitstype(0) eq 1 

suggested='naxis1, naxis2, crpix1, crval1, cdelt1, date_obs'
if not required_tags(index,suggested,missing=missing) and loud then $
   box_message,'Suggested tags: ' + arr2str(missing) +' are missing from input structures...'

tnames=tag_names(index)
tagstructs=where(str_taginfo(iindex,/type) eq 8,scnt)

if scnt gt 0 then begin
   box_message,['Stripping nested structures from index: ', tnames(tagstructs)]
   index=str_subset(index,tnames(tagstructs),/exclude)
endif  

case fitstype of
   1: begin
   if not data_chk(prefix,/string) then prefix='mwf'
   if not data_chk(extension,/string) then extension=(['.fits','.fts'])(keyword_set(soho))
   if 1-named then outfile=concat_dir(outdir, prefix + time2file(index,/sec) +  extension)
   if (nind ne  nimg) or  (nind ne n_elements(outfile)) then $
       box_message,'Mismatch between index, data, and outnames' else begin
;     ------------------------------------------------------------
      for i=0,nind-1 do begin
         img=data(0:index(i).naxis1-1, 0:index(i).naxis2-1,i)  ; handle subarr
;          --------- standard FLAT FITS -------------------
	   newhead=struct2fitshead(index(i), comments=comments)
           fxhmake,newhead,img                                     ; clean, add data info
           writefits, outfile(i), img, newhead,NaNvalue=NaNvalue    ; write FITS 2D
;          --------------------------------------------------
          if loud then box_message,'Wrote>> ' + outfile(i)
      endfor	
   endelse
   endcase
   else: box_message,'sorry, only 2D (flat) FITS for now'
endcase

return
end
