PRO CCD_ABS, IN=in, OUT=out
;
;+
; NAME:
;	CCD_ABS
;
; PURPOSE:   
;	Plot absorption [mag] and background/pixel [ADU] for
;	photometrical time series.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_ABS, [ IN=in, OUT=out ]
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
;                 defaulted to '*_ABS.PS'.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	PS file '*_ABS.PS'.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Deletes currently active window & creates new one.
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

if not EXIST(out) then out=CCD_APP(in,app='abs',ext='ps')
message,'Output file for graph : '+out,/inf

RESTORE,in,/verbose

si=size(fluxs)
file_n=si(2)
flux=dblarr(file_n)
back=dblarr(file_n)

message,'Select source for flux plot',/inf
CCD_WSEL,sname,indsel
ref=indsel(0)

message,'Select extraction radius for flux plot',/inf
CCD_WSEL,rad,indsel
ref_rad=indsel(0)


for i=0,file_n-1 do $
   if ((fluxb(ref,i) ne 0.0) and (fluxs(ref,i,ref_rad) ne 0.0)) then begin $
   flux(i)=fluxs(ref,i,ref_rad)-areas(ref,i,ref_rad)/areab(ref,i)*fluxb(ref,i)
   back(i)=fluxb(ref,i)/areab(ref,i)
   endif

ind=where(flux ne 0.0)

if ind(0) ne -1 then begin
   subtitle='Source :'+sname(ref)+'   Radius :'+ $
            strtrim(string(rad(ref_rad)),2)+' Pixel'

   wdelete,!d.window
   !p.multi=[0,1,2]
   limit=0.40
   !p.position=[0.15,limit,0.9,0.9]

   plot,time(ind)-time(0),-2.5d0*alog10(flux(ind)/flux(ind(0))), $
   linestyle=0,thick=0.5, $
   charsize=1.5,charthick=2, $
   xstyle=5,ystyle=1,xthick=2,ythick=2.0, $
   ytitle='Rel.Absorption [mag]', $
   title=in

   axis,xaxis=1,xstyle=1,xthick=2,xticks=1,xtickname=[' ',' ']
   !p.position=[0.15,0.15,0.9,limit]

   plot,time(ind)-time(0),back(ind), $
   linestyle=1,thick=0.5, $
   charsize=1.5,charthick=2, $
   xstyle=1,ystyle=1,xthick=2,ythick=2.0, $
   xtitle='Rel.GeocenJD',ytitle='Backgr./Pixel [ADU]', $
   subtitle=subtitle

   ;create a PS-plot
   set_plot,'ps'
   device,/landscape,filename=out

   plot,time(ind)-time(0),-2.5d0*alog10(flux(ind)/flux(ind(0))), $
   linestyle=0,thick=0.5, $
   charsize=1.5,charthick=2, $
   xstyle=1,ystyle=1,xthick=2,ythick=2.0, $
   xtitle='Rel.GeocenJD',ytitle='Rel.Absorption [mag]', $
   title=in

   plot,time(ind)-time(0),back(ind), $
   linestyle=1,thick=0.5, $
   charsize=1.5,charthick=2, $
   xstyle=1,ystyle=1,xthick=2,ythick=2.0, $
   xtitle='Rel.GeocenJD',ytitle='Backgr./Pixel [ADU]', $
   subtitle=subtitle

   !p.multi=0
   device,/close
   set_plot,'x'
endif


RETURN
END
