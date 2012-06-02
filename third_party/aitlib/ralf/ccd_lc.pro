PRO CCD_LC, IN=in, OUT=out, STAT=stat, MAG=mag, $
            BARY=bary, COORD=coord
;
;+
; NAME:
;	CCD_LC	
;
; PURPOSE:   
;	Create ascii file of lightcurve data. Program uses
;	extraction radii and error analysis from CCD_RAD
;	and CCD_STAT.
;	File contains the following columns:
;	GeocenJD, rel.flux, 1 sigma error of rel.flux,
;	or if /MAG is set:
;       GeocenJD, delta mag, 1 sigma error of delta mag.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_LC, [ IN=in, OUT=out, STAT=stat, MAG=mag, $
;                 BARY=bary, COORD=coord ]
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
;       IN    : Name of IDL save file with statistical data
;               defaulted to interactive loading of '*.RMS'.
;       OUT   : Name of IDL save file with radii analysis data
;               defaulted to 'CCD.STT'.
;	STAT  : Name of IDL save file with error data
;               defaulted to interactive loading of '*.STT'.
;	MAG   : Write diff. magnitudes to file, instead of rel. flux.
;	BARY  : Apply barycentric correction.
;	CORRD : Name of file with source coordinates for barycentric 
;		correction, defaulted to interactive loading of '*.CRD'.
;               Structure: Arbitrary number of comment lines
;               beginning with %.
;               ONE Line with :
;               RA and Dec as e.g. '17 00 45.2 25 4 32.4' (both 1950.0).
;	
; OUTPUTS:
;	Ascii file '*.DAT' containing lightcurve.
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

message,'RMS data file              : '+in,/inf


if not EXIST(stat) then $
stat=pickfile(title='Statistical Data File',$
              file='ccd.stt',filter='*.stt')

message,'Statistical data file      : '+stat,/inf


if not EXIST(out) then out=CCD_APP(stat,ext='dat')
message,'Output file for lightcurve : '+out,/inf

if (EXIST(bary) and not EXIST(coord)) then begin
   coord=pickfile(title='Source Coordinate File',filter='*.crd')
   message,'Object coordinate file     : '+coord,/inf 
   CCD_RASC,coord,co
   ;convert string to ra & dec in DEGREES.
   STRINGAD,co(0),ra,dec
endif

RESTORE,in,/verbose
RESTORE,stat,/verbose


si=size(f)
source_n=si(1)
file_n=si(2)
rad_n=si(3)

message,'Select source for plot',/inf
message,'SAVE for file output of plotted data set',/inf

col=long(sqrt(source_n))>1

XMENU,CCD_CBOX([sname,'SAVE','EXIT']), $
base=base,buttons=b,column=col,title='Select Source'
WIDGET_CONTROL,/realize,base

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


repeat begin

   event=WIDGET_EVENT(base)
   indsel=where(b eq event.id)
   if indsel(0) lt source_n then begin
      indsave=indsel
      ;vectors of data for choosen extraction radius
      flux_vec=dblarr(file_n)
      flux_vec(*)=f(indsel(0),*,ind_extr)
      err_vec=corr* $
      sqrt(abs(coeff(0))+abs(coeff(1))*flux_vec+abs(coeff(2))*flux_vec^2)

      indnz=where(flux_vec gt 0)
      flux_vec=flux_vec(indnz)
      err_vec=err_vec(indnz)
      time_vec=time(indnz)

      flag_vec=dblarr(n_elements(indnz))
      flag_vec(*)=flag(indsel(0),indnz)
;xx      file_vec=files(indnz)

