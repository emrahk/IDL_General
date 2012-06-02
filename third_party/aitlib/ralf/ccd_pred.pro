PRO CCD_PRED, PCAT=pcat, MASK=mask, OUT=out, SUB=sub, $
              N_SIGMA=n_sigma, SEARCH=search, SHIFT=shift
;
;+
; NAME:
;	CCD_PRED
;	
; PURPOSE:   
;	Automatical reduction of CCD frames to extract photometrical
;	time series. Needs aperture masks stored in '*.APS' IDL save
;	and a catalog of refrence star positions '*.POS', created by
;	programs of the %CCD% package.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_PRED, [ PCAT=pcat, MASK=mask, SUB=sub, Out=out, $
;		    N_SIGMA=n_sigma, SEARCH=search, SHIFT=shift ]
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
;	PCAT    : Catalog of reference postions of a pos. ref. star,
;	          defaulted to interactive selection of '*.POS' file.
;       MASK    : IDL save with data on aperture masks,
;	          defaulted to interactive selecting '*.APS'.
;	OUT     : Name of IDL save file with flux and area data
;                 defaulted to '*.FLX'.
;	SUB     : Number of subpixels = sub^2 for dividing original pixel,
;	          defaulted to 5.
;       N_SIGMA : Cut value for sigma filtering of background
;                 aperture, see CCD_BFILT.
;       SEARCH  : If search at x,y fails, use area with rectangle side
;                 length 2*SEARCH [pixel] around x,y for further trials.
;	SHIFT   : Apply SHIFT [h] from time in image header to UT.
;		  MEZ : Shift=-1, MESZ : Shift=-2.
;
; OUTPUTS:
;	IDL save '*.FLX' containing fluxes and areas in masks.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(shift) then $
message,'Time shift [h] image header to UT missing'

if not EXIST(pcat) then $
pcat=pickfile(title='Position Reference Catalog',$
              file='ccd.pos',filter='*.pos')

message,'Reference position catalog     : '+pcat,/inf

if not EXIST(mask) then $
mask=pickfile(title='Aperture Mask File',$
              file='ccd.aps',filter='*.aps')

message,'Mask file with apertures : '+mask,/inf

if not EXIST(out) then out=CCD_APP(pcat,ext='flx')
message,'Output data file         : '+out,/inf

if not EXIST(sub) then sub=5

if not EXIST(n_sigma) then n_sigma=3

if not EXIST(fwhm) then read,'% CCD_PRED: FWHM of sources [pixel] : ',fwhm

if not EXIST(search) then search=fwhm

CCD_RASC,pcat,data

file_n=n_elements(data)
rx=dblarr(file_n)
ry=dblarr(file_n)
files=strarr(file_n)

for i=0,file_n-1 do begin
   b=str_sep(strtrim(strcompress(data(i)),2),' ')
   files(i)=b(0)
   rx(i)=double(b(1))
   ry(i)=double(b(2))
endfor

message,'Image catalog entries : '+strtrim(string(file_n),2),/inf

RESTORE,mask,/verbose

read,'% CCD_PRED: Number aperture radii for sources : ',rad_n
rad=dblarr(rad_n)
read,'% CCD_PRED: Minimum radius [pixel] : ',minrad
read,'% CCD_PRED: Maximum radius [pixel] : ',maxrad
rad=double(minrad)+dindgen(rad_n)/double(rad_n)*(double(maxrad)-double(minrad))

source_n=n_elements(sx)
back_n=n_elements(bx(0,*))

sx_shift=dblarr(source_n)	;coordinates in actual frame
sy_shift=dblarr(source_n)
bx_shift=dblarr(source_n,back_n)
by_shift=dblarr(source_n,back_n)

fluxs=dblarr(source_n,file_n,rad_n)	;flux inclusive background
fluxb=dblarr(source_n,file_n)		;background flux
areas=dblarr(source_n,file_n,rad_n)	;area including source
areab=dblarr(source_n,file_n)		;area of background
;flag=1 : Source out of frame
;flag=2 : Source not found with CCD_CNTRD algorithm
;flag=3 : Reference star not found
;flag=4 : Flux aperture partially out of frame
flag=intarr(source_n,file_n)
time=dblarr(file_n)
nxy=intarr(2)


for i=0,file_n-1 do begin
   message,'Processing file : '+files(i),/inf

   CCD_IMRD,image,file=files(i)

   si=size(image)
   nxy(0:1)=si(1:2)
   CCD_GJD,files(i),ti,shift=shift
   time(i)=ti

   CCD_CENT,image,x=rx(i),y=ry(i),rxcen,rycen,fwhm=fwhm,/silent,search=search

   if rxcen eq -1 then begin
      flag(*,i)=3
      goto,NFILE
   endif

   sx_shift=sx+rxcen	;expected coordinates in actual frame
   sy_shift=sy+rycen
   for b=0,back_n-1 do begin
      bx_shift(*,b)=bx(*,b)+sx_shift
      by_shift(*,b)=by(*,b)+sy_shift
   endfor

   for k=0,source_n-1 do begin


      ;(1) check, whether star is in frame, else next source

      if ((sx_shift(k) lt 0) or (sx_shift(k) gt nxy(0)-1) or $
          (sy_shift(k) lt 0) or (sy_shift(k) gt nxy(1)-1)) then begin $
         flag(k,i)=1
         goto,NSOURCE
      endif      


      ;(2) find source, get exakt coordinates from CCD_CNTRD,
      ;    if not available, use predicted source position and
      ;    set flag=2

      CCD_CNTRD,image,sx_shift(k),sy_shift(k),xcen,ycen,fwhm,/silent

      if xcen eq -1 then begin
         flag(k,i)=2

         ;use predicted source coordinates instead
         xcen=sx_shift(k)
         ycen=sy_shift(k)
      endif


      ;(3) determine flux in circular aperture centered at source

      for r=0,rad_n-1 do begin
         CCD_FLUX,image,rad(r),xcen,ycen,flux,area,sub=sub,/silent

         fluxs(k,i,r)=flux
         areas(k,i,r)=area
         if flux eq 0.0 then flag(k,i)=4
      endfor


      ;(4) determine flux in background apertures

      for b=0,back_n-1 do begin
         CCD_FLUX,image,qside,bx_shift(k,b),by_shift(k,b),flux,area,$
                  /quad,n_sigma=n_sigma,sub=sub,/silent

         fluxb(k,i)=fluxb(k,i)+flux
         areab(k,i)=areab(k,i)+area
      endfor


   NSOURCE:
   endfor 


NFILE:
endfor 


SAVE,/xdr,fluxs,fluxb,areas,areab,rad,qside,flag,time,shift, $
     sname,prefname,files,filename=out,/verbose


RETURN
END
