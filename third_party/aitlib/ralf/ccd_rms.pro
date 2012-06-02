PRO CCD_RMS, IN=in, OUT=out, REF=ref, VAR=var, N_SIGMA=n_sigma
;
;+
; NAME:
;	CCD_RMS	
;
; PURPOSE:   
;	Statistical analysis of flux data from
;	photometrical time series.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_RMS, [ IN=in, OUT=out , REF=ref, VAR=var, N_SIGMA=n_sigma ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;       NONE.
;
; KEYWORDS:
;       IN      : Name of IDL save file with flux and area data
;                 defaulted to interactive loading of '*.FLX'.
;       OUT     : Name of IDL save file with statistical data
;                 defaulted to '*.RMS'.
;	REF     : Number of flux reference source in data array
;	          fluxs from CCD_PRED, if missing, read interactively.
;	VAR     : Number of variable source in data array
;                 fluxs from CCD_PRED, if missing, read interactively.
;	N_SIGMA : Use only flux measurements within mean+-SIGMA_N*sigma
;		  to calculate statistic, to exclude bad data.
;		  Deafultet to 5.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	IDL Save file '*.RMS' containing statistical data.
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
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(in) then $
in=pickfile(title='Flux Data File',$
              file='ccd.flx',filter='*.flx')

message,'Input flux data            : '+in,/inf

if not EXIST(out) then out=CCD_APP(in,ext='rms')
message,'Output file with statistics : '+out,/inf

if not EXIST(n_sigma) then n_sigma=5

RESTORE,in,/verbose

si=size(fluxs)
source_n=si(1)
file_n=si(2)
rad_n=si(3)
flux=dblarr(source_n,file_n,rad_n)
f=dblarr(source_n,file_n,rad_n)

message,'Select flux reference source',/inf
CCD_WSEL,sname,indsel
ref=indsel(0)

for k=0,source_n-1 do begin
   for i=0,file_n-1 do begin
      for r=0,rad_n-1 do $
      if ((fluxb(k,i) ne 0.0) and (fluxs(k,i,r) ne 0.0)) then $
      flux(k,i,r)=fluxs(k,i,r)-areas(k,i,r)/areab(k,i)*fluxb(k,i)
   endfor
endfor

for k=0,source_n-1 do begin
   for i=0,file_n-1 do begin
      for r=0,rad_n-1 do $
      if flux(ref,i,r) ne 0.0 then $
      f(k,i,r)=flux(k,i,r)/flux(ref,i,r) else $
      f(k,i,r)=0.0d0
   endfor
endfor

meanf=dblarr(source_n,rad_n)
rms=dblarr(source_n,rad_n)

for k=0,source_n-1 do begin
   for r=0,rad_n-1 do begin
      ind=where(f(k,*,r) gt 0.0,count)
      if n_elements(ind) gt 2 then begin
         vec=dblarr(n_elements(ind))
         vec(*)=f(k,ind(*),r)
	 CCD_BSIGMA,vec,sum,num,sigma,n_sigma=n_sigma,/silent
         if num ne 0.0 then begin
            meanf(k,r)=sum/num
            rms(k,r)=sigma/sqrt(num)
         endif
      endif
   endfor
endfor

SAVE,/xdr,rad,f,meanf,rms,ref,sname, $
     time,flag,files,shift,filename=out,/verbose


RETURN
END
