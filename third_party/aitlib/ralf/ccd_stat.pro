PRO CCD_STAT, IN=in, OUT=out, EXTR=extr
;
;+
; NAME:
;	CCD_STAT	
;
; PURPOSE:   
;	Multi-purpose interactive analysis of
;	statistical data from photometrical time series
;	to obtain statistical errors.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_STAT, [ IN=in, OUT=out, EXTR=extr ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;       NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;       IN   : Name of IDL save file with statistical data
;              defaulted to interactive loading of '*.RMS'.
;       OUT  : Name of IDL save file with radii analysis data
;              defaulted to '*.STT'.
;	EXTR : Extraction radius [pixel]. 
;	
; OUTPUTS:
;	IDL Save file '*.STT' containing statistical radii data.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       Plots a graph -  new window device 3 is created,
;       window device number is set to 3.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(in) then $
in=pickfile(title='RMS Data File',$
              file='ccd.rms',filter='*.rms')

message,'RMS data file : '+in,/inf

if not EXIST(out) then out=CCD_APP(in,ext='stt')
message,'Output file for analysis    : '+out,/inf

RESTORE,in,/verbose

if not EXIST(extr) then $
message,'Select extraction radius',/inf
CCD_WSEL,rad,index,title='Select Radius'
ind_extr=index(0)
extr=rad(ind_extr)


si=size(f)
source_n=si(1)
file_n=si(2)
rad_n=si(3)

;vectors of data for choosen extraction radius
mean_vec=dblarr(source_n)
rms_vec=dblarr(source_n)

mean_vec=meanf(*,ind_extr)
rms_vec=rms(*,ind_extr)


!xmin=0
!xmax=0
!ymin=0
!ymax=0

if not EXIST(nowin) then begin
   wdelete,3
   window,3
   wset,3
endif else wset,3
CLEANPLOT


;ind=index of stars excluding reference
inds=indgen(source_n)
inds=inds(where(inds ne ref))

;exclude variable source(s) from calculation of errors
print,'% CCD_STAT: Click on sources [left button]'
print,'            to be excluded from error calculation.'
print,'% CCD_STAT: Middle mouse button = Done.'


repeat begin

   plot,mean_vec(inds),rms_vec(inds),$
   psym=4,symsize=1,linestyle=0,thick=2,$
   charsize=1.5,charthick=2,$
   xstyle=0,ystyle=0,xthick=2,ythick=2,$
   xtitle='Rel.Source Flux', $
   ytitle='Error of Rel.Flux', $
   title=in, $
   subtitle=''

   d=(max(rms_vec(inds))-min(rms_vec(inds)))/50
   xyouts,mean_vec(inds),rms_vec(inds)+d, $
          sname(inds),charsize=1.2,alignment=0.5

   cursor,x,y,/data
   wait,0.5
   mouse=!err
   if mouse ne 2 then begin
      oplot,[x],[y],psym=1,symsize=4
      wait,0.5
      dist=abs(mean_vec-x)+abs(rms_vec-y)
      minind=where(dist eq min(dist))
      inds=inds(where(inds ne minind(0)))
   endif

endrep until mouse eq 2


;best fit to sigma errors
;w=weights
w=dblarr(n_elements(inds))
w(*)=1.0d0

;coeff=coefficients of rms=sqrt(|coeff(0)|+|coeff(1)|*f+|coeff(2)|*f^2)
;to ensure positive coefficients, where f=rel. flux
coeff=dblarr(3)
coeff(0:1)=LINFIT(mean_vec(inds),rms_vec(inds)^2)
coeff(2)=1.0d-3

r=CCD_CURVE(mean_vec(inds),rms_vec(inds)^2,w, $
            coeff,function_name='CCD_rmsfit',itmax=200)

x=findgen(500)/500.0d0*max(rad)
y=sqrt(abs(coeff(0))+abs(coeff(1))*x+abs(coeff(2))*x^2)

oplot,x,y,linestyle=0,thick=2

corr=rms_vec(inds)/sqrt(r)
corr=max(corr)

oplot,x,y*corr,linestyle=2,thick=2

CCD_WSEL,['Dashed line for error estimate', $
       'Solid line for error estimate'],indsel
if indsel(0) eq 1 then corr=1.0d0

SAVE,/xdr,coeff,corr,extr,ind_extr,filename=out,/verbose

;create a PS-plot
set_plot,'ps'
ps=CCD_APP(out,app='stat',ext='ps')
device,/landscape,filename=ps

plot,mean_vec(inds),rms_vec(inds),$
psym=4,symsize=1,linestyle=0,thick=2,$
charsize=1.5,charthick=2, $
xstyle=0,ystyle=0,xthick=2,ythick=2, $
xtitle='Rel.Source Flux', $
ytitle='Error of Rel.Flux', $
title=in, $
subtitle=''

oplot,x,y*corr,linestyle=2,thick=2

d=(max(rms_vec(inds))-min(rms_vec(inds)))/50
xyouts,mean_vec(inds),rms_vec(inds)+d, $
sname(inds),charsize=1.2,alignment=0.5
      
device,/close
set_plot,'x'


RETURN
END
