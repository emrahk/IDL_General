PRO CCD_ACAT, image, IN=in, OUT=out, FWHM=fwhm
;
;+
; NAME:
;	CCD_ACAT	
;
; PURPOSE:   
;	Create a catalog of positions of a reference star in a
;	series of frames by using correlation to determine the
;	shifts between consecutive frames. The star is identified
;	interactively on the first frame, then automatically
;	by DAOPHOT algorithm CNTRD using the frame shifts.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_ACAT, [ image, In=in, OUT=out, FWHM=fwhm ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	IMAGE : 2D image array, defaulted to first image in the
;		frame catalog.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	IN   : Name of input frame catalog, defaulted to
;	       interactive loading of '*.CAT'.
;	OUT  : Name of output catalog of positions for refrence star,
;	       defaulted to 'CCD.POS'.
;	FWHM : FWHM of star images [pixel], if not given,
;	       program asks for it.
;
; OUTPUTS:
;	File (ascii) with positions of a reference star.
;	If star is not identified, x=y=-1.
;	WARNING: Stars may be misidentified. Use CCD_CCAT to
;	         control and correct positions.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Uses CCD_TV, deletes and opens new window device 0.
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

;read frame file names from in
CCD_RASC,in,files
num_f=n_elements(files)
pos=dblarr(2,num_f)

if not EXIST(image) then CCD_IMRD,image,file=files(0) else begin $
si=size(image)
if si(0) ne 2 then message,'Image array must be 2 dimensional'
endelse

CCD_TV,image

if not EXIST(fwhm) then read,'% CCD_ACAT: FWHM [pixel] for sources : ',fwhm

message,'Select position reference source',/inf
repeat CCD_CENT,image,xref,yref,fwhm=fwhm until xref ne -1


for i=0,num_f-1 do begin
   message,'Image : '+files(i),/inf

   CCD_IMRD,ima,file=files(i)

   CORREL_OPTIMIZE,FILTER_IMAGE(image,/iterate,smooth=fwhm),$
                   FILTER_IMAGE(ima,/iterate,smooth=fwhm),$
                   xshift,yshift,/numpix

   CCD_CNTRD,ima,xref+xshift,yref+yshift,xcen,ycen,fwhm
   
   pos(0,i)=xcen
   pos(1,i)=ycen
   message,'Reference coordinates : '+ $
            strtrim(string(xcen),2)+' '+strtrim(string(ycen),2),/inf

   if xcen ne -1 then begin
      image=ima
      xref=xcen
      yref=ycen
   endif
endfor


;store results
fd=''
sd=''
read,'% CCD_ACAT: File ID info line      : ',fd
read,'% CCD_ACAT: Reference star ID line : ',sd

get_lun,unit
openw,unit,out
fd='% CCD_ACAT: Series ID       : '+fd
sd='% CCD_ACAT: Pos.ref.star ID : '+sd
printf,unit,fd
printf,unit,sd
printf,unit,'% CCD_ACAT: Number of images : ',num_f
printf,unit,'% CCD_ACAT: Columns          : image ID,x,y [pixel]'
for i=0,num_f-1 do printf,unit,files(i)+' '+$
strtrim(string(pos(0,i)),2)+' '+strtrim(string(pos(1,i)),2)
free_lun,unit


RETURN
END