;xx      for i=0,n_elements(file_vec)-1 do begin
;xx         FDECOMP, file_vec(i),disk,dir,name,qual,ver
;xx         file_vec(i)=name
;xx      endfor

      ytitle='Rel. Flux'
      xtitle='GeocenJD [GJD-2450000]'

      if EXIST(bary) then begin
         xtitle='BarycJD [BJD-2450000]'
         n_times=n_elements(time_vec)
         bary_vec=dblarr(n_times)
         for i=0,n_times-1 do bary_vec(i)=CCD_BCORR(time_vec(i),ra,dec)
         bary_mean=total(bary_vec*60.0d0*24.0d0)/double(n_times)
         time_vec=time_vec+bary
      endif  

      yrange=[min(flux_vec),max(flux_vec)]

      if EXIST(mag) then begin
         err_vec=2.5d0*alog10(exp(1))*err_vec/flux_vec
         flux_vec=-2.5d0*alog10(flux_vec)
	 ytitle='Delta Mag.'
         yrange=[max(flux_vec),min(flux_vec)]
      endif

      plot,time_vec-50000.0d0,flux_vec+err_vec, $
      psym=3,symsize=0.5,linestyle=0,thick=0.5, $
      charsize=1.5,charthick=2,yrange=yrange, $
      xstyle=0,ystyle=0,xthick=2,ythick=2.0, $
      xtitle=xtitle,ytitle=ytitle, $
      title=in, $
      subtitle='Source Name: '+sname(indsel(0))
      oplot,time_vec-50000.0d0,flux_vec,psym=1,linestyle=0,thick=0.5
      oplot,time_vec-50000.0d0,flux_vec-err_vec,psym=3,linestyle=0,thick=0.5

   endif else begin
      
      outf=CCD_APP(out,app=STRTRIM(sname(indsave(0)),2))
      get_lun,unit
      openw,unit,outf
      printf,unit,'% CCD_LC Program Data File'
      printf,unit,'%'
      printf,unit,'%Input file ID : '+in
      printf,unit,'%Source ID : '+sname(indsave)
      printf,unit,'%Extraction radius [pixel] : ',rad(ind_extr)
      printf,unit,'%Flux reference source : '+sname(ref)

      if EXIST(bary) then begin
         printf,unit,'%Object coordinates (1950.0) : '+co(0)
         printf,unit,'%MEAN BARYCENTRIC CORRECTION [min] : ',bary_mean
;xx         printf,unit,'%Shift time image header to UT [h] : ',shift
         printf,unit,'%'
         printf,unit,'%Flags :'
         printf,unit,'%0: Source found & extracted'
         printf,unit,'%2: Source position extrapolated'
         printf,unit,'%'
         if EXIST(mag) then $
         printf,unit, $
         '%Trunc.BarycJD, delta mag., error delta mag., flag, frame' else $
         printf,unit, $
         '%Trunc.BarycJD, rel.flux, error rel.flux, flag, frame'
      endif else begin
;xx         printf,unit,'%Shift time image header to UT [h] : ',shift
         printf,unit,'%'
         printf,unit,'%Flags :'
         printf,unit,'%0: Source found & extracted'
         printf,unit,'%2: Source position extrapolated'
         printf,unit,'%'
         if EXIST(mag) then $
         printf,unit, $
         '%Trunc.GeocenJD, delta mag., error delta mag., flag, frame' else $
         printf,unit, $
         '%Trunc.GeocenJD, rel.flux, error rel.flux, flag, frame' 
      endelse      

      for i=0,n_elements(indnz)-1 do $
      printf,unit, $
      format='(F11.5,"    ",F10.6,"    ",F10.6,"   %flag",I1,"  ",A)', $
      time_vec(i),flux_vec(i),err_vec(i),flag_vec(i);,file_vec(i)

      free_lun,unit

;     create a PS-plot
      set_plot,'ps'
      ps=CCD_APP(out,app=STRTRIM(sname(indsave(0)),2),ext='ps')
      device,/landscape,filename=ps

      plot,time_vec-50000.0d0,flux_vec+err_vec, $
      psym=3,symsize=0.5,linestyle=0,thick=2, $
      charsize=1.5,charthick=2,yrange=yrange, $
      xstyle=0,ystyle=0,xthick=2,ythick=2, $
      xtitle=xtitle,ytitle=ytitle, $
      title=in, $
      subtitle='Source Name: '+sname(indsave(0))
      oplot,time_vec-50000.0d0,flux_vec,psym=1,linestyle=0,thick=0.5
      oplot,time_vec-50000.0d0,flux_vec-err_vec,psym=3,linestyle=0,thick=0.5

      device,/close
      set_plot,'x'

   endelse

endrep until indsel(0) eq (source_n+1)

WIDGET_CONTROL,base,/destroy

WDEL

RETURN
END
