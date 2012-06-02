PRO CCD_MEAN, IN=in
;
;+
; NAME:
;	CCD_MEAN
;
; PURPOSE:   
;	Examine statistical data from photometrical time series.
;	Plots mean flux in units of refrence star flux as a function
;	of extraction radius.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_MEAN, [ IN=in ]
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
;
; OUTPUTS:
;	NONE.
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

RESTORE,in,/verbose


si=size(f)
source_n=si(1)
file_n=si(2)
rad_n=si(3)

;show mean flux as a function of extraction radius for given source
message,'Select source for plot',/inf

col=long(sqrt(source_n))>1

XMENU,CCD_CBOX([sname,'DONE']), $
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
   if indsel(0) ne source_n then begin
      plot,rad,meanf(indsel(0),*), $
      psym=4,symsize=1,linestyle=0,thick=2, $
      charsize=1.5,charthick=2, $
      xstyle=0,ystyle=0,xthick=2,ythick=2, $
      xtitle='Extraction Radius [pixel]', $
      ytitle='Mean Rel.Flux',title=in, $
      subtitle='Source Name: '+sname(indsel(0))   
      ERRPLOT,rad, $
      meanf(indsel(0),*)-rms(indsel(0),*),meanf(indsel(0),*)+rms(indsel(0),*)
   endif   
endrep until indsel(0) eq source_n

WIDGET_CONTROL,base,/destroy


RETURN
END
