PRO CCD_VAR, IN=in, STAT=stat
;
;+
; NAME:
;       CCD_VAR
;
; PURPOSE:
;	Show variability index of time series.
;	VI is defined as the auto correlation of the normalized
;       flux data (mean subtracted and each data point divided
;	by it's sigma) in units of the sigma of the auto correlation
;	of the normalized flux data, where the data have been randomly
;	shuffled.
;	If the VI around frame shift 1 deviates >>1 from zero,
;	the data include a significant long term variation of the
;	source.
;	Please note: Program selects all flux data > 0 for analysis
;	and arranges them in order of the starting time of the
;	exposure to avoid data gaps.
;
; CATEGORY:
;       Astronomical Photometry.
;
; CALLING SEQUENCE:
;       CCD_VAR, [ IN=in, STAT=stat ]
;
; INPUTS:
;       NONE.
;
; OPTIONAL INPUTS:
;       NONE.
;
; KEYWORDS:
;       NONE.
;
; OPTIONAL KEYWORDS:
;       IN   : Name of IDL save file with statistical data
;              defaulted to interactive loading of '*.RMS'.
;       STAT : Name of IDL save file with error data
;              defaulted to interactive loading of '*.STT'.
;
; OUTPUTS:
;       NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;       NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       NONE.
;
; RESTRICTIONS:
;       NONE.
;
; REVISION HISTORY:
;       Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


;on_error,2                      ;Return to caller if an error occurs

if not EXIST(in) then $
in=pickfile(title='RMS Data File',$
              file='ccd.rms',filter='*.rms')

message,'RMS data file : '+in,/inf


if not EXIST(stat) then $
stat=pickfile(title='Statistical Data File',$
              file='ccd.stt',filter='*.stt')

message,'Statistical data file : '+stat,/inf


RESTORE,in,/verbose
RESTORE,stat,/verbose

ind_extr=where(abs(rad-extr) eq min(abs(rad-extr)))


si=size(f)
source_n=si(1)
file_n=si(2)
rad_n=si(3)
m=dblarr(file_n)


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

      ;vectors of data for choosen extraction radius
      flux_vec=double(file_n)
      flux_vec=f(indsel(0),*,ind_extr)
      err_vec=corr* $
      sqrt(abs(coeff(0))+abs(coeff(1))*flux_vec+abs(coeff(2))*flux_vec^2)
  
      indnz=where(flux_vec gt 0.0)
      flux_vec=flux_vec(indnz)
      err_vec=err_vec(indnz)

      ;original data vector
      f_vec=(flux_vec-total(flux_vec)/double(n_elements(flux_vec)))/err_vec

      ;data vector with unsorted indices
      f_vec_rand=flux_vec(CCD_IND(n_elements(flux_vec)))

      ncor=n_elements(flux_vec)/2
      var=dblarr(2,ncor)

      for i=0,ncor-1 do begin
         var(0,i(0))=A_CORRELATE(f_vec,i(0))
         var(1,i(0))=A_CORRELATE(f_vec_rand,i(0))
      endfor
  
      meanf=total(var(0,*))/n_elements(var(0,*))
      sigma=sqrt(total ((var(0,*)-meanf)^2)/double(n_elements(var(0,*))))

      plot,var(0,*)/sigma,$
      psym=10,symsize=1,linestyle=0,thick=0.5,$
      charsize=1.5,charthick=2,$
      xstyle=0,ystyle=0,xthick=2,ythick=2,$
      xrange=[1,ncor-1], $
      xtitle='Frame Shift', $
      ytitle='Var.Index', $
      title=in, $
      subtitle='Source Name: '+sname(indsel(0))

   endif

endrep until indsel(0) eq source_n

WIDGET_CONTROL,base,/destroy

RETURN
END
