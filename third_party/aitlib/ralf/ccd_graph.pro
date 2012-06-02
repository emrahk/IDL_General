PRO CCD_GRAPH, IN=in, OUT=out
;
;+
; NAME:
;	CCD_GRAPH
;
; PURPOSE:   
;	Create PS file from lightcurve data.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_GRAPH, [ IN=in, OUT=out ]
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
;       IN    : Name of ST7 data file,
;               defaulted to interactive loading of '*.dat'.
;       OUT   : Name of PS file to be created,
;               defaulted to '*.ps'.
;	
; OUTPUTS:
;	PS file with lightcurve.
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
in=pickfile(title='LC Data File',filter='*.dat')

message,'LC data file              : '+in,/inf


if not EXIST(out) then out=CCD_APP(in,ext='ps')
message,'PS file for lightcurve : '+out,/inf


CCD_RASC,in,dat,head

bary=0
ind=STRPOS(STRUPCASE(head),'BARYCENTRIC')
ind=where(ind ne -1)
if ind(0) ne -1 then bary=1

mag=0
ind=STRPOS(STRUPCASE(head),'DELTA MAG')
ind=where(ind ne -1)
if ind(0) ne -1 then mag=1

num=n_elements(dat)

CCD_ST7RD,data,file=in

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


ytitle='Rel. Flux'
if mag eq 1 then ytitle='Delta Mag.'

xtitle='GeocenJD [GJD-2450000]'
if bary eq 1 then xtitle='BarycJD [BJD-2450000]'

yrange=[min(data(1,*)),max(data(1,*))]
if mag eq 1 then yrange=[max(data(1,*)),min(data(1,*))] 

plot,data(0,*)-50000.0d0,data(1,*)+data(2,*), $
psym=3,symsize=0.5,linestyle=0,thick=0.5, $
charsize=1.5,charthick=2,yrange=yrange, $
xstyle=0,ystyle=0,xthick=2,ythick=2.0, $
xtitle=xtitle,ytitle=ytitle, $
title=in
oplot,data(0,*)-50000.0d0,data(1,*),psym=1,linestyle=0,thick=0.5
oplot,data(0,*)-50000.0d0,data(1,*)-data(2,*),psym=3,linestyle=0,thick=0.5


;create a PS-plot
set_plot,'ps'
device,/landscape,filename=out

plot,data(0,*)-50000.0d0,data(1,*)+data(2,*), $
psym=3,symsize=0.5,linestyle=0,thick=0.5, $
charsize=1.5,charthick=2,yrange=yrange, $
xstyle=0,ystyle=0,xthick=2,ythick=2.0, $
xtitle=xtitle,ytitle=ytitle, $
title=in
oplot,data(0,*)-50000.0d0,data(1,*),psym=1,linestyle=0,thick=0.5
oplot,data(0,*)-50000.0d0,data(1,*)-data(2,*),psym=3,linestyle=0,thick=0.5

device,/close
set_plot,'x'


RETURN
END
