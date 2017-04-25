pro data2files, data, r, g, b, _extra=_extra, gif=gif, jpeg=jpeg, tiff=tiff, $
   times=times, filenames=filenames, autoname=autoname, outdir=outdir
;  additional keywords - see zbuff2file via keyword inheritance

;+
;   Name: data2files
;
;   Purpose: convert data (2D or 3D) -> file or file sequence
;
;   Input Parameters:
;      data - 2D or 3D data
;      r,g,b - optional color table
;
;   Keyword Parameters:
;      filenames - optional output file names
;      times     - image times in any ssw format - used in place of filenames
;                  names will be: [PREFIX]yyyymmdd_hhmmss.[EXTENSION]
;      prefix    - if set and TIMES supplie, prepended to output file name
;                   [PREFIX]yyyymmdd_hhmmss.[EXTENSION]
;      autoname  - (switch) if set, just name files:
;                  d2f001.[EXTENSION], d2f002.[EXTENSION]...d2fnnn.[EXTENSION]
;
;      OTHERS - see zbuff2file for others, including ,/gif,/jpeg,/tiff,/quality
;
;   Calling Sequence:
;      IDL> data2files, data [,r,g,b] [,/gif] [/jpeg] [/tiff]
;
;   Method:
;      Call zbuff2file for each image in <data>. Uses keyword inheritance
;
;   History:
;      Circa 1-Jan-1996 - single front end for data -> common WWW formats
;      3-June-1998 - S.L.Freeland - made OUTDIR explicit
;      11-April-2000 - S.L.Freeland - endif->endcase (required by 5.3)
;
;   Restrictions:
;     You need to supply either FILNAMES or TIMES arrays
;     Temporary version (for simple data -> image2movie interface)
;     TODO - move rebinning, labeling, and rgb options to this routine
;            in addition to image2movie.
;-

ndimen=data_chk(data,/ndimen)

if ndimen lt 2 or ndimen gt 3 then begin
   message,/info,"Expect 2D or 3D input..., returning"
   return
endif

nimages=n_elements(data(0,0,*))
strnnn=strtrim(strlen(strtrim(nimages,2))+1,2)

; ------- determine output file names (user supplied or from image times )
case 1 of
   n_elements(times) eq nimages: begin
;     convert to standard "FID" (fileid)

;     ---------- add this logic to anytim? as  out_style='fid'? ---------
      strtimes=str_replace(anytim(times,out_style='ecs'),' ','_') ; blank ->"_"
      strtimes=str_replace(str_replace(strtimes,'/',' '),':',' ') ; delim ->" "
      filenames=$
          strmid(strcompress(strtimes,/remove),0,strlen('yyyymmdd_hhmmss'))
;     (unwanted -> " " allows strcompress,/remove to eliminate)
;     ------------------------------------------------------------------------
      if data_chk(prefix,/string) then filenames=concat_dir(prefix,filenames)
   endcase
   n_elements(filenames) eq nimages: filenames=filenames
   keyword_set(autoname): filenames='d2f' + $
       string(indgen(nimages),format="(i" + strnnn + "." + strnnn + ")")

   else: begin 
      box_message,'Autonaming - we suggest supplying FILENAMES or TIMES array'
      filenames='d2f' + $
      string(indgen(nimages),format="(i" + strnnn + "." + strnnn + ")")
   endcase
endcase

case 1 of 
   keyword_set(tiff):  filenames=str_replace(filenames,'.tiff','') + '.tiff'
   keyword_set(gif):  filenames=str_replace(filenames,'.gif','') + '.gif'
   keyword_set(jpeg): filenames=str_replace(filenames,'.jpg','') + '.jpg'
   else: filenames=str_replace(filenames,'.gif','') + '.gif'
endcase

if data_chk(outdir,/string) then begin
  break_file,filenames, ll, pp, fnames, fext, fver
  filenames=concat_dir(outdir,fnames+fext+fver)
endif

dtemp=!d.name
wdef,xx,/zbuffer,im=data(*,*,0)
set_plot,'Z'

if n_params() lt 4  then begin
   loadct,0
   tvlct, r, g, b,/get
endif 

for i=0,nimages-1 do begin
   tv,data(*,*,i)
   zbuff2file,filenames(i),r,g,b, _extra=_extra, outdir=outdir
endfor

set_plot,dtemp
return
return
end
