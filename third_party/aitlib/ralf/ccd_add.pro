PRO CCD_ADD, PCAT=pcat, OUT=out
;
;+
; NAME:
;	CCD_ADD
;	
; PURPOSE:   
;	Add frames from position catalog PCAT to obtain a summed image.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_ADD, [ PCAT=pcat, Out=out ]
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
;	PCAT : Catalog of reference postions of a pos. ref. star,
;	       defaulted to interactive loading of '*.POS'.
;	OUT  : Name of IDL save file with summed image data,
;	       defaultet to '*.ADD'
;
; OUTPUTS:
;	IDL save '*.ADD' containing summed image.
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

if not EXIST(pcat) then $
pcat=pickfile(title='Position Reference Catalog',$
              file='ccd.pos',filter='*.pos')

message,'Reference position catalog : '+pcat,/inf

if not EXIST(out) then out=CCD_APP(pcat,ext='add')
message,'Save file with added image : '+out,/inf

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

CCD_IMRD,image,file=files(0)

nxy=intarr(2)
si=size(image)
nxy(0:1)=si(1:2)

add=dblarr(2*nxy(0),2*nxy(1))
dev=dblarr(2*nxy(0),2*nxy(1))
anxy=intarr(2)
si=size(add)
anxy(0:1)=si(1:2)

fadd=dblarr(2*nxy(0),2*nxy(1))
flat=dblarr(nxy(0),nxy(1))
flat(*,*)=1.0d0

temp=dblarr(2*nxy(0),2*nxy(1))
ftemp=dblarr(2*nxy(0),2*nxy(1))

x0=long(0.5*nxy(0))
y0=long(0.5*nxy(1))

CCD_CNTRD,image,rx(0),ry(0),rxcen,rycen,fwhm
if rxcen eq -1 then message,'Position reference not found'


for i=0,file_n-1 do begin
   message,'Adding file : '+strtrim(string(i),2),/inf
   CCD_IMRD,image,file=files(i)
   CCD_CNTRD,image,rx(i),ry(i),xcen,ycen,fwhm
   
   if rxcen eq -1 then goto,NFILE

   SKY,image,skymode,skysig,/silent
   image=image-skymode

   xstart=long(x0-xcen+rxcen)
   ystart=long(y0-ycen+rycen)
   xend=xstart+nxy(0)
   yend=ystart+nxy(1)
 
   if ((xstart ge 0) and (ystart ge 0) and $
       (xend le anxy(0)) and (yend le anxy(1))) then begin
      temp(*,*)=0.0d0
      temp(xstart,ystart)=image
      ftemp(*,*)=0.0d0
      ftemp(xstart,ystart)=flat

      add=add+temp
      fadd=fadd+ftemp
   endif

NFILE:
endfor

SAVE,/xdr,add,fadd,filename=out,/verbose

RETURN
END
