PRO CCD_MCAT, IN=in, OUT=out, XMAX=xmax
;
;+
; NAME:
;	CCD_MCAT	
;
; PURPOSE:   
;	Create a catalog of positions of a reference star in a
;	series of frames by using cursor for identification.
;	Coordinates are only raw coordinates of cursor.
;
; CATEGORY:
;	Astronomical Photometry
;
; CALLING SEQUENCE:
;	CCD_MCAT, [ In=in, OUT=out, XMAX=xmax ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	IN   : Name of input frame catalog, defaulted to
;	       interactive loading of '*.CAT'.
;	OUT  : Name of output catalog of positions for refrence star,
;	       defaulted to '*.POS'.
;	FWHM : FWHM of star images [pixel], if not given, interactive input.
;	XMAX : Max. allowed x-size of window.
;
; OUTPUTS:
;	File (ascii) with positions (raw cursor coordinates)
;	of a reference star.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       Uses CCD_TV, deletes and opens new window device 0.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(in) then $
in=pickfile(title='Input Frame Catalog',$
              file='ccd.cat',filter='*.cat')

message,'Input frame catalog               : '+in,/inf

if not EXIST(out) then out=CCD_APP(in,ext='pos')
message,'Output position reference catalog : '+out,/inf

;read file names
CCD_RASC,in,files
num_f=n_elements(files)
pos=dblarr(2,num_f)
bad=intarr(num_f)

message,'SELECT IDENTICAL POSITION REFRENCE STAR IN ALL FRAMES',/inf
message,'Left mouse button   : Frame OK',/inf
message,'Middle mouse button : Exclude frame from reduction',/inf

for i=0,num_f-1 do begin

   CCD_IMRD,pic,file=files(i)
   CCD_TV,pic,xmax=xmax

   message,'Image : '+files(i),/inf

   cursor,xs,ys,/data  ;note:positions start with 0,0
   bad(i)=!err
   pos(0,i)=xs
   pos(1,i)=ys
   wait,1
endfor


;store results
fd=''
sd=''
read,'%CCD_MCAT: File id info line      : ',fd
read,'%CCD_MCAT: Reference star id info : ',sd

get_lun,unit
openw,unit,out
fd='%CCD_MCAT: Series ID        : '+fd
sd='%CCD_MCAT: Pos.ref.star ID  : '+sd
printf,unit,fd
printf,unit,sd
printf,unit,'%'
printf,unit,'%Lines beginning with % denote bad frames'
printf,unit,'%CCD_MCAT: Number of images : ',num_f
printf,unit,'%CCD_MCAT: Columns          : image id,x,y [pixel]'

for i=0,num_f-1 do begin
   if bad(i) gt 1 then add='%' else add=' '
   printf,unit,add+files(i)+' '+$
   strtrim(string(pos(0,i)),2)+' '+strtrim(string(pos(1,i)),2)
endfor

free_lun,unit


RETURN
END
